package org.onap.so.sdc.simulator.providers;

import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.util.Optional;


public interface ResourceProvider {

    Optional<byte[]> getResource(final String csarId);

    Optional<InputStream> getInputStream(final String csarId) throws IOException;
}
