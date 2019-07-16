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

package org.onap.so.sdc.simulator.providers;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.StreamUtils;
import org.springframework.util.StringUtils;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Optional;
import java.util.UUID;

import static org.junit.Assert.*;
import static org.junit.Assert.assertArrayEquals;

public class ResourceProviderImplTest {
    @Rule
    public TemporaryFolder temporaryFolder = new TemporaryFolder();

    private static final String DUMMY_CONTENT = "Hell world";

    @Test
    public void test_getResource_withValidPath_matchContent() throws IOException {
        final File folder = temporaryFolder.newFolder();
        final Path file = Files.createFile(folder.toPath().resolve("empty.csar"));

        Files.write(file, DUMMY_CONTENT.getBytes());

        final ResourceProviderImpl objUnderTest = new ResourceProviderImpl(folder.getPath());

        assertArrayEquals(DUMMY_CONTENT.getBytes(), objUnderTest.getResource("empty").get());
    }

    @Test
    public void test_getResource_withoutValidPath_matchContent() throws IOException {
        final ClassPathResource classPathResource = new ClassPathResource("/csar/unalteredVNFD.csar", this.getClass());

        final byte[] expectedResult = StreamUtils.copyToByteArray(classPathResource.getInputStream());

        final ResourceProviderImpl objUnderTest = new ResourceProviderImpl("");

        assertArrayEquals(expectedResult, objUnderTest.getResource("unalteredVNFD").get());
    }

    @Test
    public void test_getResource_unbleToreadFileFromClasspath_emptyOptional() throws IOException {

        final ResourceProviderImpl objUnderTest = new ResourceProviderImpl(""){
            @Override
            String getDefaultCsarPath() {
                return "/some/dummy/path";
            }
        };
        assertFalse(objUnderTest.getResource("unalteredVNFD").isPresent());

    }

    @Test
    public void test_getResource_withValidPathAndUnabletoRead_emptyOptional() throws IOException {
        final File folder = temporaryFolder.newFolder();
        final Path file = Files.createFile(folder.toPath().resolve("empty.csar"));

        Files.write(file, DUMMY_CONTENT.getBytes());
        file.toFile().setReadable(false);

        final ResourceProviderImpl objUnderTest = new ResourceProviderImpl(folder.getPath());

        assertFalse(objUnderTest.getResource("empty").isPresent());

    }

}