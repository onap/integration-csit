FROM frolvlad/alpine-python3

COPY SO.py /
ADD ./test_data_assets/ /

EXPOSE 8443

CMD [ "python", "./SO.py", "expected_so_requests.json", "expected_so_responses.json" ]