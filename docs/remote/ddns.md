---
slug: ddns
keywords:
  - IPv6
  - DDNS
  - 动态域名解析
  - 家庭服务器
  - ESXi远程访问
  - 家庭AIO搭建教程
  - 家庭All-in-One搭建教程
description: IPv6 DDNS 动态域名解析配置指南，使用 D-NET 实现自动更新 DNS 解析记录
---
# IPv6 DDNS

在前面 [软路由 - 开启 IPv6](../route/ipv6.md) 章节中，已经拿到了运营商分配的 IPv6 地址。但这个地址不是静态的——重拨、断电、路由器重启，都可能换一个新地址，域名解析随之失效。

DDNS（动态域名解析）就是解决这个问题的：**实时监听本地 IP 变化，自动更新 DNS 记录**，让域名始终指向最新的地址，不需要人工干预。

## D-NET 介绍

D-NET 内置了 DDNS 模块，支持 A、AAAA、CNAME、TXT 多种记录类型，IPv4/IPv6 双栈均可使用。配合 DCDN 模块还能通过 CNAME 记录实现 CDN 加速接入，适合家庭宽带等动态 IP 场景。

## 安装 D-NET

参考前面章节的 [二进制安装 D-NET](ipv6-ipv4.md#__tabbed_2_1) 或 [Docker 安装 D-NET](../synology/remote-access.md#d-net)，任选一种方式安装即可。

## 配置 DDNS

安装完成后，浏览器访问 `http://127.0.0.1:9877` 进入 Web 管理页面，首次登录时设置管理员账号密码。

![登入 Web 管理页面](https://img.it927.com/aio/408.png "登入 Web 管理页面")

### 第一步：创建云厂商 AccessKey

根据使用的 DNS 服务商，在对应控制台创建 AccessKey，供 D-NET 调用 API 更新解析记录。

=== "百度智能云"
    进入 [百度智能云控制台](https://console.bce.baidu.com/iam/?_=1651763238057#/iam/accesslist) 创建 AccessKey。

    ![百度智能云创建 AccessKey](https://img.it927.com/aio/409.png "百度智能云创建 AccessKey")

=== "阿里云"
    进入 [阿里云控制台](https://ram.console.aliyun.com/manage/ak?spm=5176.12818093.nav-right.dak.488716d0mHaMgg) 创建 AccessKey。

    ![阿里云创建 AccessKey](https://img.it927.com/aio/410.png "阿里云创建 AccessKey")

### 第二步：填写云厂商配置

在 D-NET Web 管理页面中完成以下配置：

1. 打开 DDNS 开关
2. 填写云厂商 AccessKey 信息
3. 填写 TTL（推荐设置为 60 秒，IP 变化后解析能快速生效）

![填写相应的 AccessKey](https://img.it927.com/aio/557.png "填写相应的 AccessKey")

### 第三步：选择解析协议

根据实际情况选择需要的解析类型。

#### IPv6 / IPv4 解析

根据自己的公网 IP 类型选择对应协议。同时有 IPv4 和 IPv6 的话，可以两个都勾上——D-NET 会分别维护 A 记录（IPv4）和 AAAA 记录（IPv6）。

!!! tip "不确定选哪个？"
    家庭宽带通常只有 IPv6 公网地址，选 AAAA 就够了。如果运营商同时给了 IPv4 公网地址（非 NAT），可以同时勾选。

![选择解析协议](https://img.it927.com/aio/558.png "选择解析协议")

#### CNAME 解析

配合 DCDN 模块使用，将域名 CNAME 指向 CDN 域名，实现 IPv6 加速接入，无需手动维护记录。

!!! warning "注意"
    CNAME 记录不能与 A、AAAA 等其他记录类型同时存在于同一个域名下。

![CNAME 解析](https://img.it927.com/aio/559.png "CNAME 解析")

#### TXT 解析

配合 DCDN 模块的 [域名归属权验证](https://github.com/cxbdasheng/dnet/wiki/%E5%9F%9F%E5%90%8D%E5%BD%92%E5%B1%9E%E9%AA%8C%E8%AF%81) 功能使用，D-NET 会自动更新验证所需的 TXT 记录。

![TXT 解析](https://img.it927.com/aio/561.png "TXT 解析")

### 第四步：保存并验证

点击保存，等待保存成功后，可在日志中看到解析结果。第一次配置成功后，D-NET 会定期检测 IP 是否变化，有变化时自动更新 DNS 记录。

![保存成功并查看日志](https://img.it927.com/aio/560.png "保存成功并查看日志")

保存后可以用 `nslookup 你的域名` 或 `dig AAAA 你的域名` 查询解析结果，确认是否已指向当前 IP。

![nslookup](https://img.it927.com/aio/562.png "TXT 解析")

## 总结

配置完成后，无论运营商何时刷新 IPv6 地址，D-NET 都会自动同步更新 DNS 记录，家庭服务器的域名访问不再因 IP 变动而中断。

## 参考文档

- [D-NET DDNS 使用指南](https://github.com/cxbdasheng/dnet/wiki/DDNS-%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97)
- [D-NET 项目](https://github.com/cxbdasheng/dnet)
