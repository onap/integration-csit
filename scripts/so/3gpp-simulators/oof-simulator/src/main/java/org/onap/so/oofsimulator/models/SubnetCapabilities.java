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

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class SubnetCapabilities {

	private String domainType;
	@JsonProperty("capabilityDetails")
	private CapabilityDetails capabilityDetails;
	public String getDomainType() {
		return domainType;
	}
	public void setDomainType(String domainType) {
		this.domainType = domainType;
	}
	public CapabilityDetails getCapabilityDetails() {
		return capabilityDetails;
	}
	public void setCapabilityDetails(CapabilityDetails capabilityDetails) {
		this.capabilityDetails = capabilityDetails;
	}
	public SubnetCapabilities(String domainType, CapabilityDetails capabilityDetails) {
		super();
		this.domainType = domainType;
		this.capabilityDetails = capabilityDetails;
	}
	public SubnetCapabilities() {
		super();
		// TODO Auto-generated constructor stub
	}
	@Override
	public String toString() {
		return "SubnetCapabilities [domainType=" + domainType + ", capabilityDetails=" + capabilityDetails + "]";
	}
}
