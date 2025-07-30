---
keywords:
  - 软路由安装
  - openWrt安装
  - openWrt设置
  - 家庭All-in-One
  - ESXi环境搭建教程
  - 陈大剩的家庭AIO服务器
  - 家庭AIO服务器
description: 详细介绍如何使用StarWind V2V Converter将IMG等格式的镜像文件转换为ESXi支持的VMDK格式，包含完整的操作步骤和注意事项。
---
## 镜像准备
### **下载 OpenWrt 镜像**
LEDE 已经和 OpenWrt 合并了，所以现在的 OpenWrt 就是以前的 LEDE，OpenWrt 官方下载地址为：[OpenWrt](https://downloads.openwrt.org/releases/)，**推荐版本**（截止2025年07月30日）：[24.10.2](https://downloads.openwrt.org/releases/24.10.2/targets/x86/64/openwrt-24.10.2-x86-64-generic-squashfs-combined.img.gz)。

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

### **步骤 2：创建虚拟机**
**导航路径**：【虚拟机】→【创建/注册虚拟机】，首先是简单的三个步骤。

=== "步骤 1：选择创建类型"

    ![选择创建类型](https://img.it927.com/aio/108.png)

=== "步骤 2：选择名称和操作系统"

    ![选择名称和操作系统](https://img.it927.com/aio/109.png)

=== "步骤 3：选择储存"

    ![选择名称和操作系统](https://img.it927.com/aio/110.png)

三个步骤完成后接下来是自定设置，由于陈大剩配置的是主路由，所以硬件分配会稍微高一点，大家可以根据自己的需求分配。
=== "自定设置 1：CPU"
 
    ![CPU](https://img.it927.com/aio/111.png)

=== "自定设置 2：内存"
    如果需要直通 PCI 设备，必须勾选 **预留客户机内存(全部锁定)**。
    ![CPU](https://img.it927.com/aio/112.png)

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

# 查看当前网络配置
cat /etc/config/network
```
![查看网络](https://img.it927.com/aio/124.png)
可以看到 **默认配置信息**：

- **LAN IP**：192.168.1.1
- **用户名**：root
- **密码**：无（首次登录需设置）

???+ info "提示"
    如果默认的 `192.168.1.1` 与其他网段冲突，可以进行修改：
    ```bash
    # 编辑网络配置文件
    vi /etc/config/network
    
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

???+ warning "警告"

    插完网线后，控制电脑需要将原来的 ESXi 管理网口的静态 IP ，必须改为自动获取【DHCP】，才能访问 OpenWrt 管理界面。访问 ESXi 管理网口时必须再改回原来的静态 IP。

