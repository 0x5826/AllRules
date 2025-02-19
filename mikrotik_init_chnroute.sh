#!/bin/bash

set -x  # 启用调试模式，显示执行的每一步

path="./mikrotik"
listname_v4="chnroute_v4"
filename_v4="${listname_v4}.rsc"

# 创建 mikrotik 目录（如果不存在）
mkdir -p $path
echo "目录创建完成: $path"

# 下载 IP 列表并检查是否成功
echo "开始下载 IP 列表..."
chnroute_list_v4=$(curl -sSL https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt)
if [ -z "$chnroute_list_v4" ]; then
    echo "下载 IP 列表失败"
    exit 1
fi
echo "IP 列表下载成功"

# 创建临时文件
temp_file="${path}/temp.rsc"
echo "创建临时文件: $temp_file"
echo "/ip firewall address-list remove [/ip firewall address-list find list=$listname_v4]" > "$temp_file"
echo "/ip firewall address-list" >> "$temp_file"

# 处理 IP 列表
echo "开始处理 IP 列表..."
count=0
for chnroute_ipv4 in $chnroute_list_v4
do
    echo "add address=$chnroute_ipv4 disabled=no list=$listname_v4" >> "$temp_file"
    ((count++))
done
echo "处理完成，共处理 $count 条记录"

# 成功处理后，移动到最终文件
echo "移动临时文件到最终位置..."
mv "$temp_file" "$path/$filename_v4"
echo "完成！最终文件位置: $path/$filename_v4"