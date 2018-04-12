# dcape-app-minio Makefile

SHELL               = /bin/bash
CFG                ?= .env

# Site host
APP_SITE           ?= fs.dev.lan
# Minio Access key
ACCESS_KEY         ?= $(shell < /dev/urandom tr -dc A-Za-z0-9 | head -c20; echo)
# Minio Secret key
SECRET_KEY         ?= $(shell < /dev/urandom tr -dc A-Za-z0-9 | head -c40; echo)

# Docker image name
IMAGE              ?= minio/minio
# Docker image tag
IMAGE_VER          ?= RELEASE.2018-04-04T05-20-54Z
# Docker-compose project name (container name prefix)
PROJECT_NAME       ?= dcape
# dcape container name prefix
DCAPE_PROJECT_NAME ?= dcape
# dcape network attach to
DCAPE_NET          ?= $(DCAPE_PROJECT_NAME)_default

# Docker-compose image tag
DC_VER             ?= 1.14.0

define CONFIG_DEF
# ------------------------------------------------------------------------------
# Minio settings

# Site host
APP_SITE=$(APP_SITE)
# Minio Access key
ACCESS_KEY=$(ACCESS_KEY)
# Minio Secret key
SECRET_KEY=$(SECRET_KEY)

# Docker details

# Docker image name
IMAGE=$(IMAGE)
# Docker image tag
IMAGE_VER=$(IMAGE_VER)
# Docker-compose project name (container name prefix)
PROJECT_NAME=$(PROJECT_NAME)
# dcape network attach to
DCAPE_NET=$(DCAPE_NET)

endef
export CONFIG_DEF

-include $(CFG)
export

.PHONY: all $(CFG) setup start stop up reup down dc help

all: help

# ------------------------------------------------------------------------------
# webhook commands

start: up

start-hook: reup

stop: down

update: reup

# ------------------------------------------------------------------------------
# docker commands

## старт контейнеров
up:
up: CMD=up -d
up: dc

## рестарт контейнеров
reup:
reup: CMD=up --force-recreate -d
reup: dc

## остановка и удаление всех контейнеров
down:
down: CMD=rm -f -s
down: dc

# ------------------------------------------------------------------------------

# $$PWD используется для того, чтобы текущий каталог был доступен в контейнере по тому же пути
# и относительные тома новых контейнеров могли его использовать
## run docker-compose
dc: docker-compose.yml
	@docker run --rm  \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $$PWD:$$PWD \
	  -w $$PWD \
	  docker/compose:$(DC_VER) \
	  -p $$PROJECT_NAME \
	  $(CMD)

# ------------------------------------------------------------------------------

$(CFG):
	@[ -f $@ ] || echo "$$CONFIG_DEF" > $@

# ------------------------------------------------------------------------------

## List Makefile targets
help:
	@grep -A 1 "^##" Makefile | less

##
## Press 'q' for exit
##
