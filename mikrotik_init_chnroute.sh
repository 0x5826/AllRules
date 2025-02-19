#!/bin/bash

path="./mikrotik"
listname_v4="chnroute_v4"
filename_v4="${listname_v4}.rsc"

# 创建 mikrotik 目录（如果不存在）
mkdir -p $path

chnroute_list_v4=$(curl -sSL https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt)

echo "/ip firewall address-list remove [/ip firewall address-list find list=$listname_v4]" > $path/$filename_v4
echo "/ip firewall address-list" >> $path/$filename_v4
#echo "add address=10.0.0.0/8 disabled=no list=$listname_v4" >> $path/$filename_v4
#echo "add address=172.16.0.0/12 disabled=no list=$listname_v4" >> $path/$filename_v4
#echo "add address=192.168.0.0/16 disabled=no list=$listname_v4" >> $path/$filename_v4

for chnroute_ipv4 in $chnroute_list_v4
do
    echo "add address=$chnroute_ipv4 disabled=no list=$listname_v4" >> $path/$filename_v4
done