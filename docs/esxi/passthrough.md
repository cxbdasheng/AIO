---
keywords:
  - ESXi硬件直通教程
  - ESXi PCI设备直通
  - ESXi网卡直通
  - ESXi显卡直通
  - ESXi直通配置
  - 虚拟化硬件直通
  - ESXi设备管理
  - 家庭All-in-One
  - ESXi环境搭建教程
  - 陈大剩的家庭AIO服务器
  - 家庭AIO服务器
  - RTL8125网卡直通
description: 详细介绍ESXi硬件直通配置方法，包括网卡、显卡等PCI设备的直通操作步骤，让虚拟机获得更好的硬件性能。
---
ESXi 硬件直通功能允许 **将物理硬件设备独占分配给虚拟机**，相比 PVE 更加简洁易用，可获得接近原生的硬件性能。

## 直通配置入口
通过以下路径进入硬件直通配置页面：
**导航路径**：【主机】→【管理】→【硬件】→【PCI 设备】
![ESXi 直通](https://img.it927.com/aio/103.png)
在此页面可以查看所有可用的 PCI 设备列表，包括网卡、显卡、声卡等硬件设备。
???+ info "提示"

    设备查找技巧：

    - **已知型号**：点击右上角搜索框，输入具体硬件型号
    - **未知型号**：通过设备类型和厂商信息逐一筛选。

###  **常见设备识别**
| 设备类型        | 常见标识 | 示例                 |
|-------------|----------|--------------------|
| 网卡          | Network Controller | RTL8125、INTEL I350 |
| 显卡          | Display Controller | NVIDIA、AMD         |
| 声卡          | Audio Device | Realtek Audio      |
| 板载 SATA 控制器 | AHCI Controller | AHCI      |
| USB控制器      | USB Controller | xHCI、EHCI          |

## 直通板载网卡
以 RTL8125 千兆网卡为例，演示直通配置过程：
=== "步骤 1：搜索设备"

    在搜索框中输入 `RTL8125`，找到目标设备后，点击左上角的【切换直通】按钮。
    ![直通板载网卡](https://img.it927.com/aio/104.png)

=== "步骤 2：启用直通"
    配置成功后，直通状态会显示为【活动】，表示该设备已可用于虚拟机分配。
    ![成功直通网卡](https://img.it927.com/aio/105.png)

???+ warning "警告"
    如果直通管理网卡，可能导致无法远程管理 ESXi，所以至少保留一个网卡用于 ESXi 管理。

直通完成后，即可在其他虚拟机中添加【PCI 设备】方式引入直通。

## 直通板载 SATA 控制器
因 ESXi 不能针对某个特定硬盘直通，只能直通 SATA 控制器，所以我们只能直通 SATA 控制器。通过搜索【AHCI】发现 SATA 控制器无法点击直通。
![SATA](https://img.it927.com/aio/296.png)
这是因为 ESXi 默认禁止了 SATA 控制器直通，需 [SSH](../preparation/base-settings.md#ssh) 连接上 ESXi 服务器中，查找 SATA 控制器
```shell
lspci -v | grep "Class 0106" -B 1  
```
可以看到输出如下：其中 8086：供应商 ID；8d62：设备 ID；
```base
0000:00:11.4 Mass storage controller SATA controller: Intel Corporation Wellsburg AHCI Controller 
	 Class 0106: 8086:8d62
```
### 修改 passthru.map
`passthru.map` 是 VMware ESXi 中一个可选的配置文件，用于定义哪些 PCI 设备可以被配置为 PCI 设备直通（PCI Passthrough），以便直接分配给虚拟机使用，编辑 `passthru.map`。
```shell
vim /etc/vmware/passthru.map
```
再最后的行后添加：
```shell
# Intel Corporation Lynx Point AHCI Controller
# 供应商ID PCLE_ID
8086  8d62   d3d0    false
```
### 切换直通
修改成功后，请点击【重新引导主机】，这时主机会进行重启
![重新引导主机](https://img.it927.com/aio/297.png)
重启完毕后，可看到之前的灰色按钮变为了蓝色可点击状态，点击【切换直通】
![切换直通](https://img.it927.com/aio/298.png)
切换直通后，可看到颜色变黄，还需【重新引导主机】，点击【重新引导主机】
![重新引导主机](https://img.it927.com/aio/299.png)
### 验证直通
不出意外重启后，能看到直通变为了【活动】，证明直通成功
![验证直通](https://img.it927.com/aio/301.png)

## GPU 直通（显卡）
GPU 直通可让虚拟机获得接近原生的显卡性能，适用于游戏、AI 计算、视频编码等场景。
### 禁用 ESXi 显卡占用
单显卡 AIO 服务器通常无法直接直通显卡，因为被 ESXi 系统占用。可通过 SSH 禁用 ESXi 显卡占用：
```bash
# 禁用显卡占用
esxcli system settings kernel set -s vga -v FALSE
# 重新启用
esxcli system settings kernel set -s vga -v TRUE
```
???+ warning "注意"
    禁用后将无法通过显示器查看 ESXi 控制台，只能通过 SSH 管理，无法使用 `F2` 进行系统设置。

### 查找显卡设备
在 PCI 设备列表中搜索对应显卡：
- **NVIDIA 显卡**：搜索 `NVIDIA` 或 `GeForce`
- **AMD 显卡**：搜索 `AMD` 或 `Radeon`  
- **Intel 核显**：搜索 `Intel` 和 `Display`

### 启用显卡直通
1. 找到目标显卡设备，点击【切换直通】
2. 状态变为【活动】后，重新引导主机
3. 重启完成后即可在虚拟机中添加该 PCI 设备

![显卡设备](https://img.it927.com/aio/391.png)
一张显卡通常包含两个设备：视频输出和音频控制器，建议同时启用直通并分配给同一虚拟机。
???+ warning "注意事项"
    - 直通显卡后，ESXi 主机无法使用该显卡输出
    - 建议保留一个显示设备用于 ESXi 管理（如核显）
    - 某些显卡可能需要额外驱动支持

## 直通 USB 控制器
主板中的 USB 控制器一般为 **EHCI** 或 **xHCI**，直通后该控制器的所有 USB 接口都归虚拟机使用。
![硬件直通 - 直通 USB 控制器](https://img.it927.com/aio/394.png)
???+info "提示"
    主板通常有一个 xHCI 控制器。ESXi 默认禁用 USB 控制器直通（显示为灰色）。

    **EHCI**：Enhanced Host Controller Interface，Intel 主导的 USB2.0 控制器接口标准。
    
    **xHCI**：eXtensible Host Controller Interface，目前主流的 USB3.0 控制器标准，在速度、能效和虚拟化方面性能更佳，支持所有速度的 USB 设备。

#### 开启 xHCI 直通
修改 passthru.map 文件：
```shell
vi /etc/vmware/passthru.map
```
在文件末尾添加：
```
# Intel Corporation 8 Series/C220 Series Chipset Family USB xHCI
# 供应商ID PCLE_ID
8086  8d31  d3d0     default
```
修改后按照 [硬件直通 - 切换直通](#_4) 操作，USB 控制器状态显示为"活跃"即表示直通成功，可将此控制器分配给虚拟机。
![直通 USB 控制器](https://img.it927.com/aio/395.png)

## 直通单独的 USB 设备（鼠标键盘）
与直通整个 USB 控制器不同，有时我们只需要直通特定的 USB 设备（如键盘鼠标）。ESXi 支持单独设备直通，但配置稍显复杂。
### 查询设备 PID 和 VID
开启 SSH 功能（参考 [基础设置 - 开启 SSH](../preparation/base-settings.md#ssh)），连接后查询设备信息：
```shell
[root@localhost:~] lsusb
Bus 001 Device 001: ID 0e0f:8003 VMware, Inc. Root Hub
Bus 002 Device 001: ID 0e0f:8002 VMware, Inc. Root Hub
Bus 001 Device 002: ID 0c45:6510 Microdia
Bus 002 Device 002: ID 8087:8002 Intel Corp. 8 channel internal hub
Bus 001 Device 003: ID 24ae:1008 Shenzhen Rapoo Technology Co., Ltd.
```
如不确定哪个是目标设备，可拔掉鼠标键盘后重新执行 `lsusb` 对比：
```shell
Bus 001 Device 002: ID 0c45:6510 Microdia
Bus 001 Device 003: ID 24ae:1008 Shenzhen Rapoo Technology Co., Ltd.
```
### 添加到虚拟机
在目标虚拟机中添加设备 ID：【编辑虚拟机】→【虚拟机选项】→【高级】→【编辑配置】→【添加参数】：
```shell
# 键盘
usb.quirks.device0 0x0c45:0x6510 allow
# 鼠标
usb.quirks.device1 0x24ae:0x1008 allow
```
![添加参数](https://img.it927.com/aio/398.png)
### 修改 ESXi Config 配置
编辑 ESXi 配置文件：
```shell
vi /etc/vmware/config
```
在文件末尾添加：
```
usb.quirks.device0="0x0c45:0x6510 allow"
usb.quirks.device1="0x24ae:0x1008 allow"
```
### 修改 ESXi boot 配置
修改启动引导文件 /bootbank/boot.cfg，禁用 ESXi 对键盘鼠标的控制权，编辑 boot 文件:
```shell
vi /bootbank/boot.cfg
```
在 kernelopt 行末尾添加：
```shell
# 在 kernelopt= 行末尾添加：
CONFIG./USB/quirks=0x24ae:0x4025::0xffff:UQ_KBD_IGNORE:0x0101:0x0007::0xffff:UQ_KBD_IGNORE
```