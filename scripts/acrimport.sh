export REGISTRY_NAME='aksacr#########acr'
export IMAGE_REGISTRY=docker.io
export IMAGE_NAME=myoung34/github-runner
export IMAGE_TAG=latest

az acr import --name $REGISTRY_NAME --source $IMAGE_REGISTRY/$IMAGE_NAME:$IMAGE_TAG --image $IMAGE_NAME:$IMAGE_TAG
