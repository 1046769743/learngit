--
-- Author: ZhangYanguang
-- Date: 2015-12-16
--
-- Vip 配表表工具类

FuncCommon = FuncCommon or { }

--这个配置的顺序必须和策划保持一致,方便后期检查和核对. key的命名保持现状
--新的命名应该是 key 是value的大写
FuncCommon.SYSTEM_NAME = {
    PVE = "pve",                    --common--副本系统
    MAIN_LINE_QUEST = "mainlineQuest",  -- 主线任务
    TOWER = "tower",                    --爬塔
    TRAIL = "trial",                    --试炼
    TREASURE_COMBINE = "treasureCombine",-- 法宝合成
    PVP = "pvp",                    -- 竞技场
    LOTTERY = "lottery", --三皇台
    TREASURE_NEW = "treasure",  -- 新法宝
    ROMANCE = "elite", --奇缘
    ROMANCE_INTERACT = "romance_interact" ,  --奇缘npc
    CHAR = "char", --主角 
    BAG = "bag", --包裹
    EVERY_DAY_QUEST = "everydayQuest",  -- 每日任务
    SHOP_1 = "shop1",   -- 商城1 永安当铺
    SHOP_2 = "shop2",   -- 商城2 璎珞斋
    SHOP_3 = "shop3",   -- 商城3 承天剑台
    PULSE = "pulse",                -- 主角灵脉
    GAMBLE = "gamb",                --赌坊
    CHAT="chat",        --聊天
    STARLIGHT = "starlight",--星耀
    FRIEND="friend",    --好友系统
    NATAL = "treasureNatal",        --本命法宝
    TALENT = "talent",              --天赋
    GOD = "god", --神明
    SIGN = "sign", --签到
    PARTNER = "partner",            --伙伴系统
    PARTNER_ZHUANGBEI = "partnerEquipment",     --伙伴装备
    STARSOUL = "starSoul", --星魂
    COLLECT = "collect",    --收集
    ALCHEMY = "alchemy",    --炼蛊皿 
    DELEGATE = "delegate",  -- 挂机系统
    LINEUP = "teaminfo",    -- 查看阵容
    practice = "practice",  --修炼仙术
    GARMENT = "garment",    --主角时装
    PARTNER_SHENGJI = "promote", --伙伴升级
    ARRAY = "array",        --布阵
    CHANGE = "change" ,     --战斗换阵
    AUTOMATIC = "automatic",    --自动战斗
    CHAR_QUALITY = "quality",    -- 主角升品
    PARTNER_QUICKQUALITY = "quickQuality",
    PARTNER_QUALITY = "trait", -- 伙伴升品
    MAIL = "mail",              --邮件
    PARTNER_SKILL = "magic", -- 伙伴技能界面 
    PARTNERSKIN = "partnerSkin",    --伙伴皮肤
    tuturial_Star = "tuturial_Star", -- 新手引导时伙伴升星
    BATTLESPEEDTWO = "speedTwo",  --战斗双倍加速
    BATTLEPAUSE = "pause",  --暂停按钮
    PARTNER_SHENGXING = "star",     -- 伙伴升星
    TITLE = "title" ,   --称号
    LOVE = "love" ,     --情缘
    CIMELIA = "cimelia",    --神器
    SHOP_9 = "shop9" ,   --神器商店
    QUEST = "mainlineQuest", --目标任务单独名称
    SHAREBOSS = "shareBoss", --共享副本
    GUILD = "guild",   --仙盟
    FIVESOUL = "fivesoul", --五灵
    MISSION = "mission",-- 六界轶事
    SHOP_6 = "shop6",
    SHOP_7 = "shop7",   --灵石商店
    ELITE = "elite",    ---精英
    CHARSTAR = "charStar", --主角升星
    BATTLESPEEDTHREE = "speedThree",  --战斗三倍速
    PLOT_EXIT = "plotExit" ,--剧情退出
    PLOT_FAST = "plotFast",--剧情快进
    HAPPYSIGN = "happySign", --七登
    CROSSPEAK = "crossPeak",-- 巅峰竞技场
    WONDERLAND = "wonderLand", -- 须臾仙境
    SPFOOD = "spFood",     --临取体力
    COMMENT = "comment",   --- 关卡评论
    WONDER_SHOP = "shop12", --须臾商店
    ENDLESS = "endless", ---无底深渊
    EVERYDAYTARGET = "everydayTarget",--每日目标
    RING = "ring",   --跑环任务
    EQUIPAWAKE = "equipmentAwake",-- 装备觉醒
    RETRIEVE = "retrieve",--资源找回
    FIRSTCHARGE = "firstCharge", --首充
    GUILDBOSS = "guildBoss",
    MEMORYCARD = "memory", --情景卡
    QUESTION = "question", --问卷调查
    RANKLIST = "ranklist", --排行榜
    MALL = "mall",   --商城
    MONTHCARD = "monthCard",  ---月卡
    GUILDTASK = "guildTask",  --仙盟任务
    HANDBOOK= "handbook", --名册
    GUILDACTIVITY = "guildactivity", --仙盟酒家
    TRAVELER = "traveler",--六界游商
    BIOGRAPHY = "biography",--奇侠传记
}

--满足的条件
FuncCommon.CONDITION_TYPE = {
    LEVEL = 1,      --等级条件
    STATE = 2,      --境界    
    VIP = 3,        --vip 级别
    STAGE = 4,      --主线进度
    ELITE = 5,      --精英进度
    INTERACT = 6,   --奇缘指定NPC是否开启
    QUEST_GET = 8,  --任务已经领取
    STAR_CHEST = 9, --星际宝箱
}
--系统对应的view 和 name 
FuncCommon.SYSTEM_TO_VIEW_NAME = {
    love = "NewLoveMainView",
    elite = "EliteView",
    pvp = "ChallengeView",
    treasure = "TreasureMainView",
    tower = "WorldMainView",
    bag = "ItemListView",
    lottery =  "GatherSoulMainView",--"NewLotteryMainView",
    pve = "WorldMainView",
    shop1 = "ShopView",
    chat = "ChatMainView",
    guild = "GuildCreateAndAddView",
    shareBoss = "ShareBossMainView",
}
--系统对应的 name和 view 
FuncCommon.SYSTEM_VIEW_TO_NAME = {
    NewLoveMainView = {"love"},
    TreasureMainView = {"treasure"},
    TowerMainView = {"tower"},
    ItemListView = {"bag"},
    GatherSoulMainView = {"lottery"},
    WorldMainView = {"pve"},
    ChatMainView = {"chat"},
    -- CheckTeamFormationView = "teaminfo",-- viewlineup 
    ArenaMainView = {"pvp"},
    NewSignView = {"sign"},
    EliteMainView = {"elite"},                -- 精英
    -- PlayerInfoView = "playerinfo",      -- 玩家详情
    GarmentMainView = {"garment"},          --- 主角时装
    PartnerSkillView = {"magic"},          -- 伙伴技能
    PartnerCharSkillView = {"magic"},     -- 主角技能
    PartnerUpQualityView = {"trait"},    -- 奇侠升品
    PartnerUpgradeView = {"promote"},    -- 奇侠升级
    PartnerUpStarView = {"star"},       -- 奇侠升星
    PartnerView = {"partner"},      -- 奇侠
    PartnerEquipmentEnhanceView = {"partnerEquipment"},   --奇侠装备
    ShopView = {"shop1"}, -- 商店开启是以shop1 为准
    PartnerSkinMainView = {"partnerSkin"},        ---伙伴皮肤
    WorldPVEListView = {"pve"},
    EliteLieBiaoView = {"elite"},
    ChatMainView = {"chat"},
    -- QuestMainView = "mainlineQuest",
    QuestMainView = {
        "mainlineQuest",
        "everydayQuest",
    },
    WuXingTeamEmbattleView =    { "array" },
    ShareBossMainView = {"shareBoss"},
    WuLingMainView =  {"fivesoul"}
}



FuncCommon.GETWAY_TYPE = {
    TYPE_1 = 1,     --一级主系统
    TYPE_2 = 2,     --PVE
    TYPE_3 = 3,     --不显示明细的特殊类型
    TYPE_4 = 4,     --无底深渊类型跳转
}

-- 二进制位表示战斗结果的星级及完成了哪个条件
FuncCommon.battleStarCfg = {
    -- 一星
    [1] = {1,{0,0,1}},
    [2] = {1,{0,1,0}},
    [4] = {1,{1,0,0}},

    -- 二星
    [3] = {2,{0,1,1}},
    [5] = {2,{1,0,1}},
    [6] = {2,{1,1,0}},

    -- 三星
    [7] = {3,{1,1,1}},
} 

FuncCommon.numMap = {
    [0] = "十",
    [1] = "一",
    [2] = "二",
    [3] = "三",
    [4] = "四",
    [5] = "五",
    [6] = "六",
    [7] = "七",
    [8] = "八",
    [9] = "九",
}

FuncCommon.CostType = {
    BUY = 1,
    REFRESH = 2,
}

-- 玩法增量 产自类型
FuncCommon.additionFromType = {
    CARD = 1,   -- 月卡
    GUILD = 2,  -- 仙盟
}

-- 特权类型
FuncCommon.additionType = {
    addition_trialA = 1 ,  -- 山神试炼奖励
    addition_trialB = 2 ,  -- 火神试炼奖励
    addition_trialC = 3 ,  -- 盗宝者试炼奖励
    addition_PVPEveryDayReward = 4 ,  -- 等仙台每日奖励
    addition_buyCoin = 5 ,  -- 购买铜钱获取量
    -- addition_wandLand = 6 ,  -- 须臾仙元产量

    decrement_refreshShop_stone = 7 ,  -- 灵石商店刷新消耗
    decrement_refreshShop_1 = 8 ,  -- 杂货商店刷新消耗
    decrement_refreshShop_pvp = 9 ,  -- 等仙台商店刷新消耗
    decrement_refreshShop_trial = 10 ,  -- 试炼商店刷新消耗
    decrement_refreshShop_artifact = 11 ,  -- 神器商店刷新消耗
    decrement_refreshShop_tower = 12 ,  -- 锁妖塔商店刷新消耗
    decrement_refreshShop_wonder = 13 ,  -- 须臾仙境商店刷新消耗

    switch_exclusive_shop = 14, -- 月卡专属商店的开启，
    switch_super_sweep = 15, -- 超级扫荡开启，
    switch_collection_needNoWait = 16, -- 锁妖塔搜集免等待，
    addition_sp_limit = 17, -- 体力上限增加
    addition_sp_canBuyTimes = 18,  -- 购买体力次数增加

    decrement_buyChallengeTimesCost_wonder = 19, -- 各玩法首次购买次数折扣
    decrement_buyChallengeTimesCost_endless = 20,
    decrement_buyChallengeTimesCost_elite = 21,

    addition_guild_donateTimes = 22, -- 仙盟捐献次数增加
    switch_getEqualNumStone_whenUseGold = 23, -- 获取灵石开关
    switch_canTakePartIn_snapUp = 24,   -- 可以参加开服抢购
}

FuncCommon.TIME_TYPE = {
    OPEN_TIME = 1,
    CREATE_TIME = 2,
    NATURAL_TIME = 3,
}

local lastTime = 0
local vipData = nil
local cdData = nil
local countData = nil
local getMethodData = nil
local npcData = nil
local systemOpenData = nil
local maxVipLevel = nil
-- //体力价格
local SpPrice = nil;
-- //npc图标与对话内容
local npcIconDialog = nil;
-- //购买铜钱的价格
local coinPrice = nil;
-- 关卡星级条件枚举数据
local levelConditon = nil;
-- 奇侠标签表
local partnerTag = nil;
-- 玩法产量加成及耗费减少
local Addition = nil;
-- 充值系统开启表
local systemHideData = nil;

FuncCommon.screeningstring = "系统正在维护中"
function FuncCommon.init()
    vipData = Tool:configRequire("common.Vip")
    cdData = Tool:configRequire("common.Cd")
    countData = Tool:configRequire("common.Count")
    getMethodData = Tool:configRequire("common.GetMethod")
    npcData = Tool:configRequire("common.Npc")
    systemOpenData = Tool:configRequire('common.SystemOpen')
    SpPrice = Tool:configRequire("common.BuySp");
    npcIconDialog = Tool:configRequire("home.CommonPopup");
    coinPrice = Tool:configRequire("common.GoldPrice");
    config_Recharge = Tool:configRequire("recharge.Recharge")
    levelConditon = Tool:configRequire("common.LevelCondition")
    partnerTag = Tool:configRequire("common.PartnerTag")
    Addition = Tool:configRequire("common.Addition")
    systemHideData = Tool:configRequire('common.SystemHide')
end

function FuncCommon.getSysOpenData()
    return systemOpenData;
end

function FuncCommon.getSysOpenValue(id, key)
    local valueRow = systemOpenData[tostring(id)];
    if valueRow == nil then 
        echo("error: FuncCommon.getSysOpenValue id " .. 
            tostring(id) .. " is nil;");
        return nil;
    end 

    local value = valueRow[tostring(key)];
    if value == nil then 
        echo("error: FuncCommon.getSysOpenValue key " .. 
            tostring(key) .. " is nil");
    end 
    return value;
end

function FuncCommon.getSysOpenContent(id)
    return FuncCommon.getSysOpenValue(id, "content");
end

function FuncCommon.getIconPosition(id)
     return FuncCommon.getSysOpenValue(id,"iconPositon");
end

function FuncCommon.getSysOpensysname(id)
    return FuncCommon.getSysOpenValue(id, "sysname");
end

function FuncCommon.getSysOpenxtname(id)
    return FuncCommon.getSysOpenValue(id, "xtname");
end

function FuncCommon.getAdInt(id)
    return FuncCommon.getSysOpenValue(id, "adInt");
end

function FuncCommon.getFlySwich(id)
    
     return FuncCommon.getSysOpenValue(id, "flyswitch");
end

function FuncCommon.hasSystemIcon()
    local nowHeroLv = tonumber(UserModel:level())
    for k,v in pairs(systemOpenData) do
        if v.newsystemlevel then
            local closeSystemIconLv = v.newsystemlevel + v.newsystemgrade
            if nowHeroLv >= v.newsystemlevel and nowHeroLv < closeSystemIconLv then
                return true
            end

        end

    end
    return false
end

-- //用给定的ID,获取npc的图标路径,和对话内容
function FuncCommon.getNpcIconDialog(_id)
    local _item = npcIconDialog[tostring(_id)];
    if (_item ~= nil) then
        return "icon/other/" .. _item.npc .. ".png", GameConfig.getLanguage(_item.tips);
    end
    return nil, nil;
end
-- //给定购买次数来获取体力的价格
function FuncCommon.getSpPriceByTimes(_times)
    local _item = SpPrice[tostring(_times)];
    if (_item ~= nil) then
        return _item["buySpCost"];
    end
--    local _num = table.length(SpPrice);
    _item = SpPrice["0"];
    return _item["buySpCost"];
end

--[[
    dayTimes:当天第几次购买
    totalTimes:累计购买次数(创角以来的总次数)
    每次购买获得的铜钱数=基础数值（随当日购买次数读表）*MIN（（1+加成倍率*玩家累积购买次数），倍率上限）
]]
function FuncCommon.getCoinPriceByTimes(dayTimes,totalTimes)
    totalTimes = totalTimes or 0
    local buyCoinCfg = coinPrice[tostring(dayTimes)];
    if buyCoinCfg == nil then
        -- 如果超过了购买次数，buyCoinCfg为nil,用默认第一行的
        buyCoinCfg = coinPrice["0"]
    end

    -- 加成倍率(万分比)
    local buyCoinAddition = FuncDataSetting.getDataByConstantName("BuyCoinAddition")
    -- 倍率上限
    local buyCoinMaxAddition = FuncDataSetting.getDataByConstantName("BuyCoinMaxAddition")
    local quantity = buyCoinCfg.quantity
    -- echo("基础值quantity===",quantity)
    -- echo("buyCoinAddition===",buyCoinAddition)
    -- echo("buyCoinMaxAddition===",buyCoinMaxAddition)
    if buyCoinAddition and buyCoinMaxAddition then
        local addition = math.min((1+buyCoinAddition/10000*totalTimes),buyCoinMaxAddition)
        -- echo("1111 quantity=",quantity,addition)
        -- quantity = tostring(quantity * addition)
        quantity = tonumber(quantity * addition)
        quantity = math.round(quantity)
    end

    -- echo('dayTimes=',dayTimes)
    -- echo("quantity==",quantity,",totalTimes=",totalTimes)
    return buyCoinCfg.price, quantity;
end

function FuncCommon.getCoinCostByTimes(dayTimes)
    local buyCoinCfg = coinPrice[tostring(dayTimes)];
    if buyCoinCfg == nil then
        -- 如果超过了购买次数，buyCoinCfg为nil,用默认第一行的
        buyCoinCfg = coinPrice["0"]
    end

    return buyCoinCfg.price
end

function FuncCommon.getNpcDataById(npcId)
    local data = npcData[tostring(npcId)]
    if data == nil then
        echo("FuncCommon.getNpcDataById not found id ", npcId,"use default 101")
        return npcData["101"]
    end

    return data
end

function FuncCommon.getNpcName(npcId)
    return FuncCommon.getNpcDataById(npcId).name;
end

function FuncCommon.getNpcIcon(npcId)
    return FuncCommon.getNpcDataById(npcId).icon;
end

function FuncCommon.getNpcSpineBody(npcId)
    return FuncCommon.getNpcDataById(npcId).spineBody;
end

-- 获取NPC立绘
function FuncCommon.getNpcSpineArt(npcId)
    return FuncCommon.getNpcDataById(npcId).spine
end

-- 根据id，获取途径数据   由 _ 拼接的为需要动态生成的  前半段为配置的模版  后半段为需要动态变化的参数
function FuncCommon.getGetWayDataById(getWayId)
    local str_table = string.split(getWayId, "_")
    local data = nil
    if #str_table == 1 then
        data = getMethodData[tostring(getWayId)]
        if data == nil then
            echo("FuncCommon.getGetWayDataById not found id ", getWayId)
            return
        end       
    else
        local templateId = str_table[1]
        data = table.deepCopy(getMethodData[tostring(templateId)])
        if data.type == FuncCommon.GETWAY_TYPE.TYPE_4 then
            local endlessId = str_table[2]
            local floor, section = FuncEndless.getFloorAndSectionById(endlessId)
            local description = GameConfig.getLanguageWithSwap("#tid_endless_name_4", floor, section)
            data.linkPara = {}
            table.insert(data.linkPara, tostring(endlessId))
            data.description = description
        end       
    end

    return data
end


-- 根据vipLevel和key值获取属性值
function FuncCommon.getVipPropByKey(vipLevel, key)
    local vipCfg = vipData[tostring(vipLevel)]
    if vipCfg then
        return vipCfg[key]
    end

    return nil
end

-- 获得vip可达到的最大数值
function FuncCommon.getMaxVipLevel()
    if maxVipLevel then return maxVipLevel end

    local keys = table.keys(vipData)
    local sortByLevel = function(a, b)
        return tonumber(a) < tonumber(b)
    end
    table.sort(keys, sortByLevel)
    maxVipLevel = tonumber(keys[#keys])
    return maxVipLevel
end

-- 根据vipLevel 获取每天最多可以购买几次互动次数
function FuncCommon.getInteractTimes(vipLevel)
    return FuncCommon.getVipPropByKey(vipLevel, "interactTimes")
end

function FuncCommon.getGambleChangeCount(vipLevel)
	return FuncCommon.getVipPropByKey(vipLevel, "gambleChangeTimes")
end

-- 获得vip级别对应的能购买的pvp挑战次数
function FuncCommon.getPVPBuyCount(vipLevel)
    return FuncCommon.getVipPropByKey(vipLevel, "buySn")
end
-- 根据Id，获取cd数据
function FuncCommon.getCdCostById(id, leftCd)
    local data = cdData[tostring(id)]
    if data then
        local costType = data.costType
        local cdCost = nil
        -- 固定消费
        if tonumber(costType) == 1 then
            cdCost = data.cost
            -- 动态消费
        elseif tonumber(costType) == 2 then
            if not leftCd then leftCd = data.cdPlus end
            cdCost = math.ceil(leftCd * 1.0 / data.cost)
        end
        return cdCost
    else
        echo("getCdCostById not found")
        return nil
    end
end

-- 根据Id，获取cd时间
function FuncCommon.getCdTimeById(id)
    local data = cdData[tostring(id)]
    if data then
        return data.cdPlus
    else
        echo("getCdTimeById not found")
        return nil
    end
end


-- 根据countId获取 数据
function FuncCommon.getCountData(countId)
    local data = countData[tostring(countId)]
    if not data then
        echoError("没有这个countId的数据:", countId)
    end
    return data
end

local colorToQuality 

if not DEBUG_SERVICES then
    colorToQuality = {
        cc.c3b(255,255,255),
        cc.c3b(0,255,0),
        cc.c3b(0,0,255),
        cc.c3b(0xcc,0x33,0xff),
        cc.c3b(0xff,0x99,0),
        cc.c3b(255,0,0)
    }
end



--
local colorNumToQuality = {
    "ffffff",
    "65ff73",
    "65faff",
    "ff58c2",
    "ffdb4c",
    "ff0000"
}


-- 根据品质 获取对应的颜色 c3b
function FuncCommon.getColorByQuality(quality)
    local color = colorToQuality[quality]
    if not color then
        echoError("错误的品质:", quality)
        return colorToQuality[1]
    end
    return color

end

-- 获取对应的颜色值 
function FuncCommon.getColorStrByQuality(quality)
    local color = colorNumToQuality[quality]
    if not color then
        echoError("错误的品质:", quality)
        return colorNumToQuality[1]
    end
    return color
end

function FuncCommon.dumpSystemOpen()
    dump(systemOpenData, "---systemOpenData---");
end

---第五个参数 是否被系统屏蔽
function FuncCommon.isSystemOpen(sysName)
    if systemOpenData[sysName] == nil then 
        echoError("error!!! ----common.SystemOpen sysName----", sysName, "is 没有配置");
        return false, 100, 1,"系统未开启"..tostring(sysName); 
    end 

    --如果是系统关闭的
    if GameStatic:checkSystemClosed( sysName ) then
        echo("error!!! ----common.SystemOpen sysName----", sysName, "is 没有配置");
        return false, 100, 1,"系统未开启",true;   
    end

    -- local level = UserModel:level()
    -- local openLevel = tonumber(systemOpenData[sysName].lv)
    -- openLevel = openLevel or 0
    local condition = systemOpenData[sysName].condition
    local conditionType = condition[1].t
    local conditionValue = condition[1].v

    local lockTip = nil
    local rt = UserModel:checkCondition(condition)
    if rt == nil then
        return true, conditionValue, conditionType
    else
        lockTip = UserModel:getConditionTip(condition)
        return false, conditionValue, conditionType,lockTip
    end
end

--添加判断系统开启的方法
function FuncCommon.isSystemOpenByUserData(sysName,userData)
    -- 目前 这个方法用不上了 全部默认开启
    if true then
        return nil
    end
    if not userData then
        FuncCommon.isSystemOpen(sysName)
        return
    end

    if systemOpenData[sysName] == nil then 
        echoError("error!!! ----common.SystemOpen sysName----", sysName, "is 没有配置");
        return false, 100, 1,"系统未开启"..tostring(sysName); 
    end 

    --如果是系统关闭的
    if GameStatic:checkSystemClosed( sysName ) then
        echo("error!!! ----common.SystemOpen sysName----", sysName, "is 没有配置");
        return false, 100, 1,"系统未开启",true;   
    end

    local conditionGroup = systemOpenData[sysName].condition

    local lockTip = nil
    if not conditionGroup then
        return nil
    end
    --先解密
    conditionGroup = numEncrypt:decodeObject(conditionGroup) 
    for k,v in pairs(conditionGroup) do
        local t = v.t
        local value = v.v

        --等级判断
        if t == FuncCommon.CONDITION_TYPE.LEVEL then
            if userData.level < value then
                return t
            end
        --境界是否满足
        elseif t == FuncCommon.CONDITION_TYPE.STATE then
            local state = userData.state or 0
            if state < value then
                return t
            end
        --vip是否达到条件
        elseif t == FuncCommon.CONDITION_TYPE.VIP then
            local vip = userData.vip or 0
            if vip < value then
                return t
            end
        elseif t == FuncCommon.CONDITION_TYPE.STAGE then
            local needRaidId = value
            -- 已经通关的最大ID
            local passMaxRaidId = userData.userExt.stageId
            if passMaxRaidId == nil or passMaxRaidId == "" or passMaxRaidId == 0 then
                passMaxRaidId = 0
            end
            if tonumber(passMaxRaidId) < tonumber(needRaidId) then
                return t
            end
        elseif t == FuncCommon.CONDITION_TYPE.ELITE then
            local needRaidId = value
            -- 已经通关的最大ID
            local passMaxRaidId = userData.userExt.eliteId
            if passMaxRaidId == nil or rapassMaxRaidIdidId == "" or passMaxRaidId == 0 then
                return 0
            end
            if tonumber(passMaxRaidId) < tonumber(needRaidId) then
                return t
            end
        elseif t == FuncCommon.CONDITION_TYPE.INTERACT then
--            if not EliteModel:isOpenXiaoGuanById(value) then
--                return t
--            end
        elseif t == FuncCommon.CONDITION_TYPE.QUEST_GET then
            -- local questId = value;
            -- if TargetQuestModel:isMainLineQuestFinish(questId) == false then 
            --     return questId;
            -- end
        end
    end
    return nil
end

-- 判断是否是通用材质
function FuncCommon.isCommonTexture(texture)
    if texture == "UI_common" or texture == "common" then
        return true
    end
    -- 引导材质作为通用材质，不会被卸载
    if FuncCommon.isGuideTexture(texture) then
        return true
    end
    return false
end

-- 判断引导材质（引导没有使用UI加载，所以如果其他界面使用了引导的特效，材质最终会被删除，引导再次使用会报错）
function FuncCommon.isGuideTexture(texture)
    if texture == "UI_qiangzhitishi" or texture == "UI_main_img_shou" then
        return true
    end
    return false
end

--玩家名为空，用这个默认名字代替
function FuncCommon.getPlayerDefaultName()
	return GameConfig.getLanguage("tid_common_2001")
end

function FuncCommon.getRechargeConfig()
    return config_Recharge
end

function FuncCommon.getRechargeDataById(rechargeId)
    return config_Recharge[tostring(rechargeId)]
end

function FuncCommon.getSysBtnOrder(sysName)
    local order = systemOpenData[sysName].orderNum;
    if order == nil then 
        echo("error!!!--common.SystemOpen orderNum--", sysName, " is nil!");
    end 
    return order or 1;
end

function FuncCommon.getEntranceName(sysName)
    local entranceName = systemOpenData[sysName].entranceName
    if entranceName == nil then
        echo("error!!!--common.SystemOpen entranceName--",sysName, " is nil!")
    end
    return entranceName or sysName
end

--随机取loading动画name
function FuncCommon.getLoadingAniName()
    math.randomseed(os.time())
    local index = math.random(1,4)
    local name = "UI_zhuanjuhua_lo"..tostring(index);
    echo("loadingAniName ========= ".. name)
    return name
end

function FuncCommon.getLeveLCondition()
    return levelConditon
end

-- todo
-- 完善数字转换方法
function FuncCommon.getCapitalNum(num)
    return FuncCommon.numMap[num]
end

-- 通过关卡Id，获取关卡星级条件
-- 1，顺利通关 2，死亡角色少于三人 4,表示回合数少于多少判定成功
function FuncCommon.getLevelStarCondition(levelId)
    local levelData = Tool:configRequire("level.Level");
    -- 获取第一波配置
    local firstWaveData = levelData[tostring(levelId)]["1"]

    local starCondCfg = firstWaveData.starTime

    local starCondArr = {}

    for i=1,#starCondCfg do
        local condId = starCondCfg[i].type
        local condValue = starCondCfg[i].value

        local condDescTid = levelConditon[tostring(condId)].translate
        local condDescTip = nil
        if condId == 1 then
            condDescTip = GameConfig.getLanguage(condDescTid)
        elseif condId == 2 then
            if condValue == 1 then
                -- 无角色死亡
                condDescTip = GameConfig.getLanguage("#tid1555")
            else
                condDescTip = GameConfig.getLanguageWithSwap(condDescTid,FuncCommon.getCapitalNum(condValue))
            end
        elseif condId == 4 then
            condDescTip = GameConfig.getLanguageWithSwap(condDescTid,FuncCommon.getCapitalNum(condValue))
        end

        starCondArr[i] = {id = condId,tip = condDescTip}
    end

    return starCondArr
end

-- 将战斗结果值，转为星级数据
-- battleResult:战斗结果值，3位二进制表示星级及完成了哪个条件，取值范围 1-7
-- 返回值：星级star,完成的条件数组
function FuncCommon:getBattleStar(battleResult)
    local star = 0
    local condArr = {}

    local battleRt = tonumber(battleResult)
    if battleRt >= 1 and battleRt <= 7 then
        local starData = FuncCommon.battleStarCfg[battleRt]
        star = starData[1]
        -- 反转数组元素，使condArr中的条件顺序修改为从易到难
        condArr = table.reverse(starData[2])
    end

    return star,condArr
end

--[[
    根据奖励获取物品名字等
    从CompResItemView整理过来的
]]
local function _initData( reward )
    local data = string.split(reward,",")
    local rewardType = data[1]
    local rewardId = nil
    local rewardNum = 0

    local itemId,itemNum,itemType,itemSubType

    -- 如果奖品是道具
    if rewardType == UserModel.RES_TYPE.ITEM then
        rewardId = data[2]
        rewardNum = data[3]

        itemId = rewardId
        itemNum = rewardNum or 0

        local itemData = FuncItem.getItemData(itemId)
        itemType = itemData.type
        itemSubType = itemData.subType_display or 0
    -- 奖品为非道具资源
    else
        itemType = nil

        -- 如果奖品是法宝
        if rewardType == FuncDataResource.RES_TYPE.TREASURE or rewardType == FuncDataResource.RES_TYPE.PARTNER then
            rewardId = data[2]
            rewardNum = 1
        else
            rewardNum = data[2]
        end

        -- 非道具类型资源，将道具id设置为nil
        itemId = nil
    end

    return rewardType,rewardId,rewardNum,itemId,itemNum,itemType,itemSubType
end

function FuncCommon.getFormatItemNum(itemNum)
    -- echo("=========1111==============",itemNum)
    local limitNum = 10000
    itemNum = tonumber(itemNum)
    if itemNum <= limitNum then
        return itemNum
    else
        itemNum = math.floor(itemNum/10^3)
        --屏蔽1.0万的情况
        local yushu = itemNum % 10
        if yushu == 0 then
            newItemNum = string.format("%.0f", itemNum/10^1)
        else
            newItemNum = string.format("%.1f", itemNum/10^1)
        end
        
        newItemNum =  newItemNum .. "万"
        return newItemNum
    end
end

function FuncCommon.getNameByReward( reward )
    local rewardType,rewardId,rewardNum,itemId,itemNum,itemType,itemSubType = _initData(reward)

    local itemName = nil

    -- 道具类型资源
    if itemId ~= nil then
        -- 如果是碎片
        itemName = FuncItem.getItemName(itemId)
    else
        -- 完整法宝
        if tostring(rewardType) == FuncDataResource.RES_TYPE.TREASURE then
            local treasureId = rewardId
            local treasureName = FuncTreasure.getValueByKeyTD(treasureId,"name")
            treasureName = GameConfig.getLanguage(treasureName)
            -- 法宝名字
            itemName = treasureName
        -- 完整伙伴
        elseif tostring(rewardType) == FuncDataResource.RES_TYPE.PARTNER then
            local partnerId = rewardId
            -- 伙伴资质
            local partnerInfo = FuncPartner.getPartnerById(partnerId)
            local PartnerName = GameConfig.getLanguage(partnerInfo.name)
            -- 法宝名字
            itemName = PartnerName
        -- 其他类资源
        else
            itemName = FuncDataResource.getResNameById(tonumber(rewardType))
        end
    end

    itemNameWithNum = GameConfig.getLanguageWithSwap("tid_common_1018",itemName,FuncCommon.getFormatItemNum(itemNum or rewardNum))

    return itemName, itemNameWithNum
end

--[[
    获得物品形状(对应CompResItemView的frame)
    1方 2圆 3碎片形状
]]
function FuncCommon.getShapByReward( reward )
    local rewardType,rewardId,rewardNum,itemId,itemNum,itemType,itemSubType = _initData(reward)
    local frame = 1

    
    if itemType ~= nil and tonumber(itemType) == tonumber(ItemsModel.itemType.ITEM_TYPE_PIECE) then
        -- 法宝碎片
        if itemSubType and itemSubType == ItemsModel.itemSubTypes_New.ITEM_SUBTYPE_201 then
            frame = 3
        -- 伙伴碎片
        elseif itemSubType and itemSubType == ItemsModel.itemSubTypes_New.ITEM_SUBTYPE_202 then
            frame = 3
        else
            frame = 3
        end

    elseif rewardType ~= nil and tostring(rewardType) == FuncDataResource.RES_TYPE.TREASURE then
        frame = 1
    else
        frame = 1
    end

    return frame
end

---跳转调用
function FuncCommon.isjumpToSystemView(systemname)
    local isopen,level,typeid,lockTip,is_sy_screening =  FuncCommon.isSystemOpen(systemname)
    if not isopen then
        if is_sy_screening then
            WindowControler:showTips(FuncCommon.screeningstring);
        else
            WindowControler:showTips(lockTip);
        end
        return false
    end
    return true
end

--显示按钮调用
function FuncCommon.openSystemToView(systemname,pames)

    local isopen,level,typeid,lockTip,is_sy_screening =  FuncCommon.isSystemOpen(systemname)
    if isopen then
        local view = FuncCommon.SYSTEM_TO_VIEW_NAME[systemname]
        WindowControler:showWindow(view,pames)
    else
        if is_sy_screening then
            WindowControler:showTips(FuncCommon.screeningstring);
        else
            WindowControler:showTips(lockTip);
        end
    end
end

--根据当前时间获取到四点刷新的时间
function FuncCommon.byTimegetleftTime(servertime)
    local time = servertime
    -- local year = tonumber(os.date("%Y",time))
    -- local month = os.date("%m",time)
    -- local day = os.date("%d",time)
    local hour = tonumber(os.date("%H",time))
    local minute = tonumber(os.date("%M",time))
    local second = tonumber(os.date("%S",time))
    local sumsecond = minute*60 + second
    local returnsecond = 0
    if hour >= 4 then
        returnsecond =  (24 - hour)*60*60  + 4 *60*60 - sumsecond
    elseif hour < 4 then
        returnsecond = (4 - hour) * 60 * 60 - sumsecond
    else
        returnsecond = 3
    end
    -- echo("======四点刷新剩余时间=======",time,returnsecond)
    return returnsecond
end

function FuncCommon.getLastTime()
    return lastTime
end

function FuncCommon.setLastTime(_time)
    lastTime = _time
end
function FuncCommon.checkCondition( userData ,conditionGroup )

    --如果没有任何开启条件的 返回true
    if not conditionGroup then
        return nil
    end
    --先解密
    conditionGroup = numEncrypt:decodeObject(conditionGroup) 
    for k,v in pairs(conditionGroup) do
        local t = v.t
        local value = v.v

        --等级判断
        if t == FuncCommon.CONDITION_TYPE.LEVEL then
            local _level = userData.level or 0
            if _level < value then
                return t
            end
        --境界是否满足
        elseif t == FuncCommon.CONDITION_TYPE.STATE then
            
        --vip是否达到条件
        elseif t == FuncCommon.CONDITION_TYPE.VIP then
            local vip = userData.vip or 0
            if vip < value then
                return t
            end
        elseif t == FuncCommon.CONDITION_TYPE.STAGE then
            local needRaidId = value
            -- 已经通关的最大ID
            local passMaxRaidId = userData.userExt.stageId or 0
            if passMaxRaidId == "" then
                passMaxRaidId = 0
            end
            if tonumber(passMaxRaidId) < tonumber(needRaidId) then
                return t
            end
        elseif t == FuncCommon.CONDITION_TYPE.ELITE then
            local needRaidId = value
            -- 已经通关的最大ID
            local passMaxRaidId = userData.userExt.eliteId or 0
            if rapassMaxRaidIdidId == "" then
                passMaxRaidId =  0
            end
            if tonumber(passMaxRaidId) < tonumber(needRaidId) then
                return t
            end
        elseif t == FuncCommon.CONDITION_TYPE.INTERACT then
--            
        elseif t == FuncCommon.CONDITION_TYPE.QUEST_GET then
            
        elseif t ==  FuncCommon.CONDITION_TYPE.STAR_CHEST then   --星级宝箱
            
        end
    end

    --返回空表示满足
    return nil
end

function FuncCommon.getSystemOpenTerm(systemName)
    local condition = systemOpenData[systemName].condition
    return condition[1].v
end

--重复奖励叠加处理
function FuncCommon.repetitionRewardCom(reward)
    if reward == nil or #reward == 0 then
        return {}
    end
    local newTab = {}
    local index = 1
    for i=1,#reward do
        local sdata = reward[i]
        local rewData  = string.split(sdata, ",")
        local rewType = rewData[1]
        local rewId = rewData[2]
        local rewNum = rewData[3]
        local tab  =  {
                [1] = rewType, 
                [2] = rewId,
                [3] = rewNum,
            }
        if #newTab == 0 then
            table.insert(newTab,tab)
        else
            local issave = false
            for x = 1,#newTab do
                if #newTab[x] == 3 then
                    if  rewType  == newTab[x][1] then
                        if newTab[x][2] == rewId then
                            newTab[x][3] = newTab[x][3] + rewNum
                            issave = true
                        end
                    end
                elseif #newTab[x] == 2 then
                    if  rewType  == newTab[x][1] then
                        newTab[x][2] = newTab[x][2] + rewData[2]
                        issave = true
                    end

                end
            end
            if not issave then
                 table.insert(newTab,tab)
            end
        end
    end
    local strTab = {}
    for i=1,#newTab do
        if newTab[i] then
            if newTab[i][3] then
                strTab[i] = newTab[i][1]..","..newTab[i][2]..","..newTab[i][3]
            else
                strTab[i] = newTab[i][1]..","..newTab[i][2]
            end
        end
    end
    return strTab
end

--奇侠标签
function FuncCommon.getAllPartnerTagDatas(  )
    return partnerTag
end

-- 通过id和标签获取value
function FuncCommon.getPartnerTagDataByIdAndTag( id,tag )
    if not id then
        echoError("PartnerTag 传入的id 为空")
        return nil
    end
    local data = partnerTag[tostring(id)]
    if not data then
        echoError("PartnerTag 未找到id为",id ,"的数据")
        return nil
    end
    local dataTag = data[tostring(tag)]
    if not dataTag then
        echoError("PartnerTag 未找到id为",id ,"tag 为",tag,"的数据")
        return nil
    end
    return dataTag.name
end

function FuncCommon.getTagNameByTypeAndId(_type, _tagId)
    -- local name = ""
    -- local typeData = partnerTag[tostring(_type)]
    -- name = typeData[tostring(_tagId)].name
    return FuncCommon.getPartnerTagData(_type, _tagId).name
end
-- 根据type和tag获取对应的partnerTag表属性值
function FuncCommon.getPartnerTagData( _type,_tagId )
    if partnerTag[tostring(_type)] and partnerTag[tostring(_type)][tostring(_tagId)] then
        return partnerTag[tostring(_type)][tostring(_tagId)]
    else
        echoError ("PartnerTag表未找到对应的type和tagId的值",_type,_tagId,"使用默认值1，1代替")
        return partnerTag["1"]["1"]
    end
end

-- 传入的string必须为"1,1001,10;2,1002,20;"这种结构
function FuncCommon.splitStringIntoTable(_str)
    local str_table = string.split(_str, ";")
    local result = {}
    for i,v in ipairs(str_table) do
        local table1 = {}
        if v ~= "" then
            table1 = string.split(v, ",")
            table.insert(result, table1)
        end 
    end

    return result
end

function FuncCommon.getStringByNumberAndDigit(number, divisor, digit)
    local number_str = tostring(number / divisor)
    local index = digit
    local number_table = string.split(number_str, ".")
    local result = ""
    if number_table[1] then
        result = result..number_table[1]
    end

    if number_table[2] and index > 0 then
        result = result.."."
        local number_str1 = number_table[2]

        for i = 1, index, 1 do
            if string.sub(number_str1, i, i) then
                result = result..string.sub(number_str1, i, i)
            end
        end
    end

    return result
end

-- 获取玩法产量加成或者减少的数据
-- 仙盟科技无极阁 和 月卡用到
function FuncCommon.getAdditionDataByAdditionId( additionId )
    if Addition then
        local data =  Addition[tostring(additionId)]
        if not data then
            echoError("没有这个特权数据:",additionId)
            return {}
        end
        return data
    end
end

-- 判断是否有特权加成
-- 仙盟科技无极阁 和 月卡用到
-- 传入特权数据 additionType 当前时间 产自系统(可选) 
-- 返回 isHas,value,subType(固定值还是万分比还是开关)
-- - "privilegeData示例" = {
-- -     "1" = {
-- -         "2001" = "1527969600"
-- -     }
-- - }
function FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,fromSys )
    local isHas,value,subType = false,0,1
    -- dump(privilegeData, " ========= privilegeData ========= ")
    -- echoError("__additionType,curTime,fromSys ",additionType,curTime,fromSys)
    for type,additionIdArr in pairs(privilegeData) do
        if tonumber(type) == tonumber(additionType) then 
            for additionId,expireTime in pairs(additionIdArr) do
                if tostring(expireTime) == "0" or tonumber(curTime) < tonumber(expireTime) then 
                    local additionData = FuncCommon.getAdditionDataByAdditionId( additionId )
                    if additionData.type == tonumber(additionType) then
                        -- 如果传入产出系统,则加上此限制条件
                        local isFromSysOk = true
                        if fromSys then
                            isFromSysOk = false
                            if additionData.from == tonumber(fromSys) then
                                isFromSysOk = true
                            end
                        end 
                        isHas = isFromSysOk
                        value = value + additionData.subNumber 
                        subType = additionData.subType   
                    end
                end
            end
        end
    end
    -- echo("______________isHas,value,subType __________",isHas,value,subType)
    return isHas,value,subType
end

function FuncCommon.checkHasPrivilegeAdditionByType( _type )
    local privilegeData = UserModel:privileges() 
    local additionType = _type
    local curTime = TimeControler:getServerTime()
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime)
    return isHas,value,subType
end

--[[
    通用奖品合并统计
    rewards结构   
    rewards" = {
        1 = "30,785"
        2 = "1,19001,227"
        3 = "3,222083"
    }
]]
function FuncCommon.countRewards(rewards)
    local tempRewards = {}
    local resKeyList = {}

    for i=1,#rewards do
        local reward = rewards[i]
        local arr = string.split(reward,",") 

        local key = nil
        local num = 0
        -- 2位结构的奖品
        if #arr == 2 then
            key = arr[1]
            num = arr[2]

            if tempRewards[key] == nil then
                tempRewards[key] = arr

                resKeyList[#resKeyList+1] = key
            else
                tempRewards[key][2] = tempRewards[key][2] + num
            end 
        -- 3位结构的奖品
        elseif #arr == 3 then
            key = arr[1] .. arr[2]
            num = arr[3]

            if tempRewards[key] == nil then
                tempRewards[key] = arr

                resKeyList[#resKeyList+1] = key
            else
                tempRewards[key][3] = tempRewards[key][3] + num
            end 
        end
    end

    local rewardData = {}
    for i=1,#resKeyList do
        local key = resKeyList[i]
        local arr = tempRewards[key]
        rewardData[#rewardData+1] = table.concat(arr, ',')
    end

    return rewardData
end

function FuncCommon.getSystemHideDataById(_systemHideId)
    local data = systemHideData[tostring(_systemHideId)]
    if not data then
        echoError("\nsystemHide.csv not find data for this id ==", _systemHideId)
    end

    return data
end

--通过systemHide表中数据计算 开启时间和过期时间
function FuncCommon.getOpenTimeAndExpireTimeById(_systemHideId, _countId)
    local systemHideData = FuncCommon.getSystemHideDataById(_systemHideId)
    
    if systemHideData.timeType == FuncCommon.TIME_TYPE.NATURAL_TIME then
        local year = math.floor(systemHideData.firstOpenTime / 10000)
        local month = math.floor((systemHideData.firstOpenTime - year * 10000) / 100)
        local day = systemHideData.firstOpenTime % 100
        local hour = FuncCount.getHour(_countId)
        local min = FuncCount.getMinute(_countId)

        local timeStamp = os.time({year = year, month = month, day = day, hour = hour, min = min})
        local duration = systemHideData.durationTime * 24 * 60 * 60
        return timeStamp, duration + timeStamp
    elseif systemHideData.timeType == FuncCommon.TIME_TYPE.OPEN_TIME then
        local serverInfo = LoginControler:getServerInfo()
        local openTime = serverInfo.openTime
        local openDate = os.date("*t", openTime)

        local timeStampDate = openDate
        timeStampDate.day = openDate.day + systemHideData.firstOpenTime
        timeStampDate.hour = FuncCount.getHour(_countId)
        timeStampDate.min = FuncCount.getMinute(_countId)
        timeStampDate.sec = 0
        local timeStamp = os.time(timeStampDate)

        local duration = systemHideData.durationTime * 24 * 60 * 60
        return timeStamp, duration + timeStamp
    elseif systemHideData.timeType == FuncCommon.TIME_TYPE.CREATE_TIME then
        local createTime = UserModel:ctime()
        local createDate = os.date("*t", createTime)

        local timeStampDate = createDate
        timeStampDate.day = createDate.day + systemHideData.firstOpenTime
        timeStampDate.hour = FuncCount.getHour(_countId)
        timeStampDate.min = FuncCount.getMinute(_countId)
        timeStampDate.sec = 0
        local timeStamp = os.time(timeStampDate)

        local duration = systemHideData.durationTime * 24 * 60 * 60
        return timeStamp, duration + timeStamp
    end
end