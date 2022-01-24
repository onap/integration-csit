/*******************************************************************************
 *  ============LICENSE_START=======================================================
 *  dmaap kafka listener
 *  ================================================================================
 *   Copyright (C) 2022 Wipro Limited.
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
package org.onap.so.kafkaListener.entity;

import com.fasterxml.jackson.annotation.JsonProperty;

public class CommonHeader {

	private String timestamp;
	@JsonProperty("api-ver")
	private String apiVer;
	@JsonProperty("originator-id")
	private String originatorId;
	@JsonProperty("request-id")
	private String requestId;
	@JsonProperty("sub-request-id")
	private String subRequestId;
	private Object flags;
	public String getTimestamp() {
		return timestamp;
	}
	public void setTimestamp(String timestamp) {
		this.timestamp = timestamp;
	}
	public String getApiVer() {
		return apiVer;
	}
	public void setApiVer(String apiVer) {
		this.apiVer = apiVer;
	}
	public String getOriginatorId() {
		return originatorId;
	}
	public void setOriginatorId(String originatorId) {
		this.originatorId = originatorId;
	}
	public String getRequestId() {
		return requestId;
	}
	public void setRequestId(String requestId) {
		this.requestId = requestId;
	}
	public String getSubRequestId() {
		return subRequestId;
	}
	public void setSubRequestId(String subRequestId) {
		this.subRequestId = subRequestId;
	}
	public Object getFlags() {
		return flags;
	}
	public void setFlags(Object flags) {
		this.flags = flags;
	}
	public CommonHeader(String timestamp, String apiVer, String originatorId, String requestId, String subRequestId,
			Object flags) {
		super();
		this.timestamp = timestamp;
		this.apiVer = apiVer;
		this.originatorId = originatorId;
		this.requestId = requestId;
		this.subRequestId = subRequestId;
		this.flags = flags;
	}
	public CommonHeader() {
		super();
		// TODO Auto-generated constructor stub
	}
	@Override
	public String toString() {
		return "CommonHeader [timestamp=" + timestamp + ", apiVer=" + apiVer + ", originatorId=" + originatorId
				+ ", requestId=" + requestId + ", subRequestId=" + subRequestId + ", flags=" + flags + "]";
	}
	
}
