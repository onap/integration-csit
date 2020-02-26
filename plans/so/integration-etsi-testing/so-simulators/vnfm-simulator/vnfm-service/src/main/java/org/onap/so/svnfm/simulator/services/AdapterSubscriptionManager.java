package org.onap.so.svnfm.simulator.services;

/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2020 Nordix Foundation.
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

import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.InlineResponse2002;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.PkgmSubscriptionRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

/**
 *
 * @author Eoin Hanan (eoin.hanan@est.tech)
 */

@Service
public class AdapterSubscriptionManager{

    @Value("${endpoint.callbackUri}")
    private String baseEndpoint;

    private final RestTemplate restTemplate;

    public AdapterSubscriptionManager(RestTemplateBuilder restTemplateBuilder) {
        this.restTemplate = restTemplateBuilder.build();
    }

    public InlineResponse2002 createSubscription(PkgmSubscriptionRequest pkgmSubscriptionRequest) {
        final String uri =  baseEndpoint + "vnfpkgm/v1/subscription";
        final HttpEntity<?> request = new HttpEntity<>(new HttpHeaders());
        return restTemplate.exchange(uri, HttpMethod.POST, request, InlineResponse2002.class, pkgmSubscriptionRequest).getBody();
    }
}
