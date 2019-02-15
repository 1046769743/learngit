local TowerControler = TowerControler or {}

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local handle = {}


function TowerControler:chooseTowerNpcView(_id,gridPos)
    local npcData = FuncTower.getNpcData(_id)
    if not npcData.event then
        return
    end
    local npcType = nil -- npc的类型
    local eventIdData = npcData.event
    local eventNum = #eventIdData
    -- 配表中雇佣兵的数量是不定的
    -- 所以先检查是不是雇佣兵
    if eventNum > 0 then
         local eventData = FuncTower.getNpcEvent(eventIdData[1])
        if eventData.type  
            and eventData.type == FuncTowerMap.NPC_EVENT_TYPE.MERCENARY 
        then
            -- 无业流浪汉 可被雇佣为雇佣兵
            npcType = FuncTowerMap.NPC_TYPE.VAGRANT
            local _isMercenaryDead = false
            WindowControler:showWindow("TowerNpcMercenaryView",_isMercenaryDead,_id,gridPos)
            return
        end
    end      

    -- 检查其他类型
    if eventNum == 1 then
        local eventData = FuncTower.getNpcEvent(eventIdData[1])
        if eventData.type  
            and eventData.type == FuncTowerMap.NPC_EVENT_TYPE.PUZZLE 
        then
            -- 困惑的道友 小游戏
            npcType = FuncTowerMap.NPC_TYPE.PAZZLER
            WindowControler:showWindow("TowerPuzzleGameView",_id,gridPos)
        end
    elseif eventNum == 2 then
        local eventData = FuncTower.getNpcEvent(eventIdData[1])
        local eventData2 = FuncTower.getNpcEvent(eventIdData[2])
        if eventData.type and eventData2.type 
            and eventData.type == FuncTowerMap.NPC_EVENT_TYPE.CHALLENGE 
            and eventData2.type == FuncTowerMap.NPC_EVENT_TYPE.DECIPHER 
        then
            -- 被囚的道友
            npcType = FuncTowerMap.NPC_TYPE.PRISONER
            WindowControler:showWindow("TowerNpcChooseView",_id,gridPos)
        end
    elseif eventNum == 3 then
        -- 注意配表中 劫财劫色保底的顺序要正确
        local eventData = FuncTower.getNpcEvent(eventIdData[1])
        local eventData2 = FuncTower.getNpcEvent(eventIdData[2])
        local eventData3 = FuncTower.getNpcEvent(eventIdData[3])
        if eventData.type and eventData2.type and eventData3.type
            and eventData.type == FuncTowerMap.NPC_EVENT_TYPE.ROB_TREASURE 
            and eventData2.type == FuncTowerMap.NPC_EVENT_TYPE.ROB_WOMAN 
            and eventData3.type == FuncTowerMap.NPC_EVENT_TYPE.ROB_STONE 
        then
            -- 劫匪
            npcType = FuncTowerMap.NPC_TYPE.ROBBER
            WindowControler:showWindow("TowerNpcRobberView",_id,gridPos)
        end
    end
end

function TowerControler:choseChestView(_id,gridPos)
    local chestData = FuncTower.getTowerChest(_id)

    local chestType = FuncTowerMap.BOX_OPEN_CON_TYPE.NONE
    -- 如果条件不为空
    if not empty(chestData.condition) then
        chestType = FuncTowerMap.BOX_OPEN_CON_TYPE.NEED_KEY
    end
    local isOneOff,hasGot = TowerMainModel:isOneOffBoxAndHaveGot( _id )
    if isOneOff and hasGot then
        local params = {}
        params.x = gridPos.x
        params.y = gridPos.y
        local function getOneOffBoxCallback( serverData )
            if serverData.error then
                return 
            else
                TowerMainModel:updateData(serverData.result.data)
                EventControler:dispatchEvent(TowerEvent.TOWEREVENT_OPEN_BOX_SUCCESS)  --- 获取宝箱成功
            end
        end
        TowerServer:getChest(params,c_func(getOneOffBoxCallback)) 
        WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_094"))
    else
        WindowControler:showWindow("TowerChestView",gridPos,chestType,_id)
    end
end

-- 弹出连杀3怪奖励界面
function TowerControler:enterBeforeShopRewardView(_rewardData,_gridPos)
    if _rewardData and not table.isEmpty(_rewardData) then
        WindowControler:showWindow("TowerBeforeShopRewardView",_rewardData,_gridPos)
    end
end

-- 进入锁妖塔主界面
-- 先同步下服务器数据
function TowerControler:enterTowerMainView()
    local callBack = function()
        WindowControler:showWindow("TowerMainView")
    end
    self:getMapData(c_func(callBack))
end

-- 拉取锁妖塔数据
function TowerControler:getMapData(callBack)
    local getDataCallBack = function(event)
        if event.error then
            echo("没有拉取到锁妖塔的数据")
        else
            TowerMainModel:updateData(event.result.data)
            if callBack then
                callBack()
            end
        end   
    end
    TowerServer:getMapData(c_func(getDataCallBack))
end

-- 参数为格子坐标
function TowerControler:showShopView(xIdx,yIdx)
    local shopInfo = TowerMapModel:getShopInfo(xIdx,yIdx)
    dump(shopInfo, "商店信息 shopInfo")
    if not shopInfo then
        return
    end

    local _curFloorId = TowerMainModel:getCurrentFloor()
    local _rewardId = shopInfo.reward

    WindowControler:showWindow("TowerMapShopView",shopInfo.shopId,cc.p(xIdx,yIdx))
end

-- 检查是否有未完成的商店
function TowerControler:checkUnCompleteShop()
    if TutorialManager.getInstance():isInTutorial() then
        return
    end

    local shopInfo = TowerMapModel:getLocalShopInfo()
    -- dump(shopInfo, "打开未完成的商店 shopInfo")

    if shopInfo then
        local xIdx = shopInfo.x 
        local yIdx = shopInfo.y
        if xIdx and yIdx then
            self:showShopView(xIdx,yIdx)
        end
    else
        local curFloor = TowerMainModel:getCurrentFloor()
        local hasPopup = TowerMainModel:checkHasBeenPopupRewardPreview(curFloor)
        if (not hasPopup) or tostring(hasPopup) == "nil" then
            TowerMainModel:recordHasAutoOpenPreview( curFloor,true )
            WindowControler:showWindow("TowerRewardPreviewView",curFloor)
        end
    end
end

return TowerControler
