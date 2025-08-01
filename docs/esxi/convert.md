---
keywords:
  - ESXi镜像转换教程
  - IMG转VMDK格式
  - StarWind V2V Converter使用
  - ESXi虚拟机镜像转换
  - 虚拟机格式转换工具
  - VMDK镜像制作
  - ESXi镜像部署
  - 虚拟化镜像转换
  - ESXi磁盘格式转换
  - 虚拟机镜像格式支持
  - 家庭All-in-One
  - ESXi环境搭建教程
  - 陈大剩的家庭AIO服务器
  - 家庭AIO服务器
description: 详细介绍如何使用StarWind V2V Converter将IMG等格式的镜像文件转换为ESXi支持的VMDK格式，包含完整的操作步骤和注意事项。
---
在 ESXi 环境中部署虚拟机时，经常需要将各种格式的镜像文件（如 IMG、VHD、VHDX）转换为 ESXi 原生支持的 VMDK 格式。我们一般用 **StarWind V2V Converter** 来做镜像转换，它一款免费的虚拟机镜像转换工具，专门用于在不同虚拟化平台之间 **转换磁盘镜像格式**。

## 准备工作
- 一台联网的 Windows 电脑；
- 需要转换的镜像文件（IMG、VHD、VHDX后缀）；

## 工具准备
### 下载 StarWind V2V Converter
1. 访问官方下载页面：[StarWind V2V Converter](https://www.starwindsoftware.com/starwind-v2v-converter)；
2. 填写注册信息获取下载链接；
3. 检查邮箱获取下载链接并完成软件安装；

???+ warning "注册信息填写注意事项"
    - **邮箱地址**：必须填写真实有效的邮箱，下载链接将发送至此邮箱
    - **其他信息**：公司名称、电话等信息可以随意填写
    - **用途说明**：建议选择"Personal Use"个人使用

    如果不想这么麻烦的下载，可直接用我下载好的包：[StarWind V2V Converter](https://pan.baidu.com/s/1L4de1QMPDZ3yxRXOVStiQQ?pwd=vms2)；

![下载 StarWind V2V Converter](https://img.it927.com/aio/81.png)

## 镜像转换操作步骤
### 第一步：启动转换向导
双击运行 StarWind V2V Converter，进入转换向导界面：
![启动转换向导](https://img.it927.com/aio/82.png)
???+ info "提示"

    **本地文件**：镜像文件存储在本地计算机，选择 【Local File】 选项；<br/>
    **远程服务器**：镜像文件存储在 ESXi 或 Hyper-V 服务器，选择相应的远程选项，需要提供服务器连接凭据；

### 第二步：选择源镜像位置
陈大剩这里是选择本地源，并选择了本地文件：
![选择本地源](https://img.it927.com/aio/83.png)

选择源文件后，软件会自动识别并显示：镜像文件类型、镜像文件大小、磁盘分区信息。
### 第三步：选择目标存储位置
根据转换后镜像的存储需求选择目标位置：
![选择目标存储位置](https://img.it927.com/aio/84.png)

| 选项 | 适用场景 | 说明                |
|------|----------|-------------------|
| Local File | 本地存储 | 转换后的 VMDK 文件保存在本地 |
| ESXi Server | 直接部署 | 转换后直接上传到 ESXi 服务器 |
| Hyper-V Server | 跨平台迁移 | 转换为 Hyper-V 格式    |

### 第四步：选择目标格式
选择目标格式，文章演示镜像为 ESXI 使用，所以选择 VMDK 格式。
![选择目标格式](https://img.it927.com/aio/85.png)

???+ tip "格式选择建议"
    - **ESXi 环境**：选择 VMDK 格式；
    - **Hyper-V 环境**：选择 VHD/VHDX 格式；
    - **通用格式**：选择 IMG 格式；

### 第五步：配置镜像属性
根据目标虚拟化平台选择合适的镜像属性：
![配置镜像属性](https://img.it927.com/aio/86.png)

选择镜像属性，根据镜像应用需求选择 “ESXi Server image”


| 选项                                                 | 适用平台           | 特点                              |
| -------------------------------------------------- | ------------------ | --------------------------------- |
| VMware Workstation growable image（自增长镜像）      | VMware Workstation | 动态增长，节省空间，适用于桌面虚拟化   |
| VMware Workstation pre-allocated image（预分配镜像） | VMware Workstation | 预分配空间，性能更好，适用于桌面虚拟化 |
| Stream-optimized image（流优化镜像）                 | OVF包/网络传输     | 压缩格式，适合流传输                   |
| ESXi Server image                                  | ESXi 6.0+          | **针对 ESXi 优化，性能最佳**          |

???+ warning "重要提醒"

    VMware Workstation 和 ESXi Server 的 VMDK 格式略有差异，可能无法相互通用。错误的格式选择可能导致： 文件系统损坏、系统无法启动、性能异常。

### 第六步：选择磁盘分配模式
根据存储需求和性能要求选择磁盘模式：

![选择磁盘分配模式](https://img.it927.com/aio/87.png)

=== "Growable（自增长）"

    **特点**：初始占用空间小、随数据增长动态扩展、适合存储空间有限的环境；
    
    **限制**：仅在目标为远程服务器时可用、性能略低于预分配模式；

=== "Pre-allocated（预分配）"

    **特点**：立即分配全部磁盘空间、性能最佳、适合生产环境；
    
    **要求**：需要足够的存储空间、本地转换时的唯一选项；


### 第七步：执行转换过程
检查所有配置参数，确认无误后开始转换，点击"Convert"开始转换过程：

=== "转换进度"
    
    转换过程中会显示：转换进度百分比、剩余时间估算、当前处理速度。
    ![转换进度](https://img.it927.com/aio/89.png)

=== "转换完成"
    
    等待一小会就成功了~
    ![转换完成](https://img.it927.com/aio/90.png)

## 转换后处理
转换完后会得到两个文件分别为: `xxx.vmdk` 和一个 `xxx-flat.vmdk` 的两个文件，这两个文件是配套使用的。
![转换后成功](https://img.it927.com/aio/91.png)
`xxx.vmdk` 文件告诉 ESXi 如何解释和访问虚拟磁盘，`xxx-flat.vmdk` 文件包含实际的磁盘数据，**两个文件必须同时存在**，虚拟机才能正常使用该虚拟磁盘。
## 上传至 ESXi
进入 ESXi 管理后台后，依次从【存储】-【数据存储】-【数据存储浏览器】中创建一个放镜像文件的目录，我这里命名为 `os` 。
![创建镜像文件目录](https://img.it927.com/aio/100.png)
创建目录后点击【上载】按钮，依次上传 `xxx.vmdk` 和 `xxx-flat.vmdk` 的两个文件。
![上传文件](https://img.it927.com/aio/101.png)
???+ info "提示"
  
    因【上载】按钮每次只能上传一个文件，必须依次上传 `xxx.vmdk` 和 `xxx-flat.vmdk` 的两个文件，否则镜像会破坏。

上传完成后会可看到：
![成功上传](https://img.it927.com/aio/102.png)
### 验证转换结果
转换完成后，可通过 SSH 登入 ESXi 服务器,进行以下验证：
```bash
# 检查VMDK文件完整性
vmkfstools -e /vmfs/volumes/datastore1/os/xx.vmdk

# 查看VMDK文件信息
vmkfstools -q /vmfs/volumes/datastore1/os/xxx.vmdk
```
输出：
```bash
$ vmkfstools -e OpenWrt-24.10.2-x86-64-generic-squashfs-combined.vmdk 
Disk chain is consistent.
```
