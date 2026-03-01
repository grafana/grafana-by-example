FROM python:3@sha256:61346539f7b26521a230e72c11da5ebd872924745074b19736e7d65ba748c366

WORKDIR /usr/src/app
COPY requirements.txt ./
COPY log-stream-processor.py ./
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5000
ENTRYPOINT [ "flask", "--app", "log-stream-processor", "run", "--host=0.0.0.0" ]


#ENTRYPOINT [ "sleep", "3600" ]
#ENTRYPOINT [ "python", "--version" ]