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
import org.onap.sdnc.northbound.client.model.GenericResourceApiInstanceReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class Output implements Serializable {

    private static final long serialVersionUID = 3838047042980836468L;

    @JsonProperty("response-message")
    private String responseMessage;

    @JsonProperty("ack-final-indicator")
    private String ackFinalIndicator;

    @JsonProperty("svc-request-id")
    private String svcRequestId;

    @JsonProperty("response-code")
    private String responseCode;

    @JsonProperty("service-response-information")
    private GenericResourceApiInstanceReference serviceResponseInformation = null;

    @JsonProperty("vnf-response-information")
    private GenericResourceApiInstanceReference vnfResponseInformation = null; 
    
    @JsonProperty("vf-module-response-information")
    private GenericResourceApiInstanceReference vfModuleResponseInformation = null;

    /**
     * @return the responseMessage
     */
    public String getResponseMessage() {
        return responseMessage;
    }

    /**
     * @param responseMessage the responseMessage to set
     */
    public void setResponseMessage(final String responseMessage) {
        this.responseMessage = responseMessage;
    }

    /**
     * @return the ackFinalIndicator
     */
    public String getAckFinalIndicator() {
        return ackFinalIndicator;
    }

    /**
     * @param ackFinalIndicator the ackFinalIndicator to set
     */
    public void setAckFinalIndicator(final String ackFinalIndicator) {
        this.ackFinalIndicator = ackFinalIndicator;
    }

    /**
     * @return the svcRequestId
     */
    public String getSvcRequestId() {
        return svcRequestId;
    }

    /**
     * @param svcRequestId the svcRequestId to set
     */
    public void setSvcRequestId(final String svcRequestId) {
        this.svcRequestId = svcRequestId;
    }

    /**
     * @return the responseCode
     */
    public String getResponseCode() {
        return responseCode;
    }

    /**
     * @param responseCode the responseCode to set
     */
    public void setResponseCode(final String responseCode) {
        this.responseCode = responseCode;
    }

    /**
     * @return the serviceResponseInformation
     */
    public GenericResourceApiInstanceReference getServiceResponseInformation() {
        return serviceResponseInformation;
    }

    /**
     * @param serviceResponseInformation the serviceResponseInformation to set
     */
    public void setServiceResponseInformation(final GenericResourceApiInstanceReference serviceResponseInformation) {
        this.serviceResponseInformation = serviceResponseInformation;
    }

    /**
     * @return the vnfResponseInformation
     */
    public GenericResourceApiInstanceReference getVnfResponseInformation() {
        return vnfResponseInformation;
    }

    /**
     * @param vnfResponseInformation the vnfResponseInformation to set
     */
    public void setVnfResponseInformation(final GenericResourceApiInstanceReference vnfResponseInformation) {
        this.vnfResponseInformation = vnfResponseInformation;
    }


    public Output responseMessage(final String responseMessage) {
        this.responseMessage = responseMessage;
        return this;
    }

    public Output ackFinalIndicator(final String ackFinalIndicator) {
        this.ackFinalIndicator = ackFinalIndicator;
        return this;
    }

    public Output svcRequestId(final String svcRequestId) {
        this.svcRequestId = svcRequestId;
        return this;
    }

    public Output responseCode(final String responseCode) {
        this.responseCode = responseCode;
        return this;
    }

    public Output serviceResponseInformation(final GenericResourceApiInstanceReference serviceResponseInformation) {
        this.serviceResponseInformation = serviceResponseInformation;
        return this;
    }

    public Output vnfResponseInformation(final GenericResourceApiInstanceReference vnfResponseInformation) {
        this.vnfResponseInformation = vnfResponseInformation;
        return this;

    }
    public Output vfModuleResponseInformation(final GenericResourceApiInstanceReference vfModuleResponseInformation) {
        this.vfModuleResponseInformation = vfModuleResponseInformation;
        return this;

    }

    @JsonIgnore
    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append("class OutputRequest {\n");
        sb.append("    responseMessage: ").append(responseMessage).append("\n");
        sb.append("    ackFinalIndicator: ").append(ackFinalIndicator).append("\n");
        sb.append("    svcRequestId: ").append(svcRequestId).append("\n");
        sb.append("    responseCode: ").append(responseCode).append("\n");
        sb.append("    serviceResponseInformation: ").append(serviceResponseInformation).append("\n");
        sb.append("    vnfResponseInformation: ").append(vnfResponseInformation).append("\n");
        sb.append("    vfModuleResponseInformation: ").append(vfModuleResponseInformation).append("\n");
        sb.append("}");
        return sb.toString();
    }



}
