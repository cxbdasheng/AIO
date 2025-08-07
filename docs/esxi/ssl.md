---
keywords:
  - ESXi SSL证书
  - ESXi HTTPS配置
  - VMware证书管理
  - ESXi安全配置
  - 免费SSL证书
  - 域名证书配置
  - ESXi证书导入
  - 虚拟化安全
  - Let's Encrypt ESXi
  - 阿里云SSL证书
description: 介绍如何为ESXi配置有效的SSL证书，包括域名解析、证书申请、证书导入和自动续期等完整流程，提升ESXi管理界面的安全性。
---
## ESXi 系统证书无效
**浏览器警告**：每次访问都显示"不安全"警告，ESXi 自带的证书是无效的，这怎么能忍？
![SSL证书信任](https://img.it927.com/aio/220.png)

## 准备工作
配置证书，需准备一个公网域名，如陈大剩的域名 `it927.com`，如果再拥有一个公网 IP 更好。

## 域名解析

配置 1 个 A 记录的子域名解析到 192.168.8.130（ESXi 的控制台 IP）：
![域名解析](https://img.it927.com/aio/248.png)

!!! info "IP 地址说明"
    这里的 `192.168.8.130` 是 ESXi 管理网口的 IP 地址，请根据实际情况修改。

配置完成后，等待 10-15 分钟进行全球 DNS 传播，然后验证解析是否生效：

![DNS解析](https://img.it927.com/aio/249.png)

## 签发证书
使用云服务器厂商提供服务签发 1 个免费的证书（3个月），陈大剩这里使用的是阿里云的 DigiCert 免费版 SSL。
![证书签发完成](https://img.it927.com/aio/226.png)
因为签发证书为基础操作，这里不做展开，有需具体了解的可展开 “证书签发流程” 查看。
??? info "证书签发流程"
    ### 创建证书
    登录阿里云控制台，进入 **SSL证书服务**：
    
    1. 点击【购买证书】
    2. 选择【DV单域名证书【免费试用】】
    3. 确认订单并支付（免费）
    
    ![创建证书](https://img.it927.com/aio/222.png)
    
    ### 配置证书信息
    在证书管理页面：
    
    1. 点击【证书申请】
    2. 填写域名：`aio.it927.com`
    3. 选择验证方式：**DNS验证**（推荐）
    4. 填写联系信息
    
    ![验证 DNS](https://img.it927.com/aio/223.png)
    
    ### DNS 验证
    系统会生成一条 TXT 记录，需要添加到域名 DNS 中：
    
    **验证记录示例：**
    ```
    记录类型：TXT
    主机记录：_dnsauth.aio
    记录值：202312151234567890abcdef...
    TTL：600
    ```
    ![验证 DNS](https://img.it927.com/aio/225.png)
    
    **验证步骤：**
    
    1. 复制提供的 TXT 记录
    2. 在域名管理后台添加 TXT 记录
    3. 等待 DNS 传播（5-10分钟）
    4. 点击【验证】按钮
    ### 证书签发
    验证通过后，证书会在 10-30 分钟内签发完成：
    
    ![证书签发完成](https://img.it927.com/aio/226.png)

### 下载证书

证书签发后，下载证书文件：

1. 点击【下载】；
2. 选择服务器类型：**Apache**；
3. 下载包含以下文件：
   - `aio.it927.com_public.crt`（证书文件）
   - `aio.it927.com.key`（私钥文件）

## 导入证书
目前博通已经不允许 ESXi 管理界面导入 SSL 证书了，只能通过 SSH 方式更换证书，先开启 SSH 登入。
### 上传证书
上传证书，可使用 ESXi 默认的数据浏览器上传，将两个证书上传至存储的根目录，导航【存储】-【选择盘】-【上载】，然后上载下载的两个文件即可。
![上传证书](https://img.it927.com/aio/254.png)
### SSH 登入
前面章节介绍过 SSH 登入，这里介绍另一种方法，导航【主机】-【操作】-【服务】-【启用 Secure Shell (SSH)】
![开启 SSH](https://img.it927.com/aio/253.png)
再通过控制电脑 SSH 到 ESXi 中，陈大剩这里可以使用 [跳板机](../network/jumper.md) 也可以直接使用网线连接
### 备份默认证书
SSH 登入后我们先要备份默认证书，进入 `/etc/vmware/ssl` 目录，分别找到 `rui.crt` 和 `rui.key`，将这 2 个文件改名 `xxx.back`
```shell
cd /etc/vmware/ssl
mv rui.crt rui.crt.back
mv rui.key rui.crt.key
```
### 替换默认证书
备份默认证书后，还需将 `/vmfs/volumes/datastore1/` 目录下的 2 个证书，替换成默认证书，命令如下：
```shell
mv /vmfs/volumes/datastore1/aio.it927.com_public.crt rui.crt
mv /vmfs/volumes/datastore1/aio.it927.com.key rui.key
```

### 访问
上述步骤全部完成后，重启管理服务，即可使用 `https://aio.it927.com` 访问，这时候已经没有“不安全”的提示了，访问时记得加上 `https` 协议
![访问管理界面](https://img.it927.com/aio/252.png)

## 总结
本文演示配置了安全证书，但是 DNS 解析的是局域网 IP，有公网 IP 条件的朋友可以直接解析到公网 IP，没有的朋友也不要着急，我们可以将 DNS 解析 IPv6 地址上。
