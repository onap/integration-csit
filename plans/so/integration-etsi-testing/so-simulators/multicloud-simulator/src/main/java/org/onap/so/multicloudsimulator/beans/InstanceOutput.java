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
package org.onap.so.multicloudsimulator.beans;

import com.fasterxml.jackson.databind.JsonNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import java.io.IOException;
import java.io.InputStream;

@Component
@PropertySource(value = "data/InstanceOutput.json")
@ConfigurationProperties
public class InstanceOutput {
    private static final Logger LOGGER = LoggerFactory.getLogger(InstanceOutput.class);
    private String template_type;
    private String workload_id;
    private String workload_status;
    public JsonNode workload_status_reason;

    public JsonNode getWorkload_status_reason() {
        return workload_status_reason;
    }

    public void setWorkload_status_reason(final JsonNode workload_status_reason) {
        this.workload_status_reason = workload_status_reason;
    }

    public String getTemplate_type() {
        return template_type;
    }

    public void setTemplate_type(final String template_type) {
        this.template_type = template_type;
    }

    public String getWorkload_id() {
        return workload_id;
    }

    public void setWorkload_id(final String workload_id) {
        this.workload_id = workload_id;
    }

    public String getWorkload_status() {
        return workload_status;
    }

    public void setWorkload_status(final String workload_status) {
        this.workload_status = workload_status;
    }

    public static InputStream getFile(final String file) throws IOException {
        return new ClassPathResource(file).getInputStream();
    }

    public static InputStream getInstance() throws Exception, IOException {
        return getFile("data/InstanceOutput.json");
    }
}
