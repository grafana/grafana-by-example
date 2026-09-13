FROM python:3@sha256:e06cc1111ed84189e91866447f562b89faadbfbbb9937cd67e6bf4172cdb45df

WORKDIR /usr/src/app
COPY requirements.txt ./
COPY log-generator.py ./
RUN pip install --no-cache-dir -r requirements.txt
ENTRYPOINT [ "python3", "log-generator.py" ] 

#ENTRYPOINT [ "sleep", "3600" ]
#ENTRYPOINT [ "python", "--version" ]