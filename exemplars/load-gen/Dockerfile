FROM python:3.14@sha256:12d187a59ecdeb95df0a78cd6107a84398455365a66cc2183db2be42b6067d33

RUN pip3 install requests

COPY load-generator.py ./load-generator.py

ENV PYTHONUNBUFFERED=1

CMD [ "python", "load-generator.py" ]
