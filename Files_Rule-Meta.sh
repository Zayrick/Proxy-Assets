#!/bin/bash

# 临时目录和最终目录
TEMP_DIR="/tmp/meta_temp"
FINAL_DIR="/root/Shared-Files/rule-set/repo"
# GitHub 仓库信息
REPO="MetaCubeX/meta-rules-dat"
BRANCH="meta"

# Bark 配置
BARK_KEY="H7gKu6Pm2KtdrunEALTZ6R"
BARK_URL="https://api.day.app/$BARK_KEY"
TITLE="规则仓库更新失败"
BODY="克隆仓库 $REPO ($BRANCH) 失败，请检查网络或GitHub状态"
LEVEL="active"

# 确保目录存在
mkdir -p "$TEMP_DIR"
mkdir -p "$FINAL_DIR"

# 开始下载
echo "开始下载 $REPO ($BRANCH) 分支的文件..."

# 清空临时目录
rm -rf "$TEMP_DIR"/*

# 克隆仓库（只克隆最近一次提交以节省带宽和时间）
echo "正在克隆仓库 $REPO ($BRANCH) 分支..."
git clone --depth 1 --branch "$BRANCH" "https://cdn.oxiz.xyz/github.com/$REPO.git" "$TEMP_DIR" 2>&1

# 如果克隆失败，发送 Bark 通知并退出
if [ $? -ne 0 ]; then
    echo "克隆仓库失败，发送 Bark 通知..."
    curl -X "POST" "$BARK_URL" \
         -H 'Content-Type: application/json; charset=utf-8' \
         -d "{
             \"title\": \"$TITLE\",
             \"body\": \"$BODY\",
             \"level\": \"$LEVEL\",
             \"sound\": \"minuet\",
             \"group\": \"Meta规则更新失败\"
         }"
    exit 1
fi

# 处理 geo/geoip/classical/ 目录中的 list 文件
LIST_DIR="$TEMP_DIR/geo/geoip/classical"
if [ -d "$LIST_DIR" ]; then
    echo "正在转换 IPv6 规则格式..."
    
    find "$LIST_DIR" -type f -name "*.list" | while read -r file; do
        sed -i -E 's/^(IP-CIDR,)([^,]*:)/IP-CIDR6,\2/' "$file"
    done
    
    echo "IPv6 规则转换完成"
else
    echo "目录 $LIST_DIR 不存在，跳过 IPv6 规则转换"
fi

echo "开始处理 geo/geoip/classical/ 目录中的 list 文件..."
# 处理 asn/ 目录中的 list 文件
ASN_DIR="$TEMP_DIR/asn"
ASN_CLASSICAL_DIR="$ASN_DIR/classical"

# 确保 asn/classical 目录存在
mkdir -p "$ASN_CLASSICAL_DIR"

echo "开始复制 list 文件到 $ASN_CLASSICAL_DIR..."
# 查找并复制 list 文件
find "$ASN_DIR" -maxdepth 1 -type f -name "*.list" | while read -r file; do
    cp "$file" "$ASN_CLASSICAL_DIR"/
done
echo "文件复制完成"

# 处理移动后的 list 文件
find "$ASN_CLASSICAL_DIR" -type f -name "*.list" | while read -r file; do
    sed -i -E 's/^([^#].*)$/IP-CIDR,\1/' "$file"  # 默认增加 "IP-CIDR,"
    sed -i -E 's/^IP-CIDR,([^,]*:)/IP-CIDR6,\1/' "$file"  # 如果包含 ":"，替换为 "IP-CIDR6,"
done

echo "ASN 目录处理完成"

# 删除 git 目录以节省空间
rm -rf "$TEMP_DIR/.git"

# 复制所有文件到最终目录
echo "正在复制文件到目标目录: $FINAL_DIR"
rm -rf "$FINAL_DIR"/*  # 清空目标目录
cp -r "$TEMP_DIR"/* "$FINAL_DIR"/

# 清理临时目录
rm -rf "$TEMP_DIR"

echo "下载和更新完成，总文件数: $(find "$FINAL_DIR" -type f | wc -l)"
echo "==============================================="
