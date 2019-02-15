require("game.sys.view.tower.map.TowerConfig")

local TowerMainModel = class("TowerMainModel",BaseModel)

function TowerMainModel:init(data)
    TowerMainModel.super.init(self,data)
    self.TowerMainData = {}
    self.tempMonster = {}

    self._datakeys = {
		towerExt = {},
        towerFloor = {},
		towerCollection = {},   -- 搜刮数据   
	}

	self:initData()
	self:createKeyFunc()
	self:registerEvent()

    -- 如果等级达到锁妖塔开启等级 那么检查红点
    -- if UserModel:level() >= 38 then
    --     local params = {}
    --     TowerServer:getTowerMainData(params,c_func(self.checkMainViewRed,self))
    -- end

    local tempPerfect = self:getPerfectTime() or 0
    self:setPerfectTime(tempPerfect)

    self.DEBUG  = TowerConfig.SHOW_TOWER_DATA
end


function TowerMainModel:initData(data)
    -- 同时拥有道具最大数量
    self.maxOwnItemNum = 3

    self._data.towerExt = {}
    self._data.towerFloor = {}
    self._data.towerCollection = {}

    -- TODO 每次需求变更，都需要跟后端核对不同结构数据的更新方式
    -- towerFloor 下需要合并的数据
    self.towerFloorMergeKeyArr = {"cells","enemyInfo","notPerfectFloors","notPerfectFloorInfos"}
    -- 重置锁妖塔操作时，不能重置的数据
    self.notResetKeyArr = {"floorRewards"}
end

function TowerMainModel:registerEvent()
    EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_BATTLE_KK,self.attackMonsterComplete,self)
    -- 更新战斗结果数据
    EventControler:addEventListener(TowerEvent.TOWEREVENT_UPDATE_BATTLE_DATA,self.updateBattleResultData,self)

    EventControler:addEventListener("tower_collection_check_redpoint", self.dalayToCheckRed,self)
    
    self.delayTimeToCheckRedPoint = 3
    TimeControler:startOneCd("tower_collection_check_redpoint",self.delayTimeToCheckRedPoint)
end

function TowerMainModel:dalayToCheckRed()
    -- if UserModel:towerExt().maxReachFloor and UserModel:towerExt().maxReachFloor>0 then
        self:initCollectingData(c_func(self.checkCollectionBtnRedPoint,self))
    -- end
end

-- 获取战斗新增的星星数量
function TowerMainModel:getBattleAddStar()
    local changeStar = 0
    local battleUpdateData = self.battleUpdateData
    if not battleUpdateData then
        return changeStar
    end

    local oldStar = TowerMainModel:towerExt().star or 0
    local newStar = battleUpdateData.towerExt.star or 0
    echo("_______星星数量变化 oldStar,newStar __________",oldStar,newStar)
    changeStar = tonumber(newStar) - tonumber(oldStar)
    return changeStar
end

-- 获取战斗杀死的怪id
function TowerMainModel:getKilledMonsterId()
    local battleUpdateData = self.battleUpdateData
    local monsterId = nil
    if not battleUpdateData then
        return monsterId
    end

    local oldKillMonsters = self:getKillMonsters()
    local newKillMonsters = battleUpdateData.towerFloor.killMonsters

    if newKillMonsters ~= nil then
        for k,v in pairs(newKillMonsters) do
            if oldKillMonsters[k] == nil 
                or tonumber(oldKillMonsters[k]) < tonumber(newKillMonsters[k])
                then
                monsterId = k
                break
            end
        end
    end
    return monsterId
end

-- 战斗完毕恢复，做完各种动画逻辑后，需要更新战斗数据
function TowerMainModel:updateBattleResultData()
    -- echo("updateBattleResultData 更新战斗数据 ",self.battleUpdateData)
    if self.battleUpdateData then
        self.battleUpdateData.monsterReward = nil
        self:updateData(self.battleUpdateData)
        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_UPDATE_BATTLE_DATA_SUCCESS)
        self.battleUpdateData = nil
    end
end

--更新数据
function TowerMainModel:updateData(data,isBattle)
    if not data then
        return
    end
    
    if isBattle then
        self.battleUpdateData = table.deepCopy(data)
        return
    end

    if self.DEBUG then
        echo("TowerMainModel 更新数据-----------")
        dump(data)
    end
    
    self._oldData = table.deepCopy(self._data)
    -- 需要合并的数据
    if data.towerFloor then
        for k,v in pairs(data.towerFloor) do
            -- 合并数据(服务器没给的数据本地还保存)
            if table.indexof(self.towerFloorMergeKeyArr,k) then
                if self._data.towerFloor[k] == nil then
                    self._data.towerFloor[k] = {}
                end
                table.deepMerge(self._data.towerFloor[k],v)
            else
                -- 覆盖数据(服务器没给的数据本地同时删除)
                if(type(v) =="table") then
                    self._data.towerFloor[k] = table.deepCopy(v)
                else
                    self._data.towerFloor[k] = v
                end
            end
        end
    end

    if data.towerExt then
        for k,v in pairs(data.towerExt) do
            -- 新增了未完美通关 及 未完美通关层数据字段
            if table.indexof(self.towerFloorMergeKeyArr,k) then
                if self._data.towerExt[k] == nil then
                    self._data.towerExt[k] = {}
                end
                table.deepMerge(self._data.towerExt[k],v)
            else
                -- 覆盖数据(服务器没给的数据本地同时删除)
                if(type(v) =="table") then
                    self._data.towerExt[k] = table.deepCopy(v)
                else
                    self._data.towerExt[k] = v
                end
            end
        end
    end

    if self.DEBUG then
        echo("TowerMainModel 全部tower数据--------")
        dump(self._data)
    end
    
    if self._data.towerExt.employeeInfo and not self.mercenaryId then
        -- for k,v in pairs(self._data.towerExt.employeeInfo) do
        --     local data = json.decode(v)
        --     if tonumber(data.hpPercent) > 0 then
        --         TowerMainModel:saveMercenaryId(k)
        --     end
        -- end
    end

    if data.towerCollection then
        -- dump(data.towerCollection, "=====服务器返回的搜刮数据")
        for k,v in pairs(data.towerCollection) do
            if k == "events" then
                if v == nil or table.length(v) < 1 then
                    self._data.towerCollection[k] = {}
                else
                    -- echo("______ 走这里走这里 ____________")
                    if not self._data.towerCollection[k] then
                        self._data.towerCollection[k] = {}
                    end
                    -- table.deepMerge(self._data.towerCollection[k],v)
                    for kk,vv in pairs(v) do
                        self._data.towerCollection[k][kk] = table.deepCopy(vv)
                    end
                end
            elseif k == "reward" then
                self._data.towerCollection[k] = json.decode(v)
            else
                if k == "finishTime" then
                    if self._data.towerCollection[k] and (v < self._data.towerCollection[k]) then
                    -- 搜刮加速数据更新完成
                        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_TOWER_ACCELERATE_DATA_UPDATE_SUCCEED)
                    end
                    if v == 0 then
                        self._data.towerCollection = table.deepCopy(data.towerCollection)
                        break
                    end
                end
                self._data.towerCollection[k] = v
            end
        end
        -- dump(self._data.towerCollection, "======搜刮数据更新后")
    end

    if self:towerExt().map then
        TowerMapModel:updateMapData()
    end
    
    EventControler:dispatchEvent(TowerEvent.TOWEREVENT_TOWER_DATA_UPDATE)
end

--[[
    是否已经同步服务器端地图数据
]]
function TowerMainModel:hasUpdateServerData()
    if self:towerFloor() and self:towerFloor().cells then
        return true
    end

    return false
end

-- 重新加载锁妖塔数据
-- 重置/扫荡/重新锁妖塔都会重新加载数据，先清空本地数据再用服务器数据覆盖
function TowerMainModel:reLoadTowerData(serverData)
    -- echoError ("重置数据..............")
    -- dump(serverData)
    self:resetData()
    TowerMapModel:clearMapData()
    self:updateData(serverData)
end

function TowerMainModel:resetTower()
    echo("\n\n---------------重置地图数据...........")
    self:resetData()
    TowerMapModel:clearMapData()
    -- TowerMapModel:updateMapData()
    local _params = {}
    TowerMainModel:saveNPCRobberRobData( _params )
end

function TowerMainModel:resetData()
    local data = self._data.towerExt
    for k,v in pairs(data) do
        if(type(v) =="table") and not table.indexof(self.notResetKeyArr, k) then 
            data[k] = {}
        end
    end

    data = self._data.towerFloor

    for k,v in pairs(data) do
        if(type(v) =="table") and not table.indexof(self.notResetKeyArr, k) then 
            data[k] = {}  
        elseif (type(v) =="number") then
            data[k] = 0    
        end
    end
end

function TowerMainModel:getMaxOwnItemNum()
    return self.maxOwnItemNum
end

--获取人物当前所在楼层
function TowerMainModel:getCurrentFloor()
    return self:towerExt().currentFloor
end

--获取人物历史最高楼层
function TowerMainModel:getMaxClearFloor()
    return self:towerExt().maxClearFloor
end

-- 获取最大层数
function TowerMainModel:getMaxFloor()
    return FuncTower.getMaxFloor()
end

--获取人物可扫荡的层数
function TowerMainModel:getPerfectFloor()
    return self:towerExt().maxPerfectFloor
end

-- 获取人物曾经到达的最高层,进入该层即算达到该层
-- 比如达到4层但是没通过,则重置后,maxClearFloor = 3,maxReachFloor = 4
function TowerMainModel:getMaxReachFloor()
    return self:towerExt().maxReachFloor
end

-- 获取人物可搜刮的层数
-- 注意这是重置之后才会更新的  
-- 重置之前 即使完美通关了新的层 这个值也不会变
function TowerMainModel:getCollectionFloor()
    return self:towerExt().collectionFloor or 0
end

--首通奖励数组
function TowerMainModel:getTowerFloorReward()
    return self:towerExt().floorRewards
end

--[[
    获取地图反转值
    0:正常地图
    1:Y轴反转地图
]]
function TowerMainModel:getTowerMapReveral()
    return self:towerExt().reversal
end

-- 获取当前层使用的地图表名
-- 四测需求
function TowerMainModel:getCurInUseMapName()
    if not self:towerExt().map then
        echoError ("没有map数据,这可能是老号 默认用TowerMap1")
        return  "TowerMap1"
    end
    return  self:towerExt().map
end

function TowerMainModel:getShopsBuff(_id)
    if self:towerFloor().shops then
        return self:towerFloor().shops[_id]
    else
        return nil
    end
end

function TowerMainModel:getAllShopsBuff()
    if self:towerFloor().shops then
        return self:towerFloor().shops
    else
        return nil    
    end    
end


-- 根据当前扫荡到的层取得扫荡商店
-- 返回商店id 和商店里的buff列表
-- -         "shops" = {
-- -             "2_1" = {
-- -                 "106" = 0
-- -                 "203" = 1
-- -                 "301" = 0
-- -             }
-- -         }
function TowerMainModel:getNextFloorBuffList(_curTempFloor)
    local buffList = {}
    local shopIdList = {}
    if self:towerFloor().shops then
        for _shopId,_shopBuffList in pairs(self:towerFloor().shops) do
            local shopFloor = string.split(_shopId,"_")
            if shopFloor and (tostring(shopFloor[1]) == tostring(_curTempFloor)) then
                shopIdList[#shopIdList + 1] = _shopId
                for _buffId,_haveBoughtBuffNum in pairs(_shopBuffList) do
                    local tempBuff = {shopId = _shopId,buffId = _buffId,haveBoughtNum = _haveBoughtBuffNum}
                    buffList[#buffList + 1] = tempBuff
                end
            end
        end
    end
    -- dump(buffList, "________TowerMainModel中获得扫荡的某层 buffList _______")
    return shopIdList,buffList  
end

-- 获取当前层的总星数
function TowerMainModel:getAllStar()
    if self:towerFloor().floorStar then
        return tonumber(self:towerFloor().floorStar)
    else
        return 0
    end
end

--[[
    是否使用了解毒草
    true服用了解毒草
    false未使用
    解毒草道具只在本层有效
]]
function TowerMainModel:hasPoisonBuff()
    local hasBuff = self:towerFloor().hasPoisonBuff
    if not hasBuff or tonumber(hasBuff) == 0 then
        return false
    else
        return true
    end
end

-- 获取buff id数组
function TowerMainModel:getCurrentBuffs()
    return self:towerExt().currentBuffs
end

-- 获取临时buff(其中的id为道具id)
function TowerMainModel:getCurrentBuffTemps()
    return self:towerExt().currentBuffTemps or {}
end

-- 获取buff属性数组
function TowerMainModel:getBuffAttrList()
    local buffs = self:getCurrentBuffs()
    local attrArr = {}

    if buffs then
        for k,v in pairs(buffs) do
            local buffData = FuncTower.getShopBuffData(k)
            local effect = buffData.effect
            for i=1,v do
                if effect then
                    for i=1,#effect do
                        attrArr[#attrArr+1] = table.copy(effect[i])
                    end
                end
            end
        end
    end

    local findAttr = function(attrList,attr)
        for k, v in pairs(attrList) do
            if v.key == attr.key and v.mode == attr.mode then
                return v
            end
        end

        return nil
    end

    local finalAttr = {}
    for k, v in pairs(attrArr) do
        local attr = findAttr(finalAttr,v)
        if attr then
            attr.value = attr.value + v.value
        else
            finalAttr[#finalAttr+1] = v
        end   
    end

    return finalAttr
end

-- 根据道具Id获取buff战斗属性
function TowerMainModel:getBuffAttrByItemId(itemId)
    local goodsData = FuncTower.getGoodsData(itemId)
    local buffAttr = nil
    -- 属性加成
    if goodsData.goodsType == FuncTower.GOODS_TYPE.TYPE_3 then
        local buffId = goodsData.attribute[1]
        local buffAttrData = FuncTower.getTowerBuffAttrData(buffId)
        buffAttr = buffAttrData.attr
    end

    return buffAttr
end

-- 根据道具Id获取buff描述
function TowerMainModel:getBuffDesByItemId(itemId)
    local buffDes = nil
    -- TODO 如果是解毒草
    -- 因逻辑问题，解毒草没有buff提醒，策划要求解毒草写死buff描述
    if tostring(itemId) == FuncTowerMap.JIEDUCAO_ID then
        -- buffDes = "免疫本层所有毒性效果"
        buffDes = GameConfig.getLanguage("#tid_tower_prompt_114")
        return buffDes
    end
    
    local buffTemps = self:getCurrentBuffTemps()
    -- buffTemps = {["1004"] = 1}
    -- dump(buffTemps,"buffTemps-----------------")

    for k, v in pairs(buffTemps) do
        if k == itemId then
            local buffAttr = self:getBuffAttrByItemId(itemId)
            -- 目前仅支持一个属性，策划保证仅飘出一个buff
            if buffAttr then
                local curAttr = buffAttr[1]
                local attrName = ""
                -- 写死战斗属性，如果是法防或物防，都显示防御
                if curAttr.key == 11 or curAttr.key == 12 then
                    -- "防御"
                    attrName = GameConfig.getLanguage("#tid_tower_prompt_115")
                else
                    attrName = FuncBattleBase.getAttributeName(curAttr.key)
                end
                local tempValue = curAttr.value
                local buffDes = FuncBattleBase.getFormatFightAttrValueByMode(curAttr.key,tempValue,curAttr.mode)
                
                local finalBuffDes = GameConfig.getLanguageWithSwap("tid_tower_prompt_106",attrName,buffDes)
                -- return "下场战斗" .. attrName .. "+" .. buffDes
                return finalBuffDes
            end
        end
    end

    return buffDes
end

-- 获取所有临时buff 战斗属性加成
function TowerMainModel:getBuffTempsAttr()
    local buffTemps = self:getCurrentBuffTemps()
    local attrList = {}

    for k, v in pairs(buffTemps) do
        local itemId = k
        local goodsData = FuncTower.getGoodsData(itemId)
        -- 属性加成
        if goodsData.goodsType == FuncTower.GOODS_TYPE.TYPE_3 then
            local buffId = goodsData.attribute[1]
            local buffAttrData = FuncTower.getTowerBuffAttrData(buffId)
            local buffAttr = buffAttrData.attr
            for i=1,#buffAttr do
                attrList[#attrList+1] = buffAttr[i]
            end
        end
    end

    return attrList
end

function TowerMainModel:getTowerTeamFormation()
    local tempTeamInfo = {}

    if self:towerExt().employeeInfo then
        for k,v in pairs(self:towerExt().employeeInfo) do
            local teamData = json.decode(v)
            tempTeamInfo[tostring(teamData.hid)] = teamData  
        end
    end

    if self:towerExt().unitInfo then
        for k,v in pairs(self:towerExt().unitInfo) do
            local teamData = json.decode(v)
            tempTeamInfo[tostring(teamData.hid)] = teamData  
        end       
    end

    -- 将已经被禁用的奇侠记录下来
    local banPartners = {}
    if self:towerExt().banPartners and table.length(self:towerExt().banPartners) then
        banPartners = self:towerExt().banPartners
    end
    return tempTeamInfo, banPartners   
end

function TowerMainModel:checkEmployeeExist()
    if self:towerExt().employeeInfo and table.length(self:towerExt().employeeInfo) > 0 then
        return true
    end
    return false
end

-- 获取被劫持的法宝
function TowerMainModel:getBanTreasure()
    local banTreasures = {}

    if self:towerExt().banTreasures then
        banTreasures = self:towerExt().banTreasures
    end
    return banTreasures
end

function TowerMainModel:getBruiseTeamFormation(type,isHasHero,subType,sortType,existingData)
     local partners = PartnerModel:getAllPartner()
    local partnersSupply = self:getTowerTeamFormation()
    local npcs = {}
    local deadNpcs = {}
    for k,v in pairs(partners) do
        local npcCfg = FuncPartner.getPartnerById(v.id)
        local tempAbility = PartnerModel:getPartnerAbility(v.id)
        if subType == 0 or npcCfg.type == subType then 
            local npcInfo = partnersSupply[tostring(v.id)]
            local temp = {}
            local isAttend = self:checkTeamIsHas(v.id,existingData) 
            temp.id = v.id
            temp.level = v.level
            temp.quality = v.quality 
            temp.skills = v.skills 
            temp.star = v.star
            temp.name = npcCfg.name
            temp.icon = npcCfg.icon 
            temp.sourceId = npcCfg.sourceld
            temp.dynamic = npcCfg.dynamic
            temp.order = 0
            temp.tempAbility = tempAbility
            if npcInfo then
                temp.HpPercent = npcInfo.hpPercent or 10000
                temp.fury = npcInfo.energyPercent or 0
            else
                temp.HpPercent =  10000
                temp.fury =  0
            end  
            if isAttend then  
                -- 被劫色后的奇侠不可治疗,要排除
                local banPartners = TowerMainModel:towerExt().banPartners or {}
                if not table.isKeyIn(banPartners,tostring(v.id)) then
                    if temp.HpPercent <= 0 then
                        table.insert(deadNpcs,temp)
                    else    
                        table.insert(npcs,temp)
                    end
                end
            end
        end    
    end

    if isHasHero then
        local playHid = UserModel:getCharId()
        local playInfo = partnersSupply[tostring(playHid)]
        local player = {}

        local isAttend = self:checkTeamIsHas(UserModel:avatar(),existingData) 
        player.id = playHid
        player.level = UserModel:level()
        --暂定  todo dev
        player.star = UserModel:star()      --默认玩家的星级 1
        player.order = 1
        player.quality = UserModel:quality()
        player.name  = UserModel:name()
        if playInfo then
            player.HpPercent = playInfo.hpPercent
            player.fury = playInfo.energyPercent
        else
            player.HpPercent = 10000
            player.fury = 0
        end 
        if isAttend then      
            if player.HpPercent <= 0 then
                table.insert(deadNpcs,player)
            else    
                table.insert(npcs,player)
            end
        end    
    end   

    --这里应该有一个排序，上阵的，然后是品质，等等  这里进行一次排序，玩家自己放在最前面
    if sortType then
        table.sort(npcs,c_func(self.spellBreakerRule,self))
        return npcs
    else
        table.sort(npcs, c_func(self.hasNowRule,self))
        table.sort(deadNpcs, c_func(self.hasNowRule,self))
        --这里应该有一个排序，上阵的，然后是品质，等等  这里进行一次排序，玩家自己放在最前面
        if tonumber(type) ~= 3 then
            for k,v in pairs(deadNpcs) do
                npcs[#npcs+1] = v 
            end  
            return npcs
        else
            return deadNpcs   
        end    
    end
   
end

function TowerMainModel:hasNowRule(a,b)
    FuncTeamFormation.partnerSortRule(a, b)
end

--法阵专用的排序方法
function TowerMainModel:spellBreakerRule(a,b)
    local rst = false
    if a.order>b.order then
        rst = true
    elseif a.order == b.order then
        if a.quality<b.quality then
            rst = true
        elseif a.quality==b.quality then
            if a.star<b.star then
                rst = true
            elseif a.star==b.star then
                if a.level<b.level then
                    rst = true
                elseif a.level == b.level then
                            --todo
                    if toint(a.id)>toint(b.id) then
                        rst = true
                    elseif toint(a.id)==toint(b.id) then
                        rst = false
                    else
                        rst = false
                    end
                else
                    rst = false
                end
            else
                rst = false
            end
        else
            rst = false
        end
    else
        rst = false
    end 
    return rst
end

-- 判断是否有开宝箱的钥匙
function TowerMainModel:isHasBoxKey(keyId)
   local itemData = self:towerExt().goods
    if itemData ~= nil then
        for k,v in pairs(itemData) do
            if tostring(v) == tostring(keyId) then
                return true
            end
        end    
    end
    return false
end

function TowerMainModel:getItemNum()
    local itemData = self:towerExt().goods
    local itemNum = 0
    if itemData ~= nil then
        for k,v in pairs(itemData) do
            itemNum = itemNum +1
        end    
    end
    return itemNum
end

function TowerMainModel:saveMonterData(params)
    if not empty(self.tempMonster) then
        self.tempMonster ={}
    end
    self.tempMonster = params
end

function TowerMainModel:getLastBattleMonster()
    return self.tempMonster
end

function TowerMainModel:attackMonsterComplete(event)
    if event.params.rt == Fight.result_win then
        self.isBattleWin = true
        -- EventControler:dispatchEvent(TowerEvent.TOWEREVENT_ATTACK_MONSTER_SUCCESS,{monsterId=event.params.monster})
    else
        self.isBattleWin = false
        -- EventControler:dispatchEvent(TowerEvent.TOWEREVENT_ATTACK_MONSTER_FAIL,{monsterId=event.params.monster})    
    end
end

function TowerMainModel:checkBattleWin()
    return self.isBattleWin
end

-- 获取当前拥有的道具
function TowerMainModel:getGoods()
    local goods = self:towerExt().goods or {}
    return goods
end

-- 获取当前拥有的道具
function TowerMainModel:getGoodsSortArr()
    local goods = self:towerExt().goods or {}
    local goodsArr = {}
    for k,v in pairs(goods) do
        local oneGoods = {id=v,num=1,time =k}
        goodsArr[#goodsArr+1] = oneGoods
    end
    table.sort(goodsArr,function(a,b)
        if tonumber(a.time)<tonumber(b.time) then
            return true
        end
    end)
    return goodsArr
end

-- 获取当前拥有的道具数量
function TowerMainModel:getGoodsNum()
    local goods = self:getGoods()
    return table.length(goods)
end

-- 获取杀死的怪列表
function TowerMainModel:getKillMonsters()
    local monsters = TowerMainModel:towerFloor().killMonsters
    return monsters or {}
end

-- 获取敌人信息数据
function TowerMainModel:getEnemyInfo()
    local enemyInfo = TowerMainModel:towerFloor().enemyInfo
    return TowerMainModel:towerFloor().enemyInfo or {}
end

-- 通过ID获取敌人信息数据
function TowerMainModel:getMonsterInfo(monsterId)
    local enemyInfo = self:getEnemyInfo()
    local monsterInfo = {}
    for k,v in pairs(enemyInfo) do
        if k == tostring(monsterId) then
            if not empty(v) then
                monsterInfo = json.decode(v)
                break
            end    
        end
    end

    return monsterInfo
end

--重置状态(是否重置了)
function TowerMainModel:getResetType()
    return self:towerExt().resetStatus
end

-- 获取历史通关层累积拥有的星星数量
function TowerMainModel:getCurOwnStarNum()
    return self:towerExt().star
end

function TowerMainModel:getResetNum()
    local isShow = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TOWER)
    local isSweep = self:getResetType()
    if isShow then
       local todayNum = self:getTowerNum()
       return todayNum
    else
        return 0
    end   
end

-- 获取重置锁妖塔剩余次数
function TowerMainModel:getTowerNum()
    local todayNum = FuncDataSetting.getTowerResetNum()
    local nowUseResetNum = CountModel:getTowerResetCount()
    local nowResetNum = tonumber(todayNum) - tonumber(nowUseResetNum)
    return nowResetNum
end

-- 判断当前是否还有该商店,有则返回true
-- 购买所有buff之后服务器会删除商店
function TowerMainModel:isNowHasShop(_id)
    local buffData = self:towerFloor().shops
    if empty(buffData) then
        return false
    end
    for k,v in pairs(buffData) do
        if tostring(k) == tostring(_id) 
            and not empty(v) then
            return true
        end
    end
    return false
end

-- 根据道具Id获取buff描述
function TowerMainModel:getMonsterBuffDesByItemId(itemId)
    local buffDes = nil
    local buffTemps = self:getCurrentBuffTemps()
    for k, v in pairs(buffTemps) do
        if k == itemId then
            local buffAttr = self:getBuffAttrByItemId(itemId)
            if buffAttr then
                local curAttr = buffAttr[1]
                local attrName = ""
                -- 写死战斗属性，如果是法防或物防，都显示防御
                if curAttr.key == 11 or curAttr.key == 12 then
                    attrName = "防御"
                else
                    attrName = FuncBattleBase.getAttributeName(curAttr.key)
                end
                local tempValue = curAttr.value
                if tonumber(v)>1 then 
                    tempValue = curAttr.value * tonumber(v)
                end
                local buffDes = FuncBattleBase.getFormatFightAttrValueByMode(curAttr.key,tempValue,curAttr.mode)
                
                local finalBuffDes = attrName.." + "..buffDes
                return finalBuffDes
            end
        end
    end

    return buffDes
end

function TowerMainModel:checkTeamIsHas(_id,allViewData)
    if allViewData then
        for k,v in pairs(allViewData) do
            if tonumber(_id) == tonumber(v) then
                return false
            end
        end
    end    
    return true
end

function TowerMainModel:checkMapShop()
    local mapData = self:towerFloor().cells
    if not mapData then
        return false
    end

    for k,v in pairs(mapData) do
        if v["type"] and v["type"] == 8 then
            return false
        end
    end
    return true
end

-- 废弃 20180416
function TowerMainModel:checkMainViewRed(event)
    if event.error then
        echo("没有获取到锁妖塔主界面数据")
    else
        if table.length(event.result.data.towerExt) ~= 0 then
            if event.result.data.towerExt.maxClearFloor > 0 then
                local rewardBoxIdx = {1,3,5,7,9,10} 
                for i = 1,6 do
                    if rewardBoxIdx[i] <= event.result.data.towerExt.maxClearFloor then
                        local isReceived = true
                        if event.result.data.towerExt.floorRewards then
                            for k,v in pairs(event.result.data.towerExt.floorRewards) do
                                if tostring(k) == tostring(rewardBoxIdx[i]) then
                                    isReceived = false
                                    break
                                end
                            end
                            if isReceived then
                                EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                                {redPointType = HomeModel.REDPOINT.DOWNBTN.ELITE, isShow = true});
                                break
                            end   
                        end
                    end
                end
            end

            if event.result.data.towerExt.resetStatus == 2 then
                EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.DOWNBTN.ELITE, isShow = true});
            end
        end
    end
end

-- 检查锁妖塔的所有红点
function TowerMainModel:checkTowerAllRedPoint()
    local isShowBox = false --2018.08.01 主界面宝箱红点暂时不考虑 self:isShowPassFloorBoxRed()
    local isShowCollection = self:isShowCollectionRedPoint()
    local isShowReset = self:isShowResetTimesRedPoint()

    local isShowHomeRed = isShowBox or isShowCollection or isShowReset
    -- echo("isShowBox========",isShowBox)
    -- echo("isShowReset========",isShowReset)
    -- echo("isShowCollection========",isShowCollection)

    return isShowHomeRed
end

-- 显示主界面宝箱红点
function TowerMainModel:isShowPassFloorBoxRed()
    local maxFloor = FuncTower.getMaxFloor() or 1
    for i=1,maxFloor do
        local floorId = i
        local floorData = FuncTower.getOneFloorData( floorId )
        -- 判断宝箱类型,注意或者显示宝箱或者显示解锁的商店商品
        local isShopBox = false
        if floorData and floorData.reward then
            isShopBox = false
        elseif floorData and floorData.shopUnlock then
            isShopBox = true
        end
        -- 判断宝箱状态,是否领取
        -- 注意是否点开看过 点开看过就算领取
        local boxStatus = FuncTower.boxStatusType.LOCK
        local maxPassFloor = TowerMainModel:getMaxClearFloor()
        if maxPassFloor and tonumber(floorId) <= maxPassFloor then
            boxStatus = FuncTower.boxStatusType.ACCESSIBLE
        end

        -- 如果是已解锁商店 如果点击查看过则算是 已经领取
        if isShopBox then
            local hasCheck = TowerMainModel:getHasCheckTowerShopGoods(floorId)
            if tostring(hasCheck) == "true" then
                boxStatus = FuncTower.boxStatusType.GOT
            else
                boxStatus = FuncTower.boxStatusType.LOCK
            end
        else
            local haveGotBox = TowerMainModel:getTowerFloorReward() or {}
            for k,v in pairs(haveGotBox) do
                if tostring(floorId) == tostring(k) then
                    boxStatus = FuncTower.boxStatusType.GOT
                end
            end
        end
        if boxStatus == FuncTower.boxStatusType.ACCESSIBLE then
            return true
        end
    end
    return false
end

-- 显示搜刮红点
function TowerMainModel:isShowCollectionRedPoint()
    if self:getCollectionFloor() > 0 then
        if TowerMainModel:isInNewGuide() then
            return false
        else
            return self:checkCollectionBtnRedPoint(true)
        end
    else
        return false
    end
end

-- 显示剩余重置次数红点
function TowerMainModel:isShowResetTimesRedPoint()
    local leftResetTimes = TowerMainModel:getTowerNum()
    if tonumber(leftResetTimes) > 0 then
        if TowerMainModel:isInNewGuide() then
            return false
        else
            return true
        end
    else
        return false
    end
end

function TowerMainModel:setPerfectTime(Time)
   LS:prv():set(StorageCode.tower_clearance_time,Time)
end

function TowerMainModel:getPerfectTime()
    local tempNum = LS:prv():get(StorageCode.tower_clearance_time,0)
    return tempNum
end

function TowerMainModel:enterNextData(data)
    self.enterUpdateData = table.deepCopy(data)
end

function TowerMainModel:getNextData()
    return self.enterUpdateData
end

-- 保存 是否需要快速打开格子的标记 
-- 场景主界面关闭时 需要快速将格子的状态置为已探索
function TowerMainModel:saveGridAni(type)
    self.nowGridAni = type
end
function TowerMainModel:getGridAni()
    local tempType = false
    if self.nowGridAni then
        tempType = true
    end
    return tempType
end
      
-- 保存劫财劫色npc 劫的数据
function TowerMainModel:saveNPCRobberRobData( _params )
    if not self.robRecordName then
        self.robRecordName = "__rob_records_name_"
    end
    self.npcRobData = _params
    if self.oldRobData and (self.npcRobData.robId == self.oldRobData.robId) then
        return
    end

    if (not LSChat:byNameGetTable(self.robRecordName)) then
        LSChat:createTable(self.robRecordName)
    end

    dump(_params, "存信息____", 5)
    if _params then
        _params = json.encode( _params ) 
        LSChat:setData(self.robRecordName,"_params",_params)
    end
    self.oldRobData = self.npcRobData
end  

function TowerMainModel:getNPCRobberRobData()
    if not self.npcRobData then
        if not self.robRecordName then
            self.robRecordName = "__rob_records_name_"
        end
        local listtable = LSChat:byNameGetTable(self.robRecordName)
        if listtable ~= nil then
            local list = LSChat:getData(self.robRecordName,"_params")
            if tostring(list) ~= "nil" then
                dump(_params, "LSChat:getallData._params_________ ", 5)
                self.npcRobData = json.decode( list )
                self.oldRobData = self.npcRobData
            end
        end
    end
    dump(self.npcRobData, " 获取劫财劫色npc 劫的数据 self.npcRobData ")
    return self.npcRobData or {}
end  

-- -- 传入空则表示雇佣兵战死
-- function TowerMainModel:saveMercenaryId( _mercenaryId )
--     self.mercenaryId = _mercenaryId
--     LS:prv():set("___mercenaryId________",self.mercenaryId)
-- end
-- -- 获取已经有的雇佣兵 没有则返回nil
-- function TowerMainModel:gotMercenaryById()
--     local mercenaryId = LS:prv():get("___mercenaryId________")
--     echo(")___mercenaryId________",mercenaryId)
--     return mercenaryId
-- end

-- 获取临时五灵属性
function TowerMainModel:getTempWulingProperty()
    return self:towerFloor().soulBuffTemps
end
-- 获取已经领取的五灵属性
function TowerMainModel:getOwnWulingProperty()
    return self:towerExt().soulBuffs
end

-- 保存完美通关奖励 待完美通关动画播放的时候再展示
function TowerMainModel:savePerfactReward( _reward )
    self.perfactReward = _reward
end
function TowerMainModel:getPerfactReward()
    return self.perfactReward 
end

-- 保存完美通关后服务器返回的数据
function TowerMainModel:handlePerfactGearRuneData( _GearRuneData )
    -- self.perfactGearRuneData = _GearRuneData
    echo("\n\n\n _____ handle 完美通关回血回怒 数据 _________")
    if not _GearRuneData then
        self.recoverArr = nil
        self.recoverEnergy = nil
        return 
    end

    local isHasRecoveryGrid = TowerMapModel:checkIsHasRecoverGrid()
    echo("___________场上 是否有回血回怒格子_________________",isHasRecoveryGrid)
    if isHasRecoveryGrid and _GearRuneData.towerExt and _GearRuneData.towerExt.unitInfo then
        local newData = _GearRuneData.towerExt.unitInfo
        local oldData = TowerMainModel:towerExt().unitInfo
        if newData and table.length(newData)>0 then
            local increment = 0
            local curHid = nil
            local new1,old1
            for kk,vv in pairs(newData) do
                new1,old1 = 10000,10000
                if oldData and oldData[kk] then
                    oldDataItem = json.decode(oldData[kk])
                    old1 = tonumber(oldDataItem.hpPercent) 
                end 
                local newDataItem = json.decode(vv)
                curHid = newDataItem.hid
                new1 = tonumber(newDataItem.hpPercent)
                local newIncrement = new1 - old1 
                if math.abs(newIncrement) >= math.abs(increment) then
                    local oneItem = {
                        hid = curHid,
                        bloodIncrement = newIncrement,
                        nowNum = new1,
                        gearType = FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.BLOOD_REGAIN,
                    }
                    if not self.recoverArr then
                        self.recoverArr = {}
                        self.recoverArrTmp = {}
                    end
                    if math.abs(newIncrement) > math.abs(increment) then
                        self.recoverArr[#self.recoverArr + 1] = oneItem
                    else
                        self.recoverArrTmp[#self.recoverArrTmp + 1] = oneItem
                    end
                    increment = newIncrement
                end
            end

            -- 己方不能回血 血已满或者已全部阵亡
            if table.length(self.recoverArr)==0 and table.length(self.recoverArrTmp)>0 then
                self.recoverArr[1] = self.recoverArrTmp[1]
            end
        end
        dump(self.recoverArr, "@@@@ 完美通关回血数组")
    end

    self.recoverEnergy = nil
    if _GearRuneData.towerExt and _GearRuneData.towerExt.energy then
        local newEnergy = _GearRuneData.towerExt.energy
        local oldEnergy = TowerMainModel:towerExt().energy
        if not oldEnergy then
            oldEnergy = 0
        end
        local increment = newEnergy - oldEnergy 
        if not self.recoverEnergy then
            self.recoverEnergy = {}
        end

        -- 最大值限制
        local max = TowerMainModel:getMaxEnergy()
        if newEnergy > max then
            newEnergy = max
        end
        if oldEnergy > max then
            oldEnergy = max
        end

        -- if increment > 0 then
            self.recoverEnergy.energyIncrement = increment 
            self.recoverEnergy.nowNum = newEnergy 
            echo("_______@@@@ 完美通关回怒数组 @@@__ _______",self.recoverEnergy)
            -- local params = {energyIncrement = increment,nowNum = newEnergy}
            -- self:energyRecoverSucceed( params )
        -- else
        --     -- 如果怒气已满 则提示怒气已满
        --     local max = TowerMainModel:getMaxEnergy()
        --     if oldEnergy == max then
        --         self.recoverEnergy.energyIncrement = increment 
        --         self.recoverEnergy.nowNum = newEnergy 
        --     end
        -- end
    end
end

-- 获取回血回怒数据
function TowerMainModel:getPerfactGearRuneData()
    return  self.recoverArr,self.recoverEnergy
end


-- 保存打败抢劫者的奖励 待界面恢复的时候再展示
function TowerMainModel:saveBeatBadGuyData( _params )
    self.beatBadGuyData = _params
end
function TowerMainModel:getBeatBadGuyData()
    return self.beatBadGuyData
end


function TowerMainModel:saveCompesationData( _data )
    self.compesationData = _data
end

function TowerMainModel:getCompesationData()
    return self.compesationData
end

function TowerMainModel:getTotalStarNum(floor)
    local curFloorData = FuncTower.getOneFloorData(floor)
    -- 本层星总数量
    local starNum = curFloorData.starNum
    return starNum
end




-- ===========================================================================
-- 以下函数用于散灵法阵
-- ===========================================================================
-- 获取已经变更聚灵的次数
function TowerMainModel:getHasActiveRuneTimes()
    local allCellsData = self:towerFloor().cells
    for cellId,v in pairs(allCellsData) do
        if v.ext then
            local extData = json.decode(v.ext)
            if extData.runeTimes then
                return extData.runeTimes
            end
        end
    end
    return 0
end

-- 获取当前符文
function TowerMainModel:getRuneTempleType()
    local runeType = self:towerExt().runeType
    if not runeType then
        runeType = FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.SWORD
    end
    return runeType
end



-- ===========================================================================
-- 以下函数用于搜刮功能
-- ===========================================================================
-- 初始化搜刮相关数据
-- 在进入客户端不久之后进行
function TowerMainModel:initCollectingData(checkCollectionFunc)
    echo("________初始化搜刮相关数据 ........... 在进入主城不久之后进行 _____________________")
    if not self.hasInitCollectionStatus then
        local params = {}
        local function callBack( serverData )
            if not serverData.result then
                return
            end
            -- dump(serverData.result.data, "========== 搜刮进行时重登客户端 拉取数据 ============")
            TowerMainModel:updateData(serverData.result.data)
            self.hasInitCollectionStatus = true
            self:setTimerForCollection()
            if checkCollectionFunc then
                checkCollectionFunc()
            end
        end
        TowerServer:getTowerMainData(params,c_func(callBack))
    else
        self:setTimerForCollection()
    end
end

-- 将服务返回的数据进行排序
-- 并设定按时间搜刮到一个task 的定时器
-- 发出搜刮到物品的消息 其他地方进行监听
function TowerMainModel:setTimerForCollection()
    self.allCollections = self:sortAllCollections()
    -- dump(self.allCollections, "所有的待搜刮数据")
    self.haveCollectedTasks = {}
    self.leftTimers = {}
    self.foundReward = {}
    self.foundEvent = {}
    if self.allCollections and table.length(self.allCollections)>0 then
        TowerMainModel.COLLECTION_GOT_ONE_RESULT = "COLLECTION_GOT_ONE_RESULT"
        for key,v in pairs(self.allCollections) do
            local needLeftTime = v.appearTime - TimeControler:getServerTime()
            if needLeftTime <= 0 then
                self.haveCollectedTasks[#self.haveCollectedTasks+1] = table.deepCopy(v)
                if v.type == FuncTower.COLLECTION_RESULT_TYPE.REWARD then
                    self.foundReward[#self.foundReward + 1] = v.info
                elseif v.type == FuncTower.COLLECTION_RESULT_TYPE.EVENT then
                    -- self.foundEvent[#self.foundEvent + 1] = v.info
                    self.foundEvent[tostring(v.info)] = 0
                end
                EventControler:dispatchEvent(TowerEvent.TOWER_COLLECT_FIND_ONE_RESULT,v)
            else
                TimeControler:startOneCd(TowerMainModel.COLLECTION_GOT_ONE_RESULT..v.info, needLeftTime)
                self.leftTimers[tostring(v.info)] = v.info
                EventControler:addEventListener(TowerMainModel.COLLECTION_GOT_ONE_RESULT..v.info, self.gotOneCollction, self)
            end
        end 
    end
    -- dump(self.haveCollectedTasks, "self.haveCollectedTasks")
    -- dump(self.foundReward, "self.foundReward")
    -- dump(self.foundEvent, "self.foundEvent")
    -- dump(self.leftTimers, "self.leftTimers")
end

-- 将所有服务器返回的数据进行排序,以便搜刮中按顺序出现
-- 如果不是正在搜刮 返回的将是空表
-- 此时通过model数据即可取得相应的奖励 和事件
function TowerMainModel:sortAllCollections()
    local status = TowerMainModel:getCollectionStatus()
    if status ~= FuncTower.COLLECTION_STATUS.COLLECTING then
        return 
    end

    self.reward = table.deepCopy(self:towerCollection().reward or {})
    self.events = table.deepCopy(self:towerCollection().events or {})
    -- 将事件vector转换成数组,reward本身是数组的形式 不用转换
    local eventTempArr = {}
    for k,v in pairs(self.events) do
        eventTempArr[#eventTempArr+1] = k
    end
    self.events = eventTempArr

    -- dump(self.reward, "排序reward=======")
    -- dump(self.events, "排序events=======")

    local taskNum = #self.reward + #self.events

    local finishTime = self:towerCollection().finishTime
    local canCollectionFloor = self:getCollectionFloor()
    if canCollectionFloor <= 0 then
        return 
    end
    local collectionConfigData = FuncTower.getCollectionDataByID(canCollectionFloor)
    local startTime = finishTime - collectionConfigData.time
    local perTaskNeedTime = collectionConfigData.time/taskNum

    local randomseed = taskNum
    local allResults = {}
    for i=1,taskNum do
        math.randomseed(randomseed+finishTime)
        local index = math.random(1,randomseed)
        local tempItem = {}
        if index <= #self.reward then
            tempItem.type = FuncTower.COLLECTION_RESULT_TYPE.REWARD
            tempItem.info = self.reward[index]
            tempItem.appearTime = startTime + perTaskNeedTime*i
            table.remove(self.reward,index)
        else
            index = index - #self.reward
            echo("_____index___________",index)
            tempItem.type = FuncTower.COLLECTION_RESULT_TYPE.EVENT
            tempItem.info = self.events[index]
            tempItem.appearTime = startTime + perTaskNeedTime*i
            table.remove(self.events,index)
        end
        allResults[tostring(tempItem.info)] = tempItem
        randomseed = #self.reward + #self.events
    end
    -- dump(self.reward, "排序reward=======")
    -- dump(self.events, "排序events=======")
    -- dump(allResults, "排序=======")
    return allResults
end

-- 搜寻到一个任务时的处理函数
-- 记录在搜刮到的数组里 并发出消息 通知界面进行相应的展示
function TowerMainModel:gotOneCollction( event )
    local eventName = event.name
    local arr = string.split(eventName,TowerMainModel.COLLECTION_GOT_ONE_RESULT)
    local key = tostring(arr[2])
    self:cancelAllTimers(key)

    local targetTask = self.allCollections[key]
    if not targetTask then
        return 
    end
    self.haveCollectedTasks[#self.haveCollectedTasks+1] = table.deepCopy(targetTask)

    if targetTask.type == FuncTower.COLLECTION_RESULT_TYPE.REWARD then
        self.foundReward[#self.foundReward + 1] = targetTask.info
    elseif targetTask.type == FuncTower.COLLECTION_RESULT_TYPE.EVENT then
        -- self.foundEvent[#self.foundEvent + 1] = targetTask.info
        self.foundEvent[tostring(targetTask.info)] = 0
    end
    -- if TowerConfig.SHOW_TOWER_DATA then
        -- dump(targetTask, "搜寻到的目标task")
        -- dump(self.haveCollectedTasks, "self.haveCollectedTasks")
        -- dump(self.foundReward, "self.foundReward")
        -- dump(self.foundEvent, "self.foundEvent")
    -- end

    EventControler:dispatchEvent(TowerEvent.TOWER_COLLECT_FIND_ONE_RESULT,targetTask)
    TowerMainModel:checkCollectionBtnRedPoint()
end

-- 移除搜刮事件定时器
-- 传入相应cd 的key值则只移除相应的cd
-- 否则移除全部
function TowerMainModel:cancelAllTimers(cdkey)
    if TowerConfig.SHOW_TOWER_DATA then
        dump(self.leftTimers, "要移除的定时器")
    end
    if cdkey then
        TimeControler:removeOneCd( TowerMainModel.COLLECTION_GOT_ONE_RESULT..cdkey )
    elseif self.leftTimers and  table.length(self.leftTimers)>0 then
        for key,v in pairs(self.leftTimers) do
            TimeControler:removeOneCd( TowerMainModel.COLLECTION_GOT_ONE_RESULT..key )
        end
        self.leftTimers = {}
    end
end


-- 获取搜寻过程中搜刮到的奖励
-- 为数组格式 注意不同于事件数组 self.foundEvent
-- key 值为int value 为具体奖励string 如"1,5003,20"
function TowerMainModel:getFoundCollectingReward()
    local collectStatus = self:getCollectionStatus()
    if collectStatus ~= FuncTower.COLLECTION_STATUS.COLLECTING then
        self.foundReward = {}
    end
    return self.foundReward
end

-- 获取搜寻过程中搜刮到的事件
-- key 值为事件id value为事件完成与否 但是不能据此判断 需要通过checkEventStatus方法判断
function TowerMainModel:getFoundCollectingEvent()
    local collectStatus = self:getCollectionStatus()
    if collectStatus ~= FuncTower.COLLECTION_STATUS.COLLECTING then
        self.foundEvent = {}
    end
    return self.foundEvent
end


-- 获取搜刮结束时间
function TowerMainModel:getFinishTime()
    return self:towerCollection().finishTime
end

-- 获取搜刮完成后的奖励
function TowerMainModel:getHasFinishReward()
    return self:towerCollection().reward
end



-- 获取待处理的一个搜刮事件,
-- 用于处理事件界面 自动跳到下一个待处理事件
-- eventId,status,rewardIndex
-- 注意搜刮中和搜刮结束 获取事件的处理逻辑不同
function TowerMainModel:getToHandleEvent()
    local events = TowerMainModel:towerCollection().events
    -- 搜刮中
    local status,curProcess = TowerMainModel:getCurStatusAndProgress()
    if status == FuncTower.COLLECTION_STATUS.COLLECTING then
        events = self:getFoundCollectingEvent()
        if table.length(events) > 0 then
            for eventId,eventData in pairs(events) do
                local targetEventId,status = self:checkEventStatus(eventId)
                if targetEventId and status then
                    if status == FuncTower.COLLECTION_EVENT_STATUS.TODO then
                        return targetEventId,status
                    end
                end
            end
        end
    end
    -- 搜刮结束
    local status = FuncTower.COLLECTION_EVENT_STATUS.TODO 
    if table.length(events) > 0 then
        for eventId,eventData in pairs(events) do
            local targetEventId,status = self:checkEventStatus(eventId)
            if targetEventId and status then
                if status == FuncTower.COLLECTION_EVENT_STATUS.TODO then
                    return targetEventId,status
                end
            end
        end
    else
        return nil
    end
end

-- 检查事件的完成状态
-- 已处理 未处理
-- 返回curEventId,status 占卜事件处理后有奖励,返回相应的配表索引 rewardIndex
function TowerMainModel:checkEventStatus( curEventId )
    local status
    if not curEventId then
        return 
    end
    local eventConfigData = FuncTower.getCollectionEventDataByID(curEventId)
    if not eventConfigData then
        return 
    end
    local eventType = eventConfigData.type
    local eventData = self:getCollectionDataById( curEventId )
    if not eventData then
        status = FuncTower.COLLECTION_EVENT_STATUS.DONE
        return curEventId,status
    end

    -- dump(eventData, "一个事件的数据")
    if tostring(eventType) == tostring(FuncTower.COLLECTION_EVENT_TYPE.MERCHANT) then
        -- echo("______ 商人事件 _____________")
        if eventData.count>0 then
            status = FuncTower.COLLECTION_EVENT_STATUS.DONE
        else
            status = FuncTower.COLLECTION_EVENT_STATUS.TODO
        end
    elseif tostring(eventType) == tostring(FuncTower.COLLECTION_EVENT_TYPE.SOOTHSAYER) then
        -- echo("______ 占卜事件 _____________")
        if eventData.count>0 then
            if not eventData.type then
                status = FuncTower.COLLECTION_EVENT_STATUS.DONE
            else
                -- 有奖励未领取
                status = FuncTower.COLLECTION_EVENT_STATUS.TODO
                local rewardIndex = eventData.type
                return curEventId,status,rewardIndex
            end
        else
            status = FuncTower.COLLECTION_EVENT_STATUS.TODO
        end
    elseif tostring(eventType) == tostring(FuncTower.COLLECTION_EVENT_TYPE.FISHING) then
        -- echo("______ 钓鱼事件 _____________")
        if eventData.count>0 then
            status = FuncTower.COLLECTION_EVENT_STATUS.DONE
        else
            status = FuncTower.COLLECTION_EVENT_STATUS.TODO
        end
    elseif tostring(eventType) == tostring(FuncTower.COLLECTION_EVENT_TYPE.GUESS) then
        -- echo("______ 猜人事件 _____________")
        if eventData.count>0 then
            -- 有奖励未领取
            if eventData.type then
                status = FuncTower.COLLECTION_EVENT_STATUS.DONE
            else
                status = FuncTower.COLLECTION_EVENT_STATUS.TODO
            end
        else
            status = FuncTower.COLLECTION_EVENT_STATUS.TODO
        end
    end
    return curEventId,status
end

-- 获取事件数据
function TowerMainModel:getCollectionDataById( eventId )
    local events = TowerMainModel:towerCollection().events
    for k,v in pairs(events) do
        if k == eventId then
            return v
        end
    end
end

-- 获取事件处理次数
function TowerMainModel:getHandleTimes( eventId )
    local events = TowerMainModel:towerCollection().events
    for k,v in pairs(events) do
        if k == eventId then
            return v.count
        end
    end
end

-- 获取搜刮剩余次数
function TowerMainModel:getCollectionTimes()
    if not self.configCollectionTime then
        self.configCollectionTime = FuncDataSetting.getDataByConstantName("TowerCollectionNum") or 3
    end
    local hasUsedTimes = self:towerExt().collectionTimes
    return self.configCollectionTime - hasUsedTimes
end

-- 搜刮红点
-- 传入是否要返回值决定 是返回值还是发消息
function TowerMainModel:checkCollectionBtnRedPoint(isNeedReturnValue)
    if self:isInNewGuide() then
        return false
    end
    -- echoError("_______谁在叫我!!!_________")
    local isShowRed = self.isShowRed or false
    local collectionFloor = self:getCollectionFloor()
    if collectionFloor < 1 then
        self.isShowRed = false
        return false
    end
    local collectStatus = self:getCollectionStatus()
    if collectStatus == FuncTower.COLLECTION_STATUS.TODO then
        local leftTimes = self:getCollectionTimes()
        if leftTimes > 0 then
            isShowRed = true
        else
            isShowRed = false
        end
    elseif collectStatus == FuncTower.COLLECTION_STATUS.DONE then
        local toHandleReward = self:getHasFinishReward()
        if toHandleReward and table.length(toHandleReward)>0 then
            isShowRed = true
        else
            isShowRed = false
        end
    elseif collectStatus == FuncTower.COLLECTION_STATUS.COLLECTING then
        local toHandleEvent = self:getFoundCollectingEvent()
        if toHandleEvent and table.length(toHandleEvent)>0 then
            isShowRed = false
            for eventId,v in pairs(toHandleEvent) do
                local _,status = self:checkEventStatus(tostring(eventId))
                if status == FuncTower.COLLECTION_EVENT_STATUS.TODO then
                    isShowRed = true
                    break
                end
            end
        else
            isShowRed = false
        end
    end
    -- echo("_________ 判断红点是否变化 self.isShowRed,isShowRed  _____________",self.isShowRed,isShowRed)
    -- if self.isShowRed ~= isShowRed then
    if not isNeedReturnValue then
        self.isShowRed = isShowRed
        -- echo("_________ 发出搜刮红点变化消息 isShowRed_______________",isShowRed)
        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_TOWER_COLLECTION_REDPOINT_CHANGED,{isShow=self.isShowRed})  -- 搜刮红点变更
        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_TOWER_COLLECTION_REDPOINT_CHANGED,{isShow=self.isShowRed})  -- 搜刮红点变更
    else
        return self.isShowRed
    end
end

-- 获取搜刮状态:准备搜刮, 搜刮中, 搜刮完成
function TowerMainModel:getCollectionStatus()
    local status = FuncTower.COLLECTION_STATUS.TODO
    local rewardData = {}
    if not self:towerCollection().finishTime then
        status = FuncTower.COLLECTION_STATUS.TODO
    else
        if self:towerCollection().finishTime >= TimeControler:getServerTime() then
            status = FuncTower.COLLECTION_STATUS.COLLECTING
        else    
            if ( self:towerCollection().reward and table.length(self:towerCollection().reward)>0 )
                or ( self:towerCollection().events and table.length(self:towerCollection().events)>0 ) then
                status = FuncTower.COLLECTION_STATUS.DONE
                rewardData = self:towerCollection().reward
            else 
                status = FuncTower.COLLECTION_STATUS.TODO
            end
        end
    end
    return status,rewardData
end

-- 获取当前搜刮进度 
-- 准备搜刮则搜刮进度为0
-- 搜刮中则实时变化
-- 搜刮完成则搜刮进度为100%
function TowerMainModel:getCurStatusAndProgress()
    if not self.collectionNeedTime then
        local collectionConfigData = FuncTower.getCollectionDataByID(self:getCollectionFloor())
        self.collectionNeedTime = collectionConfigData.time
    end
    local status = self:getCollectionStatus()
    local curProgress = 0
    if status == FuncTower.COLLECTION_STATUS.TODO then
        curProgress = 0
    elseif status == FuncTower.COLLECTION_STATUS.DONE then
        curProgress = 100
    elseif status == FuncTower.COLLECTION_STATUS.COLLECTING then
        curProgress = (TimeControler:getServerTime() - (self:towerCollection().finishTime - self.collectionNeedTime))/self.collectionNeedTime
        curProgress = curProgress * 100
        if curProgress > 100 then
            curProgress = 100
        elseif curProgress < 0 then
            curProgress = 0 
        end
    end
    return status,curProgress
end






-- ===========================================================================
-- 以下函数用于奖励列表
-- ===========================================================================
-- 获取一层首次通关的奖励
function TowerMainModel:getPassOneFloorReward( floorId )
    return FuncTower.getFloorReward(floorId)
end

-- 获取完美通关一层的奖励
function TowerMainModel:getPerfectOneFloorReward( floorId )
    local rewardId = FuncTower.getPerfectPassReward(floorId)
    local rewardData = FuncItem.getRewardData(rewardId)
    if rewardData and rewardData.info then
        return rewardData.info 
    else
        echoError("完美通关奖励配置错误,层,奖励id",floorId,rewardId)
    end
end

-- 获取一层一次性宝箱
function TowerMainModel:getOneFloorOneOffBoxes( floorId )
    -- local oneOffArr = {}
    -- local recycleArr = {}
    -- local data = TowerMapModel:getTowerMapData(floorId)
    -- for k,v in pairs(data) do
    --     for kk,vv in pairs(v) do
    --         if vv.info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.BOX then
    --             local boxId = nil
    --             local gridInfo = vv.info
    --             local isPoZhen = false  -- 标记是不是破阵所得的宝箱 破阵所得的宝箱不展示在奖励列表界面
    --             if gridInfo.ext ~= nil and gridInfo.ext.boxId then
    --                 boxId= gridInfo.ext.boxId
    --                 isPoZhen = true
    --             else    
    --                 boxId= gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
    --                 isPoZhen = false
    --             end
    --             if not isPoZhen then
    --                 local boxData = FuncTower.getBoxData(boxId)
    --                 if boxData and boxData.isOneOff then
    --                     oneOffArr[#oneOffArr + 1] = boxId
    --                 elseif boxData then
    --                     recycleArr[#recycleArr + 1] = boxId
    --                 end
    --             end
    --         end
    --     end
    -- end
    -- dump(oneOffArr, "oneOffArr")
    -- dump(recycleArr, "recycleArr")


    local oneOffArr = {}
    local recycleArr = {}
    local groupArr = {}
    local mapName = TowerMainModel:getCurInUseMapName()
    local data = FuncTowerMap.getTowerMapDataByMapName(mapName)
    for k,v in pairs(data) do
        for kk,vv in pairs(v) do
            if vv.info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.BOX then
                local boxId = vv.info[FuncTowerMap.GRID_BIT.TYPE_ID]
                local boxData = FuncTower.getBoxData(boxId)
                if boxData and boxData.isOneOff then
                    oneOffArr[#oneOffArr + 1] = boxId
                elseif boxData then
                    recycleArr[#recycleArr + 1] = boxId
                end
            elseif vv.info[FuncTowerMap.GRID_BIT.RAND_ID] and vv.info[FuncTowerMap.GRID_BIT.RAND_ID] ~= "0" then
                local groupId = vv.info[FuncTowerMap.GRID_BIT.RAND_ID]
                if not table.isValueIn(groupArr,groupId) then
                    table.insert(groupArr, groupId)
                end
            end
        end
    end
    dump(groupArr, "getOneFloorOneOffBoxes ===== groupArr", nesting)
    -- 随机部分包含的格子数据
    for k,groupId in pairs(groupArr) do
        local groupData = FuncTower.getCellDataByRandomId( groupId )
        dump(groupData, "groupData", nesting)
        for index,configCellStr in pairs(groupData) do
            local configCellData = string.split(configCellStr,",")
            if configCellData[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.BOX then
                local boxId = configCellData[FuncTowerMap.GRID_BIT.TYPE_ID]
                local boxData = FuncTower.getBoxData(boxId)
                if boxData and boxData.isOneOff then
                    oneOffArr[#oneOffArr + 1] = boxId
                elseif boxData then
                    recycleArr[#recycleArr + 1] = boxId
                end
            end
        end
    end
    dump(oneOffArr, "oneOffArr")
    dump(recycleArr, "recycleArr")
    return oneOffArr,recycleArr
end

-- 获取一层的所有星级怪和非星级怪
function TowerMainModel:getOneFloorAllStarMonsters( floorId )
    -- local starArr = {}
    -- local wildArr = {}
    -- local data = TowerMapModel:getTowerMapData(floorId)
    -- for k,v in pairs(data) do
    --     for kk,vv in pairs(v) do
    --         if vv.info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.MONSTER then
    --             local monsterData = FuncTower.getMonsterData(vv.info[FuncTowerMap.GRID_BIT.TYPE_ID])
    --             if monsterData and monsterData.star == FuncTowerMap.MONSTER_STAR_TYPE.STAR then
    --                 starArr[#starArr + 1] = vv.info[FuncTowerMap.GRID_BIT.TYPE_ID]
    --             else
    --                 wildArr[#wildArr + 1] = vv.info[FuncTowerMap.GRID_BIT.TYPE_ID]
    --             end
    --         end
    --     end
    -- end
    -- dump(starArr, "starArr")
    -- dump(wildArr, "wildArr")

    local starArr = {}
    local wildArr = {}
    local groupArr = {}
    local mapName = TowerMainModel:getCurInUseMapName()
    local data = FuncTowerMap.getTowerMapDataByMapName(mapName)
    for k,v in pairs(data) do
        for kk,vv in pairs(v) do
            if vv.info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.MONSTER then
                local monsterId = vv.info[FuncTowerMap.GRID_BIT.TYPE_ID]
                local monsterData = FuncTower.getMonsterData(monsterId)
                if monsterData and monsterData.star == FuncTowerMap.MONSTER_STAR_TYPE.STAR then
                    starArr[#starArr + 1] = monsterId
                else
                    wildArr[#wildArr + 1] = monsterId
                end
            elseif vv.info[FuncTowerMap.GRID_BIT.RAND_ID] and vv.info[FuncTowerMap.GRID_BIT.RAND_ID] ~= "0" then
                local groupId = vv.info[FuncTowerMap.GRID_BIT.RAND_ID]
                if not table.isValueIn(groupArr,groupId) then
                    table.insert(groupArr, groupId)
                end
            end
        end
    end
    dump(groupArr, "getOneFloorAllStarMonsters ===== groupArr", nesting)

    -- 随机部分包含的格子数据
    for k,groupId in pairs(groupArr) do
        local groupData = FuncTower.getCellDataByRandomId( groupId )
        dump(groupData, "groupData", nesting)
        for index,configCellStr in pairs(groupData) do
            local configCellData = string.split(configCellStr,",")
            if configCellData[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.MONSTER then
                local monsterId = configCellData[FuncTowerMap.GRID_BIT.TYPE_ID]
                local monsterData = FuncTower.getMonsterData(monsterId)
                if monsterData and monsterData.star == FuncTowerMap.MONSTER_STAR_TYPE.STAR then
                    starArr[#starArr + 1] = monsterId
                else
                    wildArr[#wildArr + 1] = monsterId
                end
            end
        end
    end
    dump(starArr, "starArr")
    dump(wildArr, "wildArr")

    return starArr,wildArr
end

-- 判断一次性宝箱是否已领取
-- 注意服务端将所有已经领取的宝箱id都存在了
-- notPerfectFloorInfos下对应层的box字段
function TowerMainModel:isOneOffBoxAndHaveGot( boxId )
    -- 判断是否为一次性宝箱
    local isOneOff = true
    local boxData = FuncTower.getBoxData(boxId) 
    if (not boxData) or (not boxData.isOneOff) or (boxData.isOneOff < 1) then
        isOneOff = false
    end
    -- 判断是否已经领取
    local curFloor = self:towerExt().currentFloor
    local hasGot = false
    local NotPerfectFloors = self:towerExt().notPerfectFloorInfos
    if NotPerfectFloors and table.length(NotPerfectFloors)>0 then
        for k,v in pairs(NotPerfectFloors) do
            if tostring(curFloor) == k then
                if v.boxs and table.length(v.boxs)>0 then
                    for kk,vv in pairs(v.boxs) do
                        if tostring(boxId) == kk then
                            hasGot = true
                            break
                        end
                    end
                end
            end
        end
    end
    return isOneOff,hasGot
end

-- 判断一个怪是否曾经被杀过
-- 用于判断首次击杀奖励有没有领取
function TowerMainModel:isOneOffMonsterRewardHaveGot( monsterId )
    -- 判断是否已经领取
    local curFloor = self:towerExt().currentFloor
    local NotPerfectFloors = self:towerExt().notPerfectFloorInfos
    local hasGot = false
    if NotPerfectFloors and table.length(NotPerfectFloors)>0 then
        for k,v in pairs(NotPerfectFloors) do
            if tostring(curFloor) == k then
                if v.monsters and table.length(v.monsters)>0 then
                    for kk,vv in pairs(v.monsters) do
                        if tostring(monsterId) == kk then
                            hasGot = vv -- 返回历史上击杀的最大星星数量,1,2,3
                            break
                        end
                    end
                end
            end
        end
    end
    return hasGot
end

-- ===========================================================================
-- 以下函数用于怒气回升
-- ===========================================================================
-- 获取当前怒气
-- 若超过配置的最大怒气值 则返回最大怒气值
-- 暂时为10 
function TowerMainModel:getCurEnergy()
    local curNum = self:towerExt().energy
    local maxNum = self:getMaxEnergy()
    if curNum > maxNum then
        curNum = maxNum
    end
    return curNum
end

-- 获取怒气上限
-- 注意购买怒气上限加1 之后上限值会增加
function TowerMainModel:getMaxEnergy()
    local max = FuncTower.maxEnergy
    local buffs = self:getCurrentBuffs()
    if buffs and table.length(buffs)>0 then
        for k,v in pairs(buffs) do
            local buffData = FuncTower.getShopBuffData(k)
            if buffData.magicUp then
                max = max + buffData.magicUp*tonumber(v)
            end
        end
    end
    return max
end

-- 判断某个怪是否被击杀
-- 用于判断掉血时是否弹出掉血tips
function TowerMainModel:checkIsMonsterKilled( monsterId )
    local kills = TowerMainModel:getKillMonsters()
    if kills and table.length(kills) then
        for k,v in pairs(kills) do
            if k == tostring(monsterId) then
                return true
            end
        end
    end
    return false
end

-- ===========================================================================
-- 以下函数用于阶段解锁
-- ===========================================================================
-- 判断能否进入锁妖塔某层
-- 返回是否被锁,是否是最后一层
function TowerMainModel:checkIsCanEnterFloor( curFloorId )
    local isLock,level,isJump = false,1,false
    local togoFloor = tonumber(curFloorId)
    local maxFloor = FuncTower.getMaxFloor()
    if togoFloor > maxFloor then
        togoFloor = maxFloor 
    end

    local togoFloorData = FuncTower.getOneFloorData(togoFloor)
    -- dump(togoFloorData, "将要通往层的配置数据")
    if togoFloorData and togoFloorData.levelLimit then
        -- echo("_____ UserModel:level(),togoFloorData.levelLimit __________",UserModel:level(),togoFloorData.levelLimit)
        level = togoFloorData.levelLimit
        if UserModel:level() < togoFloorData.levelLimit then
            isLock = true
        else
            isLock = false
        end
    end

    local currentFloor = self:getCurrentFloor()
    if (togoFloor - currentFloor) > 1 then
        isLock = false
        isJump = true
    end

    -- echo("_____ isLock,level ________",isLock,level)
    return isLock,level,isJump
end

-- 判断传入层所在阶段和下一层所在阶段是否不同
-- 是否达到下一阶段
-- 注意这根据历史判断 历史上达到过则也算达到
function TowerMainModel:checkIsArriveNextStage(_currentFloor)
    local currentFloor = _currentFloor or self:getCurrentFloor()
    local nextfloor = currentFloor + 1
    local historyRearchMaxFloor = self:getMaxClearFloor()
    -- 注意正常情况下 都是通过传送门进入下一层 当前层才会被设为clearFloor
    -- 但是若当前层是顶层 则没有下一层可以进 所以当前层可以通过完美通关来达到clearFloor
    local notperfectfloor = self:towerExt().notPerfectFloors
    if notperfectfloor and table.length(notperfectfloor)>0 then
        for k,v in pairs(notperfectfloor) do
            if historyRearchMaxFloor == k then
                historyRearchMaxFloor = historyRearchMaxFloor + 1
            end
        end
    end

    local maxFloor = self:getMaxFloor()
    if nextfloor > maxFloor then
        nextfloor = maxFloor
    end
    if historyRearchMaxFloor > maxFloor then
        historyRearchMaxFloor = maxFloor
    end

    local curFloorData = FuncTower.getOneFloorData( currentFloor )
    local nextFloorData = FuncTower.getOneFloorData( nextfloor )
    local historyMaxFloorData = FuncTower.getOneFloorData( historyRearchMaxFloor )
    local currentStage,nextStage,maxRearchStage = 1,1,1
    if curFloorData then
        currentStage = curFloorData.stage
    end
    if nextFloorData then
        nextStage = nextFloorData.stage
    end
    if historyMaxFloorData then
        maxRearchStage = historyMaxFloorData.stage
    end

    if (tonumber(currentStage) < tonumber(nextStage)) and (tonumber(maxRearchStage) < tonumber(nextStage)) then
        return true
    end
end





-- ===========================================================================
-- 以下函数用于记录本地数据
-- ===========================================================================
-- 记录和检查某层的奖励列表界面是否弹出过
-- 一次重置周期内 每一层只会弹一次
function TowerMainModel:checkHasBeenPopupRewardPreview(curFloor)
    local has = LS:prv():get("StorageCode.tower_recordHasAutoOpenPreview"..UserModel:rid()..curFloor,nil)
    return has
end
function TowerMainModel:recordHasAutoOpenPreview( curFloor,value )
    LS:prv():set("StorageCode.tower_recordHasAutoOpenPreview"..UserModel:rid()..curFloor,value)
end


-- 记录搜刮事件--钓鱼的尝试次数
-- 每次搜刮出钓鱼事件 都只能尝试三次
function TowerMainModel:checkFishingTimes()
    local has = LS:prv():get("StorageCode.tower_recordFishingTimes",0)
    return tonumber(has)
end
function TowerMainModel:recordFishingTimes(fishingTimes)
    LS:prv():set("StorageCode.tower_recordFishingTimes",fishingTimes)
end


-- 记录是否已经查看过主界面已解锁的宝箱
-- 主界面左侧的通关解锁商品 解锁后点击出来看一次 则不再弹伸缩动画
function TowerMainModel:recordHasCheckTowerShopGoods(floor,hasCheck)
    LS:prv():set("StorageCode.tower_recordHasCheckTowerShopGoods"..UserModel:rid()..floor,hasCheck)
end
function TowerMainModel:getHasCheckTowerShopGoods(floor)
    local has = LS:prv():get("StorageCode.tower_recordHasCheckTowerShopGoods"..UserModel:rid()..floor,false)
    return has
end



-- 判断某层是否完美通关
-- 用于内部 (即进入了锁妖塔才能用此方法)
-- 现在用于奖励列表判断某层完美通关奖励是否已经领取
function TowerMainModel:checkIsPerfectPassOneFloor( floorId )
    local isPerfect = false
    if not floorId then
        return isPerfect
    end
    local maxHistoryFloor = self:towerExt().maxClearFloor or 0
    local serialPerfectMaxFloor = self:towerExt().maxPerfectFloor or 0
    if tonumber(floorId) <= tonumber(serialPerfectMaxFloor) then
        isPerfect = true
    else
        local notPerfects = self:towerExt().notPerfectFloors or {}
        if table.isKeyIn(notPerfects,tostring(floorId)) then
            isPerfect = false
        else
            -- notPerfectFloors 出现跨层才记录未完美层,否则没记录
            local kuaceng = tonumber(maxHistoryFloor) - tonumber(serialPerfectMaxFloor)
            if kuaceng > 1 then
                isPerfect = true
            else
                isPerfect = false
            end
        end
    end
    return isPerfect
end

-- 判断某层是否通关
-- 锁妖塔外使用
function TowerMainModel:checkIsPerfectPass( floorId )
    local isPerfect = false
    if not floorId then
        return isPerfect
    end

    local maxFloor = self:towerExt().maxClearFloor
    if not maxFloor then
        maxFloor = UserModel:towerExt().maxClearFloor or 0
    end
    if tonumber(floorId) <= tonumber(maxFloor) then
        isPerfect = true
    else
        isPerfect = false
    end
    return isPerfect
end

-- 是否处于新手引导期间
function TowerMainModel:isInNewGuide()
    return TutorialManager.getInstance():isInTutorial()
end


return TowerMainModel
