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

package org.onap.so.svnfm.simulator.services;

import java.lang.reflect.InvocationTargetException;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import org.modelmapper.ModelMapper;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.model.CreateVnfRequest;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.model.InlineResponse200;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.model.InlineResponse201;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.model.InlineResponse201.InstantiationStateEnum;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.model.InlineResponse201InstantiatedVnfInfo;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.model.InlineResponse201VimConnectionInfo;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.model.LccnSubscriptionRequest;
import org.onap.so.svnfm.simulator.model.Vnfds;
import org.onap.so.svnfm.simulator.notifications.VnfInstantiationNotification;
import org.onap.so.svnfm.simulator.notifications.VnfmAdapterCreationNotification;
import org.onap.so.svnfm.simulator.repository.VnfOperationRepository;
import org.onap.so.svnfm.simulator.repository.VnfmRepository;
import org.onap.so.svnfm.simulator.config.ApplicationConfig;
import org.onap.so.svnfm.simulator.constants.Constant;
import org.onap.so.svnfm.simulator.model.VnfInstance;
import org.onap.so.svnfm.simulator.model.VnfOperation;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.support.SimpleValueWrapper;
import org.springframework.stereotype.Service;

/**
 *
 * @author Lathishbabu Ganesan (lathishbabu.ganesan@est.tech)
 * @author Ronan Kenny (ronan.kenny@est.tech)
 */
@Service
public class SvnfmService {

    private VnfmRepository vnfmRepository;
    private VnfOperationRepository vnfOperationRepository;
    private VnfmHelper vnfmHelper;
    private ApplicationConfig applicationConfig;
    private CacheManager cacheManager;
    private Vnfds vnfds;
    private SubscriptionService subscriptionService;

    private final ExecutorService executor = Executors.newCachedThreadPool();

    private static final Logger LOGGER = LoggerFactory.getLogger(SvnfmService.class);

    @Autowired
    public SvnfmService(VnfmRepository vnfmRepository, VnfOperationRepository vnfOperationRepository,
            VnfmHelper vnfmHelper, ApplicationConfig applicationConfig, CacheManager cacheManager, Vnfds vnfds,
            SubscriptionService subscriptionService) {
        this.vnfmRepository = vnfmRepository;
        this.vnfOperationRepository = vnfOperationRepository;
        this.vnfmHelper = vnfmHelper;
        this.applicationConfig = applicationConfig;
        this.cacheManager = cacheManager;
        this.vnfds = vnfds;
        this.subscriptionService = subscriptionService;
    }

    public InlineResponse201 createVnf(final CreateVnfRequest createVNFRequest, final String id) {
        InlineResponse201 inlineResponse201 = null;
        try {
            final VnfInstance vnfInstance = vnfmHelper.createVnfInstance(createVNFRequest, id);
            vnfmRepository.save(vnfInstance);
            final Thread creationNotification = new Thread(new VnfmAdapterCreationNotification());
            creationNotification.start();
            inlineResponse201 = vnfmHelper.getInlineResponse201(vnfInstance);
            LOGGER.debug("Response from Create VNF {}", inlineResponse201);
        } catch (IllegalAccessException | InvocationTargetException e) {
            LOGGER.error("Failed in Create Vnf", e);
        }
        return inlineResponse201;
    }

    @CachePut(value = Constant.IN_LINE_RESPONSE_201_CACHE, key = "#id")
    public void updateVnf(final InstantiationStateEnum instantiationState,
            final InlineResponse201InstantiatedVnfInfo instantiatedVnfInfo, final String id,
            final List<InlineResponse201VimConnectionInfo> vimConnectionInfo) {
        final InlineResponse201 vnf = getVnf(id);
        vnf.setInstantiatedVnfInfo(instantiatedVnfInfo);
        vnf.setInstantiationState(instantiationState);
        vnf.setVimConnectionInfo(vimConnectionInfo);
    }

    public String instantiateVnf(final String vnfId) {
        final VnfOperation vnfOperation = buildVnfOperation(InlineResponse200.OperationEnum.INSTANTIATE, vnfId);
        vnfOperationRepository.save(vnfOperation);
        executor.submit(new InstantiateOperationProgressor(vnfOperation, this, vnfOperationRepository,
                applicationConfig, vnfds, subscriptionService));
        return vnfOperation.getId();
    }

    private VnfOperation buildVnfOperation(final InlineResponse200.OperationEnum operation, final String vnfId) {
        final VnfOperation vnfOperation = new VnfOperation();
        vnfOperation.setId(UUID.randomUUID().toString());
        vnfOperation.setOperation(operation);
        vnfOperation.setOperationState(InlineResponse200.OperationStateEnum.STARTING);
        vnfOperation.setVnfInstanceId(vnfId);
        return vnfOperation;
    }

    public InlineResponse200 getOperationStatus(final String operationId) {
        LOGGER.info("Getting operation status with id: {}", operationId);
        final Thread instantiationNotification = new Thread(new VnfInstantiationNotification());
        instantiationNotification.start();
        for (final VnfOperation operation : vnfOperationRepository.findAll()) {
            LOGGER.info("Operation found: {}", operation);
            if (operation.getId().equals(operationId)) {
                final ModelMapper modelMapper = new ModelMapper();
                return modelMapper.map(operation, InlineResponse200.class);
            }
        }
        return null;
    }

    public InlineResponse201 getVnf(final String vnfId) {
        final Cache ca = cacheManager.getCache(Constant.IN_LINE_RESPONSE_201_CACHE);
        if (ca == null)
            return null;
        final SimpleValueWrapper wrapper = (SimpleValueWrapper) ca.get(vnfId);
        if (wrapper == null)
            return null;
        final InlineResponse201 inlineResponse201 = (InlineResponse201) wrapper.get();
        if (inlineResponse201 != null) {
            LOGGER.info("Cache Read Successful");
            return inlineResponse201;
        }
        return null;
    }

    public String terminateVnf(final String vnfId) {
        final VnfOperation vnfOperation = buildVnfOperation(InlineResponse200.OperationEnum.TERMINATE, vnfId);
        vnfOperationRepository.save(vnfOperation);
        executor.submit(new TerminateOperationProgressor(vnfOperation, this, vnfOperationRepository, applicationConfig,
                vnfds, subscriptionService));
        return vnfOperation.getId();
    }

    public void registerSubscription(final LccnSubscriptionRequest subscription) {
        subscriptionService.registerSubscription(subscription);
    }
}
