# 生物血量调整 Mob Health Tuner

《饥荒：联机版》（Don't Starve Together）服务端 mod。

把敌对 / 中立生物的血量统一调整为 50%，以在单人游戏中平衡原本为多人游戏设计的血量数值。
玩家、墙体、建筑、巢穴、船与纯友好生物不受影响。

mod 尚在初期版本，可能有一些遗漏和问题。所有调整可在 `scripts/mhr_config.lua` 中手动编辑。

> Adjusts hostile / neutral creature health to 50% across the board, rebalancing
> values originally designed for multiplayer for solo play.
> Players, walls, structures, nests, boats and friendly creatures are unaffected.

## 安装

从 [Releases](https://github.com/SoknyArtemis/mob-health-restore/releases) 下载 zip，解压到游戏 `mods/` 目录（保持 `mob-health-tuner` 目录名），创建 / 编辑世界时在服务器 mod 中启用。纯服务端生效，进服玩家无需订阅。

## 配置

| 配置项 | 默认 | 说明 |
|---|---|---|
| 影响其他 mod 的生物 | 否 | 默认只调整原版生物，开启后其他 mod 添加的生物也会受到影响 |
| 日志输出 | 关 | 在服务器日志里打印每一次血量调整（调试用） |

## 声明

本 mod 在开发过程中使用了 AI 辅助（代码实现、自动化测试与图标制作），整体设计与最终定稿由作者 **星華輝月** 完成。

## 许可

[GPL-3.0](LICENSE)
