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
package org.onap.so.aaisimulator.controller;

import static org.onap.so.aaisimulator.utils.Constants.PROJECT;
import static org.onap.so.aaisimulator.utils.Constants.PROJECT_URL;
import static org.onap.so.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.so.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.Project;
import org.onap.aai.domain.yang.Relationship;
import org.onap.so.aaisimulator.models.Format;
import org.onap.so.aaisimulator.models.Results;
import org.onap.so.aaisimulator.service.providers.ProjectCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Controller
@RequestMapping(path = PROJECT_URL)
public class ProjectController {
    private static final Logger LOGGER = LoggerFactory.getLogger(ProjectController.class);

    private final ProjectCacheServiceProvider cacheServiceProvider;

    @Autowired
    public ProjectController(final ProjectCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "/{project-name}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putProject(@RequestBody final Project project,
            @PathVariable("project-name") final String projectName, final HttpServletRequest request) {
        LOGGER.info("Will put project for 'project-name': {} ...", project.getProjectName());

        if (project.getResourceVersion() == null || project.getResourceVersion().isEmpty()) {
            project.setResourceVersion(getResourceVersion());

        }
        cacheServiceProvider.putProject(projectName, project);
        return ResponseEntity.accepted().build();

    }

    @GetMapping(value = "/{project-name}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getProject(@PathVariable("project-name") final String projectName,
            @RequestParam(name = "resultIndex", required = false) final Integer resultIndex,
            @RequestParam(name = "resultSize", required = false) final Integer resultSize,
            @RequestParam(name = "format", required = false) final String format, final HttpServletRequest request) {
        LOGGER.info("retrieving project for 'project-name': {} ...", projectName);

        final Optional<Project> optional = cacheServiceProvider.getProject(projectName);
        if (!optional.isPresent()) {
            LOGGER.error("Couldn't find {} in cache", projectName);
            return getRequestErrorResponseEntity(request);
        }

        final Format value = Format.forValue(format);
        switch (value) {
            case RAW:
                final Project project = optional.get();
                LOGGER.info("found project {} in cache", project);
                return ResponseEntity.ok(project);
            case COUNT:
                final Map<String, Object> map = new HashMap<>();
                map.put(PROJECT, 1);
                return ResponseEntity.ok(new Results(map));
            default:
                break;
        }
        LOGGER.error("invalid format type :{}", format);
        return getRequestErrorResponseEntity(request);
    }

    @PutMapping(value = "/{project-name}/relationship-list/relationship",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putProjectRelationShip(@RequestBody final Relationship relationship,
            @PathVariable("project-name") final String projectName, final HttpServletRequest request) {

        LOGGER.info("adding relationship for project-name: {} ...", projectName);
        if (cacheServiceProvider.putProjectRelationShip(projectName, relationship)) {
            LOGGER.info("added project relationship {} in cache", relationship);
            return ResponseEntity.accepted().build();
        }
        LOGGER.error("Couldn't find {} in cache", projectName);
        return getRequestErrorResponseEntity(request);
    }

}
