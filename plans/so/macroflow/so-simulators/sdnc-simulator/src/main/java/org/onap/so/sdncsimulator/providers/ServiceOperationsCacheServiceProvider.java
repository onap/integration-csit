/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2019 Nordix Foundation.
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
package org.onap.so.sdncsimulator.providers;

import java.util.List;
import java.util.Optional;

import org.onap.sdnc.northbound.client.model.*;
import org.onap.so.sdncsimulator.models.Output;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public interface ServiceOperationsCacheServiceProvider {

    Output putServiceOperationInformation(
            final GenericResourceApiServiceOperationInformation apiServiceOperationInformation);

    Output deleteServiceOperationInformation(
            final GenericResourceApiServiceOperationInformation serviceOperationInformation);

    Optional<GenericResourceApiServicemodelinfrastructureService> getGenericResourceApiServicemodelinfrastructureService(
            final String serviceInstanceId);

    Output putVnfOperationInformation(final GenericResourceApiVnfOperationInformation apiVnfOperationInformation);

    Output deleteVnfOperationInformation(final GenericResourceApiVnfOperationInformation apiVnfOperationInformation);
    
    Output putVfModuleOperationInformation(final GenericResourceApiVfModuleOperationInformation apiVfModuleOperationInformation);

    //public void getVnfsList(List<GenericResourceApiServicedataServicedataVnfsVnf> vnfsList);
    
    public GenericResourceApiVfModuleTopology getGenericResourceApiVfModuleTopology();
    public GenericResourceApiVnfTopology getGenericResourceApiVnfTopology();

    void clearAll();

}
