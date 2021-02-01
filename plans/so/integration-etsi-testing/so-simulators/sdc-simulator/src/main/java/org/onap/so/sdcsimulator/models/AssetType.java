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

import static org.onap.so.sdcsimulator.utils.Constants.CATALOG_URL;
import static org.onap.so.sdcsimulator.utils.Constants.FORWARD_SLASH;
import java.io.File;
import java.io.IOException;
import org.springframework.core.io.Resource;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 *
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public enum AssetType {

    RESOURCES {
        @Override
        public AssetInfo getAssetInfo(final Resource resource) throws IOException {
            return OBJ_MAPPER.readValue(resource.getInputStream(), ResourceAssetInfo.class);
        }

        @Override
        public AssetInfo getAssetInfo(final File file) throws IOException {
            return OBJ_MAPPER.readValue(file, ResourceAssetInfo.class);
        }

        @Override
        public Metadata getMetadata(final Resource resource) throws IOException {
            return OBJ_MAPPER.readValue(resource.getInputStream(), ResourceMetadata.class);
        }

        @Override
        public Metadata getMetadata(final File file) throws IOException {
            return OBJ_MAPPER.readValue(file, ResourceMetadata.class);
        }

    },
    SERVICES {
        @Override
        public AssetInfo getAssetInfo(final Resource resource) throws IOException {
            return OBJ_MAPPER.readValue(resource.getInputStream(), ServiceAssetInfo.class);
        }

        @Override
        public AssetInfo getAssetInfo(final File file) throws IOException {
            return OBJ_MAPPER.readValue(file, ServiceAssetInfo.class);
        }

        @Override
        public Metadata getMetadata(final Resource resource) throws IOException {
            return OBJ_MAPPER.readValue(resource.getInputStream(), ServiceMetadata.class);
        }

        @Override
        public Metadata getMetadata(final File file) throws IOException {
            return OBJ_MAPPER.readValue(file, ServiceMetadata.class);
        }

    };

    private static final ObjectMapper OBJ_MAPPER =
            new ObjectMapper().configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);


    public abstract AssetInfo getAssetInfo(final Resource resource) throws IOException;

    public abstract AssetInfo getAssetInfo(final File file) throws IOException;

    public abstract Metadata getMetadata(final Resource resource) throws IOException;

    public abstract Metadata getMetadata(final File file) throws IOException;

    public String getToscaModelUrl(final String filename) {
        return CATALOG_URL + FORWARD_SLASH + this.toString().toLowerCase() + FORWARD_SLASH + filename + "/toscaModel";
    }

    public AssetInfo getDefaultAssetInfo(final String filename) {
        AssetInfo defaultValue = null;

        if (this.equals(RESOURCES)) {
            defaultValue = new ResourceAssetInfo().subCategory("Network Service");
        } else if (this.equals(SERVICES)) {
            defaultValue = new ServiceAssetInfo().distributionStatus("DISTRIBUTED");
        } else {
            defaultValue = new AssetInfo();
        }

        return defaultValue.uuid(filename).invariantUuid(filename).name(filename).version("1.0")
                .toscaModelUrl(getToscaModelUrl(filename)).category("Generic").lifecycleState("CERTIFIED")
                .lastUpdaterUserId("SDC_SIMULATOR");
    }

}
