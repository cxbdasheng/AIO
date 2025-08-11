---
keywords:
  - OpenClash安装
  - OpenWrt安装OpenClash
  - 软路由存储管理
  - 陈大剩的家庭AIO服务器
  - 家庭AIO服务器
description: 介绍在ESXi环境中对OpenWrt软路由进行磁盘扩容的完整教程，包括ESXi虚拟机设置、OpenWrt分区扩展和文件系统扩容等步骤。
---
OpenClash 是基于 Clash 核心的 OpenWrt 代理工具，提供了友好的 Web 界面和强大的规则管理功能。本教程将详细介绍如何在 OpenWrt 系统上安装和配置 OpenClash。

官方开源项目地址：[https://github.com/vernesong/OpenClash](https://github.com/vernesong/OpenClash)


## 方法一：通过 opkg 安装（推荐）

### 更新软件包列表
```shell
opkg update
```
### 卸载 dnsmasq
```shell
opkg remove dnsmasq
mv /etc/config/dhcp /etc/config/dhcp.bak
```
### 依赖安装
```shell
opkg install shell iptables dnsmasq-full curl ca-bundle ipset ip-full iptables-mod-tproxy iptables-mod-extra ruby ruby-yaml kmod-tun kmod-inet-diag unzip luci-compat luci luci-base
```

### 下载 OpenClash 安装包
访问 [OpenClash Releases](https://github.com/vernesong/OpenClash/releases) 页面，下载对应的 ipk 文件， 传到 OpenWrt 里面。

截止 2025年08月11日，最新版为：[luci-app-openclash_0.46.137_all.ipk](https://github.com/vernesong/OpenClash/releases/download/v0.46.137/luci-app-openclash_0.46.137_all.ipk)
```shell
# 下载最新版本
cd /tmp
wget https://github.com/vernesong/OpenClash/releases/download/v0.46.137/luci-app-openclash_0.46.137_all.ipk
```
???+info "提示"
    可使用多种方法下载，陈大剩这里使用的 `wget`，进入 `GitHub` 可到网上搜一些稳定的 IP 地址。

### 安装 OpenClash
```shell
opkg install luci-app-openclash_0.46.137_all.ipk
```
安装看到如下提示，则为安装成功
```shell
Installing luci-app-openclash (0.46.137) to root...
Configuring luci-app-openclash.
```
成功后重启 OpenWrt，【服务】菜单下可以找到 OpenClash
```shell
reboot
```
## 方法二：手动编译安装
手动编译安装稍微复杂点，不建议此方式安装。
### 克隆源码
```shell
git clone https://github.com/vernesong/OpenClash.git package/luci-app-openclash
```
###  编译
```shell
make package/luci-app-openclash/compile V=s
```

## 初始配置
安装成功后，在 OpenWrt 的控制面板里面的【服务】菜单下可以找到 OpenClash，继续内核，后面的自由发挥。
![OpenClash](https://img.it927.com/aio/284.png)
