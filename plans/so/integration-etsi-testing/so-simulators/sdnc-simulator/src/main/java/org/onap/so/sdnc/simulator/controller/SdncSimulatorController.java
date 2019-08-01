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
package org.onap.so.sdnc.simulator.controller;

import javax.ws.rs.core.MediaType;
import org.onap.so.sdnc.simulator.utils.Constants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@RestController
@RequestMapping(path = Constants.BASE_URL)
public class SdncSimulatorController {
    private static final Logger LOGGER = LoggerFactory.getLogger(SdncSimulatorController.class);

    @GetMapping(value = "/healthcheck", produces = MediaType.APPLICATION_JSON)
    @ResponseStatus(code = HttpStatus.OK)
    public String healthCheck() {
        LOGGER.info("Running health check ...");
        return Constants.HEALTHY;
    }
}
