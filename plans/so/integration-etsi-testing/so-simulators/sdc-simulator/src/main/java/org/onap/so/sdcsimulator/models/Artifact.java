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
import org.springframework.util.ObjectUtils;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 *
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class Artifact implements Serializable {

    private static final long serialVersionUID = 4106531921550274666L;

    @JsonProperty("artifactName")
    private String artifactName;

    @JsonProperty("artifactType")
    private String artifactType;

    @JsonProperty("artifactURL")
    private String artifactUrl;

    @JsonProperty("artifactDescription")
    private String artifactDescription;

    @JsonProperty("artifactChecksum")
    private String artifactChecksum;

    @JsonProperty("artifactUUID")
    private String artifactUuid;

    @JsonProperty("artifactVersion")
    private String artifactVersion;

    @JsonProperty("artifactLabel")
    private String artifactLabel;

    @JsonProperty("artifactGroupType")
    private String artifactGroupType;

    public String getArtifactName() {
        return artifactName;
    }

    public void setArtifactName(final String artifactName) {
        this.artifactName = artifactName;
    }

    public Artifact artifactName(final String artifactName) {
        this.artifactName = artifactName;
        return this;
    }

    public String getArtifactType() {
        return artifactType;
    }

    public void setArtifactType(final String artifactType) {
        this.artifactType = artifactType;
    }

    public Artifact artifactType(final String artifactType) {
        this.artifactType = artifactType;
        return this;
    }

    public String getArtifactUrl() {
        return artifactUrl;
    }

    public void setArtifactUrl(final String artifactUrl) {
        this.artifactUrl = artifactUrl;
    }

    public Artifact artifactUrl(final String artifactURL) {
        this.artifactUrl = artifactURL;
        return this;
    }

    public String getArtifactDescription() {
        return artifactDescription;
    }

    public void setArtifactDescription(final String artifactDescription) {
        this.artifactDescription = artifactDescription;
    }

    public Artifact artifactDescription(final String artifactDescription) {
        this.artifactDescription = artifactDescription;
        return this;
    }

    public String getArtifactChecksum() {
        return artifactChecksum;
    }

    public void setArtifactChecksum(final String artifactChecksum) {
        this.artifactChecksum = artifactChecksum;
    }

    public Artifact artifactChecksum(final String artifactChecksum) {
        this.artifactChecksum = artifactChecksum;
        return this;
    }

    public String getArtifactUuid() {
        return artifactUuid;
    }

    public void setArtifactUuid(final String artifactUuid) {
        this.artifactUuid = artifactUuid;
    }

    public Artifact artifactUuid(final String artifactUuid) {
        this.artifactUuid = artifactUuid;
        return this;
    }

    public String getArtifactVersion() {
        return artifactVersion;
    }

    public void setArtifactVersion(final String artifactVersion) {
        this.artifactVersion = artifactVersion;
    }

    public Artifact artifactVersion(final String artifactVersion) {
        this.artifactVersion = artifactVersion;
        return this;
    }

    public String getArtifactLabel() {
        return artifactLabel;
    }

    public void setArtifactLabel(final String artifactLabel) {
        this.artifactLabel = artifactLabel;
    }

    public Artifact artifactLabel(final String artifactLabel) {
        this.artifactLabel = artifactLabel;
        return this;
    }

    public String getArtifactGroupType() {
        return artifactGroupType;
    }

    public void setArtifactGroupType(final String artifactGroupType) {
        this.artifactGroupType = artifactGroupType;
    }

    public Artifact artifactGroupType(final String artifactGroupType) {
        this.artifactGroupType = artifactGroupType;
        return this;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((artifactChecksum == null) ? 0 : artifactChecksum.hashCode());
        result = prime * result + ((artifactDescription == null) ? 0 : artifactDescription.hashCode());
        result = prime * result + ((artifactGroupType == null) ? 0 : artifactGroupType.hashCode());
        result = prime * result + ((artifactLabel == null) ? 0 : artifactLabel.hashCode());
        result = prime * result + ((artifactName == null) ? 0 : artifactName.hashCode());
        result = prime * result + ((artifactType == null) ? 0 : artifactType.hashCode());
        result = prime * result + ((artifactUrl == null) ? 0 : artifactUrl.hashCode());
        result = prime * result + ((artifactUuid == null) ? 0 : artifactUuid.hashCode());
        result = prime * result + ((artifactVersion == null) ? 0 : artifactVersion.hashCode());
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (obj instanceof AssetInfo) {
            final Artifact other = (Artifact) obj;
            return ObjectUtils.nullSafeEquals(artifactChecksum, other.artifactChecksum)
                    && ObjectUtils.nullSafeEquals(artifactDescription, other.artifactDescription)
                    && ObjectUtils.nullSafeEquals(artifactGroupType, other.artifactGroupType)
                    && ObjectUtils.nullSafeEquals(artifactLabel, other.artifactLabel)
                    && ObjectUtils.nullSafeEquals(artifactGroupType, other.artifactGroupType)
                    && ObjectUtils.nullSafeEquals(artifactName, other.artifactName)
                    && ObjectUtils.nullSafeEquals(artifactType, other.artifactType)
                    && ObjectUtils.nullSafeEquals(artifactUrl, other.artifactUrl)
                    && ObjectUtils.nullSafeEquals(artifactUuid, other.artifactUuid)
                    && ObjectUtils.nullSafeEquals(artifactVersion, other.artifactVersion);


        }
        return false;

    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append("class Artifact {\n");
        sb.append("    artifactName: ").append(artifactName).append("\n");
        sb.append("    artifactType: ").append(artifactType).append("\n");
        sb.append("    artifactURL: ").append(artifactUrl).append("\n");
        sb.append("    artifactDescription: ").append(artifactDescription).append("\n");
        sb.append("    artifactChecksum: ").append(artifactChecksum).append("\n");
        sb.append("    artifactUUID: ").append(artifactUuid).append("\n");
        sb.append("    artifactVersion: ").append(artifactVersion).append("\n");
        sb.append("    artifactLabel: ").append(artifactLabel).append("\n");
        sb.append("    artifactGroupType: ").append(artifactGroupType).append("\n");

        sb.append("}");
        return sb.toString();

    }
}
