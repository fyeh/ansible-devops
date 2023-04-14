#!/bin/bash
function print_cluster_name  {
	oc project openshift-console > /dev/null
	clustername=$(oc get route | grep "console " | awk  '{print $2}' | awk -F. '{print $2}' | awk -F- '{print $1}')
	echo "Logged in to cluster: ${clustername}"
}

function check_prereq {
	command -v oc >/dev/null 2>&1 || { echo >&2 "Required executable \"oc\" not found on PATH.  Aborting."; exit 1; }

	oc whoami &> /dev/null
	if [[ "$?" == "1" ]]; then
	echo "You must be logged in to your OpenShift cluster to proceed (oc login)"
	exit 1
	fi
}

function check_continue {
	read -p "Continue (y/n)?" CONTINUE
	case $CONTINUE in
    		Y|y|Yes|yes|YES) 
                return 0
                ;;
    		*) 
                return 1
                ;;
	esac
}

check_prereq
print_cluster_name
check_continue
if [[ "$?" == 1 ]]; then
    exit 0
fi

if [[ -z "${W3_USERNAME_LOWERCASE}" ]]; then
    echo "W3_USERNAME_LOWERCASE variable is not set"
    exit 1
fi
if [[ -z "${ARTIFACTORY_TOKEN}" ]]; then
    echo "ARTIFACTORY_TOKEN variable is not set"
    exit 1
fi
if [[ -z "${IBM_ENTITLEMENT_KEY}" ]]; then
    echo "IBM_ENTITLEMENT_KEY variable is not set"
    exit 1
fi


ansible-galaxy collection build
ansible-galaxy collection install ibm-mas_devops-*.tar.gz --ignore-certs --force
rm ibm-mas_devops-*.tar.gz

for proj in $(oc get projects -o name | grep 'mas.*core' | awk -F/ '{print $2}');do
    export NAMESPACE=$proj
    ansible localhost -m include_role -a name=ibm.mas_devops.install_ibm_entitlement
done

for proj in $(oc get projects -o name | grep 'mas.*visualinspection' | awk -F/ '{print $2}');do
    export NAMESPACE=$proj
    ansible localhost -m include_role -a name=ibm.mas_devops.install_ibm_entitlement
done
