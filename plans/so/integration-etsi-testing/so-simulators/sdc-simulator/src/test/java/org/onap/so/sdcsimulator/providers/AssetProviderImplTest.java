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

package org.onap.so.sdcsimulator.providers;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertFalse;
import static org.onap.so.sdcsimulator.models.AssetType.RESOURCES;
import static org.onap.so.sdcsimulator.utils.Constants.DOT_CSAR;
import static org.onap.so.sdcsimulator.utils.Constants.FORWARD_SLASH;
import static org.onap.so.sdcsimulator.utils.Constants.MAIN_RESOURCE_FOLDER;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.util.StreamUtils;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 * @author Eoin Hanan (eoin.hanan@est.tech)
 */
public class AssetProviderImplTest {

    private static final String VNF_RESOURCE_ID = "73522444-e8e9-49c1-be29-d355800aa349";

    @Rule
    public TemporaryFolder temporaryFolder = new TemporaryFolder();

    private static final String DUMMY_CONTENT = "Hello world";

    private final PathMatchingResourcePatternResolver resourcePatternResolver =
            new PathMatchingResourcePatternResolver();

    @Test
    public void test_getResource_withValidPath_matchContent() throws IOException {
        final File folder = temporaryFolder.newFolder(RESOURCES.toString());
        final String uuid = UUID.randomUUID().toString();
        final Path file = Files.createFile(folder.toPath().resolve(uuid + DOT_CSAR));

        Files.write(file, DUMMY_CONTENT.getBytes());

        final AssetProviderImpl objUnderTest = new AssetProviderImpl(folder.getParent(), resourcePatternResolver);

        assertArrayEquals(DUMMY_CONTENT.getBytes(), objUnderTest.getAsset(uuid, RESOURCES).get());
    }

    @Test
    public void test_getResource_withoutValidPath_matchContent() throws IOException {
        final String validCsarPath = MAIN_RESOURCE_FOLDER + RESOURCES + FORWARD_SLASH + VNF_RESOURCE_ID + DOT_CSAR;
        final ClassPathResource classPathResource = new ClassPathResource(validCsarPath, this.getClass());

        final byte[] expectedResult = StreamUtils.copyToByteArray(classPathResource.getInputStream());

        final AssetProviderImpl objUnderTest = new AssetProviderImpl("", resourcePatternResolver);

        assertArrayEquals(expectedResult, objUnderTest.getAsset(VNF_RESOURCE_ID, RESOURCES).get());
    }

    @Test
    public void test_getResource_unbleToReadFileFromClasspath_emptyOptional() throws IOException {

        final AssetProviderImpl objUnderTest = new AssetProviderImpl("", resourcePatternResolver);
        assertFalse(objUnderTest.getAsset(UUID.randomUUID().toString(), RESOURCES).isPresent());

    }
}
