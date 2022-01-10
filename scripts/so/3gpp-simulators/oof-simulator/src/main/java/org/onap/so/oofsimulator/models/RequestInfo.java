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
package org.onap.so.oofsimulator.models;

import com.fasterxml.jackson.annotation.JsonProperty;

public class RequestInfo {
	
	private String transactionId;
	private String requestId;
	private String sourceId;
	private int timeout;
	private int numSolutions;
	private String callbackUrl;
	@JsonProperty("AddtnlArgs")
	private AddtnlArgs addtnlArgs;
	
	
	public int getNumSolutions() {
		return numSolutions;
	}
	public void setNumSolutions(int numSolutions) {
		this.numSolutions = numSolutions;
	}
	public String getTransactionId() {
		return transactionId;
	}
	public void setTransactionId(String transactionId) {
		this.transactionId = transactionId;
	}
	public String getRequestId() {
		return requestId;
	}
	public void setRequestId(String requestId) {
		this.requestId = requestId;
	}
	public String getSourceId() {
		return sourceId;
	}
	public void setSourceId(String sourceId) {
		this.sourceId = sourceId;
	}
	public int getTimeout() {
		return timeout;
	}
	public void setTimeout(int timeout) {
		this.timeout = timeout;
	}
	public String getCallbackUrl() {
		return callbackUrl;
	}
	public void setCallbackUrl(String callbackUrl) {
		this.callbackUrl = callbackUrl;
	}
	
	public AddtnlArgs getAddtnlArgs() {
		return addtnlArgs;
	}
	public void setAddtnlArgs(AddtnlArgs addtnlArgs) {
		this.addtnlArgs = addtnlArgs;
	}
	
	public RequestInfo() {
		super();
	}

	public RequestInfo(String transactionId, String requestId, String sourceId, int timeout, int numSolutions, String callbackUrl, AddtnlArgs addtnlArgs) {
		super();
		this.transactionId = transactionId;
		this.requestId = requestId;
		this.sourceId = sourceId;
		this.timeout = timeout;
		this.numSolutions=numSolutions;
		this.callbackUrl = callbackUrl;
		this.addtnlArgs = addtnlArgs;
	}
	@Override
	public String toString() {
		return "RequestInfo [transactionId=" + transactionId + ", requestId=" + requestId + ", sourceId=" + sourceId
				+ ", timeout=" + timeout + ", numSolutions=" + numSolutions + ", callbackUrl=" + callbackUrl
				+ ", addtnlArgs=" + addtnlArgs + "]";
	}
}

