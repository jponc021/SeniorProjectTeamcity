#! /bin/bash

if [ -z "$namespace" ]; then
    echo "Please set the namespace environment variable before calling this script."
    exit 1
fi
if [ -z "${vip_web_version}" ]; then
    echo "Please set the vip_web_version environment variable before calling this script."
    exit 2
fi

function deleteTcpLoadBalancing {
    portsInUse="$(${kubectl} get configMap nginx-tcp-ingress-configmap -o=jsonpath='{.data}')"
    portsInUse=$(echo "$portsInUse" | sed "s/map\[//" | sed "s/\]//" | tr " " "\n")

    currentPort=""
    currentNamespace=""
    for port in ${portsInUse}; do
        portNamespacePair=$(echo "$port" | sed "s/\/.*//")
        currentPort=$(echo "$portNamespacePair" | sed "s/:.*//")
        currentNamespace=$(echo "$portNamespacePair" | sed "s/.*://")
        if [ "$currentNamespace" = "$namespace" ]; then
            ${kubectl} patch configMap nginx-tcp-ingress-configmap --type=json -p "[{\"op\":\"remove\",\"path\":\"/data/$currentPort\"}]"
        fi
    done
}

function configureTcpLoadBalancing {
    deleteTcpLoadBalancing
    portsInUse="$(${kubectl} get configMap nginx-tcp-ingress-configmap -o=jsonpath='{.data}')"
    portsInUse=$(echo "$portsInUse" | sed "s/map\[//" | sed "s/\]//" | tr " " "\n")

    mongoPort=65534
    found="true"
    while [ "${found}" = "true" ]; do
        found="false"
        currentPort=""
        for port in ${portsInUse}; do
            portNamespacePair=$(echo "$port" | sed "s/\/.*//")
            currentPort=$(echo "$portNamespacePair" | sed "s/:.*//")
            if [ ${mongoPort} -eq $((currentPort + 0)) ]; then
                found="true"
            fi
        done
        mongoPort=$((mongoPort - 1))
    done
    ${kubectl} patch configMap nginx-tcp-ingress-configmap --type=json -p "[{\"op\":\"add\",\"path\":\"/data/${mongoPort}\",\"value\":\"${namespace}/mongo:27017\"}]"
}
#--kubeconfig /home/josep/kubernetes/conf/admin.conf
kubectl="kubectl -n ingress-controller"
echo "Configuring tcp load balancing for mongo"
configureTcpLoadBalancing
echo

kubectl="kubectl -n $namespace"
kubewait="./waitKube.bash"

echo "Deleting resources if they exist"
${kubectl} delete persistentVolumeClaim vip-mongo
${kubectl} delete deployment vip-mongo
${kubectl} delete service vip-mongo
${kubectl} delete deployment vip-web
${kubectl} delete service vip-web
${kubectl} delete ingress vip-ingress
echo "Waiting for existing resources to be deleted"
${kubewait} delete persistentVolumeClaim vip-mongo "$kubectl"
${kubewait} delete deployment vip-mongo "$kubectl"
${kubewait} delete deployment vip-web "$kubectl"
echo

echo "Creating persistentVolumeClaim vip-mongo"
${kubectl} create -f ../deployTemplates/vip-mongo-pvc.yaml
echo "Waiting for persistentVolumeClaim vip-mongo to be created"
${kubewait} create persistentVolumeClaim vip-mongo "$kubectl"
echo

echo "Creating deployment vip-mongo"
${kubectl} create -f ../deployTemplates/vip-mongo-deployment.yaml
echo "Waiting for deployment vip-mongo to be created"
${kubewait} create deployment vip-mongo "$kubectl"
echo

echo "Creating service vip-mongo"
${kubectl} create -f ../deployTemplates/vip-mongo-service.yaml
echo

cat ../deployTemplates/vip-web-deployment.yaml | sed "s/{{vip_web_version}}/$vip_web_version/" > ./vip-web-deployment.yaml
echo "Creating deployment vip-web"
${kubectl} create -f ./vip-web-deployment.yaml
echo "Waiting for deployment vip-web to be created"
${kubewait} create deployment vip-web "$kubectl"
echo

echo "Creating service vip-web"
${kubectl} create -f ../deployTemplates/vip-web-service.yaml

cat ../deployTemplates/vip-ingress.yaml | sed "s/{{namespace}}/$namespace/" > ./vip-ingress.yaml
echo "Creating vip-ingress ingress"
${kubectl} create -f ./vip-ingress.yaml