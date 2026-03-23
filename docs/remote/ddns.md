---
slug: ipv6
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

D-NET DDNS（Dynamic DNS）是一个自动化 DNS 解析管理模块，专为动态 IP 环境设计。

DDNS **通过实时监听本地 IP 地址变化，自动更新 DNS 解析记录**，确保域名始终指向最新的 IP 地址。

支持 A、AAAA、CNAME、TXT 多种记录类型，IPv4/IPv6 双栈，适合**家庭宽带等动态 IP 环境下对外提供服务**，也可配合 DCDN 功能，通过 CNAME 记录指向 CDN 域名实现加速接入。

## 支持的 DNS 服务商

| 服务商 | service 值 | AccessKey | AccessSecret |
|--------|-----------|-----------|--------------|
| 阿里云 DNS | `alidns` | AccessKey ID | AccessKey Secret |
| 腾讯云 DNSPod | `tencent` | SecretId | SecretKey |
| 华为云 DNS | `huawei` | AccessKey ID | Secret Access Key |
| 百度智能云 DNS | `baiducloud` | AccessKey ID | Secret Access Key |
| Cloudflare | `cloudflare` | API Token | 不需要 |

!!! tip "Cloudflare 获取 API Token"
    登录 Cloudflare → 右上角头像 → My Profile → API Tokens → Create Token，选择 **Edit zone DNS** 模板，范围选择对应域名即可。

## D-NET DDNS 配置

### 基本配置

1. 访问 D-NET 管理界面，进入 **DDNS 配置** 页面；
2. 填写以下信息：

| 字段 | 说明 | 示例 |
|------|------|------|
| 域名 | 需要动态解析的完整域名（含子域名） | `ddns.example.com` |
| 服务商 | 选择 DNS 服务商 | 阿里云 |
| AccessKey | 云厂商访问密钥 ID | — |
| AccessSecret | 云厂商访问密钥（Cloudflare 不填） | — |
| TTL | 解析记录的缓存时间 | `600`（秒）、`10m`、`1h` |

### 添加 DNS 记录

每个域名下可添加多条记录，每条记录配置如下：

| 字段 | 说明 |
|------|------|
| 记录类型 | A、AAAA、CNAME、TXT |
| IP 来源 | 见下方 [IP 来源类型](#ip-来源类型) |
| 值 | 根据 IP 来源填写对应内容 |
| 正则（可选） | 仅网卡获取 IPv6 时使用，用于筛选特定地址 |

!!! warning "CNAME 互斥限制"
    CNAME 记录不能与同一子域名下的其他记录类型（A、AAAA、TXT 等）共存。当某个子域名被配置为 CNAME 时，D-NET 会自动删除该子域名下已存在的其他类型记录；反之，若该子域名已有 CNAME 记录，切换为其他类型时也会先删除 CNAME。请确认后再操作，**被删除的记录无法恢复**。

## IP 来源类型

### IPv4

| 来源类型 | 说明 | 值填写示例 |
|---------|------|-----------|
| 静态 IPv4 | 固定 IP 地址，不自动更新 | `1.2.3.4` |
| URL 获取 | 通过外部接口获取公网 IP | `https://api4.ipify.org` |
| 网卡获取 | 读取本机指定网卡的 IP | `eth0`、`en0` |
| 命令获取 | 执行自定义命令并解析输出 | `curl -s https://api4.ipify.org` |

### IPv6

| 来源类型 | 说明 | 值填写示例 |
|---------|------|-----------|
| 静态 IPv6 | 固定 IPv6 地址 | `2001:db8::1` |
| URL 获取 | 通过外部接口获取公网 IPv6 | `https://api6.ipify.org` |
| 网卡获取 | 读取本机指定网卡的 IPv6（支持正则筛选） | `eth0` |
| 命令获取 | 执行自定义命令并解析输出 | — |

!!! tip "网卡获取 IPv6 的正则筛选"
    一块网卡通常会有多个 IPv6 地址（临时地址、链路本地地址等），可以通过正则表达式精确匹配所需地址。例如 `^2409` 匹配电信分配的 IPv6 前缀。

## CNAME 配合 DCDN 使用

如果已配置 DCDN，可以在 DDNS 中添加一条 CNAME 记录，将域名指向 CDN 的 CNAME 地址，实现通过简单域名接入 CDN 加速：

1. **记录类型**：CNAME
2. **IP 来源**：静态
3. **值**：填写 CDN 分配的 CNAME 地址（如 `xxx.example.com.w.kunluncan.com`）

## TTL 说明

TTL 支持多种格式：

| 格式 | 含义 | 示例 |
|------|------|------|
| 纯数字 | 秒数 | `600` |
| 带 `m` 后缀 | 分钟 | `10m` |
| 带 `h` 后缀 | 小时 | `1h` |

各服务商 TTL 限制：

| 服务商 | 最小 TTL | 默认值 | 备注 |
|--------|---------|--------|------|
| 阿里云 | — | 600 秒 | — |
| 腾讯云 | — | 600 秒 | — |
| 华为云 | 300 秒 | — | 低于 300 秒将自动调整 |
| 百度智能云 | 60 秒 | — | 最大 86400 秒 |
| Cloudflare | 60 秒 | — | 填 `1` 表示 Auto TTL |

## 参考文档

- [D-NET DDNS 使用指南](https://github.com/cxbdasheng/dnet/wiki/DDNS-%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97)
- [D-NET 项目](https://github.com/cxbdasheng/dnet)