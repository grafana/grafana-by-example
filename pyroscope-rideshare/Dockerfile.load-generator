FROM python:3.14@sha256:1eb6b7d4b76454b1de8317863ac3213b678c337b27e604a4e3fb70bddbb2bad7

RUN pip3 install requests

COPY load-generator.py ./load-generator.py

ENV PYTHONUNBUFFERED=1

CMD [ "python", "load-generator.py" ]
