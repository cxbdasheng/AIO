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
ESXi 中硬件直通是指 **单独将某个硬件以独占方式分配给某个虚拟机**，ESXi 的硬件直通功能相比 PVE 更加简洁易用，通过将物理硬件设备直接分配给虚拟机，可以获得接近原生的硬件性能。

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
修改成功后，请点击【重新引导主机】，这时主机会进行重启
![重新引导主机](https://img.it927.com/aio/297.png)
### 切换直通
重启完毕后，可看到之前的灰色按钮变为了蓝色可点击状态，点击【切换直通】
![切换直通](https://img.it927.com/aio/298.png)
切换直通后，可看到颜色变黄，还需【重新引导主机】，点击【重新引导主机】
![重新引导主机](https://img.it927.com/aio/299.png)
### 验证直通
不出意外重启后，能看到直通变为了【活动】，证明直通成功
![验证直通](https://img.it927.com/aio/301.png)
