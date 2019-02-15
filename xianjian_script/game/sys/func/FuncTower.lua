FuncTower= FuncTower or {}

FuncTower.VIEW_TYPE ={
    RESER_VIEW = 1,                 -- 重置锁妖塔确认
    SWEEP_VIEW = 2,                 -- 扫荡
    NEXTFLOOR_VIEW = 3,             -- 进入下一层 确认
    SWEEP_TIPS_VIEW = 4,
    GET_SOUL_TIPS_VIEW = 5,         -- 获取五灵属性提示 
    RECONFIRM_TIPS_CLOSE_SHOP = 6,  -- 关闭内部商店确认
    RECONFIRM_TIPS_TO_HANDLE_EVENTS = 7,  -- 前往处理搜刮事件 确认
    COLLECT = 8,                    -- 搜刮
    ACCELERATE_CONFIRM = 9,                    -- 搜刮加速
    BUY_GOODS_CONFIRM = 10,                    -- 购买商人的商品确认
    ZHANBU_CONFIRM = 11,                    -- 占卜确认
}

FuncTower.CHOOSEHERO_TYPE = {
    SHOP_VIEW = 1,
    FORMATION_VIEW = 2,
    GOODS_VIEW = 3,
}

FuncTower.SHOW_TIPS = {
    PARTNER = 1,
    TREASURE = 2,
}

-- 搜刮状态
FuncTower.COLLECTION_STATUS = {
    TODO = 1,
    COLLECTING = 2,
    DONE = 3,
}
-- 搜刮结果类型 奖励 事件
FuncTower.COLLECTION_RESULT_TYPE = {
    REWARD = 1,
    EVENT = 2,
}
-- 搜刮事件的类型
FuncTower.COLLECTION_EVENT_TYPE = {
    MERCHANT = 1,      -- 商人
    SOOTHSAYER = 2,    -- 占卜
    FISHING = 3,       -- 垂钓
    GUESS = 4,         -- 猜人
}
-- 搜刮事件的处理状态
FuncTower.COLLECTION_EVENT_STATUS = {
    TODO = 1,       -- 未完成
    DONE = 2,       -- 已完成
}

-- 主界面左侧宝箱状态
FuncTower.boxStatusType = {
    LOCK = 1,
    ACCESSIBLE = 2,
    GOT = 3,
}

-- 锁妖塔重置状态
FuncTower.towerResetStatus = {
    NO_RESET = "1",           -- 没有重置
    HAVE_BEEN_RESET = "2",    -- 已经重置
    NOT_INVOLVED = "3",       -- 从未进过锁妖塔
}



FuncTower.towerItemType = "tower_999" -- 锁妖塔道具 为适应奖励展示界面而定义
FuncTower.towerItemMaxNum = 3   -- 场景中获得的最大道具数量
FuncTower.maxEnergy = 10 -- 最大怒气值


local towerData = nil   --锁妖塔主界面表
local npcData = nil --锁妖塔Npc数据
local npcEventData = nil  --锁妖塔npc事件
local towerMonsterData = nil --锁妖塔怪物事件
local towerBoxData = nil    --宝箱事件
local towerGoodsData = nil  --道具事件
local towerInnerShop = nil   --商店事件
local towerCageData = nil   --笼子
local towerBuffAttrData = nil --buff属性
local towerMapBuffData = nil    --地图buff,毒事件配置在该表中
local TowerObstacleData = nil --障碍物
local towerSceneData = nil    --地图场景皮肤

local towerRuneData = nil    -- 聚灵格子
local towerRuneTempleData = nil    -- 散灵法阵事件
local towerDoorData = nil    -- 门事件

local towerCollectionData = nil    -- 搜刮表
local towerCollectionEventData = nil    -- 搜刮事件表

local towerRandomData = nil    -- 搜刮事件表

function FuncTower.init()
    towerData = Tool:configRequire("tower.Tower")
    npcData = Tool:configRequire("tower.TowerNpc")
    npcEventData = Tool:configRequire("tower.TowerNpcEvent")
    towerMonsterData = Tool:configRequire("tower.TowerMonster")
    towerBoxData = Tool:configRequire("tower.TowerBox")
    towerGoodsData = Tool:configRequire("tower.TowerGoods")
    towerShopBuffData = Tool:configRequire("tower.TowerShopBuff")
    towerChestData = Tool:configRequire("tower.TowerBox")
    towerInnerShop = Tool:configRequire("tower.TowerInnerShop")
    towerCageData = Tool:configRequire("tower.TowerCage")
    towerBuffAttrData = Tool:configRequire("tower.TowerBuffAttr")
    towerAltarData = Tool:configRequire("tower.TowerAltar")
    towerMapBuffData = Tool:configRequire("tower.TowerMapBuff")
    towerObstacleData = Tool:configRequire("tower.TowerObstacle")
    towerSceneData = Tool:configRequire("tower.TowerScene")

    towerRuneData = Tool:configRequire("tower.TowerRuneGrid")
    towerRuneTempleData = Tool:configRequire("tower.TowerRuneTemple")
    towerDoorData = Tool:configRequire("tower.TowerLockDoor")
    towerCollectionData = Tool:configRequire("tower.TowerCollection")
    towerCollectionEventData = Tool:configRequire("tower.TowerCollectionEvent")

    towerRandomData = Tool:configRequire("tower.TowerCellRandom")

    FuncTower.GOODS_TYPE = {
        TYPE_1 = 1,
        TYPE_2 = 2,
        TYPE_3 = 3
    }

end

function FuncTower.getTowerCfgData()
    return towerData
end

-- 获取一层锁妖塔数据
function FuncTower.getOneFloorData( _curFloorId )
    return towerData[tostring(_curFloorId)]
end

-- 获取通关一层的奖励 可能是奖励 也可能是解锁锁妖塔商品
function FuncTower.getFloorReward(_id)
    local towerReward = towerData[tostring(_id)].reward
    if towerReward then
        return towerReward -- 返回奖励 table
    else 
        return towerData[tostring(_id)].shopUnlock  -- 返回解锁锁妖塔商店表里一行的id string
    end
end

-- 获取完美通关奖励
function FuncTower.getPerfectPassReward(_curFloorId)
    local towerReward = towerData[tostring(_curFloorId)].bossReward
    if towerReward then
        return towerReward
    else 
        echoError("不存在当前楼层的完美通关奖励".._curFloorId)
    end
end

-- 获取弹出商店前的 奖励
-- (每击杀三只怪就会有一个奖励 才弹出商店)
function FuncTower.getBeforeShopReward( _curFloorId,_rewardId )
    local killingReward = towerData[tostring(_curFloorId)]
    local str1 = "shopReward".._rewardId
    if killingReward[str1] then
        return killingReward[str1] 
    else 
        echoError("当前楼层 ".._curFloorId..",不存在字段为"..str1.." 的奖励")
    end
end

-- 获取配置的最高层
-- 增加地图外随机规则后 layerData 字段作废 用newLayerData代替
function FuncTower.getMaxFloor()
    local maxFloor = 0
    for k, v in pairs(towerData) do
        if v.newLayerData then
            if tonumber(k) > maxFloor then
                maxFloor = tonumber(k)
            end
        end
    end
    return maxFloor
end

function FuncTower.getNpcData(_id)
   local npcHasData = npcData[tostring(_id)]
    if npcHasData then
        return npcHasData
    else 
        echoError("不存在这个NPC".._id)
    end
end

function FuncTower.getNpcEvent(_id)
     local npcEventData = npcEventData[tostring(_id)]
    if npcEventData then
        return npcEventData
    else 
        echoError("不存在这个NPC事件".._id)
    end
end

function FuncTower.getMonsterData(_id)
     local monsterData = towerMonsterData[tostring(_id)]
    if monsterData then
        return monsterData
    else 
        echoError("不存在这个怪物".._id)
    end
end

function FuncTower.getAllMonsterData()
      local monsterData = towerMonsterData
    if monsterData then
        return monsterData
    else 
        echoError("不存在怪物表")
    end
end

function FuncTower.getBoxData(_id)
    local boxData = towerBoxData[tostring(_id)]
    if boxData then
        return boxData
    else 
        echoError("不存在这个box数据".._id)
    end
end

function FuncTower.getGoodsData(_id)
    local goodsData = towerGoodsData[tostring(_id)]
    if goodsData then
        return goodsData
    else 
        echoError("不存在这个goods数据".._id)
    end
end

function FuncTower.getGoodsValue(_id,key)
    local goodsData = towerGoodsData[tostring(_id)]
    if goodsData then
        return goodsData[tostring(key)]
    else 
        echoError("不存在这个goods数据".._id)
    end
end

function FuncTower.getShopBuffData(_id)
    local buffData = towerShopBuffData[tostring(_id)]
    if buffData then
        return buffData
    else 
        echoError("不存在这个buff数据".._id)
    end
end

function FuncTower.getTowerChest(_id)
    local chestData = towerChestData[tostring(_id)]
     if chestData then
        return chestData
    else 
        echoError("不存在这个buff数据".._id)
    end
end

function FuncTower.getTowerInnerShop(_id)
    local shopData = towerInnerShop[tostring(_id)]
     if shopData then
        return shopData
    else 
        echoError("不存在这个shop数据".._id)
    end
end

function FuncTower.getTowerCage(_id)
    local cageData = towerCageData[tostring(_id)]
     if cageData then
        return cageData
    else 
        echoError("不存在这个cage数据".._id)
    end
end

function FuncTower.getMapBuffData(_id)
    local mapBuffData = towerMapBuffData[tostring(_id)]
    if mapBuffData then
        return mapBuffData
    else 
        echoError("不存在这个mapBuff数据".._id)
    end
end

function FuncTower.getObstacleData(_id)
    local obstacleData = towerObstacleData[tostring(_id)]
    if obstacleData then
        return obstacleData
    else 
        echoError("不存在这个mapBuff数据".._id)
    end
end

-- 根据npcEventId事件获取对应的进战斗的levelId
function FuncTower.getLevelIdByNpcEventId(eventId )
    local levelId = nil
    local eventData = FuncTower.getNpcEvent(eventId)
    if eventData then
        if eventData.parameter and #eventData.parameter > 0 then
            levelId = eventData.parameter[1]
        else
            echoError("TowerNpcEvent ---里的parameter值配置错误，应该是数组，且是关卡id")
        end
    else
        echoError("没有找到对应的TowerNpcEvent---",battleParams.eventId)
    end
    return levelId
end

-- 获取buff数据
function FuncTower.getTowerBuffAttrData(_id)
    local buffAttrData = towerBuffAttrData[tostring(_id)]
    if buffAttrData then
        return buffAttrData
    else 
        echoError("不存在这个buffAttr数据".._id)
    end
end

-- 通过towerFloor，获取场景皮肤数据
function FuncTower.getTowerMapSkinData(towerFloor)
    local towerData = FuncTower.getOneFloorData(towerFloor)
    local sceneData = nil
    if towerData then
        local sceneId = towerData.scene
        if sceneId then
            sceneData = FuncTower.getTowerSceneData(sceneId)
        end
    else
        echoError("FuncTower.getTowerMapSkinData towerIndex=",towerIndex)
    end
    return sceneData
end

-- 获取场景皮肤数据
function FuncTower.getTowerSceneData(_id)
    local sceneData = towerSceneData[tostring(_id)]
    if sceneData then
        return sceneData
    else 
        echoError("不存在这个sceneData数据".._id)
    end
end

function FuncTower.getLevelIdByMonster(monsterId,star)
    local monsterData = FuncTower.getMonsterData(monsterId)
    local mission = monsterData.level
    local correct = nil
    local starNum = tonumber(star)
    if starNum > 0 then
        correct = monsterData.correct[starNum]
    end
    return mission,correct
    -- 2017.08.16 pangkangning 表修改了，使用上面的方法
    -- local mission = nil
    -- local starNum = star
    -- if tonumber(starNum) == 0 then
    --     starNum = 1
    -- end
    -- for k,v in pairs(monsterData.difficulty) do
    --     if tonumber(k) == tonumber(starNum) then
    --         mission = v
    --     end
    -- end
    -- return mission
end   

function FuncTower.getTowerAltarDataByID(_id)
    local altarData = towerAltarData[tostring(_id)]
    if altarData then
        return altarData
    else 
        echoError("不存在这个法阵数据".._id)
    end
end 

-- ====================================================
-- 三测添加
function FuncTower.getRuneDataByID(_id)
    local runeData = towerRuneData[tostring(_id)]
    if runeData then
        return runeData
    else 
        echoError("不存在这个id 的聚灵数据".._id)
    end
end 

function FuncTower.getRuneTempleDataByID(_id)
    local runeTempleData = towerRuneTempleData[tostring(_id)]
    if runeTempleData then
        return runeTempleData
    else 
        echoError("不存在这个id 的散灵法阵数据".._id)
    end
end 

function FuncTower.getDoorEventDataByID(_id)
    local doorData = towerDoorData[tostring(_id)]
    if doorData then
        return doorData
    else 
        echoError("不存在这个id 的 门事件 数据".._id)
    end
end 

-- 根据搜刮层数获取搜刮配置数据
-- 注意这里的id 在配表中是 搜刮层数 number
function FuncTower.getCollectionDataByID(_id)
    local cData = towerCollectionData[tostring(_id)]
    if cData then
        return cData
    else 
        echoError("不存在这个 层数 的搜刮配置数据".._id)
    end
end 

function FuncTower.getCollectionEventDataByID(_id)
    local cEventData = towerCollectionEventData[tostring(_id)]
    if cEventData then
        return cEventData
    else 
        echoError("不存在这个id 的搜刮事件数据".._id)
    end
end 

function FuncTower.testTower4Data()
    dump(FuncTower.getRuneDataByID(1), "聚灵格子数据,id=1")
    dump(FuncTower.getRuneTempleDataByID(1), "散灵法阵数据,id=1")
    dump(FuncTower.getDoorEventDataByID(1), "门数据,id=1")
    dump(FuncTower.getCollectionDataByID(1), "搜刮层数1对应数据,id=1")
    dump(FuncTower.getCollectionEventDataByID(1), "搜刮事件1对应数据,id=1")
end
-- ============================================================
-- 一些额外函数
-- ============================================================
-- 给扫荡商店排序
function FuncTower.sortBuffItems(data)
    table.sort(data,function(a,b)
        local aCost = FuncTower.getShopBuffData(a.buffId).cost
        local bCost = FuncTower.getShopBuffData(b.buffId).cost

        -- 先按照类型排序
        if aCost < bCost then
            return true
        end
        return false
    end)
end

-- 给内部商店的buff排序
function FuncTower.sortInnerBuffItems(data)
    table.sort(data,function(a,b)
        local aCost = FuncTower.getShopBuffData(a).cost
        local bCost = FuncTower.getShopBuffData(b).cost

        -- 先按照类型排序
        if aCost < bCost then
            return true
        end
        return false
    end)
end

-- 给定一个id 判断是不是配表里配置的雇佣兵
function FuncTower.isConfigEmployee( _mercenaryId )
    for k,_data in pairs(npcEventData) do
        if tonumber(_data.type) == FuncTowerMap.NPC_EVENT_TYPE.MERCENARY then
            local params = _data.parameter 
            for kk,vv in pairs(params) do
                local configMercenaryId = string.split(vv,",")[2]
                if tostring(configMercenaryId) == tostring(_mercenaryId) then
                    return true
                end
            end
        end
    end
    return false
end

-- 根据随机组及随机下标获取随机格子对应数据
function FuncTower.getCellDataByRandomId( randomGroupId,randomIndex )
    if towerRandomData[tostring(randomGroupId)] then
        local data = towerRandomData[tostring(randomGroupId)]
        if not randomIndex then
            return data.groupCell
        end
        local index = tonumber(randomIndex)
        if index then
            return data.groupCell[index]
        end
    end
end