FROM python:3@sha256:be8ccd085666c34273c9dc5607c9842f8b2e3116128aae45148ce164c07ce09d

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY metrics-generator.py ./
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT [ "python3", "metrics-generator.py" ]