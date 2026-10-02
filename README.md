# 生物血量调整 Mob Health Tuner

《饥荒：联机版》服务端 mod：把敌对 / 中立生物的血量统一调整为 50%，在单人游戏中平衡原本为多人游戏设计的数值。

## 安装

把 [release](https://github.com/SoknyArtemis/mob-health-restore/releases) 里的 zip 解压到游戏 `mods/` 目录（保持 `mob-health-tuner` 目录名），创建世界时启用。纯服务端生效，进服玩家无需订阅。

## 配置

| 配置 | 默认 | 说明 |
|---|---|---|
| 影响其他 mod 的生物 | 否 | 默认只调整原版生物 |
| 日志输出 | 关 | 在服务器日志打印每次调整，排查用 |

个别生物想排除或用不同系数，编辑 `scripts/mhr_config.lua`（EXCLUDE / OVERRIDE 表）。

玩家、宠物、墙体、建筑、巢穴、船与纯友好生物（切斯特、格罗姆、阿比盖尔、沃比、伯尼、影子仆从等）不受影响。

## 维护

```bash
./tools/gen_vanilla_list.sh   # 游戏大版本更新后重新生成原版 prefab 名单
./tools/test_on_server.sh     # 本地服务器回归测试
./tools/release.sh            # 打包可发布文件到 release/
```

## 许可

[GPL-3.0](LICENSE)
