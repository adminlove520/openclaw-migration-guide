# Codespaces 运行 OpenClaw 注意事项

## 启动方式

在 Codespaces 上，不能用 systemd，需要用 nohup 后台运行：

```bash
# 后台启动 Gateway
nohup openclaw gateway --verbose &

# 检查是否启动成功
curl http://127.0.0.1:18789

# 查看日志
tail -f nohup.out
```

## 常见问题

### Gateway 启动失败

- **症状**：openclaw gateway restart 失败，提示 systemd not found
- **原因**：Codespaces 容器不支持 systemd
- **解决**：使用 nohup 后台启动

### Workspace 路径问题

- **症状**：配置里的路径是 Windows 格式 `C:\Users\...`
- **解决**：删除 workspace 配置项，让它用默认路径

### 配置文件问题

- **症状**：Gateway 启动后立即关闭
- **可能原因**：
  - browser/ 配置有 Windows 路径
  - skills/ 有不兼容的依赖
- **解决**：先删掉这些目录，只保留核心配置启动，成功后再逐个添加

## 推荐的启动流程

```bash
# 1. 安装 openclaw
npm install -g openclaw

# 2. 配置 openclaw.json（删除 workspace 等 Windows 路径）

# 3. 后台启动
nohup openclaw gateway --verbose &

# 4. 检查
curl http://127.0.0.1:18789
```
