#!/bin/bash

# options:
# remove stopped containers and untagged images
#   $bash docker_delete.sh
# remove all stopped|running containers and untagged images
#   $bash docker_delete.sh --reset
# remove containers|images|tags matching {repository|image|repository\image|tag|image:tag}
# pattern and untagged images
#   $bash docker_delete.sh --purge {image}
# everything
#   $bash docker_delete.sh --nuclear

if [ "$1" == "--reset" ]; then
    # Remove all containers regardless of state
    docker rm -vf $(docker ps -a -q) 2>/dev/null || echo "No more containers to remove."
elif [ "$1" == "--purge" ]; then
    # Attempt to remove running containers that are using the images we're trying to purge first.
    (docker rm -vf $(docker ps -a | grep "$2/\|/$2 \| $2 \|:$2\|$2-\|$2:\|$2_" | awk '{print $1}') 2>/dev/null || echo "No containers using the \"$2\" image, continuing purge.") &&\
    # Remove all images matching arg given after "--purge"
    docker rmi $(docker images | grep "$2/\|/$2 \| $2 \|$2 \|$2-\|$2_" | awk '{print $3}') 2>/dev/null || echo "No images matching \"$2\" to purge."
else
    # This alternate only removes "stopped" containers
    docker rm -vf $(docker ps -a | grep "Exited" | awk '{print $1}') 2>/dev/null || echo "No stopped containers to remove."
fi

if [ "$1" == "--nuclear" ]; then
    docker rm -vf $(docker ps -a -q) 2>/dev/null || echo "No more containers to remove."
    docker rmi $(docker images -q) 2>/dev/null || echo "No more images to remove."
else
    # Always remove untagged images
    docker rmi $(docker images | grep "<none>" | awk '{print $3}') 2>/dev/null || echo "No untagged images to delete."
fi

docker rm $(docker ps -q -f status=exited)

docker volume rm $(docker volume ls -qf dangling=true)

docker rmi $(docker images --filter "dangling=true" -q --no-trunc)

#uncomment this to remove all docker images
#docker rmi --force $(docker images |  awk '{print $3}') 2>/dev/null || echo "No images to delete."
exit 0
