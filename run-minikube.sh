#!/bin/bash
if [[ -z $(kubectl get namespaces | grep jenkins) ]]; then
	kubectl create ns jenkins
fi

kubectl config set-context $(kubectl config current-context) --namespace=jenkins

if [[ -z $(kubectl get secrets | grep ssh-key-secret) ]]; then
	kubectl create secret generic ssh-key-secret --from-file=ssh-privatekey=./private/ssh/id_rsa_1 --from-file=ssh-publickey=./private/ssh/id_rsa_1.pub
	kubectl create secret generic tmnow-ssh-secret --from-file=ssh-privatekey=./private/ssh/id_rsa --from-file=ssh-publickey=./private/ssh/id_rsa.pub
    kubectl create secret generic sbt-tmnow-jfrog-credentials --from-file=tmnow.credentials=./private/sbt/tmnow.credentials
    kubectl create secret generic docker-tmnow-jfrog-credentials --from-file=docker.jfrog.credentials=./private/docker/config.json
fi
if [[ $(kubectl get configmaps --ignore-not-found) ]]; then
	kubectl delete configmaps kube-master
fi
kubectl create configmap kube-master --from-literal=master.url=$(kubectl cluster-info | grep master | grep -o 'https:\/\/[[:alnum:][:punct:]]*')
kubectl apply -f jenkins.yml
kubectl apply -f service.yml
