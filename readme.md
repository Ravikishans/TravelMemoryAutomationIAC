---

# TravelMemory Project Deployment

This project sets up a MERN stack application on AWS using **Terraform** for infrastructure provisioning and **Ansible** for configuration management and application deployment. It includes setting up a VPC, EC2 instances for the web server and database, configuring the servers using Ansible, and deploying the application.

## **Table of Contents**
1. [Project Structure](#project-structure)
2. [Infrastructure Setup with Terraform](#infrastructure-setup-with-terraform)
3. [Configuration and Deployment with Ansible](#configuration-and-deployment-with-ansible)
4. [Final Deployment Validation](#final-deployment-validation)

---

## **Project Structure**

Here's the directory structure of the project:

```bash
travel-memory-project/
├── configmgmt/
│   ├── hosts.ini
│   ├── web_setup.yml
│   ├── db_setup.yml
│   ├── ansible.cfg
│   └── roles/
│       ├── web/
│       │   ├── tasks/
│       │   │   └── main.yml
│       │   ├── handlers/
│       │   │   └── main.yml
│       │   └── files/
│       └── db/
│           ├── tasks/
│           │   └── main.yml
│           ├── handlers/
│           │   └── main.yml
│           └── files/
├── provisioning/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── readme.md
├── screenshots/
├── run.sh

```

---

## **Infrastructure Setup with Terraform**

### **Step 1: Initialize Terraform Project**
Navigate to the `terraform/` directory and initialize the Terraform project:

```bash
cd provisioning/
terraform init
```

### **Step 2: Validate Terraform Configuration**
Validate the syntax of your Terraform files:

```bash
terraform validate
```

### **Step 3: Plan Infrastructure Changes**
Preview the resources Terraform will create without making any changes:

```bash
terraform plan
```

### **Step 4: Apply Infrastructure Changes**
Apply the Terraform plan to create the infrastructure:

```bash
terraform apply -auto-approve
```

### **Step 5: Output Web Server's Public IP**
After the Terraform deployment, display the public IP of the web server:

```bash
terraform output web_server_public_ip
```

### **Step 6: Destroy Infrastructure (Optional)**
If you need to tear down your infrastructure, run:

```bash
terraform destroy -auto-approve
```

---

## **Configuration and Deployment with Ansible**

Before running Ansible playbooks, ensure that you've updated the `hosts.ini` file in the `ansible/` directory with the public IP of the web server and the private IP of the database server.

### **Step 1: Install Ansible**
If you haven't installed Ansible, install it using the following command (for Ubuntu/Debian):

```bash
sudo apt update
sudo apt install ansible -y
```

### **Step 2: Test Ansible Connectivity**
Test whether Ansible can connect to the EC2 instances using the `ping` module:

```bash
ansible -i configmgmt/hosts.ini frontend -m ping
ansible -i configmgmt/hosts.ini backend -m ping
ansible -i configmgmt/hosts.ini database -m ping
```

### **Step 3: Run Web Server Setup Playbook**
This playbook installs Node.js and NPM, clones the MERN application, and installs the dependencies:

```bash
ansible-playbook -i configmgmt/hosts.ini configmgmt/web_setup.yml
```

### **Step 4: Run Database Server Setup Playbook**
This playbook installs MongoDB on the database server and sets up the required database user:

```bash
ansible-playbook -i configmgmt/hosts.ini configmgmt/db_setup.yml
```

### **Step 5: Start the Node.js Application**
The Node.js application will be started using the `pm2` process manager. Ensure the following command is part of your `web_setup.yml` playbook. If not, add it and rerun the playbook:

```bash
pm2 start index.js
```

### **Step 6: Harden Security**
Run the following command to apply additional security measures (if added to the playbook):

```bash
ansible-playbook -i configmgmt/hosts.ini configmgmt/web_setup.yml
```

---

## **Final Deployment Validation**

After completing the infrastructure setup and application deployment, follow these steps to validate the deployment:

### **Step 1: Access the Frontend**
Open your browser and navigate to the public IP of the web server. This will open the React frontend of your MERN application:

```
http://<web_server_public_ip>
```

### **Step 2: Verify Frontend-Backend Communication**
Ensure that the frontend communicates correctly with the backend, which is running on the same server or on a different instance in the private subnet.

### **Step 3: Check MongoDB Connectivity**
Make sure the backend can connect to the MongoDB instance running on the private database server.

---

## **Commands for Debugging and Monitoring**

### **SSH into the EC2 Instances**

**SSH into the Web Server (Public Subnet):**
```bash
ssh -i /path/to/your/private/key.pem ec2-user@<web_server_public_ip>
```

**SSH into the Database Server (Private Subnet) (via the Web Server):**
```bash
ssh -i /path/to/your/private/key.pem -J ec2-user@<web_server_public_ip> ec2-user@<db_server_private_ip>
```

### **Check the Status of Services**

**Check MongoDB on the Database Server:**
```bash
sudo systemctl status mongodb
```

**Check Node.js Application (if using PM2) on the Web Server:**
```bash
pm2 status
```

### **View PM2 Logs**

If you want to view the logs for the Node.js application managed by `pm2`, use the following command:

```bash
pm2 logs
```

---

## **Conclusion**

By following the steps in this `README.md`, you should be able to successfully set up, configure, and deploy a MERN application on AWS using Terraform for infrastructure and Ansible for configuration management. If you encounter any issues, use the debugging commands provided to troubleshoot and monitor your deployment.

---
