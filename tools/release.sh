#!/usr/bin/env bash
# 打包可发布文件到 release/ 目录。
#
# 采用白名单机制：只有明确登记的文件才会进包，README、tools/、图标源图
# (modicon.png)、编辑器备份 (~ / #file#) 等开发用文件一律不进。
# 以后新增可发布文件（如新脚本、新贴图）时，在下面的 FILES 或 scripts 白名单里登记。
#
# 用法: ./tools/publish.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/release"

# 可发布的根目录文件
FILES="modinfo.lua modmain.lua modicon.tex modicon.xml"

rm -rf "$OUT"
mkdir -p "$OUT/scripts"

for f in $FILES; do
    if [ ! -f "$ROOT/$f" ]; then
        echo "缺少可发布文件: $f" >&2
        exit 1
    fi
    cp "$ROOT/$f" "$OUT/$f"
done

for f in "$ROOT"/scripts/*.lua; do
    [ -e "$f" ] || { echo "scripts/ 下没有 lua 文件" >&2; exit 1; }
    cp "$f" "$OUT/scripts/$(basename "$f")"
done

echo "已打包到 $OUT："
(cd "$OUT" && find . -type f -printf "%p  %s B\n" | sort)
