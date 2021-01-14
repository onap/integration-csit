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

import static org.onap.so.sdcsimulator.utils.Constants.CATALOG_URL;
import static org.onap.so.sdcsimulator.utils.Constants.DOT_CSAR;
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
import org.onap.so.sdcsimulator.models.ResourceArtifact;
import org.onap.so.sdcsimulator.utils.Constants;
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
 * @author Eoin Hanan (eoin.hanan@est.tech)
 */
@Service
public class ResourceProviderImpl implements ResourceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(ResourceProvider.class);

    private final String resourceLocation;

    private final ResourcePatternResolver resourcePatternResolver;

    @Autowired
    public ResourceProviderImpl(@Value("${sdc.resource.location:/app/csars/}") final String resourceLocation,
            final ResourcePatternResolver resourcePatternResolver) {
        this.resourceLocation = resourceLocation;
        this.resourcePatternResolver = resourcePatternResolver;
    }

    @Override
    public Optional<byte[]> getResource(final String csarId) {
        try {
            final Optional<InputStream> optionalInputStream = getInputStream(csarId);
            if (optionalInputStream.isPresent()) {
                return Optional.of(StreamUtils.copyToByteArray(optionalInputStream.get()));
            }
        } catch (final IOException ioException) {
            LOGGER.warn("Unable to create file stream ...", ioException);
        }

        return Optional.empty();
    }

    @Override
    public Set<ResourceArtifact> getResource() {
        final Set<ResourceArtifact> result = new HashSet<>();

        final Path dir = Paths.get(resourceLocation);
        if (Files.exists(dir)) {
            try (final DirectoryStream<Path> stream = Files.newDirectoryStream(dir, WILD_CARD_REGEX + DOT_CSAR)) {
                for (final Path entry : stream) {
                    final String filename = getFilenameWithoutExtension(entry);
                    final ResourceArtifact artifact = getResourceArtifact(filename);
                    result.add(artifact);
                    LOGGER.info("Found resource on file system: {}", artifact);


                }
            } catch (final IOException ioException) {
                LOGGER.error("Unable to find resources on filesystem", ioException);
            }
        }

        try {
            final String csarFileLocationPattern =
                    CLASSPATH_ALL_URL_PREFIX + MAIN_RESOURCE_FOLDER + WILD_CARD_REGEX + DOT_CSAR;
            final Resource[] resources = resourcePatternResolver.getResources(csarFileLocationPattern);
            if (resources != null) {

                for (final Resource resource : resources) {
                    final ResourceArtifact artifact =
                            getResourceArtifact(getFilenameWithoutExtension(resource.getFilename()));
                    result.add(artifact);
                    LOGGER.info("Found resource in classpath: {}", artifact);
                }
            }

        } catch (final IOException ioException) {
            LOGGER.error("Unable to find resources in classpath", ioException);
        }

        return result;
    }

    private ResourceArtifact getResourceArtifact(final String filename) {
        return new ResourceArtifact().uuid(filename).invariantUuid(filename).name(filename).version("1.0")
                .toscaModelUrl(CATALOG_URL + "/resources/" + filename + "/toscaModel").category("Generic")
                .subCategory("Network Service").resourceType("VF").lifecycleState("CERTIFIED")
                .lastUpdaterUserId("SDC_SIMULATOR");
    }

    private String getFilenameWithoutExtension(final String filename) {
        return filename.substring(0, filename.lastIndexOf('.'));
    }

    private String getFilenameWithoutExtension(final Path file) {
        return getFilenameWithoutExtension(file.getFileName().toString());
    }

    private Optional<InputStream> getInputStream(final String csarId) throws IOException {
        final Path filePath = Paths.get(resourceLocation, csarId + DOT_CSAR);
        if (Files.exists(filePath)) {
            LOGGER.info("Found resource in on file system using path: {}", filePath);
            return Optional.of(Files.newInputStream(filePath));
        }
        LOGGER.warn("Couldn't find file on file system '{}', will search it in classpath", filePath);

        final String path = MAIN_RESOURCE_FOLDER + csarId + DOT_CSAR;
        ClassPathResource classPathResource = getClassPathResource(path);
        if (classPathResource.exists()) {
            LOGGER.info("Found resource in classpath using path: {}", path);
            return Optional.of(classPathResource.getInputStream());
        }

        LOGGER.warn("Couldn't find file on file system '{}', will return default csar", filePath);
        classPathResource = getClassPathResource(getDefaultCsarPath());
        if (classPathResource.exists()) {
            LOGGER.info("Found  default csar in classpath");
            return Optional.of(classPathResource.getInputStream());
        }

        LOGGER.error("Couldn't find default csar in classpath ....");
        return Optional.empty();
    }

    private ClassPathResource getClassPathResource(final String path) {
        return new ClassPathResource(path, this.getClass());
    }

    /*
     * Used in test
     */
    String getDefaultCsarPath() {
        return Constants.DEFAULT_CSAR_PATH;
    }
}
