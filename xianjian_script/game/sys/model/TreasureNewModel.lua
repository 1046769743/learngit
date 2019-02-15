--
--
--
local TreasureNewModel = class("TreasureNewModel", BaseModel);

TreasureNewModel.JINJIE_STAGE = {
    MAX_QUALITY = 1, -- 已经达到最高品
    CONDITION = 2, -- 条件不满足
    COST = 3, -- 消耗不满足
    UP_QUALITY = 4, -- 满足升品
}
    -- 临时数据
--    self.treasureInfos= {}
--    self.treasureInfos["503"] = {
--        id = "503",
--        quality = 2,
--        star = 2,
--        awaken = 0,
--    }
function TreasureNewModel:init(data)
    TreasureNewModel.super.init(self, data)
    self.treasureInfos = data or {}
    for i,v in pairs(self.treasureInfos) do
        if not v.starPoint then
            v.starPoint = 0
        end
    end
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
         {redPointType = HomeModel.REDPOINT.DOWNBTN.TREASURE, isShow = self:homeRedPointEvent()});
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.dispathRedPointEvent, self)
end
--红点显示
function TreasureNewModel:homeRedPointEvent()
    local allTreashues = TreasureNewModel:getAllTreasure()
    for i,v in pairs(allTreashues) do
        if TreasureNewModel:isShowRedTreasure(v) then
            return true
        end
    end

    return false
end

function TreasureNewModel:dispathRedPointEvent(event)
    for k,v in pairs(event.params) do
        local itemCfg = FuncItem.getItemData(k)
        if itemCfg.subType_display == ItemsModel.itemSubTypes_New.ITEM_SUBTYPE_201 then
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                    {redPointType = HomeModel.REDPOINT.DOWNBTN.TREASURE, isShow = self:homeRedPointEvent()})
            break
        end
    end
    -- WindowControler:globalDelayCall(c_func(function()
    --     EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
    --      {redPointType = HomeModel.REDPOINT.DOWNBTN.TREASURE, isShow = self:homeRedPointEvent()})
    -- end),0.05)
end

function TreasureNewModel:updateData(data)
    
    for i,v in pairs(data) do
        echo("法宝ID  ====== ",i)
        if self.treasureInfos[i] then -- 已经存在
            if v.quality then
                echo("法宝品质  ====== ",i)
                self.treasureInfos[i].quality = v.quality
                EventControler:dispatchEvent(TreasureNewEvent.UP_QUALITY_SUCCESS_EVENT)
            elseif v.star then
                echo("法宝星级  ====== ",i)
                self.treasureInfos[i].star = v.star
                EventControler:dispatchEvent(TreasureNewEvent.UP_STAR_SUCCESS_EVENT)
                
            elseif v.awaken then 
                echo("法宝觉醒  ====== ",i)
                self.treasureInfos[i].awaken = v.awaken
                EventControler:dispatchEvent(TreasureNewEvent.JUEXING_SUCCESS_EVENT)
            end
        else
            echo("新法宝================")
            self.treasureInfos[i] = v
            EventControler:dispatchEvent(TreasureNewEvent.COMBINE_SUCCESS_EVENT)
        end
    end
    TreasureNewModel.super.updateData(self, data)
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
         {redPointType = HomeModel.REDPOINT.DOWNBTN.TREASURE, isShow = self:homeRedPointEvent()});
    EventControler:dispatchEvent(TreasureNewEvent.TREASURE_CHANGED_EVENT)
end

-- 获取已拥有的法宝
function TreasureNewModel:getOwnTreasures()
    return self.treasureInfos
end

-- 所有法宝的全局养成战力   如果需要计算他人的法宝养成战力 需要传数据_treasureInfos
function TreasureNewModel:getAllTreasStarAbility(_treasureInfos)
    local ability = 0
    if not _treasureInfos then
        _treasureInfos = self.treasureInfos
    end
    for i,v in pairs(_treasureInfos) do
        ability = ability + FuncTreasureNew.getTreasureStarAbility(v)
    end
    return ability
end

function TreasureNewModel:getTreasureAbilityById(_treasureId)
    local ability = 0
    local treasureData = self.treasureInfos[tostring(_treasureId)]

    ability = FuncTreasureNew.getTreasureStarAbility(treasureData)
    return ability
end

-- 记录当前选中的法宝id
function TreasureNewModel:setSelectTreasureId( _id )
    self.selectTreasureId = _id
end
function TreasureNewModel:getSelectTreasureId(  )
    return self.selectTreasureId
end

-- 获取法宝数组
function TreasureNewModel:getAllTreasure()
    local treasures = {}
    local cfg = FuncTreasureNew.getTreasureData()
    for i,v in pairs(cfg) do
        table.insert(treasures,v.hid)
    end
    local sortFunc = function (a,b)
        -- 判断是否存在
        local dataA = TreasureNewModel:getTreasureData(a)
        local dataB = TreasureNewModel:getTreasureData(b)
        local dataCfgA = FuncTreasureNew.getTreasureDataById(a)
        local dataCfgB = FuncTreasureNew.getTreasureDataById(b)
        local isHaveA = dataA and 1 or 0
        local isHaveB = dataB and 1 or 0
        if isHaveA == isHaveB then -- 都存在
            if isHaveA == 1 then-- 都存在
                --判断品质
                if dataCfgA.aptitude > dataCfgB.aptitude then
                    return true
                elseif dataCfgA.aptitude < dataCfgB.aptitude then 
                    return false  
                end
                -- 判断星级
                if dataA.star > dataB.star then
                    return true
                elseif dataA.star < dataB.star then
                    return false
                end

                -- 判断战力
                local powerA = FuncTreasureNew.getTreasureAbility(dataA,1)
                local powerB = FuncTreasureNew.getTreasureAbility(dataB,1)
                if powerA > powerB then
                    return true
                elseif powerA < powerB then
                    return false
                end
                
                -- 根据ID判断
                if tonumber(a) > tonumber(b) then
                    return true
                elseif tonumber(a) < tonumber(b) then
                    return false

                end

                return false

            else-- 未拥有
                -- 判断资质
                if dataCfgA.aptitude > dataCfgB.aptitude then
                    return true
                elseif dataCfgA.aptitude < dataCfgB.aptitude then 
                    return false  
                end
                -- 判断星级 -- 按照策划说的 初始都为1  保险起见判断下
                if dataCfgA.initStar > dataCfgB.initStar then
                    return true
                elseif dataCfgA.initStar < dataCfgB.initStar then
                    return false
                end
                -- 判断战力
                local initDataA = FuncTreasureNew.getTreasureInitData(a)
                local initDataB= FuncTreasureNew.getTreasureInitData(b)
                local powerA = FuncTreasureNew.getTreasureAbility(initDataA,1)
                local powerB = FuncTreasureNew.getTreasureAbility(initDataB,1)
                if powerA > powerB then
                    return true
                elseif powerA < powerB then
                    return false
                end
                -- 根据ID判断
                if tonumber(a) > tonumber(b) then
                    return true
                elseif tonumber(a) < tonumber(b) then
                    return false
                end
                return false
            end
            
        elseif isHaveA > isHaveB then 
            return true
        elseif isHaveB > isHaveA then 
            return false
        end
    end
    table.sort(treasures,sortFunc)

    return treasures
end

-- 获得星级-技能解锁表
function TreasureNewModel:getStarSkillMap(treasureId)
    return FuncTreasureNew.getStarSkillMap(treasureId,UserModel:avatar())
end
-- 获得法宝信息
function TreasureNewModel:getTreasureData(treasureId)
    local data = self.treasureInfos[treasureId]
    return data
end

-- 判断是否有xx法宝
function TreasureNewModel:isHaveTreasure(treasureId)
    local data = self.treasureInfos[treasureId]
    if data then
        return true 
    else
        return false
    end
end

--  判断法宝是否解锁
--condition = {
--    key =  -- 类型 int 
--    value1 = -- 条件
--    value2 = -- 条件
--}

--1.主角等级达到XXX
--2.XX伙伴品质达到XXX（指定伙伴）
--3.拥有XXX个XXX品质伙伴
--4.XX法宝达到XX品质
--5.寻仙副本通过第XX关
--6.成就点数达到XXX
--7.XX法宝达到X星
--8.拥有XX个伙伴
function TreasureNewModel:isUnlock(condition)
    condition = string.split(condition,",") 
    local str = nil
    local getwayFunc = nil
    if tonumber(condition[1]) == 1 then  
        local userLever = UserModel:level()
        str = "需要主角等级达到"..condition[2].."级"
        getwayFunc = function ()
            WindowControler:showTips(str)
        end
        if userLever >= tonumber(condition[2]) then
            return true ,str
        else
            getwayFunc = function ()
                WindowControler:showWindow("WorldMainView")
            end
            return false ,str,getwayFunc
        end
    elseif tonumber(condition[1]) == 2 then
        local partnerData = PartnerModel:getPartnerDataById(condition[2])
        local name = GameConfig.getLanguage(FuncPartner.getPartnerById(condition[2]))
        str = name .."品质达到"..condition[3]
        getwayFunc = function ()
            local data = PartnerModel:getAllPartner()
            if data and table.length(data) > 0 then
                WindowControler:showWindow("PartnerView")
            else
                WindowControler:showTips( GameConfig.getLanguage("#tid1563"))
            end
        end
        if partnerData then
            if partnerData.quality >= tonumber(condition[3]) then
                return true,str
            else
                return false,str,getwayFunc
            end
        else
            return false,str,getwayFunc
        end
    elseif tonumber(condition[1]) == 3 then
        local num = PartnerModel:getEquipmentNumByMorethanquality(tonumber(condition[3])-1)
        str = "拥有"..condition[2].."个"..condition[3].."品质奇侠"
        getwayFunc = function ()
            local data = PartnerModel:getAllPartner()
            if data and table.length(data) > 0 then
                WindowControler:showWindow("PartnerView")
            else
                WindowControler:showTips( GameConfig.getLanguage("#tid1563"))
            end
        end
        if num >= tonumber(condition[2]) then
            return true,str
        else
            return false,str,getwayFunc
        end
    elseif tonumber(condition[1]) == 4 then
        -- 判断是否有xx法宝
        local data = TreasureNewModel:getTreasureData(condition[2])
        local name = FuncTreasureNew.getTreasureDataByKeyID(condition[2],"name")
        name =  GameConfig.getLanguage(name)
        str = name.."法宝达到"..condition[3].."品质"
        getwayFunc = function ()
            WindowControler:showTips(str)
        end
        if data then
            -- 判断品质是否满足
            if tonumber(condition[3]) <= data.quality then
                return true,str
            else
                return false,str,getwayFunc
            end
        else
            return false,str,getwayFunc
        end
    elseif tonumber(condition[1]) == 5 then --
        local passMaxRaidId = UserExtModel:getMainStageId()
        local raidId = condition[2]
        local raidData = FuncChapter.getRaidDataByRaidId(raidId)
        local raidName = WorldModel:getRaidName(raidId)
        local chapter = WorldModel:getChapterNum(FuncChapter.getChapterByStoryId(raidData.chapter))
        local section = WorldModel:getChapterNum(FuncChapter.getSectionByRaidId(raidId))
        str = "通关第" .. chapter .. "章第" .. section .. "节"
        getwayFunc = function ()
            WindowControler:showWindow("WorldMainView")
        end
        if tonumber(passMaxRaidId) >= tonumber(condition[2]) then
            return true,str,getwayFunc
        else
            return false,str,getwayFunc
        end

    elseif tonumber(condition[1]) == 6 then
        str = "成就点数达到"..condition[2]
        local haveNum = UserModel:getAchievementPoint();
        getwayFunc = function ()
            WindowControler:showWindow("QuestMainView")
        end
        echo("当前成就点 === ",haveNum)
        if haveNum >= tonumber(condition[2]) then
            return true ,str
        else
            return false ,str,getwayFunc
        end
        
    elseif tonumber(condition[1]) == 7 then
        -- 判断是否有xx法宝
        local data = TreasureNewModel:getTreasureData(condition[2])
        --7.XX法宝达到X星
        local name = FuncTreasureNew.getTreasureDataByKeyID(condition[2],"name")
        name = GameConfig.getLanguage(name)
        str = name.."达到"..condition[3].."星"
        getwayFunc = function ()
            WindowControler:showTips(str)
        end
        if data then
            -- 判断星级是否满足
            if tonumber(condition[3]) <= data.star then
                return true,str
            else
                return false,str,getwayFunc
            end
        else
            return false,str,getwayFunc
        end
    elseif tonumber(condition[1]) == 8 then
        local allPartners = PartnerModel:getAllPartner()
        --8.拥有XX个伙伴
        str = "拥有"..condition[2].."个奇侠"
        getwayFunc = function ()
            WindowControler:showWindow("PartnerView")
        end
        local haveNum = table.length(allPartners)
        if haveNum >= tonumber(condition[2]) then
            return true ,str
        else
            return false,str,getwayFunc
        end
    end
end
-- 判断是否可解锁法宝
function TreasureNewModel:isCanJiesuo( id )
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local conditionT = dataCfg.unlockCondition
    local canLock = true
    for i,v in pairs(conditionT) do
        local unlock = TreasureNewModel:isUnlock(v);
        if unlock == false then
            return false
        end
    end
    return true
end
-- 判断是否显示红点
function TreasureNewModel:isShowRedTreasure(id)
    -- 判断是否开启
    if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TREASURE_NEW) then
        return false  
    end
    -- 是否拥有
    local data = self.treasureInfos[id]
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    if data then
        -- 可升星
        if data.star >= dataCfg.maxStar then
            -- 此时最大星级
            return false
        end
        local starDataCfg = FuncTreasureNew.getTreasureUpstarDataById(id)
        starDataCfg = starDataCfg[tostring(data.star)]
        local haveNum = ItemsModel:getItemNumById(id)
        if data.starPoint < 5 then
            local needNum = starDataCfg.cost[data.starPoint + 1]
            if needNum and haveNum>=needNum then 
                return true
            end
        else
            -- 此时可升星
            return true
        end
       
    else
        -- 合成或解锁
        local dataCfg = FuncTreasureNew.getTreasureDataById(id)
        if dataCfg.unlockType == 1 then
            local conditionT = dataCfg.unlockCondition
            local canLock = true
            for i,v in pairs(conditionT) do
                local unlock = TreasureNewModel:isUnlock(v);
                if unlock == false then
                    return false
                end
            end
            return true
        elseif dataCfg.unlockType == 2 then
            local needNum = dataCfg.pieceNum
            local haveNum = ItemsModel:getItemNumById(id);
            if haveNum >= needNum then
                return true 
            end
        end
    end

    return false
end

-- 获取达到X资质的法宝
function TreasureNewModel:getEnoughAptitudeNum(_aptitude)
    local num = 0
    for i,v in pairs(self.treasureInfos) do
        local dataCfg = FuncTreasureNew.getTreasureDataById(v.id)
        if _aptitude <= dataCfg.aptitude then
            num = num + 1
        end
    end
    return num
end
-- 获取达到X星级的法宝
function TreasureNewModel:getEnoughStarNum(_star)
    local num = 0
    for i,v in pairs(self.treasureInfos) do
        if _star <= v.star then
            num = num + 1
        end
    end
    return num
end

return TreasureNewModel;





















