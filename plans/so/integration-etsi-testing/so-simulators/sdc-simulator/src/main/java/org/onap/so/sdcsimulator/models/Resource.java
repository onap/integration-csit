/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2021 Nordix Foundation.
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
package org.onap.so.sdcsimulator.models;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;
import org.springframework.util.ObjectUtils;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 *
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class Resource implements Serializable {

    private static final long serialVersionUID = -8014206400770867160L;

    @JsonProperty("resourceInstanceName")
    private String resourceInstanceName;

    @JsonProperty("resourceName")
    private String resourceName;

    @JsonProperty("resourceInvariantUUID")
    private String resourceInvariantUuid;

    @JsonProperty("resourceVersion")
    private String resourceVersion;

    @JsonProperty("resoucreType")
    private String resourceType;

    @JsonProperty("resourceUUID")
    private String resourceUuid;

    @JsonProperty("artifacts")
    private Set<Artifact> artifacts = new HashSet<>();

    public String getResourceInstanceName() {
        return resourceInstanceName;
    }

    public void setResourceInstanceName(final String resourceInstanceName) {
        this.resourceInstanceName = resourceInstanceName;
    }

    public Resource resourceInstanceName(final String resourceInstanceName) {
        this.resourceInstanceName = resourceInstanceName;
        return this;
    }

    public String getResourceName() {
        return resourceName;
    }

    public void setResourceName(final String resourceName) {
        this.resourceName = resourceName;
    }

    public Resource resourceName(final String resourceName) {
        this.resourceName = resourceName;
        return this;
    }

    public String getResourceInvariantUuid() {
        return resourceInvariantUuid;
    }

    public void setResourceInvariantUuid(final String resourceInvariantUuid) {
        this.resourceInvariantUuid = resourceInvariantUuid;
    }

    public Resource resourceInvariantUuid(final String resourceInvariantUuid) {
        this.resourceInvariantUuid = resourceInvariantUuid;
        return this;
    }

    public String getResourceVersion() {
        return resourceVersion;
    }

    public void setResourceVersion(final String resourceVersion) {
        this.resourceVersion = resourceVersion;
    }

    public Resource resourceVersion(final String resourceVersion) {
        this.resourceVersion = resourceVersion;
        return this;
    }

    public String getResourceType() {
        return resourceType;
    }

    public void setResourceType(final String resourceType) {
        this.resourceType = resourceType;
    }

    public Resource resourceType(final String resourceType) {
        this.resourceType = resourceType;
        return this;
    }

    public String getResourceUuid() {
        return resourceUuid;
    }

    public void setResourceUuid(final String resourceUuid) {
        this.resourceUuid = resourceUuid;
    }

    public Resource resourceUUID(final String resourceUuid) {
        this.resourceUuid = resourceUuid;
        return this;
    }

    public Set<Artifact> getArtifacts() {
        return artifacts;
    }

    public void setArtifacts(final Set<Artifact> artifacts) {
        this.artifacts = artifacts;
    }

    public Resource artifacts(final Set<Artifact> artifacts) {
        this.artifacts = artifacts;
        return this;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((artifacts == null) ? 0 : artifacts.hashCode());
        result = prime * result + ((resourceType == null) ? 0 : resourceType.hashCode());
        result = prime * result + ((resourceInstanceName == null) ? 0 : resourceInstanceName.hashCode());
        result = prime * result + ((resourceInvariantUuid == null) ? 0 : resourceInvariantUuid.hashCode());
        result = prime * result + ((resourceName == null) ? 0 : resourceName.hashCode());
        result = prime * result + ((resourceUuid == null) ? 0 : resourceUuid.hashCode());
        result = prime * result + ((resourceVersion == null) ? 0 : resourceVersion.hashCode());
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (obj instanceof Resource) {
            final Resource other = (Resource) obj;
            return ObjectUtils.nullSafeEquals(resourceInstanceName, other.resourceInstanceName)
                    && ObjectUtils.nullSafeEquals(resourceName, other.resourceName)
                    && ObjectUtils.nullSafeEquals(resourceInvariantUuid, other.resourceInvariantUuid)
                    && ObjectUtils.nullSafeEquals(resourceVersion, other.resourceVersion)
                    && ObjectUtils.nullSafeEquals(resourceType, other.resourceType)
                    && ObjectUtils.nullSafeEquals(resourceUuid, other.resourceUuid)
                    && ObjectUtils.nullSafeEquals(artifacts, other.artifacts);
        }
        return false;

    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append("class Resource {\n");
        sb.append("    resourceInstanceName: ").append(resourceInstanceName).append("\n");
        sb.append("    resourceName: ").append(resourceName).append("\n");
        sb.append("    resourceInvariantUuid: ").append(resourceInvariantUuid).append("\n");
        sb.append("    resourceVersion: ").append(resourceVersion).append("\n");
        sb.append("    resourceType: ").append(resourceType).append("\n");
        sb.append("    resourceUuid: ").append(resourceUuid).append("\n");
        sb.append("    artifacts: ").append(artifacts).append("\n");

        sb.append("}");
        return sb.toString();

    }



}
