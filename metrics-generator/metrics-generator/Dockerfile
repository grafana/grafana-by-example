FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY metrics-generator.py ./
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT [ "python3", "metrics-generator.py" ]