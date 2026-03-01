# OpenClaw 迁移手册（本地 → VPS / Codespaces）

> 本手册适用于将 OpenClaw 从一台机器迁移到另一台机器（VPS、Codespaces 等）

---

## 📋 迁移前准备

### 1.1 确认目标机器环境

- **操作系统**：Linux (Ubuntu 20.04+) / macOS / Windows Server
- **必备软件**：
  - Node.js 18+
  - Git
  - PM2 (可选，用于后台运行)

### 1.2 备份源机器的 .openclaw 目录

```bash
# 在源机器上执行
cp -r ~/.openclaw ~/openclaw-backup
```

---

## 📦 需要迁移的文件

### 必须迁移 ✅

| 文件/目录 | 说明 |
|----------|------|
| `openclaw.json` | 核心配置文件 |
| `credentials/` | API 凭据（敏感！） |
| `identity/` | 身份配置 |
| `workspace/` | 工作空间（记忆、文档） |
| `skills/` | 已安装的技能 |
| `memory/` | 记忆文件 |
| `cron/` | 定时任务配置 |
| `agents/` | Agent 配置 |

### 可选迁移

| 文件/目录 | 说明 |
|----------|------|
| `browser/` | 浏览器配置 |
| `canvas/` | Canvas 配置 |
| `telegram/` | Telegram 配置 |
| `extensions/` | 已安装的插件 |

### 不需要迁移 ❌

| 文件/目录 | 说明 |
|----------|------|
| `logs/` | 日志文件，无需 |
| `*.bak` | 备份文件 |
| `node_modules/` | 重新安装即可 |
| `extensions/` | 重新安装即可 |

---

## 🛠️ 迁移步骤（逐个执行）

### 步骤 1：安装 OpenClaw

```bash
# 在目标机器上安装 OpenClaw
npm install -g openclaw

# 或使用 npx
npx openclaw gateway install
```

### 步骤 2：传输配置文件

```bash
# 方法一：使用 scp（Linux/macOS）
scp -r user@source:~/.openclaw/openclaw.json user@target:~/.openclaw/

# 方法二：使用 Git 仓库（推荐）
# 1. 创建私有仓库存储配置
# 2. 推送配置到仓库
# 3. 在目标机器克隆

# 方法三：手动复制（如果可以访问源机器文件系统）
```

### 步骤 3：传输凭据

```bash
# 传输 credentials 目录（包含敏感 API keys）
scp -r user@source:~/.openclaw/credentials user@target:~/.openclaw/
```

⚠️ **注意**：凭据文件包含敏感信息，建议：
- 使用加密传输
- 或手动复制粘贴

### 步骤 4：传输工作空间

```bash
# 如果 workspace 是普通文件夹
scp -r user@source:~/.openclaw/workspace user@target:~/.openclaw/

# 如果 workspace 是 Git 子仓库
# 1. 先在源机器解除子仓库
cd ~/.openclaw/workspace
rm -rf .git  # 删除子仓库（会丢失历史）
cd ..
git add workspace
git commit -m "convert workspace to regular folder"
git push
# 2. 然后再传输
```

### 步骤 5：传输其他配置

```bash
# 传输 skills
scp -r user@source:~/.openclaw/skills user@target:~/.openclaw/

# 传输 memory
scp -r user@source:~/.openclaw/memory user@target:~/.openclaw/

# 传输 cron
scp -r user@source:~/.openclaw/cron user@target:~/.openclaw/

# 传输 agents
scp -r user@source:~/.openclaw/agents user@target:~/.openclaw/
```

---

## ⚙️ 目标机器配置

### 6.1 安装依赖

```bash
# 安装 skills 依赖（如果有）
cd ~/.openclaw/skills
npm install

# 或使用 openclaw
openclaw skills install
```

### 6.2 配置环境变量

检查以下环境变量是否需要设置：

```bash
# Telegram Bot Token
export TELEGRAM_BOT_TOKEN="your_token"

# OpenAI API Key
export OPENAI_API_KEY="your_key"

# MiniMax API Key
export MINIMAX_API_KEY="your_key"
```

### 6.3 启动 OpenClaw

```bash
# 测试启动
openclaw gateway start

# 后台运行（使用 PM2）
pm2 start "openclaw gateway start" --name openclaw
pm2 save
```

---

## 🔧 常见问题

### Q1: workspace 里有 .git 导致无法复制？

**解决方案**：
```bash
# 方法一：删除 .git（会丢失历史）
cd ~/.openclaw/workspace
rm -rf .git

# 方法二：保留 .git，只复制文件
cp -r workspace/* target/workspace/
```

### Q2: 凭据文件权限问题？

**解决方案**：
```bash
chmod 700 ~/.openclaw/credentials
chmod 600 ~/.openclaw/credentials/*
```

### Q3: 目标机器缺少依赖？

**解决方案**：
```bash
# 检查 Node.js 版本
node --version  # 需要 18+

# 升级 Node.js（如果需要）
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

---

## ✅ 迁移检查清单

- [ ] openclaw.json 已传输
- [ ] credentials 已传输
- [ ] identity 已传输
- [ ] workspace 已传输
- [ ] skills 已传输
- [ ] memory 已传输
- [ ] cron 已传输
- [ ] agents 已传输
- [ ] 依赖已安装
- [ ] Gateway 可以启动

---

## 📝 迁移后注意事项

1. **更新配置**：如果 IP、域名等有变化，更新 `openclaw.json`
2. **检查定时任务**：cron 任务可能需要重新注册
3. **测试消息发送**：确保 Telegram/Discord 等渠道正常
4. **检查日志**：查看是否有错误

---

## 🔄 回滚方案

如果迁移失败，回滚到之前的状态：

```bash
# 删除新配置
rm -rf ~/.openclaw

# 恢复备份
cp -r ~/openclaw-backup ~/.openclaw
```

---

*手册版本：2026-03-01*
