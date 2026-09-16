FROM python:3@sha256:e06cc1111ed84189e91866447f562b89faadbfbbb9937cd67e6bf4172cdb45df

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY postgres-metrics.py ./
RUN pip install --no-cache-dir -r requirements.txt


#ENTRYPOINT [ "sleep", "3600" ]
#ENTRYPOINT [ "python", "--version" ]
ENTRYPOINT [ "python", "postgres-metrics.py", "metrics" ] 
#ENTRYPOINT [ "python", "postgres-metrics.py", "db-test" ] 