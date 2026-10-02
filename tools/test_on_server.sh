#!/usr/bin/env bash
# 在本地起一个离线专用服务器实测 mod。
#
# 专用服务器的 stdin 控制台不可脚本化，因此本脚本会向游戏 mods 目录写入一个
# 一次性的测试 harness mod（mhr-test-harness），在 world 加载完成后批量 spawn
# 生物并把血量打印为 "MHRTEST|prefab|值" 行，最后自动关服。
#
# 前置：本机装有 DST，且本 mod 已软链/复制到 <DST>/mods/mob-health-restore。
# 集群配置位于 ~/.klei/DoNotStarveTogether/MHRTest（首次运行自动创建）。
#
# 用法: ./tools/test_on_server.sh

set -uo pipefail

DST=$(ls -d "$HOME"/.steam/steam/steamapps/common/Don*Starve*Together 2>/dev/null | head -n 1)
if [ -z "$DST" ]; then
    echo "未找到 DST 安装目录" >&2
    exit 1
fi

CLUSTER=MHRTest
KLEI_DIR="$HOME/.klei/DoNotStarveTogether/$CLUSTER"
LOG=/tmp/mhr_server.log

# openSUSE 没有 libcurl-gnutls.so.4，用系统的 OpenSSL 版 libcurl 顶替
# （curl 对外 API 相同，仅 TLS 后端不同，DST 专用服务器社区通用解法）
LOCAL_LIBS=/tmp/mhr_libs
mkdir -p "$LOCAL_LIBS"
if [ ! -e "$LOCAL_LIBS/libcurl-gnutls.so.4" ]; then
    ln -sf /usr/lib64/libcurl.so.4 "$LOCAL_LIBS/libcurl-gnutls.so.4"
fi
export LD_LIBRARY_PATH="$LOCAL_LIBS${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# ---- 集群配置（幂等） ----
mkdir -p "$KLEI_DIR/Master"
if [ ! -f "$KLEI_DIR/cluster.ini" ]; then
    cat > "$KLEI_DIR/cluster.ini" <<'EOF'
[MISC]
CONSOLE_ENABLED = 1
[SHARD]
shard_enabled = true
[NETWORK]
cluster_name = MHRTest
offline_cluster = true
cluster_intention = survival
[GAMEPLAY]
game_mode = survival
EOF
fi
if [ ! -f "$KLEI_DIR/Master/server.ini" ]; then
    cat > "$KLEI_DIR/Master/server.ini" <<'EOF'
[SERVER]
is_master = true
name = Master
[NETWORK]
server_port = 10999
[STEAM]
master_server_port = 12347
authentication_port = 8767
[SHARD]
id = 1
EOF
fi
# 小世界，加快生成（只在生成新世界时生效；要重新生成可删除 Master/save 目录）
cat > "$KLEI_DIR/Master/worldgenoverride.lua" <<'EOF'
return {
    override_enabled = true,
    overrides = { world_size = "small" },
}
EOF

# 本 mod 的实体就住在游戏 mods 目录里（~/Projects 里只是软链），
# 无需任何同步步骤，脚本修改直接生效。
cat > "$KLEI_DIR/Master/modoverrides.lua" <<'EOF'
return {
    ["mob-health-tuner"] = { enabled = true,
        configuration_options = {
            AFFECT_MODDED = false,
            VERBOSE = true,
        } },
    ["mhr-test-harness"] = { enabled = true },
}
EOF

# ---- 一次性测试 harness mod（结束时清理，避免留在游戏 mod 列表里） ----
HARNESS="$DST/mods/mhr-test-harness"
trap 'rm -rf "$HARNESS"' EXIT
mkdir -p "$HARNESS"
cat > "$HARNESS/modinfo.lua" <<'EOF'
name = "MHR Test Harness"
description = "internal test harness, do not publish"
author = "test"
version = "0.0.0"
api_version = 10
dst_compatible = true
all_clients_require_mod = false
client_only_mod = false
EOF

# 待测生物清单（harness 会原样写进 lua）
# 注：koalefant 的可生成 prefab 是 koalefant_summer/winter；Rock Jaw 内部名是
# shark；Skittersquid 内部名是 squid；antlion/wobysmall 需要特定环境，spawn 会
# 报错（ERR），属预期，用于确认不影响其代码路径。
CREATURES=(deerclops bearger moose dragonfly beequeen crabking toadstool klaus
    minotaur malbatross antlion spiderqueen
    knight bishop rook warg leif werepig krampus tallbird teenbird
    beefalo koalefant_summer walrus rocky grassgator merm
    spider pigman bunnyman hound firehound rabbit perd bee butterfly crow
    fruitfly lordfruitfly cookiecutter shark gnarwail squid waterplant
    chester glommer abigail spiderden wall_wood winona_catapult smallbird
    wobysmall bernie_active shadowwaxwell otterden)

LIST_LUA=$(printf '"%s",' "${CREATURES[@]}")

cat > "$HARNESS/modmain.lua" <<EOF
local creatures = {$LIST_LUA}

local function run()
    print("MHRTEST BEGIN")
    for _, name in ipairs(creatures) do
        local ok, e = GLOBAL.pcall(GLOBAL.SpawnPrefab, name)
        local hp = "ERR"
        if ok and e ~= nil and e.components ~= nil and e.components.health ~= nil then
            hp = tostring(e.components.health.maxhealth)
            e:Remove()
        elseif ok and e == nil then
            hp = "SPAWNFAIL"
        end
        print("MHRTEST|" .. name .. "|" .. hp)
    end
    print("MHRTEST END")
    GLOBAL.c_shutdown()
end

AddSimPostInit(function()
    GLOBAL.TheWorld:DoTaskInTime(5, run)
end)
EOF

# ---- 跑服务器 ----
echo "启动专用服务器（首次需生成世界，约 1 分钟）..."
: > "$LOG"
(
    cd "$DST/bin64" &&
        timeout 420 ./dontstarve_dedicated_server_nullrenderer_x64 \
            -console -cluster "$CLUSTER" -shard Master > "$LOG" 2>&1
) &
SERVER_PID=$!

echo -n "等待测试输出"
for _ in $(seq 1 150); do
    if grep -q "MHRTEST END" "$LOG"; then break; fi
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
echo "===== 测试结果 ====="
grep "MHRTEST" "$LOG" | sed 's/^.*MHRTEST/MHRTEST/' | sort -u
echo
echo "[MHR] 调试行数量: $(grep -c "\[MHR\]" "$LOG")"
echo "完整日志: $LOG"
