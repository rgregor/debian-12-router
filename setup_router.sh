#!/bin/bash

# run this script from the project root directory for the debian 12 router setup
# make sure the SSH Agent is set up to provide the remote host keys
# and the remote Debian host already has an appropriate SSH account (to be done manually
# and omitted here to reduce exposure of info that could compromise credential security)

[[ -f "$ANSIBLE_VAULT_PASSWORD_FILE" ]] || { echo "please configure your .env file correctly, refer to dotenv.template" ; exit 1; }

playbook=playbooks/forbidden-router/forbidden-router.yaml
extra_args=-vv

ansible-playbook $playbook $extra_args
