#
# ============LICENSE_START=======================================================
#  Copyright (C) 2019 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
#

import certifi
import os


def add_onap_ca_cert():
    cafile = certifi.where()
    dir_path = os.path.dirname(os.path.realpath(__file__))
    datarouter_ca = dir_path + '/onap_ca_cert.pem'
    with open(datarouter_ca, 'rb') as infile:
        customca = infile.read()

    with open(cafile, 'ab') as outfile:
        outfile.write(customca)

    print("Added DR Cert to CA")


def remove_onap_ca_cert():
    cafile = certifi.where()
    number_of_lines_to_delete = 39
    count = 0
    dr_cert_exists = False

    with open(cafile, 'r+b', buffering=0) as outfile:
        for line in outfile.readlines()[-35:-34]:
            if '# Serial: 0x9EAEEDC0A7CEB59D'.encode() in line:
                dr_cert_exists = True
        if dr_cert_exists:
            outfile.seek(0, os.SEEK_END)
            end = outfile.tell()
            while outfile.tell() > 0:
                outfile.seek(-1, os.SEEK_CUR)
                char = outfile.read(1)
                if char == b'\n':
                    count += 1
                if count == number_of_lines_to_delete:
                    outfile.truncate()
                    print(
                        "Removed " + str(number_of_lines_to_delete) + " lines from end of CA File")
                    exit(0)
                outfile.seek(-1, os.SEEK_CUR)
        else:
            print("No DR cert in CA File to remove")

    if count < number_of_lines_to_delete + 1:
        print("Number of lines in file less than number of lines to delete. Exiting...")
        exit(1)
