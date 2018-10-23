*** Settings ***
Library 	  RequestsLibrary
Library       OperatingSystem
Library       json
Resource      ../../common.robot
Resource      ../resources/keywords/scaleout_vid_keywords.robot


*** Variables ***
${VID_TEST_ASSET_DIR}              %{WORKSPACE}/tests/vid/resources/simulators/test_data_assets
${EXPECTED_SO_RESPONSES_FILEPATH}  ${VID_TEST_ASSET_DIR}/expected_so_responses.json
${EXPECTED_SO_REQUESTS_FILEPATH}   ${VID_TEST_ASSET_DIR}/expected_so_requests.json
${SO_SIMULATOR_BASE_URL}           http://${SO_SIMULATOR_IP}:8443
${VID_HTTP_BASE_URL}               http://${VID_IP}:8080
${VID_SCALEOUT_ENDPOINT}           vid/change-management/workflow/ws-test-0310-8
${VALID_SCALEOUT_REQ_FILEPATH}     ${VID_TEST_ASSET_DIR}/vid_scaleout_request.json
${VALID_SCALEOUT_RESP_FILEPATH}    ${VID_TEST_ASSET_DIR}/so_action_response.json


*** Test Cases ***
Triggering scaleout workflow operation succeeds
    Setup Expected Data In SO Simulator  ${EXPECTED_SO_RESPONSES_FILEPATH}  ${SO_SIMULATOR_BASE_URL}  setResponse
    ${soExpectedJsonResp}=  json_from_file  ${VALID_SCALEOUT_RESP_FILEPATH}
    ${vidRequest}=  json_from_file  ${VALID_SCALEOUT_REQ_FILEPATH}
    ${headers}=  Create Dictionary     Content-Type=application/json
    ${session}=  Create Session  alias=vid  url=${VID_HTTP_BASE_URL}  headers=${headers}
    ${resp}=  Post Request  vid  uri=/${VID_SCALEOUT_ENDPOINT}  data=${vidRequest}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}     200
    Dictionaries Should Be Equal  ${soExpectedJsonResp}  ${resp.json()['entity']}



