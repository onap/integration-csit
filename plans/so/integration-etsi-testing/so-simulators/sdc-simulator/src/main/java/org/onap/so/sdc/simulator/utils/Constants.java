/*
 * ============LICENSE_START======================================================= Copyright (C) 2019 Nordix
 * Foundation. ================================================================================ Licensed under the
 * Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may
 * obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0 ============LICENSE_END=========================================================
 */

package org.onap.so.sdc.simulator.utils;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 */
public class Constants {

    public static final String BASE_URL = "/sdc/v1";

    public static final String CATALOG_URL = BASE_URL + "/catalog";

    public static final String HEALTHY = "healthy";

    public static final String DEFAULT_CSAR_NAME = "default_csar_file";

    public static final String DOT = ".";

    public static final String DOT_CSAR = DOT + "csar";

    public static final String DEFAULT_CSAR_NAME_WITH_EXT = DEFAULT_CSAR_NAME + DOT_CSAR;

    public static final String DEFAULT_CSAR_PATH = "/csar/" + DEFAULT_CSAR_NAME_WITH_EXT;


    private Constants() {}
}
