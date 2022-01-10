package org.onap.so.oofsimulator.models;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class TerminateRequestDetails {

	private String type;
	private String nxiId;
	private RequestInfo requestInfo;
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getNxiId() {
		return nxiId;
	}
	public void setNxiId(String nxiId) {
		this.nxiId = nxiId;
	}
	public RequestInfo getRequestInfo() {
		return requestInfo;
	}
	public void setRequestInfo(RequestInfo requestInfo) {
		this.requestInfo = requestInfo;
	}
	public TerminateRequestDetails(String type, String nxiId, RequestInfo requestInfo) {
		super();
		this.type = type;
		this.nxiId = nxiId;
		this.requestInfo = requestInfo;
	}
	public TerminateRequestDetails() {
		super();
	}
	@Override
	public String toString() {
		return "TerminateRequestDetails [type=" + type + ", nxiId=" + nxiId + ", requestInfo=" + requestInfo + "]";
	}
	
}

