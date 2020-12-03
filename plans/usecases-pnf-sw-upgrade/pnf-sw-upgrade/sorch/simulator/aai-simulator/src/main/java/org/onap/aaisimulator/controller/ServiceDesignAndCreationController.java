/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2020 Nordix Foundation.
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
package org.onap.aaisimulator.controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import javax.ws.rs.core.MediaType;
import org.onap.aaisimulator.models.ServiceModelVersion;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static org.onap.aaisimulator.utils.Constants.SERVICE_DESIGN_AND_CREATION_URL;

/**
 * @author Eliezio Oliveira (eliezio.oliveira@est.tech)
 */
@RestController
@RequestMapping(path = SERVICE_DESIGN_AND_CREATION_URL)
public class ServiceDesignAndCreationController {

    private static final Logger LOGGER = LoggerFactory.getLogger(ServiceDesignAndCreationController.class);

    @Value("${SERVICE_DESIGN_AND_CREATION_RESPONSES_LOCATION:./}")
    private String responsesLocation;

    @GetMapping(path = "/models/model/{model-invariant-id}/model-vers",  produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<String> getModelVers(@PathVariable("model-invariant-id") String modelInvariantId) {
        Path responsesPath = Paths.get(responsesLocation).toAbsolutePath();
        LOGGER.info("Will get ModelVer for 'model-invariant-id': {}, looking under {}",
                modelInvariantId, responsesPath.toString());

        Path responsePath = responsesPath.resolve(modelInvariantId + ".json");
        if (!responsePath.toFile().exists()) {
            LOGGER.error("{} not found", responsePath.toString());
            return ResponseEntity.notFound().build();
        }
        try {
            String content = new String(Files.readAllBytes(responsePath), StandardCharsets.UTF_8);
            Gson gson = new GsonBuilder().setPrettyPrinting().create();
            ServiceModelVersion json = gson.fromJson(content, ServiceModelVersion.class);
            String jsonInString = gson.toJson(json);
            LOGGER.info("{} found with {} characters", responsePath.toString(), content.length());
            return ResponseEntity.ok().body(jsonInString);
        } catch (IOException e) {
            LOGGER.error("Failed to read response from {}: {}}", responsePath.toString(), e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}