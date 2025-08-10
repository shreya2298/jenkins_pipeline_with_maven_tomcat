# Jenkins & Tomcat Setup on AWS EC2 with Terraform + Jenkins Pipeline using Maven

This document combines the steps from two Medium articles:

1. **[Installing Jenkins and Tomcat on EC2 using Terraform](https://medium.com/@smfegade2298/installing-jenkins-and-tomcat-on-ec2-using-terraform-d573713cd47d)**
2. **[Create Jenkins Pipeline using Maven and Tomcat](https://medium.com/@smfegade2298/create-jenkins-pipeline-using-maven-and-tomcat-6fca362b9c24)**

---

## Part 1: Installing Jenkins and Tomcat on EC2 using Terraform

### Overview
This section covers provisioning an AWS EC2 instance with:
- **Jenkins** (on port `8082`)
- **Apache Tomcat** (on port `8080`)
- **Java OpenJDK 17**
- Configured Security Groups and networking via Terraform

### Terraform Files
File structure:
```
provider.tf       # AWS provider and region
variables.tf      # Variable definitions
vpc.tf            # VPC creation
routes.tf         # Route tables and internet gateway
sg.tf             # Security groups
ec2.tf            # EC2 instance definition with user_data for installation
outputs.tf        # Output public IP and other details
```

### Key Setup Steps
1. Install Terraform on your local machine.
2. Create a Terraform project folder and add the `.tf` files.
3. Define security groups to allow:
   - **22 (SSH)** – For remote login
   - **80 (HTTP)** – If needed for web apps
   - **8082** – Jenkins
   - **8080** – Tomcat
4. Use `user_data` in EC2 configuration to:
   - Install Java, Jenkins, and Tomcat
   - Configure Tomcat Manager for remote access
5. Deploy with:
```bash
terraform init
terraform apply
```

6. Access:
   - Jenkins → `http://<EC2_PUBLIC_IP>:8082`
   - Tomcat → `http://<EC2_PUBLIC_IP>:8080`

7. Get Jenkins initial admin password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Security Note
- **For production**, avoid opening all ports to `0.0.0.0/0`.
- Implement authentication for Tomcat.
- Use HTTPS for Jenkins and Tomcat.

---

## Part 2: Creating Jenkins Pipeline using Maven and Tomcat

### Overview
This section automates deployment of a Maven project to Tomcat using Jenkins.

### Steps
1. Install Jenkins plugins:
   - **Maven Integration**
   - **Git**
2. Configure tools in Jenkins:
   - **JDK** (e.g., `jdk17`)
   - **Maven** (e.g., `Maven3`)
3. Create a Jenkins pipeline project.

### Pipeline Script Example
```groovy
pipeline {
    agent any
    tools {
        maven 'Maven3'   // Configured name in Jenkins
        jdk 'jdk17'      // Configured name in Jenkins
    }
    environment {
        DEPLOY_PATH = "/opt/apache-tomcat-9.0.65/webapps"
        WAR_NAME = "petclinic.war"
    }
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/smita1988/new-project.git'
            }
        }
        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('WAR Deploy') {
            steps {
                sh 'cp target/*.war $DEPLOY_PATH/$WAR_NAME'
            }
        }
    }
}
```

### Manual Deployment Steps (if not using pipeline)
```bash
cp target/*.war /opt/apache-tomcat-9.0.65/webapps/
cd /opt/apache-tomcat-9.0.65/bin
./shutdown.sh
./startup.sh
```

### Access the Application
```
http://<EC2_PUBLIC_IP>:8080/petclinic
```

---

## Summary
- **Terraform** automates provisioning of Jenkins & Tomcat on AWS EC2.
- **Jenkins pipeline** automates building and deploying a Maven-based application to Tomcat.
- Both combined form a CI/CD workflow for Java web applications.

---
