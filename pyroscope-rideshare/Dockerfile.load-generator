FROM python:3.10@sha256:c10791e6f69086d5216f7b5d3b839929c454e24305867ed9bc5152f0355b5423

RUN pip3 install requests

COPY load-generator.py ./load-generator.py

ENV PYTHONUNBUFFERED=1

CMD [ "python", "load-generator.py" ]
