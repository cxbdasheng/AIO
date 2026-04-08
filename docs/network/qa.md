---
slug: network-troubleshooting
keywords:
  - ESXi网络故障排查
  - 家庭AIO网络问题
  - 虚拟机无法联网
  - ESXi网络优化
  - 软路由网络故障
  - 网络丢包排查
  - iperf3测速
  - ESXi网络性能优化
description: 总结家庭 AIO 环境中常见的网络故障场景与排查思路，涵盖虚拟机无法联网、网速异常、DNS 解析失败、VLAN 不通等问题，并提供实用的网络优化建议。
---

# 网络故障排查与优化

网络问题是 AIO 搭建过程中最让人抓狂的部分。症状千奇百怪，有时候重启一下就好了，有时候找半天才发现是个配置写错了。这篇文章把我踩过的坑和排查思路都整理出来，希望能帮你少走弯路。

---

## 排查思路：先分层再排查

网络是分层的，排查问题也要从下往上来，不要上来就怀疑软件配置，先把硬件和链路确认了。

```mermaid
flowchart LR
    A["物理层<br/>网线、网卡、交换机"]
    B["ESXi 虚拟网络层<br/>vSwitch、端口组"]
    C["软路由层<br/>OpenWRT / iKuai 路由配置"]
    D["虚拟机操作系统层<br/>IP、DNS、防火墙"]
    E["应用层<br/>服务端口、代理、证书"]

    A --> B --> C --> D --> E

    style A fill:#f5f5f5,stroke:#999
    style B fill:#e8f4fd,stroke:#5b9bd5
    style C fill:#e8f4fd,stroke:#5b9bd5
    style D fill:#e8f4fd,stroke:#5b9bd5
    style E fill:#f0f9eb,stroke:#70b869
```

每一层都有对应的检查方法，下面分场景展开。

## 常用诊断工具

在开始之前，先认识几个必备工具：

=== "Linux / OpenWRT"

    ```bash
    # 查看 IP 和接口状态
    ip addr
    ip link show

    # 连通性测试
    ping 192.168.1.1
    ping 8.8.8.8

    # 路由追踪（找到哪一跳断了）
    traceroute 8.8.8.8

    # DNS 解析测试
    nslookup baidu.com
    dig baidu.com @114.114.114.114

    # 端口联通测试
    nc -zv 192.168.1.1 80
    curl -v http://192.168.1.1

    # 网速测试（需先安装 iperf3）
    iperf3 -s          # 服务端
    iperf3 -c <IP>     # 客户端
    ```

=== "Windows"

    ```powershell
    # 查看网络接口
    ipconfig /all

    # 连通性测试
    ping 192.168.1.1
    ping 8.8.8.8

    # 路由追踪
    tracert 8.8.8.8

    # DNS 解析测试
    nslookup baidu.com

    # 端口联通测试
    Test-NetConnection -ComputerName 192.168.1.1 -Port 80
    ```

=== "ESXi"

    ESXi 本身提供了 `esxcli` 命令行工具，可以在 SSH 进入后使用：

    ```bash
    # 查看物理网卡状态
    esxcli network nic list

    # 查看虚拟交换机
    esxcli network vswitch standard list

    # 查看端口组
    esxcli network vswitch standard portgroup list

    # 测试连通性（ESXi 自带 ping）
    vmkping 192.168.1.1

    # 查看 VMkernel 接口
    esxcli network ip interface list
    ```

---

## 场景一：虚拟机无法联网

这是最常见的问题，刚装好的虚拟机死活上不了网。

### 检查步骤

**第一步：确认虚拟机有没有拿到 IP**

```bash
ip addr show
```

- 如果没有 IP（或只有 `169.254.x.x` 这种自动私有地址）→ DHCP 没拿到，往下查
- 如果有正常 IP → 跳到「有 IP 但不通」部分

**第二步：检查端口组配置**

进入 ESXi 管理界面，确认虚拟机所在的**端口组**：

1. 是否绑定了正确的虚拟交换机？
2. VLAN ID 是否配置正确？（`0` 表示不使用 VLAN，设错了会导致流量进入错误网段）

!!! warning "VLAN ID 设错是高频坑"
    如果你的软路由对某个网口启用了 VLAN，而 ESXi 端口组的 VLAN ID 没有对应上，虚拟机就完全拿不到 IP。两边必须一致。

**第三步：确认 DHCP 服务正常**

登录软路由管理界面，检查对应接口的 DHCP 服务是否开启，以及是否有可用的 IP 地址池。

**第四步：检查虚拟机网卡是否连接**

在 ESXi 虚拟机设置里，确认网络适配器的「已连接」选项是勾选状态。有时候克隆的虚拟机这个选项会被自动取消。

### 有 IP 但不通

如果虚拟机有 IP，但 ping 网关不通：

```bash
# 先确认网关地址
ip route show

# ping 网关
ping 192.168.x.1
```

- ping 网关不通 → 问题在 ESXi 虚拟网络层或软路由，检查端口组和路由配置
- ping 网关通但 ping 8.8.8.8 不通 → 问题在软路由的 WAN 侧或上游
- ping 8.8.8.8 通但域名解析失败 → DNS 问题，见「场景三」

---

## 场景二：网速异常（慢/丢包）

### 用 iperf3 定位瓶颈

iperf3 是最好用的内网测速工具。在两台机器上分别运行：

```bash
# 机器 A（服务端）
iperf3 -s

# 机器 B（客户端）
iperf3 -c <机器A的IP> -t 30
```

逐段测试，缩小范围：

```
虚拟机 A ↔ 同宿主机虚拟机 B（同 vSwitch）→ 测内部交换性能
虚拟机 A ↔ 物理机（跨 vSwitch）→ 测 ESXi 网络转发
虚拟机 A ↔ 外网设备 → 测 WAN 侧
```

### 常见原因

**1. 网卡协商速度不对**

进入 ESXi → 网络 → 物理网卡，检查实际速率是否符合预期（比如千兆网卡应该显示 1000 Mbps）。

如果协商速度不对，可能是网线质量差或者交换机端口问题。

**2. MTU 不一致导致丢包**

MTU 设置不一致会导致大包丢失，表现为小数据包通但文件传输或视频卡顿。

```bash
# 测试 MTU（逐步减小直到不丢包）
ping -M do -s 1472 8.8.8.8   # Linux
ping -f -l 1472 8.8.8.8      # Windows
```

!!! tip "MTU 推荐值"
    - 普通以太网：1500
    - PPPoE 拨号：1492（需要减去 PPPoE 头）
    - 启用了 VXLAN/隧道：根据实际情况降低，通常 1400-1450

**3. 虚拟机网卡驱动问题**

推荐在 ESXi 虚拟机中使用 `VMXNET3` 网卡类型，性能远优于 E1000/E1000e。新建虚拟机默认就是 VMXNET3，老虚拟机可以手动更换（需要重新安装驱动）。

**4. ESXi 宿主机 CPU 打满**

网络转发也会消耗 CPU。如果宿主机 CPU 使用率高，也会影响网络性能。可以在 ESXi 监控界面确认。

---

## 场景三：DNS 解析失败

表现：能 ping 通 IP，但 `ping baidu.com` 报 `Name or service not known`。

### 排查步骤

```bash
# 查看当前 DNS 配置
cat /etc/resolv.conf

# 手动指定 DNS 测试
dig baidu.com @114.114.114.114
dig baidu.com @8.8.8.8
```

- 手动指定 DNS 能解析 → 当前 DNS 服务器有问题，检查软路由的 DNS 设置
- 手动指定也不能解析 → 网络本身有问题，先解决连通性

**软路由 DNS 常见问题：**

1. OpenWRT 的 DNS 转发（dnsmasq）配置错误
2. 使用了 OpenClash 等代理工具，导致 DNS 被劫持或循环
3. 软路由防火墙规则屏蔽了 53 端口的 UDP 流量

!!! note "OpenClash 用户注意"
    启用 OpenClash 后，DNS 流量会经过 Clash 的 DNS 模块处理。如果配置了 Fake-IP 模式，部分场景下内网域名解析可能出问题。建议把内网域名加入 DNS 白名单或绕过规则。

---

## 场景四：跨 VLAN 不通

在本教程的网络拓扑中，不同 VLAN（如管理网段和普通虚拟机网段）之间需要通过软路由做三层转发。如果 VLAN 间不通，按以下步骤排查：

**1. 确认软路由接口配置**

软路由上必须有对应 VLAN 的接口，并配置了 IP 地址（作为该 VLAN 的网关）。

**2. 确认路由规则**

```bash
# 在软路由上查看路由表
ip route show

# 确认目标网段有路由
ip route get 192.168.20.1
```

**3. 检查防火墙规则**

OpenWRT 的防火墙默认会阻止部分跨区域流量。需要在防火墙规则中允许对应的 VLAN 区域互访。

**4. 确认 ESXi 端口组 VLAN 设置**

不同 VLAN 的虚拟机必须分配在不同 VLAN ID 的端口组上，否则它们实际上在同一个二层网络，VLAN 隔离失效。

---

## 场景五：外网访问不稳定

主要表现：DDNS 可以访问但时不时断开，或者延迟不稳定。

### 可能原因

**1. IPv6 地址变化未及时更新**

DDNS 依赖 IPv6 地址，运营商重新拨号后地址变化，DDNS 脚本未能及时更新。建议把 DDNS 更新频率设置为 1-5 分钟，并检查脚本日志确认是否正常运行。

**2. 运营商 QoS 限速**

部分运营商会对家宽上行流量做 QoS，高峰期速度会大幅下降。可以通过在非高峰期测速对比来验证。

**3. MTU 导致的大包丢失**

远程访问时大文件传输失败，但小请求正常，通常是 MTU 问题。参考「场景二」中的 MTU 测试方法。

---

## 网络优化建议

### 启用 TSO/LRO 卸载

VMXNET3 支持 TCP Segmentation Offload（TSO）和 Large Receive Offload（LRO），可以将部分 TCP 处理工作卸载到网卡，减少 CPU 负担。

在 Linux 虚拟机中确认状态：

```bash
ethtool -k eth0 | grep offload
```

一般默认已开启，如果没有可以手动启用：

```bash
ethtool -K eth0 tso on
ethtool -K eth0 lro on
```

### 合理规划 VLAN

从一开始就规划好 VLAN，比后期改动要省事得多。建议按用途划分：

| VLAN ID | 用途 | 网段示例 |
|---------|------|---------|
| 1 | ESXi 管理 | 192.168.1.0/24 |
| 10 | 家庭设备 | 192.168.10.0/24 |
| 20 | 服务器/虚拟机 | 192.168.20.0/24 |
| 30 | IoT 设备（隔离） | 192.168.30.0/24 |

### 避免 DHCP 冲突

一个网段内只能有一个 DHCP 服务器。常见的多 DHCP 场景：

- ESXi 管理网络和某个虚拟机都开了 DHCP 服务
- 软路由的多个接口意外桥接在同一 vSwitch

出现 IP 冲突时，可以在软路由日志里搜索 DHCP 相关记录，找到多余的 DHCP 服务并关闭。

### 定期检查网卡日志

```bash
# Linux 查看网卡错误
ethtool -S eth0 | grep -i error
ip -s link show eth0

# 查看系统日志中的网络错误
dmesg | grep -i eth
journalctl -k | grep -i network
```

如果 `RX errors` 或 `TX errors` 持续增加，通常是物理链路问题（网线、网卡或交换机端口）。

---

## 快速排查清单

遇到网络问题时，可以按这个顺序快速过一遍：

- [ ] 物理网线是否插好，交换机端口指示灯是否正常
- [ ] ESXi 物理网卡协商速率是否正确
- [ ] 虚拟机所在端口组的 VLAN ID 是否正确
- [ ] 虚拟机网卡是否处于「已连接」状态
- [ ] 虚拟机是否拿到了正确网段的 IP
- [ ] 能否 ping 通网关
- [ ] 能否 ping 通 8.8.8.8
- [ ] DNS 解析是否正常
- [ ] 软路由防火墙是否有阻断规则
- [ ] 是否有多个 DHCP 服务器冲突
