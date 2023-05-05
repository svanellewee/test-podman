DOCKER_TAG = test-pod
CONTAINER_NAME = test-pod-123
DOCKER_HOST = unix://$(shell podman info --format '{{.Host.RemoteSocket.Path}}')

clean:
	docker rmi $(DOCKER_TAG) || true

build: clean
	DOCKER_BUILDKIT=1 docker image build \
                          --no-cache \
                          --tag $(DOCKER_TAG) .

run-direct:
	docker run -it --rm --name $(CONTAINER_NAME)  \
		-v ./some_subdir:$(PWD)/some_subdir \
		$(DOCKER_TAG) bash

# run-direct:
# 	docker run -it --rm --name test-pod  \
# 		--mount type=bind,source=./some_subdir,target=/home/app/some_subdir,relabel=shared \
# 		test-podman bash

DOCKER_HOST:
	@podman info --format '{{.Host.RemoteSocket.Path}}'
