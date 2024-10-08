#!/bin/bash

# Variables
TERRAFORM_DIR="/mnt/c/Users/Ravik/Desktop/DevOps/TM_tera_ansible/provisioning"          # Update this path to your Terraform directory
LOCAL_FILE="/home/ravikishans/raviAWS.pem"            # Update this path to the local file to copy
REMOTE_DEST="/home/ubuntu"                # Destination on the remote instance
ANSIBLE_HOSTS_FILE="/mnt/c/Users/Ravik/Desktop/DevOps/TM_tera_ansible/configmgmt/hosts.ini"     # Update this path to your hosts.ini file
# ANSIBLE_PLAYBOOK="/mnt/c/Users/Ravik/Desktop/DevOps/TM_tera_ansible/configmgmt/deploy_nginx.yml"      # Update this path to your Ansible playbook
PEM_FILE="/home/ravikishans/raviAWS.pem"                   # Update this to your PEM file path


# Step 1: Run Terraform provisioning
cd $TERRAFORM_DIR
terraform init
terraform apply -auto-approve
terraform output
# Step 2: Get instance details (adjust depending on your output variables)
# Assuming Terraform outputs the public and private IPs
FRONTEND_PUBLIC_IP=$(terraform output instance_public_ip_fe)
BACKEND_PRIVATE_IP=$(terraform output instance_private_ip_be)
DATABASE_PRIVATE_IP=$(terraform output instance_private_ip_database)

# Step 3: SSH into the frontend instance and copy the local file
# echo "Copying file to frontend instance..."
# scp -i $PEM_FILE $LOCAL_FILE ubuntu@$FRONTEND_PUBLIC_IP:$REMOTE_DEST

# Step 4: Update hosts.ini file
echo "Updating hosts.ini file..."
cat <<EOL > $ANSIBLE_HOSTS_FILE
[frontend]
rtm-frontend ansible_host=$FRONTEND_PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=$PEM_FILE

[backend]
rtm-backend ansible_host=$BACKEND_PRIVATE_IP ansible_user=ubuntu ansible_ssh_private_key_file=$PEM_FILE ansible_ssh_common_args='-o ProxyCommand="ssh -i $PEM_FILE -W %h:%p ubuntu@$FRONTEND_PUBLIC_IP"' ansible_python_interpreter=/usr/bin/python3

[database]
rtm-database ansible_host=$DATABASE_PRIVATE_IP ansible_user=ubuntu ansible_ssh_private_key_file=$PEM_FILE ansible_ssh_common_args='-o ProxyCommand="ssh -i $PEM_FILE -W %h:%p ubuntu@$FRONTEND_PUBLIC_IP"' ansible_python_interpreter=/usr/bin/python3

EOL


ansible all -m ping -i $ANSIBLE_HOSTS_FILE
# # Step 5: Run Ansible playbook to configure instances
# echo "Running Ansible playbook..."
# ansible-playbook -i $ANSIBLE_HOSTS_FILE $ANSIBLE_PLAYBOOK

# # Done
echo "Provisioning completed."
