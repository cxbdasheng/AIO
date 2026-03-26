---
slug: full-home-wifi-roaming
keywords:
  - 全屋网络覆盖
  - OpenWrt 无缝漫游
  - 802.11r
  - 802.11k
  - 802.11v
  - dumb AP
description: 用 OpenWrt 实现两个 AP 之间的 WiFi 无缝漫游，告别手机"死抱"信号差的 AP 不放手的问题。
---

# 全屋网络覆盖

都 2026 年了，不会还有人不知道"数据漫游"这东西吧？如果想简单组网，两个 WiFi 名称设置一样，那没有看这篇文章的必要了，陈大剩所说的全屋网络覆盖是指通过 OpenWrt 实现"数据漫游"，两个 AP 无缝衔接。

## 为什么同名 WiFi 不叫无缝漫游

很多人的解决方案是把两个路由器的 SSID 和密码设置一样，确实能连上，但问题在于**设备侧决定切换时机**。手机靠近副 AP 了，但信号还没差到让它主动切换，它就会死抱着主 AP 不放，直到信号差到掉线才切，这个过程网络会中断 1-3 秒，打游戏、视频通话直接感受到卡顿。

真正的无缝漫游需要三个协议配合：

| 协议 | 作用 |
|------|------|
| **802.11r**（Fast BSS Transition）| 切换 AP 时跳过重新认证，切换时间从几百毫秒压到 50ms 以内 |
| **802.11k**（Radio Resource Management）| AP 主动告知设备周边有哪些 AP 可用，帮设备找到更好的候选 |
| **802.11v**（BSS Transition Management）| AP 可以主动"劝说"设备切换到信号更好的 AP |

三个协议同时开，效果最好。

## 组网方案

我的方案是**主路由 + 副 AP**，通过网线做有线回程（Wired Backhaul），稳定性远强于无线回程。

```
光猫 ──── 主路由（OpenWrt，运行 DHCP） ──── 交换机 ──── 副 AP（OpenWrt，dumb AP 模式）
                                                    └──── 其他有线设备
```

- **主路由**：负责拨号、DHCP、防火墙，同时也是一个 AP
- **副 AP**：只做无线接入点，关掉 DHCP，桥接到主路由的网络，IP 固定用于管理

!!! tip "副 AP 用什么设备"
    刷了 OpenWrt 的旧路由器完全够用，不需要买专门的 AP。我用的是一台吃灰的小米路由器刷机，省钱又够用。

## 副 AP 配置（Dumb AP 模式）

先把副 AP 改成哑路由模式，这步一定要先做，否则两个 DHCP 服务器会打架。

!!! warning "网线插 LAN 口，不是 WAN 口"
    从交换机/主路由拉过来的网线，必须插副 AP 的任意一个 **LAN 口**。OpenWrt 默认 WAN 口是独立的 `wan` 接口，不在 LAN 桥里，插错口设备根本上不了网。

SSH 进副 AP，执行：

```bash
# 关闭 DHCP
uci set dhcp.lan.ignore=1
uci commit dhcp

# 关闭防火墙（dumb AP 不需要）
/etc/init.d/firewall stop
/etc/init.d/firewall disable

# 给副 AP 一个固定 IP，方便后续管理（根据你的网段修改）
uci set network.lan.ipaddr='192.168.1.2'
uci set network.lan.gateway='192.168.1.1'
uci set network.lan.dns='192.168.1.1'
uci commit network

/etc/init.d/network restart
```

之后用 `192.168.1.2` 访问副 AP 的管理界面。

## 开启 802.11r/k/v

主路由和副 AP 都要配置，且配置必须**完全一致**，否则漫游会出问题。

=== "LuCI 图形界面"

    进入 **Network → Wireless**，点击对应无线接口的 **Edit**，找到 **WLAN Roaming** 选项卡：

    - **802.11r Fast Transition**：勾选启用
    - **Mobility Domain**：填一个 4 位十六进制数，例如 `abcd`，主副 AP **必须相同**
    - **FT protocol**：选 `FT over the Air`（无需预配置密钥，更简单）
    - **802.11k Neighbor Report**：勾选启用
    - **802.11v BSS Transition**：勾选启用

=== "UCI 命令行"

    ```bash
    # 以 2.4G 接口为例，接口名根据实际情况修改（通常是 radio0 或 radio1）
    uci set wireless.@wifi-iface[0].ieee80211r=1
    uci set wireless.@wifi-iface[0].mobility_domain='abcd'
    uci set wireless.@wifi-iface[0].ft_over_ds=0
    uci set wireless.@wifi-iface[0].ft_psk_generate_local=1
    uci set wireless.@wifi-iface[0].ieee80211k=1
    uci set wireless.@wifi-iface[0].ieee80211v=1
    uci set wireless.@wifi-iface[0].bss_transition=1
    uci commit wireless
    wifi reload
    ```

    5G 接口同样操作，把 `wifi-iface[0]` 换成对应的接口索引。

!!! warning "Mobility Domain 必须两边一致"
    这个值如果主副 AP 不一样，802.11r 形同虚设，设备切换时还是要走完整认证流程。

## 调整 AP 发射功率

光配协议还不够，还要让设备"愿意"切换。两个 AP 覆盖范围如果重叠太多，设备没有切换动力；重叠太少，中间会有信号死角。

一般经验：

- 两个 AP 之间的**信号重叠区域**约占各自覆盖半径的 15%–20%
- 如果房子不大，主动降低发射功率（比如从 20dBm 降到 17dBm），让设备更早触发漫游
- 可以在 LuCI 的 **Wireless → Advanced Settings** 里调整 `Transmit Power`

## 验证漫游效果

手机连上 WiFi 后，从主 AP 走向副 AP，用以下方式验证：

**方法一：ping 测延迟**

```bash
# 手机上用 Network Analyzer 之类的 App，或电脑上 ping 网关
ping 192.168.1.1 -t
```

漫游时如果丢包不超过 1 个、延迟没有明显跳升，说明 802.11r 生效了。

**方法二：看关联 AP**

在主路由 LuCI 的 **Status → Overview** 或 **Network → Wireless** 页面，观察设备是否从主路由的关联列表消失，同时出现在副 AP 的关联列表里。

**方法三：抓包**（进阶）

用 Wireshark 抓 802.11 帧，看切换时是否有 `FT Action` 帧，有的话说明 Fast Transition 正常工作。

## 踩坑记录

**坑一：部分安卓设备不触发漫游**

某些安卓手机对 802.11v 的 BSS Transition Request 支持很差，AP 发劝离帧它直接忽略。这种情况只能靠降低发射功率，让信号差到触发设备自己切换，或者开启 `disassoc_low_ack`（超时未响应的客户端强制踢掉），这个选项在 UCI 里：

```bash
uci set wireless.@wifi-iface[0].disassoc_low_ack=1
uci commit wireless
wifi reload
```

**坑二：802.11r 与部分老设备不兼容**

开了 802.11r 之后，极少数老设备（主要是 IoT 设备，比如老款智能插座）会连不上。解法是单独为这些设备开一个不启用 802.11r 的 SSID，或者换一个频段（IoT 设备通常只支持 2.4G，5G 单独开漫游不影响它们）。

**坑三：有线回程和无线回程混用**

如果副 AP 是无线回程接入的（Mesh 模式），OpenWrt 的配置会更复杂，需要用 `relayd` 或 `batman-adv`，这篇就不展开了。有条件一定拉网线，省心。

## 总结

配完之后，手机从客厅走到卧室，WiFi 全程不断，连视频通话都感受不到切换，体验接近商用 AP 的 Mesh 方案，但成本低得多——两台刷了 OpenWrt 的旧路由器就够了。

核心要点：

- 副 AP 必须设为 dumb AP 模式，关掉 DHCP 和防火墙
- 802.11r 的 Mobility Domain 两边必须一致
- 802.11k + 802.11v 配合 802.11r 才能发挥最好效果
- 有线回程比无线回程稳定得多，能拉网线就拉网线