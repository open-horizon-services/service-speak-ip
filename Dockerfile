FROM ubuntu:18.04

RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    python3 \
    python3-pip \
    apt-utils \
    espeak \
    curl jq vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip3 install netifaces

WORKDIR /
COPY ./speak-ip.py /

CMD python3 speak-ip.py

