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
public class ServiceProfile {
	
	private int maxPktSize;
	private int termDensity;
	private int maxNumberofUEs;
	private int survivalTime;
	private int latency;
	private int reliability;
	private int dLThptPerSlice;
	private int expDataRateUL;
	private float availability;
	private String sliceProfileId;
	private String sNSSAI;
	private ArrayList<String> snssaiList;
	private PerfReq perfReq;
	private int jitter;
	private int maxNumberofPDUSession;
	private String sST;
	private int dLThptPerUE;
	private int maxNumberofConns;
	private String uEMobilityLevel;
	private int uLThptPerUE;
	private int expDataRateDL;
	private ArrayList<String> pLMNIdList;
	private ArrayList<Integer> coverageAreaTAList;
	private int uLThptPerSlice;
	private int activityFactor;
	private String resourceSharingLevel;
	public int getMaxPktSize() {
		return maxPktSize;
	}
	public void setMaxPktSize(int maxPktSize) {
		this.maxPktSize = maxPktSize;
	}
	public int getTermDensity() {
		return termDensity;
	}
	public void setTermDensity(int termDensity) {
		this.termDensity = termDensity;
	}
	public int getMaxNumberofUEs() {
		return maxNumberofUEs;
	}
	public void setMaxNumberOfUEs(int maxNumberofUEs) {
		this.maxNumberofUEs = maxNumberofUEs;
	}
	public int getSurvivalTime() {
		return survivalTime;
	}
	public void setSurvivalTime(int survivalTime) {
		this.survivalTime = survivalTime;
	}
	public int getLatency() {
		return latency;
	}
	public void setLatency(int latency) {
		this.latency = latency;
	}
	public int getReliability() {
		return reliability;
	}
	public void setReliability(int reliability) {
		this.reliability = reliability;
	}
	public int getdLThptPerSlice() {
		return dLThptPerSlice;
	}
	public void setdLThptPerSlice(int dLThptPerSlice) {
		this.dLThptPerSlice = dLThptPerSlice;
	}
	public int getExpDataRateUL() {
		return expDataRateUL;
	}
	public void setExpDataRateUL(int expDataRateUL) {
		this.expDataRateUL = expDataRateUL;
	}
	public float getAvailability() {
		return availability;
	}
	public void setAvailability(float availability) {
		this.availability = availability;
	}
	public String getsNSSAI() {
		return sNSSAI;
	}
	public void setsNSSAI(String sNSSAI) {
		this.sNSSAI = sNSSAI;
	}
	public int getJitter() {
		return jitter;
	}
	public void setJitter(int jitter) {
		this.jitter = jitter;
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
	public int getdLThptPerUE() {
		return dLThptPerUE;
	}
	public void setdLThptPerUE(int dLThptPerUE) {
		this.dLThptPerUE = dLThptPerUE;
	}
	public int getMaxNumberofConns() {
		return maxNumberofConns;
	}
	public void setMaxNumberofConns(int maxNumberofConns) {
		this.maxNumberofConns = maxNumberofConns;
	}
	public String getuEMobilityLevel() {
		return uEMobilityLevel;
	}
	public void setuEMobilityLevel(String uEMobilityLevel) {
		this.uEMobilityLevel = uEMobilityLevel;
	}
	public int getuLThptPerUE() {
		return uLThptPerUE;
	}
	public void setuLThptPerUE(int uLThptPerUE) {
		this.uLThptPerUE = uLThptPerUE;
	}
	public int getExpDataRateDL() {
		return expDataRateDL;
	}
	public void setExpDataRateDL(int expDataRateDL) {
		this.expDataRateDL = expDataRateDL;
	}
	public ArrayList<String> getpLMNIdList() {
		return pLMNIdList;
	}
	public void setpLMNIdList(ArrayList<String> pLMNIdList) {
		this.pLMNIdList = pLMNIdList;
	}
	public ArrayList<Integer> getCoverageAreaTAList() {
		return coverageAreaTAList;
	}
	public void setCoverageAreaTAList(ArrayList<Integer> coverageAreaTAList) {
		this.coverageAreaTAList = coverageAreaTAList;
	}
	public int getuLThptPerSlice() {
		return uLThptPerSlice;
	}
	public void setuLThptPerSlice(int uLThptPerSlice) {
		this.uLThptPerSlice= uLThptPerSlice;
	}
	public int getActivityFactor() {
		return activityFactor;
	}
	public void setActivityFactor(int activityFactor) {
		this.activityFactor = activityFactor;
	}
	public String getResourceSharingLevel() {
		return resourceSharingLevel;
	}
	public void setResourceSharingLevel(String resourceSharingLevel) {
		this.resourceSharingLevel = resourceSharingLevel;
	}
	public String getSliceProfileId() {
		return sliceProfileId;
	}
	public void setSliceProfileId(String sliceProfileId) {
		this.sliceProfileId = sliceProfileId;
	}
	public ArrayList<String> getSnssaiList() {
		return snssaiList;
	}
	public void setSnssaiList(ArrayList<String> snssaiList) {
		this.snssaiList = snssaiList;
	}
	public PerfReq getPerfReq() {
		return perfReq;
	}
	public void setPerfReq(PerfReq perfReq) {
		this.perfReq = perfReq;
	}
	public ServiceProfile() {
		super();
		// TODO Auto-generated constructor stub
	}
	public ServiceProfile(int maxPktSize, int termDensity, int maxNumberofUEs, int survivalTime, int latency,
			int reliability, int dLThptPerSlice, int expDataRateUL, float availability, String sliceProfileId,
			String sNSSAI, ArrayList<String> snssaiList, PerfReq perfReq, int jitter, int maxNumberofPDUSession,
			String sST, int dLThptPerUE, int maxNumberofConns, String uEMobilityLevel, int uLThptPerUE,
			int expDataRateDL, ArrayList<String> pLMNIdList, ArrayList<Integer> coverageAreaTAList, int uLThptPerSlice,
			int activityFactor, String resourceSharingLevel) {
		super();
		this.maxPktSize = maxPktSize;
		this.termDensity = termDensity;
		this.maxNumberofUEs = maxNumberofUEs;
		this.survivalTime = survivalTime;
		this.latency = latency;
		this.reliability = reliability;
		this.dLThptPerSlice = dLThptPerSlice;
		this.expDataRateUL = expDataRateUL;
		this.availability = availability;
		this.sliceProfileId = sliceProfileId;
		this.sNSSAI = sNSSAI;
		this.snssaiList = snssaiList;
		this.perfReq = perfReq;
		this.jitter = jitter;
		this.maxNumberofPDUSession = maxNumberofPDUSession;
		this.sST = sST;
		this.dLThptPerUE = dLThptPerUE;
		this.maxNumberofConns = maxNumberofConns;
		this.uEMobilityLevel = uEMobilityLevel;
		this.uLThptPerUE = uLThptPerUE;
		this.expDataRateDL = expDataRateDL;
		this.pLMNIdList = pLMNIdList;
		this.coverageAreaTAList = coverageAreaTAList;
		this.uLThptPerSlice = uLThptPerSlice;
		this.activityFactor = activityFactor;
		this.resourceSharingLevel = resourceSharingLevel;
	}
	@Override
	public String toString() {
		return "ServiceProfile [maxPktSize=" + maxPktSize + ", termDensity=" + termDensity + ", maxNumberofUEs="
				+ maxNumberofUEs + ", survivalTime=" + survivalTime + ", latency=" + latency + ", reliability="
				+ reliability + ", dLThptPerSlice=" + dLThptPerSlice + ", expDataRateUL=" + expDataRateUL
				+ ", availability=" + availability + ", sliceProfileId=" + sliceProfileId + ", sNSSAI=" + sNSSAI
				+ ", snssaiList=" + snssaiList + ", perfReq=" + perfReq + ", jitter=" + jitter
				+ ", maxNumberofPDUSession=" + maxNumberofPDUSession + ", sST=" + sST + ", dLThptPerUE=" + dLThptPerUE
				+ ", maxNumberofConns=" + maxNumberofConns + ", uEMobilityLevel=" + uEMobilityLevel + ", uLThptPerUE="
				+ uLThptPerUE + ", expDataRateDL=" + expDataRateDL + ", pLMNIdList=" + pLMNIdList
				+ ", coverageAreaTAList=" + coverageAreaTAList + ", uLThptPerSlice=" + uLThptPerSlice
				+ ", activityFactor=" + activityFactor + ", resourceSharingLevel=" + resourceSharingLevel + "]";
	}		
}

