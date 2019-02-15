--
--Author:      zhuguangyuan
--DateTime:    2017-09-25 10:48:36
--Description: 新版情缘系统数据相关
-- 情缘指伙伴之间的情缘，在伙伴系统之上开发
-- 情缘用到伙伴里的loves、resonanceLv字段

-- local NewLoveModel = class("NewLoveModel", PartnerModel);
local NewLoveModel = class("NewLoveModel", BaseModel);

NewLoveModel.haveSentLoveLevelUpRequest = false
NewLoveModel.haveSentResonateLevelUpRequest = false

function NewLoveModel:init()
    -- 获得父类(PartnerModel)的数据
    NewLoveModel.super.init(self, {})

	self:updateHomeRedPoint()
    self:registerEvent()
    -- local show = self:isShowMainViewRed()

    -- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,{redPointType = HomeModel.REDPOINT.DOWNBTN.LOVE, isShow = show})
end

function NewLoveModel:updateData()
	
end

function NewLoveModel:registerEvent()
	-- 监听相关消息更新主城红点
    -- 情缘升级成功
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_LOVE_LEVEL_UP_GRADE, self.updateHomeRedPoint, self)
   	-- 伙伴共鸣升阶成功
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_PARTNER_RESONATE_ONE_STEP, self.updateHomeRedPoint, self)
    -- 点亮情缘 数据更新完毕
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_UPDATE_GLOBAL_PROPERTY_DATA, self.updateHomeRedPoint, self)
    -- 更新红点
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_UPDATE_RED,self.updateHomeRedPoint, self)
    -- 点亮寻缘服务器返回  更新数据
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_LIGHTEN_ONE_CELL, self.onOneCellLighten, self)
end





--------------------------------------------------------------------------
---------------------- 状态判断相关         ------------------------------
--------------------------------------------------------------------------
-- 判断某条情缘是否可以升级到指定等级
function NewLoveModel:isCanUpgradeLove(loveId,targetRank)
	-- 情缘相关副伙伴为未投放伙伴,可能未配条件,直接返回不可提升
	local vicePartnerId = FuncNewLove.getLoveVicePartnerIdByLoveId(loveId)
	local _data = FuncPartner.getPartnerById(vicePartnerId)
    local _isShow = _data.isShow
    if _isShow == 0 then
    	return false
    end

	local condition = FuncNewLove.getLovelevelUpCondition(loveId,targetRank)
	-- echo("_______ ,loveId,targetRank___________",loveId,targetRank)
	-- dump(condition,"升级条件")
	for k,v in ipairs(condition) do
		if not self:isFinishCondition(loveId,v) then
			return false
		end
	end
	return true
end

-- 判断某个小条件是否完成
function NewLoveModel:isFinishCondition(loveId,oneConditionData)
	-- echo("\n\n\n\n")
	local partnerId = oneConditionData.partner
	local mode = oneConditionData.mode
	local value = oneConditionData.value
	local conditionType = oneConditionData.type

	-- 伙伴id为占位符，2=情缘值要求档次 3=剧情任务
	-- if partnerId == "1" then
	-- 因需求废弃以上分支删除2018-07-24

	-- 还没拥有伙伴则情缘肯定不能升级
	local isHavePartner = PartnerModel:isHavedPatnner(partnerId)
	if (not isHavePartner) then
		return false
	end
	local partnerData = PartnerModel:getPartnerDataById(partnerId)
	-- 类型为1=伙伴养成类 
	if conditionType == 1 then
		-- mode = 1,2,3,4 == 等级，星级，品阶，拥有该伙伴
		if not partnerData then
			return false
		end
		if mode == 4 then
			return true
		elseif mode == 1 then
			return partnerData.level >= value and true or false
		elseif mode == 2 then
			return partnerData.star >= value and true or false
		elseif mode == 3 then
			return partnerData.quality >= value and true or false
		end
	end

	return false
end


-- 主奇侠的所有情缘线都完成升级
-- 主奇侠可与众奇侠产生一个等级的共鸣
function NewLoveModel:isCanResonate(mainPartnerId)
	local partnerData = PartnerModel:getPartnerDataById(mainPartnerId)
	if not partnerData then
		return false
	end
	if not partnerData.loves then
		return false
	end
	-- 遍历该奇侠的所有情缘，若等级都比共鸣等级高，则可以提升共鸣等级
	local partners = FuncNewLove.getVicePartnersListByPartnerId(mainPartnerId)
	local loveNum = 0
	for k,v in pairs(partnerData.loves) do
		if v.lv <= partnerData.resonanceLv then
			return false
		end
		loveNum = loveNum + 1
	end
	if loveNum < #partners then
		return false
	end 
	return true
end

--------------------------------------------------------------------------
---------------------- 红点显示相关           ----------------------------
--------------------------------------------------------------------------
-- 显示主城红点
function NewLoveModel:updateHomeRedPoint()
	local allThemes = FuncNewLove.getAllThemeData()
	local canShow = false
	for k,v in pairs(allThemes) do
		if self:isShowThemeRedPoint(k) then
			canShow = true
		end
	end

	-- echo("____________ 发送主城红点事件 ——————————————————————————————")
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        { redPointType = HomeModel.REDPOINT.DOWNBTN.LOVE, isShow = canShow })
end
-- 判断主界面是否显示主题红点
function NewLoveModel:isShowThemeRedPoint(themeId)
	local mainPartners = FuncNewLove.getPartnersByThemeId(themeId)
	-- dump(mainPartners,"红点显示--主奇侠数组")

	local canShow = false
	for k,v in ipairs(mainPartners) do
		canShow = self:isShowMainPartnerRedPoint(v)
		if canShow then 
			-- echo("就是这个伙计发的红点事件 --- ",v)
			return true 
		end
	end
	return canShow
end

-- 判断主界面是否显示主奇侠红点
function NewLoveModel:isShowMainPartnerRedPoint(mainPartnerId)
	if not PartnerModel:isHavedPatnner(mainPartnerId) then
		return false
	end
	local canShow1 = self:isShowResonanceRedPoint(mainPartnerId)
	if canShow1 then
		-- echo("就是这个伙计发的红点事件 --- 可以提升共鸣  ",mainPartnerId)
		return true
	end

	local vicePartners = FuncNewLove.getVicePartnersListByPartnerId(mainPartnerId)
	-- dump(vicePartners,"红点显示--副奇侠数组")
	------------------------------------------
	-- 配表不完全，先做下特殊处理
	if not vicePartners then
		return false
	end
	local canShow2 = false
	for k,v in ipairs(vicePartners) do
		canShow2 = self:isShowVicePartnerRedPoint(mainPartnerId,v)
		if canShow2 then
			-- echo("就是这个伙计发的红点事件 --- 副奇侠显示红点了  ",v)
			return true
		end
	end
	return canShow2
end

-- 判断主奇侠界面是否显示共鸣红点
function NewLoveModel:isShowResonanceRedPoint(mainPartnerId)
	local canShow = self:isCanResonate(mainPartnerId)
	if canShow then
		return true
	else
		return false
	end
end

-- 判断主奇侠界面是否显示副奇侠红点
function NewLoveModel:isShowVicePartnerRedPoint(mainPartnerId, vicePartnerId)
	local partnerData = PartnerModel:getPartnerDataById(mainPartnerId)
	local loveId =  FuncNewLove.getLoveIdByPartnerId(mainPartnerId, vicePartnerId)	
	-- if not partnerData.loves then
		local canShow = self:isShowLoveUpRedPoint(loveId)
		if canShow then
			return true
		else
			return false
		end
	-- end

	-- local curLove = partnerData.loves[tostring(loveId)]
	-- if not curLove then
	-- 	local canShow = self:isShowLoveUpRedPoint(loveId)
	-- 	if canShow then
	-- 		return true
	-- 	else
	-- 		return false
	-- 	end
	-- else
	-- 	local loveValue = curLove.value
	-- 	local lovelevel = curLove.lv
	-- 	if lovelevel < FuncNewLove.maxLevel and lovelevel > 0 then
	-- 		local targetLevel = lovelevel + 1
	-- 		local needLoveValue = FuncNewLove.getDispositionByLoveIdAndLevel(loveId, targetLevel)
	-- 		if tonumber(loveValue) < tonumber(needLoveValue) then
	-- 			return false
	-- 		else
	-- 			return true
	-- 		end		
	-- 	else
	-- 		return false
	-- 	end
	-- end	
end

-- 判断副奇侠界面是否显示情缘升阶红点
function NewLoveModel:isShowLoveUpRedPoint(loveId)
	local targetRank = self:getTargetRank( loveId )
	if targetRank == 6 then
		return false
	end
	local canShow = self:isCanUpgradeLove(loveId,targetRank)
	if canShow then
		return true
	else
		return false
	end
end

--------------------------------------------------------------------------
---------------------- 服务器相关           ------------------------------
--------------------------------------------------------------------------
-- 情缘升级
function NewLoveModel:loveLevelUp(loveId,targetLoveLevel,txtArr)
	local function levelUpCallBack( serverData )
		if not serverData.result then
			NewLoveModel.haveSentLoveLevelUpRequest = false
			return
		end
		EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT)
		local result = serverData.result
		-- dump(result,"情缘升级成功服务器返回数据 ====== ")
		local ability = result.data.dirtyList.u.abilityNew
		local partners = result.data.dirtyList.u.partners
		local mainPartnerId = FuncNewLove.getLoveMainPartnerIdByLoveId(loveId)
		local loveLevel = partners[tostring(mainPartnerId)].loves[tostring(loveId)].lv
		if loveLevel then
			-- EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_ONE_LOVE_LEVEL_UP_GRADE,
			-- 	{loveId = loveId,lv = loveLevel,txtArr = txtArr})
			WindowControler:showWindow("NewLovePromoteView",loveId,txtArr,loveLevel) 
		end
	end
	-- 显示任务完成与否的不同状态
    if targetLoveLevel <= FuncNewLove.maxLevel then
    	local isFinshAllCondition = true
    	local condition = FuncNewLove.getLovelevelUpCondition(loveId,targetLoveLevel)
    	if not condition then
    		return 
    	end
    	for k,v in ipairs(condition) do
    		if not NewLoveModel:isFinishCondition(loveId,v) then
    			isFinshAllCondition = false
    			echo("没达到要求喔伙计 回去吧！下次再来")
    			return
    		end
    	end
    	if targetLoveLevel then
    		targetLoveLevel = nil
    		NewLoveServer:loveLevelUp(loveId,c_func(levelUpCallBack))
    	end
    end
end

-- 共鸣升级
function NewLoveModel:loveResonanceUp(mainPartnerId,txtArr,vicePartnerId)
	local function ResonanceUpCallBack( serverData )
		if not serverData.result then
			NewLoveModel.haveSentResonateLevelUpRequest = false
			return
		end
		EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT)
		local result = serverData.result
		-- dump(result,"共鸣升级成功服务器返回数据 ====== ")
		local ability = result.data.dirtyList.u.abilityNew
		local partners = result.data.dirtyList.u.partners

		local resonateLevel = partners[tostring(mainPartnerId)].resonanceLv
		if resonateLevel then
			-- echo("__________ 共鸣升级成功 resonateLevel ___________",resonateLevel)
			dump(txtArr,"lplplplplplp =============== ")
			EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_ONE_PARTNER_RESONATE_ONE_STEP,
				{partnerId = mainPartnerId,level = resonateLevel,vicePartnerId = vicePartnerId})
			EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_PLAY_ANIMAtion_EVENT,
				{txtArr = txtArr})
		end
	end
 	if NewLoveModel:isCanResonate(mainPartnerId) then
		NewLoveServer:loveResonanceUp(mainPartnerId,c_func(ResonanceUpCallBack))
	end
end

-- -- 进入战斗
-- function NewLoveModel:loveLevelUp(loveId)
-- 	local function levelUpCallBack( serverData )
-- 		local result = serverData.result
-- 		dump(result,"情缘升级成功服务器返回数据 ====== ")
-- 	end
-- 	NewLoveServer:loveLevelUp(loveId,c_func(levelUpCallBack))
-- end

-- -- 上传战报
-- function NewLoveModel:loveLevelUp(loveId)
-- 	local function levelUpCallBack( serverData )
-- 		local result = serverData.result
-- 		dump(result,"情缘升级成功服务器返回数据 ====== ")
-- 	end
-- 	NewLoveServer:loveLevelUp(loveId,c_func(levelUpCallBack))
-- end

--------------------------------------------------------------------------
---------------------- 工具函数相关         ------------------------------
--------------------------------------------------------------------------
-- 根据情缘id 获取它的下一个目标等级
-- 如果为5阶 则下一阶为6阶
function NewLoveModel:getTargetRank( loveId )
	local currentRank = self:getLoveRank( loveId )
	return currentRank + 1

	-- if currentRank ~= 5 then
	-- 	return currentRank + 1
	-- else
	-- 	return currentRank
	-- end
end

-- 根据情缘id 获取它的等级
function NewLoveModel:getLoveRank( loveId )
	local mainPartnerId = FuncNewLove.getLoveMainPartnerIdByLoveId(loveId)
	if not PartnerModel:isHavedPatnner(mainPartnerId) then
		return 0
	end
	local partnerData = PartnerModel:getPartnerDataById(mainPartnerId)
	if partnerData and partnerData.loves then 
		local data = partnerData.loves[loveId]
		if data then
			return data.lv
		else
			return 0
		end
	else
		return 0
	end
end

-- 根据副奇侠获取相关数据
-- loveId,loveLevel,loveValue,condition
-- loveLevel初始为0,loveValue初始为0,condition为升阶到下一阶的条件
function NewLoveModel:getVicePartnerLoveData( mainPartnerId,vicePartnerId,mainPartnerLoves )
	local loveId = nil
	local loveLevel = nil
    local targetLoveLevel = nil
	local loveValue = nil
	local condition = nil
	local noLove = true
	if mainPartnerLoves then
		for k,v in pairs(mainPartnerLoves) do
			local vId = FuncNewLove.getLoveVicePartnerIdByLoveId(k)
			-- echo("______ k,vId,vicePartnerId _________",k,vId,vicePartnerId)
			if tostring(vId) == tostring(vicePartnerId) then 
				loveId = v.id 
				loveLevel = v.lv 
				loveValue = v.value
                if loveLevel < FuncNewLove.maxLevel then
                    targetLoveLevel = loveLevel + 1
                else
                    targetLoveLevel = loveLevel
                end

				condition = FuncNewLove.getLovelevelUpCondition(loveId,targetLoveLevel)
				noLove = false
				break
			end
		end
	end	
	if noLove then
		loveId = FuncNewLove.getLoveIdByPartnerId(mainPartnerId,vicePartnerId)
		loveLevel = 0   
		loveValue = 0
        if loveLevel < FuncNewLove.maxLevel then
            targetLoveLevel = loveLevel + 1
        else
            targetLoveLevel = loveLevel
        end
		condition = FuncNewLove.getLovelevelUpCondition(loveId,targetLoveLevel)
	end

	-- echo("__loveId,loveLevel,loveValue _____",loveId,loveLevel,loveValue)
	return loveId,loveLevel,loveValue,condition
end

-- 获得已经激活的情缘的数量
-- 注意a b 和 b a 之间是两条情缘
-- _level表示要求_level阶以上的情缘,不传则为0
function NewLoveModel:getActivateLoveNum( _level )
	local loveLevel = 0
	if not _level then
		loveLevel = 0 
	else
		loveLevel = _level - 1
	end
	if loveLevel<0 then
		loveLevel = 0 
	end
	local count = 0
	local allpartners = PartnerModel:getAllPartner()
	for k,v in pairs(allpartners) do
		if v.loves then
		  	for k,v in pairs(v.loves) do
		      	if v.lv > loveLevel then
		   		 	count = count + 1
		   		end
		  	end
		end
	end
  return count
end

--储存在本地的
function NewLoveModel:saveLoveChooseId(id)
	LS:prv():set(StorageCode.love_choose_id,id)
end

function NewLoveModel:getLoveChooseId()
	local realId =LS:prv():get(StorageCode.love_choose_id,"")
	return realId
end

function NewLoveModel:isHaveInPartner(id)
	local tempPartner = PartnerModel:getAllPartner()
	for k,v in pairs(tempPartner) do
		if tonumber(k) == tonumber(id) then
			return true
		end
	end
	return false
end

function NewLoveModel:questNowHasPartner(partnerTeam)
	local tempMap = {}
	for k,v in pairs(partnerTeam) do
		local weight = 0
		local nowType = self:isHaveInPartner(v)
		if nowType then
			weight = 1
		end
		local nowData = {}
		nowData.id = v 
		nowData.weight = weight
		table.insert(tempMap,nowData)
	end
	table.sort( tempMap, function(a,b)
		local judge = false
		if a.weight > b.weight then
			judge = true 
		elseif a.weight == b.weight then
			if a.id < b.id then
				judge = true
			end
		end
		return judge
	end)
	return tempMap
end




-- ====================================================================
-- ====================================================================
-- 情缘全局属性
-- ====================================================================
-- ====================================================================
function NewLoveModel:onOneCellLighten( event )
	local data = event.params
	-- local function callback()
	-- 	EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_UPDATE_GLOBAL_PROPERTY_DATA,
	-- 		{searchId = data.searchId,cellId = data.cellId,oldPower = data.oldPower})
	-- end
	NewLoveModel:initGlobalLoveData()
	EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_UPDATE_GLOBAL_PROPERTY_DATA,
	{searchId = data.searchId,cellId = data.cellId,oldPower = data.oldPower})
end

-- 判断传入searchId是不是当前searchId的先序id
-- 由于目前id为有顺序的,可以直接转成数字比较
function NewLoveModel:isPreviousSearchId(_searchId,_curSearchId)
	return tonumber(_searchId) <= tonumber(_curSearchId)
end

-- 初始化数据
function NewLoveModel:initGlobalLoveData()
    -- 实际属性计算用
    self._showData = {}
    self._showData.char 		= FuncNewLove.countFinalAttrForShow(FuncNewLove.appendTarget.CHAR,self._calculateData.char)
    self._showData.offensive 	= FuncNewLove.countFinalAttrForShow(FuncNewLove.appendTarget.OFFENSIVE,self._calculateData.offensive)
    self._showData.defensive 	= FuncNewLove.countFinalAttrForShow(FuncNewLove.appendTarget.DEFENSIVE,self._calculateData.defensive)
    self._showData.assisted 	= FuncNewLove.countFinalAttrForShow(FuncNewLove.appendTarget.ASSISTED,self._calculateData.assisted)

    if FuncNewLove.isDebug then
        dump(self._showData.char, "self._showData.char")    
        dump(self._showData.offensive, "self._showData.offensive")    
        dump(self._showData.defensive, "self._showData.defensive")    
        dump(self._showData.assisted, "self._showData.assisted")    
        dump(self._showData.power, "self._showData.power")    
    end
end

function NewLoveModel:getShowPropertyData()
	return self._showData
end

function NewLoveModel:setCurrentLoveId(_loveId)
	self.currentLoveId = _loveId
end

function NewLoveModel:getCurrentLoveId()
	return self.currentLoveId
end

-- 获取上一次选中的奇侠所在奇侠列表的index
function NewLoveModel:getLastChoosedPartnerIndex()
	if not self.choosedPartnerIndex then
		self.choosedPartnerIndex = 1
	end
	return self.choosedPartnerIndex
end

-- 获取上一次选中的奇侠所在奇侠列表的index
function NewLoveModel:setLastChoosedPartnerIndex(index)
	self.choosedPartnerIndex = index
end


return NewLoveModel;
