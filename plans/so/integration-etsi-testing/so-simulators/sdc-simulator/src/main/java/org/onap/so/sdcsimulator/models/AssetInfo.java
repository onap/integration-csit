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
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class AssetInfo implements Serializable {

    private static final long serialVersionUID = 3967660000071162759L;

    @JsonProperty("uuid")
    private String uuid;

    @JsonProperty("invariantUUID")
    private String invariantUuid;

    @JsonProperty("name")
    private String name;

    @JsonProperty("version")
    private String version;

    @JsonProperty("toscaModelURL")
    private String toscaModelUrl;

    @JsonProperty("category")
    private String category;

    @JsonProperty("resourceType")
    private String resourceType;

    @JsonProperty("lifecycleState")
    private String lifecycleState;

    @JsonProperty("lastUpdaterUserId")
    private String lastUpdaterUserId;

    @JsonProperty("toscaResourceName")
    private String toscaResourceName;

    public String getUuid() {
        return uuid;
    }

    public void setUuid(final String uuid) {
        this.uuid = uuid;
    }

    public AssetInfo uuid(final String uuid) {
        this.uuid = uuid;
        return this;
    }

    public String getInvariantUuid() {
        return invariantUuid;
    }

    public void setInvariantUuid(final String invariantUuid) {
        this.invariantUuid = invariantUuid;
    }

    public AssetInfo invariantUuid(final String invariantUuid) {
        this.invariantUuid = invariantUuid;
        return this;
    }

    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public AssetInfo name(final String name) {
        this.name = name;
        return this;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(final String version) {
        this.version = version;
    }

    public AssetInfo version(final String version) {
        this.version = version;
        return this;
    }

    public String getToscaModelUrl() {
        return toscaModelUrl;
    }

    public void setToscaModelUrl(final String toscaModelUrl) {
        this.toscaModelUrl = toscaModelUrl;
    }

    public AssetInfo toscaModelUrl(final String toscaModelUrl) {
        this.toscaModelUrl = toscaModelUrl;
        return this;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(final String category) {
        this.category = category;
    }

    public AssetInfo category(final String category) {
        this.category = category;
        return this;
    }

    public String getResourceType() {
        return resourceType;
    }

    public void setResourceType(final String resourceType) {
        this.resourceType = resourceType;
    }

    public AssetInfo resourceType(final String resourceType) {
        this.resourceType = resourceType;
        return this;
    }

    public String getLifecycleState() {
        return lifecycleState;
    }

    public void setLifecycleState(final String lifecycleState) {
        this.lifecycleState = lifecycleState;
    }

    public AssetInfo lifecycleState(final String lifecycleState) {
        this.lifecycleState = lifecycleState;
        return this;
    }

    public String getLastUpdaterUserId() {
        return lastUpdaterUserId;
    }

    public void setLastUpdaterUserId(final String lastUpdaterUserId) {
        this.lastUpdaterUserId = lastUpdaterUserId;
    }

    public AssetInfo lastUpdaterUserId(final String lastUpdaterUserId) {
        this.lastUpdaterUserId = lastUpdaterUserId;
        return this;
    }

    public String getToscaResourceName() {
        return toscaResourceName;
    }

    public void setToscaResourceName(final String toscaResourceName) {
        this.toscaResourceName = toscaResourceName;
    }

    public AssetInfo toscaResourceName(final String toscaResourceName) {
        this.toscaResourceName = toscaResourceName;
        return this;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((category == null) ? 0 : category.hashCode());
        result = prime * result + ((invariantUuid == null) ? 0 : invariantUuid.hashCode());
        result = prime * result + ((lastUpdaterUserId == null) ? 0 : lastUpdaterUserId.hashCode());
        result = prime * result + ((lifecycleState == null) ? 0 : lifecycleState.hashCode());
        result = prime * result + ((name == null) ? 0 : name.hashCode());
        result = prime * result + ((resourceType == null) ? 0 : resourceType.hashCode());
        result = prime * result + ((toscaModelUrl == null) ? 0 : toscaModelUrl.hashCode());
        result = prime * result + ((uuid == null) ? 0 : uuid.hashCode());
        result = prime * result + ((version == null) ? 0 : version.hashCode());

        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (obj instanceof AssetInfo) {
            final AssetInfo other = (AssetInfo) obj;
            return ObjectUtils.nullSafeEquals(category, other.category)
                    && ObjectUtils.nullSafeEquals(invariantUuid, other.invariantUuid)
                    && ObjectUtils.nullSafeEquals(lastUpdaterUserId, other.lastUpdaterUserId)
                    && ObjectUtils.nullSafeEquals(lifecycleState, other.lifecycleState)
                    && ObjectUtils.nullSafeEquals(name, other.name)
                    && ObjectUtils.nullSafeEquals(resourceType, other.resourceType)
                    && ObjectUtils.nullSafeEquals(toscaModelUrl, other.toscaModelUrl)
                    && ObjectUtils.nullSafeEquals(uuid, other.uuid)
                    && ObjectUtils.nullSafeEquals(version, other.version);

        }
        return false;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append("class ");
        sb.append(this.getClass().getName());
        sb.append(" {\n");
        sb.append("    uuid: ").append(uuid).append("\n");
        sb.append("    invariantUuid: ").append(invariantUuid).append("\n");
        sb.append("    name: ").append(name).append("\n");
        sb.append("    version: ").append(version).append("\n");
        sb.append("    toscaModelUrl: ").append(toscaModelUrl).append("\n");
        sb.append("    category: ").append(category).append("\n");
        sb.append("    lifecycleState: ").append(lifecycleState).append("\n");
        sb.append("    lastUpdaterUserId: ").append(lastUpdaterUserId).append("\n");

        sb.append("}");
        return sb.toString();
    }

}
