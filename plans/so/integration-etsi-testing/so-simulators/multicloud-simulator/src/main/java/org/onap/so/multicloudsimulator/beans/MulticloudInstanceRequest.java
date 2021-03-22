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

import java.util.Map;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(value = "true")
public class MulticloudInstanceRequest {

    @JsonProperty(value = "cloud-region")
    private String cloudRegion;

    @JsonProperty(value = "rb-name")
    private String rbName;

    @JsonProperty(value = "rb-version")
    private String rbVersion;

    @JsonProperty(value = "profile-name")
    private String profileName;

    @JsonProperty(value = "labels")
    private Map<String, String> labels;

    @JsonProperty(value = "override-values")
    private Map<String, String> overrideValues;

    @JsonProperty(value = "release-name")
    private String vfModuleUuid;

    public String getCloudRegion() {
        return cloudRegion;
    }

    public void setCloudRegion(final String cloudRegion) {
        this.cloudRegion = cloudRegion;
    }

    public String getRbName() {
        return rbName;
    }

    public void setRbName(final String rbName) {
        this.rbName = rbName;
    }

    public String getRbVersion() {
        return rbVersion;
    }

    public void setRbVersion(final String rbVersion) {
        this.rbVersion = rbVersion;
    }

    public String getProfileName() {
        return profileName;
    }

    public void setProfileName(final String profileName) {
        this.profileName = profileName;
    }

    public Map<String, String> getLabels() {
        return labels;
    }

    public void setLabels(Map<String, String> labels) {
        this.labels = labels;
    }

    public Map<String, String> getOverrideValues() {
        return overrideValues;
    }

    public void setOverrideValues(Map<String, String> overrideValues) {
        this.overrideValues = overrideValues;
    }

    public String getVfModuleUuid() {
        return vfModuleUuid;
    }

    public void setVfModuleUuid(final String vfModuleUuid) {
        this.vfModuleUuid = vfModuleUuid;
    }

}
