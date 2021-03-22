package org.onap.so.multicloudsimulator.controller;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.apache.commons.io.IOUtils;
import org.onap.so.multicloudsimulator.beans.InstanceOutput;
import org.onap.so.multicloudsimulator.beans.MulticloudCreateResponse;
import org.onap.so.multicloudsimulator.beans.MulticloudInstanceRequest;
import org.onap.so.multicloudsimulator.beans.InstanceResponse;
import org.onap.so.multicloudsimulator.beans.InstanceNameOutput;
import org.onap.so.multicloudsimulator.beans.MulticloudRequest;

import org.springframework.http.ResponseEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.io.InputStream;

import static org.onap.so.multicloudsimulator.utils.Constants.BASE_URL;

@RestController
@RequestMapping(path = BASE_URL)
public class MultiCloudController {

	public static final String X_HTTP_METHOD_OVERRIDE = "X-HTTP-Method-Override";
	private static final Logger LOGGER = LoggerFactory.getLogger(MultiCloudController.class);
	public MulticloudCreateResponse multicloudCreateResponse = new MulticloudCreateResponse();

	@PostMapping(value = "/v1/instance")
	public ResponseEntity<?> createInstance(@RequestBody MulticloudInstanceRequest req) {
		System.out.println("MultiCloud createInstance ");
		final InstanceResponse InstanceResponse = new InstanceResponse();

		LOGGER.info("Calling createInstance");
		return ResponseEntity.ok(InstanceResponse);
	}

	@GetMapping(value = "/{cloud-owner}/{cloud-region-id}/infra_workload", produces = { MediaType.APPLICATION_JSON })
	public ResponseEntity<?> getInstance(@PathVariable("cloud-owner") String cloudOwner,
			@PathVariable("cloud-region-id") String cloudRegionId,
			@RequestParam(value = "depth", required = false, defaultValue = "0") Integer depth,
			@RequestParam(name = "format", required = false) final String name, final HttpServletRequest request)
			throws Exception {

		LOGGER.info("found CloudOwner {} in cache", cloudOwner);
		LOGGER.info("found cloudRegionId {} in cache", cloudRegionId);
		LOGGER.info("found name {} in cache", name);
		final InputStream instanceOutput = InstanceOutput.getInstance();
		String output = IOUtils.toString(instanceOutput, "utf-8");

		return ResponseEntity.ok(output);
	}

	@PostMapping(value = "/{cloud-owner}/{cloud-region-id}/infra_workload", consumes = { MediaType.APPLICATION_JSON,
			MediaType.APPLICATION_XML }, produces = { MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML })
	public ResponseEntity<?> postCreateInstance(@RequestBody final MulticloudCreateResponse inputRequest,
			@PathVariable("cloud-owner") final String cloudOwner,
			@PathVariable("cloud-region-id") final String cloudRegionId,
			@RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String xHttpHeaderOverride,
			HttpServletRequest request) throws IOException {

		LOGGER.info("Calling postCreateInstance");
		inputRequest.setWorkloadStatusReason(null);

		inputRequest.setWorkloadId("sad_sammet");
		inputRequest.setTemplateType("heat");
		inputRequest.setWorkloadStatus("CREATE_COMPLETE");

		return ResponseEntity.status(201).body(inputRequest);
	}

	@GetMapping(value = "/{cloud-owner}/{cloud-region-id}/infra_workload/{workload-id}", produces = {
			MediaType.APPLICATION_JSON })
	public ResponseEntity<?> getInstanceName(@PathVariable("cloud-owner") String cloudOwner,
			@PathVariable("cloud-region-id") String cloudRegionId, @PathVariable("workload-id") String workloadId,
			@RequestParam(value = "depth", required = false, defaultValue = "0") Integer depth,
			@RequestParam(name = "format", required = false) final String name, final HttpServletRequest request)
			throws Exception {

		LOGGER.info("Calling getInstanceName");
		LOGGER.info("found CloudOwner {} in cache", cloudOwner);
		LOGGER.info("found cloudRegionId {} in cache", cloudRegionId);
		LOGGER.info("found name {} in cache", name);
		final InputStream instanceNameOutput = InstanceNameOutput.getInstanceName();
		String output = IOUtils.toString(instanceNameOutput, "utf-8");

		return ResponseEntity.ok(output);
	}

	@PostMapping(value = "/{cloud-owner}/{cloud-region-id}/infra_workload/{workload-id}", consumes = {
			MediaType.APPLICATION_JSON,
			MediaType.APPLICATION_XML }, produces = { MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML })
	public ResponseEntity<?> postCreateInstanceName(@RequestBody final MulticloudRequest inputRequest,
			@PathVariable("cloud-owner") final String cloudOwner, @PathVariable("workload-id") String workloadId,
			@PathVariable("cloud-region-id") final String cloudRegionId,
			@RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String xHttpHeaderOverride,
			final HttpServletRequest request) throws IOException {

		LOGGER.info("Calling postCreateInstanceName");

		return ResponseEntity.status(405).build();
	}
}