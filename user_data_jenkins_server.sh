#!/bin/bash

# Update YUM repo
yum check-update -y

# Install required applications
sudo yum -y update
sudo yum install -y git zip unzip
sudo yum install -y docker.io 
sudo add-apt-repository ppa:webupd8team/java
sudo yum -y update
sudo yum install -y java-1.8.0-openjdk.x86_64
sudo /usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
sudo /usr/sbin/alternatives --set javac /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/javac
sudo yum -y remove java-1.7
sudo yum -y install wget
sudo yum install -y zip unzip git
sudo wget https://releases.hashicorp.com/terraform/0.9.8/terraform_0.9.8_linux_amd64.zip
sudo unzip terraform_0.9.8_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo yum update -y aws-cli
sudo yum install git vim nano -y

# install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm --import http://pkg.jenkins-ci.org/redhat-stable/jenkins-ci.org.key
sudo yum -y update
sudo yum -y install jenkins 
sudo /etc/init.d/jenkins start
sudo chkconfig jenkins on
sudo service jenkins status on

 # Install the required plugins\n,
            cd /var/lib/jenkins/plugins\n,
            sudo curl -O -L https://updates.jenkins-ci.org/latest/token-macro.hpi\n,
            sudo curl -O -L https://updates.jenkins-ci.org/latest/docker-build-publish.hpi\n,
            sudo curl -O -L https://updates.jenkins-ci.org/latest/multiple-scms.hpi\n,
            sudo curl -O -L https://updates.jenkins-ci.org/latest/github-api.hpi\n,
            sudo curl -O -L https://updates.jenkins-ci.org/latest/scm-api.hpi\n,
            sudo curl -O -L https://updates.jenkins-ci.org/latest/git-client.hpi\n,
            sudo curl -O -L https://updates.jenkins-ci.org/latest/github.hpi\n,
            sudo curl -O -L https://updates.jenkins-ci.org/latest/git.hpi\n,
            sudo curl -O -L https://updates.jenkins-ci.org/latest/dockerhub.hpi\n,
            sudo chown jenkins:jenkins *.hpi\n,

	      # Wait 30 seconds to allow Jenkins to startup\n,
              echo \"Waiting 30 seconds for Jenkins to start.....\"\n,
              sleep 30\n,

            # Restarting Jenkins\n, 
            sudo /etc/init.d/jenkins restart
	echo “Jenkins Server is now ready”
	sleep 10
	echo	 “initial admin password is … ”
	sleep 5
	cat /var/lib/jenkins/secrets/initialAdminpassword
	sleep 5
	echo “The End !”



# Install NFS client required packages
echo "Installing NFS client required packages"
yum -y install nfs-utils bind-utils

# Add instance to the ECS cluster
echo "Adding instance to the ECS cluster"
echo ECS_CLUSTER='jenkins' > /etc/ecs/ecs.config


# Restart ECS and Docker
echo "Restarting ECS and Docker"
#sudo stop ecs
#sudo service docker restart
#sudo start ecs

