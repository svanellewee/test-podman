USERNAME = scatman
DOCKER_TAG = test-pod
CONTAINER_NAME = test-pod-123

testme:
	$(shell echo $DOCKER_HOST2)


build: clean
	DOCKER_BUILDKIT=1 docker image build \
                          --no-cache \
                          --tag $(DOCKER_TAG) .

run-direct: build 
	docker run -it --rm --name $(CONTAINER_NAME)  \
		-v ./some_subdir:/home/$(USERNAME)/some_subdir \
		$(DOCKER_TAG) bash

test-mount: 
	docker exec -it $(CONTAINER_NAME) ls ./some_subdir && \
	docker exec -it $(CONTAINER_NAME) touch ./some_subdir/something

# run-direct:
# 	docker run -it --rm --name test-pod  \
# 		--mount type=bind,source=./some_subdir,target=/home/app/some_subdir,relabel=shared \
# 		test-podman bash

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
	docker rmi $(DOCKER_TAG) || true

clean: nuke-containers nuke-volumes clean-images
