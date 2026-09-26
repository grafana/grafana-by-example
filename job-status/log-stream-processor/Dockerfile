FROM python:3@sha256:be8ccd085666c34273c9dc5607c9842f8b2e3116128aae45148ce164c07ce09d

WORKDIR /usr/src/app
COPY requirements.txt ./
COPY log-stream-processor.py ./
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000
ENTRYPOINT [ "flask", "--app", "log-stream-processor", "run", "--host=0.0.0.0" ]


#ENTRYPOINT [ "sleep", "3600" ]
#ENTRYPOINT [ "python", "--version" ]