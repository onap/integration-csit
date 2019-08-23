/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2019 Nordix Foundation.
 * ================================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * ============LICENSE_END=========================================================
 */
package org.onap.so.sdncsimulator.models;

import java.io.Serializable;
import com.fasterxml.jackson.annotation.JsonIgnore;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class InputRequest<T> implements Serializable {

    private static final long serialVersionUID = -3408332422970506740L;

    private T input;

    /**
     * @return the input
     */
    public T getInput() {
        return input;
    }

    /**
     * @param input the input to set
     */
    public void setInput(final T input) {
        this.input = input;
    }

    @JsonIgnore
    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append("class InputRequest {\n");
        sb.append("    input: ").append(input).append("\n");
        sb.append("}");
        return sb.toString();
    }

}
