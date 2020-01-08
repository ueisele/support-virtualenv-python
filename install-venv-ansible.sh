#!/usr/bin/env bash
set -e

VENV_HOME=~/Apps/lang/python/venv
mkdir -p ${VENV_HOME}
VENVWRAPPER_HOME=~/Apps/lang/python/venvwrapper
mkdir -p ${VENVWRAPPER_HOME}

ANSIBLE_VERSION=2.3.0.0

function create_penv_script() {
    cat > ${VENV_HOME}/penv << EOL
#!/usr/bin/env bash
set -e

function run_in_env() {
	local envpath=\${1:?'Missing python virtualenv path first parameter'}
	shift
	(source ${VENV_HOME}/\${envpath}/bin/activate && "\$@")
}
run_in_env "\$@"
EOL
    chmod +x ${VENV_HOME}/penv
}

function create_command_wrapper_script() {
    local command=${1:?"Specify command as first parameter"}
    mkdir -p ${VENVWRAPPER_HOME}/ansible-v${ANSIBLE_VERSION}
    cat > ${VENVWRAPPER_HOME}/ansible-v${ANSIBLE_VERSION}/${command} << EOL
#!/usr/bin/env bash
set -e
function command() {
	${VENV_HOME}/penv ansible-v${ANSIBLE_VERSION} ${command} "\$@"
}
command "\$@"
EOL
    chmod +x ${VENVWRAPPER_HOME}/ansible-v${ANSIBLE_VERSION}/${command}
}

virtualenv2 ${VENV_HOME}/ansible-v${ANSIBLE_VERSION}

create_penv_script
create_command_wrapper_script pip

${VENVWRAPPER_HOME}/ansible-v${ANSIBLE_VERSION}/pip install yolk3k
${VENVWRAPPER_HOME}/ansible-v${ANSIBLE_VERSION}/pip install boto
${VENVWRAPPER_HOME}/ansible-v${ANSIBLE_VERSION}/pip install six
${VENVWRAPPER_HOME}/ansible-v${ANSIBLE_VERSION}/pip install PyYAML
${VENVWRAPPER_HOME}/ansible-v${ANSIBLE_VERSION}/pip install pycrypto
${VENVWRAPPER_HOME}/ansible-v${ANSIBLE_VERSION}/pip install Jinja2
${VENVWRAPPER_HOME}/ansible-v${ANSIBLE_VERSION}/pip install ansible==${ANSIBLE_VERSION}

create_command_wrapper_script ansible
create_command_wrapper_script ansible-playbook
