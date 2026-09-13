FROM python:3.14@sha256:e06cc1111ed84189e91866447f562b89faadbfbbb9937cd67e6bf4172cdb45df

RUN pip3 install requests

COPY load-generator.py ./load-generator.py

ENV PYTHONUNBUFFERED=1

CMD [ "python", "load-generator.py" ]
