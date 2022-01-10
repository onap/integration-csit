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
package org.onap.so.kafkaListener.entity;

import com.fasterxml.jackson.annotation.JsonProperty;

public class InputBody {
	
	@JsonProperty("common-header")
	private CommonHeader commonHeader;
	private String action;
	private Object payload;
	public CommonHeader getCommonHeader() {
		return commonHeader;
	}
	public void setCommonHeader(CommonHeader commonHeader) {
		this.commonHeader = commonHeader;
	}
	public String getAction() {
		return action;
	}
	public void setAction(String action) {
		this.action = action;
	}
	public Object getPayload() {
		return payload;
	}
	public void setPayLoad(Object payload) {
		this.payload = payload;
	}
	public InputBody(CommonHeader commonHeader, String action, Object payload) {
		super();
		this.commonHeader = commonHeader;
		this.action = action;
		this.payload = payload;
	}
	public InputBody() {
		super();
		// TODO Auto-generated constructor stub
	}
	@Override
	public String toString() {
		return "InputBody [commonHeader=" + commonHeader + ", action=" + action + ", payload=" + payload + "]";
	}
}
