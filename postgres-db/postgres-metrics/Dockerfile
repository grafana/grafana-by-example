FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY postgres-metrics.py ./
RUN pip install --no-cache-dir -r requirements.txt


#ENTRYPOINT [ "sleep", "3600" ]
#ENTRYPOINT [ "python", "--version" ]
ENTRYPOINT [ "python", "postgres-metrics.py", "metrics" ] 
#ENTRYPOINT [ "python", "postgres-metrics.py", "db-test" ] 