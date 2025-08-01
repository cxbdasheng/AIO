---
slug: OpenWrt-ipv6-config
keywords: 
  - OpenWrt IPv6配置
  - IPv6 PPPoE拨号
  - IPv6中继模式
  - 家庭网络IPv6部署
  - OpenWrt网络配置
  - 家庭AIO搭建教程
  - 家庭All-in-One搭建教程
description: 介绍OpenWrt中IPv6的配置方法，包括PPPoE拨号和中继模式两种场景，以及常见问题的解决方案。
---
本节适用于软路由 OpenWrt 以及其他类 OpenWrt 系统的 IPv6 配置。
## 前置准备工作
在开始IPv6配置之前，需要完成以下必备操作：
### 1. 删除 IPv6 ULA 前缀
导航至：【网络】-【接口】 - 【全局网络选项】，删除 **IPv6 ULA 前缀** 设置。

![删除IPv6 ULA前缀](https://img.it927.com/aio/147.png)

???+info "提示"
    ULA 地址用于在本地网络内进行设备间的通信，类似于 IPv4 的私有地址（如 192.168.x.x 或 10.x.x.x）

### 2. 禁用 IPv6 AAAA 记录过滤
导航至：【网络】-【DHCP/DNS】-【过滤器】，取消勾选 "过滤IPv6 AAAA记录"。

![禁用 IPv6 AAAA 记录过滤](https://img.it927.com/aio/148.png)
???+info "提示"
    AAAA 记录是 IPv6 的 DNS 记录类型，过滤此记录会阻止 IPv6 域名解析，导致无法访问支持 IPv6 的网站。

## 场景一：软路由 PPPoE 拨号获取 IPv6（24 小时不关机方案）
### 网络拓扑
```
光猫(桥接模式) → OpenWrt(PPPoE拨号) → 客户端设备
```
### 配置步骤
#### 1. 验证拨号状态
PPPoE 拨号成功后，系统会自动创建 `wan_6` 虚拟动态接口。理想状态下，该接口应具备：

- 一个 IPv6 地址
- 一个 IPv6-PD 前缀委托

![PPPoE拨号网络拓扑](https://img.it927.com/aio/149.png)
???+warning "故障排查"
    如果无 IPv6 地址和 IPv6-PD 前缀委托，通常是运营商问题，需要：
    
    1. 致电运营商客服确认是否开通 IPv6 服务
    2. 要求技术人员检查线路配置
    3. 部分地区可能需要重新签约或升级套餐

#### 2. 配置 LAN 接口
虽然 WAN 口已经有了 IPv6 ，但并未给 LAN 口分配，还需要配置 LAN 口 IPv6，导航至：【网络】-【接口】-【LAN】-【lan 编辑】-【高级设置】


**高级设置**：

- IPv6 分配长度：`64`
  - IPv6 后缀：`eui64` 或 `random`（推荐 random，避免地址被扫描）
  - 委托 IPv6 前缀：不勾选（如需向下级设备分发前缀请勾选）

![配置 LAN 接口](https://img.it927.com/aio/150.png)
???+ info "提示"
    如果下面的网段也需要分配 IPv6，则点击委托 IPv6 前缀，陈大剩实验室网段和预留网段并无 IPv6 要求，所以未勾选。

**防火墙设置**： 防火墙区域：`lan`

![防火墙设置](https://img.it927.com/aio/151.png)

#### 3. 配置 DHCP 服务器
导航【网络】-【接口】-【lan 编辑】-【DHCP 服务器】-【IPv6 设置】配置 lan 参数，IPv6 设置：

**IPv6设置**：

- RA服务：`服务器模式`
- 本地IPv6 DNS服务器：`不勾选`

![lan 参数](https://img.it927.com/aio/152.png)

导航【网络】-【接口】-【lan 编辑】-【DHCP 服务器】-【IPv6 RA 设置】：

1. RA 标记：无

![lan 参数](https://img.it927.com/aio/153.png)
???+info "提示"
    在 IPv6 路由器通告（Router Advertisement, RA）消息中，**标记**（Flags）是指示某些网络配置行为的重要部分。

    主要包含以下几个标记：

    -  M 位（Managed Address Configuration Flag）：指示主机是否应该使用 DHCPv6 来获取 IPv6 地址。
    - O 位（Other Configuration Flag）：指示主机是否应使用 DHCPv6 获取其他配置选项（如 DNS 服务器）。

    DHCPv6 目前并不好用（前缀更新不能主动推送到局域网设备），即使关闭后  Windows 还是会主动找 DHCPv6 获取 IPv6 地址，而且安卓并不支持 DHCPv6 。
 
#### 4. 应用配置
点击保存并应用（可重启），LAN 接口上就会出现 IPv6 地址（24开头）
![保存并应用](https://img.it927.com/aio/154.png)
#### 5. 验证客户端连接
OpenWrt 已经设置好了 IPv6 地址，接下来是验证客户端的连接，Windows 点击网络适配器禁用启用或重启拔插网线，就可以查看 IPv6 地址了。
![验证客户端连接](https://img.it927.com/aio/155.png)
???+info "提示"
    如客户端未看到 IPv6 地址，请检查客户端是否开启 IPv6 协议。

## 场景二：软路由路由模式获取 IPv6（下级路由方案）
### 网络拓扑
```
上级路由器/光猫(PPPoE拨号) → OpenWrt(软路由-路由模式) → 客户端设备
```

在此模式下，OpenWrt 充当下级路由器，且上级路由器需要开启委托 IPv6 前缀，也就上级路由器需 [配置 LAN 接口 - 委托 IPv6 前缀](#2-lan) 功能。
### 配置步骤
#### 1. 创建 DHCPv6 接口

导航【网络】- 【接口】- 【添加新接口】

- 接口名称：`wan6`
- 协议：`DHCPv6客户端`
- 设备：选择 WAN 口对应的物理接口

![创建 DHCPv6 接口](https://img.it927.com/aio/157.png)
#### 2. 配置防火墙
导航【网络】- 【接口】- 【wan6 编辑】-【防火墙设置】：防火墙设置为 `wan` 区域
![配置防火墙](https://img.it927.com/aio/158.png)
#### 3. 检查 IPv6-PD 状态
配置完成后，检查是否获得 **IPv6-PD 前缀委托** 前缀委托：

**情况A：成功获得PD前缀**
![IPv6-PD 前缀委托](https://img.it927.com/aio/160.png)
如果下发了则比较幸运，按照之前 [配置 LAN 接口](#2-lan) 配置就行。

**情况B：未获得PD前缀**
![检查 IPv6-PD 状态](https://img.it927.com/aio/159.png)

如果未下发 **IPv6-PD 前缀委托**，说明 光猫/路由器 没有继续向下级路由器发生 **PD 前缀委托**，那么只能采取：

1. 路由器/光猫 进行桥接，OpenWrt 进行拨号，参考 [场景一：软路由 PPPoE 拨号获取 IPv6（24 小时不关机方案）](#pppoe-ipv624)；
2. 路由器/光猫 进行拨号，OpenWrt 中继（纯交换机，无法控制网络），参考 [场景三：软路由中继模式获取 IPv6（24 小时随时开机方案）](#ipv624)；
3. 找宽带运营商或者自行换购另一款 路由器/光猫；

## 场景三：软路由中继模式获取 IPv6（24 小时随时开机方案）
建议上级路由也是一台软路由，否则软路由（OpenWrt）只能当傻瓜交换机，无法控制网络。
### 网络拓扑
```
上级路由器/光猫(PPPoE拨号) → OpenWrt(软路由-中继模式) → 客户端设备
```
### 配置步骤
#### 1. 配置 wan6 接口
导航【网络】-【接口】-【wan6 编辑】，修改 `wan6` 为中继模式。
???+ info "提示"
    没有 `wan6` 接口，可按照 [场景二：软路由路由模式获取 IPv6（下级路由方案）- 1. 创建 DHCPv6 接口](#1-dhcpv6) 创建 `wan6` 接口。

![配置 wan6 接口](https://img.it927.com/aio/161.png)

???+info "提示"
    1. **主接口** 在多接口环境中，主接口是系统默认使用的接口，用于发送和接收 IPv6 路由器通告（RA）和其他 IPv6 流量。
    2. **RA 服务**（Router Advertisement Service）是指路由器通过发送路由器通告（RA）消息来广播网络参数和配置信息的功能。
    3. **NDP 代理**（Neighbor Discovery Protocol Proxy）是指在 IPv6 网络中，一种允许路由器充当中介，帮助主机在不同子网之间发现邻居设备的功能。

#### 2. 配置 LAN 接口
导航【网络】-【接口】-【lan 编辑】-【DHCP 服务器】-【IPv6 设置】，设置 lan 口 DHCP 服务器 设计为中继模式
![配置 LAN 接口](https://img.it927.com/aio/162.png)
#### 3. 应用配置
点击保存并应用（可重启），重启电脑网络接口，查看是否拥有 IPv6。
![应用配置](https://img.it927.com/aio/163.png)

## 总结
IPv6 配置的成功很大程度上取决于网络环境和上级设备的支持情况。PPPoE 拨号模式提供最佳的控制能力和稳定性，应作为首选方案。在实际部署时，建议根据具体环境选择合适的配置方案，并做好充分的测试验证。