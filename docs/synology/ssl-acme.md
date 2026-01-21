---
slug: synology-ssl-acme
keywords:
  - 群晖SSL证书
  - acme.sh自动续签
  - Let's Encrypt证书
  - 群晖HTTPS配置
  - SSL证书自动更新
  - 群晖证书管理
  - DSM SSL配置
  - 免费SSL证书
  - 群晖域名证书
  - 黑群晖SSL
  - acme.sh部署
  - 群晖证书续签
  - 陈大剩的家庭AIO服务器
  - 家庭AIO服务器
description: 详细介绍如何使用acme.sh为群晖NAS自动申请和续签Let's Encrypt免费SSL证书，包括安装配置、DNS API验证、自动部署到DSM系统以及常见问题解决方案
---

# 使用 acme.sh 自动续签群晖的 SSL 证书

## 什么是 acme.sh

**acme.sh 是一个纯 Shell 脚本实现的 ACME 协议客户端，可以自动化申请和续签 Let's Encrypt 等机构的免费 SSL 证书**。相比 certbot 等工具，acme.sh 更轻量、依赖更少，特别适合在群晖等 NAS 设备上使用，本节使用 Docker 安装 acme.sh。

## 为什么需要自动续签

Let's Encrypt 证书有效期为 90 天，到期前需要手动续签比较麻烦。使用 acme.sh 可以实现：

- 自动申请证书
- 自动续签（默认 60 天后自动续签）
- 自动部署到群晖 DSM 系统
- 无需手动干预，一次配置永久有效

## 前置准备

1. **域名**：需要拥有一个域名，并能够修改 DNS 解析记录
2. **DNS API 支持**：建议使用 DNS API 方式验证域名所有权（支持多种 DNS 服务商）

## 安装 Docker

群晖需要先安装 Container Manager（Docker）才能运行 acme.sh 容器。

=== "步骤 1：安装 Container Manager"
    进入群晖 **【套件中心】**，搜索 `docker`，选择 **Container Manager** 并安装
    ![安装 Container Manager](https://img.it927.com/aio/487.png)

=== "步骤 2：配置 Docker 网络"
    在 Container Manager 中设置 Docker 网络子网，通常保持默认配置即可
    ![配置 Docker 网络](https://img.it927.com/aio/488.png)

=== "步骤 3：确认配置"
    检查 Docker 配置信息，确认无误后点击 **【完成】**
    ![检查 Docker 配置](https://img.it927.com/aio/489.png)

=== "步骤 4：验证安装"
    安装完成后，可在 **【套件中心】** 查看到 Container Manager
    ![完成 Docker 安装](https://img.it927.com/aio/490.png)

## 安装 acme.sh

安装完 Container Manager（Docker）后，需要下载并运行 acme.sh 容器镜像。

=== "步骤 1：搜索 acme.sh 镜像"
    进入 **【套件中心】→【Container Manager】→【镜像仓库】**，搜索 `acme.sh`，点击选择
    ![搜索 acme.sh 镜像](https://img.it927.com/aio/527.png)

=== "步骤 2：下载镜像"
    选择最新版本（通常默认为 `latest` 标签），点击 **【下载】**
    ![下载镜像](https://img.it927.com/aio/492.png)

=== "步骤 3：创建容器"
    进入 **【Container Manager】→【容器】**，点击 **【新增】**
    ![创建 Docker 容器](https://img.it927.com/aio/493.png)

=== "步骤 4：常规设置"
    - **映像**：选择 `acme.sh:latest`
    - **容器名称**：自定义（如 `acme-sh`），复制容器名称，后续会用到。
    - **启用自动重新启动**：勾选此选项，确保容器随系统启动
    ![Docker 常规设置](https://img.it927.com/aio/528.png)

=== "步骤 5：存储设置"
    **存储空间映射**：挂载到容器内的 `/acme.sh` 目录，可以新创建一个目录，如 `/volume1/docker/acme.sh`
    ![Docker 端口存储设置](https://img.it927.com/aio/529.png)

=== "步骤 6：环境变量设置"
    设置必要的环境变量用于证书申请和部署。以下是不同 DNS 服务商的配置示例：

    **群晖 DSM 部署相关（必填）：**
    ```shell
    SYNO_Username=admin              # 群晖管理员账号
    SYNO_Password=your_password      # 群晖管理员登录密码
    SYNO_Certificate=nas.it927.com   # 证书描述名称（建议使用域名）
    SYNO_Create=1                    # 如果证书不存在则自动创建
    ```

    **DNS 服务商 API 配置（根据实际服务商选择其一）：**

    华为云 DNS：
    ```shell
    HUAWEICLOUD_Username=your_iam_username      # IAM 用户名
    HUAWEICLOUD_Password=your_iam_password      # IAM 用户密码
    HUAWEICLOUD_DomainName=your_account_name    # 华为云账户名
    ```

    阿里云 DNS：
    ```shell
    Ali_Key=your_access_key          # 阿里云 Access Key
    Ali_Secret=your_access_secret    # 阿里云 Access Secret
    ```

    腾讯云 DNS：
    ```shell
    Tencent_SecretId=your_secret_id      # 腾讯云 SecretId
    Tencent_SecretKey=your_secret_key    # 腾讯云 SecretKey
    ```

    CloudFlare DNS：
    ```shell
    CF_Token=your_api_token          # CloudFlare API Token
    CF_Account_ID=your_account_id    # CloudFlare Account ID
    ```

    更多 DNS 服务商配置请参考：[acme.sh DNS API 文档](https://github.com/acmesh-official/acme.sh/wiki/dnsapi2)

    ![环境变量设置](https://img.it927.com/aio/530.png)

    ???+ warning "注意"
        如果使用华为云 DNS，必须创建 IAM 子账号并授权相应权限，详见 [华为云特殊设置](#_3)

=== "步骤 7：网络设置"
    网络模式可设置为 **【host】** 模式，**执行命令** 处输入 `daemon`。
    ![Docker 网络设置](https://img.it927.com/aio/531.png)

=== "步骤 8：确认创建"
    检查所有配置参数，确认无误后点击 **【完成】**

### 华为云特殊设置

???+ info "为什么需要特殊设置"
    华为云的 API 访问必须使用 IAM 子账号进行认证，主账号无法直接使用。因此需要创建 IAM 子账号并授予 DNS 管理权限，否则证书申请和续签会失败。

#### 创建 IAM 子账号

=== "步骤 1：进入统一身份认证"
    登录华为云控制台，选择 **【统一身份认证】** 服务
    ![进入统一身份认证](https://img.it927.com/aio/515.png)
=== "步骤 2：创建子账号"
    进入【用户】点击【创建用户】
    ![创建子账号](https://img.it927.com/aio/516.png)
=== "步骤 3：创建用户"
    输入用户名，选择：【编程访问】、【管理控制台访问】，关闭【登入保护】，点击【下一步】
    ![创建子账号](https://img.it927.com/aio/517.png)
=== "步骤 4：完成用户创建"
    点击【创建用户】
    ![完成用户创建](https://img.it927.com/aio/522.png)
=== "步骤 5：下载凭证信息"
    创建完成后会提示下载凭证信息（包含初始密码），务必保存好
    ![下载凭证信息](https://img.it927.com/aio/550.png)

#### 创建并配置用户组

完成子用户创建后，需要创建用户组并授予 DNS 管理权限。

=== "步骤 1：创建用户组"
    进入【用户组】点击【创建用户组】
    ![创建用户组](https://img.it927.com/aio/547.png)
=== "步骤 2：完成用户组创建"
    输入用户组名称和描述，点击【确定】
    ![完成用户组创建](https://img.it927.com/aio/548.png)
=== "步骤 3：授权用户组"
    在【用户组】中点击刚刚创建的用户组，点击【授权】
    ![授权用户组](https://img.it927.com/aio/549.png)
=== "步骤 4：授权用户组权限"
    搜索【dns】授权，选择【 DNS Administrator 】和【 DNS FullAccess 】，点击【下一步】
    ![授权用户组权限](https://img.it927.com/aio/518.png)
=== "步骤 5：授权用户组最小权限"
    授权所有资源，点击【确认】
    ![授权用户组最小权限](https://img.it927.com/aio/519.png)
=== "步骤 6：完成授权"
    确认授权信息，完成用户组权限配置
    ![完成授权](https://img.it927.com/aio/520.png)

#### 将用户添加到用户组

创建并配置好用户组后，需要将之前创建的 IAM 用户添加到该用户组中。

=== "步骤 1：进入用户授权"
    返回【用户】列表，选择刚创建的用户，点击【授权】
    ![用户授权](https://img.it927.com/aio/523.png)
=== "步骤 2：选择用户组"
    在授权界面中，选择刚创建的用户组，将用户加入该组
    ![选择用户组](https://img.it927.com/aio/521.png)
=== "步骤 3：完成用户授权"
    确认授权，完成用户添加到用户组的操作
    ![完成授权](https://img.it927.com/aio/551.png)

#### 获取环境变量所需信息

完成上述配置后，需要登录子账号获取 acme.sh 所需的环境变量信息。

=== "步骤 1：复制子账号登录链接"
    将鼠标悬停在创建的子账号名称上，会显示子账号登录链接，复制该链接
    ![复制登录链接](https://img.it927.com/aio/552.png)

=== "步骤 2：登录子账号"
    在新的浏览器窗口或无痕模式下访问该链接，使用之前下载的初始密码登录
    ![登录子账号](https://img.it927.com/aio/553.png)

=== "步骤 3：修改初始密码"
    首次登录后系统会要求修改初始密码，设置新密码并妥善保存
    ![修改初始密码](https://img.it927.com/aio/554.png)

=== "步骤 4：查看账户信息"
    登录成功后，进入控制台，在 **【我的凭证】** 中查看账户信息
    ![查看账户信息](https://img.it927.com/aio/556.png)

#### 环境变量配置信息

完成以上步骤后，即可获得 acme.sh 所需的华为云环境变量：

![账户凭证信息](https://img.it927.com/aio/526.png)

三个环境变量的对应关系：

- **HUAWEICLOUD_Username**：IAM 用户名（上图中的"IAM 用户名"）
- **HUAWEICLOUD_Password**：IAM 用户密码（修改后的新密码）
- **HUAWEICLOUD_DomainName**：账户名（上图中的"账户名"）

## 配置自动续签

运行 acme.sh 容器后，需要创建自动续签脚本并配置计划任务，实现证书的自动申请和续签。

=== "步骤 1：编写自动续签脚本"
    在本地创建名为 `cert.sh` 的脚本文件，根据实际情况修改以下三个必填参数：
    ```shell
    #!/bin/bash
    # 域名（必填）
    DOMAIN='nas.it927.com'
    
    # 域名 DNS 服务商（必填）
    # 类型：dns_ali dns_dp dns_gd dns_aws dns_linode dns_huaweicloud 根据域名服务商而定
    # 可参考：https://github.com/acmesh-official/acme.sh/wiki/dnsapi2
    DNS='dns_huaweicloud'
    
    # Docker 容器名称（必填）
    DOCKER_CONTAINER_NAME='acme-sh'
    
    # DNS API 生效等待时间 值(单位：秒)，一般120即可
    # 某些域名服务商的API生效时间较大，需要将这个值加大(比如900)
    DNS_SLEEP=120
    
    # 证书服务商，letsencrypt
    CERT_SERVER='letsencrypt'
    
    generateCrtCommand="acme.sh --force --log --issue --server ${CERT_SERVER} --dns ${DNS} --dnssleep ${DNS_SLEEP} -d "${DOMAIN}" -d "*.${DOMAIN}""
    
    installCrtCommand="acme.sh --deploy -d "${DOMAIN}" -d "*.${DOMAIN}" --deploy-hook synology_dsm"
    
    docker exec $DOCKER_CONTAINER_NAME  $generateCrtCommand
    
    docker exec $DOCKER_CONTAINER_NAME $installCrtCommand
    ```
=== "步骤 2：上传脚本"
    将上一步生成的脚本上传到群晖，并保存在 `/volume1/docker/acme.sh` 目录（共享目录）下：
    ![Docker 上传脚本](https://img.it927.com/aio/533.png)
=== "步骤 3：新建定时任务"
    进入 **【控制面板】→【计划任务】**，点击 **【新增】**
    ![Docker 新建定时任务](https://img.it927.com/aio/534.png)
=== "步骤 4：计划任务设置（常规）"
    - **任务名称**：`update_ssl`（可自定义）
    - **用户账号**：输入 `root`
    ![计划任务设置](https://img.it927.com/aio/535.png)
=== "步骤 5：计划任务设置（计划）"
    设置定时执行计划。由于 Let's Encrypt 证书有效期为 90 天，建议设置为每月执行一次或每周执行一次，确保证书及时续签。

    推荐设置：每月 1 号凌晨 2 点执行
    ![计划任务设置](https://img.it927.com/aio/536.png)
=== "步骤 6：计划任务设置（任务设置）"
    任务设置模块，通知按需选择，用户定义的脚本输入上一步生成的脚本路径，并输入日志路径：
    ```shell
    /volume1/docker/acme.sh/cert.sh >> /volume1/docker/acme.sh/log.txt 2>&1
    ```
    ![计划任务设置](https://img.it927.com/aio/537.png)
=== "步骤 7：确认创建"
    检查所有配置参数，确认无误后点击 **【确认】**，输入密码完成创建。
    ![计划任务设置](https://img.it927.com/aio/538.png)

### 验证证书续签

配置完成后，可以手动执行一次计划任务来验证证书是否能够成功申请。

=== "步骤 1：手动执行任务"
    在计划任务列表中，选择刚创建的任务，点击 **【运行】** 手动执行一次
    ![查看续签结果](https://img.it927.com/aio/541.png)

=== "步骤 2：查看执行日志"
    等待 3-5 分钟后，检查 `/volume1/docker/acme.sh/log.txt` 日志文件，确认证书申请和部署是否成功

???+ tip "故障排查"
    如果证书申请失败，请检查以下几点：

    - 脚本参数是否正确（域名、DNS 服务商、容器名称）
    - 环境变量是否正确配置
    - DNS API 密钥是否有效且具备相应权限
    - 查看 `/volume1/docker/acme.sh/log.txt` 日志文件获取详细错误信息

## 证书部署配置

证书申请成功后，需要在群晖 DSM 中进行一些配置，才能正常使用 HTTPS 访问。

### 1. 配置 DNS 解析

首先需要在域名服务商处添加 DNS 解析记录，将域名指向群晖的 IP 地址。

**内网访问配置：**

如果仅在内网使用，将域名解析到群晖的内网 IP 地址（如 `192.168.88.191`）

![内网 DNS 解析](https://img.it927.com/aio/543.png)

**公网访问配置：**

如果需要从公网访问，将域名解析到公网 IP，并在路由器中配置端口转发（HTTPS 使用 443 端口）

### 2. 设置默认证书

证书部署成功后，需要在 DSM 中将其设置为默认证书。

进入 **【控制面板】→【安全性】→【证书】→【设置】**，将所有服务的证书都设置为刚申请的证书：

![设置默认证书](https://img.it927.com/aio/542.png)

???+ info "证书应用说明"
    建议将所有服务都设置为使用新证书，包括：

    - DSM 桌面
    - 所有套件和应用程序
    - 反向代理服务（如有）

### 3. 配置主机名称

设置主机名称可以确保 DSM 正确响应来自域名的 HTTPS 请求。

进入 **【控制面板】→【外部访问】→【高级设置】**，在"主机名称"中填入您的域名：

![设置主机名称](https://img.it927.com/aio/511.png)

## 验证证书

完成所有配置后，可以通过以下方式验证证书是否正常工作：

### 浏览器访问验证

在浏览器中访问 `https://your-domain.com`（替换为您的实际域名），如果看到如下页面且浏览器地址栏显示安全锁图标，说明证书配置成功：

![证书验证成功](https://img.it927.com/aio/544.png)

### 证书信息检查

点击浏览器地址栏的安全锁图标，查看证书详情，确认：

- 证书颁发机构为 Let's Encrypt
- 证书有效期为 90 天
- 证书包含主域名和通配符域名（如配置了 `*.your-domain.com`）