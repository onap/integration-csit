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

public class Input {

	private SliceProfile sliceProfile;
	private String RANNSSIId;
	private String NSIID;
	private String RANNFNSSIId;
	private String callbackURL;
	private Object additionalproperties;
	public SliceProfile getSliceProfile() {
		return sliceProfile;
	}
	public void setSliceProfile(SliceProfile sliceProfile) {
		this.sliceProfile = sliceProfile;
	}
	public String getRANNSSIId() {
		return RANNSSIId;
	}
	public void setRANNSSIId(String rANNSSIId) {
		RANNSSIId = rANNSSIId;
	}
	public String getNSIID() {
		return NSIID;
	}
	public void setNSIID(String nSIID) {
		NSIID = nSIID;
	}
	public String getRANNFNSSIId() {
		return RANNFNSSIId;
	}
	public void setRANNFNSSIId(String rANNFNSSIId) {
		RANNFNSSIId = rANNFNSSIId;
	}
	public String getCallbackURL() {
		return callbackURL;
	}
	public void setCallbackURL(String callbackURL) {
		this.callbackURL = callbackURL;
	}
	public Object getAdditionalproperties() {
		return additionalproperties;
	}
	public void setAdditionalproperties(Object additionalproperties) {
		this.additionalproperties = additionalproperties;
	}
	public Input(SliceProfile sliceProfile, String rANNSSIId, String nSIID, String rANNFNSSIId,
			String callbackURL, Object additionalproperties) {
		super();
		this.sliceProfile = sliceProfile;
		RANNSSIId = rANNSSIId;
		NSIID = nSIID;
		RANNFNSSIId = rANNFNSSIId;
		this.callbackURL = callbackURL;
		this.additionalproperties = additionalproperties;
	}
	public Input() {
		super();
		// TODO Auto-generated constructor stub
	}
	@Override
	public String toString() {
		return "Input [sliceProfile=" + sliceProfile + ", RANNSSIId=" + RANNSSIId + ", NSIID=" + NSIID
				+ ", RANNFNSSIId=" + RANNFNSSIId + ", callbackURL=" + callbackURL + ", additionalproperties="
				+ additionalproperties + "]";
	}
	
}
