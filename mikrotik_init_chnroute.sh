#!/bin/bash

path="./mikrotik"
listname_v4="chnroute_v4"
filename_v4="${listname_v4}.rsc"

# 创建 mikrotik 目录（如果不存在）
mkdir -p $path

# 下载 IP 列表并检查是否成功
chnroute_list_v4=$(curl -sSL https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt)
if [ -z "$chnroute_list_v4" ]; then
    echo "下载 IP 列表失败"
    exit 1
fi

# 创建临时文件
temp_file="${path}/temp.rsc"
echo "/ip firewall address-list remove [/ip firewall address-list find list=$listname_v4]" > "$temp_file"
echo "/ip firewall address-list" >> "$temp_file"

# 处理 IP 列表
for chnroute_ipv4 in $chnroute_list_v4
do
    echo "add address=$chnroute_ipv4 disabled=no list=$listname_v4" >> "$temp_file"
done

# 成功处理后，移动到最终文件
mv "$temp_file" "$path/$filename_v4"