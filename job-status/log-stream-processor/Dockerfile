FROM python:3@sha256:8edbf9e42c7fb168b9c523718ed907117e6d2e60f5889c0c499bbda3a787da53

WORKDIR /usr/src/app
COPY requirements.txt ./
COPY log-stream-processor.py ./
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000
ENTRYPOINT [ "flask", "--app", "log-stream-processor", "run", "--host=0.0.0.0" ]


#ENTRYPOINT [ "sleep", "3600" ]
#ENTRYPOINT [ "python", "--version" ]