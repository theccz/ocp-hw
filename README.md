This repository deploys a 3-master HA Openshift Container Platform Cluster using a combination of Ansible and shell scripting. Curent version is 3.11.43.

Login to the bastion host of the homework environment

# ssh -i <path/to/key> <login_id>@bastion.$GUID.example.opentlc.com

Login as root user

# sudo -i

Clone Repo

# git clone https://github.com/theccz/ocp-hw

# cd ocp-hw

Start the install

# ansible-playbook -f 20 homework.yaml

Please refer to the engagement journal for more info.