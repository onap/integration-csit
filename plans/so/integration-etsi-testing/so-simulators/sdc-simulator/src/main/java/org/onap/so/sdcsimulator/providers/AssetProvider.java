/*-
 * ============LICENSE_START=======================================================
 *   Copyright (C) 2019 Nordix Foundation.
 * ================================================================================
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  SPDX-License-Identifier: Apache-2.0
 * ============LICENSE_END=========================================================
 */

package org.onap.so.sdcsimulator.providers;

import java.util.Optional;
import java.util.Set;
import org.onap.so.sdcsimulator.models.AssetInfo;
import org.onap.so.sdcsimulator.models.AssetType;
import org.onap.so.sdcsimulator.models.Metadata;

/**
 * @author Eoin Hanan (eoin.hanan@est.tech)
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public interface AssetProvider {

    Optional<byte[]> getAsset(final String csarId, final AssetType assetType);

    Set<AssetInfo> getAssetInfo(final AssetType assetType);
    
    Optional<Metadata> getMetadata(final String csarId, final AssetType assetType);

}
