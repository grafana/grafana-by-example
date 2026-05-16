FROM python:3@sha256:89a288a9a9e9141b9f0c51744c358138da6369897792f1af3f5425e407d9529a

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY metrics-generator.py ./
RUN pip install --no-cache-dir -r requirements.txt

#ENTRYPOINT [ "sleep", "3600" ]