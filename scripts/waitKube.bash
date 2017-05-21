#!/bin/bash

command="$1"
type="$2"
name="$3"
kubectl="$4"

function wait-value-equals-output {
    desiredOutput=$1
    command=$2
    output=$($command)
    while [ $desiredOutput != $output ]
    do
	output=$($command)
    done
}

function wait-exists {
    type=$1
    name=$2
    kubectl=$3
    getCommand="$kubectl get $type $name"
    $getCommand &>/dev/null
    while [ $? -ne 0 ]
    do
	$getCommand &>/dev/null
    done
}

function delete {
    type="$1"
    name="$2"
    kubectl="$3"
    fullCommand="$kubectl get $type $name"
    $fullCommand &>/dev/null
    while [ $? -eq 0 ]
    do
	$fullCommand &>/dev/null
    done
    echo "$type $name successfuly deleted"
}

function create {
    type="$1"
    name="$2"
    kubectl="$3"

    phaseCommand="$kubectl get $type -o=jsonpath='{.items[?(@.metadata.name==\"$name\")].status.phase}'"
    
    case "$type" in
	"namespace")
	    wait-exists "$type" "$name" "$kubectl"
            echo "$type $name successfuly created"
	    return 0
	    ;;
	"terminatingPod")#note this will wait for the pod to finish before returning
	    wait-exists "pod" "$name" "$kubectl"
	    readyCommand="$kubectl get pod $name -o=jsonpath='{.status.phase}'"
	    desired="'Succeeded'"
	    ;;
	"pod")
	    wait-exists "$type" "$name" "$kubectl"
	    readyCommand="$phaseCommand"
	    desired="'Running'"
	    ;;
	"persistentVolumeClaim")
	    wait-exists "$type" "$name" "$kubectl"
   	    readyCommand="$phaseCommand"
	    desired="'Bound'"
	    ;;
	"statefulSet")
	    wait-exists "$type" "$name" "$kubectl"
	    readyCommand="$kubectl get statefulSet -o=jsonpath='{.items[?(@.metadata.name==\"$name\")].status.replicas}'"
	    desiredCommand="$kubectl get statefulSet -o=jsonpath='{.items[?(@.metadata.name==\"$name\")].spec.replicas}'"
	    desired=$($desiredCommand)
	    ;;
	"daemonSet")
	    wait-exists "daemonSet" "$name" "$kubectl"
	    desiredCommand="$kubectl get daemonSet -o=jsonpath='{.items[?(@.metadata.name==\"$name\")].status.desiredNumberScheduled}'"
	    desired=$($desiredCommand)
	    readyCommand="$kubectl get daemonSet -o=jsonpath='{.items[?(@.metadata.name==\"$name\")].status.numberReady}'"
	    ;;
	"deployment")
	    wait-exists "deployment" "$name" "$kubectl"
	    desiredCommand="$kubectl get deployment -o=jsonpath='{.items[?(@.metadata.name==\"$name\")].status.replicas}'"
	    desired=$($desiredCommand)
	    readyCommand="$kubectl get deployment -o=jsonpath='{.items[?(@.metadata.name==\"$name\")].status.readyReplicas}'"
	    ;;
	*)
	    echo "Resource type '$type' not recognized"
	    exit
	    ;;
    esac
    wait-value-equals-output "$desired" "$readyCommand"
    echo "$type $name successfuly created"
}

if [ -z "$command" -o -z "$type" -o -z "$name" -o -z "$kubectl" ]; then
    echo "Some parameters values are empty, please review the values and try again:"
    echo "command: '$command'"
    echo "type: '$type'"
    echo "name: '$name'"
    echo "kubectl: '$kubectl'"
    exit 2
fi

case "$command" in
    "create")
        create "$type" "$name" "$kubectl"
	;;
    "delete")
	delete  "$type" "$name" "$kubectl"
	;;
    *)
	echo "Unrecognized command: '$command'"
	exit 1
	;;
esac
