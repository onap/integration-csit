#!/bin/bash
#
# ===========LICENSE_START====================================================
#  Copyright (C) 2020 AT&T Intellectual Property. All rights reserved.
# ============================================================================
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
# ============LICENSE_END=====================================================
#

#
# Polls a topic for a message.  Additional text items can be specified,
# in which case, it discards messages that do not contain all of the
# specified text items.
#
# Exits with a non-zero status if no matching message is received on the
# topic before the timeout.
#

if [ $# -lt 1 ]
then
	echo "arg(s): topic-name [text-to-match1 [text-to-match2 ...]]" >&2
	exit 1
fi

topic="${1}"
shift

matched=no

while [ ${matched} = "no" ]
do
    msg=`curl -s -k "https://localhost:3905/events/${topic}/script/1?limit=1"`
	if [ $? -ne 0 -o "${msg}" = "[]" ]
	then
		echo not found >&2
		exit 2
	fi

	matched=yes
	for text in "$@"
	do
		echo "${msg}" | grep -q "${text}"
		if [ $? -ne 0 ]
		then
			matched=no
			break
		fi
	done
done

echo "${msg}"
