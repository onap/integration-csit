package org.onap.so.oofsimulator.models;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class TerminateSyncResponse {
	
	private String reason;
	private String requestId;
	private String requestStatus;
	private boolean terminateResponse;
	private String transactionId;
	
	public TerminateSyncResponse() {
		super();
	}
	public TerminateSyncResponse(String reason, String requestId, String requestStatus, boolean terminateResponse,
			String transactionId) {
		super();
		this.reason = reason;
		this.requestId = requestId;
		this.requestStatus = requestStatus;
		this.terminateResponse = terminateResponse;
		this.transactionId = transactionId;
	}
	public String getReason() {
		return reason;
	}
	public void setReason(String reason) {
		this.reason = reason;
	}
	public String getRequestId() {
		return requestId;
	}
	public void setRequestId(String requestId) {
		this.requestId = requestId;
	}
	public String getRequestStatus() {
		return requestStatus;
	}
	public void setRequestStatus(String requestStatus) {
		this.requestStatus = requestStatus;
	}
	public boolean isTerminateResponse() {
		return terminateResponse;
	}
	public void setTerminateResponse(boolean terminateResponse) {
		this.terminateResponse = terminateResponse;
	}
	public String getTransactionId() {
		return transactionId;
	}
	public void setTransactionId(String transactionId) {
		this.transactionId = transactionId;
	}
	@Override
	public String toString() {
		return "TerminateSyncResponse [reason=" + reason + ", requestId=" + requestId + ", requestStatus="
				+ requestStatus + ", terminateResponse=" + terminateResponse + ", transactionId=" + transactionId + "]";
	}
}

