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

@JsonIgnoreProperties(ignoreUnknown = true)
public class CapabilityDetails {

	private int latency;
	private int maxNumberofUEs;
	private int maxThroughput;
	private int termDensity;
	public int getLatency() {
		return latency;
	}
	public void setLatency(int latency) {
		this.latency = latency;
	}
	public int getMaxNumberofUEs() {
		return maxNumberofUEs;
	}
	public void setMaxNumberofUEs(int maxNumberofUEs) {
		this.maxNumberofUEs = maxNumberofUEs;
	}
	public int getMaxThroughput() {
		return maxThroughput;
	}
	public void setMaxThroughput(int maxThroughput) {
		this.maxThroughput = maxThroughput;
	}
	public int getTermDensity() {
		return termDensity;
	}
	public void setTermDensity(int termDensity) {
		this.termDensity = termDensity;
	}
	public CapabilityDetails(int latency, int maxNumberofUEs, int maxThroughput, int termDensity) {
		super();
		this.latency = latency;
		this.maxNumberofUEs = maxNumberofUEs;
		this.maxThroughput = maxThroughput;
		this.termDensity = termDensity;
	}
	public CapabilityDetails() {
		super();
		// TODO Auto-generated constructor stub
	}
	@Override
	public String toString() {
		return "CapabilityDetails [latency=" + latency + ", maxNumberofUEs=" + maxNumberofUEs + ", maxThroughput="
				+ maxThroughput + ", termDensity=" + termDensity + "]";
	}
}
