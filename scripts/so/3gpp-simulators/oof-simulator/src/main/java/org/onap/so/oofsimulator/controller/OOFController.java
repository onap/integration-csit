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
package org.onap.so.oofsimulator.controller;

import java.io.IOException;

import org.apache.tomcat.util.json.ParseException;
import org.onap.so.oofsimulator.models.RequestDetails;
import org.onap.so.oofsimulator.models.SynchronousResponse;
import org.onap.so.oofsimulator.models.TerminateRequestDetails;
import org.onap.so.oofsimulator.models.TerminateSyncResponse;
import org.onap.so.oofsimulator.service.OOFService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Controller
@EnableAsync
public class OOFController {
	private static final Logger LOGGER = LoggerFactory.getLogger(OOFController.class);
	
	@Autowired
	private OOFService oofService;

	@PostMapping(value = "api/oof/selection/nst/v1",consumes = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<?> postNSTSelectionSync(@RequestBody RequestDetails requestDetails) throws InterruptedException, IOException {
		LOGGER.info("SynchronousResponse NST Selection");
		SynchronousResponse synchronousResponse=oofService.getSynchronousResponse(requestDetails);
		ResponseEntity<SynchronousResponse> responseEntity=new ResponseEntity<SynchronousResponse>(synchronousResponse,HttpStatus.ACCEPTED);
		oofService.postAsync(requestDetails);
		return responseEntity;
	}

	@PostMapping(value = "api/oof/selection/nsi/v1",consumes = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<?> postNSISelectionSync(@RequestBody RequestDetails requestDetails) throws InterruptedException, IOException {
		LOGGER.info("SynchronousResponse NSI Selection");
		SynchronousResponse synchronousResponse=oofService.getSynchronousResponse(requestDetails);
		ResponseEntity<SynchronousResponse> responseEntity=new ResponseEntity<SynchronousResponse>(synchronousResponse,HttpStatus.ACCEPTED);
		oofService.postAsync(requestDetails);
		return responseEntity;
	}
	
	@PostMapping(value = "api/oof/selection/nssi/v1",consumes = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<SynchronousResponse> postNSSISelectionSync(@RequestBody RequestDetails requestDetails) throws ParseException, InterruptedException, IOException {
		LOGGER.info("SynchronousResponse NSSI Selection");
		SynchronousResponse synchronousResponse=oofService.getSynchronousResponse(requestDetails);
		ResponseEntity<SynchronousResponse> responseEntity=new ResponseEntity<SynchronousResponse>(synchronousResponse,HttpStatus.ACCEPTED);
		oofService.postAsync(requestDetails);
		return responseEntity;
	}
	
	//dummy url for testing async response
	/*@PostMapping(value = "api/oof/async")
	public ResponseEntity<String> postNSISelectionAsync(@RequestBody String r) {
		ResponseEntity<String> responseEntity=new ResponseEntity<String>(r,HttpStatus.ACCEPTED);
		return responseEntity;
	}*/
	@PostMapping(value = "api/oof/terminate/nxi/v1",consumes = MediaType.APPLICATION_JSON_VALUE)
	public ResponseEntity<TerminateSyncResponse> postNXITerminationSync(@RequestBody TerminateRequestDetails terminateRequestDetails) throws ParseException, InterruptedException, IOException {
	LOGGER.info("SynchronousResponse NXI Termination");
	TerminateSyncResponse terminateSyncResponse=oofService.getTerminateSyncResponse(terminateRequestDetails);
	ResponseEntity<TerminateSyncResponse> responseEntity=new ResponseEntity<TerminateSyncResponse>(terminateSyncResponse,HttpStatus.ACCEPTED);
//	oofService.postTerminateAsync(terminateRequestDetails);
	return responseEntity;
	}
	
}
