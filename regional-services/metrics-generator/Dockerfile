FROM python:3@sha256:61346539f7b26521a230e72c11da5ebd872924745074b19736e7d65ba748c366

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY metrics-generator.py ./
RUN pip install --no-cache-dir -r requirements.txt


#ENTRYPOINT [ "sleep", "3600" ]
#ENTRYPOINT [ "python", "--version" ]
ENTRYPOINT [ "python", "metrics-generator.py", "regionalServices" ] 