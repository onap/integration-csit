/*******************************************************************************
 *  ============LICENSE_START=======================================================
 *  dmaap kafka listener
 *  ================================================================================
 *   Copyright (C) 2021 Wipro Limited.
 *   ==============================================================================
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *  
 *          http://www.apache.org/licenses/LICENSE-2.0
 *  
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 *     ============LICENSE_END=========================================================
 *  
 *******************************************************************************/
package org.onap.so.kafkaListener.listener;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.stream.Collectors;

import java.nio.charset.Charset;
import org.apache.tomcat.util.codec.binary.Base64;

import org.onap.so.kafkaListener.entity.AsyncResponse;
import org.onap.so.kafkaListener.entity.PayLoad;
import org.onap.so.kafkaListener.entity.ReqBody;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
@EnableAsync
public class KafkaListenerService {
	
	private static final Logger LOGGER = LoggerFactory.getLogger(KafkaListenerService.class);

	@Autowired
	private ObjectMapper obj;
	
	@Autowired
	private RestTemplate restTemplate;
	
	@KafkaListener(groupId="users",topics = "RAN-Slice-Mgmt",containerFactory = "kafkaListenerContainerFactory")
	public void getMsgFromTopic(ReqBody requestBody) throws IOException {
		LOGGER.info("Response for the given topic");
		String load=requestBody.getBody().getInputBody().getPayload().toString();
		PayLoad payLoad=obj.readValue(load, PayLoad.class);
		asyncResponse(payLoad.getInput().getCallbackURL(),requestBody.getBody().getInputBody().getCommonHeader().getRequestId());
	}
	
	@Async
	public AsyncResponse asyncResponse(String callbackurl,String requestId) throws IOException {
		LOGGER.info("AsynchronousResponse from KafkaListener");
		AsyncResponse asyncResponse=new AsyncResponse();
		asyncResponse.setRequestId(requestId);
		asyncResponse.setStatus("success");
		asyncResponse.setAction("allocate");
		String response="";
		try (InputStream inputStream = getClass().getResourceAsStream("/Response.json");
			BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
			response = reader.lines()
			      .collect(Collectors.joining(System.lineSeparator()));
		}
		catch(Exception e) {
                        LOGGER.info("Error with reading Response.json",e);
                }
		JsonNode root=obj.readTree(response);
		asyncResponse.setReason(root.get("reason"));
		asyncResponse.setNfIds(root.get("nfIds"));
		HttpHeaders httpHeaders=new HttpHeaders();
		httpHeaders.add(HttpHeaders.CONTENT_TYPE, "application/json");
		httpHeaders.add(HttpHeaders.ACCEPT, "application/json,*/*");
		httpHeaders.add(HttpHeaders.AUTHORIZATION, authenticate());
		httpHeaders.add(HttpHeaders.USER_AGENT,"Jersey/2.25.1 (HttpUrlConnection 11.0.8)");
		HttpEntity<AsyncResponse> httpEntity=new HttpEntity<AsyncResponse>(asyncResponse,httpHeaders);
		return restTemplate.postForObject(callbackurl,httpEntity, AsyncResponse.class);

	}

	public String authenticate() {
            String auth = "mso_admin" + ":" + "password1$";
            byte[] encodedAuth = Base64.encodeBase64(
            auth.getBytes(Charset.forName("US-ASCII")) );
            String authHeader = "Basic " + new String( encodedAuth );
            return authHeader;
	}
	
}
