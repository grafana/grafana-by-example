FROM python:3@sha256:1eb6b7d4b76454b1de8317863ac3213b678c337b27e604a4e3fb70bddbb2bad7

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY metrics-generator.py ./
RUN pip install --no-cache-dir -r requirements.txt


#ENTRYPOINT [ "sleep", "3600" ]
#ENTRYPOINT [ "python", "--version" ]
ENTRYPOINT [ "python", "metrics-generator.py", "regionalServices" ] 