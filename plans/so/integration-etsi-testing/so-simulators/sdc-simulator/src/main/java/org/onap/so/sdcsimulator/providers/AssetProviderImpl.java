/*-
 * ============LICENSE_START=======================================================
 *   Copyright (C) 2019 Nordix Foundation.
 * ================================================================================
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  SPDX-License-Identifier: Apache-2.0
 * ============LICENSE_END=========================================================
 */

package org.onap.so.sdcsimulator.providers;

import static org.onap.so.sdcsimulator.utils.Constants.DOT_CSAR;
import static org.onap.so.sdcsimulator.utils.Constants.DOT_JSON;
import static org.onap.so.sdcsimulator.utils.Constants.FORWARD_SLASH;
import static org.onap.so.sdcsimulator.utils.Constants.MAIN_RESOURCE_FOLDER;
import static org.onap.so.sdcsimulator.utils.Constants.WILD_CARD_REGEX;
import static org.springframework.core.io.support.ResourcePatternResolver.CLASSPATH_ALL_URL_PREFIX;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;
import org.onap.so.sdcsimulator.models.AssetInfo;
import org.onap.so.sdcsimulator.models.AssetType;
import org.onap.so.sdcsimulator.models.Metadata;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 */
@Service
public class AssetProviderImpl implements AssetProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(AssetProvider.class);

    private final String resourceLocation;

    private final ResourcePatternResolver resourcePatternResolver;

    @Autowired
    public AssetProviderImpl(@Value("${sdc.resource.location:/app/csars/}") final String resourceLocation,
            final ResourcePatternResolver resourcePatternResolver) {
        this.resourceLocation = resourceLocation;
        this.resourcePatternResolver = resourcePatternResolver;
    }

    @Override
    public Optional<byte[]> getAsset(final String csarId, final AssetType assetType) {
        try {
            final Optional<InputStream> optionalInputStream = getInputStream(csarId, assetType);
            if (optionalInputStream.isPresent()) {
                return Optional.of(StreamUtils.copyToByteArray(optionalInputStream.get()));
            }
        } catch (final IOException ioException) {
            LOGGER.warn("Unable to create file stream ...", ioException);
        }

        return Optional.empty();
    }

    @Override
    public Set<AssetInfo> getAssetInfo(final AssetType assetType) {
        final Set<AssetInfo> result = new HashSet<>();

        final Path dir = Paths.get(resourceLocation).resolve(assetType.toString());
        if (Files.exists(dir)) {
            try (final DirectoryStream<Path> stream = Files.newDirectoryStream(dir, WILD_CARD_REGEX + DOT_CSAR)) {
                for (final Path entry : stream) {
                    final String filename = getFilenameWithoutExtension(entry);
                    result.add(getAssetInfo(assetType, filename, entry));
                }
            } catch (final IOException ioException) {
                LOGGER.error("Unable to find assetInfo on filesystem", ioException);
            }
        }

        try {
            final String classPathdir = MAIN_RESOURCE_FOLDER + assetType.toString() + FORWARD_SLASH;
            final String csarFileLocationPattern = CLASSPATH_ALL_URL_PREFIX + classPathdir + WILD_CARD_REGEX + DOT_CSAR;
            final Resource[] resources = resourcePatternResolver.getResources(csarFileLocationPattern);
            if (resources != null) {

                for (final Resource resource : resources) {
                    final String filename = getFilenameWithoutExtension(resource.getFilename());
                    result.add(getAssetInfo(assetType, filename, resource));
                }
            }

        } catch (final IOException ioException) {
            LOGGER.error("Unable to find assetInfo in classpath", ioException);
        }

        return result;
    }

    @Override
    public Optional<Metadata> getMetadata(final String csarId, final AssetType assetType) {
        final Path dir = Paths.get(resourceLocation).resolve(assetType.toString());
        final Path metadataFilePath = dir.resolve(csarId + DOT_JSON);
        try {
            if (Files.exists(metadataFilePath)) {
                LOGGER.info("Found metadata file on file system using path: {}", metadataFilePath);

                return Optional.of(assetType.getMetadata(metadataFilePath.toFile()));

            }
        } catch (final IOException ioException) {
            LOGGER.error("Unable to find metadata file on filesystem", ioException);
        }


        try {
            final String path = MAIN_RESOURCE_FOLDER + assetType.toString() + FORWARD_SLASH + csarId + DOT_JSON;
            LOGGER.warn("Couldn't find metadata file on file system '{}', will search it in classpath", path);
            final ClassPathResource classPathResource = getClassPathResource(path);
            if (classPathResource.exists()) {
                LOGGER.info("Found metadata file in classpath using path: {}", path);
                return Optional.of(assetType.getMetadata(classPathResource));
            }
        } catch (final IOException ioException) {
            LOGGER.error("Unable to find metadata file in classpath", ioException);
        }
        LOGGER.error("Couldn't find metadata file in classpath ....");
        return Optional.empty();
    }

    private AssetInfo getAssetInfo(final AssetType assetType, final String filename, final Resource resource)
            throws IOException {
        final Resource jsonResource = resource.createRelative(filename + DOT_JSON);

        if (jsonResource != null && jsonResource.exists()) {
            final AssetInfo assetInfo = assetType.getAssetInfo(jsonResource);
            assetInfo.setUuid(filename);
            assetInfo.setToscaModelUrl(assetType.getToscaModelUrl(filename));
            LOGGER.info("Found AssetInfo file in classpath: {}", assetInfo);
            return assetInfo;

        }

        final AssetInfo assetInfo = assetType.getDefaultAssetInfo(filename);
        LOGGER.info("Returning AssetInfo: {}", assetInfo);
        return assetInfo;

    }

    private AssetInfo getAssetInfo(final AssetType assetType, final String filename, final Path entry)
            throws IOException {
        final Path assetJsonFilePath = entry.getParent().resolve(filename + DOT_JSON);
        if (Files.exists(assetJsonFilePath)) {
            final AssetInfo assetInfo = assetType.getAssetInfo(assetJsonFilePath.toFile());
            assetInfo.setUuid(filename);
            assetInfo.setToscaModelUrl(assetType.getToscaModelUrl(filename));
            LOGGER.info("Found AssetInfo file on file system: {}", assetInfo);
            return assetInfo;

        }
        final AssetInfo assetInfo = assetType.getDefaultAssetInfo(filename);
        LOGGER.info("Returning AssetInfo: {}", assetInfo);
        return assetInfo;
    }

    private String getFilenameWithoutExtension(final String filename) {
        return filename.substring(0, filename.lastIndexOf('.'));
    }

    private String getFilenameWithoutExtension(final Path file) {
        return getFilenameWithoutExtension(file.getFileName().toString());
    }

    private Optional<InputStream> getInputStream(final String csarId, final AssetType assetType) throws IOException {
        final Path filePath = Paths.get(resourceLocation, assetType.toString(), csarId + DOT_CSAR);
        if (Files.exists(filePath)) {
            LOGGER.info("Found csar on file system using path: {}", filePath);
            return Optional.of(Files.newInputStream(filePath));
        }
        LOGGER.warn("Couldn't find file on file system '{}', will search it in classpath", filePath);

        final String path = MAIN_RESOURCE_FOLDER + assetType.toString() + FORWARD_SLASH + csarId + DOT_CSAR;
        final ClassPathResource classPathResource = getClassPathResource(path);
        if (classPathResource.exists()) {
            LOGGER.info("Found csar in classpath using path: {}", path);
            return Optional.of(classPathResource.getInputStream());
        }

        LOGGER.error("Couldn't find csar in classpath ....");
        return Optional.empty();
    }

    private ClassPathResource getClassPathResource(final String path) {
        return new ClassPathResource(path, this.getClass());
    }

}
