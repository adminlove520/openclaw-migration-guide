# OpenClaw 迁移指南

> 从本地迁移到 VPS / Codespaces 的完整指南

## 📚 文档目录

- [Codespaces 启动指南](./docs/Codespaces-OpenClaw启动指南.md)
- [OpenClaw 迁移手册](./docs/OpenClaw迁移手册.md)
- [迁移脚本](./scripts/migrate-openclaw.sh)

## 🚀 快速开始

### Codespaces

```bash
# 1. 安装 openclaw
npm install -g openclaw

# 2. 复制配置文件
# 复制 openclaw.json 到 ~/.openclaw/

# 3. 用 nohup 启动（不能用 systemd）
nohup openclaw gateway --verbose &

# 4. 检查
curl http://127.0.0.1:18789
```

### VPS

```bash
# 1. 安装 openclaw
npm install -g openclaw

# 2. 使用迁移脚本
./scripts/migrate-openclaw.sh /path/to/backup ~/.openclaw

# 3. 启动
openclaw gateway start
```

## 📖 详细文档

见 `docs/` 目录

## 🤝 贡献

欢迎提交 PR 和 Issue！

## 📝 许可证

MIT
