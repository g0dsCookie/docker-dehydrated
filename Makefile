VERSION			?= latest

USERNAME		?= g0dscookie
SERVICE			?= dehydrated
TAG				= $(USERNAME)/$(SERVICE)

.PHONY: build
build:
	./build.py --version $(VERSION) --stdout

.PHONE: build-all
build-all:
	./build.py --version all --stdout

.PHONY: push
push:
	docker push $(TAG)