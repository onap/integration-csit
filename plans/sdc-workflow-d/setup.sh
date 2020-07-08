#!/bin/bash
#
# Copyright 2019 © Samsung Electronics Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# It can enable HTTPS for SDC component
export SDC_TEST_HTTPS="${SDC_TEST_HTTPS:-false}"

# By default all images are from remote upstream registry, this option
# provides the chance to test locally built images
export SDC_LOCAL_IMAGES="${SDC_LOCAL_IMAGES:-false}"

export WORKFLOW_LOCAL_IMAGES="${WORKFLOW_LOCAL_IMAGES:-false}"

# For this to take effect SDC_LOCAL_IMAGES must be enabled...
#
# The path to the local sdc git repo from which the local images have
# been built - it also affects the tag used - if left empty *AND*
# local images are used *AND* SDC_LOCAL_TAG is unset then the tag
# will be set to: 'latest'
#
# BEWARE: Using local images with an incorrect git repo could lead to
# problems...set SDC_LOCAL_GITREPO or GERRIT_BRANCH properly...
export SDC_LOCAL_GITREPO="${SDC_LOCAL_GITREPO}"

# For this to take effect SDC_LOCAL_IMAGES must be enabled...
#
# This will set the tag for local images - leaving this empty *AND*
# with unset SDC_LOCAL_GITREPO the local images will fallback to the
# tag: 'latest'
export SDC_LOCAL_TAG="${SDC_LOCAL_TAG}"


export WORKFLOW_LOCAL_GITREPO="${WORKFLOW_LOCAL_GITREPO}"



source ${WORKSPACE}/scripts/sdc-workflow-d/sdc_workflow_d.sh
