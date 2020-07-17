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
package org.onap.so.sdncsimulator.controller;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.onap.sdnc.northbound.client.model.GenericResourceApiRpcActionEnumeration.ASSIGN;
import static org.onap.sdnc.northbound.client.model.GenericResourceApiRpcActionEnumeration.DEACTIVATE;
import static org.onap.so.sdncsimulator.controller.TestUtils.getInvalidRequestInput;
import static org.onap.so.sdncsimulator.controller.TestUtils.getRequestInput;
import static org.onap.so.sdncsimulator.controller.TestUtils.getServiceRequestWithRequestActionDeleteServiceAndSvcActionDeactivateInput;
import static org.onap.so.sdncsimulator.controller.TestUtils.getServiceRequestWithRequestActionDeleteServiceInput;
import static org.onap.so.sdncsimulator.controller.TestUtils.getVnfRequestInput;
import static org.onap.so.sdncsimulator.controller.TestUtils.getVnfRequestWithRequestActionDeleteVnfInput;
import static org.onap.so.sdncsimulator.controller.TestUtils.getVnfRequestWithSvcActionActivateInput;
import java.util.Optional;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.sdnc.northbound.client.model.GenericResourceApiInstanceReference;
import org.onap.sdnc.northbound.client.model.GenericResourceApiLastRpcActionEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiOperStatusData;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicedataServicedataVnfsVnf;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServicemodelinfrastructureService;
import org.onap.so.sdncsimulator.models.InputRequest;
import org.onap.so.sdncsimulator.models.Output;
import org.onap.so.sdncsimulator.models.OutputRequest;
import org.onap.so.sdncsimulator.providers.ServiceOperationsCacheServiceProvider;
import org.onap.so.sdncsimulator.utils.Constants;
import org.onap.aaisimulator.model.UserCredentials;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ActiveProfiles("test")
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Configuration
public class OperationsControllerTest {

    private static final String HTTP_STATUS_BAD_REQUEST = Integer.toString(HttpStatus.BAD_REQUEST.value());
    private static final String HTTP_STATUS_OK = Integer.toString(HttpStatus.OK.value());

    private static final String SVC_REQUEST_ID = "04fc9f50-87b8-430d-a232-ef24bd6c4150";

    private static final String VNF_SVC_REQUEST_ID = "8fd2622b-01fc-424d-bfc8-f48bcd64e546";

    private static final String SERVICE_INSTANCE_ID = "ccece8fe-13da-456a-baf6-41b3a4a2bc2b";

    private static final String SERVICE_TOPOLOGY_OPERATION_URL = "/GENERIC-RESOURCE-API:service-topology-operation/";

    private static final String VNF_TOPOLOGY_OPERATION_URL = "/GENERIC-RESOURCE-API:vnf-topology-operation/";

    private static final String VNF_INSTANCE_ID = "dfd02fb5-d7fb-4aac-b3c4-cd6b60058701";

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private ServiceOperationsCacheServiceProvider cacheServiceProvider;

    @Autowired
    private UserCredentials userCredentials;


    @Test
    public void test_postServiceOperationInformation_successfullyAddedToCache() throws Exception {

        final HttpEntity<?> httpEntity = new HttpEntity<>(getRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
        assertTrue(responseEntity.hasBody());

        final OutputRequest actualOutputRequest = responseEntity.getBody();
        assertNotNull(actualOutputRequest);

        final Output actualObject = actualOutputRequest.getOutput();

        assertNotNull(actualObject);
        assertEquals(HTTP_STATUS_OK, actualObject.getResponseCode());
        assertEquals(Constants.YES, actualObject.getAckFinalIndicator());
        assertEquals(SVC_REQUEST_ID, actualObject.getSvcRequestId());
        assertNotNull(actualObject.getServiceResponseInformation());

        final GenericResourceApiInstanceReference acutalReference = actualObject.getServiceResponseInformation();
        assertEquals(Constants.RESTCONF_CONFIG_END_POINT + SERVICE_INSTANCE_ID, acutalReference.getObjectPath());
        assertEquals(SERVICE_INSTANCE_ID, acutalReference.getInstanceId());
        final Optional<GenericResourceApiServicemodelinfrastructureService> optional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertTrue(optional.isPresent());

        final GenericResourceApiServicemodelinfrastructureService service = optional.get();
        assertNotNull(service.getServiceInstanceId());
        assertEquals(SERVICE_INSTANCE_ID, service.getServiceInstanceId());
        assertNotNull(service.getServiceData());
        assertNotNull(service.getServiceStatus());

    }

    @Test
    public void test_postServiceOperationInformation_NullInputRequest_badRequest() throws Exception {

        final HttpEntity<?> httpEntity = new HttpEntity<>(new InputRequest<>(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.BAD_REQUEST, responseEntity.getStatusCode());
    }

    @Test
    public void test_postServiceOperationInformation_NullServiceInstanceId_badRequest() throws Exception {

        final HttpEntity<?> httpEntity = new HttpEntity<>(getInvalidRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.BAD_REQUEST, responseEntity.getStatusCode());
        assertTrue(responseEntity.hasBody());

        final OutputRequest actualOutputRequest = responseEntity.getBody();
        assertNotNull(actualOutputRequest);

        final Output actualObject = actualOutputRequest.getOutput();
        assertNotNull(actualObject);
        assertEquals(HTTP_STATUS_BAD_REQUEST, actualObject.getResponseCode());
        assertEquals(SVC_REQUEST_ID, actualObject.getSvcRequestId());
        assertEquals(Constants.YES, actualObject.getAckFinalIndicator());

    }

    @Test
    public void test_postVnfOperationInformation_successfullyAddToExistingServiceInCache() throws Exception {
        final HttpEntity<?> httpEntity = new HttpEntity<>(getRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());

        final HttpEntity<?> httpVnfEntity = new HttpEntity<>(getVnfRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseVnfEntity =
                restTemplate.exchange(getVnfUrl(), HttpMethod.POST, httpVnfEntity, OutputRequest.class);
        assertEquals(HttpStatus.OK, responseVnfEntity.getStatusCode());
        assertTrue(responseVnfEntity.hasBody());

        final OutputRequest actualOutputRequest = responseVnfEntity.getBody();
        assertNotNull(actualOutputRequest);
        assertNotNull(actualOutputRequest.getOutput());

        final Output actualObject = actualOutputRequest.getOutput();

        assertEquals(HTTP_STATUS_OK, actualObject.getResponseCode());
        assertEquals(Constants.YES, actualObject.getAckFinalIndicator());
        assertEquals(VNF_SVC_REQUEST_ID, actualObject.getSvcRequestId());
        assertNotNull(actualObject.getServiceResponseInformation());

        final GenericResourceApiInstanceReference acutalReference = actualObject.getServiceResponseInformation();
        assertEquals(Constants.RESTCONF_CONFIG_END_POINT + SERVICE_INSTANCE_ID, acutalReference.getObjectPath());
        assertEquals(SERVICE_INSTANCE_ID, acutalReference.getInstanceId());
        final Optional<GenericResourceApiServicemodelinfrastructureService> optional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertTrue(optional.isPresent());

        final GenericResourceApiInstanceReference actualvnfInformation = actualObject.getVnfResponseInformation();
        assertEquals(VNF_INSTANCE_ID, actualvnfInformation.getInstanceId());

        final Optional<GenericResourceApiServicemodelinfrastructureService> serviceOptional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertTrue(serviceOptional.isPresent());

        final GenericResourceApiServicemodelinfrastructureService service = serviceOptional.get();
        assertNotNull(service.getServiceInstanceId());
        assertNotNull(service.getServiceData().getVnfs().getVnf());
        assertNotNull(service.getServiceData());
        assertNotNull(service.getServiceData().getVnfs());
        assertNotNull(service.getServiceData().getVnfs().getVnf());
        assertEquals(1, service.getServiceData().getVnfs().getVnf().size());
        final GenericResourceApiServicedataServicedataVnfsVnf vnf = service.getServiceData().getVnfs().getVnf().get(0);
        assertNotNull(vnf.getVnfId());
        assertEquals(VNF_INSTANCE_ID, vnf.getVnfId());
        assertNotNull(vnf.getVnfData());
    }

    @Test
    public void test_postSameVnfOperationInformationTwice_ShouldReturnbadRequest() throws Exception {

        final HttpEntity<?> httpEntity = new HttpEntity<>(getRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());

        final HttpEntity<?> httpVnfEntity = new HttpEntity<>(getVnfRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseVnfEntity =
                restTemplate.exchange(getVnfUrl(), HttpMethod.POST, httpVnfEntity, OutputRequest.class);
        assertEquals(HttpStatus.OK, responseVnfEntity.getStatusCode());
        assertTrue(responseVnfEntity.hasBody());

        final OutputRequest actualOutputRequest = responseVnfEntity.getBody();
        assertNotNull(actualOutputRequest);
        assertNotNull(actualOutputRequest.getOutput());

        final ResponseEntity<OutputRequest> badResponse =
                restTemplate.exchange(getVnfUrl(), HttpMethod.POST, httpVnfEntity, OutputRequest.class);

        final OutputRequest badOutputRequest = badResponse.getBody();
        assertNotNull(badOutputRequest);

        final Output actualObject = badOutputRequest.getOutput();
        assertNotNull(actualObject);
        assertEquals(HTTP_STATUS_BAD_REQUEST, actualObject.getResponseCode());
        assertEquals(VNF_SVC_REQUEST_ID, actualObject.getSvcRequestId());
        assertEquals(Constants.YES, actualObject.getAckFinalIndicator());

    }

    @Test
    public void test_postVnfOperationInformationWithSvcActionChanged_successfullyAddToExistingServiceInCache()
            throws Exception {
        final HttpEntity<?> httpEntity = new HttpEntity<>(getRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());

        final HttpEntity<?> httpVnfWithSvcActionAssignEntity = new HttpEntity<>(getVnfRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> response = restTemplate.exchange(getVnfUrl(), HttpMethod.POST,
                httpVnfWithSvcActionAssignEntity, OutputRequest.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.hasBody());

        final HttpEntity<?> httpVnfEntity =
                new HttpEntity<>(getVnfRequestWithSvcActionActivateInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseVnfEntity =
                restTemplate.exchange(getVnfUrl(), HttpMethod.POST, httpVnfEntity, OutputRequest.class);
        assertEquals(HttpStatus.OK, responseVnfEntity.getStatusCode());
        assertTrue(responseVnfEntity.hasBody());

        final OutputRequest actualOutputRequest = responseVnfEntity.getBody();
        assertNotNull(actualOutputRequest);
        assertNotNull(actualOutputRequest.getOutput());

        final Output actualObject = actualOutputRequest.getOutput();

        assertEquals(HTTP_STATUS_OK, actualObject.getResponseCode());
        assertEquals(Constants.YES, actualObject.getAckFinalIndicator());
        assertEquals(VNF_SVC_REQUEST_ID, actualObject.getSvcRequestId());
        assertNotNull(actualObject.getServiceResponseInformation());

        final GenericResourceApiInstanceReference acutalReference = actualObject.getServiceResponseInformation();
        assertEquals(Constants.RESTCONF_CONFIG_END_POINT + SERVICE_INSTANCE_ID, acutalReference.getObjectPath());
        assertEquals(SERVICE_INSTANCE_ID, acutalReference.getInstanceId());
        final Optional<GenericResourceApiServicemodelinfrastructureService> optional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertTrue(optional.isPresent());

        final GenericResourceApiInstanceReference actualvnfInformation = actualObject.getVnfResponseInformation();
        assertEquals(VNF_INSTANCE_ID, actualvnfInformation.getInstanceId());

        final Optional<GenericResourceApiServicemodelinfrastructureService> serviceOptional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertTrue(serviceOptional.isPresent());

        final GenericResourceApiServicemodelinfrastructureService service = serviceOptional.get();
        assertNotNull(service.getServiceInstanceId());
        assertNotNull(service.getServiceData().getVnfs().getVnf());
        assertNotNull(service.getServiceData());
        assertNotNull(service.getServiceData().getVnfs());
        assertNotNull(service.getServiceData().getVnfs().getVnf());
        assertEquals(1, service.getServiceData().getVnfs().getVnf().size());
        final GenericResourceApiServicedataServicedataVnfsVnf vnf = service.getServiceData().getVnfs().getVnf().get(0);
        assertNotNull(vnf.getVnfId());
        assertEquals(VNF_INSTANCE_ID, vnf.getVnfId());
        assertNotNull(vnf.getVnfData());
        final GenericResourceApiOperStatusData vnfLevelOperStatus = vnf.getVnfData().getVnfLevelOperStatus();
        assertNotNull(vnfLevelOperStatus);
        assertEquals(GenericResourceApiLastRpcActionEnumeration.ACTIVATE, vnfLevelOperStatus.getLastRpcAction());

    }

    @Test
    public void test_postVnfOperationInformation_successfullyRemoveVnfFromExistingServiceInCache() throws Exception {
        final HttpEntity<?> httpEntity = new HttpEntity<>(getRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());

        final HttpEntity<?> httpAddVnfEntity = new HttpEntity<>(getVnfRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseAddVnfEntity =
                restTemplate.exchange(getVnfUrl(), HttpMethod.POST, httpAddVnfEntity, OutputRequest.class);
        assertEquals(HttpStatus.OK, responseAddVnfEntity.getStatusCode());

        Optional<GenericResourceApiServicemodelinfrastructureService> serviceOptional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertTrue(serviceOptional.isPresent());

        GenericResourceApiServicemodelinfrastructureService service = serviceOptional.get();
        assertNotNull(service.getServiceInstanceId());
        assertNotNull(service.getServiceData().getVnfs().getVnf());
        assertNotNull(service.getServiceData());
        assertNotNull(service.getServiceData().getVnfs());
        assertNotNull(service.getServiceData().getVnfs().getVnf());
        assertFalse(service.getServiceData().getVnfs().getVnf().isEmpty());

        final HttpEntity<?> httpRemoveVnfEntity =
                new HttpEntity<>(getVnfRequestWithRequestActionDeleteVnfInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseRemoveVnfEntity =
                restTemplate.exchange(getVnfUrl(), HttpMethod.POST, httpRemoveVnfEntity, OutputRequest.class);
        assertEquals(HttpStatus.OK, responseRemoveVnfEntity.getStatusCode());

        final OutputRequest actualOutputRequest = responseRemoveVnfEntity.getBody();
        assertNotNull(actualOutputRequest);
        assertNotNull(actualOutputRequest.getOutput());

        final Output actualObject = actualOutputRequest.getOutput();

        assertEquals(HTTP_STATUS_OK, actualObject.getResponseCode());
        assertEquals(Constants.YES, actualObject.getAckFinalIndicator());
        assertEquals(VNF_SVC_REQUEST_ID, actualObject.getSvcRequestId());

        serviceOptional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertTrue(serviceOptional.isPresent());

        service = serviceOptional.get();
        assertNotNull(service.getServiceInstanceId());
        assertNotNull(service.getServiceData().getVnfs().getVnf());
        assertNotNull(service.getServiceData());
        assertNotNull(service.getServiceData().getVnfs());
        assertNotNull(service.getServiceData().getVnfs().getVnf());
        assertTrue(service.getServiceData().getVnfs().getVnf().isEmpty());


    }

    @Test
    public void test_postServiceOperationInformation_withActionDeleteServiceInstance_successfullyRemoveServiceFromExistingServiceInCache()
            throws Exception {
        final HttpEntity<?> httpEntity = new HttpEntity<>(getRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
        Optional<GenericResourceApiServicemodelinfrastructureService> serviceOptional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertTrue(serviceOptional.isPresent());

        final GenericResourceApiServicemodelinfrastructureService service = serviceOptional.get();
        assertNotNull(service.getServiceInstanceId());

        final HttpEntity<?> httpRemoveServiceEntity =
                new HttpEntity<>(getServiceRequestWithRequestActionDeleteServiceInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseRemoveServiceEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpRemoveServiceEntity, OutputRequest.class);
        assertEquals(HttpStatus.OK, responseRemoveServiceEntity.getStatusCode());

        final OutputRequest actualOutputRequest = responseRemoveServiceEntity.getBody();
        assertNotNull(actualOutputRequest);
        assertNotNull(actualOutputRequest.getOutput());

        final Output actualObject = actualOutputRequest.getOutput();

        assertEquals(HTTP_STATUS_OK, actualObject.getResponseCode());
        assertEquals(Constants.YES, actualObject.getAckFinalIndicator());
        assertEquals(SVC_REQUEST_ID, actualObject.getSvcRequestId());

        serviceOptional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertFalse(serviceOptional.isPresent());

    }

    @Test
    public void test_postServiceOperationInformation_withActionDeleteServiceInstanceAndSvcActionDeactivate_successfullyUpdateExistingServiceInCache()
            throws Exception {

        final HttpEntity<?> httpEntity = new HttpEntity<>(getRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
        Optional<GenericResourceApiServicemodelinfrastructureService> serviceOptional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertTrue(serviceOptional.isPresent());

        GenericResourceApiServicemodelinfrastructureService service = serviceOptional.get();
        assertNotNull(service.getServiceInstanceId());
        assertNotNull(service.getServiceStatus());
        assertEquals(ASSIGN, service.getServiceStatus().getRpcAction());

        final HttpEntity<?> entity = new HttpEntity<>(
                getServiceRequestWithRequestActionDeleteServiceAndSvcActionDeactivateInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> deactivateResponseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, entity, OutputRequest.class);
        assertEquals(HttpStatus.OK, deactivateResponseEntity.getStatusCode());

        final OutputRequest actualOutputRequest = deactivateResponseEntity.getBody();
        assertNotNull(actualOutputRequest);
        assertNotNull(actualOutputRequest.getOutput());

        final Output actualObject = actualOutputRequest.getOutput();

        assertEquals(HTTP_STATUS_OK, actualObject.getResponseCode());
        assertEquals(Constants.YES, actualObject.getAckFinalIndicator());
        assertEquals(SVC_REQUEST_ID, actualObject.getSvcRequestId());

        serviceOptional =
                cacheServiceProvider.getGenericResourceApiServicemodelinfrastructureService(SERVICE_INSTANCE_ID);
        assertTrue(serviceOptional.isPresent());
        service = serviceOptional.get();
        assertNotNull(service.getServiceStatus());
        assertEquals(DEACTIVATE, service.getServiceStatus().getRpcAction());

    }

    private HttpHeaders getHttpHeaders() {
        return TestUtils.getHttpHeaders(userCredentials.getUsers().iterator().next().getUsername());
    }

    private String getUrl() {
        return "http://localhost:" + port + Constants.OPERATIONS_URL + SERVICE_TOPOLOGY_OPERATION_URL;
    }

    private String getVnfUrl() {
        return "http://localhost:" + port + Constants.OPERATIONS_URL + VNF_TOPOLOGY_OPERATION_URL;
    }

    @After
    public void after() {
        cacheServiceProvider.clearAll();
    }

}
