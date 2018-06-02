FROM ubuntu:latest

RUN apt-get update -y
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y nodejs npm

ARG app_path="/opt/app"

RUN mkdir ${app_path}
RUN mkdir ${app_path}/logs/

ADD api.py ${app_path}
ADD views ${app_path}/views

ADD requirements.txt ${app_path}

RUN pip3 install -r ${app_path}/requirements.txt

EXPOSE 80
CMD ["bash","-c","cd /opt/app/ && python3 api.py"]
