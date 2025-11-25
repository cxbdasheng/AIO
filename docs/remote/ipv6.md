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
description: IPv6 DDNS 动态域名解析配置指南（文档编写中）
---

# IPv6 DDNS

!!! info "文档状态"
    本文档正在编写中，预计在 [D-NET](https://github.com/cxbdasheng/dnet) V2 版本发布时完善。

## 当前解决方案

在本文档完善之前，可以：

### 方案 1：使用 ddns-go

[ddns-go](https://github.com/jeessy2/ddns-go) 是一个简单好用的 DDNS 工具，支持多种服务商。

**快速使用**：
```bash
# Docker 方式运行
docker run -d \
  --name ddns-go \
  --restart unless-stopped \
  -p 9876:9876 \
  jeessy/ddns-go
```

访问 `http://localhost:9876` 进行配置。

### 方案 2：等待 D-NET V2

D-NET V2 将集成 DDNS 功能，提供更完整的动态网络管理方案。项目地址：[D-NET](https://github.com/cxbdasheng/dnet)
**D-NET V2 规划功能**：

- 自动检测 IPv6 地址变化
- 支持多种 DDNS 服务商
- 统一的 Web 管理界面
- 与 CDN 自动同步集成

## 参考文档

在等待本文档完善期间，可以参考：

- [ddns-go 官方文档](https://github.com/jeessy2/ddns-go)

## 预计更新时间

本文档将在 D-NET V2 正式发布后完善，预计包含：

1. 详细的配置步骤
2. 多种服务商配置示例
3. 常见问题解答
4. 最佳实践建议

!!! tip "关注更新"
    关注 [D-NET 项目](https://github.com/cxbdasheng/dnet) 获取最新动态。