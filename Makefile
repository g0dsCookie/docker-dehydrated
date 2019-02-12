MAJOR			?=
MINOR			?=
PATCH			?=

TAG		= g0dscookie/dehydrated
TAGLIST	= -t ${TAG}:${MAJOR} -t ${TAG}:${MAJOR}.${MINOR} -t ${TAG}:${MAJOR}.${MINOR}.${PATCH}
BUILDARGS = --build-arg MAJOR=${MAJOR} --build-arg MINOR=${MINOR} --build-arg PATCH=${PATCH}

.PHONY: nothing
nothing:
	@echo "No job given."
	@exit 1

.PHONY: alpine3.9
alpine3.9:
	docker build ${BUILDARGS} ${TAGLIST} alpine3.9

.PHONY: alpine3.9-latest
alpine3.9-latest:
	docker build ${BUILDARGS} -t ${TAG}:latest ${TAGLIST} alpine3.9

.PHONY: clean
clean:
	docker rmi -f $(shell docker images -aq ${TAG})

.PHONY: push
push:
	docker push ${TAG}