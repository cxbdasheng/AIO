【开源自荐】D-NET 一款轻量级动态网络管理工具，支持多平台的 CDN、DNS 和 内网穿透自动化管理与监控

## 项目地址
[https://github.com/cxbdasheng/dnet](https://github.com/cxbdasheng/dnet)

## 主要功能
D-NET 一款轻量级动态网络管理工具，支持多平台的 CDN、DNS 和 内网穿透自动化管理与监控
### DCDN
**动态 CDN 管理 (DCDN)：** 能够自动监听本机 IPv6/IPv4 地址变化，直接将新的 IPv6/IPv4 设置到 CDN 回源的源站上。
优点：1.回源直接是 IP 地址，速度快，不需要多一次解析； 2.不会存在 DNS 解析延迟的情况。

目前已支持：阿里云（CDN、DCDN、ESA）、腾讯云（CDN、EdgeOne）、百度云（CDN、DRCDN）
例子：【】
### 其他功能模块
- **动态 DNS 管理 (DDNS)：** 自动更新域名解析记录（V2 版本规划中）
- **内网穿透管理：** 从外网访问内网服务（V3 版本规划中）
- **Webhook 通知：** 实时推送 IP 变更通知
- **Web 管理界面：** 可视化配置和管理

## 界面
![界面](https://raw.githubusercontent.com/cxbdasheng/dnet/refs/heads/main/dnet.png)
