*** Settings ***
Library		OperatingSystem
Library		RequestsLibrary
Library		Process

Resource	../../resources/common-keywords.robot

*** Variables ***


*** Test Cases ***

######### Single file, SFTP

Verify single event with single 1MB SFTP file. From event poll to published file
	[TAGS]							DFC_FUNCTIONAL_1
	[Documentation]					Verify single event with single SFTP 1MB file from event poll to published file.
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/../dfc-containers-clean.sh
    Set Environment Variable  		MR_TC           --tc100
    Set Environment Variable  		DR_TC           --tc normal
    Set Environment Variable  		DR_REDIR_TC     --tc normal
    Set Environment Variable  		NUM_FTPFILES    1
    Set Environment Variable  		NUM_PNFS        1
    Set Environment Variable  		FILE_SIZE       1MB
    Set Environment Variable  		FTP_TYPE        SFTP
    ${cli_cmd_output}=          	Run Process     ./simulators-start.sh    cwd=${SIMGROUP_ROOT}
	MR Sim Emitted Files Equal    	0													                                #Verify 0 file emitted from MR sim
	DR Sim Published Files Equal  	0													                                #Verify 0 file published to DR sim
	${cli_cmd_output}=          	Run Process		${DFC_ROOT}/dfc-start.sh  cwd=${DFC_ROOT}
	Wait Until Keyword Succeeds	1 minute	10 sec	MR Sim Emitted Files Equal    	1	                                #Verify 1 file emitted from MR sim
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Query Not Published Equal    	1	                        #Verify 1 query response for not published files
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Published Files Equal    	1	                            #Verify 1 file published to DR sim
	DR Redir Sim Downloaded Volume Equal  	1 000 000													                #Verify 1 000 000 bytes published file data in DR redir sim
	${cli_cmd_output}=				Run Process     ${SIMGROUP_ROOT}/simulators-kill.sh
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/dfc-kill.sh

Verify single event with single 5MB SFTP file. From event poll to published file
	[TAGS]							DFC_FUNCTIONAL_2
	[Documentation]					Verify single event with single SFTP 5MB file from event poll to published file.
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/../dfc-containers-clean.sh
    Set Environment Variable  		MR_TC           --tc101
    Set Environment Variable  		DR_TC           --tc normal
    Set Environment Variable  		DR_REDIR_TC     --tc normal
    Set Environment Variable  		NUM_FTPFILES    1
    Set Environment Variable  		NUM_PNFS        1
    Set Environment Variable  		FILE_SIZE       5MB
    Set Environment Variable  		FTP_TYPE        SFTP
    ${cli_cmd_output}=          	Run Process     ./simulators-start.sh    cwd=${SIMGROUP_ROOT}
	MR Sim Emitted Files Equal    	0													                                #Verify 0 file emitted from MR sim
	DR Sim Published Files Equal  	0													                                #Verify 0 file published to DR sim
	${cli_cmd_output}=          	Run Process		${DFC_ROOT}/dfc-start.sh  cwd=${DFC_ROOT}
	Wait Until Keyword Succeeds	1 minute	10 sec	MR Sim Emitted Files Equal    	1	                                #Verify 1 file emitted from MR sim
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Query Not Published Equal    	1	                        #Verify 1 query response for not published files
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Published Files Equal    	1	                            #Verify 1 file published to DR sim
	DR Redir Sim Downloaded Volume Equal  	5 000 000													                #Verify 1 000 000 bytes published file data in DR redir sim
	${cli_cmd_output}=				Run Process     ${SIMGROUP_ROOT}/simulators-kill.sh
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/dfc-kill.sh

Verify single event with single 50MB SFTP file. From event poll to published file
	[TAGS]							DFC_FUNCTIONAL_3
	[Documentation]					Verify single event with single SFTP 50MB file from event poll to published file.
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/../dfc-containers-clean.sh
    Set Environment Variable  		MR_TC           --tc102
    Set Environment Variable  		DR_TC           --tc normal
    Set Environment Variable  		DR_REDIR_TC     --tc normal
    Set Environment Variable  		NUM_FTPFILES    1
    Set Environment Variable  		NUM_PNFS        1
    Set Environment Variable  		FILE_SIZE       50MB
    Set Environment Variable  		FTP_TYPE        SFTP
    ${cli_cmd_output}=          	Run Process     ./simulators-start.sh    cwd=${SIMGROUP_ROOT}
	MR Sim Emitted Files Equal    	0													                                #Verify 0 file emitted from MR sim
	DR Sim Published Files Equal  	0													                                #Verify 0 file published to DR sim
	${cli_cmd_output}=          	Run Process		${DFC_ROOT}/dfc-start.sh  cwd=${DFC_ROOT}
	Wait Until Keyword Succeeds	1 minute	10 sec	MR Sim Emitted Files Equal    	1	                                #Verify 1 file emitted from MR sim
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Query Not Published Equal    	1	                        #Verify 1 query response for not published files
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Published Files Equal    	1	                            #Verify 1 file published to DR sim
	DR Redir Sim Downloaded Volume Equal  	50 000 000													                #Verify 50 000 000 bytes published file data in DR redir sim
	${cli_cmd_output}=				Run Process     ${SIMGROUP_ROOT}/simulators-kill.sh
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/dfc-kill.sh


######### Single file, FTPS

Verify single event with single 1MB FTPS file. From event poll to published file
	[TAGS]							DFC_FUNCTIONAL_10
	[Documentation]					Verify single event with single FTPS 1MB file from event poll to published file.
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/../dfc-containers-clean.sh
    Set Environment Variable  		MR_TC           --tc200
    Set Environment Variable  		DR_TC           --tc normal
    Set Environment Variable  		DR_REDIR_TC     --tc normal
    Set Environment Variable  		NUM_FTPFILES    1
    Set Environment Variable  		NUM_PNFS        1
    Set Environment Variable  		FILE_SIZE       1MB
    Set Environment Variable  		FTP_TYPE        FTPS
    ${cli_cmd_output}=          	Run Process     ./simulators-start.sh    cwd=${SIMGROUP_ROOT}
	MR Sim Emitted Files Equal    	0													                                #Verify 0 file emitted from MR sim
	DR Sim Published Files Equal  	0													                                #Verify 0 file published to DR sim
	${cli_cmd_output}=          	Run Process		${DFC_ROOT}/dfc-start.sh  cwd=${DFC_ROOT}
	Wait Until Keyword Succeeds	1 minute	10 sec	MR Sim Emitted Files Equal    	1	                                #Verify 1 file emitted from MR sim
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Query Not Published Equal    	1	                        #Verify 1 query response for not published files
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Published Files Equal    	1	                            #Verify 1 file published to DR sim
	DR Redir Sim Downloaded Volume Equal  	1 000 000													                #Verify 1 000 000 bytes published file data in DR redir sim
	${cli_cmd_output}=				Run Process     ${SIMGROUP_ROOT}/simulators-kill.sh
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/dfc-kill.sh

Verify single event with single 5MB FTPS file. From event poll to published file
	[TAGS]							DFC_FUNCTIONAL_11
	[Documentation]					Verify single event with single FTPS 5MB file from event poll to published file.
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/../dfc-containers-clean.sh
    Set Environment Variable  		MR_TC           --tc201
    Set Environment Variable  		DR_TC           --tc normal
    Set Environment Variable  		DR_REDIR_TC     --tc normal
    Set Environment Variable  		NUM_FTPFILES    1
    Set Environment Variable  		NUM_PNFS        1
    Set Environment Variable  		FILE_SIZE       5MB
    Set Environment Variable  		FTP_TYPE        FTPS
    ${cli_cmd_output}=          	Run Process     ./simulators-start.sh    cwd=${SIMGROUP_ROOT}
	MR Sim Emitted Files Equal    	0													                                #Verify 0 file emitted from MR sim
	DR Sim Published Files Equal  	0													                                #Verify 0 file published to DR sim
	${cli_cmd_output}=          	Run Process		${DFC_ROOT}/dfc-start.sh  cwd=${DFC_ROOT}
	Wait Until Keyword Succeeds	1 minute	10 sec	MR Sim Emitted Files Equal    	1	                                #Verify 1 file emitted from MR sim
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Query Not Published Equal    	1	                        #Verify 1 query response for not published files
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Published Files Equal    	1	                            #Verify 1 file published to DR sim
	DR Redir Sim Downloaded Volume Equal  	5 000 000													                #Verify 5 000 000 bytes published file data in DR redir sim
	${cli_cmd_output}=				Run Process     ${SIMGROUP_ROOT}/simulators-kill.sh
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/dfc-kill.sh

Verify single event with single 50MB FTPS file. From event poll to published file
	[TAGS]							DFC_FUNCTIONAL_12
	[Documentation]					Verify single event with single FTPS 50MB file from event poll to published file.
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/../dfc-containers-clean.sh
    Set Environment Variable  		MR_TC           --tc202
    Set Environment Variable  		DR_TC           --tc normal
    Set Environment Variable  		DR_REDIR_TC     --tc normal
    Set Environment Variable  		NUM_FTPFILES    1
    Set Environment Variable  		NUM_PNFS        1
    Set Environment Variable  		FILE_SIZE       50MB
    Set Environment Variable  		FTP_TYPE        FTPS
    ${cli_cmd_output}=          	Run Process     ./simulators-start.sh    cwd=${SIMGROUP_ROOT}
	MR Sim Emitted Files Equal    	0													                                #Verify 0 file emitted from MR sim
	DR Sim Published Files Equal  	0													                                #Verify 0 file published to DR sim
	${cli_cmd_output}=          	Run Process		${DFC_ROOT}/dfc-start.sh  cwd=${DFC_ROOT}
	Wait Until Keyword Succeeds	1 minute	10 sec	MR Sim Emitted Files Equal    	1	                                #Verify 1 file emitted from MR sim
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Query Not Published Equal    	1	                        #Verify 1 query response for not published files
	Wait Until Keyword Succeeds	1 minute	10 sec	DR Sim Published Files Equal    	1	                            #Verify 1 file published to DR sim
	DR Redir Sim Downloaded Volume Equal  	50 000 000													                #Verify 50 000 000 bytes published file data in DR redir sim
	${cli_cmd_output}=				Run Process     ${SIMGROUP_ROOT}/simulators-kill.sh
	${cli_cmd_output}=				Run Process     ${DFC_ROOT}/dfc-kill.sh


*** Keywords ***

