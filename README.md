<div align="center">

  <img src="./assets/banner.svg" width="100%" alt="SCPSL Linux Optimization Banner"/>

  <br><br>

  <p align="center">
    <img src="https://img.shields.io/badge/Game-SCP%3A%20Secret%20Laboratory-ff5555?style=for-the-badge&logo=steam&logoColor=white" />
    <img src="https://img.shields.io/badge/Played_Hours-350%2B_Hours-50fa7b?style=for-the-badge&logo=clockify&logoColor=white" />
    <img src="https://img.shields.io/badge/OS-Arch%20%7C%20Nyarch%20Linux-1793d1?style=for-the-badge&logo=arch-linux&logoColor=white" />
    <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" />
    <img src="https://img.shields.io/badge/Author-shenchuchu91--hub-ff79c6?style=for-the-badge" />
  </p>

  <p align="center">
    <i>🎯 基于 350+ 小时实操验证：解决 Wayland 准星偏移脱节、Unity 多核调度优化与帧率上限解锁实录 🎯</i>
  </p>

</div>

---

## 💻 硬件测试环境与参考配置 (Hardware Specs & Test Environment)

为了确保本项目的**可复现性与测试严谨度**，下表列出作者的实际验证环境以及建议的运行基准：

| 项目 | 本文测试验证机型 (Tested Environment) | 建议最低运行配置 (Minimum Requirements) |
| :--- | :--- | :--- |
| **操作系统** | Nyarch Linux x86_64 (Linux Kernel 7.x, Wayland / Niri) | Arch Linux 及常见 Linux 衍生版 |
| **处理器 (CPU)** | 13th Gen Intel Core i7-13620H (16 Threads) | 4 核心 8 线程以上 64 位处理器 |
| **显卡 (GPU)** | NVIDIA GeForce RTX 5060 Laptop (驱动版本: 615.78+) | 支持 Vulkan 1.3 的独立显卡或现代核显 |
| **屏幕规格** | 1080p @ 144Hz IPS 高刷新率屏 | 1080p @ 60Hz 标准显示设备 |
| **内存 (RAM)** | 16 GB DDR5 | 8 GB RAM |

> 📌 *说明：文中所有调优效果与启动项参数（如 320 FPS 帧率上限）均为**作者在上述实测机型中的测试记录**。不同机器的硬件规格、驱动版本及桌面协议有所不同，读者可根据自身配置酌情适配。*

---

## 🎯 痛点一：为什么准星不能对中？鼠标偏移物理脱节的唯一正解

在 Linux（特别是 Wayland 会话与平铺桌面环境）下玩《SCP: 秘密实验室》（SCPSL），许多玩家都会遇到一个让人极其崩溃的致命 Bug：
- **准星偏离屏幕物理中心**；
- 鼠标点击的位置和实际视线准星完全脱节；
- 开枪手感极度别扭，无法精准命中目标！

### 🔍 根本原因分析：
在 Linux Wayland 下，Unity 引擎在**独占全屏 (Exclusive Fullscreen)** 模式下调用系统指针限制（Pointer Constraint / Cursor Lock）时，容易出现视口分辨率与桌面缩放坐标系错位。

### 🌟 验证有效的解决方案：
进入游戏「设置 (Settings)」 -> 「视频 (Video)」 -> **显示模式【千万不要选择全屏 (Fullscreen)】！**

> ✅ **必须选择：【无边框窗口化 (Borderless Windowed)】！**

选完无边框窗口化后，搭配 Wayland / Niri 的自动居中与平铺机制，准星在作者测试环境下**瞬间绝对对中、鼠标精准归位，手感完全恢复正常**！

---

## 📂 痛点二：boot.config 在哪里？如何找到并修改？

在 Steam 客户端中定位该文件非常简单：

1. 打开 Steam 客户端，在左侧游戏库中找到 **《SCP秘密实验室 / SCP: Secret Laboratory》**；
2. **鼠标右键点击游戏** -> 鼠标悬停在 **「管理 (Manage)」** 上 -> 点击 **「浏览本地文件 (Browse local files)」**；
3. 系统文件管理器会自动打开游戏根目录；
4. 双击进入 **`SCPSL_Data`** 文件夹；
5. 你就会在这个文件夹里看到名为 **`boot.config`** 的配置文件。

---

## ⚡ 痛点三：boot.config 满血调优参数深度剖析

用任意文本编辑器打开 `SCPSL_Data/boot.config`，将其修改为以下参数：

```ini
gfx-enable-native-gfx-jobs=1
gfx-enable-gfx-jobs=1
gfx-disable-mt-rendering=1
job-worker-count=6
hdr-display-enabled=0
gc-max-time-slice=1
no-stereo-rendering=1
force-feature-level-9-3=1
wait-for-managed-debugger=0
wait-for-native-debugger=0
scripting-runtime-version=latest
vr-enabled=0
```

### 🔬 核心参数解析：
- **`job-worker-count=6`**：
  > ⚠️ **核心关键**：后面的数值请根据你自己的 **CPU 物理大核/线程数** 填写！作者在 i7-13620H 上测试填 6，读者 8 核机型可填 6-8，能让多核 CPU 充分参与多线程任务调度，缓解单核跑满导致的偶发掉帧；
- **`gfx-enable-native-gfx-jobs=1` & `gfx-enable-gfx-jobs=1`**：
  开启引擎底层的原生图形工作调度线程，减轻主线程渲染负载；
- **`gc-max-time-slice=1`**：
  将 Unity 内存垃圾回收的时间片限制在 1ms，在作者测试中有效减轻了遭遇大量怪物或混战时的瞬时大掉帧；
- **`hdr-display-enabled=0` & `vr-enabled=0`**：
  禁用无用的 HDR 与 VR 监测，减少不必要的管线开销；
- **`wait-for-managed-debugger=0`**：
  关闭调试器等待，加快加载进图速度。

---

## 🚀 痛点四：Steam 推荐启动项参数

在 Steam 库中**右键游戏 -> 点击「属性」 -> 在「常规」标签页最下方的「启动选项」输入框**中填入：

```bash
-quality 0 accuracystats -gfx-disable-vsync -disable-assembly-update-check -screen-fullscreen 0 -targetFrameRate 320
```

### 启动项说明：
- `-targetFrameRate 320`：解锁引擎帧率上限（作者在 144Hz 高刷屏测试上限设为 320，读者亦可设为 144 或 240）；
- `-screen-fullscreen 0`：启动时强制采用窗口模式，避免全屏指针错位；
- `-gfx-disable-vsync`：关闭垂直同步，降低输入延迟；
- `-disable-assembly-update-check`：跳过程序集热检查，提升启动效率；
- `accuracystats`：开启命中与网络同步状态输出。

---

## 🌐 新人必看：默认英文如何切换简体中文？

新安装的 SCPSL 默认界面为全英文：

1. 启动游戏进入主菜单；
2. 点击右上角的 **齿轮设置图标 (Settings)**；
3. 选择 **「Language（语言）」** 选项卡；
4. 在语言下拉列表中选择 **「简体中文 (Simplified Chinese)」**；
5. 点击确认，游戏界面立刻全部中文化。

---

## 🛠️ 附赠：自动化脚本与安全恢复说明

为提高可操作性，本仓库提供了一键检测与配置脚本：

```bash
# 1. 克隆本仓库
git clone https://github.com/shenchuchu91-hub/SCPSL-ArchLinux-Optimization.git ~/scpsl-opt

# 2. 运行一键配置脚本
cd ~/scpsl-opt
chmod +x scripts/scpsl-optimizer.sh
./scripts/scpsl-optimizer.sh
```

### 🛡️ 安全、恢复与反作弊守则：
- **自动备份**：脚本在执行修改前，会自动将你的原配置文件备份为：  
  `SCPSL_Data/boot.config.backup_时间戳`；
- **一键恢复**：若想恢复原貌，只需将备份文件重新覆盖回 `boot.config` 即可，绝不破坏原有游戏完整性；
- **公平竞技声明**：本项目所有修改仅为 Unity 官方引擎参数调优与 Wayland 窗口显示调度，绝不涉及内存修改、外挂注入或破坏游戏公平性，严格遵循游戏发行方 EULA。完整规范详见 [全局免责声明与通用安全规范 (Disclaimer)](https://github.com/shenchuchu91-hub/disclaimer)。

---

<div align="center">

🌸 **版权与许可** 🌸  
本项目基于 [MIT License](LICENSE) 开源发布。  
欢迎根据自身硬件反馈测试数据！

<sub>Made with 💖 by <b>shenchuchu91-hub</b></sub>

</div>
