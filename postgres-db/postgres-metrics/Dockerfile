FROM python:3@sha256:8edbf9e42c7fb168b9c523718ed907117e6d2e60f5889c0c499bbda3a787da53

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY postgres-metrics.py ./
RUN pip install --no-cache-dir -r requirements.txt


#ENTRYPOINT [ "sleep", "3600" ]
#ENTRYPOINT [ "python", "--version" ]
ENTRYPOINT [ "python", "postgres-metrics.py", "metrics" ] 
#ENTRYPOINT [ "python", "postgres-metrics.py", "db-test" ] 