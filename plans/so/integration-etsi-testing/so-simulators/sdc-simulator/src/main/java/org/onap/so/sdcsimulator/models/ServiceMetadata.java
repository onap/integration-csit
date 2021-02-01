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
public class ServiceMetadata extends Metadata implements Serializable {

    private static final long serialVersionUID = -5677805295913361365L;
    @JsonProperty("distributionStatus")
    private String distributionStatus;

    public String getDistributionStatus() {
        return distributionStatus;
    }

    public void setDistributionStatus(final String distributionStatus) {
        this.distributionStatus = distributionStatus;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + super.hashCode();
        result = prime * result + ((distributionStatus == null) ? 0 : distributionStatus.hashCode());

        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (obj instanceof ServiceMetadata) {
            final ServiceMetadata other = (ServiceMetadata) obj;
            return super.equals(obj) && ObjectUtils.nullSafeEquals(distributionStatus, other.distributionStatus);

        }
        return false;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append(super.toString());
        sb.deleteCharAt(sb.length() - 1);
        sb.append("    distributionStatus: ").append(distributionStatus).append("\n");

        sb.append("}");
        return sb.toString();
    }

}
