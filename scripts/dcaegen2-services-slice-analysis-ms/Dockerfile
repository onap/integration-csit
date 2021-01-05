FROM python:alpine3.7

ADD configdb-sim.py /

ADD ./sim-data /

RUN pip install Flask --trusted-host pypi.org --trusted-host files.pythonhosted.org

RUN pip install requests --trusted-host pypi.org --trusted-host files.pythonhosted.org

EXPOSE 5000

CMD ["flask", "run", "--host", "0.0.0.0"]

CMD [ "python", "./configdb-sim.py" ]
