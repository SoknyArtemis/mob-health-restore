-- Mob Health Tuner（生物血量调整）：把敌对/中立生物的血量统一乘以系数
-- （默认 50%），在单人游戏中平衡原本为多人游戏设计的数值。
--
-- 实现方式：AddPrefabPostInitAny 在每个实体构造完成后触发（此时 prefab 已
-- 设置完血量和全部 tag），我们把该实体 health 组件的 SetMaxHealth 包装为
-- "设多少都先乘系数"，再对当前值应用一次。这样：
--   * 生成时设置的血量会被缩放；
--   * 之后任何代码再重设血量（帝王蟹镶嵌宝石重算、Boss 变身缩放等）也会被缩放；
--   * 只在服务端生效（客户端没有 health 组件，天然跳过）。

local TheNet = GLOBAL.TheNet

-- 系数固定 50%（设置界面不提供调整）；个别生物需要不同系数时，
-- 用 scripts/mhr_config.lua 的 OVERRIDE 表按 prefab 名指定。
local HEALTH_SCALE = 0.5
local BOSS_SCALE = 0.5
local AFFECT_MODDED = GetModConfigData("AFFECT_MODDED") or false
local VERBOSE = GetModConfigData("VERBOSE") or false

local config = require("mhr_config")
local EXCLUDE = config.EXCLUDE
local OVERRIDE = config.OVERRIDE
local VANILLA = require("mhr_vanilla")

-- 原版 prefab 判定用两条互补的证据：
-- 1) mhr_vanilla.lua 静态名单（从游戏脚本生成；部分用变量名注册的 prefab 抓不全）
-- 2) 运行时反查：不属于任何已加载 mod 的 prefab 就是原版的
--    （DST 的 mod prefab 全部记录在 ModManager.mods[i].Prefabs 里）
local ModManager = GLOBAL.ModManager

local function IsFromMod(name)
    if ModManager ~= nil and ModManager.mods ~= nil then
        for _, mod in pairs(ModManager.mods) do
            if mod.Prefabs ~= nil and mod.Prefabs[name] ~= nil then
                return true
            end
        end
    end
    return false
end

local function ShouldProcess(inst, prefab)
    if not TheNet:GetIsServer() then
        return false
    end
    if inst.components == nil or inst.components.health == nil then
        return false
    end
    if EXCLUDE[prefab] then
        return false
    end
    if not AFFECT_MODDED and not VANILLA[prefab] and IsFromMod(prefab) then
        return false
    end
    -- 玩家 / 宠物 / 墙体 / 建筑与巢穴（蜘蛛巢、蜂窝、狗窝等带 structure tag）
    -- 船与防撞栏（boat / boatbumper tag）是玩家载具部件，不属于生物
    if inst:HasTag("player")
        or inst:HasTag("critter")
        or inst:HasTag("wall")
        or inst:HasTag("structure")
        or inst:HasTag("boat")
        or inst:HasTag("boatbumper") then
        return false
    end
    return true
end

AddPrefabPostInitAny(function(inst)
    if inst == nil or inst.prefab == nil then
        return
    end
    local prefab = inst.prefab
    if not ShouldProcess(inst, prefab) then
        return
    end

    local health = inst.components.health
    local scale = OVERRIDE[prefab]
        or (inst:HasTag("epic") and BOSS_SCALE or HEALTH_SCALE)
    if scale == nil or scale <= 0 or scale >= 1 then
        return
    end

    local before = health.maxhealth
    if before == nil or before <= 0 then
        return
    end

    -- 包装后续的 SetMaxHealth，让生成后的任何重设也保持缩放
    local oldset = health.SetMaxHealth
    health.SetMaxHealth = function(self, amount)
        oldset(self, math.max(amount * scale, 1))
    end
    health:SetMaxHealth(before)

    -- 少数实体（帝王蟹钳/阶段怪等）开了 save_maxhealth，其上限会存档并在
    -- OnLoad 时直接赋值恢复（绕过上面的包装）。这里同样包装 OnLoad/OnSave：
    -- 存档时打上 mhr 标记，读档时只缩放没有标记的数据，保证跨会话幂等。
    local oldload = health.OnLoad
    health.OnLoad = function(self, data)
        if data ~= nil and data.maxhealth ~= nil and data.mhr ~= true then
            data.maxhealth = math.max(data.maxhealth * scale, 1)
        end
        return oldload(self, data)
    end
    local oldsave = health.OnSave
    health.OnSave = function(self)
        local data = oldsave(self)
        if data ~= nil then
            data.mhr = true
        end
        return data
    end

    if VERBOSE then
        print(string.format("[MHR] %s: maxhealth %g -> %g (scale %.2f)",
            prefab, before, health.maxhealth, scale))
    end
end)
