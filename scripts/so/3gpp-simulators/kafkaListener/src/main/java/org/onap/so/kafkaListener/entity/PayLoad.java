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

public class PayLoad {

	private Input input;

	public Input getInput() {
		return input;
	}

	public void setInputPayLoad(Input input) {
		this.input = input;
	}

	public PayLoad(Input input) {
		super();
		this.input = input;
	}

	public PayLoad() {
		super();
		// TODO Auto-generated constructor stub
	}

	@Override
	public String toString() {
		return "PayLoad [input=" + input + "]";
	}
}
