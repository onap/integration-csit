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
public class PerfReq {
	@JsonProperty("perfReqEmbbList")
	private PerfReqEmbbList perfReqEmbbList;
	
	public PerfReqEmbbList getPerfReqEmbbList() {
		return perfReqEmbbList;
	}
	public PerfReq(PerfReqEmbbList perfReqEmbbList) {
		super();
		this.perfReqEmbbList = perfReqEmbbList;
	}
	public PerfReq() {
		super();
	}
	@Override
	public String toString() {
		return "PerfReq [perfReqEmbbList=" + perfReqEmbbList + "]";
	}
}

