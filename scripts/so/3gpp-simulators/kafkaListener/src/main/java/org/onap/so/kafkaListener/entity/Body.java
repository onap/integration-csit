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

public class Body {
	@JsonProperty("input")
	private InputBody input;

	public InputBody getInputBody() {
		return input;
	}

	public Body() {
		super();
		// TODO Auto-generated constructor stub
	}

	public Body(InputBody input) {
		super();
		this.input = input;
	}

	public void setInputBody(InputBody input) {
		this.input = input;
	}

	@Override
	public String toString() {
		return "Body [InputBody=" + input + "]";
	}
}
