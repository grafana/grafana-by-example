FROM python:3@sha256:e4bc83a3314d078d651f06c8440e9a03ba892ee2f6577437f174abd8731fb343

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY metrics-generator.py ./
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT [ "python3", "metrics-generator.py" ]