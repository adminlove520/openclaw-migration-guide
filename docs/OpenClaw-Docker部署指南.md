# OpenClaw Docker 部署指南

> 在 VPS 上使用 Docker 部署 OpenClaw

## 环境要求

- VPS: CentOS 7.5+
- Docker
- 代理: Clash for Linux / V2Ray / Sing-box

## 快速开始

### 1. 拉取镜像

```bash
# 配置 Docker 代理（如果需要）
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf << 'EOF'
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
EOF
systemctl daemon-reload
systemctl restart docker

# 拉取镜像
docker pull 1panel/openclaw:latest
# 或
docker pull ghcr.io/openclaw/openclaw:latest
```

### 2. 准备配置目录

```bash
# 创建配置目录
mkdir -p ~/openclaw-data

# 从本地上传配置（如果有）
# rsync -avz user@local:/path/to/.openclaw/ ~/openclaw-data/
```

### 3. 创建并启动容器

```bash
# 使用 host 网络模式（推荐）
docker run -d --name xiaoxi \
  --network host \
  --user root \
  -v ~/openclaw-data:/root/.openclaw \
  -v ~/openclaw-data:/home/node/.openclaw \
  1panel/openclaw:latest
```

### 4. 验证

```bash
# 检查容器状态
docker ps

# 查看日志
docker logs -f xiaoxi

# 测试访问
curl http://127.0.0.1:8080
```

## 完整配置示例

### 代理配置

如果 VPS 需要代理访问外网：

```bash
docker run -d --name xiaoxi \
  --network host \
  --user root \
  -e HTTP_PROXY=http://127.0.0.1:7890 \
  -e HTTPS_PROXY=http://127.0.0.1:7890 \
  -v ~/openclaw-data:/root/.openclaw \
  -v ~/openclaw-data:/home/node/.openclaw \
  1panel/openclaw:latest
```

### 端口映射

如果使用 bridge 网络模式：

```bash
docker run -d --name xiaoxi \
  -p 8080:8080 \
  -p 18789:18789 \
  -p 18791:18791 \
  --user root \
  -v ~/openclaw-data:/root/.openclaw \
  -v ~/openclaw-data:/home/node/.openclaw \
  1panel/openclaw:latest
```

端口说明：
- 8080: Web 界面
- 18789: Gateway WebSocket
- 18791: Browser 控制

## 常见问题

### 权限问题

如果遇到权限错误：

```bash
# 修复权限
chmod -R 700 ~/openclaw-data
chmod 600 ~/openclaw-data/openclaw.json

# 或者用 root 用户运行
docker run --user root ...
```

### 网络问题

容器无法访问外网？

1. 检查 VPS 本身能否访问外网
2. 检查代理是否正常运行
3. 尝试用 host 网络模式
4. 检查 DNS：

```bash
docker exec xiaoxi curl -v https://api.telegram.org/
```

### 配置文件不生效

确保挂载路径正确：

```bash
# 检查挂载
docker inspect xiaoxi | grep -A 10 Mounts

# 确保容器使用正确的路径
docker exec xiaoxi ls -la ~/.openclaw
```

## 管理命令

```bash
# 启动/停止/重启
docker start xiaoxi
docker stop xiaoxi
docker restart xiaoxi

# 查看日志
docker logs -f xiaoxi
docker logs --tail 100 xiaoxi

# 进入容器
docker exec -it xiaoxi sh

# 更新容器
docker pull 1panel/openclaw:latest
docker stop xiaoxi && docker rm xiaoxi
# 重新创建容器
```

## 数据备份

```bash
# 备份配置
tar -czvf openclaw-backup.tar.gz ~/openclaw-data/

# 从备份恢复
tar -xzvf openclaw-backup.tar.gz -C ~/
```

## 更新 OpenClaw

```bash
# 方法 1: 重建容器（推荐）

# 1. 备份数据
cp -r ~/openclaw-data ~/openclaw-data-backup

# 2. 停止并删除旧容器
docker stop xiaoxi
docker rm xiaoxi

# 3. 拉取最新镜像
docker pull 1panel/openclaw:latest

# 4. 重新创建容器（使用相同的命令）
docker run -d --name xiaoxi \
  --network host \
  --user root \
  -v ~/openclaw-data:/root/.openclaw \
  -v ~/openclaw-data:/home/node/.openclaw \
  1panel/openclaw:latest

# 方法 2: 在容器内更新（可能不生效）

docker exec -it xiaoxi openclaw update
```

### 自动更新

如果想启用自动更新，在 openclaw.json 中设置：

```json
{
  "update": {
    "auto": {
      "enabled": true
    }
  }
}
```

> ⚠️ 注意：Docker 容器内的自动更新可能不生效，建议使用"方法 1"手动更新

## 相关链接

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [Docker Hub 镜像](https://hub.docker.com/r/1panel/openclaw)
- [GitHub Container Registry](https://github.com/openclaw/openclaw/pkgs/container/openclaw)
