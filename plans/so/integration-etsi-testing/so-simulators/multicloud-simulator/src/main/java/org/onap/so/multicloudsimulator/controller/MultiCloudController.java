/*-
 * ============LICENSE_START=======================================================
 * Copyright 2021 Huawei Technologies Co., Ltd.
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
 * ============LICENSE_END=========================================================
 */
package org.onap.so.multicloudsimulator.controller;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.apache.commons.io.IOUtils;
import org.onap.so.multicloudsimulator.beans.InstanceOutput;
import org.onap.so.multicloudsimulator.beans.MulticloudCreateResponse;
import org.onap.so.multicloudsimulator.beans.MulticloudInstanceRequest;
import org.onap.so.multicloudsimulator.beans.InstanceResponse;
import org.onap.so.multicloudsimulator.beans.InstanceNameOutput;
import org.onap.so.multicloudsimulator.beans.MulticloudRequest;

import org.springframework.http.ResponseEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMethod;

import java.io.IOException;
import java.io.InputStream;

import static org.onap.so.multicloudsimulator.utils.Constants.BASE_URL;

@RestController
public class MultiCloudController {

    public static final String X_HTTP_METHOD_OVERRIDE = "X-HTTP-Method-Override";
    private static final Logger LOGGER = LoggerFactory.getLogger(MultiCloudController.class);

    @RequestMapping(value = "/v1/instance", method = RequestMethod.POST)
    public ResponseEntity<?> createInstance(@RequestBody MulticloudInstanceRequest req) {
        System.out.println("MultiCloud createInstance ");
        final InstanceResponse InstanceResponse = new InstanceResponse();

        LOGGER.info("Calling v1 instance method");
        return ResponseEntity.ok(req);
    }

    @RequestMapping(value = BASE_URL + "/{cloud-owner}/{cloud-region-id}/infra_workload", method = RequestMethod.GET,
            produces = "application/json")
    public ResponseEntity<?> getInstance(@PathVariable("cloud-owner") String cloudOwner,
            @PathVariable("cloud-region-id") String cloudRegionId,
            @RequestParam(value = "depth", required = false, defaultValue = "0") Integer depth,
            @RequestParam(name = "format", required = false) final String name, final HttpServletRequest request)
            throws Exception {

        LOGGER.info("found CloudOwner {}", cloudOwner);
        LOGGER.info("found cloudRegionId {}", cloudRegionId);
        LOGGER.info("found name {}", name);
        final InputStream instanceOutput = InstanceOutput.getInstance();
        final String output = IOUtils.toString(instanceOutput, "utf-8");

        return ResponseEntity.ok(output);
    }

    @RequestMapping(value = BASE_URL + "/{cloud-owner}/{cloud-region-id}/infra_workload", method = RequestMethod.POST,
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> postCreateInstance(@RequestBody final MulticloudCreateResponse inputRequest,
            @PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String xHttpHeaderOverride,
            final HttpServletRequest request) throws IOException {

        LOGGER.info("Calling postCreateInstance");
        inputRequest.setWorkloadStatusReason(null);

        inputRequest.setWorkloadId("sad_sammet");
        inputRequest.setTemplateType("heat");
        inputRequest.setWorkloadStatus("CREATE_COMPLETE");

        return ResponseEntity.status(201).body(inputRequest);
    }

    @RequestMapping(value = BASE_URL + "/{cloud-owner}/{cloud-region-id}/infra_workload/{workload-id}", method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON)
    public ResponseEntity<?> getInstanceName(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId, @PathVariable("workload-id") final String workloadId,
            @RequestParam(value = "depth", required = false, defaultValue = "0") final Integer depth,
            @RequestParam(name = "format", required = false) final String name, final HttpServletRequest request)
            throws Exception {

        LOGGER.info("Calling getInstanceName");
        LOGGER.info("found CloudOwner {}", cloudOwner);
        LOGGER.info("found cloudRegionId {}", cloudRegionId);
        LOGGER.info("found name {}", name);
        final InputStream instanceNameOutput = InstanceNameOutput.getInstanceName();
        final String output = IOUtils.toString(instanceNameOutput, "utf-8");

        return ResponseEntity.ok(output);
    }

    @RequestMapping(value = BASE_URL + "/{cloud-owner}/{cloud-region-id}/infra_workload/{workload-id}", method = RequestMethod.POST,
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> postCreateInstanceName(@RequestBody final MulticloudRequest inputRequest,
            @PathVariable("cloud-owner") final String cloudOwner, @PathVariable("workload-id") String workloadId,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String xHttpHeaderOverride,
            final HttpServletRequest request) throws IOException {

        LOGGER.info("Calling postCreateInstanceName");

        return ResponseEntity.status(405).build();
    }
}