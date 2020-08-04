# Robot Library
This catalog contains python files used in Robot tests for dcaegen2.ves.

# DMaaP Simulator
Catalog dmaap_simulator contains python implementation of DMaaP simulator. It uses python BaseHTTPServer to expose endpoints.

# DMaaP Tests
Catalog dmaap_test contains tests that are used to validate DMaaP simulator. Test are using "pytest" and "MagicMock". 

### In order to run tests: 
1. create virtual environemnt with Python 2.7;
2. install requirements from file requirements.txt located in dmaap_test;
3. set environement variable WORKSPACE to point root csit catalog
4. run py.test command in catalog dmaap_test
