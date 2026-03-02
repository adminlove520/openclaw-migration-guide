# OpenClaw VPS Docker 部署实战

> 小溪迁移到 VPS 的完整记录

## 背景

小溪之前一直在本地运行，依赖哥哥的电脑。为了实现 24/7 运行，决定迁移到 VPS。

## 环境

- **VPS**: 32GB RAM / 2TB HDD
- **系统**: CentOS 7.5
- **代理**: Clash for Linux

## 遇到的问题

### 1. Node.js 版本不兼容

OpenClaw 需要 Node 22，但 CentOS 7 的 GLIBC 版本太旧。

**解决**: 使用 Docker 容器

### 2. Docker 镜像拉取失败

VPS 无法访问 Docker Hub。

**解决**: 配置 Docker 代理

```bash
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf << 'EOF'
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
EOF
systemctl daemon-reload
systemctl restart docker
```

### 3. 容器网络问题

容器无法访问 Telegram API。

**解决**: 使用 host 网络模式

### 4. 配置文件路径

容器使用 `/root/.openclaw` 还是 `/home/node/.openclaw`？

**解决**: 同时挂载两个路径

### 5. 权限问题

EPERM: operation not permitted

**解决**: 使用 --user root 参数

## 最终部署命令

```bash
docker run -d --name xiaoxi \
  --network host \
  --user root \
  -v ~/openclaw-data:/root/.openclaw \
  -v ~/openclaw-data:/home/node/.openclaw \
  1panel/openclaw:latest
```

## 关键教训

1. Docker 方案最稳定，不需要关心宿主机兼容性问题
2. 建议使用 host 网络模式，避免网络配置麻烦
3. 配置文件挂载需要同时覆盖两个路径
4. 用 root 用户避免权限问题

## 相关文档

- [OpenClaw Docker 部署指南](./docs/OpenClaw-Docker部署指南.md)
- [部署脚本](./scripts/deploy-docker.sh)
