---
slug: bios-settings
keywords: 
  - 家庭AIO BIOS 设置指南
  - 家庭AIO设置指南
  - 家庭AIO搭建教程
  - 家庭All-in-One搭建教程
description: 在安装系统前，需要设置 BIOS。由于不同主板的 BIOS 设置大同小异，很难详细展开说明，因此我们主要关注以下几个相关选项。
---
## BIOS 设置指南
在安装系统前，需要设置 BIOS。由于不同主板的 BIOS 设置大同小异，很难详细展开说明，因此我们主要关注以下几个相关选项：

- [x] **开启** Intel VMX 虚拟化技术（PCIe 硬件直通必须）
- [x] **开启** VT-d（PCIe 硬件直通必须）
- [x] **开启** SR-IOV 网卡虚拟化技术 （高效先进的虚拟机网卡技术）
- [x] **开启** Above 4G  Decoding（vGPU 方案需要开启这个选项）
- [x] **开启** Numa （多路 CPU 建议开启，提高多路 CPU 运行效率，合理分配负载）
- [x] **开启** x2APIC（PCIe 硬件直通需要）
- [x] **开启** 来电启动（远程开机需要）

以华南主板为例，**首先恢复出厂设置** 后，`VMX`、`VT-d` 和 `Numa` 都是满足要求的，我只需要设置其他选项即可，如果你的也是华南主板，请按照以下步骤进行设置：
???+ info

      华南金牌主板的操作手册可在：[下载中心-华南金牌官网](http://www.huananzhi.com/download1.php?lm=13) 处下载，BIOS 说明书可在：[服务支持-华南金牌官网](http://www.huananzhi.com/sc.php?lm=18) 处下载。

## 开启 Above 4G  Decoding

vGPU 方案需要开启 4G 以上解码，没有 vGPU 的使用需求不打开也是没问题的。以我的华南主板为例，在【Advenced】-【PCI Subsustem Settings】里面可以打开 **Above 4G Decoding** 选项。
![Above 4G Decoding](https://img.it927.com/aio/16.png)


## 开启 SR-IOV
以华南主板为例，在【Advenced】-【PCI Subsustem Settings】里面可以打开 **SR-IOV** 选项：

![开启 SR-IOV](https://img.it927.com/aio/17.png)
???+ info

    全称是 `Single Root IO Virtualization Support` 是一种高效先进的虚拟网卡技术。一个物理网卡可以虚拟出来多个轻量化的PCI-e 物理设备，从而可以分配给虚拟机使用。启用 SR-IOV 的这个功能，将大大减轻宿主机的CPU负荷，提高网络性能，降低网络时延等。
## 开启 x2APIC

华南主板为例，在 【InterRCSetup】 - 【Processor Configuration】 里面可以打开 **X2APIC** 选项：

![开启 x2APIC](https://img.it927.com/aio/18.png)

???+ info

    x2APIC 是 x86 平台处理中断的机制，是之前 xAPIC 的替代品，再之前是 Intel® 82489DX external APIC。x2APIC 支持帮助操作系统以较高的内核数配置更高效地运行，并优化虚拟化环境中的中断分配。


!!! warning "如果开启后，通过命令检测如果依然没有工作在 X2APIC 模式的情况下，请尝试**关掉**下面的「X2APIC_OPT_OUT_Flag」选项" 

## 开启来电启动
设置好来电启动后，只要电源通电主机就会自动开机，这个能配合后面的小米智能插座进行远程开机。华南主板为例，在 【InterRCSetup】 - 【PCH Configuration】-【PCH Devices】-【Restore AC after Power Loss】 里面可以选择 **Power On** （来电启动）选项：
![开启来电启动](https://img.it927.com/aio/24.png)

???+ info

    “来电启动”（也称为 PWRON After PWR-Fail 或 AC Power Recovery）是指在计算机意外断电后，当电源恢复时，计算机自动开机的功能。