/*******************************************************************************
 *  ============LICENSE_START=======================================================
 *  OOF Simulator
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
package org.onap.so.oofsimulator.service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.stream.Collectors;

import org.onap.so.oofsimulator.models.AsynchronousResponse;
import org.onap.so.oofsimulator.models.RequestDetails;
import org.onap.so.oofsimulator.models.SynchronousResponse;
import org.onap.so.oofsimulator.models.TerminateRequestDetails;
import org.onap.so.oofsimulator.models.TerminateSyncResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class OOFService {
	private static final Logger LOGGER = LoggerFactory.getLogger(OOFService.class);
	
	@Autowired
	private ObjectMapper obj;
	
	@Autowired
	private RestTemplate restTemplate;

	public SynchronousResponse getSynchronousResponse(RequestDetails requestDetails) {
		SynchronousResponse synchronousResponse=new SynchronousResponse();
		synchronousResponse.setRequestId(requestDetails.getRequestInfo().getRequestId());
		synchronousResponse.setTransactionId(requestDetails.getRequestInfo().getTransactionId());
		synchronousResponse.setRequestStatus("completed");
		return synchronousResponse;
	}
	
	public AsynchronousResponse getAsynchronousResponse(RequestDetails requestDetails) throws IOException {
		AsynchronousResponse asynchronousResponse=new AsynchronousResponse();
		asynchronousResponse.setRequestId(requestDetails.getRequestInfo().getRequestId());
		asynchronousResponse.setTransactionId(requestDetails.getRequestInfo().getTransactionId());
		asynchronousResponse.setRequestStatus("completed");
		String solution="";
		try (InputStream inputStream = getClass().getResourceAsStream(solutionJSON(requestDetails));
			    BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
			solution = reader.lines()
			      .collect(Collectors.joining(System.lineSeparator()));
		}
		JsonNode node=obj.readTree(solution);
		asynchronousResponse.setSolutions(node.get("solutions"));
		return asynchronousResponse;
	}
	
	@Async
	public String postAsync(RequestDetails requestDetails) throws InterruptedException, IOException {
		Thread.sleep(2000);
		LOGGER.info("AsynchronousResponse");
		AsynchronousResponse asynchronousResponse=getAsynchronousResponse(requestDetails);
		ObjectMapper Obj = new ObjectMapper();
                String jsonStr = Obj.writeValueAsString(asynchronousResponse);
		HttpHeaders httpHeaders=new HttpHeaders();
		httpHeaders.add(HttpHeaders.CONTENT_TYPE,"application/json");
		LOGGER.info(jsonStr);
		HttpEntity<String> httpEntity=new HttpEntity<String>(jsonStr,httpHeaders);
		return restTemplate.postForObject(requestDetails.getRequestInfo().getCallbackUrl(),
				httpEntity, String.class);
	}
	
	public String solutionJSON(RequestDetails requestDetails) {
		String s="/solution";		
		if(requestDetails.getRequestInfo().getCallbackUrl().contains("NSI")) {
			s=s+"NSI";
		}else if(requestDetails.getRequestInfo().getCallbackUrl().contains("NST")){
			s=s+"NST";
		}else {s=s+"NSSI";}
		s=s+".json";
		return s;
	}
	public TerminateSyncResponse getTerminateSyncResponse(TerminateRequestDetails terminateRequestDetails) {
		TerminateSyncResponse terminateSyncResponse=new TerminateSyncResponse();
		terminateSyncResponse.setRequestId(terminateRequestDetails.getRequestInfo().getRequestId());
		terminateSyncResponse.setTransactionId(terminateRequestDetails.getRequestInfo().getTransactionId());
		terminateSyncResponse.setTerminateResponse(true);
		terminateSyncResponse.setRequestStatus("success");
		return terminateSyncResponse;
	}


}

