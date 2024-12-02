>  English | [中文](README_zh.md)
>
# UPM Community Edition Quick Installation Guide

This guide will lead you through the quick installation and configuration of the UPM (Unified Platform Manager) community edition. Please ensure that you have a basic understanding of Kubernetes and Docker.

Before starting the installation, please ensure that the following preparation requirements are met. These preparations include hardware requirements and version descriptions to ensure the system can run smoothly.

## Environment Readiness

1. **Hardware Requirements**
   - Minimum:
     - CPU: At least 8 cores
     - Memory: At least 16 GB
     - Disk Space: At least 50 GB available space
     - Network: Stable internet connection
   - Recommended:
     - CPU: At least 12 cores
     - Memory: At least 24 GB
     - Disk Space: At least 100 GB available space
     - Network: Stable internet connection
2. **Operating System Versions**
   - Linux: RHEL9, Rocky Linux9
   - Windows: Windows 11 Pro or higher
   - MacOS: Mojave 14.0.1 or higher

## Minikube Startup

Minikube is used to create a local Kubernetes cluster. Please choose the appropriate driver and installation method based on your operating system.

### Linux

1. **Install minikube driver (docker)**

   - It is recommended to use docker as the minikube driver. The following is an example of installing docker on a Linux system

     ```
     sudo dnf -y install dnf-plugins-core
     sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
     sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
     sudo usermod -aG docker $USER && newgrp docker
     sudo systemctl restart docker
     ```

2. **Install minikube**

   ```
   sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
   ```

3. **Start the minikube cluster** **Note: Run with a non-root user.**

   ```
   export KUBE_VERSION="v1.30.6"
   export LIMIT_CPUS="8"
   export LIMIT_MEMORY="16G"
   
   minikube start -p "minikube" --driver=docker \
     --nodes=2 \
     --kubernetes-version="${KUBE_VERSION}" \
     --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}"
   ```

### MacOS for Apple Silicon

1. **Install minikube driver (docker)**

   - It is recommended to use Docker Desktop as the minikube driver.
   - Install Docker Desktop: [Docker Desktop Download] (Please replace with the official Podman Desktop download link)
   - After installation, adjust the CPU and memory limits in Docker Desktop settings according to your system resources (e.g., 12C24G).

2. **Install minikube**

   ```
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
   sudo install minikube-darwin-arm64 /usr/local/bin/minikube
   ```

3. **Start Docker**

4. **Start the minikube cluster**

   ```
   export KUBE_VERSION="v1.30.6"
   export LIMIT_CPUS="8"
   export LIMIT_MEMORY="16G"
   
   minikube start -p "minikube" --driver=podman \
     --nodes=2 \
     --container-runtime=cri-o --kubernetes-version="${KUBE_VERSION}" \
     --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}"
   ```

### Windows (x86)

1. **Install minikube driver (Hyper-V)**

   - It is recommended to use Hyper-V as the minikube driver. The following is an example of enabling Hyper-V on a Windows system:

     ```
     Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
     ```

     The system may need to be restarted.

2. **Install minikube**

   - On x86-64 Windows systems, it is recommended to install the latest stable version of Minikube using the .exe installer:

     - Download and run the latest version of the installer: [Minikube Latest Version Download] (Please replace with the official Minikube download link)

     - Or, use PowerShell:

       ```powershell
       New-Item -Path 'c:\' -Name 'minikube' -ItemType Directory -Force
       Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing
       ```

     - Add

       ```
       minikube.exe
       ```

        

       to your system PATH environment variable. Make sure to run PowerShell as an administrator.

       powershell

       ```
       $oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
       if ($oldPath.Split(';') -inotcontains 'C:\minikube'){
         [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine)
       }
       ```

     - After installation, close and reopen the terminal to make the changes take effect.

3. **Start the minikube cluster**

   ```
   export KUBE_VERSION="v1.30.6"
   export LIMIT_CPUS="8"
   export LIMIT_MEMORY="16G"
   
   minikube start -p "minikube" --driver=hyperv \
     --nodes=2 \
     --kubernetes-version="${KUBE_VERSION}" \
     --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}"
   ```

## Install UPM

1. **Install UPM Platform**

   - Run the installation script:

     ```
     sh -x quickstart/platform/install.sh
     ```

   - Wait until the following message is returned:

     ```
     [Info][2024-11-04T11:23:47+0800]: All pods are ready or succeeded
     NAME                                            READY   STATUS      RESTARTS     AGE     IP            NODE       NOMINATED NODE   READINESS GATES
     upm-platform-auth-6bd94cb567-jm9bd               1/1     Running     0            2m18s   10.244.0.51   minikube   <none>           <none>
     upm-platform-elasticsearch-ms-7ff7654dfb-hzmdt   1/1     Running     0            2m18s   10.244.0.50   minikube   <none>           <none>
     upm-platform-gateway-759d64d8cf-b6rhl            1/1     Running     0            2m18s   10.244.0.55   minikube   <none>           <none>
     upm-platform-kafka-ms-7796666475-gtdkp           1/1     Running     0            2m18s   10.244.0.62   minikube   <none>           <none>
     upm-platform-mysql-0                             1/1     Running     0            2m18s   10.244.0.63   minikube   <none>           <none>
     upm-platform-mysql-ms-56b9bddd99-6zcjc           1/1     Running     0            2m18s   10.244.0.47   minikube   <none>           <none>
     upm-platform-nacos-0                             1/1     Running     2 (2m ago)   2m18s   10.244.0.64   minikube   <none>           <none>
     upm-platform-nacos-init-db-kqk4q                 0/1     Completed   0            2m18s   10.244.0.56   minikube   <none>           <none>
     upm-platform-nginx-6597db9db8-2nbw9              1/1     Running     0            2m18s   10.244.0.52   minikube   <none>           <none>
     upm-platform-operatelog-585d7b644c-928jd         1/1     Running     0            2m18s   10.244.0.53   minikube   <none>           <none>
     upm-platform-postgresql-ms-79678fff-ftxbz        1/1     Running     0            2m18s   10.244.0.48   minikube   <none>           <none>
     upm-platform-redis-cluster-ms-68f4fc9f49-94j4r   1/1     Running     0            2m18s   10.244.0.57   minikube   <none>           <none>
     upm-platform-redis-master-0                      1/1     Running     0            2m18s   10.244.0.58   minikube   <none>           <none>
     upm-platform-redis-ms-69c45859b4-rs9c4           1/1     Running     0            2m18s   10.244.0.59   minikube   <none>           <none>
     upm-platform-resource-68c6d8c797-b2nq5           1/1     Running     0            2m18s   10.244.0.49   minikube   <none>           <none>
     upm-platform-ui-5665978468-48nx5                 1/1     Running     0            2m18s   10.244.0.60   minikube   <none>           <none>
     upm-platform-user-6b6b5d6446-dt4mj               1/1     Running     0            2m18s   10.244.0.61   minikube   <none>           <none>
     upm-platform-zookeeper-ms-79d4dd99f-ftzw6        1/1     Running     0            2m18s   10.244.0.54   minikube   <none>           <none>
     [Info][2024-11-04T11:23:47+0800]: upm-platform ready, elapsed time: 40 seconds
     job.batch "upm-platform-install" deleted
     ```

     You should see multiple UPM platform-related pods in the Running state.

2. **Install UPM Engine**

   - Run the installation script:

     ```
     sh -x quickstart/engine/install.sh
     ```

   - Verify the successful deployment of UPM engine:

     ```
     kubectl get pod -n upm-system | grep upm-engine
     ```

     You should see UPM engine-related pods in the Running state.

3. **Install cert-manager**

   - Run the installation script:

     ```
     sh -x quickstart/engine/install-cert-manager.sh
     ```

   - Check if the cert-manager pods are running normally:

     ```
     kubectl get pod -n cert-manager
     ```

4. **Accessing the UPM User Interface**

   - Use the `kubectl port-forward` command to map the 80 port of the `upm-platform-nginx` service to localhost:

     ```
     kubectl port-forward --address 0.0.0.0 -n upm-system services/upm-platform-nginx 80:80 &
     ```

   - Then, access the UPM user interface in your browser: `http://127.0.0.1/upm-ui/#/login`

   - Default username: `super_root`

   - Default password: `Upm@2024!`

**Important Note:** Please configure proxy settings (HTTP_PROXY, HTTPS_PROXY, NO_PROXY) according to your actual network environment. Ensure all links point to the latest official documentation and download addresses. This guide is for reference only, and specific operations may vary depending on the environment.



## Initializing the UPM Platform

- **Add Project**
  - Resource Management > Project Management > Add
  - Name: Project name, a logical concept, custom name
  - Namespace: The namespace where application instances are created
- **Add Cluster**
  - Cluster Management > Register
  - Name: Cluster name, a logical concept, custom name
  - Cluster Type: Choose Kubernetes
  - Supported Service Types: Choose NodePort
  - Default Service Type: Choose NodePort
  - Keepalive Address: Use the node address in minikube
  - Authentication Method: Choose kubeconfig
  - Configuration File Content: Fill in the kubeconfig file of the cluster created by minikube
- **Add Region**
  - Region Management > Add
  - Cluster: Select the previously created cluster
  - Name: Region name, a logical concept, custom name
- **Add Host Group**
  - Host Group Management > Add
  - Cluster: Select the previously created cluster
  - Region: Select the previously created region
  - Name: Host group name, a logical concept, custom name
- **Add Host**
  - Host Management > Register
  - Select the node and click Next
  - Region: Select the previously created region
  - Host Group: Select the previously created host group
  - Tags: Select all types of instances allowed to be created on this host
  - Click "Register Now" to view the host in the host list
- **Add Storage Class**
  - Storage Class Management > Register
  - Select "standard" and click Next
  - Name: Custom storage name
  - Click "Register" to view the storage class in the storage class list
- **Instance Scale Management**
  - Example: MySQL
  - MySQL > Scale Management > Add
  - Type: Choose MySQL
  - Name: Scale name, custom
  - Minimum Running Limit: Kubernetes resource concept
  - Maximum Usage Limit: Kubernetes resource concept
  - Click "Save" to view the scale in the scale list
- **Create Instance**
  - Example: MySQL
  - MySQL > Work Order Management > Add > Apply Now > Confirm
  - In the work order list, click
  - Approval > Agree > Confirm > Execute > Confirm > Go To
  - Wait for the MySQL instance creation to complete
