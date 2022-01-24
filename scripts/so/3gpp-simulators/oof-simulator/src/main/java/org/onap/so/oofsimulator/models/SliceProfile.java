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

@JsonIgnoreProperties(ignoreUnknown = true)
public class SliceProfile {
	private int termDensity;
	private String domainType;
	private int maxNumberofUEs;
	private int latency;
	private ArrayList<String> snssaiList;
	private int expDataRateUL;
	private ArrayList<String> pLMNIdList;
	private int maxNumberofPDUSession;
	private String sST;
	private int expDataRateDL;
	private ArrayList<Integer> coverageAreaTAList;
	private int maxThroughput;
	private String resourceSharingLevel;
	public int getTermDensity() {
		return termDensity;
	}
	public void setTermDensity(int termDensity) {
		this.termDensity = termDensity;
	}
	public String getDomainType() {
		return domainType;
	}
	public void setDomainType(String domainType) {
		this.domainType = domainType;
	}
	public int getMaxNumberofUEs() {
		return maxNumberofUEs;
	}
	public void setMaxNumberofUEs(int maxNumberofUEs) {
		this.maxNumberofUEs = maxNumberofUEs;
	}
	public int getLatency() {
		return latency;
	}
	public void setLatency(int latency) {
		this.latency = latency;
	}
	public ArrayList<String> getSnssaiList() {
		return snssaiList;
	}
	public void setSnssaiList(ArrayList<String> snssaiList) {
		this.snssaiList = snssaiList;
	}
	public int getExpDataRateUL() {
		return expDataRateUL;
	}
	public void setExpDataRateUL(int expDataRateUL) {
		this.expDataRateUL = expDataRateUL;
	}
	public ArrayList<String> getPlmnIdList() {
		return pLMNIdList;
	}
	public void setPlmnIdList(ArrayList<String> pLMNIdList) {
		this.pLMNIdList = pLMNIdList;
	}
	public int getMaxNumberofPDUSession() {
		return maxNumberofPDUSession;
	}
	public void setMaxNumberofPDUSession(int maxNumberofPDUSession) {
		this.maxNumberofPDUSession = maxNumberofPDUSession;
	}
	public String getsST() {
		return sST;
	}
	public void setsST(String sST) {
		this.sST = sST;
	}
	public int getExpDataRateDL() {
		return expDataRateDL;
	}
	public void setExpDataRateDL(int expDataRateDL) {
		this.expDataRateDL = expDataRateDL;
	}
	public ArrayList<Integer> getCoverageAreaTAList() {
		return coverageAreaTAList;
	}
	public void setCoverageAreaTAList(ArrayList<Integer> coverageAreaTAList) {
		this.coverageAreaTAList = coverageAreaTAList;
	}
	public int getMaxThroughput() {
		return maxThroughput;
	}
	public void setMaxThroughput(int maxThroughput) {
		this.maxThroughput = maxThroughput;
	}
	public String getResourceSharingLevel() {
		return resourceSharingLevel;
	}
	public void setResourceSharingLevel(String resourceSharingLevel) {
		this.resourceSharingLevel = resourceSharingLevel;
	}
	public SliceProfile(int termDensity, String domainType, int maxNumberofUEs, int latency,
			ArrayList<String> snssaiList, int expDataRateUL, ArrayList<String> pLMNIdList, int maxNumberofPDUSession,
			String sST, int expDataRateDL, ArrayList<Integer> coverageAreaTAList, int maxThroughput,
			String resourceSharingLevel) {
		super();
		this.termDensity = termDensity;
		this.domainType = domainType;
		this.maxNumberofUEs = maxNumberofUEs;
		this.latency = latency;
		this.snssaiList = snssaiList;
		this.expDataRateUL = expDataRateUL;
		this.pLMNIdList = pLMNIdList;
		this.maxNumberofPDUSession = maxNumberofPDUSession;
		this.sST = sST;
		this.expDataRateDL = expDataRateDL;
		this.coverageAreaTAList = coverageAreaTAList;
		this.maxThroughput = maxThroughput;
		this.resourceSharingLevel = resourceSharingLevel;
	}
	public SliceProfile() {
		super();
		// TODO Auto-generated constructor stub
	}
	@Override
	public String toString() {
		return "SliceProfile [termDensity=" + termDensity + ", domainType=" + domainType + ", maxNumberofUEs="
				+ maxNumberofUEs + ", latency=" + latency + ", snssaiList=" + snssaiList + ", expDataRateUL="
				+ expDataRateUL + ", pLMNIdList=" + pLMNIdList + ", maxNumberofPDUSession=" + maxNumberofPDUSession
				+ ", sST=" + sST + ", expDataRateDL=" + expDataRateDL + ", coverageAreaTAList=" + coverageAreaTAList
				+ ", maxThroughput=" + maxThroughput + ", resourceSharingLevel=" + resourceSharingLevel + "]";
	}
	
}
