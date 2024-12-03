> [English](README.md) | 中文

# UPM 社区版快速安装指南

本指南将引导您快速安装和配置UPM社区版。  请确保您已具备基本的 Kubernetes 和 Docker 知识。

在开始安装前，请确保满足以下准备工作要求。这些准备工作包括硬件要求和版本描述，以确保系统能够顺利运行。

## 环境就绪

### 1. 硬件要求

至少准备以下配置以满足kubernetes与upm整体安装需求。

**最低要求**

- **CPU**：至少 8 核心
- **内存**：至少 16 GB
- **磁盘空间**：至少 50 GB 可用空间
- **网络**：稳定可访问国际互联网连接

**推荐要求**

- **CPU**：至少 12 核心
- **内存**：至少 24 GB
- **磁盘空间**：至少 100 GB 可用空间
- **网络**：稳定可访问国际互联网连接

### 2. 操作系统版本

**Linux:**

- RHEL9, Rocky Linux9

**Windows:**

- Windows 11 专业版 或更高版本

**MacOS:**

- Mojave 14.0.1 或更高版本

## Minikube 启动

Minikube 用于在本地创建 Kubernetes 集群。 请根据您的操作系统选择相应的驱动程序和安装方法。

### Linux **(x86)**

#### 1. 安装 minikube driver（docker）

推荐使用 docker 作为 minikube driver。 以下是在 Linux 系统上安装 docker 的示例：

```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER && newgrp docker
sudo systemctl restart docker 
```

##### 2. 安装 minikube

```bash
sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```

##### 3. 启动 minikube 集群

**注意启动时候使用非root用户运行

```bash
export KUBE_VERSION="v1.30.6"
export LIMIT_CPUS="8"
export LIMIT_MEMORY="16G"

minikube start -p "minikube" --driver=docker \
  --nodes=2 \
  --kubernetes-version="${KUBE_VERSION}" \
  --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}"
```



### MacOS for Apple Silicon

#### 1. 安装 minikube driver（docker）

推荐使用 Docker Desktop 作为 minikube driver。

安装 Docker Desktop: [Docker Desktop 下载](https://desktop.docker.com/mac/main/arm64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=module&_gl=1*1nk4x9v*_gcl_au*MTIxMDQ3MzgyLjE3Mjk3Mzk5Njg.*_ga*NDIyMjM4MTYzLjE2NTE2NzEzNjY.*_ga_XJWPQMJYHQ*MTczMzEzNzE1My4xODQuMS4xNzMzMTM3MzM0LjE5LjAuMA..) *(请替换为 Podman Desktop 官方下载链接)*

安装完成后，在 Podman Desktop 的设置中，根据您的系统资源情况调整 CPU 和内存限制 (例如 12C24G)。

#### 2. 安装 minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
```

#### 3.点击启动docker

#### 4. 启动 minikube 集群

```bash
export KUBE_VERSION="v1.30.6"
export LIMIT_CPUS="8"
export LIMIT_MEMORY="16G"

minikube start -p "minikube" --driver=podman \
  --nodes=2 \
  --kubernetes-version="${KUBE_VERSION}" \
  --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}" 
```



### Windows (x86)

#### 1. 安装 minikube driver（Hyper-V）

推荐使用 Hyper-V 作为 minikube driver。 以下是在 Windows 系统上安装 Hyper-V 的示例：

**启用 Hyper-V:** 以管理员身份运行 PowerShell，执行以下命令：

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

系统可能需要重启。

##### 2. 安装 minikube

在 x86-64 Windows 系统上，建议使用 `.exe` 安装程序安装 Minikube 的最新稳定版本：

下载并运行最新版本的安装程序：[Minikube 最新版本下载](https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe)  *(请替换为 Minikube 官方提供的最新下载链接)*

或者，使用 PowerShell：

```powershell
New-Item -Path 'c:\' -Name 'minikube' -ItemType Directory -Force
Invoke-WebRequest -OutFile 'c:\minikube\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing
```

将 `minikube.exe` 添加到您的系统 `PATH` 环境变量中。  *请务必以管理员身份运行 PowerShell*。

```powershell
$oldPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
if ($oldPath.Split(';') -inotcontains 'C:\minikube'){
  [Environment]::SetEnvironmentVariable('Path', $('{0};C:\minikube' -f $oldPath), [EnvironmentVariableTarget]::Machine)
}
```

安装完成后，请关闭并重新打开终端以使更改生效。

#### 3. 启动 minikube 集群

```bash
export KUBE_VERSION="v1.30.6"
export LIMIT_CPUS="8"
export LIMIT_MEMORY="16G"

minikube start -p "minikube" --driver=hyperv \
  --nodes=2 \
  --kubernetes-version="${KUBE_VERSION}" \
  --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}"
```



## 安装 UPM

### 1. 安装 UPM Platform

运行安装脚本：

```bash
curl -sSL https://raw.githubusercontent.com/upmio/upm-quickstart/refs/heads/main/platform/install.sh | sh -
```

安装完成后，使用以下命令验证 `upm-engine` 部署是否成功：

```bash
kubectl get pod -n upm-system | grep upm-platform
```

您应该看到多个 `upm-platform` 相关的 Pod 处于 `Running` 状态。



### 2. 安装 UPM Engine

运行安装脚本：

```bash
https://raw.githubusercontent.com/upmio/upm-quickstart/refs/heads/main/engine/install.sh
```

安装完成后，使用以下命令验证 `upm-engine` 部署是否成功：

```bash
kubectl get pod -n upm-system | grep upm-engine
```

您应该看到 `upm-engine` 相关的 Pod 处于 `Running` 状态。 



#### 安装cert-manager

运行安装脚本：

```
https://github.com/upmio/upm-quickstart/blob/main/engine/uninstall-cert-manager.sh
```

请检查 `cert-manager` 的 Pod 是否正常运行：

```bash
kubectl get pod -n cert-manager
```



### 3. 访问 UPM 用户界面

使用 `kubectl port-forward` 命令将 `upm-platform-nginx` 服务的 80 端口映射到本地：

```bash
kubectl port-forward --address 0.0.0.0 -n upm-system services/upm-platform-nginx 80:80 &
```

然后，在浏览器中访问： `http://127.0.0.1/upm-ui/#/login`

默认用户名：`super_root`

默认密码：`Upm@2024!`

**重要提示:**  请根据您的实际网络环境配置代理设置 (`HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`)。  确保所有链接指向最新的官方文档和下载地址。  本指南仅供参考，具体操作可能因环境而异。
