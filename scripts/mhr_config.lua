-- Mob Health Tuner（生物血量调整）手工配置：排除名单与个别生物的专属系数。
-- 想让某个生物不受影响，在 EXCLUDE 里加一行；想让某个生物用不同系数，
-- 在 OVERRIDE 里加一行（优先级高于 epic/普通系数）。

local MHR = {}

-- 完全不受影响的 prefab：
-- 纯友好生物 / 玩家造物 / 有特殊血量系统的单位。
-- 注意：玩家、宠物(Critter)、墙体、建筑/巢穴(spiderden 等带 structure tag)
-- 已在 modmain 里按 tag 自动排除，不必写在这里。
MHR.EXCLUDE = {
    chester         = true, -- 切斯特
    hutch           = true, -- 哈奇
    glommer         = true, -- 格罗姆
    abigail         = true, -- 阿比盖尔（随温蒂成长的专属血量系统）
    wobysmall       = true, -- 沃比（小狗形态）
    wobybig         = true, -- 沃比（大狗形态）
    bernie_active   = true, -- 伯尼（激活）
    bernie_inactive = true, -- 伯尼（未激活）
    bernie_big      = true, -- 大伯尼
    shadowwaxwell   = true, -- 麦斯威尔的影子仆从
    smallbird       = true, -- 小鸟（友方雏鸟；青少年鸟 teenbird 不在此列，正常受系数影响）
    winona_catapult = true, -- 薇诺娜投石机（玩家造物）
    hermitcrab      = true, -- 珍珠（隐居蟹婆婆）
    wagstaff_npc    = true, -- 瓦格斯塔夫博士
    -- 巢穴类：其余巢穴（蜘蛛巢/蜂窝/狗窝等）带 structure tag 已被自动排除，
    -- 以下没有该 tag，在此显式排除
    otterden        = true, -- 水獭窝
    spiderhole      = true, -- 蛛穴（喷吐蛛的巢）
    dropperweb      = true, -- 蛛网（喷吐蛛的网）
    -- 玩家召唤的友好帮手 / 玩家造物 / 血量被游戏机制挪用的对象
    ticoon            = true, -- 大虎（藏宝图寻宝浣熊）
    polly_rogers      = true, -- 波莉·罗杰（寻宝鹦鹉）
    lavae_pet         = true, -- 岩浆虫宠物（玩家孵化）
    wormwood_carrat   = true, -- 沃姆伍德技能宠物：胡萝卜
    wormwood_fruitdragon = true, -- 沃姆伍德技能宠物：果蜥龙
    wormwood_lightflier  = true, -- 沃姆伍德技能宠物：光翼虫
    mermking          = true, -- 鱼人王（沃特建造的友方单位）
    friendlyfruitfly  = true, -- 友好果蝇（农田帮手）
    wortox_decoy      = true, -- 沃托克斯的替身
    shadowworker      = true, -- 麦斯威尔影子仆从：工人
    shadowdigger      = true, -- 麦斯威尔影子仆从：挖掘者
    shadowdancer      = true, -- 麦斯威尔影子仆从：舞者
    shadowlumber      = true, -- 麦斯威尔影子仆从：伐木工
    shadowminer       = true, -- 麦斯威尔影子仆从：矿工
    shadowprotector   = true, -- 麦斯威尔影子仆从：守卫
    shadowduelist     = true, -- 麦斯威尔影子仆从：决斗者
    dummytarget       = true, -- 靶子（玩家部署的练习目标）
    dummytarget_lunar = true, -- 靶子（月亮）
    dummytarget_shadow = true, -- 靶子（暗影）
    boatrace_seastack = true, -- 龙舟竞赛活动障碍物
    boatrace_seastack_monkey = true, -- 龙舟竞赛活动障碍物（猴子礁）
    deck_of_cards     = true, -- 牌堆（血量被游戏当计数器用，绝不能调）
    player_hosted     = true, -- 被附身的尸体（与真实玩家关联的实体）
    lavaarena_bernie  = true, -- 伯尼（熔炉活动版，生存模式不可生成）
    -- 敌对障碍物 / 可破坏场景物（不是生物）
    ruins_bowl        = true, -- 遗迹碗
    ruins_chipbowl    = true, -- 遗迹小碗
    ruins_plate       = true, -- 遗迹盘子
    ruins_rubble_chair = true, -- 遗迹残椅
    ruins_rubble_table = true, -- 遗迹残桌
    ruins_rubble_vase  = true, -- 遗迹残瓶
    ruins_table       = true, -- 遗迹桌
    ruins_vase        = true, -- 遗迹瓶
    sandblock         = true, -- 蚁狮沙块
    sandspike_med     = true, -- 蚁狮沙刺（中）
    sandspike_short   = true, -- 蚁狮沙刺（短）
    sandspike_tall    = true, -- 蚁狮沙刺（高）
    crabking_icewall  = true, -- 帝王蟹冰墙
    -- 1 血物品（调整无实际影响，排除保持干净）
    pumpkin_lantern   = true, -- 南瓜灯
    balloon           = true, -- 气球
    balloonhat        = true, -- 气球帽
    balloonparty      = true, -- 派对气球
    balloonspeed      = true, -- 加速气球
    balloonvest       = true, -- 气球背心
}

-- 个别生物的专属系数，例如：
-- MHR.OVERRIDE = {
--     beequeen = 0.75,   -- 蜂后单独用 75%
--     minotaur = 0.25,   -- 远古守护者单独用 25%
-- }
MHR.OVERRIDE = {}

return MHR
