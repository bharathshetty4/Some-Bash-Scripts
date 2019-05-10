#install minikube 
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.0.0/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube

export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export CHANGE_MINIKUBE_NONE_USER=true


#start minikube
sudo -E minikube start --vm-driver none --insecure-registry=$(ip addr | grep en | awk '/global/{print $2}' | cut -f1 -d/ | head -1):5000 --kubernetes-version v1.11.3 --cpus 4 --memory 8196 --disk-size 80g
