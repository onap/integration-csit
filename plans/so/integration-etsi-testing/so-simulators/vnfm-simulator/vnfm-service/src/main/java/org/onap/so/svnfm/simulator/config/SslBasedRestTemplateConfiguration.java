/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2020 Nordix Foundation.
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
package org.onap.so.svnfm.simulator.config;

import com.google.gson.Gson;
import org.apache.http.client.HttpClient;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.JSON;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.json.GsonHttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.client.RestTemplate;
import java.security.KeyStore;
import java.util.Iterator;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 * @author Andrew Lamb (andrew.a.lamb@est.tech)
 */
@Configuration public class SslBasedRestTemplateConfiguration {

    private static final Logger logger = LoggerFactory.getLogger(SslBasedRestTemplateConfiguration.class);

    public static final String SSL_BASED_CONFIGURABLE_REST_TEMPLATE = "sslBasedConfigurableRestTemplate";

    @Value("${http.client.ssl.trust-store:#{null}}")
    private Resource trustStore;
    @Value("${http.client.ssl.trust-store-password:#{null}}")
    private String trustStorePassword;

    @Value("${server.ssl.key-store:#{null}}")
    private Resource keyStoreResource;
    @Value("${server.ssl.key--store-password:#{null}}")
    private String keyStorePassword;

    @Bean
    @Qualifier(SSL_BASED_CONFIGURABLE_REST_TEMPLATE)
    public RestTemplate sslBasedrestTemplate() throws Exception {
        logger.info("Configuring {} ...", this.getClass().getCanonicalName());
        final RestTemplate restTemplate = new RestTemplate();
        final HttpClientBuilder builder = HttpClients.custom();

        if (keyStoreResource != null && trustStore != null) {
            logger.info("Setting key-store: {}", keyStoreResource.getURL());
            logger.info("Setting key-store-password: {}", keyStorePassword);
            final KeyStore keystore = KeyStore.getInstance("pkcs12");
            keystore.load(keyStoreResource.getInputStream(), keyStorePassword.toCharArray());

            logger.info("Setting client trust-store: {}", trustStore.getURL());
            logger.info("Setting client trust-store-password: {}", trustStorePassword);
            final SSLConnectionSocketFactory socketFactory = new SSLConnectionSocketFactory(
                    new SSLContextBuilder().loadTrustMaterial(trustStore.getURL(), trustStorePassword.toCharArray())
                            .loadKeyMaterial(keystore, keyStorePassword.toCharArray()).build());
            builder.setSSLSocketFactory(socketFactory);
        }

        final HttpClient httpClient = builder.build();
        final HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory(httpClient);
        restTemplate.setRequestFactory(factory);
        setGsonMessageConverter(restTemplate);
        return restTemplate;
    }

    public void setGsonMessageConverter(final RestTemplate restTemplate) {
        logger.info("Setting GsonMessageConverter ...");
        final Iterator<HttpMessageConverter<?>> iterator = restTemplate.getMessageConverters().iterator();
        while (iterator.hasNext()) {
            if (iterator.next() instanceof MappingJackson2HttpMessageConverter) {
                iterator.remove();
            }
        }
        final Gson gson = new JSON().getGson();
        restTemplate.getMessageConverters().add(new GsonHttpMessageConverter(gson));
        logger.info("Finished setting GsonMessageConverter ...");
    }

}
