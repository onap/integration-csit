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

import static org.onap.sdnc.northbound.client.model.GenericResourceApiOrderStatusEnumeration.CREATED;
import static org.onap.sdnc.northbound.client.model.GenericResourceApiOrderStatusEnumeration.PENDINGCREATE;
import static org.onap.sdnc.northbound.client.model.GenericResourceApiRequestStatusEnumeration.SYNCCOMPLETE;
import static org.onap.so.sdncsimulator.utils.Constants.RESTCONF_CONFIG_END_POINT;
import static org.onap.so.sdncsimulator.utils.Constants.SERVICE_DATA_VNFS_VNF;
import static org.onap.so.sdncsimulator.utils.Constants.SERVICE_TOPOLOGY_OPERATION;
import static org.onap.so.sdncsimulator.utils.Constants.SERVICE_TOPOLOGY_OPERATION_CACHE;
import static org.onap.so.sdncsimulator.utils.Constants.VNF_DATA_VNF_TOPOLOGY;
import static org.onap.so.sdncsimulator.utils.Constants.YES;
import static org.onap.so.sdncsimulator.utils.ObjectUtils.getString;
import static org.onap.so.sdncsimulator.utils.ObjectUtils.getStringOrNull;
import static org.onap.so.sdncsimulator.utils.ObjectUtils.isValid;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import javax.validation.Valid;
import org.onap.sdnc.northbound.client.model.GenericResourceApiInstanceReference;
import org.onap.sdnc.northbound.client.model.GenericResourceApiLastActionEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiLastRpcActionEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiOnapmodelinformationOnapModelInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiOperStatusData;
import org.onap.sdnc.northbound.client.model.GenericResourceApiOrderStatusEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiRequestinformationRequestInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiRpcActionEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiSdncrequestheaderSdncRequestHeader;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServiceOperationInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicedataServiceData;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicedataServicedataVnfs;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicedataServicedataVnfsVnf;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicedataServicedataVnfsVnfVnfData;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServiceinformationServiceInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicemodelinfrastructureService;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicestatusServiceStatus;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicetopologyServiceTopology;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicetopologyidentifierServiceTopologyIdentifier;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVnfOperationInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVnfinformationVnfInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVnfrequestinputVnfRequestInput;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVnftopologyVnfTopology;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVnftopologyidentifierstructureVnfTopologyIdentifierStructure;
import org.onap.so.sdncsimulator.models.Output;
import org.onap.aaisimulator.cache.provider.AbstractCacheServiceProvider;
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

    private static final String HTTP_STATUS_BAD_REQUEST = Integer.toString(HttpStatus.BAD_REQUEST.value());
    private static final String HTTP_STATUS_OK = Integer.toString(HttpStatus.OK.value());
    private static final String EMPTY_STRING = "";
    private static final Logger LOGGER = LoggerFactory.getLogger(ServiceOperationsCacheServiceProviderimpl.class);

    @Autowired
    public ServiceOperationsCacheServiceProviderimpl(final CacheManager cacheManager) {
        super(cacheManager);
    }

    @Override
    public Output putServiceOperationInformation(final GenericResourceApiServiceOperationInformation input) {

        final GenericResourceApiSdncrequestheaderSdncRequestHeader requestHeader = input.getSdncRequestHeader();
        final String svcRequestId = getSvcRequestId(requestHeader);

        final GenericResourceApiServiceinformationServiceInformation serviceInformation = input.getServiceInformation();
        if (serviceInformation != null && isValid(serviceInformation.getServiceInstanceId())) {
            final String serviceInstanceId = serviceInformation.getServiceInstanceId();

            if (isServiceOperationInformationNotExists(serviceInstanceId, input)) {
                final Cache cache = getCache(SERVICE_TOPOLOGY_OPERATION_CACHE);
                LOGGER.info("Adding GenericResourceApiServiceOperationInformation to cache with key: {}",
                        serviceInstanceId);

                final GenericResourceApiServicemodelinfrastructureService service =
                        getServiceItem(input, serviceInstanceId);
                cache.put(serviceInstanceId, service);

                final GenericResourceApiServicestatusServiceStatus serviceStatus = service.getServiceStatus();

                return new Output().ackFinalIndicator(serviceStatus.getFinalIndicator())
                        .responseCode(serviceStatus.getResponseCode())
                        .responseMessage(serviceStatus.getResponseMessage()).svcRequestId(svcRequestId)
                        .serviceResponseInformation(new GenericResourceApiInstanceReference()
                                .instanceId(serviceInstanceId).objectPath(getObjectPath(serviceInstanceId)));
            }
            LOGGER.error("serviceInstanceId: {} already exists", serviceInstanceId);
            return new Output().ackFinalIndicator(YES).responseCode(HTTP_STATUS_BAD_REQUEST)
                    .responseMessage("serviceInstanceId: " + serviceInstanceId + " already exists")
                    .svcRequestId(svcRequestId);
        }

        LOGGER.error(
                "Unable to add GenericResourceApiServiceOperationInformation in cache due to invalid input: {}... ",
                input);
        return new Output().ackFinalIndicator(YES).responseCode(HTTP_STATUS_BAD_REQUEST)
                .responseMessage("Service instance not found").svcRequestId(svcRequestId);

    }

    @Override
    public Output deleteServiceOperationInformation(final GenericResourceApiServiceOperationInformation input) {
        final GenericResourceApiServiceinformationServiceInformation serviceInformation = input.getServiceInformation();
        final String svcRequestId = getSvcRequestId(input.getSdncRequestHeader());

        if (serviceInformation != null && isValid(serviceInformation.getServiceInstanceId())) {
            final String serviceInstanceId = serviceInformation.getServiceInstanceId();
            final Optional<GenericResourceApiServicemodelinfrastructureService> optional =
                    getGenericResourceApiServicemodelinfrastructureService(serviceInstanceId);
            if (optional.isPresent()) {
                final Cache cache = getCache(SERVICE_TOPOLOGY_OPERATION_CACHE);
                LOGGER.info("Deleting GenericResourceApiServiceOperationInformation from cache using key: {}",
                        serviceInstanceId);
                cache.evict(serviceInstanceId);
                return new Output().ackFinalIndicator(YES).responseCode(HTTP_STATUS_OK)
                        .responseMessage(EMPTY_STRING).svcRequestId(svcRequestId).serviceResponseInformation(
                                new GenericResourceApiInstanceReference().instanceId(serviceInstanceId));
            }
            LOGGER.error(
                    "Unable to find existing GenericResourceApiServiceModelInfrastructure in cache using service instance id: {}",
                    serviceInstanceId);

        }
        LOGGER.error("Unable to remove service instance from cache due to invalid input: {}... ", input);
        return new Output().ackFinalIndicator(YES).responseCode(HTTP_STATUS_BAD_REQUEST)
                .responseMessage("Unable to remove service").svcRequestId(svcRequestId);
    }

    @Override
    public Optional<GenericResourceApiServicemodelinfrastructureService> getGenericResourceApiServicemodelinfrastructureService(
            final String serviceInstanceId) {
        final Cache cache = getCache(SERVICE_TOPOLOGY_OPERATION_CACHE);

        final GenericResourceApiServicemodelinfrastructureService value =
                cache.get(serviceInstanceId, GenericResourceApiServicemodelinfrastructureService.class);
        if (value != null) {
            LOGGER.info("Found {} in cahce for service instance id: {}", value, serviceInstanceId);
            return Optional.of(value);
        }
        LOGGER.error("Unable to find GenericResourceApiServiceModelInfrastructure in cache for service instance id: {}",
                serviceInstanceId);
        return Optional.empty();
    }

    @Override
    public Output putVnfOperationInformation(final GenericResourceApiVnfOperationInformation input) {

        final GenericResourceApiServiceinformationServiceInformation serviceInformation = input.getServiceInformation();
        final GenericResourceApiVnfinformationVnfInformation vnfInformation = input.getVnfInformation();

        final GenericResourceApiSdncrequestheaderSdncRequestHeader requestHeader = input.getSdncRequestHeader();
        final String svcRequestId = getSvcRequestId(requestHeader);

        if (serviceInformation != null && isValid(serviceInformation.getServiceInstanceId()) && vnfInformation != null
                && isValid(vnfInformation.getVnfId())) {
            final String serviceInstanceId = serviceInformation.getServiceInstanceId();
            final String vnfId = vnfInformation.getVnfId();
            final Optional<GenericResourceApiServicemodelinfrastructureService> optional =
                    getGenericResourceApiServicemodelinfrastructureService(serviceInstanceId);
            if (optional.isPresent()) {
                final GenericResourceApiServicemodelinfrastructureService service = optional.get();
                final GenericResourceApiServicedataServiceData serviceData = service.getServiceData();
                if (serviceData != null) {
                    final List<GenericResourceApiServicedataServicedataVnfsVnf> vnfsList = getVnfs(serviceData);
                    final GenericResourceApiLastRpcActionEnumeration svcAction =
                            GenericResourceApiLastRpcActionEnumeration.fromValue(getSvcAction(requestHeader));

                    if (ifVnfNotExists(vnfId, svcAction, vnfsList)) {
                        vnfsList.add(getGenericResourceApiServicedataVnf(serviceInstanceId, vnfId, input));

                        final GenericResourceApiServicestatusServiceStatus serviceStatus = service.getServiceStatus();

                        return new Output().ackFinalIndicator(serviceStatus.getFinalIndicator())
                                .responseCode(serviceStatus.getResponseCode())
                                .responseMessage(serviceStatus.getResponseMessage()).svcRequestId(svcRequestId)
                                .serviceResponseInformation(new GenericResourceApiInstanceReference()
                                        .instanceId(serviceInstanceId).objectPath(getObjectPath(serviceInstanceId)))
                                .vnfResponseInformation(new GenericResourceApiInstanceReference().instanceId(vnfId)
                                        .objectPath(getObjectPath(serviceInstanceId, vnfId)));
                    }
                    LOGGER.error("vnfId: {} already exists with SVC Action: {}", vnfId, svcAction);
                    return new Output().ackFinalIndicator(YES).responseCode(HTTP_STATUS_BAD_REQUEST)
                            .responseMessage("vnfId: " + vnfId + " already exists").svcRequestId(svcRequestId);
                }
            }
            LOGGER.error(
                    "Unable to find existing GenericResourceApiServiceModelInfrastructure in cache using service instance id: {}",
                    serviceInstanceId);

        }
        LOGGER.error(
                "Unable to add GenericResourceApiServiceOperationInformation in cache due to invalid input: {}... ",
                input);
        return new Output().ackFinalIndicator(YES).responseCode(HTTP_STATUS_BAD_REQUEST)
                .responseMessage("Unable to add vnf").svcRequestId(svcRequestId);
    }

    @Override
    public Output deleteVnfOperationInformation(final GenericResourceApiVnfOperationInformation input) {
        final GenericResourceApiServiceinformationServiceInformation serviceInformation = input.getServiceInformation();
        final GenericResourceApiVnfinformationVnfInformation vnfInformation = input.getVnfInformation();

        final GenericResourceApiSdncrequestheaderSdncRequestHeader requestHeader = input.getSdncRequestHeader();
        final String svcRequestId = getSvcRequestId(requestHeader);

        if (serviceInformation != null && isValid(serviceInformation.getServiceInstanceId()) && vnfInformation != null
                && isValid(vnfInformation.getVnfId())) {
            final String serviceInstanceId = serviceInformation.getServiceInstanceId();
            final String vnfId = vnfInformation.getVnfId();
            final Optional<GenericResourceApiServicemodelinfrastructureService> optional =
                    getGenericResourceApiServicemodelinfrastructureService(serviceInstanceId);
            if (optional.isPresent()) {
                final GenericResourceApiServicemodelinfrastructureService service = optional.get();
                final GenericResourceApiServicedataServiceData serviceData = service.getServiceData();
                if (serviceData != null) {
                    final List<GenericResourceApiServicedataServicedataVnfsVnf> vnfsList = getVnfs(serviceData);
                    final Optional<GenericResourceApiServicedataServicedataVnfsVnf> vnfInstanceOptional =
                            getExistingVnf(vnfId, vnfsList);

                    if (vnfInstanceOptional.isPresent()) {
                        vnfsList.removeIf(vnf -> {
                            final String existingVnfId = vnf.getVnfId();
                            if (existingVnfId != null && existingVnfId.equals(vnfId)) {
                                LOGGER.info("Remove vnf with id: {} ... ", existingVnfId);
                                return true;
                            }
                            return false;
                        });

                        return new Output().ackFinalIndicator(YES).responseCode(HTTP_STATUS_OK)
                                .responseMessage(EMPTY_STRING).svcRequestId(svcRequestId)
                                .serviceResponseInformation(
                                        new GenericResourceApiInstanceReference().instanceId(serviceInstanceId))
                                .vnfResponseInformation(new GenericResourceApiInstanceReference().instanceId(vnfId));
                    }

                }
            }
            LOGGER.error(
                    "Unable to find existing GenericResourceApiServiceModelInfrastructure in cache using service instance id: {}",
                    serviceInstanceId);

        }
        LOGGER.error("Unable to remove vnf instance from cache due to invalid input: {}... ", input);
        return new Output().ackFinalIndicator(YES).responseCode(HTTP_STATUS_BAD_REQUEST)
                .responseMessage("Unable to remove vnf").svcRequestId(svcRequestId);

    }

    private String getSvcRequestId(final GenericResourceApiSdncrequestheaderSdncRequestHeader requestHeader) {
        return requestHeader != null ? requestHeader.getSvcRequestId() : null;
    }

    @Override
    public void clearAll() {
        clearCache(SERVICE_TOPOLOGY_OPERATION_CACHE);
    }

    private String getObjectPath(final String serviceInstanceId, final String vnfId) {
        return getObjectPath(serviceInstanceId) + SERVICE_DATA_VNFS_VNF + vnfId + VNF_DATA_VNF_TOPOLOGY;
    }

    private String getObjectPath(final String serviceInstanceId) {
        return RESTCONF_CONFIG_END_POINT + serviceInstanceId;
    }


    private boolean ifVnfNotExists(final String vnfId, final GenericResourceApiLastRpcActionEnumeration svcAction,
            final List<GenericResourceApiServicedataServicedataVnfsVnf> vnfsList) {
        final Optional<GenericResourceApiServicedataServicedataVnfsVnf> optional = getExistingVnf(vnfId, vnfsList);
        if (optional.isPresent()) {
            final GenericResourceApiServicedataServicedataVnfsVnf existingVnf = optional.get();
            final GenericResourceApiServicedataServicedataVnfsVnfVnfData vnfData = existingVnf.getVnfData();

            if (vnfData != null && vnfData.getVnfLevelOperStatus() != null
                    && vnfData.getVnfLevelOperStatus().getLastRpcAction() != null) {
                final GenericResourceApiLastRpcActionEnumeration existingVnflastRpcAction =
                        vnfData.getVnfLevelOperStatus().getLastRpcAction();
                if (existingVnflastRpcAction.equals(svcAction)) {
                    LOGGER.error("Found vnf with id: {} and LastRpcAction: {} same as SvcAction:  {}", vnfId,
                            existingVnflastRpcAction, svcAction);
                    return false;
                }
                LOGGER.warn("Will remove and replace existing vnf with id: {} as SvcAction is changed from {} to {}",
                        vnfId, existingVnflastRpcAction, svcAction);
                vnfsList.removeIf(vnf -> vnf.getVnfId() != null && vnf.getVnfId().equals(vnfId));

            }
        }

        return true;
    }

    private Optional<GenericResourceApiServicedataServicedataVnfsVnf> getExistingVnf(final String vnfId,
            final List<GenericResourceApiServicedataServicedataVnfsVnf> vnfsList) {
        return vnfsList.stream().filter(vnf -> vnf.getVnfId() != null && vnf.getVnfId().equals(vnfId)).findFirst();
    }

    private List<GenericResourceApiServicedataServicedataVnfsVnf> getVnfs(
            final GenericResourceApiServicedataServiceData serviceData) {
        GenericResourceApiServicedataServicedataVnfs vnfs = serviceData.getVnfs();
        if (vnfs == null) {
            vnfs = new GenericResourceApiServicedataServicedataVnfs();
            serviceData.setVnfs(vnfs);
        }

        List<GenericResourceApiServicedataServicedataVnfsVnf> vnfsList = vnfs.getVnf();
        if (vnfsList == null) {
            vnfsList = new ArrayList<>();
            vnfs.setVnf(vnfsList);
        }
        return vnfsList;
    }

    private GenericResourceApiServicedataServicedataVnfsVnf getGenericResourceApiServicedataVnf(
            final String serviceInstanceId, final String vnfId, final GenericResourceApiVnfOperationInformation input) {
        return new GenericResourceApiServicedataServicedataVnfsVnf().vnfId(vnfId).vnfData(getVnfData(input));
    }

    private GenericResourceApiServicedataServicedataVnfsVnfVnfData getVnfData(
            final GenericResourceApiVnfOperationInformation input) {

        final GenericResourceApiServicedataServicedataVnfsVnfVnfData vnfData =
                new GenericResourceApiServicedataServicedataVnfsVnfVnfData();

        vnfData.vnfLevelOperStatus(
                getServiceLevelOperStatus(PENDINGCREATE, input.getRequestInformation(), input.getSdncRequestHeader()));
        vnfData.serviceInformation(input.getServiceInformation());
        vnfData.sdncRequestHeader(input.getSdncRequestHeader());
        vnfData.vnfInformation(input.getVnfInformation());
        vnfData.requestInformation(input.getRequestInformation());
        vnfData.vnfRequestInput(input.getVnfRequestInput());

        vnfData.vnfTopology(getVnfTopology(input.getVnfInformation(), input.getVnfRequestInput()));

        return vnfData;
    }

    private GenericResourceApiVnftopologyVnfTopology getVnfTopology(
            final GenericResourceApiVnfinformationVnfInformation vnfInformation,
            final GenericResourceApiVnfrequestinputVnfRequestInput vnfRequestInput) {

        final GenericResourceApiVnftopologyVnfTopology apiVnftopologyVnfTopology =
                new GenericResourceApiVnftopologyVnfTopology();

        if (vnfInformation != null) {
            apiVnftopologyVnfTopology.onapModelInformation(vnfInformation.getOnapModelInformation());
            apiVnftopologyVnfTopology.vnfTopologyIdentifierStructure(getTopologyIdentifierStructure(vnfInformation));
        }
        if (vnfRequestInput != null) {
            apiVnftopologyVnfTopology.tenant(vnfRequestInput.getTenant());
            apiVnftopologyVnfTopology.aicClli(vnfRequestInput.getAicClli());
            apiVnftopologyVnfTopology.aicCloudRegion(vnfRequestInput.getAicCloudRegion());
        }
        return apiVnftopologyVnfTopology;
    }

    private GenericResourceApiVnftopologyidentifierstructureVnfTopologyIdentifierStructure getTopologyIdentifierStructure(
            @Valid final GenericResourceApiVnfinformationVnfInformation vnfInformation) {
        return new GenericResourceApiVnftopologyidentifierstructureVnfTopologyIdentifierStructure()
                .vnfId(vnfInformation.getVnfId()).vnfName(vnfInformation.getVnfName())
                .vnfType(vnfInformation.getVnfType());
    }

    private GenericResourceApiServicemodelinfrastructureService getServiceItem(
            final GenericResourceApiServiceOperationInformation input, final String serviceInstanceId) {

        final GenericResourceApiServicedataServiceData apiServicedataServiceData =
                new GenericResourceApiServicedataServiceData();

        apiServicedataServiceData.requestInformation(input.getRequestInformation());
        apiServicedataServiceData.serviceRequestInput(input.getServiceRequestInput());
        apiServicedataServiceData.serviceInformation(input.getServiceInformation());
        apiServicedataServiceData.serviceTopology(getServiceTopology(input));
        apiServicedataServiceData.sdncRequestHeader(input.getSdncRequestHeader());
        apiServicedataServiceData.serviceLevelOperStatus(getServiceLevelOperStatus(input));

        final GenericResourceApiServicestatusServiceStatus serviceStatus =
                getServiceStatus(getSvcAction(input.getSdncRequestHeader()),
                        getRequestAction(input.getRequestInformation()), HTTP_STATUS_OK);

        return new GenericResourceApiServicemodelinfrastructureService().serviceData(apiServicedataServiceData)
                .serviceStatus(serviceStatus).serviceInstanceId(serviceInstanceId);
    }

    private String getSvcAction(final GenericResourceApiSdncrequestheaderSdncRequestHeader input) {
        return input != null ? getStringOrNull(input.getSvcAction()) : null;
    }

    private GenericResourceApiServicestatusServiceStatus getServiceStatus(final String rpcAction, final String action,
            final String responseCode) {
        return new GenericResourceApiServicestatusServiceStatus().finalIndicator(YES)
                .rpcAction(GenericResourceApiRpcActionEnumeration.fromValue(rpcAction))
                .rpcName(SERVICE_TOPOLOGY_OPERATION).responseTimestamp(LocalDateTime.now().toString())
                .responseCode(responseCode).requestStatus(SYNCCOMPLETE).responseMessage(EMPTY_STRING).action(action);
    }

    private GenericResourceApiOperStatusData getServiceLevelOperStatus(
            final GenericResourceApiServiceOperationInformation input) {
        return getServiceLevelOperStatus(CREATED, input.getRequestInformation(), input.getSdncRequestHeader());
    }

    private GenericResourceApiOperStatusData getServiceLevelOperStatus(
            final GenericResourceApiOrderStatusEnumeration statusEnumeration,
            final GenericResourceApiRequestinformationRequestInformation requestInformation,
            final GenericResourceApiSdncrequestheaderSdncRequestHeader sdncRequestHeader) {
        return new GenericResourceApiOperStatusData().orderStatus(statusEnumeration)
                .lastAction(GenericResourceApiLastActionEnumeration.fromValue(getRequestAction(requestInformation)))
                .lastRpcAction(GenericResourceApiLastRpcActionEnumeration.fromValue(getSvcAction(sdncRequestHeader)));
    }

    private String getRequestAction(final GenericResourceApiRequestinformationRequestInformation input) {
        return getRequestAction(input, EMPTY_STRING);
    }

    private String getRequestAction(final GenericResourceApiRequestinformationRequestInformation input,
            final String defaultValue) {
        return input != null ? getString(input.getRequestAction(), defaultValue) : defaultValue;
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

    private boolean isServiceOperationInformationNotExists(final String serviceInstanceId,
            final GenericResourceApiServiceOperationInformation input) {
        final GenericResourceApiSdncrequestheaderSdncRequestHeader requestHeader = input.getSdncRequestHeader();
        final Optional<GenericResourceApiServicemodelinfrastructureService> optional =
                getGenericResourceApiServicemodelinfrastructureService(serviceInstanceId);

        if (optional.isPresent()) {
            final GenericResourceApiServicemodelinfrastructureService existingService = optional.get();
            final GenericResourceApiServicestatusServiceStatus serviceStatus = existingService.getServiceStatus();
            if (serviceStatus != null) {
                final GenericResourceApiRpcActionEnumeration rpcAction = serviceStatus.getRpcAction();
                final String svcAction = getSvcAction(requestHeader);
                if (rpcAction != null && rpcAction.toString().equals(svcAction)) {
                    LOGGER.error("Found Service with id: {} and RpcAction: {} same as SvcAction:  {}",
                            serviceInstanceId, rpcAction, svcAction);
                    return false;
                }

                final Cache cache = getCache(SERVICE_TOPOLOGY_OPERATION_CACHE);
                LOGGER.info(
                        "Deleting existing GenericResourceApiServiceOperationInformation from cache using key: {} as SvcAction is changed from {} to {}",
                        serviceInstanceId, rpcAction, svcAction);
                cache.evict(serviceInstanceId);
            }
        }
        return true;

    }

}
