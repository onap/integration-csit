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

import java.io.Serializable;
import org.apache.commons.lang3.builder.ToStringBuilder;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.fasterxml.jackson.databind.JsonNode;

@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonPropertyOrder({ "template_type", "workload_id", "template_response", "workload_status_reason", "workload_status" })
public class MulticloudCreateResponse implements Serializable {
    private static final long serialVersionUID = -5215028275577848311L;

    @JsonProperty("template_type")
    private String templateType;
    @JsonProperty("workload_id")
    private String workloadId;
    @JsonProperty("template_response")
    private JsonNode templateResponse;
    @JsonProperty("workload_status_reason")
    private JsonNode workloadStatusReason;
    @JsonProperty("workload_status")
    private String workloadStatus;

    @JsonCreator
    public MulticloudCreateResponse(@JsonProperty("template_type") String templateType,
            @JsonProperty("workload_id") String workloadId,
            @JsonProperty("template_response") JsonNode templateResponse) {
        this.templateType = templateType;
        this.workloadId = workloadId;
        this.templateResponse = templateResponse;
    }

    public MulticloudCreateResponse() {

    }

    public String getTemplateType() {
        return templateType;
    }

    public void setTemplateType(final String templateType) {
        this.templateType = templateType;
    }

    public String getWorkloadId() {
        return workloadId;
    }

    public void setWorkloadId(final String workloadId) {
        this.workloadId = workloadId;
    }

    public void setTemplateResponse(final JsonNode templateResponse) {
        this.templateResponse = templateResponse;
    }

    public JsonNode getTemplateResponse() {
        return templateResponse;
    }

    public void setWorkloadStatusReason(final JsonNode workloadStatusReason) {
        this.workloadStatusReason = workloadStatusReason;
    }

    public JsonNode getWorkloadStatusReason() {
        return workloadStatusReason;
    }

    public String getWorkloadSstatus() {
        return workloadStatus;
    }

    public void setWorkloadStatus(final String workloadStatus) {
        this.workloadStatus = workloadStatus;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("templateType", templateType).append("workloadId", workloadId)
                .append("templateResponse", templateResponse)
                .append("workload_status_reason", workloadStatusReason.toString())
                .append("workload_status", workloadStatus).toString();
    }
}
