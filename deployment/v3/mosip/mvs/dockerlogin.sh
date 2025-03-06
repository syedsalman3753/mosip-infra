#!/bin/bash

# Prompt the user for Docker Hub (or Docker registry) credentials
DOCKER_REGISTRY="index.docker.io/v1/"
DOCKER_USERNAME="technoforte2023"
DOCKER_PASSWORD="Palms@123#"
NAMESPACE="mvs"

# Set the default registry to Docker Hub if no registry is specified
#if [ -z "$DOCKER_REGISTRY" ]; then
 # DOCKER_REGISTRY="https://hub.docker.com/repository/docker/niradocker/admin-service/general"
#fi
kubectl create secret docker-registry dockerhub --docker-server=$DOCKER_REGISTRY \
	  --docker-username=$DOCKER_USERNAME \
	    --docker-password=$DOCKER_PASSWORD \
             --namespace=$NAMESPACE\

	     
	     
#kubectl patch serviceaccount print-print-service \
  # -p '{"imagePullSecrets": [{"name": "dockerhub"}]}' \
 #     -n printtest
	    
#TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_USERNAME}'", "password": "'${DOCKER_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)

#REPO_LIST=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${NAMESPACE}/?page_size=100 | jq -r '.results|.[]|.name')

#for i in ${REPO_LIST}
#do
#	  echo "${i}:"
	    # tags
#	      IMAGE_TAGS=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${ORG}/${i}/tags/?page_size=100 | jq -r '.results|.[]|.name')
#	        for j in ${IMAGE_TAGS}
#			  do
#				      echo "  - ${j}"
#				        done
#					  echo
#				  done
# Log in to Docker using the provided credentials
#echo "$DOCKER_PASSWORD" | docker login $DOCKER_REGISTRY -u "$DOCKER_USERNAME" --password-stdin

# Check if the login was successful
if [ $? -eq 0 ]; then
  echo "Login to Docker registry ($DOCKER_REGISTRY) succeeded."
else
  echo "Login to Docker registry ($DOCKER_REGISTRY) failed."
fi
#PATH=$(pwd)
#Image="${PATH##*/}"
#IMAGE_NAME="niradocker/$Image:niradev-1.2.0.1-N1"

#echo "Pulling the Docker image: $IMAGE_NAME"

#docker pull $IMAGE_NAME

#if [ $? -eq 0 ]; then
#	  echo "Docker image pulled successfully."
 # else
#	    echo "Failed to pull Docker image."
#	      exit 1
#fi
#images=$(curl -s "https://hub.docker.com/v2/repositories/sjkarthik/?page_size=100" | jq '.results[].name')
#echo "$images"

