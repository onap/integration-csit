FROM python:3-alpine3.9

# `component` should be `so` or `aai`
ARG component
ENV component=$component

COPY SO.py /
RUN mkdir test_data_assets
ADD ./test_data_assets/ /test_data_assets

EXPOSE 8443

CMD python ./SO.py /test_data_assets/expected_${component}_requests.json /test_data_assets/expected_${component}_responses.json
