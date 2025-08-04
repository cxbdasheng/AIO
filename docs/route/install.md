---
keywords:
  - 软路由安装
  - OpenWrt安装
  - OpenWrt设置
  - 家庭All-in-One
  - ESXi环境搭建教程
  - 陈大剩的家庭AIO服务器
  - 家庭AIO服务器
description: 详细介绍如何使用StarWind V2V Converter将IMG等格式的镜像文件转换为ESXi支持的VMDK格式，包含完整的操作步骤和注意事项。
---
## 镜像准备
### **下载 OpenWrt 镜像**
LEDE 已经和 OpenWrt 合并了，所以现在的 OpenWrt 就是以前的 LEDE，OpenWrt 官方下载地址为：[OpenWrt](https://downloads.OpenWrt.org/releases/)，**推荐版本**（截止2025年07月30日）：[24.10.2](https://downloads.OpenWrt.org/releases/24.10.2/targets/x86/64/OpenWrt-24.10.2-x86-64-generic-squashfs-combined.img.gz)。

### **镜像格式转换**
1. **解压镜像**：将下载的 `.img.gz` 文件解压为 `.img` 格式；
2. **格式转换**：使用前面章节中的 [StarWind V2V Converter](../esxi/convert.md) 将 IMG 转换为 VMDK 格式；
3. **获得文件**：转换完成后会得到 `xxx.vmdk` 和 `xxx-flat.vmdk` 两个文件，上传至 ESXi 镜像文件夹中；

## ESXi 部署步骤
### **步骤 1：创建存储目录**

通过 ESXi 管理界面创建专用目录：

**导航路径**：【存储】→【数据存储】→【数据存储浏览器】

![创建目录](https://img.it927.com/aio/106.png)

1. 创建软路由专用目录，陈大剩这里教程为主路由，所以名字设置为`main-route`。 
2. 从镜像存储目录 `os` 中复制转换后的 VMDK 文件到 `main-route` 目录

![复制到文件夹](https://img.it927.com/aio/107.png)

???+ warning "警告"

    当不创建专用文件夹时，VMDK 镜像文件会被 ESXi 视为该 **虚拟机的专属文件**，**与虚拟机形成强绑定关系，后续其他虚拟机无法使用此镜像**，且删除虚拟机时，ESXi 会清理所有关联的文件。

### **步骤 2：创建虚拟机**
**导航路径**：【虚拟机】→【创建/注册虚拟机】，首先是简单的三个步骤。

=== "步骤 1：选择创建类型"

    ![选择创建类型](https://img.it927.com/aio/108.png)

=== "步骤 2：选择名称和操作系统"

    ![选择名称和操作系统](https://img.it927.com/aio/109.png)

=== "步骤 3：选择储存"

    ![选择名称和操作系统](https://img.it927.com/aio/110.png)

三个步骤完成后接下来是自定设置，由于陈大剩配置的是主路由，所以硬件分配会稍微高一点，大家可以根据自己的需求分配，自定义步骤比较多，如无需配置直通，后面两个步骤可跳过。
=== "自定设置 1：CPU"
 
    ![CPU](https://img.it927.com/aio/111.png)

=== "自定设置 2：内存"
    如果需要直通 PCI 设备，必须勾选 **预留客户机内存(全部锁定)**。
    ![内存](https://img.it927.com/aio/112.png)

=== "自定设置 3：删除不必要的配置"
    删除默认的硬盘、CD/DVD 驱动器等不需要的设备，保留必要的网络适配器（非必须）。
    ![删除不必要的配置](https://img.it927.com/aio/113.png)

=== "自定设置 4：添加硬盘"
    添加硬盘为镜像做准备，选择添加现有硬盘。
    ![添加硬盘](https://img.it927.com/aio/114.png)

=== "自定设置 5：添加镜像"

    ![添加镜像](https://img.it927.com/aio/115.png)

=== "自定设置 6：直通网卡"
    如需要直通网卡或其他设备，请选择【添加其他设备】-【PCI】设备，如非直通请忽略本步骤。
    ![直通网卡](https://img.it927.com/aio/118.png)

=== "自定设置 7：选择直通网卡"

    ![选择直通网卡](https://img.it927.com/aio/119.png)

自定义设置完了，还需要需要将【虚拟机选项设】固件选择为【BIOS】。
![固件选择](https://img.it927.com/aio/121.png)
最后，所有配置完成后，检查一遍，点完成。
![启用 UEFI 安全引导](https://img.it927.com/aio/117.png)

## 配置网络
点击【打开电源】启动 OpenWrt，系统启动完成后不会自动进入 Shell，需要手动按回车键，进入 Shell 控制台开始配置。
![进入 Shell](https://img.it927.com/aio/122.png)
**查看当前网络状态**：
```bash
# 查看网络接口
ip addr show
```
![查看网络接口](https://img.it927.com/aio/125.png)
如果像陈大剩上图的网络配置一样，**当前 br-lan 桥接接口中仅包含 `eth0` 网口**，直通的网卡未加入 br-lan 桥接接口，建议先将所有接口添加到桥接中，便于后续网线插任何网卡都能管理 OpenWrt。
```bash
# 查看当前网络配置
cat /etc/config/network
```
![查看网络](https://img.it927.com/aio/124.png)
这里问可以看到 br-lan 中只有 `eth0`。
### 网口配置桥接
如果我们将所有网口配置桥接 `br-lan` 上，那我们随便插哪个网口都能访问 OpenWrt 管理后台了,编辑 `/etc/config/network` 文件。
```bash
# 编辑当前网络配置
vim /etc/config/network
```
在 config device 下面添加两行，将两个直通端口加上
```bash
config device
    option name 'br-lan'
    option type 'bridge'
    list ports 'eth0'
    list ports 'eth1'    # 添加第一个直通网口
    list ports 'eth2'    # 添加第二个直通网口
```
![网口配置桥接](https://img.it927.com/aio/127.png)
不熟悉 `vim` 编辑器的网友可以查询 `vim` 如何保存和插入，保存结束后重启网络服务：
```bash
/etc/init.d/network restart
```
???+ info "提示"
    
    文本编辑器并不一定要用 `vim`，按照自己的使用习惯即可。

可以看到 **默认配置信息**：

- **LAN IP**：192.168.1.1
- **用户名**：root
- **密码**：无（首次登录需设置）

???+ info "提示"
    如果默认的 `192.168.1.1` 与其他网段冲突，可以进行修改，替换掉 `192.168.1.1`：
    ```bash
    # 编辑网络配置文件
    vim /etc/config/network
    # 替换掉 `192.168.1.1`
    # 重启网络服务
    /etc/init.d/network restart
    ```

### **Web 管理界面访问**
因为直通的两个网口都没有插网线，所以现在默认是空，我们需要按如下的步骤访问。

**访问步骤**：将连接 ESXi 管理网口的网线插到直通的网卡，将控制电脑的网络设置改为自动获取（DHCP），通过浏览器访问 OpenWrt 管理界面。

**访问信息**：

- **访问地址**：http://192.168.1.1
- **默认用户名**：root
- **密码**：首次登录时设置

![OpenWrt](https://img.it927.com/aio/126.png)
???+ warning "警告"

    插完网线后，控制电脑需要将原来的 ESXi 管理网口的静态 IP ，必须改为自动获取【DHCP】，才能访问 OpenWrt 管理界面。访问 ESXi 管理网口时必须再改回原来的静态 IP。

## 基础设置
进入 Web 管理界面后，可以看到直通的网口和虚拟交换机网口（10GbE），我们还要做一些基础设置。
![基础设置](https://img.it927.com/aio/128.png)
### 设置密码
进入管理页面后第一件事情，是设置密码，导航【System】-【Administration】输入两次密码后点击【Save】
![设置密码](https://img.it927.com/aio/129.png)

### 确定 WAN 和 LAN 口
因配置 [网口配置桥接](#_4) 将全部接口配置为 LAN 口，还需确认具体的 WAN，可以通过网卡的活跃度判断，插的那个网口。陈大剩这里 `eth1` 是现在插网线的网口（2.5G 网口），`eth2` 是直通的第二个 2.5G 网口，`eth0` 是虚拟交换机网口。 
![基础设置](https://img.it927.com/aio/130.png)
根据网络规划，`eth2` 配置为 WAN 口（连接上游网络），将 `eth0` 和 `eth1` 配置为 LAN 口。其中，`eth0` 和 `eth1` 通过桥接方式连接到 br-lan 接口，共同充当 LAN 接口。

接下来需要分别配置 WAN 和 LAN 接口：
=== "配置 WAN 口"
    导航【Network】-【Interfaces】将 【WAN】 口【Device】配置为 `eth2` 网口后点击 【Save】，如果有【WAN6】接口也，同样设置 `eth2` 即可。
    ![配置 WAN 口](https://img.it927.com/aio/131.png)

=== "配置 LAN 口"
    导航【Network】-【Devices】将 【br-lan】 配置成 `eth0` 和 `eth1`。
    ![配置 LAN 口](https://img.it927.com/aio/132.png)

=== "应用配置"
    完成 WAN 和 LAN 接口配置后，点击页面底部的【Save & Apply】按钮应用所有设置。
    ![配置 LAN 口](https://img.it927.com/aio/133.png)

点击【Save & Apply】后，系统会显示倒计时读秒。如果在读秒期间配置成功，页面将自动刷新；如果配置失败，系统将恢复到之前的配置状态。

不出意外的话，将一根联网的网线插入 WAN 口（`eth2`），OpenWrt 即可正常联网。

???+ info "配置建议"
    
    - WAN 和 LAN 口分配应根据实际网络需求调整
    - 建议至少保留一个 WAN 口用于上游网络连接
    - 配置前请确认网口物理连接状态

### **换源**
安装是默认使用的是国外源，导致有些镜像无法下载，需换国内源。 本教程使用清华源，换源方式可通过：界面换源、自动替换、手工替换这三种中随机一种换源，替换完后有网的情况下，可以 **更新一下软件包**。
#### 界面换源
导航 【System】-【Software】点击【Configure opkg】将【/etc/opkg/distfeeds.conf】框内容换成如下：
```shell
src/gz openwrt_core https://mirrors.ustc.edu.cn/openwrt/releases/24.10.2/targets/x86/64/packages
src/gz openwrt_base https://mirrors.ustc.edu.cn/openwrt/releases/24.10.2/packages/x86_64/base
src/gz openwrt_kmods https://mirrors.ustc.edu.cn/openwrt/releases/24.10.2/targets/x86/64/kmods/6.6.93-1-1745ebad77278f5cdc8330d17a3f43d6
src/gz openwrt_luci https://mirrors.ustc.edu.cn/openwrt/releases/24.10.2/packages/x86_64/luci
src/gz openwrt_packages https://mirrors.ustc.edu.cn/openwrt/releases/24.10.2/packages/x86_64/packages
src/gz openwrt_routing https://mirrors.ustc.edu.cn/openwrt/releases/24.10.2/packages/x86_64/routing
src/gz openwrt_telephony https://mirrors.ustc.edu.cn/openwrt/releases/24.10.2/packages/x86_64/telephony
```
![换源](https://img.it927.com/aio/134.png)
???+ info "注意"

    手动替换时一定要注意 CPU 架构一搬分为：x86、arm、mips、....，其中 x86 占据 90% 的市场。换源时一定要清楚 CPU 架构，不知道可直接百度查 CPU 型号。
#### 自动替换
自动替换需要 SSH 连接 OpenWrt，执行如下命令自动替换：
```shell
sed -i 's_downloads.OpenWrt.org_mirrors.tuna.tsinghua.edu.cn/OpenWrt_' /etc/opkg/distfeeds.conf
```
#### 手工替换
需要 SSH 连接 OpenWrt，并编辑 `/etc/opkg/distfeeds.conf` 文件，将其中的 `downloads.OpenWrt.org` 替换为 `mirrors.tuna.tsinghua.edu.cn/OpenWrt` 即可。
### 语言设置
如果此时 WAN 口已经连接了网线，可以将界面换为中文， 安装中文语言包，导航【System】-【Software】-【Filter】。

接着搜索：`base-zh-cn`，找到 **luci-i18n-base-zh-cn** 点击【Install】安装即可：
![语言设置](https://img.it927.com/aio/135.png)
安装完成后刷新浏览器页面，系统界面将切换为中文。
![语言设置](https://img.it927.com/aio/136.png)

### ttyd
如果不想每次通过 SSH 去连接软路由，则可以安装 ttyd 插件。
![ttyd](https://img.it927.com/aio/137.png)
安装完成后，直接导航【服务】-【终端】连接 OpenWrt。
![ttyd](https://img.it927.com/aio/138.png)
登录账号为：root；密码为之前 [软路由 - 设置密码](install.md#_6) 设置的密码。

## 网络实战
至此 OpenWrt 的安装全部结束，如只想看安装就到此结束了，有家庭网络需求，可以继续看前面的 [网络架构 - 网络拓扑实战](../network/fight.md)。