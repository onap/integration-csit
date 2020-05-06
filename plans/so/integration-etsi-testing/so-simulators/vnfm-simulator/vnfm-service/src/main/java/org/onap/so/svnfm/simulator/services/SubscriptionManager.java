package org.onap.so.svnfm.simulator.services;

import static org.onap.so.svnfm.simulator.config.SslBasedRestTemplateConfiguration.SSL_BASED_CONFIGURABLE_REST_TEMPLATE;

import java.nio.charset.StandardCharsets;
import javax.ws.rs.core.MediaType;
import org.apache.commons.codec.binary.Base64;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.InlineResponse201;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.PkgmSubscriptionRequest;
import org.onap.so.svnfm.simulator.constants.Constant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

/**
 *
 * @author Eoin Hanan (eoin.hanan@est.tech)
 * @author Gareth Roper (gareth.roper@est.tech)
 */
@Service
public class SubscriptionManager {

    private static final Logger LOGGER = LoggerFactory.getLogger(SubscriptionManager.class);

    private final RestTemplate restTemplate;

    @Value("${vnfm-adapter.auth.name}")
    private String username;

    @Value("${vnfm-adapter.auth.password}")
    private String password;

    @Autowired
    public SubscriptionManager(
            @Qualifier(SSL_BASED_CONFIGURABLE_REST_TEMPLATE) final RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * Send subscription request to the vnfm adapter
     *
     * @param pkgmSubscriptionRequest The subscription request to send
     * @return
     */
    public InlineResponse201 createSubscription(final PkgmSubscriptionRequest pkgmSubscriptionRequest) {
        final byte[] encodedAuth = getBasicAuth(username, password);
        final String authHeader = "Basic " + new String(encodedAuth);
        final String uri = Constant.VNFM_ADAPTER_SUBSCRIPTION_ENDPOINT;
        final HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON);
        headers.add(HttpHeaders.AUTHORIZATION, authHeader);
        headers.add(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON);
        final HttpEntity<?> request = new HttpEntity<>(pkgmSubscriptionRequest, headers);
        LOGGER.info("Creating Subscription using request: {}", pkgmSubscriptionRequest);
        return restTemplate.exchange(uri, HttpMethod.POST, request, InlineResponse201.class).getBody();
    }

    private byte[] getBasicAuth(final String username, final String password) {
        final String auth = username + ":" + password;
        return Base64.encodeBase64(auth.getBytes(StandardCharsets.ISO_8859_1));
    }

}
