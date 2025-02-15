FROM debian:latest

# configure nodejs / npm repository
RUN curl -fsSL https://deb.nodesource.com/setup_23.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    rm nodesource_setup.sh

# general: curl, nodejs, npm, jq, yq, ca-certificates, wget
# google cloud sdk: apt-transport-https, gnupg
# kubernetes: kubectx, kubernetes-client
# text editors: nano, vim
# terminal niceness: zsh
RUN apt-get update && apt install -y \
    apt-transport-https \
    curl \
    gnupg \
    jq \
    kubernetes-client \
    nano \
    nodejs \
    vim \
    wget \
    yq \
    zsh && \
    rm -rf /var/lib/apt/lists/*

COPY profile/** /root/

COPY --from=hashicorp/terraform:latest /bin/terraform /bin/terraform

COPY --from=hashicorp/vault:latest /bin/vault /bin/vault

# install gcloud sdk
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-sdk google-cloud-cli-gke-gcloud-auth-plugin -y && rm -rf /var/lib/apt/lists/*

WORKDIR /root

ENTRYPOINT ["zsh"]