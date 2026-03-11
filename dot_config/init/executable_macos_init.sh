#!/usr/bin/env bash
# ==============================================================================
#  macOS 全能环境初始化脚本 (Ultimate Version with MAS)
#  Author: yinhaoyu
#  描述: 自动安装开发工具、常用应用、MAS 应用，并智能处理国产软件
# ==============================================================================

set -o pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 打印函数
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅  $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌  $1${NC}"; }
step() { echo -e "${CYAN}👉  $1${NC}"; }

# ------------------------------------------------------------------------------
# 0. 检查 Homebrew
# ------------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  error "Homebrew 未安装！正在尝试安装..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ $(uname -m) == 'arm64' ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

echo ""
info "🚀 开始 macOS 全能环境初始化..."
echo ""

# ------------------------------------------------------------------------------
# 1. 安装基础 CLI 工具
# ------------------------------------------------------------------------------
step "正在安装开发核心工具 (CLI)..."
cli_tools=(
  neovim lazygit chezmoi git zoxide superfile
  exiftool lazyssh git-delta yazi ffmpeg sevenzip jq
  poppler fd ripgrep fzf zoxide resvg imagemagick uv
  pyenv htop tldr tree wget curl mas
)

for tool in "${cli_tools[@]}"; do
  if brew list "$tool" &>/dev/null; then
    success "$tool 已安装。"
  else
    info "正在安装 $tool ..."
    brew install "$tool" || warn "$tool 安装失败。"
  fi
done

# ------------------------------------------------------------------------------
# 2. 安装字体
# ------------------------------------------------------------------------------
step "正在配置字体..."
brew tap homebrew/cask-fonts &>/dev/null || true
fonts=(font-symbols-only-nerd-font font-hack-nerd-font font-jetbrains-mono-nerd-font)
for font in "${fonts[@]}"; do
  brew install --cask "$font" &>/dev/null && success "$font 已安装。" || warn "$font 安装失败。"
done

# ------------------------------------------------------------------------------
# 3. 安装 GUI 应用 (Cask)
# ------------------------------------------------------------------------------
step "正在安装图形界面应用 (Cask)..."
cask_apps=(
  wechat douyin notion google-chrome bilibili termius warp qbittorrent
  tencent-lemon IINA wpsoffice-cn free-download-manager monitorcontrol
  visual-studio-code raycast chatgpt baidunetdisk adrive qq canva
  wetype youku claude folo stash doubao feishu flykey qianwen
  tencent-meeting qqlive docker-desktop github input-source-pro keka
  kindavim Nugget Obsidian snipaste telegram UTM Zed
)

for app in "${cask_apps[@]}"; do
  if brew list --cask "$app" &>/dev/null; then
    success "$app 已安装。"
  else
    brew install --cask "$app" || warn "$app 安装失败 (可能需手动下载)。"
  fi
done

# ------------------------------------------------------------------------------
# 4. 安装 Mac App Store 应用 (MAS)
# ------------------------------------------------------------------------------
step "正在配置 Mac App Store 应用..."

# 检查是否登录
if ! mas account &>/dev/null; then
  warn "⚠️  检测到未登录 Mac App Store。"
  echo "   👉 请在弹出的 App Store 窗口中登录您的 Apple ID。"
  echo "   ⏳ 登录后按任意键继续..."
  open -a "App Store"
  read -n 1 -s
  echo ""
fi

# 验证登录状态
if ! mas account &>/dev/null; then
  error "❌ 仍未检测到登录，跳过 MAS 应用安装。请手动登录后重新运行脚本。"
else
  success "✅ 已登录账号：$(mas account)"

  # 定义 MAS 应用 ID (App ID 可以在 App Store 网页版 URL 中找到，或者用 mas search 命令搜索)
  # 示例: Infuse, Final Cut Pro, Logic Pro, Pages, Numbers, Keynote, Affinity Photo 等
  # 格式: "应用名称:AppID"
  declare -A mas_apps
  mas_apps["Infuse"]="1161688597" # Infuse 视频播放器
  # mas_apps["Pages"]="pages"             # 这里的 ID 可以用名字代替，mas 会自动搜索，但推荐用数字 ID 更稳
  # 下面演示用数字 ID (您需要确认自己是否购买过这些软件，否则会安装失败或提示购买)
  # mas_apps["Final Cut Pro"]="424389933"
  # mas_apps["Logic Pro"]="634148309"
  # mas_apps["Affinity Photo 2"]="1606912748"

  # 为了演示，我们只安装 Infuse (如果您没买，它会提示购买)
  # 您可以取消下面的注释并填入您想安装的软件 ID
  # 查找 ID 方法: mas search "软件名"

  for app_name in "${!mas_apps[@]}"; do
    app_id="${mas_apps[$app_name]}"
    info "正在检查/安装 $app_name (ID: $app_id) ..."

    # 检查是否已安装
    if mas list | grep -q "$app_id"; then
      success "$app_name 已安装。"
    else
      # 尝试安装
      if mas install "$app_id"; then
        success "$app_name 安装成功！"
      else
        warn "$app_name 安装失败。可能原因：未购买、网络问题或 ID 错误。请手动在 App Store 安装。"
        # 尝试打开 App Store 该页面
        open "https://apps.apple.com/app/id$app_id"
      fi
    fi
  done
fi

# ------------------------------------------------------------------------------
# 5. 特殊处理：无 Homebrew/MAS 源的国产软件
# ------------------------------------------------------------------------------
step "正在处理需手动下载的国产/商业软件..."
declare -A manual_apps
# manual_apps["Douyin"]="https://www.douyin.com/"
# manual_apps["Bilibili"]="https://app.bilibili.com/"

for app_name in "${!manual_apps[@]}"; do
  warn "❌ $app_name 需手动下载。"
  open "${manual_apps[$app_name]}"
  sleep 1
done

# ------------------------------------------------------------------------------
# 6. Python 环境配置
# ------------------------------------------------------------------------------
step "配置 Python 环境..."
TARGET_PY_VERSION="3.10.0"
if ! pyenv versions | grep -q "$TARGET_PY_VERSION"; then
  info "正在安装 Python $TARGET_PY_VERSION ..."
  brew install openssl readline sqlite zlib xz tk &>/dev/null
  env PYTHON_CONFIGURE_OPTS="--with-openssl=$(brew --prefix openssl)" pyenv install "$TARGET_PY_VERSION" || error "Python 安装失败。"
fi
pyenv global "$TARGET_PY_VERSION"
success "Python 全局版本: $TARGET_PY_VERSION"

if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# ------------------------------------------------------------------------------
# 7. 收尾
# ------------------------------------------------------------------------------
echo ""
success "🎉 所有任务完成！"
echo ""
info "📝 后续建议："
echo "   1. 重启终端使配置生效。"
echo "   2. 检查 App Store 中是否有正在下载的应用。"
echo "   3. 手动安装浏览器中打开的国产软件。"
echo "   4. 运行 'nvim' 初始化编辑器。"
