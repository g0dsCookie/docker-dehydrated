VERSION			?= latest

USERNAME		?= g0dscookie
SERVICE			?= dehydrated
TAG				= $(USERNAME)/$(SERVICE)

.PHONY: build
build:
	./build.py --version $(VERSION)

.PHONE: build-all
build-all:
	./build.py --version all

.PHONY: push
push:
	docker push $(TAG)