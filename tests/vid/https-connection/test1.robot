*** Settings ***
Library       SeleniumLibrary
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
${VID_SCALEOUT_ENDPOINT}           vid/mso/mso_create_vfmodule_instance/0d8a98d8-d7ca-4c26-b7ab-81d3729e3b6c/vnfs/61c19619-2714-46f8-90c9-39734e4f545f
${VALID_SCALEOUT_REQ_FILEPATH}     ${VID_TEST_ASSET_DIR}/vid_create_vfmodule_request.json
${VALID_SCALEOUT_RESP_FILEPATH}    ${VID_TEST_ASSET_DIR}/so_action_response.json


*** Test Cases ***
Triggering create vfmodule operation in SO is performed using HTTPS
    Setup Expected Data In SO Simulator  ${EXPECTED_SO_RESPONSES_FILEPATH}  ${SO_SIMULATOR_BASE_URL}  setResponse
    ${jsessionIdCookie}=  Login to VID Internally  ${VID_HTTP_BASE_URL}/vid/login.htm  demo  Kp8bJ4SXszM0WX
    Log to console  loginResponse:  ${jsessionIdCookie}
    ${soExpectedJsonResp}=  json_from_file  ${VALID_SCALEOUT_RESP_FILEPATH}
    ${soResponse}=  Send Post request from VID FE  ${VID_HTTP_BASE_URL}  ${VID_SCALEOUT_ENDPOINT}  ${VALID_SCALEOUT_REQ_FILEPATH}  ${VALID_SCALEOUT_RESP_FILEPATH}  ${jsessionIdCookie}
    Dictionaries Should Be Equal  ${soExpectedJsonResp}  ${soResponse.json()['entity']}
    [Teardown]    Close Browser