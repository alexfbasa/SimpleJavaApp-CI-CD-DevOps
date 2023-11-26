#!/bin/bash

# Function to install Docker
install_docker() {
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$(id -un)"
    sudo usermod -aG docker jenkins
    sudo systemctl start docker
    local docker_gid=$(getent group docker | cut -d: -f3)
    if [[ $? -ne 0 ]]; then
        echo "Docker install failed"
        exit 1
    else
        echo "Docker installed successfully"
    fi
    if [[ $docker_gid -eq 991 ]]; then
        echo "Docker group already has GID 991."
    else
        echo "Updating Docker group GID to 991..."
        sudo groupmod -g 991 docker
        sudo systemctl restart docker
        echo "Docker group GID updated to 991."
    fi
}
# Update the system
sudo yum -y update

# Install Nginx
sudo yum -y install epel-release
sudo yum -y install nginx

sudo yum -y install java-11-openjdk

sudo yum install -y wget
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y
cd /var/lib/jenkins/ || exit

sudo systemctl start jenkins
sudo systemctl enable jenkins

# Start and enable Nginx

sudo systemctl start nginx
sudo systemctl enable nginx

# Install Docker (if not installed)
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    install_docker
fi
# Restart Docker service to apply changes
sudo systemctl restart docker
sleep 10
sudo chown root:docker /var/run/docker.sock



# Configure Nginx as a reverse proxy for Jenkins
sudo bash -c 'cat <<EOT > /etc/nginx/conf.d/jenkins.conf
server {
    listen 80;
    server_name jenkins-io.in;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    access_log /var/log/nginx/jenkins_access.log;
    error_log /var/log/nginx/jenkins_error.log;
}
EOT'

# Reload Nginx to apply the configuration
sudo systemctl reload nginx

echo "Getting  Jenkins TOKEN"
JENKINSPWD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo $JENKINSPWD
#P@ssword2#J&N1ks
echo "Jenkins and Nginx installation completed. Access Jenkins at http://100.0.0.3:8080"

"docker run --name jenkins --rm -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD='P@ssword2#J&N1ks' --network minikube alexsimple/jenkins_jcasc:v5"
"minikube start --base-image "gcr.io/k8s-minikube/kicbase:v0.0.32""
"minikube start --base-image --memory 4096 "gcr.io/k8s-minikube/kicbase:v0.0.42""
"docker pull gcr.io/k8s-minikube/kicbase:v0.0.42" - latest image
"""$ kubectl cluster-info
   Kubernetes control plane is running at https://192.168.49.2:8443
"""