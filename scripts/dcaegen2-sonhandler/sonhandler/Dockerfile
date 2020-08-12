
FROM python:alpine3.7

ADD configdb-oof-sim.py /

ADD ./sim-data /

RUN pip install Flask

RUN pip install requests

EXPOSE 5000

CMD ["flask", "run", "--host", "0.0.0.0"]

CMD [ "python", "./configdb-oof-sim.py" ]
