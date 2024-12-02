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

### Linux

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
  --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}" \
  --base-image='registry.cn-hangzhou.aliyuncs.com/google_containers/kicbase:v0.0.45'
```

### MacOS （arm）

#### 1. 安装 minikube driver（docker）
推荐使用 Podman Desktop 作为 minikube driver。 以下是在 MacOS 系统上安装 Podman Desktop 的示例：

安装 Podman Desktop: [Podman Desktop 下载](https://podman.io/) *(请替换为 Podman Desktop 官方下载链接)*

安装完成后，在 Podman Desktop 的设置中，根据您的系统资源情况调整 CPU 和内存限制 (例如 12C24G)。

#### 2. 安装 minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
```

#### 3. 启动 minikube 集群

```bash
export KUBE_VERSION="v1.30.6"
export LIMIT_CPUS="8"
export LIMIT_MEMORY="16G"

minikube start -p "minikube" --driver=podman \
  --nodes=2 \
  --container-runtime=cri-o --kubernetes-version="${KUBE_VERSION}" \
  --memory="${LIMIT_MEMORY}" --cpus="${LIMIT_CPUS}"
```

### Windows

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
sh -x quickstart/platform/install.sh
```

在继续下一步之前，请等待返回以下消息：

```bash
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

您应该看到多个 `upm-platform` 相关的 Pod 处于 `Running` 状态。


### 2. 安装 UPM Engine

运行安装脚本：

```bash
sh -x quickstart/engine/install.sh
```

安装完成后，使用以下命令验证 `upm-engine` 部署是否成功：

```bash
kubectl get pod -n upm-system | grep upm-engine
```

您应该看到 `upm-engine` 相关的 Pod 处于 `Running` 状态。 



#### 安装cert-manager

运行安装脚本：

```
sh -x quickstart/engine/install-cert-manager.sh
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



### 初始化 UPM 平台

#### 添加项目

资源管理>项目管理>新增

**名称**：项目名称，逻辑概念，自定义名称

**命名空间**：应用实例创建所在的namespace

#### 添加集群

集群管理>注册

**名称**：集群名称，逻辑概念，自定义名称

**集群类型**：选择kubernetes

**支持服务类型**：选择NodePort

**默认服务类型**：选择NodePort

**Keepalive Address**：使用minikube中的node地址

**认证方式**：选择kubeconfig

**配置文件内容**：填写minikube所创建集群的kubeconfig文件

#### 添加区域

 区域管理>新增

**集群**：选择之前创建的集群

**名称**：区域名称，逻辑概念，自定义名称

#### 添加主机组

主机组管理>新增

**集群**：选择之前创建的集群

**区域**：选择之前创建的区域

**名称**：主机组名称，逻辑概念，自定义名称

#### 添加主机

 主机管理>注册

选择节点后点击下一步

**区域**：选择之前创建的区域

**主机组**：选择之前创建的主机组

**标签**：该主机上允许创建实例的类型，这里选择全选

点击立即注册后可以在主机列表中查看到该主机

#### 添加存储类

存储类管理>注册

选择standard点击下一步

**名称**：存储名称自定义

点击注册后可以在存储类列表中查看到该存储类

#### 实例规模管理

这里以MySQL为例

 MySQL> 规模管理>新增

**类型**：选择MySQL

**名称**：规模名称，自定义

**最小运行限制**：kubernetes resource概念

**最大使用限制**：kubernetes resource概念

点击保存后可以在规模列表中查看到该规模

#### 创建实例

这里以MySQL为例

 MySQL>工单管理>新增>立即申请>确认

工单列表中点击

审批>同意>确认>执行>确认>前往

MySQL实例创建中等待完成







