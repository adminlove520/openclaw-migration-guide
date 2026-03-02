#!/bin/bash

# OpenClaw Docker 部署脚本
# 用法: ./deploy-docker.sh [配置目录]

set -e

# 配置
CONTAINER_NAME="xiaoxi"
IMAGE="1panel/openclaw:latest"
DATA_DIR=${1:-$HOME/openclaw-data}

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 OpenClaw Docker 部署脚本${NC}"

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安装${NC}"
    exit 1
fi

# 创建配置目录
if [ ! -d "$DATA_DIR" ]; then
    echo -e "${YELLOW}📁 创建配置目录: $DATA_DIR${NC}"
    mkdir -p "$DATA_DIR"
fi

# 检查代理
if [ -n "$HTTP_PROXY" ]; then
    echo -e "${YELLOW}🌐 检测到代理: $HTTP_PROXY${NC}"
fi

# 停止并删除旧容器
if docker ps -a | grep -q $CONTAINER_NAME; then
    echo -e "${YELLOW}🛑 停止旧容器...${NC}"
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
fi

# 拉取最新镜像
echo -e "${YELLOW}📥 拉取镜像...${NC}"
docker pull $IMAGE

# 创建并启动容器
echo -e "${YELLOW}🔨 创建容器...${NC}"
docker run -d --name $CONTAINER_NAME \
    --network host \
    --user root \
    -e HTTP_PROXY=$HTTP_PROXY \
    -e HTTPS_PROXY=$HTTPS_PROXY \
    -v $DATA_DIR:/root/.openclaw \
    -v $DATA_DIR:/home/node/.openclaw \
    $IMAGE

# 等待启动
echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
sleep 10

# 检查状态
if docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${GREEN}✅ 部署成功!${NC}"
    echo -e ""
    echo -e "容器状态:"
    docker ps | grep $CONTAINER_NAME
    echo -e ""
    echo -e "查看日志: docker logs -f $CONTAINER_NAME"
else
    echo -e "${RED}❌ 部署失败${NC}"
    echo -e ""
    echo -e "日志:"
    docker logs $CONTAINER_NAME
    exit 1
fi
