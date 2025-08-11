---
keywords:
  - OpenWrt扩容
  - ESXi虚拟机扩容
  - OpenWrt磁盘扩容
  - 软路由扩容
  - OpenWrt存储扩展
  - ESXi磁盘扩展
  - 虚拟机磁盘扩容
  - OpenWrt分区扩展
  - 家庭AIO扩容
  - 软路由存储管理
  - 陈大剩的家庭AIO服务器
  - 家庭AIO服务器
description: 介绍在ESXi环境中对OpenWrt软路由进行磁盘扩容的完整教程，包括ESXi虚拟机设置、OpenWrt分区扩展和文件系统扩容等步骤。
---
OpenWrt 安装成功后，磁盘空间才 **86 Mib**，没安装几个软件就不够用了，这怎么能忍？
![默认配置](https://img.it927.com/aio/268.png)

## 准备工作
本教程基于 **SquashFS** 文件系统的 OpenWrt，如果是基于 **ext4** 系统话，应该会更简单。在扩容前需要安装几个特定的工具，`cfdisk`、`resize2fs`、`losetup`，导航至【软件包】-【过滤器】
=== "losetup"
    ![losetup](https://img.it927.com/aio/280.png)

=== "cfdisk"
    ![cfdisk](https://img.it927.com/aio/269.png)

=== "resize2fs"
    ![resize2fs](https://img.it927.com/aio/270.png)

## ESXi 虚拟磁盘扩容
在进行磁盘扩容前，必须完全关闭 OpenWrt 虚拟机，在 ESXi 管理界面确认虚拟机状态为"已关闭电源" 开始操作。
### 扩展虚拟磁盘
工具安装成功后，先扩充物理磁盘，导航至【虚拟机】选择虚拟机后编辑，将硬盘设置成想要的大小，陈大剩设置成了 3 GB
![扩充虚拟主机物理磁盘](https://img.it927.com/aio/271.png)

### 验证磁盘扩展
虚拟机启动后，通过 SSH 连接验证磁盘是否成功扩展：
```shell
# 查看分区信息
cat /proc/partitions
```
![查看分区信息](https://img.it927.com/aio/283.png)
可以看到分区信息 `sda` 中多很了多。
## OpenWrt 系统层面扩容
### 连接系统
使用 [ttyd 工具](install.md#ttyd) 或 SSH 连接到 OpenWrt 命令行：
![登录 SSH](https://img.it927.com/aio/272.png)
可通过命令，查看一下原始磁盘的大小
```shell
# 查看磁盘使用情况
df -h
```
![验证磁盘扩展](https://img.it927.com/aio/278.png)
### 扩充磁盘
扩充磁盘按照如下命令操作：
=== "步骤一：查看磁盘"
    使用 `cfdisk` 命令查看磁盘状态，能看到有 `2.9 G` 的空余磁盘（Free space），选择需要扩容的第二个磁盘，选择【Resize】回车
    ![查看磁盘状态](https://img.it927.com/aio/273.png)

=== "步骤二：扩充磁盘"
    弹出来 `New size` 输入要扩大的大小，陈大剩这里默认是 `3 G`
    ![New size](https://img.it927.com/aio/274.png)

=== "步骤三：写入磁盘"
    扩充成功后选，选择【Write】回车
    ![写入磁盘](https://img.it927.com/aio/275.png)

=== "步骤四：确认写入"
    写入磁盘后，会弹出确认写入操作，输入【yes】回车后，选择【Quit】回车
    ![确认写入](https://img.it927.com/aio/276.png)

### 设置循环
扩充磁盘后，还需要设置循环，目前还只用了 `cfdisk` 工具，接下来使用 `losetup` 和 `resize2fs` 工具，输入如下命令
```shell
losetup /dev/loop0 /dev/sda2
resize2fs -f /dev/loop0
```
不出意外，能看到如下结果
```
resize2fs 1.47.0 (5-Feb-2023)
Filesystem at /dev/loop0 is mounted on /overlay; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 24
The filesystem on /dev/loop0 is now 3123008 (1k) blocks long.
```
???+info "提示"
    循环设备是 Linux 内核提供的一种虚拟块设备，它可以将一个普通文件映射为块设备来使用。

    简单来说，就是让系统把一个文件当作硬盘分区来操作

### 重启系统
看到结果后，使用命令重启 OpenWrt：
```shell
reboot
```
### 验证扩容结果
系统重启后，验证扩容是否成功：
```bash
# 查看磁盘使用情况
df -h

# 查看覆盖文件系统大小
df -h /overlay

# 查看可用空间
df -h | grep overlay
```
**成功扩容后的输出示例：**
![成功扩容后的输出示例](https://img.it927.com/aio/282.png)

## 结果
通过上述步骤后，能看到软件包已经扩容成功，还是不能忍，可以继续加空间
![结果](https://img.it927.com/aio/281.png)
