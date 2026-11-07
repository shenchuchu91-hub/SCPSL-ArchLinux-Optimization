#!/usr/bin/env bash
# ==============================================================================
#  🎯 SCPSL (SCP: 秘密实验室) Linux 一键优化与准星管理工具
# ==============================================================================

set -e

C_RESET="\033[0m"
C_BOLD="\033[1m"
C_PINK="\033[38;2;243;139;168m"
C_GREEN="\033[38;2;166;227;161m"
C_CYAN="\033[38;2;137;220;235m"
C_YELLOW="\033[38;2;249;226;175m"
C_RED="\033[38;2;243;139;168m"

echo -e "${C_PINK}"
cat << 'EOF'
  [+]========================================================[+]
   |   🎯 SCP: Secret Laboratory Linux Optimizer (SCPSL)    |
   |   350+ 小时实战老玩家经验沉淀 · boot.config 满血调优   |
  [+]========================================================[+]
EOF
echo -e "${C_RESET}"

# 1. 尝试自动探测 Steam SCPSL 安装目录
find_scpsl_dir() {
    local candidates=(
        "$HOME/.local/share/Steam/steamapps/common/SCP Secret Laboratory"
        "$HOME/.steam/steam/steamapps/common/SCP Secret Laboratory"
        "$HOME/.steam/root/steamapps/common/SCP Secret Laboratory"
    )

    for p in "${candidates[@]}"; do
        if [ -d "$p/SCPSL_Data" ]; then
            echo "$p"
            return 0
        fi
    done

    # 尝试从整个 Steam 库递归搜索
    local found=$(find "$HOME/.local/share/Steam" "$HOME/.steam" -maxdepth 5 -type d -name "SCPSL_Data" 2>/dev/null | head -n1)
    if [ -n "$found" ]; then
        dirname "$found"
        return 0
    fi

    return 1
}

echo -e "${C_CYAN}[*] 正在检索 SCPSL 游戏目录...${C_RESET}"
GAME_DIR=""
if GAME_DIR=$(find_scpsl_dir); then
    echo -e "${C_GREEN}[✔] 自动找到游戏目录: ${GAME_DIR}${C_RESET}"
else
    echo -e "${C_YELLOW}[!] 未在默认 Steam 路径下自动找到游戏，请输入你的 SCPSL 游戏根目录路径:${C_RESET}"
    read -p "路径 (例如 /mnt/Games/steamapps/common/SCP Secret Laboratory): " USER_INPUT
    if [ -d "$USER_INPUT/SCPSL_Data" ]; then
        GAME_DIR="$USER_INPUT"
    else
        echo -e "${C_RED}[✘] 目录下未找到 SCPSL_Data 文件夹，请确认路径无误！${C_RESET}"
        exit 1
    fi
fi

DATA_DIR="$GAME_DIR/SCPSL_Data"
BOOT_CONFIG="$DATA_DIR/boot.config"

# 2. 备份原 boot.config
if [ -f "$BOOT_CONFIG" ]; then
    BACKUP="$BOOT_CONFIG.backup_$(date +%Y%m%d_%H%M%S)"
    cp "$BOOT_CONFIG" "$BACKUP"
    echo -e "${C_YELLOW}[!] 已安全备份原有配置至: ${BACKUP}${C_RESET}"
fi

# 3. 自动计算 CPU 核心数
CPU_CORES=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "6")
WORKER_COUNT=$((CPU_CORES > 4 ? CPU_CORES - 2 : 4))
if [ "$WORKER_COUNT" -lt 2 ]; then WORKER_COUNT=2; fi

echo -e "${C_CYAN}[*] 检测到 CPU 线程数: ${CPU_CORES}，推荐工作线程 (job-worker-count): ${WORKER_COUNT}${C_RESET}"

# 4. 写入优化版 boot.config
cat << EOF > "$BOOT_CONFIG"
gfx-enable-native-gfx-jobs=1
gfx-enable-gfx-jobs=1
gfx-disable-mt-rendering=1
job-worker-count=${WORKER_COUNT}
hdr-display-enabled=0
gc-max-time-slice=1
no-stereo-rendering=1
force-feature-level-9-3=1
wait-for-managed-debugger=0
wait-for-native-debugger=0
scripting-runtime-version=latest
vr-enabled=0
EOF

echo -e "${C_GREEN}[✔] 优化版 boot.config 写入成功！${C_RESET}"

# 5. 输出启动项与准星避坑提示
echo -e "\n${C_PINK}====================================================${C_RESET}"
echo -e "${C_BOLD}🎯 必须注意的准星对中与设置关键（老玩家血泪经验）:${C_RESET}"
echo -e "${C_YELLOW}1. 准星对中 Bug 核心解法：${C_RESET}"
echo -e "   进入游戏后，【显示模式】${C_RED}千万不能选择全屏独占 (Fullscreen)${C_RESET}！"
echo -e "   必须选择 ${C_GREEN}【无边框窗口化 (Borderless Windowed)】${C_RESET}，否则准星会出现物理偏移/鼠标脱离！"
echo ""
echo -e "${C_YELLOW}2. 默认语言调整：${C_RESET}"
echo -e "   首次进入游戏如果显示英文，点击右上角设置 (Settings) -> 语言 (Language) -> 选择「简体中文」即可。"
echo ""
echo -e "${C_YELLOW}3. 推荐 Steam 黄金启动项参数 (右键游戏 -> 属性 -> 启动选项):${C_RESET}"
echo -e "${C_GREEN}-quality 0 accuracystats -gfx-disable-vsync -disable-assembly-update-check -screen-fullscreen 0 -targetFrameRate 320${C_RESET}"
echo -e "${C_PINK}====================================================${C_RESET}\n"
