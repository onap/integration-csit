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

import org.springframework.util.ObjectUtils;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 *
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class ResourceAssetInfo extends AssetInfo {

    private static final long serialVersionUID = -6812049917047990700L;

    @JsonProperty("subCategory")
    private String subCategory;

    public String getSubCategory() {
        return subCategory;
    }

    public void setSubCategory(final String subCategory) {
        this.subCategory = subCategory;
    }

    public ResourceAssetInfo subCategory(final String subCategory) {
        this.subCategory = subCategory;
        return this;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + super.hashCode();
        result = prime * result + ((subCategory == null) ? 0 : subCategory.hashCode());

        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (obj instanceof ResourceAssetInfo) {
            final ResourceAssetInfo other = (ResourceAssetInfo) obj;
            return super.equals(obj) && ObjectUtils.nullSafeEquals(subCategory, other.subCategory);

        }
        return false;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append(super.toString());
        sb.deleteCharAt(sb.length() - 1);
        sb.append("    subCategory: ").append(subCategory).append("\n");

        sb.append("}");
        return sb.toString();
    }

}
