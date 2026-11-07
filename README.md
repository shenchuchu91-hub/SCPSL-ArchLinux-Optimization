<div align="center">

  <img src="./assets/banner.svg" width="100%" alt="SCPSL Linux Optimization Banner"/>

  <br><br>

  <p align="center">
    <img src="https://img.shields.io/badge/Game-SCP%3A%20Secret%20Laboratory-ff5555?style=for-the-badge&logo=steam&logoColor=white" />
    <img src="https://img.shields.io/badge/Played_Hours-350%2B_Hours-50fa7b?style=for-the-badge&logo=clockify&logoColor=white" />
    <img src="https://img.shields.io/badge/OS-Arch%20%7C%20Nyarch%20Linux-1793d1?style=for-the-badge&logo=arch-linux&logoColor=white" />
    <img src="https://img.shields.io/badge/FPS-320_FPS_Unlocked-bd93f9?style=for-the-badge&logo=speedtest&logoColor=white" />
    <img src="https://img.shields.io/badge/Author-shenchuchu91--hub-ff79c6?style=for-the-badge" />
  </p>

  <p align="center">
    <i>🎯 一位 357 小时实战老玩家的深度调教心法：解决准星偏移、榨干 CPU 多核性能、突破 320 FPS！ 🎯</i>
  </p>

</div>

---

## 📑 核心避坑与调优目录

- [🎯 痛点一：为什么准星不能对中？鼠标偏移物理脱节的唯一正解](#-痛点一为什么准星不能对中鼠标偏移物理脱节的唯一正解)
- [📂 痛点二：bootconfig 在哪里？如何找到并修改？](#-痛点二bootconfig-在哪里如何找到并修改)
- [⚡ 痛点三：bootconfig 满血调优参数深度剖析](#-痛点三bootconfig-满血调优参数深度剖析)
- [🚀 痛点四：Steam 黄金启动项参数 (直上 320 FPS)](#-痛点四steam-黄金启动项参数-直上-320-fps)
- [🌐 新人必看：默认英文如何切换简体中文？](#-新人必看默认英文如何切换简体中文)
- [🛠️ 附赠：一键自动备份与多核配置脚本](#-附赠一键自动备份与多核配置脚本)

---

## 🎯 痛点一：为什么准星不能对中？鼠标偏移物理脱节的唯一正解

在 Linux（无论是 Wayland、X11 还是 Niri 桌面）下玩《SCP: 秘密实验室》（SCPSL），许多玩家都会遇到一个让人极其崩溃的致命 Bug：
- **准星严重偏离屏幕中心**；
- 鼠标点击的位置和实际视线准星完全脱节；
- 对枪打不到人，操作手感极度别扭！

### 🔍 根本原因揭秘：
在 Linux 下，Unity 引擎在**独占全屏 (Exclusive Fullscreen)** 模式下捕获鼠标指针限制（Pointer Constraint）时，会出现视口与桌面缩放坐标系错位。

### 🌟 独家解决方案（血泪经验）：
进入游戏「设置」 -> 「视频 (Video)」 -> **显示模式【千万不能选全屏 (Fullscreen)】！**

> ✅ **必须选择：【无边框窗口化 (Borderless Windowed)】！**

选完无边框窗口化后，搭配 Wayland / Niri 的自动平铺与居中，准星瞬间**绝对对中、鼠标精准归位，开枪手感完全拉满**！

---

## 📂 痛点二：boot.config 在哪里？如何找到并修改？

不少新手听说改 `boot.config` 能大幅提升帧率，但根本找不到这个文件藏在什么地方。其实在 Steam 里找它非常容易：

1. 打开 Steam 客户端，在左侧游戏库中找到 **《SCP秘密实验室 / SCP: Secret Laboratory》**；
2. **鼠标右键点击游戏** -> 鼠标悬停在 **「管理 (Manage)」** 上 -> 点击 **「浏览本地文件 (Browse local files)」**；
3. 系统文件管理器会自动弹开游戏安装主目录；
4. 双击进入 **`SCPSL_Data`** 文件夹；
5. 你就会在这个文件夹里看到名为 **`boot.config`** 的配置文件！

---

## ⚡ 痛点三：boot.config 满血调优参数深度剖析

用任意文本编辑器打开 `SCPSL_Data/boot.config`，将其全部内容替换为以下经过 350+ 小时实战验证的极致优化配置：

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

### 🔬 各项核心参数解析：
- **`job-worker-count=6`**：
  > ⚠️ **核心关键**：后面的数值请根据你自己的 **CPU 物理大核/线程数** 填写！比如 6 核心填 6，8 核心填 6-8，能让多核 CPU 满载参与游戏运算，彻底告别单核满载掉帧！
- **`gfx-enable-native-gfx-jobs=1` & `gfx-enable-gfx-jobs=1`**：
  开启引擎底层的原生图形工作调度线程，极大减轻主线程渲染负载；
- **`gc-max-time-slice=1`**：
  将 Unity 内存垃圾回收的时间片限制在 1ms，**消除突然遇到大量怪物或混战时卡顿 1 秒的瞬时大掉帧**；
- **`hdr-display-enabled=0` & `vr-enabled=0`**：
  禁用无用的 HDR 与 VR 监测，节省显存与着色器算力开销；
- **`wait-for-managed-debugger=0`**：
  关闭调试器等待，加快加载进图速度。

---

## 🚀 痛点四：Steam 黄金启动项参数 (直上 320 FPS)

在 Steam 库中**右键游戏 -> 点击「属性」 -> 在「常规」标签页最下方的「启动选项」输入框**中填入：

```bash
-quality 0 accuracystats -gfx-disable-vsync -disable-assembly-update-check -screen-fullscreen 0 -targetFrameRate 320
```

### 启动项详解：
- `-targetFrameRate 320`：突破默认 60 帧/引擎帧率限制，解锁最高 320 FPS 超丝滑高刷！
- `-screen-fullscreen 0`：强制启动为窗口/无边框模式，从根源杜绝全屏准星偏移 Bug！
- `-gfx-disable-vsync`：彻底关闭垂直同步，降低输入延迟；
- `-disable-assembly-update-check`：关闭程序集热更新检查，秒级进入游戏大厅；
- `accuracystats`：开启精准命中与网络同步统计。

---

## 🌐 新人必看：默认英文如何切换简体中文？

新安装的 SCPSL 默认界面是全英文，不要慌：

1. 启动游戏进入主菜单；
2. 点击右上角的 **齿轮设置图标 (Settings)**；
3. 选择 **「Language（语言）」** 选项卡；
4. 在语言下拉列表中选择 **「简体中文 (Simplified Chinese)」**；
5. 点击确认，整个游戏从角色技能、物品说明到系统菜单立刻全部中文化！

---

## 🛠️ 附赠：一键自动备份与多核配置脚本

如果你不想手动翻目录查找，可以使用本仓库为你准备好的自动化脚本：

```bash
# 1. 克隆本仓库
git clone https://github.com/shenchuchu91-hub/SCPSL-ArchLinux-Optimization.git ~/scpsl-opt

# 2. 运行一键配置脚本
cd ~/scpsl-opt
chmod +x scripts/scpsl-optimizer.sh
./scripts/scpsl-optimizer.sh
```

> **该脚本会自动**：
> 1. 自动探查你的 Steam 库并定位 `SCPSL_Data`；
> 2. 自动根据时间戳安全备份你的原有 `boot.config`；
> 3. 自动读取你当前 CPU 的真实核心数并写入匹配的工作线程数！

---

<div align="center">

🌸 **献给所有深爱 SCPSL 的 Arch Linux 玩家** 🌸  
收容失效，但准星绝不偏移！

<sub>Made with 💖 by <b>shenchuchu91-hub</b> (357h Veteran)</sub>

</div>
