#! /bin/bash
#set -x
####
#
# NOTE: Tested on Mac's default zsh only
#
####

alias k=kubectl
alias kx=kubectx

function slp {
	echo $#
	if [[ $# -lt 1 ]]; then
		echo "slp <aws_profile> [other saml2aws args]"
		return
	fi

	export AWS_PROFILE=$1 && saml2aws login --skip-prompt --duo-mfa-option="Duo Push" --profile=$@
}

#alias sl="saml2aws login --skip-prompt --duo-mfa-option=\"Duo Push\" --force --profile=$1"

# Usage: get_kube_config maglevcloud3.tesseractinternal.com
function get_kube_config {
    if [[ $# -ne 1 ]]; then
	echo "get_kube_config maglevcloud3.tesseractinternal.com"
	return
    fi

    # Observe the arguments to cat, they are at the end of the docker command :)
    # https://docs.docker.com/engine/reference/run/#entrypoint-default-command-to-execute-at-runtime
    docker run --entrypoint 'cat' -it containers.cisco.com/maglev-cloud/cluster-access:$1 /root/.kube/config
}


function __init_KUBECONFIG {
	KUBECONFIG=""
	for f in ~/.kube/*yaml
	do
		KUBECONFIG=$KUBECONFIG:$f
	done
	export KUBECONFIG=$KUBECONFIG
}

# Initialize KUBECONFIG env var to all the yaml files
# https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
# kubectl by default merges contexts from all the files listed in KUBECONFIG env var
#
# kubectl config view
# kubectl config current-context
# kubectl config use-context context-name
unset KUBECONFIG && __init_KUBECONFIG

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/mesimhad/.sdkman"
[[ -s "/Users/mesimhad/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/mesimhad/.sdkman/bin/sdkman-init.sh"

# TODO: Add shell dependency
source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
PROMPT='$(kube_ps1)'$PROMPT

autoload -Uz compinit
compinit -i
source <(kubectl completion zsh)
complete -F __start_kubectl k
