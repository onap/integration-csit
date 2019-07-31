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
package org.onap.so.aai.simulator.utils;

import static org.onap.so.aai.simulator.utils.Constants.ERROR_MESSAGE;
import static org.onap.so.aai.simulator.utils.Constants.ERROR_MESSAGE_ID;
import javax.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class Utils {

    private static final String EMPTY_STRING = "";

    public static final String getResourceVersion() {
        return System.currentTimeMillis() + EMPTY_STRING;
    }

    public static ResponseEntity<?> getRequestErrorResponseEntity(final HttpServletRequest request,
            final String nodeType) {
        return new ResponseEntity<>(
                new RequestErrorBuilder().messageId(ERROR_MESSAGE_ID).text(ERROR_MESSAGE)
                        .variables(request.getMethod(), request.getRequestURI(), "Node Not Found:No Node of " + nodeType
                                + " service-instance found at: " + request.getRequestURI(), "ERR.5.4.6114")
                        .build(),
                HttpStatus.NOT_FOUND);
    }


    public static ResponseEntity<?> getRequestErrorResponseEntity(final HttpServletRequest request) {
        return getRequestErrorResponseEntity(request, Constants.SERVICE_RESOURCE_TYPE);
    }


    private Utils() {}

}
