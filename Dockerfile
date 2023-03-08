FROM ubuntu:latest

# Install Trivy
RUN apt-get update && apt-get install -y wget apt-transport-https gnupg lsb-release && \
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add - && \
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | tee -a /etc/apt/sources.list.d/trivy.list && \
    apt-get update && \
    apt-get install -y trivy

# Install Azure CLI
RUN apt-get update && \
    apt-get install -y curl apt-transport-https lsb-release gnupg
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
RUN AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-get update && \
    apt-get install -y azure-cli

# COPY the html template file to container
COPY html.tpl /usr/local/share/my-html.tpl 

#COPY the bash script file to container
COPY trivy-acr-scanner.sh /my_scripts/trivy-acr-scanner.sh
RUN chmod +x /my_scripts/trivy-acr-scanner.sh

CMD ["/bin/bash"]
