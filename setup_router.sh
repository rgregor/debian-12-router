#!/bin/bash

# run this script from the project root directory for the debian 12 router setup
# make sure the SSH Agent is set up to provide the remote host keys
# and the remote Debian host already has an appropriate SSH account (to be done manually 
# and omitted here to reduce exposure of info that could compromise credential security)

# also configure the bare Debian 12 installation to have ~/.ssh/authorized_keys setup, remotely

playbook=playbooks/router/router.yaml
extra_args=-vvv

if [ -f ~/.ansible_router_vars ]; then
    ansible-playbook $playbook --vault-password-file ~/.ansible_router_vars $extra_args
else
    ansible-playbook $playbook --ask-vault-pass $extra_args
fi


