#!/usr/bin/env bash
# 从本机 DST 游戏脚本重新生成 scripts/mhr_vanilla.lua（原版 prefab 名单）。
#
# 用途：mod 默认只影响原版生物（配置 AFFECT_MODDED 可打开对其他 mod 生物的
# 影响），因此需要一份「当前游戏版本注册过的所有原版 prefab 名」的名单。
# 游戏大版本更新后（尤其是新增了生物的更新）建议重跑一次本脚本。
#
# 用法: ./tools/gen_vanilla_list.sh [DST安装目录]
#       默认目录: ~/.steam/steam/steamapps/common/Don't Starve Together

set -euo pipefail

# 默认目录用 glob 推断（路径里含撇号，不能直接写进 ${1:-...} 的默认值）
if [ $# -ge 1 ]; then
    DST="$1"
else
    DST=$(ls -d "$HOME"/.steam/steam/steamapps/common/Don*Starve*Together 2>/dev/null | head -n 1)
fi
BUNDLE="$DST/data/databundles/scripts.zip"
OUT="$(cd "$(dirname "$0")/.." && pwd)/scripts/mhr_vanilla.lua"
mkdir -p "$(dirname "$OUT")"

if [ ! -f "$BUNDLE" ]; then
    echo "找不到游戏脚本包: $BUNDLE" >&2
    echo "请把 DST 安装目录作为第一个参数传入。" >&2
    exit 1
fi

BUILD=$(cat "$DST/version.txt")
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
unzip -oq "$BUNDLE" -d "$WORK"

# prefab 文件里通过 Prefab("name", ...) 注册名字；一个文件可能注册多个 prefab。
# 玩家角色走 MakePlayerCharacter("name", ...) 宏，单独收集。
NAMES=$( { grep -rhoE 'Prefab\(\s*"[a-z0-9_]+"' "$WORK"/scripts/prefabs/*.lua; \
    grep -rhoE 'MakePlayerCharacter\(\s*"[a-z0-9_]+"' "$WORK"/scripts/prefabs/*.lua; } \
    | grep -oE '"[a-z0-9_]+"' | tr -d '"' | sort -u)
COUNT=$(echo "$NAMES" | wc -l)

{
    echo "-- 本文件由 tools/gen_vanilla_list.sh 自动生成，请勿手工编辑。"
    echo "-- 数据来源: DST build $BUILD ($(date +%F))，共 $COUNT 个原版 prefab。"
    echo "local NAMES = [["
    echo "$NAMES" | fold -s -w 90
    echo "]]"
    echo ""
    echo "local VANILLA = {}"
    echo "for name in string.gmatch(NAMES, \"%S+\") do"
    echo "    VANILLA[name] = true"
    echo "end"
    echo ""
    echo "return VANILLA"
} > "$OUT"

echo "已生成 $OUT ($COUNT 个 prefab, build $BUILD)"
