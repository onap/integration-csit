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

public class ReqBody {

	private Body body;
	private String version;
	@JsonProperty("rpc-name")
	private String rpcName;
	@JsonProperty("correlation-id")
	private String correlationId;
	private String type;
	public Body getBody() {
		return body;
	}
	public void setBody(Body body) {
		this.body = body;
	}
	public String getVersion() {
		return version;
	}
	public void setVersion(String version) {
		this.version = version;
	}
	public String getRpcName() {
		return rpcName;
	}
	public void setRpcName(String rpcName) {
		this.rpcName = rpcName;
	}
	public String getCorrelationId() {
		return correlationId;
	}
	public void setCorrelationId(String correlationId) {
		this.correlationId = correlationId;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public ReqBody(Body body, String version, String rpcName, String correlationId, String type) {
		super();
		this.body = body;
		this.version = version;
		this.rpcName = rpcName;
		this.correlationId = correlationId;
		this.type = type;
	}
	public ReqBody() {
		super();
		// TODO Auto-generated constructor stub
	}
	@Override
	public String toString() {
		return "ReqBody [body=" + body + ", version=" + version + ", rpcName=" + rpcName + ", correlationId="
				+ correlationId + ", type=" + type + "]";
	}
}
