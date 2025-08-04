---
keywords:
  - ESXi安装Ubuntu
  - Ubuntu虚拟机创建
  - ESXi Ubuntu教程
  - 虚拟化Ubuntu部署
  - ESXi Linux安装
  - Ubuntu Server安装
  - VMware Ubuntu配置
  - 家庭AIO Ubuntu
  - 跳板机
  - Ubuntu系统优化
  - 家庭AIO搭建教程
  - 家庭All-in-One搭建教程
description: 详细介绍在ESXi环境中创建和安装Ubuntu跳板机的完整教程，包含虚拟机配置、系统安装、VMware Tools安装和网络配置等步骤。
---
根据网络拓扑设计的规范，需安装一个跳板机，跳板机需要支持的功能如下：

- [x] **代理** ESXi 管理网口，使不需要插网线即可访问 ESXi Web 管理页面；
- [x] **代理** 所有网络，可以通过跳板机找到每一台网络拓扑下的主机；
- [x] **隔离** 网络，实现内外网物理隔离，避免直接暴露内部系统；
- [x] **转发** 端口，可以提供安全的端口映射和转发服务；
- [x] **统一** 入口管理，作为访问内部网络资源的唯一入口，集中管理所有远程访问请求；

## 选择跳板机操作系统

综上原因需要，并不想每次都是通过配置命令行设置，最终陈大剩选择的具有图形界面的 Ubuntu 系统。

## 安装 Ubuntu 
Ubuntu 作为最受欢迎的 Linux 发行版之一，在ESXi环境中具有以下优势：**优秀的虚拟化支持**、**丰富的软件生态**、**长期支持版本**、**活跃的社区**、**企业级稳定性**。

### 准备工作
#### 1. 下载Ubuntu ISO镜像

根据使用场景选择合适的 Ubuntu 版本，陈大剩这里选择 Ubuntu Server 22.04 LTS 的版本。

=== "Ubuntu Server LTS（推荐）"
    
    **适用场景：** 服务器环境，无图形界面，资源占用少。
    
    - 下载地址：[Ubuntu Server 22.04 LTS](https://ubuntu.com/download/server)
    - 文件大小：约 1.4 GB
    - 推荐版本：22.04 LTS（支持到2027年）


=== "Ubuntu Desktop LTS"
    
    **适用场景：** 需要图形界面的应用场景。
    
    - 下载地址：[Ubuntu Desktop 22.04 LTS](https://ubuntu.com/download/desktop)
    - 文件大小：约 4.7 GB
    - 资源需求：更高的 CPU 和内存要求

#### 2. 上传ISO到ESXi数据存储
将下载的 ISO 文件上传到 ESXi 数据存储：

1. 登录ESXi管理后台
2. 导航：**存储** → **数据存储浏览器**
3. 选择目标数据存储
4. 创建ISO文件夹（可选）
5. 点击【上传文件】
  
![上传ISO文件](https://img.it927.com/aio/191.png)
### 创建虚拟机
#### 1. 新建虚拟机向导

**导航路径**：【虚拟机】→【创建/注册虚拟机】，首先是简单的三个步骤。

=== "步骤 1：选择创建类型"

    ![选择创建类型](https://img.it927.com/aio/108.png)

=== "步骤 2：选择名称和操作系统"

    ![选择名称和操作系统](https://img.it927.com/aio/192.png)

=== "步骤 3：选择储存"

    ![选择名称和操作系统](https://img.it927.com/aio/193.png)

#### 2. 存储和硬件配置
由于陈大剩配置的是跳板机需要图形页面，所以硬件分配会稍微高一点，大家可以根据自己的需求分配，自定义步骤比较多，如无需配置直通，后面两个步骤可跳过。
=== "自定设置 1：CPU"
 
    ![CPU](https://img.it927.com/aio/194.png)

=== "自定设置 2：内存"
    ![内存](https://img.it927.com/aio/195.png)

=== "自定设置 3：硬盘设置"
    ![添加硬盘](https://img.it927.com/aio/196.png)

=== "自定设置 4：添加网络适配器"
    如果需要代理 ESXi 管理网卡，则需添加 VM NetWork，其他再添加三个网络拓扑的网段。
    ![添加网络适配器](https://img.it927.com/aio/197.png)

=== "自定设置 5：添加镜像"

    ![添加镜像](https://img.it927.com/aio/198.png)

自定义设置完了，还需要需要将【虚拟机选项设】固件选择为【BIOS】，不直通选 EFI 也没有问题。
![固件选择](https://img.it927.com/aio/121.png)
最后，所有配置完成后，检查一遍，点完成。
### 开始安装
#### 安装流程
配置配置完后，可以点击打开电源开始安装：
=== "步骤一 ：引导页面"
    引导页面选择：*Try or Install Ubuntu（尝试或安装 Ubuntu）
     ![引导页面](https://img.it927.com/aio/199.png)

=== "步骤二 ：安装页面"
    安装页面选择【中文】后，点击【安装 Ubuntu】
     ![安装页面](https://img.it927.com/aio/203.png)

=== "步骤三 ：选择键盘布局"
    安装页面选择【中文】后，点击【安装 Ubuntu】
     ![选择键盘布局](https://img.it927.com/aio/204.png)

=== "步骤四 ：安装选项"
    安装选择选择【最小安装】即可
     ![选择键盘布局](https://img.it927.com/aio/205.png)

=== "步骤五 ：安装类型"
    安装类型选择【清除整个磁盘并安装 Ubuntu】，后面有个提示确认即可
     ![安装类型](https://img.it927.com/aio/206.png)

=== "步骤六 ：选择时区"
    选择时区点击【中国的地区】即可，或手动输入【上海】
     ![选择时区](https://img.it927.com/aio/208.png)

=== "步骤七 ：设置账号密码"
    设置账号密码按照自己的需求设置
     ![设置账号密码](https://img.it927.com/aio/207.png)

#### 完成安装
安装完成后，系统还会提示安装完成，需要重启一次
![重启系统](https://img.it927.com/aio/209.png)
至此，已经安装完成了 Ubuntu，稍后关机后，可以将 [存储和硬件配置-自定设置 5：添加镜像](#2) 添加的镜像给删除。
![删除镜像](https://img.it927.com/aio/210.png)

#### 安装 sshd
因为我们最小化安装，Ubuntu 并未带 `sshd` 包，所以需安装了，通过点击左下角的菜单图标进入菜单，再点击终端进入终端。
![安装 sshd](https://img.it927.com/aio/211.png)
在终端中输入，并按照要求输入密码，结束安装。
```shell
sudo apt-get install  openssh-server
```
???+info "注意"
    如果无法安装，请注意换源，换源教程请参考：[Ubuntu20.04 更换国内镜像源](https://midoq.github.io/2022/05/30/Ubuntu20-04%E6%9B%B4%E6%8D%A2%E5%9B%BD%E5%86%85%E9%95%9C%E5%83%8F%E6%BA%90/)

#### 开启 root 登入
在 Ubuntu 中，通常不推荐使用 root 用户来执行日常任务，因为这可能会导致系统安全性降低。由于我们只本地访问所以开启也无所谓。
##### 先设置 root 密码
输入如下命令后，再输入两次密码
```shell
sudo passwd root
```
##### 开启 root 访问
```shell
sudo nano /etc/ssh/sshd_config
```
查找找这行 `PermitRootLogin prohibit-password`，改为 `PermitRootLogin yes`
```shell
#PermitRootLogin prohibit-password # 复制一行
PermitRootLogin yes
```
重启 sshd，即可通过 ssh 访问了。
```shell
sudo systemctl restart ssh
```
## 跳板机网络配置
跳板机安装成功后，我们还需要将四个网卡设置固定 IP ，防止每次重启 IP 发生变化。
=== "网卡一"
    ![网卡一](https://img.it927.com/aio/212.png)
=== "网卡二"
    ![网卡二](https://img.it927.com/aio/213.png)

其中 `ens34` 一直处于正在连接中，为什么呢？因它和 ESXi 管理网卡一个网段，这个网段没有 DHCP 服务器，所以一直在连接中，获取不到 IP 地址。
### ESXi 管理网段设置
编辑 `ens34` 网卡，选择【IPv4】方式改为【手动】，将地址和 ESXi 管理网卡设置成一个网段。

因陈大剩 ESXi 管理网口地址为 `192.168.188.1`，所以这个网段设置为 `192.168.188.5`（不与 `192.168.188.1` 冲突就行），子网掩码为 `255.255.255.0`。
![ESXi 管理网段设置](https://img.it927.com/aio/214.png)
点击【应用】后，能看到 `ens34` 状态为已连接：
![ens34网卡状态](https://img.it927.com/aio/215.png)
通过 Ubuntu 自带的浏览器 Firefox 访问 `192.168.188.1`，可以看到能够成功访问 ESXi Web 管理页面。
![访问ESXi Web](https://img.it927.com/aio/216.png)
### 其他网段设置
其他网段需防止跳板机启动时跳 IP，还需要将获取 IP 方式改为 **静态 IP**，以家庭终端网段为例，首先查看获取的 IP：
![获取的 IP](https://img.it927.com/aio/217.png)
然后将 IP 填入【手动】中，点击【应用】
![访问](https://img.it927.com/aio/218.png)
**实验室网段** 和 **预留网段** 也依次按照此设置即可。

## 安装端口转发工具
`socat` 是一个多功能的网络工具，可以用于端口转发，比如我们可以将 **ESXi** 管理 Web 端口转发至 跳板机的端口，**ESXi** 管理 Web 页面就不需要再插网线了。
### 安装 socat
通过 apt 安装
```
sudo apt install socat 
```
### 代理测试
安装成功后输入 Ubuntu 如下代理 **ESXi** 管理 Web 端口
```shell
socat TCP-LISTEN:443,fork TCP:192.168.188.1:443
```

- `TCP-LISTEN:443`：监听本地的 `443` 端口。
- `fork`：允许同时处理多个连接。
- `TCP:192.168.88.1:443`：将流量转发到跳板机的 `443` 端口。

其他家庭网段终端可通过浏览器输入跳板机 IP `https://192.168.8.130/` 进行访问，记住一定要加上前面的  `https`  协议，不出意外我们能进行访问。
![浏览器输入跳板机](https://img.it927.com/aio/220.png)
## 代理 ESXi 管理网口
前面步骤是 **手动将命令输入到终端中**，不可能每次都去手动输入，我们需要设置成随跳板机一起启动，就得将 `socat` 设置为 **守护进程**，可以通过 `systemd` 的特性来实现。
### 创建一个 systemd 服务文件
打开终端，使用文本编辑器创建一个新的服务文件。例如，使用 `vim` 创建服务文件：
```shell
sudo vim /etc/systemd/system/socat-esxi.service
```
### 添加服务配置
写入如下内容：
```shell
[Unit]
Description=Socat Port Forwarding Service
After=network.target

[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:443,fork TCP:192.168.188.1:443
Restart=always

[Install]
WantedBy=multi-user.target
```

- **Restart=always**：确保服务在退出时自动重启；
- **RestartSec=5**：在重启之前等待 5 秒；
- **User=nobody**：以 `nobody` 用户身份运行服务，确保安全性。你可以根据需要更改为其他用户；
- **StandardOutput=syslog** 和 **StandardError=syslog**：将输出和错误记录到系统日志中，方便后续查看；

### 重新加载 systemd
运行以重新加载 `systemd`，使其识别新创建的服务：
```shell
sudo systemctl daemon-reload
```
### 启动服务
使用命令启动服务：
```shell
sudo systemctl start socat-esxi.service
```
### 检查服务状态
```shell
sudo systemctl status socat-esxi.service
```
![检查服务状态](https://img.it927.com/aio/221.png)
执行后查看是否成功，其他家庭网段终端可通过浏览器输入跳板机 IP `https://192.168.8.130/` 进行访问：
![浏览器输入跳板机](https://img.it927.com/aio/220.png)
至此大功告成，设置跳板机设置开机启动后，开机启动设置在软路由之后即可，可参考 [ESXi 进阶操作 - 虚拟机自启动](../esxi/self-starting.md)，最后可拔掉 **ESXi** 管理端口网线。

## 后续规划
前面功能只能说是跳板机的冰山一角，后续还可通过跳板机实现很多跨网段的方案。