#!/bin/bash

# 配置
RULES_DIR="./smartdns"        # 修改为 smartdns 目录
TEMP_DIR="./smartdns/tmp"     # 保持临时目录不变

# 规则源配置
declare -A RULE_SOURCES=(
    ["adblock"]="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/reject-list.txt"
    ["gfwlist"]="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt"
    ["china"]="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt"
    ["apple_cn"]="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/apple-cn.txt"
    ["steam"]="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data/steam"
    ["global"]="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt"
)

# 下载函数
download_rule() {
    local url="$1"
    local output="$2"
    curl -sSL --connect-timeout 10 --max-time 30 "$url" -o "$output"
}

# 处理域名规则
process_domains() {
    local input="$1"
    local output="$2"
    local type="$3"

    case "$type" in
        "steam")
            grep -v '^#' "$input" | \
            sed -e 's/^full://; s/ @cn.*$//; s/ *$//; /^$/d' | \
            grep -E '^[a-zA-Z0-9][a-zA-Z0-9\.-]+\.[a-zA-Z]{2,}$' | sort -u > "$output"
            ;;
        *)
            sed -e 's/^full://; s/^domain://; s/^regexp://; /^#/d; /^$/d' "$input" | \
            grep -E '^[a-zA-Z0-9][a-zA-Z0-9\.-]+\.[a-zA-Z]{2,}$' | sort -u > "$output"
            ;;
    esac
}

# 主函数
main() {
    # 创建必要的目录
    mkdir -p "${TEMP_DIR}"

    # 更新所有规则
    for name in "${!RULE_SOURCES[@]}"; do
        echo "更新 ${name} 规则..."
        
        local temp_file="${TEMP_DIR}/${name}.tmp"
        local final_file="${RULES_DIR}/${name}.txt"
        
        if download_rule "${RULE_SOURCES[$name]}" "$temp_file"; then
            if [ "$name" = "steam" ]; then
                process_domains "$temp_file" "$final_file" "steam"
            else
                process_domains "$temp_file" "$final_file" "basic"
            fi
            echo "${name} 规则更新完成，共 $(wc -l < "$final_file") 条记录"
        else
            echo "${name} 规则下载失败"
        fi
    done
}

# 执行主函数
main