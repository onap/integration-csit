FROM python:3-alpine3.9

# `component` should be `so` or `aai`
ARG component

COPY SO.py /
ADD ./test_data_assets/ /

EXPOSE 8443

CMD python ./SO.py expected_${component}_requests.json expected_${component}_responses.json
