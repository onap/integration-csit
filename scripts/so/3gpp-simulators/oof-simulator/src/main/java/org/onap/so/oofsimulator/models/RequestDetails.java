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

import java.util.ArrayList;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
@JsonIgnoreProperties(ignoreUnknown = true)
public class RequestDetails {
	private RequestInfo requestInfo;
	private ServiceProfile serviceProfile;
	@JsonProperty("NSTInfo")
	private NSTInfo nstInfo;
	@JsonProperty("NSSTInfo")
	private Object nsstInfoObj;
	private boolean preferReuse;
	private ArrayList<SubnetCapabilities> subnetCapabilities;
	private SliceProfile sliceProfile;
	public SliceProfile getSliceProfile() {
		return sliceProfile;
	}
	public void setSliceProfile(SliceProfile sliceProfile) {
		this.sliceProfile = sliceProfile;
	}
	public RequestInfo getRequestInfo() {
		return requestInfo;
	}
	public void setRequestInfo(RequestInfo requestInfo) {
		this.requestInfo = requestInfo;
	}
	public ServiceProfile getServiceProfile() {
		return serviceProfile;
	}
	public void setServiceProfile(ServiceProfile serviceProfile) {
		this.serviceProfile = serviceProfile;
	}
	public NSTInfo getNstInfo() {
		return nstInfo;
	}
	public void setNstInfo(NSTInfo nstInfo) {
		this.nstInfo = nstInfo;
	}
	public boolean isPreferReuse() {
		return preferReuse;
	}
	public void setPreferReuse(boolean preferReuse) {
		this.preferReuse = preferReuse;
	}
	public ArrayList<SubnetCapabilities> getSubnetCapabilities() {
		return subnetCapabilities;
	}
	public void setSubnetCapabilities(ArrayList<SubnetCapabilities> subnetCapabilities) {
		this.subnetCapabilities = subnetCapabilities;
	}
	public RequestDetails() {
		super();
		// TODO Auto-generated constructor stub
	}
	public RequestDetails(RequestInfo requestInfo, ServiceProfile serviceProfile, NSTInfo nstInfo, Object nsstInfoObj,
			boolean preferReuse, ArrayList<SubnetCapabilities> subnetCapabilities, SliceProfile sliceProfile) {
		super();
		this.requestInfo = requestInfo;
		this.serviceProfile = serviceProfile;
		this.nstInfo = nstInfo;
		this.nsstInfoObj = nsstInfoObj;
		this.preferReuse = preferReuse;
		this.subnetCapabilities = subnetCapabilities;
		this.sliceProfile = sliceProfile;
	}
	@Override
	public String toString() {
		return "RequestDetails [requestInfo=" + requestInfo + ", serviceProfile=" + serviceProfile + ", nstInfo="
				+ nstInfo + ", nsstInfoObj=" + nsstInfoObj + ", preferReuse=" + preferReuse + ", subnetCapabilities="
				+ subnetCapabilities + ", sliceProfile=" + sliceProfile + "]";
	}
	
}
