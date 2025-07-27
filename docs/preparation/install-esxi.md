---
slug: install-esxi
keywords: 
  - ESXi安装
  - 家庭ESXi安装
  - 家庭AIO搭建教程
  - 家庭All-in-One搭建教程
description: 在安装系统前，需要设置 BIOS。由于不同主板的 BIOS 设置大同小异，很难详细展开说明，因此我们主要关注以下几个相关选项。
---
## 准备工作
- 大于 8G 的硬盘
- 一台可联网的电脑（需要带 RJ45 网口）

## 制作引导 U盘

引导使用 [Ventoy](https://www.ventoy.net/cn/)，目前使用的 1.0.99 版本，下载 [ventoy-1.0.99-windows.zip](https://github.com/ventoy/Ventoy/releases) 解压到桌面，打开后按照以下步骤制作引导 U 盘。
![制作引导 U盘](https://img.it927.com/aio/27.png)

## 下载镜像

下载镜像需要在官方网站注册账号才能下载，如果不想这么麻烦，可以直接使用我已经下载好的 [镜像](https://pan.baidu.com/s/15MNW2IN8_5aEz45bFuE0SA?pwd=sjc7)，当然也可以去第三方地址下载。
???+ warning "注意"

    第三方下载时，可以根据需要对比哈希值，如果一致则为官方正版 ISO 文件，否则需要仔细甄别。


下面介绍官网下载的方法：
=== "步骤一"

    访问 [官方下载地址](https://customerconnect.vmware.com/zh/evalcEnter?p=vsphere-eval-8)，先注册一个 VMWare 的账号，注册登录完毕后，会进入仪表盘，点击【My Downloads】 能看到如下页面
    ![登录官网](https://img.it927.com/aio/28.png)

=== "步骤二"

    再点击上方的 [HERE](https://support.broadcom.com/group/ecx/free-downloads) 然后选择 【VMware vSphere Hypervisor】点击下拉选择最新版本即可。
    ![Hypervisor](https://img.it927.com/aio/29.png)

=== "步骤三"

    按照下面操作即可愉快的下载了，点击下载时还会要求填一些信息，随便填即可。
    ![Hypervisor](https://img.it927.com/aio/30.png)
    下载后记得将镜像移动到上一步的 **引导 U盘** 中。

???+ info

    找不到具体哈希值值时可去官网查历史: [版本记录](https://knowledge.broadcom.com/external/article)。同时我们要注意一下，我们的硬件是否支持 ：[VMware兼容性指南](https://compatibilityguide.broadcom.com/)，ESXi 9.0 系列已经不支持 E5-2600 处理器了，请自行确认。

## 安装
### Ventoy  引导进入镜像
=== "步骤一"

    开启家庭 AIO 服务器，选择 U 盘启动，并进入 Ventoy 界面，选择 ESXi 镜像回车再回车。
    ![进入 Ventoy 界面](https://img.it927.com/aio/31.png)

=== "步骤二"

    进入后选择第一个选项：Boot in normal mode（以正常模式启动）
    ![Boot in normal mode](https://img.it927.com/aio/32.png)

### 修改ESXi的默认空间
在读秒阶段，快速按下 `Shift+O`，调出命令行，来修改 ESXi 的默认空间大小，在下面命令行输入：`autoPartotionOSDataSize=20480`。命令注意区分大小写，将默认空间设置为 20GB。硬盘空间不足的话推荐设置 8192(8GB) 即可
![修改ESXi的默认空间](https://img.it927.com/aio/33.png)
### 安装系统
=== "步骤一"

    U盘启动后，等待系统文件自动加载
    ![系统加载](https://img.it927.com/aio/35.png)

=== "步骤二"

    当出现欢迎弹窗时，按下键盘 `Enter` 继续
    ![欢迎弹窗](https://img.it927.com/aio/36.png)

=== "步骤三"

    弹出协议窗口时，按下键盘 `F11`，接受协议
    ![接受协议](https://img.it927.com/aio/37.png)

=== "步骤四"

    选择安装硬盘，这里我选择三星的 890 硬盘选择后，按下键盘 `Enter` 继续
    ![选择安装硬盘](https://img.it927.com/aio/40.png)

=== "步骤五"

    保持默认，按下键盘 `Enter` 继续
    ![保持默认](https://img.it927.com/aio/43.png)

=== "步骤六"

    设置访问密码 ，密码设置要求：字母大小写+数字+特殊符号 8位以上
    ![设置访问密码](https://img.it927.com/aio/45.png)

=== "步骤七"

    CPU 警告不用管（是说下个版本不支持了），继续：
    ![CPU 警告](https://img.it927.com/aio/46.png)

=== "步骤八"

    按下键盘 `F11`，开始安装
    ![开始安装](https://img.it927.com/aio/47.png)

=== "步骤九"

    等待系统安装完成。
    ![开始安装](https://img.it927.com/aio/48.png)

### 安装完成
=== "步骤一"

    系统安装完成后，按下键盘 `Enter` 重启，等待重启
    ![安装完成](https://img.it927.com/aio/49.png)

=== "步骤二"

    重启过程中下面会有进度条：
    ![重启过程](https://img.it927.com/aio/52.png)

=== "步骤三"

    系统安装重启完成，显示了 IP 地址，就已经安装完成了，因为我们没有插网线，所以地址显示是 0.0.0.0。
    ![安装完成](https://img.it927.com/aio/54.png)

这一个步骤就是安装完成，接下来就是设置网口 IP 地址了。
### 设置管理网卡 IP 地址
#### 进入自定义系统页面
在设置网卡前，我们需要进入自定义系统页面。
=== "步骤一"

    这时候我们还没有连网线呢？ESXi 启动后，按键盘 `F2`，输入前面安装时设置的密码，进行网络设置
    ![进入配置](https://img.it927.com/aio/55.png)

=== "步骤二"

    键盘上下方向键移动到 【configure managenment netweork】选项，按下键盘 `Enter` 继续
    ![配置网络](https://img.it927.com/aio/38.png)

#### 查看网络适配器
选择第一个 【Netweork Adapter】选项，按下键盘 `Enter` 查看网络适配器：
![网卡列表](https://img.it927.com/aio/39.png)
我这里只显示 INTEL I350T4V2 四口网卡，只是我并没有插网线，还有两个板载的 2.5G 网口，因为 ESXi 不支持，所以没有显示网络适配器中。

???+ warning "注意"

    如果你没有找到网卡，恭喜你，大概率是 ESXi 不支持你的网卡，可以在 [Broadcom Compatibility Guide](https://compatibilityguide.broadcom.com/search?program=io&persona=live&column=brandName&order=asc) 查询你的网卡是否在兼容表中，不存在则需要购买一款支持的网卡。

#### 设置管理网卡 IP 地址
这个环节中，如果你上游有路由器，不需要软路由，只需要在路由器下使用，则只需从路由器上接一根网线到 ESXi 上即可，等待路由器自动设置 IP 地址即可，无需下面的 IP 设置。

陈大剩只是想把管理网口当管理用，所以设计一个死 IP 即可，后续可通过网线和跳板机直接访问管理 ESXi，如果你想和陈大剩一样，跟着设计就行，后续文章会介绍使用流程。
=== "步骤一"

    键盘上下方向键移动到 【set static ipv4 address and network configuration】 按键盘空格选择，方向键向下移动 设置 IP 地址
    ![设置 IP 地址](https://img.it927.com/aio/56.png)

=== "步骤二"

    进入，关闭 IPv6 登录，没有必要 IPv6 登录
    ![关闭 IPv6 登录](https://img.it927.com/aio/57.png)

=== "步骤三"

    设置完成后按 `Enter` 确定，然后按键盘 `esc` 退出，弹窗按键盘`Y` 键，确定更改。
    ![进入配置](https://img.it927.com/aio/44.png)

## 安装结束
安装和设计结束后，会回到 ESXi 的首页，能看到这里，恭喜安装顺利结束。
![ESXi 主页](https://img.it927.com/aio/50.png)