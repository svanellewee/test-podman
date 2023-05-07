CONT_USER ?= scatman
DOCKER_TAG ?= test-pod
CONT_NAME ?= test-pod-123

build: clean
	DOCKER_BUILDKIT=1 docker image build \
			--build-arg USERNAME=$(CONT_USER) \
                        --no-cache \
                        --tag $(DOCKER_TAG) .

run-direct: build 
	docker run -it --userns=keep-id --rm --name $(CONT_NAME)  \
		-v ./some_subdir:/home/$(CONT_USER)/some_subdir:Z \
		$(DOCKER_TAG) bash

run-direct-again: build 
	docker run -it --rm --name $(CONT_NAME)  \
		--mount type=bind,source=./some_subdir,target=/home/$(CONT_USER)/some_subdir,relabel=shared \
		$(DOCKER_TAG) bash

test-mount: 
	docker exec -it $(CONT_NAME) ls -ahtlr ./ ./some_subdir && \
	docker exec -it $(CONT_NAME) touch ./some_subdir/something

DOCKER_HOST:
	@podman info --format '{{.Host.RemoteSocket.Path}}'

list-vols:
	docker volume ls

nuke-containers:
	@echo "=============Cleaning containers"
	docker ps -a | tail -n+2 | cut -d ' '  -f1 | xargs -I {} docker rm {}

nuke-volumes:
	@echo "=============Cleaning volumes"
	docker volume ls | tail -n+2 | tr -s ' '  | cut -d ' ' -f2| tee | xargs -I {} docker volume rm -f  {} 

clean-images:
	@echo "=============Cleaning images"
	docker images ls | tr -s ' ' | tail -n+2 | cut -d ' ' -f3 | xargs -I {} docker rmi {}

clean: nuke-containers nuke-volumes clean-images
