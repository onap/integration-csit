package org.onap.so.oofsimulator.models;

public class AddtnlArgs {

	private String serviceInstanceId;
	
	public AddtnlArgs(String serviceInstanceId) {
		super();
		this.serviceInstanceId = serviceInstanceId;
	}
	
	public AddtnlArgs() {
		super();
	}

	public String getServiceInstanceId() {
		return serviceInstanceId;
	}

	public void setServiceInstanceId(String serviceInstanceId) {
		this.serviceInstanceId = serviceInstanceId;
	}

	@Override
	public String toString() {
		return "AddtnlArgs [serviceInstanceId=" + serviceInstanceId + "]";
	}	
}

