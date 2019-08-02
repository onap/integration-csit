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
package org.onap.so.aaisimulator.models;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonRootName;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@JsonRootName(value = "result")
public class Result {

    private List<Map<String, Object>> values = new ArrayList<>();

    public Result() {}

    public Result(final Map<String, Object> value) {
        this.values.add(value);
    }

    /**
     * @return the values
     */
    public List<Map<String, Object>> getValues() {
        return values;
    }

    /**
     * @param values the values to set
     */
    public void setValues(final List<Map<String, Object>> values) {
        this.values = values;
    }


    @JsonIgnore
    @Override
    public String toString() {
        return "Result [values=" + values + "]";
    }

}
