>  English | [中文](README_zh.md)

### Quick Installation Guide for UPM Community Edition

This guide will walk you through the quick installation and configuration of the UPM Community Edition. Please ensure that you have basic knowledge of Kubernetes and Docker.

Before starting the installation, please ensure that the following prerequisites are met. These prerequisites include hardware requirements and version descriptions to ensure smooth system operation.

#### Environment Readiness

1. **Hardware Requirements** Prepare at least the following configurations to meet the overall installation needs of Kubernetes and UPM.
   - Minimum Requirements
     - CPU: At least 8 cores
     - Memory: At least 16 GB
     - Disk Space: At least 50 GB available space
     - Network: Stable internet connection with access to international networks
   - Recommended Requirements
     - CPU: At least 12 cores
     - Memory: At least 24 GB
     - Disk Space: At least 100 GB available space
     - Network: Stable internet connection with access to international networks
2. **Operating System Versions**
   - Linux:
     - RHEL9, Rocky Linux9
   - Windows:
     - Windows 11 Pro or higher
   - MacOS:
     - Mojave 14.0.1 or higher

#### Minikube Startup

Minikube is used to create a local Kubernetes cluster. Please choose the appropriate driver and installation method based on your operating system.

**Linux (x86)**

1. Install Minikube Driver (Docker)

   - It is recommended to use Docker as the Minikube driver. The following is an example of installing Docker on a Linux system:

     ```
     sudo dnf -y install dnf-plugins-core
     sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
     sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
     sudo usermod -aG docker $USER && newgrp docker
     sudo systemctl restart docker
     ```

2. Install Minikube

   ```
   sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
   ```

3. Start Minikube Cluster

   - Note: Start the cluster using a non-root user.

     ```
     export KUBE_VERSION="v1.30.6"
     export LIMIT_CPUS="8"
     export LIMIT_MEMORY="16G"
     
     minikube start -p "minikube" --driver=docker \
       --nodes=2 \
       --kubernetes-version="${KUBE_VERSION}" \
       --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}"
     ```

**MacOS for Apple Silicon**

1. Install Minikube Driver (Docker)

   - It is recommended to use Docker Desktop as the Minikube driver.
   - Install Docker Desktop: [Docker Desktop Download] (Please replace with the official Docker Desktop download link)
   - After installation, adjust the CPU and memory limits in Docker Desktop settings according to your system resources (e.g., 12C24G).

2. Install Minikube

   ```
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
   sudo install minikube-darwin-arm64 /usr/local/bin/minikube
   ```

3. **Launch Docker**

4. Start Minikube Cluster

   ```
   export KUBE_VERSION="v1.30.6"
   export LIMIT_CPUS="8"
   export LIMIT_MEMORY="16G"
   
   minikube start -p "minikube" --driver=docker \
     --nodes=2 \
     --kubernetes-version="${KUBE_VERSION}" \
     --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}"
   ```

**Windows (x86)**

1. Install Minikube Driver (Hyper-V)

   - It is recommended to use Hyper-V as the Minikube driver. The following is an example of enabling Hyper-V on a Windows system:

     - Run PowerShell as Administrator and execute the following command:

       ```
       Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
       ```

     - The system may need to restart.

2. Install Minikube

   - On x86-64 Windows systems, it is recommended to install the latest stable version of Minikube using the .exe installer:

     - Download and run the latest version installer: [Minikube Latest Version Download] (Please replace with the official Minikube download link)

     - Alternatively, use PowerShell:

       ```
       New-Item -Path 'c:\' -Name 'minikube' -ItemType Directory -Force
       Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing
       Add minikube.exe to your system PATH environment variable. Please run PowerShell as Administrator.
       $oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
       if ($oldPath.Split(';') -inotcontains 'C:\minikube'){
         [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine)
       }
       ```

     - After installation, close and reopen the terminal to apply the changes.

3. Start Minikube Cluster

   ```
   export KUBE_VERSION="v1.30.6"
   export LIMIT_CPUS="8"
   export LIMIT_MEMORY="16G"
   
   minikube start -p "minikube" --driver=hyperv \
     --nodes=2 \
     --kubernetes-version="${KUBE_VERSION}" \
     --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}"
   ```

#### Install UPM

1. **Install UPM Platform**

   - Run the installation script:

     ```
     curl -sSL https://raw.githubusercontent.com/upmio/upm-quickstart/refs/heads/main/platform/install.sh | sh -
     ```

   - After installation, verify the deployment of upm-engine using the following command:

     ```
     kubectl get pod -n upm-system | grep upm-platform
     ```

   - You should see multiple upm-platform-related Pods in the Running state.

2. **Install UPM Engine**

   - Run the installation script:

     ```
     curl -sSL https://raw.githubusercontent.com/upmio/upm-quickstart/refs/heads/main/engine/install.sh | sh -
     ```

   - After installation, verify the deployment of upm-engine using the following command:

     ```
     kubectl get pod -n upm-system | grep upm-engine
     ```

   - You should see upm-engine-related Pods in the Running state.

3. **Install cert-manager**

   - Run the installation script:

     ```
     curl -sSL https://raw.githubusercontent.com/upmio/upm-quickstart/refs/heads/main/engine/install.sh | sh -
     ```

   - Check if the cert-manager Pods are running normally:

     ```
     kubectl get pod -n cert-manager
     ```

#### Access UPM User Interface

- Use the

  ```
  kubectl port-forward
  ```

  command to map port 80 of the upm-platform-nginx service to your local machine:

  ```
  kubectl port-forward --address 0.0.0.0 -n upm-system services/upm-platform-nginx 80:80 &
  ```

- Open a browser and navigate to: `http://127.0.0.1/upm-ui/#/login`

- Default username: `super_root`

- Default password: `Upm@2024!`

#### Important Notes

- Configure proxy settings (HTTP_PROXY, HTTPS_PROXY, NO_PROXY) according to your actual network environment.
- Ensure all links point to the latest official documentation and download addresses.
- This guide is for reference only; specific operations may vary depending on your environment.
