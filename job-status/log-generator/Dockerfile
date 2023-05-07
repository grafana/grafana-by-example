FROM python:3

WORKDIR /usr/src/app
COPY requirements.txt ./
COPY log-generator.py ./
RUN pip install --no-cache-dir -r requirements.txt
ENTRYPOINT [ "python3", "log-generator.py" ] 

#ENTRYPOINT [ "sleep", "3600" ]
#ENTRYPOINT [ "python", "--version" ]