# 初始化 MacOS

## chezmoi 的工作原理
<img width="754" height="560" alt="截屏2025-08-03 02 31 37" src="https://github.com/user-attachments/assets/3fddaabc-fde9-4c04-8a36-cfbc86ad253e" />

## 安装 brew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 更新 brew 国内源

```bash
# 1. 替换 Homebrew 主程序仓库
cd "$(brew --repo)"
git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git

# 2. 替换 homebrew-core (核心公式库)
cd "$(brew --repo homebrew/core)"
git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git

# 3. 替换 homebrew-cask (图形应用库)
cd "$(brew --repo homebrew/cask)"
git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
# 4. 更新 Homebrew 自身及软件列表
brew update
```

## 安装配置文件

```bash
brew install chezmoi
# 使用你的 dotfiles 仓库初始化 chezmoi，仓库将被保存到 ~/.local/share/chezmoi
chezmoi init https://github.com/YVastness/macos-dotfiles.git
# chezmoi 把仓库里的配置文件 copy 到对应的真实地址
chezmoi apply -v
```

## 初始化 MacOS

```bash
bash ~/.config/init/macos_init.sh
```
