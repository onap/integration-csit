/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2019 Nordix Foundation.
 * ================================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * ============LICENSE_END=========================================================
 */

package org.onap.so.sdc.simulator;

import org.onap.so.sdc.simulator.providers.ResourceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.logging.logback.LogbackLoggingSystem;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.*;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.xml.crypto.OctetStreamData;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Optional;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 */
@RestController
@RequestMapping(path = Constant.BASE_URL)
public class SdcSimulatorController {

    private ResourceProvider resourceProvider;

    public SdcSimulatorController(@Autowired final ResourceProvider resourceProvider) {
        this.resourceProvider = resourceProvider;
    }

    private static final Logger LOGGER = LoggerFactory.getLogger(SdcSimulatorController.class);

    @GetMapping(value = "/healthcheck", produces = MediaType.APPLICATION_JSON)
    @ResponseStatus(code = HttpStatus.OK)
    public String healthCheck() {
        LOGGER.info("Running health check ...");
        return Constant.HEALTHY;
    }

    @GetMapping(value = "/resources/{csarId}/toscaModel", produces = MediaType.APPLICATION_OCTET_STREAM)
    public ResponseEntity<byte[]> getCsar(@PathVariable("csarId") final String csarId) throws IOException {
        LOGGER.info("Running getCsar for {} ...", csarId);
        final Optional<byte[]> resource = resourceProvider.getResource(csarId);
        if (resource.isPresent()) {
            return new ResponseEntity<>(resource.get(), HttpStatus.OK);
        }
        LOGGER.error("Unable to find csar: {}",  csarId);

        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }


}
