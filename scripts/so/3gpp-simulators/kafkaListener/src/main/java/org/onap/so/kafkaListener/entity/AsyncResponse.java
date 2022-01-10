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

public class AsyncResponse {
	
	private String status;
	private String requestId;
	private String action;
	private Object reason;
	private Object nfIds;
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public String getRequestId() {
		return requestId;
	}
	public void setRequestId(String requestId) {
		this.requestId = requestId;
	}
	public String getAction() {
		return action;
	}
	public void setAction(String action) {
		this.action = action;
	}
	public Object getReason() {
		return reason;
	}
	public void setReason(Object reason) {
		this.reason = reason;
	}
	public Object getNfIds() {
		return nfIds;
	}
	public void setNfIds(Object nfIds) {
		this.nfIds = nfIds;
	}
	public AsyncResponse(String status, String requestId, String action, Object reason, Object nfIds) {
		super();
		this.status = status;
		this.requestId = requestId;
		this.action = action;
		this.reason = reason;
		this.nfIds = nfIds;
	}
	public AsyncResponse() {
		super();
		// TODO Auto-generated constructor stub
	}
	@Override
	public String toString() {
		return "AsyncResponse [status=" + status + ", requestId=" + requestId + ", action=" + action + ", reason="
				+ reason + ", nfIds=" + nfIds + "]";
	}

}
