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

import static org.onap.so.sdncsimulator.utils.Constants.RESTCONF_CONFIG_END_POINT;
import static org.onap.so.sdncsimulator.utils.Constants.SERVICE_TOPOLOGY_OPERATION;
import static org.onap.so.sdncsimulator.utils.Constants.SERVICE_TOPOLOGY_OPERATION_CACHE;
import static org.onap.so.sdncsimulator.utils.Constants.YES;
import static org.onap.so.sdncsimulator.utils.ObjectUtils.getString;
import static org.onap.so.sdncsimulator.utils.ObjectUtils.getStringOrNull;
import static org.onap.so.sdncsimulator.utils.ObjectUtils.isValid;
import java.time.LocalDateTime;
import java.util.Optional;
import org.onap.sdnc.northbound.client.model.GenericResourceApiInstanceReference;
import org.onap.sdnc.northbound.client.model.GenericResourceApiLastActionEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiLastRpcActionEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiOnapmodelinformationOnapModelInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiOperStatusData;
import org.onap.sdnc.northbound.client.model.GenericResourceApiOrderStatusEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiRequestStatusEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiRequestinformationRequestInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiRpcActionEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiSdncrequestheaderSdncRequestHeader;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServiceModelInfrastructure;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServiceOperationInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicedataServiceData;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServiceinformationServiceInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicemodelinfrastructureService;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicestatusServiceStatus;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicetopologyServiceTopology;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicetopologyidentifierServiceTopologyIdentifier;
import org.onap.so.sdncsimulator.models.OutputRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Service
public class ServiceOperationsCacheServiceProviderimpl extends AbstractCacheServiceProvider
        implements ServiceOperationsCacheServiceProvider {


    private static final Logger LOGGER = LoggerFactory.getLogger(ServiceOperationsCacheServiceProviderimpl.class);

    @Autowired
    public ServiceOperationsCacheServiceProviderimpl(final CacheManager cacheManager) {
        super(cacheManager);
    }

    @Override
    public OutputRequest putServiceOperationInformation(final GenericResourceApiServiceOperationInformation input) {

        final GenericResourceApiSdncrequestheaderSdncRequestHeader requestHeader = input.getSdncRequestHeader();
        final String svcRequestId = requestHeader != null ? requestHeader.getSvcRequestId() : null;

        final GenericResourceApiServiceinformationServiceInformation serviceInformation = input.getServiceInformation();
        if (serviceInformation != null && isValid(serviceInformation.getServiceInstanceId())) {
            final Cache cache = getCache(SERVICE_TOPOLOGY_OPERATION_CACHE);
            final String serviceInstanceId = serviceInformation.getServiceInstanceId();
            LOGGER.info("Adding GenericResourceApiServiceOperationInformation to cache with key: {}",
                    serviceInstanceId);

            final GenericResourceApiServiceModelInfrastructure serviceModelInfrastructure =
                    new GenericResourceApiServiceModelInfrastructure();

            final GenericResourceApiServicemodelinfrastructureService service = getServiceItem(input);
            serviceModelInfrastructure.addServiceItem(service);
            cache.put(serviceInstanceId, serviceModelInfrastructure);

            final GenericResourceApiServicestatusServiceStatus serviceStatus = service.getServiceStatus();

            return new OutputRequest().ackFinalIndicator(serviceStatus.getFinalIndicator())
                    .responseCode(serviceStatus.getResponseCode()).responseMessage(serviceStatus.getResponseMessage())
                    .svcRequestId(svcRequestId).serviceResponseInformation(new GenericResourceApiInstanceReference()
                            .instanceId(serviceInstanceId).objectPath(RESTCONF_CONFIG_END_POINT + serviceInstanceId));

        }
        return new OutputRequest().ackFinalIndicator(YES).responseCode(HttpStatus.BAD_REQUEST.toString())
                .responseMessage("Service instance not found").svcRequestId(svcRequestId);
    }

    @Override
    public Optional<GenericResourceApiServiceModelInfrastructure> getGenericResourceApiServiceModelInfrastructure(
            final String serviceInstanceId) {
        final Cache cache = getCache(SERVICE_TOPOLOGY_OPERATION_CACHE);

        final GenericResourceApiServiceModelInfrastructure value =
                cache.get(serviceInstanceId, GenericResourceApiServiceModelInfrastructure.class);
        if (value != null) {
            return Optional.of(value);
        }
        return Optional.empty();
    }

    @Override
    public void clearAll() {
        clearCahce(SERVICE_TOPOLOGY_OPERATION_CACHE);
    }

    private GenericResourceApiServicemodelinfrastructureService getServiceItem(
            final GenericResourceApiServiceOperationInformation input) {

        final GenericResourceApiServicedataServiceData apiServicedataServiceData =
                new GenericResourceApiServicedataServiceData();

        apiServicedataServiceData.requestInformation(input.getRequestInformation());
        apiServicedataServiceData.serviceRequestInput(input.getServiceRequestInput());
        apiServicedataServiceData.serviceInformation(input.getServiceInformation());
        apiServicedataServiceData.serviceTopology(getServiceTopology(input));
        apiServicedataServiceData.sdncRequestHeader(input.getSdncRequestHeader());
        apiServicedataServiceData.serviceLevelOperStatus(getServiceLevelOperStatus(input));

        final GenericResourceApiServicestatusServiceStatus serviceStatus =
                getServiceStatus(getSvcAction(input.getSdncRequestHeader()), getAction(input.getRequestInformation()),
                        HttpStatus.OK.toString());

        return new GenericResourceApiServicemodelinfrastructureService().serviceData(apiServicedataServiceData)
                .serviceStatus(serviceStatus);
    }

    private String getAction(final GenericResourceApiRequestinformationRequestInformation input) {
        return getString(input.getRequestAction(), "");
    }

    private String getSvcAction(final GenericResourceApiSdncrequestheaderSdncRequestHeader input) {
        return input != null ? getStringOrNull(input.getSvcAction()) : null;
    }

    private GenericResourceApiServicestatusServiceStatus getServiceStatus(final String rpcAction, final String action,
            final String responseCode) {
        return new GenericResourceApiServicestatusServiceStatus().finalIndicator(YES)
                .rpcAction(GenericResourceApiRpcActionEnumeration.fromValue(rpcAction))
                .rpcName(SERVICE_TOPOLOGY_OPERATION).responseTimestamp(LocalDateTime.now().toString())
                .responseCode(responseCode).requestStatus(GenericResourceApiRequestStatusEnumeration.SYNCCOMPLETE)
                .responseMessage("").action(action);
    }

    private GenericResourceApiOperStatusData getServiceLevelOperStatus(
            final GenericResourceApiServiceOperationInformation input) {
        return new GenericResourceApiOperStatusData().orderStatus(GenericResourceApiOrderStatusEnumeration.CREATED)
                .lastAction(GenericResourceApiLastActionEnumeration
                        .fromValue(getRequestAction(input.getRequestInformation())))
                .lastRpcAction(GenericResourceApiLastRpcActionEnumeration
                        .fromValue(getSvcAction(input.getSdncRequestHeader())));
    }

    private String getRequestAction(final GenericResourceApiRequestinformationRequestInformation input) {
        return input != null ? getStringOrNull(input.getRequestAction()) : null;
    }

    private GenericResourceApiServicetopologyServiceTopology getServiceTopology(
            final GenericResourceApiServiceOperationInformation input) {
        final GenericResourceApiOnapmodelinformationOnapModelInformation modelInformation =
                input.getServiceInformation() != null ? input.getServiceInformation().getOnapModelInformation() : null;
        return new GenericResourceApiServicetopologyServiceTopology().onapModelInformation(modelInformation)
                .serviceTopologyIdentifier(getServiceTopologyIdentifier(input));
    }

    private GenericResourceApiServicetopologyidentifierServiceTopologyIdentifier getServiceTopologyIdentifier(
            final GenericResourceApiServiceOperationInformation input) {
        final GenericResourceApiServicetopologyidentifierServiceTopologyIdentifier identifier =
                new GenericResourceApiServicetopologyidentifierServiceTopologyIdentifier();

        if (input.getServiceInformation() != null) {
            final GenericResourceApiServiceinformationServiceInformation serviceInformation =
                    input.getServiceInformation();
            identifier.globalCustomerId(serviceInformation.getGlobalCustomerId())
                    .serviceType(input.getServiceInformation().getSubscriptionServiceType())
                    .serviceInstanceId(input.getServiceInformation().getServiceInstanceId());;
        }

        if (input.getServiceRequestInput() != null) {
            identifier.serviceInstanceName(input.getServiceRequestInput().getServiceInstanceName());
        }

        return identifier;

    }

}
