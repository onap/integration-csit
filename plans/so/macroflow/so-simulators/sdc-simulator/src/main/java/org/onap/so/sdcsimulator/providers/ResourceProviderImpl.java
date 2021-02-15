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

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Optional;
import org.onap.so.sdcsimulator.utils.Constants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

/**
 * @author Eoin Hanan (eoin.hanan@est.tech)
 */
@Service
public class ResourceProviderImpl implements ResourceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(ResourceProvider.class);

    private final String resourceLocation;

    public ResourceProviderImpl(@Value("${sdc.resource.location:/app/csars/}") final String resourceLocation) {
        this.resourceLocation = resourceLocation;
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
    public Optional<InputStream> getInputStream(final String csarId) throws IOException {
        final Path filePath = Paths.get(resourceLocation, csarId + ".csar");
        if (Files.exists(filePath)) {
            return Optional.of(Files.newInputStream(filePath));
        }

        LOGGER.info("Couldn't find file on file system '{}', will return default csar", filePath);
        final ClassPathResource classPathResource = new ClassPathResource(getDefaultCsarPath(), this.getClass());
        if (classPathResource.exists()) {
            return Optional.of(classPathResource.getInputStream());
        }

        LOGGER.error("Couldn't find default csar in classpath ....");
        return Optional.empty();
    }

    /*
     * Used in test
     */
    String getDefaultCsarPath() {
        return Constants.DEFAULT_CSAR_PATH;
    }
}