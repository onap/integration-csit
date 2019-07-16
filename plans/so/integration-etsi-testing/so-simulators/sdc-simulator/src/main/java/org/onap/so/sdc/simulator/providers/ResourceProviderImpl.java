package org.onap.so.sdc.simulator.providers;

import org.onap.so.sdc.simulator.SdcSimulatorController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

@Service
public class ResourceProviderImpl implements ResourceProvider {
    private static final Logger LOGGER = LoggerFactory.getLogger(ResourceProvider.class);
    private static final String DEFAULT_CSAR_PATH = "/csar/unalteredVNFD.csar";


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

        LOGGER.info("Couldn't find file on file system, will return default csar : {}", filePath);
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
        return DEFAULT_CSAR_PATH;
    }
}
