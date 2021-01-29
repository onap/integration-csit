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

import java.util.HashSet;
import java.util.Set;
import org.springframework.util.ObjectUtils;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 *
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class Metadata extends AssetInfo {

    private static final long serialVersionUID = 2754071491333890698L;

    @JsonProperty("resources")
    private Set<Resource> resources = new HashSet<>();

    @JsonProperty("artifacts")
    private Set<Artifact> artifacts = new HashSet<>();


    public Set<Resource> getResources() {
        return resources;
    }

    public void setResources(final Set<Resource> resources) {
        this.resources = resources;
    }

    public Metadata resources(final Set<Resource> resources) {
        this.resources = resources;
        return this;
    }

    public Set<Artifact> getArtifacts() {
        return artifacts;
    }

    public void setArtifacts(final Set<Artifact> artifacts) {
        this.artifacts = artifacts;
    }

    public Metadata artifacts(Set<Artifact> artifacts) {
        this.artifacts = artifacts;
        return this;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + super.hashCode();
        result = prime * result + ((resources == null) ? 0 : resources.hashCode());
        result = prime * result + ((artifacts == null) ? 0 : artifacts.hashCode());

        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (obj instanceof Metadata) {
            final Metadata other = (Metadata) obj;
            return super.equals(obj) && ObjectUtils.nullSafeEquals(resources, other.resources)
                    && ObjectUtils.nullSafeEquals(artifacts, other.artifacts);

        }
        return false;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append(super.toString());
        sb.deleteCharAt(sb.length() - 1);
        sb.append("    resources: ").append(resources).append("\n");
        sb.append("    artifacts: ").append(artifacts).append("\n");

        sb.append("}");
        return sb.toString();
    }


}
