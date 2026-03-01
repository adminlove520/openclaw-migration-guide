#!/bin/bash
# OpenClaw 迁移脚本 - 从备份仓库复制到目标目录
# 用法: ./migrate.sh /path/to/backup/.openclaw /path/to/target/.openclaw

set -e

SOURCE_DIR="$1"
TARGET_DIR="$2"

if [ -z "$SOURCE_DIR" ] || [ -z "$TARGET_DIR" ]; then
    echo "用法: ./migrate.sh /path/to/backup/.openclaw /path/to/target/.openclaw"
    exit 1
fi

echo "=== OpenClaw 迁移脚本 ==="
echo "源目录: $SOURCE_DIR"
echo "目标目录: $TARGET_DIR"
echo ""

# 创建目标目录
mkdir -p "$TARGET_DIR"

# 需要复制的目录
DIRS=(
    "credentials"
    "identity"
    "skills"
    "cron"
    "memory"
    "agents"
    "browser"
    "canvas"
    "telegram"
)

# 需要复制的文件
FILES=(
    "openclaw.json"
)

echo "开始复制..."

# 复制文件
for file in "${FILES[@]}"; do
    if [ -f "$SOURCE_DIR/$file" ]; then
        cp "$SOURCE_DIR/$file" "$TARGET_DIR/"
        echo "✓ 复制: $file"
    else
        echo "✗ 跳过: $file (不存在)"
    fi
done

# 复制目录
for dir in "${DIRS[@]}"; do
    if [ -d "$SOURCE_DIR/$dir" ]; then
        cp -r "$SOURCE_DIR/$dir" "$TARGET_DIR/"
        echo "✓ 复制: $dir/"
    else
        echo "✗ 跳过: $dir/ (不存在)"
    fi
done

echo ""
echo "=== 迁移完成 ==="
echo ""
echo "注意: workspace 需要单独处理（可能包含 .git 或大文件）"
echo "如需复制 workspace，请手动执行:"
echo "  cp -r $SOURCE_DIR/workspace $TARGET_DIR/"
