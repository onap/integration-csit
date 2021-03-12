package org.onap.so.multicloudsimulator.controller;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.onap.so.multicloudsimulator.beans.InstanceResponse;
import org.onap.so.multicloudsimulator.beans.MulticloudInstanceRequest;
import org.onap.so.multicloudsimulator.beans.MulticloudCreateResponse;
import org.onap.so.multicloudsimulator.beans.MulticloudRequest;
import org.onap.so.openstack.beans.HeatStatus;

import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.URI;

import static org.onap.so.multicloudsimulator.utils.Constants.BASE_URL;
@RestController
public class MultiCloudController {

	public static final String X_HTTP_METHOD_OVERRIDE = "X-HTTP-Method-Override";
	private static final Logger LOGGER = LoggerFactory.getLogger(MultiCloudController.class);
	public MulticloudCreateResponse multicloudCreateResponse = new MulticloudCreateResponse();

	@RequestMapping(value = "/v1/instance", method = RequestMethod.POST)
	public ResponseEntity<?> createInstance(@RequestBody MulticloudInstanceRequest req){
		System.out.println("MultiCloud createInstance ");
		InstanceResponse InstanceResponse = new InstanceResponse();
		LOGGER.info("able to get v1 instance post method");
		return ResponseEntity.ok(req);
	}

	@RequestMapping(value = BASE_URL + "/{cloud-owner}/{cloud-region-id}/infra_workload", method = RequestMethod.GET,
			produces = "application/json")
	public ResponseEntity<?> getInstance(
			@PathVariable("cloud-owner") String cloudOwner, @PathVariable("cloud-region-id") String cloudRegionId,
			@RequestParam(value = "depth", required = false, defaultValue = "0") Integer depth,
			@RequestParam(name = "format", required = false) final String name, final HttpServletRequest request) throws IOException {

		LOGGER.info("found CloudOwner {} in cache", cloudOwner);
		LOGGER.info("found cloudRegionId {} in cache", cloudRegionId);
		LOGGER.info("found name {} in cache", name);
		JSONObject json = new JSONObject();

		json.put("template_type", "heat");
		json.put("workload_id", "");
		json.put("workload_status", "GET_COMPLETE");
		JSONObject workload = new JSONObject();
		workload.put("stacks", HeatStatus.NOTFOUND);
		json.put("workload_status_reason", workload);

		return ResponseEntity.ok(json);
	}

	@RequestMapping(value = BASE_URL + "/{cloud-owner}/{cloud-region-id}/infra_workload", method = RequestMethod.POST,
			produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
			consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
	public ResponseEntity<?> postCreateInstance(
			@RequestBody final MulticloudRequest inputRequest, @PathVariable("cloud-owner") final String cloudOwner,
			@PathVariable("cloud-region-id") final String cloudRegionId,
			@RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String xHttpHeaderOverride,
			final HttpServletRequest request) throws IOException {

		LOGGER.info("input request {}: ",inputRequest.toString());
		String input = "{\n" +
				"   \"template_type\": \"heat\",\n" +
				"   \"workload_id\": \"sad_sammet\",\n" +
				"   \"template_response\": [\n" +
				"      {\n" +
				"         \"GVK\": {\n" +
				"            \"Group\": \"k8s.plugin.opnfv.org\",\n" +
				"            \"Version\": \"v1alpha1\",\n" +
				"            \"Kind\": \"Network\"\n" +
				"         },\n" +
				"         \"Name\": \"k8s-region-2-onap-nf-20210120t221126760z-management-network\"\n" +
				"      },\n" +
				"      {\n" +
				"         \"GVK\": {\n" +
				"            \"Group\": \"k8s.plugin.opnfv.org\",\n" +
				"            \"Version\": \"v1alpha1\",\n" +
				"            \"Kind\": \"Network\"\n" +
				"         },\n" +
				"         \"Name\": \"k8s-region-2-onap-nf-20210120t221126760z-protected-network\"\n" +
				"      },\n" +
				"      {\n" +
				"         \"GVK\": {\n" +
				"            \"Group\": \"k8s.plugin.opnfv.org\",\n" +
				"            \"Version\": \"v1alpha1\",\n" +
				"            \"Kind\": \"Network\"\n" +
				"         },\n" +
				"         \"Name\": \"k8s-region-2-onap-nf-20210120t221126760z-unprotected-network\"\n" +
				"      },\n" +
				"      {\n" +
				"         \"GVK\": {\n" +
				"            \"Group\": \"k8s.cni.cncf.io\",\n" +
				"            \"Version\": \"v1\",\n" +
				"            \"Kind\": \"NetworkAttachmentDefinition\"\n" +
				"         },\n" +
				"         \"Name\": \"k8s-region-2-onap-nf-20210120t221126760z-ovn-nat\"\n" +
				"      }\n" +
				"   ],\n" +
				"   \"workload_status\": \"CREATE_COMPLETE\",\n" +
				"   \"workload_status_reason\": \"test\"\n" +
				"}";

		ObjectMapper objectMapper = new ObjectMapper();
		JSONObject workload = new JSONObject();

		workload.put("stack",true);

		JsonNode jsonNode = objectMapper.readTree(workload.toJSONString());
		MulticloudCreateResponse multiResponse = objectMapper.readValue(input, MulticloudCreateResponse.class);
		multiResponse.setWorkloadStatusReason(null);

		LOGGER.info("workload reason: {}",multiResponse.getWorkloadStatusReason());
		multiResponse.setWorkloadId("sad_sammet");
		multiResponse.setTemplateType("heat");
		multiResponse.setWorkloadStatus("CREATE_COMPLETE");

		return ResponseEntity.status(201).body(multiResponse);
	}

	@RequestMapping(value = BASE_URL + "/{cloud-owner}/{cloud-region-id}/infra_workload/{workload-id}", method = RequestMethod.GET,
			produces = MediaType.APPLICATION_JSON)
	public ResponseEntity<?> getInstanceName(
			@PathVariable("cloud-owner") String cloudOwner, @PathVariable("cloud-region-id") String cloudRegionId,
			@PathVariable("workload-id") String workloadId,
			@RequestParam(value = "depth", required = false, defaultValue = "0") Integer depth,
			@RequestParam(name = "format", required = false) final String name, final HttpServletRequest request) throws IOException {

		LOGGER.info("Calling getInstanceName");
		LOGGER.info("found CloudOwner {} in cache", cloudOwner);
		LOGGER.info("found cloudRegionId {} in cache", cloudRegionId);
		LOGGER.info("found name {} in cache", name);
		JSONObject json = new JSONObject();

		json.put("template_type", "heat");
		json.put("workload_id", "sad_sammet");
		json.put("workload_status", "CREATE_COMPLETE");
		JSONObject workload = new JSONObject();
		workload.put("stacks", true);
		json.put("workload_status_reason", null);

		return ResponseEntity.ok(json);
	}

	@RequestMapping(value = BASE_URL + "/{cloud-owner}/{cloud-region-id}/infra_workload/{workload-id}", method = RequestMethod.POST,
			produces = {MediaType.APPLICATION_JSON,
					MediaType.APPLICATION_XML}, consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
	public ResponseEntity<?> postCreateInstanceName(
			@RequestBody final MulticloudRequest inputRequest, @PathVariable("cloud-owner") final String cloudOwner,
			@PathVariable("workload-id") String workloadId,
			@PathVariable("cloud-region-id") final String cloudRegionId,
			@RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String xHttpHeaderOverride,
			final HttpServletRequest request) throws IOException {

		LOGGER.info("Calling postCreateInstanceName");

		return ResponseEntity.status(405).build();
	}
}
