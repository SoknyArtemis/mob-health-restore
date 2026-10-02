#!/usr/bin/env bash
# 生成「受影响生物全列表」：在离线集群里把游戏注册的每一个 prefab 都 spawn 一遍，
# mod 的 VERBOSE 日志（[MHR] 行）会精确记录每一个被处理的生物。
#
# 用途：游戏版本更新后，用它刷新 modinfo 描述里的生物列表。
# 前置与 test_on_server.sh 相同（本机 DST、离线集群 MHRTest）。
#
# 用法: ./tools/gen_affected_list.sh

set -uo pipefail

DST=$(ls -d "$HOME"/.steam/steam/steamapps/common/Don*Starve*Together 2>/dev/null | head -n 1)
if [ -z "$DST" ]; then
    echo "未找到 DST 安装目录" >&2
    exit 1
fi

CLUSTER=MHRTest
KLEI_DIR="$HOME/.klei/DoNotStarveTogether/$CLUSTER"
LOG=/tmp/mhr_genlist.log

# openSUSE 缺 libcurl-gnutls.so.4 的替代（同 test_on_server.sh）
LOCAL_LIBS=/tmp/mhr_libs
mkdir -p "$LOCAL_LIBS"
[ -e "$LOCAL_LIBS/libcurl-gnutls.so.4" ] || ln -sf /usr/lib64/libcurl.so.4 "$LOCAL_LIBS/libcurl-gnutls.so.4"
export LD_LIBRARY_PATH="$LOCAL_LIBS${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

if [ ! -f "$KLEI_DIR/cluster.ini" ]; then
    echo "缺少集群配置，请先运行一次 tools/test_on_server.sh" >&2
    exit 1
fi

# mod 实体就在游戏 mods 目录（~/Projects 里是软链），无需同步
cat > "$KLEI_DIR/Master/modoverrides.lua" <<'EOF'
return {
    ["mob-health-tuner"] = { enabled = true,
        configuration_options = { AFFECT_MODDED = false, VERBOSE = true } },
    ["mhr-genlist-harness"] = { enabled = true },
}
EOF

# harness：分批 spawn 全部注册 prefab，避免单帧卡死
HARNESS="$DST/mods/mhr-genlist-harness"
trap 'rm -rf "$HARNESS"' EXIT
mkdir -p "$HARNESS"
cat > "$HARNESS/modinfo.lua" <<'EOF'
name = "MHR GenList Harness"
description = "internal, do not publish"
author = "test"
version = "0.0.0"
api_version = 10
dst_compatible = true
all_clients_require_mod = false
client_only_mod = false
EOF
cat > "$HARNESS/modmain.lua" <<'EOF'
-- 注意：mod 加载时原版 prefab 尚未注册（mods.lua 先于 prefab 加载执行），
-- 名单必须在世界加载后（SimPostInit）才收集。
local names = nil
local i, total = 0, 0

local function step()
    if names == nil then
        names = {}
        for name in pairs(GLOBAL.Prefabs) do
            if not string.find(name, "MOD_", 1, true) then
                table.insert(names, name)
            end
        end
        table.sort(names)
        total = #names
        print("MHRGEN collected " .. total)
    end
    local t0 = GLOBAL.GetTime()
    while i < total and GLOBAL.GetTime() - t0 < 0.1 do
        i = i + 1
        local n = names[i]
        GLOBAL.pcall(function()
            local inst = GLOBAL.SpawnPrefab(n)
            if inst ~= nil then inst:Remove() end
        end)
    end
    print(string.format("MHRGEN %d/%d", i, total))
    if i < total then
        GLOBAL.TheWorld:DoTaskInTime(0.1, step)
    else
        print("MHRGEN DONE")
        GLOBAL.c_shutdown()
    end
end

AddSimPostInit(function()
    GLOBAL.TheWorld:DoTaskInTime(5, step)
end)
EOF

echo "启动专用服务器枚举全部 prefab（约 2-3 分钟）..."
: > "$LOG"
(
    cd "$DST/bin64" &&
        timeout 420 ./dontstarve_dedicated_server_nullrenderer_x64 \
            -console -cluster "$CLUSTER" -shard Master > "$LOG" 2>&1
) &
SERVER_PID=$!

echo -n "等待枚举完成"
for _ in $(seq 1 180); do
    if grep -q "MHRGEN DONE" "$LOG"; then break; fi
    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        echo
        echo "服务器提前退出，请检查 $LOG" >&2
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo
wait "$SERVER_PID" 2>/dev/null

echo
echo "===== 受影响生物（去重后的 [MHR] 行） ====="
grep -o "\[MHR\] [a-z0-9_]*:" "$LOG" | sort -u | sed 's/\[MHR\] //;s/:$//' | tr '\n' ' '
echo
echo
echo "共 $(grep -o '\[MHR\] [a-z0-9_]*:' "$LOG" | sort -u | wc -l) 种，完整日志: $LOG"
