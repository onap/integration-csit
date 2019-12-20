/*-
 * ============LICENSE_START=======================================================
 * Copyright (C) 2019 Samsung. All rights reserved.
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
 * ============LICENSE_END=========================================================
 */

package org.onap.so.svnfm.simulator.api;

import com.squareup.okhttp.Call;
import com.squareup.okhttp.Response;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.lcn.*;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.lcn.api.DefaultApi;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.lcn.model.VnfLcmOperationOccurrenceNotification;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class VeVnfmApi extends DefaultApi {

    public VeVnfmApi(final ApiClient apiClient) {
        super(apiClient);
    }

    public Call lcnVnfLcmOperationOccurrenceNotificationPostCall(
            final VnfLcmOperationOccurrenceNotification vnfLcmOperationOccurrenceNotification,
            final String contentType, final String authorization,
            final ProgressResponseBody.ProgressListener progressListener,
            final ProgressRequestBody.ProgressRequestListener progressRequestListener) throws ApiException {
        return lcnVnfObjectNotificationPostCall(vnfLcmOperationOccurrenceNotification,
                contentType, authorization, progressListener, progressRequestListener);
    }

    private Call lcnVnfObjectNotificationPostCall(
            final Object body, final String contentType, final String authorization,
            final ProgressResponseBody.ProgressListener progressListener,
            final ProgressRequestBody.ProgressRequestListener progressRequestListener) throws ApiException {
        final List<Pair> localVarQueryParams = new ArrayList<>();
        final List<Pair> localVarCollectionQueryParams = new ArrayList<>();
        final Map<String, String> localVarHeaderParams = new HashMap<>();

        if (authorization != null) {
            localVarHeaderParams.put("Authorization", getApiClient().parameterToString(authorization));
        }

        if (contentType != null) {
            localVarHeaderParams.put("Content-Type", getApiClient().parameterToString(contentType));
        }

        final String[] localVarAccepts = new String[]{"application/json"};
        final String localVarAccept = getApiClient().selectHeaderAccept(localVarAccepts);

        if (localVarAccept != null) {
            localVarHeaderParams.put("Accept", localVarAccept);
        }

        final String[] localVarContentTypes = new String[]{"application/json"};
        final String localVarContentType = getApiClient().selectHeaderContentType(localVarContentTypes);
        localVarHeaderParams.put("Content-Type", localVarContentType);

        if (progressListener != null) {
            getApiClient().getHttpClient().networkInterceptors().add(ch -> {
                final Response originalResponse = ch.proceed(ch.request());
                return originalResponse.newBuilder().body(new ProgressResponseBody(originalResponse.body(), progressListener)).build();
            });
        }

        final Map<String, Object> localVarFormParams = new HashMap<>();
        final String[] localVarAuthNames = new String[0];

        return getApiClient().buildCall("", "POST", localVarQueryParams, localVarCollectionQueryParams, body, localVarHeaderParams, localVarFormParams, localVarAuthNames, progressRequestListener);
    }
}
