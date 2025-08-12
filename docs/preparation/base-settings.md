---
slug: base-settings
keywords: 
  - ESXi基础设置
  - 家庭ESXi基础设置
  - 家庭AIO搭建教程
  - 家庭All-in-One搭建教程
description: 在成功安装ESXi系统后，还需要进行一系列基础配置，以便通过Web界面管理虚拟化环境。
---
在成功安装ESXi系统后，还需要进行一系列基础配置，以便通过 Web 界面管理虚拟化环境。
## 通过 Web 浏览器进入管理后台
通过上节的 [设置管理网卡 IP 地址](install-esxi.md#ip_1) 设置了一个 IP 地址，现在可以通过浏览器访问该 IP 地址，进入管理后台。

### 设置活动的网络适配器
是不是忘记干什么了？对插网线，连接物理网络。需一根网线，插到 AIO 主机的网卡槽中（ESXi 支持的网卡），另一头再插入另一台电脑网口中。继续上节的 [查看网络适配器](install-esxi.md#_7) 看看活动的网口是哪个，并通过空格键打上 `X`，保存即可。
![活动的网口](https://img.it927.com/aio/59.png)
???+ warning "注意"

    选择适配器时需要选择状态为：**Connected**（活动的），并禁用之前处于 Disconnected 状态的适配器。

### 配置控制电脑 IP 段
设置完后，另一台电脑（控制电脑），还需要将网段设置和 AIO 主机网段一致才可访问管理后台。
=== "MacOS 设置"

    如果另一台电脑（控制电脑）是 MacOS 操作系统，则在【网络】-【选择网卡】-【详细信息】-【TCP/IP】-【配置IPv4】，将 IPv4 设置为：192.168.188.2（不能和 **192.168.188.1** 相同），子网掩码设置为：255.255.255.0。
    ![配置IPv4](https://img.it927.com/aio/58.png)

=== "Win 设置"

    如果另一台电脑（控制电脑）是 Windows 操作系统，则在【控制面板】-【网络和共享中心】-【属性】-【Internet协议版本4(TCP/IPv4)属性】，选择手动配置，将 IPv4 设置为：192.168.188.3，子网掩码设置为：255.255.255.0。
    ![配置IPv4](https://img.it927.com/aio/64.png)

???+ warning "注意"

    **IPv4** 地址不能和 AIO 主机（**192.168.188.1**）相同，子网掩码必须和 AIO 主机（**255.255.255.0**）一致。

### 访问 ESXi 管理后台
完成网络配置后，即可通过Web浏览器访问 ESXi 管理界面：
=== "步骤一"
    
    在另一台电脑（控制电脑）浏览器中输入 AIO 主机的 IP 地址（192.168.188.1），按照图片中的操作，进入管理后台。
    ![进入管理后台](https://img.it927.com/aio/61.png)

=== "步骤二"
    
    用户名输入：root，密码输入 [安装系统](install-esxi.md#__tabbed_3_6) 时的密码，点击登入即可。
    ![进入管理后台](https://img.it927.com/aio/60.png)

成功登录后，将看到 ESXi 管理界面，可以查看硬件状态和进行后续配置。
![管理后台](https://img.it927.com/aio/62.png)
## 设置主机名
导航到 【管理】- 【系统】- 【高级设置】，搜索 `System.hostname`，设置有意义的主机名，如 `all-in-one-pc`。
![进入管理后台](https://img.it927.com/aio/66.png)
## 激活系统
有激活码可通过【管理】-【许可】-【分配许可证】可激活 ESXi 系统，无激活码有 30 天的试用版。
![管理后台](https://img.it927.com/aio/63.png)

## 开启 SSH 
为了方便后续的高级配置，建议启用 SSH 服务开启，SSH 方便后续直通做准备。通过【管理】-【服务】-【搜索】ssh，找到 `TSM-SSH` 启动服务。
![管理后台](https://img.it927.com/aio/65.png)
### 验证 SSH 连接
通过 `ssh` 命令测试，密码为登入密码，如果能进入的话，证明虚拟机已开通 SSH 服务。
```bash
ssh root@192.168.188.1
```
## 禁用 ESXi 显卡占用
如果 AIO 只有一张显卡的话，大概率这张显卡无法直通，因为被 ESXi 系统占用了，这时可以关闭 ESXi 占用。

通过上一步的 [验证 SSH 连接](base-settings.md#ssh_1) 进入 SSH 后，执行关闭命令。
```bash
# 关闭
esxcli system settings kernel set -s vga -v FALSE
# 开启
esxcli system settings kernel set -s vga -v TRUE
```
???+ note "注意事项"

    禁用显卡占用后将无法通过显示器查看 ESXi 控制台信息，只能通过 SSH 进行管理操作，也就是无法使用 `F2` 进行系统设置（其实很少用到，除了开始设置网络外）。

## 直通板载 SATA 控制器
ESXi 中板载 SATA 控制器默认是无法进行直通（灰色按钮），需要通过命令开启，通过 [验证 SSH 连接](base-settings.md#ssh_1) 进入 SSH 后，查找板载 SATA 控制器信息。
```bash
lspci -v | grep "Class 0106" -B 1
```
然后再修改 passthru.map 文件，
```bash
vi /etc/vmware/passthru.map
```
添加相应的设备 ID 配置
```bash
# Intel Corporation Lynx Point AHCI Controller
# 供应商ID PCLE_ID
8086  8d62   d3d0    false
```
