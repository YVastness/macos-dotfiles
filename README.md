# 初始化 MacOS

## chezmoi 的工作原理
<img width="754" height="560" alt="截屏2025-08-03 02 31 37" src="https://github.com/user-attachments/assets/3fddaabc-fde9-4c04-8a36-cfbc86ad253e" />

## 安装

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
