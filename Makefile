# A simple service that speaks the LAN IP address of a Raspberry Pi.
# It does this over and over forever, every 30 seconds.

DOCKERHUB_ID:=ibmosquito
SERVICE_NAME:="speak-ip"
SERVICE_VERSION:="1.0.0"
PATTERN_NAME:="pattern-speak-ip"
ARCH:="arm"
 
# Leave blank for open DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"
CONTAINER_CREDS:=

# The spoken message will contain the LAN IP address assigned to this interface
INTERFACE_NAME:=eth0

default: build run

build:
	docker build -t $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) .

dev: stop build
	docker run -it -v `pwd`:/outside \
          --name ${SERVICE_NAME} \
          --device /dev/snd \
          --net=host \
          -e INTERFACE_NAME=$(INTERFACE_NAME) \
          $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) /bin/sh

run: stop
	docker run -d \
          --name ${SERVICE_NAME} \
          --restart unless-stopped \
          --device /dev/snd \
          --net=host \
          -e INTERFACE_NAME=$(INTERFACE_NAME) \
          $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION)

test:
	@echo "Attach a speaker to your pi and listen."

push:
	docker push $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) 

publish-service:
	@ARCH=$(ARCH) \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        SERVICE_CONTAINER="$(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION)" \
        hzn exchange service publish -O $(CONTAINER_CREDS) -f service.json --pull-image

publish-pattern:
	@ARCH=$(ARCH) \
        SERVICE_NAME="$(SERVICE_NAME)" \
        SERVICE_VERSION="$(SERVICE_VERSION)"\
        PATTERN_NAME="$(PATTERN_NAME)" \
	hzn exchange pattern publish -f pattern.json

stop:
	@docker rm -f ${SERVICE_NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKERHUB_ID)/$(SERVICE_NAME)_$(ARCH):$(SERVICE_VERSION) >/dev/null 2>&1 || :

agent-run:
	hzn register --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"

agent-stop:
	hzn unregister -f

.PHONY: build dev run push publish-service publish-pattern test stop clean agent-run agent-stop
