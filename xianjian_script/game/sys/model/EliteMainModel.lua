--
--Author:      zhuguangyuan
--DateTime:    2018-02-01 15:34:42
--Description: 精英副本 主数据类
--

local EliteMainModel = class("EliteMainModel",BaseModel)

function EliteMainModel:init(data)
    EliteMainModel.super.init(self,data)
    -- 总体数据
    self.eliteMainData = {}

    self._datakeys = {
		towerExt = {},
		towerFloor = {},
	}
	self:createKeyFunc()

	-- 进战斗保存临时数据
    self.tempMonster = {}


	self:initData()
	self:registerEvent()

    local tempPerfect = self:getPerfectTime() or 0
    self:setPerfectTime(tempPerfect)

    self.DEBUG  = false
end

function EliteMainModel:initData(data)
    -- 同时拥有道具最大数量
    self.maxOwnItemNum = 3

    self._data.towerExt = {}
    self._data.towerFloor = {}

    -- TODO 每次需求变更，都需要跟后端核对不同结构数据的更新方式
    -- towerFloor 下需要合并的数据
    self.towerFloorMergeKeyArr = {"cells","enemyInfo"}
    -- 重置锁妖塔操作时，不能重置的数据
    self.notResetKeyArr = {"floorRewards"} 
end

function EliteMainModel:registerEvent()
end

-- 获取战斗新增的星星数量
function EliteMainModel:getBattleAddStar()
    local changeStar = 0
    local battleUpdateData = self.battleUpdateData
    if not battleUpdateData then
        return changeStar
    end

    local oldStar = EliteMainModel:towerExt().star or 0
    local newStar = battleUpdateData.towerExt.star or 0

    changeStar = tonumber(newStar) - tonumber(oldStar)
    return changeStar
end

-- 获取战斗杀死的怪id
function EliteMainModel:getKilledMonsterId()
    local battleUpdateData = self.battleUpdateData
    local monsterId = nil
    if not battleUpdateData then
        return monsterId
    end

    local oldKillMonsters = self:getKillMonsters()
    local newKillMonsters = battleUpdateData.towerFloor.killMonsters

    if newKillMonsters ~= nil then
        for k,v in pairs(newKillMonsters) do
            if oldKillMonsters[k] == nil then
                monsterId = k
                break
            end
        end
    end
    return monsterId
end

-- 战斗完毕恢复，做完各种动画逻辑后，需要更新战斗数据
function EliteMainModel:updateBattleResultData()
    echo("updateBattleResultData 更新战斗数据 ",self.battleUpdateData)
    if self.battleUpdateData then
        self:updateData(self.battleUpdateData)
        self.battleUpdateData = nil
    end
end

--更新数据
function EliteMainModel:updateData(data,isBattle)
    if isBattle then
        self.battleUpdateData = table.deepCopy(data)
        return
    end

    if self.DEBUG then
        echo("EliteMainModel 更新数据-data----------")
        dump(data)
    end
    
    EliteMapModel:updateCells(data)
    EventControler:dispatchEvent(EliteEvent.ELITE_GRID_DATA_UPDATE)
end

-- 重新加载锁妖塔数据
-- 重置/扫荡/重新锁妖塔都会重新加载数据，先清空本地数据再用服务器数据覆盖
function EliteMainModel:reLoadTowerData(serverData)
    self:resetData()
    EliteMapModel:clearMapData()
    self:updateData(serverData)
end

function EliteMainModel:resetData()
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


--获取人物当前所在章节
function EliteMainModel:getCurrentChapter()
	local cur = self.eliteMainData.curChapter
	if not cur then
		cur = 1
		self.eliteMainData.curChapter = 1
	end
    echo("______ 取当前章 cur____________",cur)
	return cur
end
--设置人物当前所在章节
function EliteMainModel:setCurrentChapter(_curChapter)
    echo("________ 存当前章 ",_curChapter)
	self.eliteMainData.curChapter = tonumber(_curChapter)
end

-- 随机题库中的题目
-- 不能重复
function EliteMainModel:randomQuestion()
    -- 获取未被使用过的题目
    if not self.allValidQuestion or table.length(self.allValidQuestion) < 1 then
        self.randomList = {}
        -- 注意这里的坑点 如果不是深度拷贝 下次循环进来的时候 取到的其实就是 self.allValidQuestion
        -- 因为不深度拷贝的话其实只是将指针给了 self.allValidQuestion
        self.allValidQuestion = table.deepCopy(FuncEliteMap:getAllConfigQuestions()) 
        -- 如果使用了部分题目则剔除,否则再用全部
        local haveBeenUsed = {}
        if table.length(haveBeenUsed) < table.length(self.allValidQuestion) then
            for k,v in pairs(self.allValidQuestion) do
                if table.isValueIn(haveBeenUsed,k) then
                    v = nil
                else
                    self.randomList[#self.randomList + 1] = k
                end
            end
        else
            for k,v in pairs(self.allValidQuestion) do
                self.randomList[#self.randomList + 1] = k
            end
        end
    end
    math.randomseed(os.time())
    local index = math.random(1,#self.randomList)
    local ques = table.deepCopy(self.allValidQuestion[self.randomList[index]])
    self.allValidQuestion[self.randomList[index]] = nil
    table.remove(self.randomList,index)
    return ques
end

-- 获取当前的题目
-- _isChange 是否重新随机题目
function EliteMainModel:getCurQuestion(boxId,_isChange)
    echo("boxId,_isChange=====",boxId,_isChange)
    dump(self.questionCacheList,"self.questionCacheList-------------")
    if not self.questionCacheList then
        self.questionCacheList = {}
    end

    local curQuestion = nil 
    if self.questionCacheList[boxId] then
        if (not _isChange) then
            curQuestion = self.questionCacheList[boxId]
            return curQuestion
        end
    end

    curQuestion = self:randomQuestion()
    curQuestion.answer = {}
    curQuestion.answer[1] = curQuestion.a1
    curQuestion.answer[2] = curQuestion.a2
    curQuestion.answer[3] = curQuestion.a3
    curQuestion.answer[4] = curQuestion.a4
    if not self.numOfAnswer then
        self.numOfAnswer = 4
    end

    curQuestion = self:randomQuestion()
    curQuestion.answer = {}
    curQuestion.answer[1] = curQuestion.a1
    curQuestion.answer[2] = curQuestion.a2
    curQuestion.answer[3] = curQuestion.a3
    curQuestion.answer[4] = curQuestion.a4
    if not self.numOfAnswer then
        self.numOfAnswer = 4
    end

    for i = self.numOfAnswer,1,-1 do
        math.randomseed(os.time())
        local index = math.random(1,i)
        -- echo("______index_i_______",index,i)
        if index == 1 and not curQuestion.correctAnswer then
            curQuestion.correctAnswer = i
        end
        local temp = curQuestion.answer[i]
        curQuestion.answer[i] = curQuestion.answer[index]
        curQuestion.answer[index] = temp
    end

    self.questionCacheList[boxId] = curQuestion

    return curQuestion
end

-- 检查是否能够进入下一章
function EliteMainModel:checkIfCangotoNextChapter( _storyId )
    local storyId = tostring(_storyId)
    -- 已经是最后一章
    if WorldModel:isLastChapter(storyId) then
        WindowControler:showTips(GameConfig.getLanguage("#tid_story_10106"))
        return
    end

    local nextStoryId = WorldModel:getNextStoryId(storyId)
    local storyFirstRaidId = FuncChapter.getRaidIdByStoryId(nextStoryId,1)
    local raidData = FuncChapter.getRaidDataByRaidId(storyFirstRaidId)
    local conditionArr = raidData.condition
    -- dump(conditionArr, "=== 下一章第一节的开启条件 conditionArr")

    -- 检查是否达到开启条件
    local isMainLineOK,isEliteOK = true,true
    -- local isEliteOK = true
    if not raidData.condition or table.length(raidData.condition)<=0 then
    else
        local len = table.length(raidData.condition)
        for i = len,1,-1 do
            local conditionData = raidData.condition[i]
            dump(conditionData, "conditionData")
        -- for k,conditionData in pairs(raidData.condition) do
            local needRaidId = conditionData.v
            local needStoryId = FuncChapter.getStoryIdByRaidId(needRaidId)
            local needChapter = FuncChapter.getChapterByStoryId(needStoryId)
            local needSection = FuncChapter.getSectionByRaidId(needRaidId)

            local curRaidId = nil
            if tonumber(conditionData.t) == UserModel.CONDITION_TYPE.STAGE then
                isMainLineOK = false
                curRaidId = UserExtModel:getMainStageId()
                local curStoryId = FuncChapter.getStoryIdByRaidId(curRaidId)
                local curChapter = FuncChapter.getChapterByStoryId(curStoryId)
                local curSection = FuncChapter.getSectionByRaidId(curRaidId)
                if tonumber(needChapter) < tonumber(curChapter) 
                    or (tonumber(needChapter) == tonumber(curChapter)
                        and tonumber(needSection) <= tonumber(curSection)) 
                then
                    isMainLineOK = true
                else
                    isMainLineOK = false
                    if isEliteOK then
                        WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid2134",needChapter,needSection))
                    end
                end
            elseif tonumber(conditionData.t) == UserModel.CONDITION_TYPE.ELITE then 
                isEliteOK = false
                curRaidId = UserExtModel:getEliteStageId()
                if tostring(curRaidId) == "0" then
                    isEliteOK = false
                    WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid2135",needChapter,needSection))
                else
                    local curStoryId = FuncChapter.getStoryIdByRaidId(curRaidId)
                    local curChapter = FuncChapter.getChapterByStoryId(curStoryId)
                    local curSection = FuncChapter.getSectionByRaidId(curRaidId)
                    if tonumber(needChapter) < tonumber(curChapter) 
                        or (tonumber(needChapter) == tonumber(curChapter)
                            and tonumber(needSection) <= tonumber(curSection)) 
                    then
                        isEliteOK = true
                    else
                        isEliteOK = false
                        WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid2135",needChapter,needSection))
                    end
                end
            end
        end
    end
    return isMainLineOK,isEliteOK
end

-- 更新底部宝箱进度条
-- _view 为宝箱所在的view
function EliteMainModel:updateBoxProgress( _storyId,_boxPanel,_view )
    local boxPanel = _boxPanel
    local curStoryId = _storyId
    local storyData = FuncChapter.getStoryDataByStoryId(curStoryId)
    local ownStar = WorldModel:getTotalStarNum(curStoryId)
    self.offsetX = 28

    for i=1,3 do
        -- 宝箱数量
        local needStarNum = storyData.bonusCon[i]
        local panelBox = boxPanel["panel_box"..i]
        -- local mcStar = panelBox.mc_1
        local panelRed = boxPanel['panel_red' .. i]
        if panelRed then
            panelRed:setVisible(false)
        end

        panelBox.txt_1:setString(needStarNum)
       
        -- 根据当前章、拥有星星数量、宝箱id及宝箱需要的开启星星数量 判断宝箱状态
        local boxIndex = i
        local boxStatus = WorldModel:getStarBoxStatus(curStoryId,ownStar,needStarNum,boxIndex)
        local progress11 = needStarNum/(storyData.section * 3) -- 每个关卡都是最多三星
        local progressSize = boxPanel.panel_jin.progress_huang:getContainerBox()
        local newPosX = (progressSize.width) * progress11
        panelBox:anchor(0.5,0.5)
        panelBox:setPositionX(newPosX+self.offsetX)

        panelRed:pos(panelBox:getPositionX()+28,panelBox:getPositionY())
        -- 默认点亮星星
        -- mcStar:showFrame(1)
        -- 不满足开宝箱条件
        if boxStatus == WorldModel.starBoxStatus.STATUS_NOT_ENOUGH then
            panelBox.mc_box:showFrame(1)  --宝箱不打开
            self:playStarBoxAnim(panelBox,false,_view) --不播放宝箱闪光动画
        -- 满足开宝箱条件
        elseif boxStatus == WorldModel.starBoxStatus.STATUS_ENOUGH then
            panelBox.mc_box:showFrame(1)  --宝箱不打开
            self:playStarBoxAnim(panelBox,true,_view)
            if panelRed then
                panelRed:setVisible(true)
            end
        --已开箱
        elseif boxStatus == WorldModel.starBoxStatus.STATUS_USED then
            panelBox.mc_box:showFrame(2)  --宝箱呈打开状
            self:playStarBoxAnim(panelBox,false,_view)
        end
        
        panelBox:setTouchSwallowEnabled(true)  
        panelBox:setTouchedFunc(c_func(self.openStarBoxes,self,boxIndex,needStarNum,curStoryId)) --开宝箱
    end
    -- 设置进度条
    local preogress = boxPanel.panel_jin.progress_huang
    local percent = ownStar / storyData.bonusCon[3] * 100

    preogress:setDirection(ProgressBar.l_r)
    preogress:setPercent(percent)

    if boxPanel.panel_jindu and boxPanel.panel_jindu.txt_1 then
        boxPanel.panel_jindu.txt_1:setString(ownStar .. "/" .. storyData.bonusCon[3])
    end
end

--播放宝箱闪光动画
function EliteMainModel:playStarBoxAnim(panelBox,isPlay,_view)  
-- isPlay,true表示播放动画；false表示不播放动画，如果ctn已经有动画，需要做换装的反动作，并删除动画
    local ctnBox = panelBox.ctn_xing1
    if isPlay then
        if ctnBox:getChildrenCount() == 0 then
            panelBox.mc_box:setVisible(false)
            local mcView = UIBaseDef:cloneOneView(panelBox.mc_box)
            local anim = _view:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",ctnBox, false, GameVars.emptyFunc)
            mcView.currentView:pos(-1,5)
            FuncArmature.changeBoneDisplay(anim,"node",mcView)
            anim:startPlay(true)
        end
    else
        if ctnBox:getChildrenCount() > 0 then
            panelBox.mc_box:setVisible(true)
            ctnBox:removeAllChildren()
        end
    end
end

-- 开宝箱
function EliteMainModel:openStarBoxes(index,needStarNum,curStoryId)  
    if EliteMainModel.isHandlingEvent then
        echo("_________ 正在处理事件 ___________")
        return 
    end
    local data = {}
    data.boxIndex = index
    data.needStarNum = needStarNum
    data.storyId = curStoryId
    data.ownStar = WorldModel:getTotalStarNum(curStoryId)

    -- 宝箱状态
    local boxStatus = WorldModel:getStarBoxStatus(curStoryId,data.ownStar,needStarNum,index)
    data.boxStatus = boxStatus

    -- 如果满足领取条件，直接领取宝箱
    if boxStatus == WorldModel.starBoxStatus.STATUS_ENOUGH then
        local openStarBoxCallBack = function(event)
            if event.result ~= nil then
                local rewardData = event.result.data.reward
                WindowControler:showWindow("RewardSmallBgView", rewardData);
                EventControler:dispatchEvent(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES)
            end
        end
        WorldServer:openStarBox(curStoryId,index,c_func(openStarBoxCallBack))
    else
        -- 如果不满足领取或已领取
        WindowControler:showWindow("WorldStarRewardView", data)  --展示评级奖励界面
    end
end


function EliteMainModel:setIsPerfect( isPerfect )
    echo("________ 设置精英通关是否 ____________",isPerfect)
    self.isPerfect = isPerfect
end

function EliteMainModel:getIsPerfect()
    local isPerfect = self.isPerfect
    echo("________ 获取获取 精英通关是否 ____________",isPerfect)
    return isPerfect
end













function EliteMainModel:getMaxOwnItemNum()
    return self.maxOwnItemNum
end

--获取人物历史最高楼层
function EliteMainModel:getMaxClearFloor()
    return self:towerExt().maxClearFloor
end

-- 获取最大层数
function EliteMainModel:getMaxFloor()
    return FuncTower.getMaxFloor()
end

--获取人物可扫荡的层数
function EliteMainModel:getPerfectFloor()
    return self:towerExt().maxPerfectFloor
end

--首通奖励数组
function EliteMainModel:getTowerFloorReward()
    return self:towerExt().floorRewards
end

--[[
    获取地图反转值
    0:正常地图
    1:Y轴反转地图
]]
function EliteMainModel:getTowerMapReveral()
    return self:towerExt().reversal
end

function EliteMainModel:getShopsBuff(_id)
    if self:towerFloor().shops then
        return self:towerFloor().shops[_id]
    else
        return nil
    end
end

function EliteMainModel:getAllShopsBuff()
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
function EliteMainModel:getNextFloorBuffList(_curTempFloor)
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
    dump(buffList, "________EliteMainModel中获得扫荡的某层 buffList _______")
    return shopIdList,buffList  
end


function EliteMainModel:getAllStar()
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
function EliteMainModel:hasPoisonBuff()
    local hasBuff = self:towerFloor().hasPoisonBuff
    if not hasBuff or tonumber(hasBuff) == 0 then
        return false
    else
        return true
    end
end

-- 获取buff id数组
function EliteMainModel:getCurrentBuffs()
    return self:towerExt().currentBuffs
end

-- 获取临时buff(其中的id为道具id)
function EliteMainModel:getCurrentBuffTemps()
    return self:towerExt().currentBuffTemps or {}
end

-- 获取buff属性数组
function EliteMainModel:getBuffAttrList()
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
function EliteMainModel:getBuffAttrByItemId(itemId)
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
function EliteMainModel:getBuffDesByItemId(itemId)
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
function EliteMainModel:getBuffTempsAttr()
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

function EliteMainModel:getTowerTeamFormation()
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

function EliteMainModel:checkEmployeeExist()
    if self:towerExt().employeeInfo and table.length(self:towerExt().employeeInfo) > 0 then
        return true
    end
    return false
end

-- 获取被劫持的法宝
function EliteMainModel:getBanTreasure()
    local banTreasures = {}

    if self:towerExt().banTreasures then
        banTreasures = self:towerExt().banTreasures
    end
    return banTreasures
end

function EliteMainModel:getBruiseTeamFormation(type,isHasHero,subType,sortType,existingData)
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
                if temp.HpPercent <= 0 then
                    table.insert(deadNpcs,temp)
                else    
                    table.insert(npcs,temp)
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

function EliteMainModel:hasNowRule(a,b)
    FuncTeamFormation.partnerSortRule(a, b)
end

--法阵专用的排序方法
function EliteMainModel:spellBreakerRule(a,b)
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

function EliteMainModel:getPlayerKey()
   local itemData = self:towerExt().goods
    if itemData ~= nil then
        for k,v in pairs(itemData) do
            if tostring(v) == "1001" then
                return true
            end
        end    
    end
    return false
end

function EliteMainModel:getItemNum()
    local itemData = self:towerExt().goods
    local itemNum = 0
    if itemData ~= nil then
        for k,v in pairs(itemData) do
            itemNum = itemNum +1
        end    
    end
    return itemNum
end

function EliteMainModel:saveMonterData(params)
    if not empty(self.tempMonster) then
        self.tempMonster ={}
    end
    self.tempMonster = params
end

function EliteMainModel:getLastBattleMonster()
    return self.tempMonster
end

function EliteMainModel:saveBattleResult(_result)
    echo("_______保存战斗结果___result_____",_result)
    if tonumber(_result) == tonumber(Fight.result_win) then
        self.isBattleWin = true
    else
        self.isBattleWin = false
    end
end

function EliteMainModel:checkBattleWin()
    return self.isBattleWin
end

-- 获取当前拥有的道具
function EliteMainModel:getGoods()
    local goods = self:towerExt().goods or {}
    return goods
end

-- 获取当前拥有的道具
function EliteMainModel:getGoodsSortArr()
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
function EliteMainModel:getGoodsNum()
    local goods = self:getGoods()
    return table.length(goods)
end

-- 获取杀死的怪列表
function EliteMainModel:getKillMonsters()
    local monsters = EliteMainModel:towerFloor().killMonsters
    return monsters or {}
end

-- 获取敌人信息数据
function EliteMainModel:getEnemyInfo()
    local enemyInfo = EliteMainModel:towerFloor().enemyInfo
    return EliteMainModel:towerFloor().enemyInfo or {}
end

-- 通过ID获取敌人信息数据
function EliteMainModel:getMonsterInfo(monsterId)
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

--重置状态
function EliteMainModel:getResetType()
    return self:towerExt().resetStatus
end
-- 获取拥有的星星数量
function EliteMainModel:getCurOwnStarNum()
    return self:towerExt().star
end

function EliteMainModel:getResetNum()
    local isShow = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TOWER)
    local isSweep = self:getResetType()
    if isShow then
       local todayNum = self:getTowerNum()
       return todayNum
    else
        return 0
    end   
end

function EliteMainModel:getTowerNum()
    local todayNum = FuncDataSetting.getTowerResetNum()
    local nowUseResetNum = CountModel:getTowerResetCount()
    local nowResetNum = tonumber(todayNum) - tonumber(nowUseResetNum)
    return nowResetNum
end

-- 判断当前是否还有该商店,有则返回true
-- 购买所有buff之后服务器会删除商店
function EliteMainModel:isNowHasShop(_id)
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
function EliteMainModel:getMonsterBuffDesByItemId(itemId)
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

function EliteMainModel:checkTeamIsHas(_id,allViewData)
    if allViewData then
        for k,v in pairs(allViewData) do
            if tonumber(_id) == tonumber(v) then
                return false
            end
        end
    end    
    return true
end

function EliteMainModel:checkMapShop()
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

function EliteMainModel:checkMainViewRed(event)

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

function EliteMainModel:setPerfectTime(Time)
   LS:prv():set(StorageCode.tower_clearance_time,Time)
end

function EliteMainModel:getPerfectTime()
    local tempNum = LS:prv():get(StorageCode.tower_clearance_time,0)
    return tempNum
end

function EliteMainModel:enterNextData(data)
    self.enterUpdateData = table.deepCopy(data)
end

function EliteMainModel:getNextData()
    return self.enterUpdateData
end

function EliteMainModel:saveGridAni(type)
    self.nowGridAni = type
end

function EliteMainModel:getGridAni()
    local tempType = false
    if self.nowGridAni then
        tempType = true
    end
    return tempType
end
      
-- 保存劫财劫色npc 劫的数据
function EliteMainModel:saveNPCRobberRobData( _params )
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
function EliteMainModel:getNPCRobberRobData()
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
-- function EliteMainModel:saveMercenaryId( _mercenaryId )
--     self.mercenaryId = _mercenaryId
--     LS:prv():set("___mercenaryId________",self.mercenaryId)
-- end
-- -- 获取已经有的雇佣兵 没有则返回nil
-- function EliteMainModel:gotMercenaryById()
--     local mercenaryId = LS:prv():get("___mercenaryId________")
--     echo(")___mercenaryId________",mercenaryId)
--     return mercenaryId
-- end

-- 获取临时五灵属性
function EliteMainModel:getTempWulingProperty()
    return self:towerFloor().soulBuffTemps
end
-- 获取已经领取的五灵属性
function EliteMainModel:getOwnWulingProperty()
    return self:towerExt().soulBuffs
end

-- 保存完美通关奖励 待完美通关动画播放的时候再展示
function EliteMainModel:savePerfactReward( _reward )
    self.perfactReward = _reward
end
function EliteMainModel:getPerfactReward()
    return self.perfactReward or {}
end

-- 保存打败抢劫者的奖励 待界面恢复的时候再展示
function EliteMainModel:saveBeatBadGuyData( _params )
    self.beatBadGuyData = _params
end
function EliteMainModel:getBeatBadGuyData()
    return self.beatBadGuyData
end


function EliteMainModel:saveCompesationData( _data )
    self.compesationData = _data
end

function EliteMainModel:getCompesationData()
    return self.compesationData
end

function EliteMainModel:getTotalStarNum(floor)
    local curFloorData = FuncTower.getOneFloorData(floor)
    -- 本层星总数量
    local starNum = curFloorData.starNum
    return starNum
end

-- 外部进入精英探索界面,传入要进入的章 
function EliteMainModel:enterEliteExploreScene(_curChapter)
    local curChapter = _curChapter
    if not curChapter then
        local raidId = WorldModel:getMaxUnLockEliteRaidId()
        local storyId = FuncChapter.getStoryIdByRaidId(raidId)
        curChapter = FuncChapter.getChapterByStoryId(storyId)
    end
    EliteMainModel:setCurrentChapter(curChapter) 
    echo("_________________curChapter ",curChapter)
    EliteMapModel:updateMapData(true)
    WindowControler:showWindow("EliteMapView")
end



-- 检查扫荡条件  -- 三星关卡才能扫荡
function EliteMainModel:isSweepConditionTrue(raidId,noShow)
    local raidScore = WorldModel:getBattleStarByRaidId( raidId )
    -- 特权是否开启
    local _type = FuncCommon.additionType.switch_super_sweep
    local hasTequan = FuncCommon.checkHasPrivilegeAdditionByType( _type )
    if raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        return true
    else
        if hasTequan and raidScore >= WorldModel.stageScore.SCORE_ONE_STAR then
            return true
        end
        if not noShow then
            local tipMsg = GameConfig.getLanguage("#tid2133")
            WindowControler:showTips(tipMsg)
        end
        return false
    end
end

-- 判断战斗后是否已经通关本章
function EliteMainModel:checkIsPerfect(currentStoryId,currentUnfoldRaidId)
    -- 判断是否有新章开启(自动选中下一个关卡)
    local newPassRaid = WorldModel:getEliteNewPassRaid()
    local maxStoryId = WorldModel:getUnLockMaxStoryId( FuncChapter.stageType.TYPE_STAGE_ELITE )
    if tonumber(maxStoryId) >= tonumber(currentStoryId) 
        and newPassRaid and WorldModel:isLastRaidId(newPassRaid) 
    then
        if tonumber(maxStoryId) > tonumber(currentStoryId) then
            currentStoryId = maxStoryId
            currentUnfoldRaidId = FuncChapter.getRaidIdByStoryId(maxStoryId,1)
            local function showTips() 
                WindowControler:showTips(GameConfig.getLanguage("#tid_elite_001"));
            end
            -- self:delayCall(c_func(showTips), 1)
            showTips()
        end
        local function forceOpenGrids()
            EventControler:dispatchEvent(EliteEvent.ELITE_AUTO_OPEN_LEFT_GRIDS)
        end
        -- self:delayCall(c_func(forceOpenGrids), 1)
        forceOpenGrids()
    else
        currentUnfoldRaidId = WorldModel:getUnLockMaxRaidIdByStoryId(currentStoryId)
    end
    return currentStoryId,currentUnfoldRaidId
end

return EliteMainModel
