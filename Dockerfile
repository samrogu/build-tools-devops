FROM gcr.io/kaniko-project/executor:v1.24.0 AS kaniko
FROM maven:3.9.11-eclipse-temurin-21-alpine

# Actualizar e instalar dependencias básicas
RUN apk update && apk upgrade

# Instalar dependencias necesarias
RUN apk add --no-cache \
    bash \
    curl \
    python3 \
    py3-pip \
    git \
    ca-certificates \
    openssl \
    libc6-compat \
    tar \
    jq

# Instalar Google Cloud SDK (gcloud)
ENV CLOUD_SDK_VERSION=533.0.0

RUN curl -sSL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    | tar -xz -C /opt && \
    /opt/google-cloud-sdk/install.sh --quiet

ENV PATH="/opt/google-cloud-sdk/bin:${PATH}"

# Instalar kubectl
ENV KUBECTL_VERSION=v1.33.4

RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Instalar Helm
ENV HELM_VERSION=v3.18.6

RUN curl -sSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    | tar -xz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64

ENV TRIVY_VERSION=0.65.0
# Instalar Trivy
RUN curl -sSL https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_linux-64bit.tar.gz \
    -o trivy.tar.gz && \
    tar -xzf trivy.tar.gz && \
    mv trivy /usr/local/bin/ && \
    rm trivy.tar.gz
# Instalar plugin de autenticación para GKE
RUN gcloud components install gke-gcloud-auth-plugin
# Validar versiones
RUN gcloud --version && kubectl version --client && helm version

COPY --from=kaniko /kaniko /kaniko



ENTRYPOINT ["/bin/bash"]
