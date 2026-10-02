name = ChooseTranslationTable({
    "Mob Health Tuner", -- 非中英语言的回退项
    en = "Mob Health Tuner",
    zh = "生物血量调整 (Mob Health Tuner)",
    zht = "生物血量调整 (Mob Health Tuner)",
})

description = ChooseTranslationTable({
[[Adjusts hostile/neutral creature health to 50% across the board, rebalancing values originally designed for multiplayer for solo play.
Players, walls, structures, nests, boats and friendly creatures are unaffected.

This mod is in an early version; some omissions and issues may remain.
All adjustments can be manually edited in scripts/mhr_config.lua.

Server-side mod]],
    en = [[Adjusts hostile/neutral creature health to 50% across the board, rebalancing values originally designed for multiplayer for solo play.
Players, walls, structures, nests, boats and friendly creatures are unaffected.

This mod is in an early version; some omissions and issues may remain.
All adjustments can be manually edited in scripts/mhr_config.lua.

Server-side mod]],
    zh = [[把敌对 / 中立生物的血量统一调整为 50%，
以在单人游戏中平衡原本为多人游戏设计的血量数值，
玩家、墙体、建筑、巢穴、船与纯友好生物不受影响。

mod 尚在初期版本，可能有一些遗漏和问题。
所有调整可在 scripts/mhr_config.lua 中手动编辑。

服务端 mod]],
    zht = [[把敌对 / 中立生物的血量统一调整为 50%，
以在单人游戏中平衡原本为多人游戏设计的血量数值，
玩家、墙体、建筑、巢穴、船与纯友好生物不受影响。

mod 尚在初期版本，可能有一些遗漏和问题。
所有调整可在 scripts/mhr_config.lua 中手动编辑。

服务端 mod]],
})

author = "星華輝月"
version = "0.1.0"

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

all_clients_require_mod = false
client_only_mod = false

icon = "modicon.tex"
icon_atlas = "modicon.xml"

server_filter_tags = { "balance", "tweak" }

configuration_options = {
    {
        name = "AFFECT_MODDED",
        label = ChooseTranslationTable({
            "Affect modded creatures",
            en = "Affect modded creatures",
            zh = "影响其他 mod 的生物",
            zht = "影响其他 mod 的生物",
        }),
        hover = ChooseTranslationTable({
            "Only vanilla creatures are adjusted by default; creatures added by other mods will also be affected when enabled.",
            en = "Only vanilla creatures are adjusted by default; creatures added by other mods will also be affected when enabled.",
            zh = "默认只调整原版生物，开启后其他 mod 添加的生物也会受到影响。",
            zht = "默认只调整原版生物，开启后其他 mod 添加的生物也会受到影响。",
        }),
        options = {
            { description = ChooseTranslationTable({
                "No (default)", en = "No (default)", zh = "否（默认）", zht = "否（默认）",
            }), data = false },
            { description = ChooseTranslationTable({
                "Yes", en = "Yes", zh = "是", zht = "是",
            }), data = true },
        },
        default = false,
    },
    {
        name = "VERBOSE",
        label = ChooseTranslationTable({
            "Verbose logging",
            en = "Verbose logging",
            zh = "日志输出",
            zht = "日志输出",
        }),
        hover = ChooseTranslationTable({
            "Print every health adjustment to the server log (for debugging). Enable when investigating with c_spawn.",
            en = "Print every health adjustment to the server log (for debugging). Enable when investigating with c_spawn.",
            zh = "在服务器日志里打印每一次血量调整（调试用）。用 c_spawn 排查问题时打开。",
            zht = "在服务器日志里打印每一次血量调整（调试用）。用 c_spawn 排查问题时打开。",
        }),
        options = {
            { description = ChooseTranslationTable({
                "Off (default)", en = "Off (default)", zh = "关闭（默认）", zht = "关闭（默认）",
            }), data = false },
            { description = ChooseTranslationTable({
                "On", en = "On", zh = "开启", zht = "开启",
            }), data = true },
        },
        default = false,
    },
}
