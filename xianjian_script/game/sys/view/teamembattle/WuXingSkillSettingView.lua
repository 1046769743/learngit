--[[
	Author: TODO
	Date:2018-01-02
	Description: TODO
]]

local WuXingSkillSettingView = class("WuXingSkillSettingView", UIBase);

function WuXingSkillSettingView:ctor(winName, _systemId)
    WuXingSkillSettingView.super.ctor(self, winName)
    self.systemId = _systemId
end

function WuXingSkillSettingView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingSkillSettingView:registerEvent()
	WuXingSkillSettingView.super.registerEvent(self);

	self.btn_1:setTouchedFunc(c_func(self.resetScrollData, self))
	self.panel_di.btn_1:setTouchedFunc(c_func(self.clickCloseButton, self))
	self:registClickClose("out", c_func(self.clickCloseButton, self))
end

function WuXingSkillSettingView:initData()
	local formation = TeamFormationModel:getTempFormation()
	local partnerFormation = formation.partnerFormation
	self.datas = {}
	local index = 1
	-- 按照阵型中的奇侠顺序初始化顺序
	for i = 1, 6, 1 do
		local partnerId = partnerFormation["p"..i].partner.partnerId
		if tostring(partnerId) ~= "0" then
			self.datas[index] = partnerId
			self.partnerNum = index
			index = index + 1 
		end
	end


	self.scrollListData = {}
	for i = 1, 10, 1 do
		self.scrollListData[i] = {}
		self.scrollListData[i].index = i
		self.scrollListData[i].partnerId = "0"
	end

	if formation.energy and table.length(formation.energy) then
		for k,v in pairs(formation.energy) do
			if TeamFormationModel:chkIsInFormation(v) then
				self.scrollListData[tonumber(k)].partnerId = v
			end			
		end
	end

	local tempData = {}
	for i = 1, 10, 1 do
		tempData[i] = {}
		tempData[i].index = i
		tempData[i].partnerId = "0"
	end
	local index_temp = 1
	for i,v in ipairs(self.scrollListData) do
		if tostring(v.partnerId) ~= "0" then
			tempData[index_temp].partnerId = tostring(v.partnerId)
			index_temp = index_temp + 1
		end
	end

	self.scrollListData = tempData
end

function WuXingSkillSettingView:resetScrollData()
	for i = 1, 10, 1 do
		self.scrollListData[i].index = i
		self.scrollListData[i].partnerId = "0"
	end

	self.scroll_1:refreshCellView(1)
end

function WuXingSkillSettingView:initView() 
	self.panel_di.txt_1:setString(GameConfig.getLanguage("#tid_wuxing_012"))

	self.mc_2:showFrame(self.partnerNum)
	self:updateScrollView()
end

function WuXingSkillSettingView:initViewAlign()
	-- TODO
end

function WuXingSkillSettingView:getEnergyCostById(_partnerId)
	local attrData
    if tonumber(_partnerId) == 1 then
        local charAttrData = CharModel:getCharAttr()
    	attrData = FuncBattleBase.formatAttribute(charAttrData)
    else    
    	local partnerData = PartnerModel:getPartnerAttr(tostring(_partnerId))
        attrData = FuncBattleBase.formatAttribute(partnerData)
    end
    local energyCost = 0
    -- 5  对应怒气消耗值
	for i,v in ipairs(attrData) do
	 	if tostring(v.key) == "5" then
	 		energyCost = v.value
	 		break
	 	end
	end
	return energyCost
end

function WuXingSkillSettingView:updateUI()
	for k = 1, self.partnerNum, 1 do
		local tempView = self.mc_2.currentView["panel_"..k]
		local partnerId = self.datas[k]
		tempView:setVisible(true)
		self:updateItemView(tempView, partnerId)      
        local energyCost = self:getEnergyCostById(partnerId)
    	tempView.mc_1:showFrame(tonumber(energyCost) + 1)
        tempView.partnerId = partnerId
		tempView:setTouchedFunc(
            c_func(self.doItemClick, self, tempView),
            nil,
            true, 
            c_func(self.doItemBegan, self, tempView), 
            c_func(self.doItemMove, self, tempView),
            false,
            c_func(self.doItemEnded, self, tempView)
        )
	end
end

function WuXingSkillSettingView:updateScrollView()
	self.mc_1:setVisible(false)

	local createCellFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.mc_1)
		self:updateScrollItem(view, itemData)
		return view
	end

	local reuseUpdateCellFunc = function (itemData, view)
		self:updateScrollItem(view, itemData)
		return view
	end

	self.params = {
		{
			data = self.scrollListData,	        
	        createFunc = createCellFunc,
	        offsetX = 15,
	        offsetY = 130,
	        widthGap = 5,
	        heightGap = 0,
	        perFrame = 1,
	        perNums = 5,
	        itemRect = {x = 0, y = -240, width = 120, height = 120},
	        updateCellFunc = reuseUpdateCellFunc,
		}
	}

	self.scroll_1:styleFill(self.params)
	self.scroll_1:refreshCellView(1)
	self.scroll_1:setCanScroll(false)
	self.scroll_1:hideDragBar()
end

function WuXingSkillSettingView:updateScrollItem(_view, _itemData)
	local partnerId = _itemData.partnerId
	local index = _itemData.index
	-- echo(_itemData.index,_itemData.partnerId,"______refresh-----")
	if tostring(partnerId) == "0" then
		_view:showFrame(2)
		_view.currentView.mc_1:showFrame(index)
	else
		_view:showFrame(1)
		local view = _view.currentView
		view.data = _itemData
		view.panel_1.data = _itemData
		self:updateItemView(view.panel_1, partnerId)
		local energyCost = self:getEnergyCostById(partnerId)
		view.panel_1.mc_1:showFrame(tonumber(energyCost) + 1)	
		view:setTouchedFunc(c_func(self.doScrollItemClick, self, view))
	end
end

function WuXingSkillSettingView:updateItemView(_view, _partnerId)
	local tempView = _view
	local itemType 
    local nowElement
    tempView.ctn_tu2:removeAllChildren()
    local partnerId = _partnerId
    tempView.partnerId = partnerId
    tempView.data = _view.data
    if tonumber(partnerId) == 1 then   	
        partnerId = UserModel:avatar()
        local garmentId = GarmentModel:getOnGarmentId()
        tempView.UI_1:updataUI(partnerId, garmentId)
        local curTreaData = nil
        local tempTreasure = nil
        curTreaData = TeamFormationModel:getCurTreaByIdx(1)  
        tempTreasure = FuncTreasureNew.getTreasureDataById(curTreaData)   
        nowElement = tempTreasure.wuling
        itemType = tempTreasure.type
    else    
        local skin = ""
        local partnerData = PartnerModel:getPartnerDataById(partnerId)
        local partnerCfg = FuncPartner.getPartnerById(partnerId)
        if partnerData then
            skin = partnerData.skin
        end
        tempView.UI_1:updataUI(partnerId, skin)
        itemType = FuncPartner.getPartnerById(partnerId).type
        -- itemType = TeamFormationModel:getPropByPartnerId(partnerId)
    	nowElement = partnerCfg.elements
    end

    tempView.UI_1.panel_lv:setVisible(false)
    tempView.mc_gfj:showFrame(itemType)
    local wuxingData = FuncTeamFormation.getWuXingDataById(nowElement)
    local wuxingIcon = FuncRes.iconWuXing(wuxingData.icon)
    local sp = display.newSprite(wuxingIcon):addto(tempView.ctn_tu2)
    sp:setScale(0.3)

    -- if FuncCommon.isSystemOpen("fivesoul") then 
    --     tempView.ctn_tu2:visible(true)
    --     tempView.panel_d:visible(true)
    -- else
    --     tempView.ctn_tu2:visible(false)
    --     tempView.panel_d:visible(false)
    -- end

    tempView:setTouchedFunc(
            c_func(self.doScrollItemClick, self, tempView),
            nil,
            true, 
            c_func(self.doItemBegan, self, tempView), 
            c_func(self.doItemMove, self, tempView),
            false,
            c_func(self.doItemEnded, self, tempView)
        )
end

function WuXingSkillSettingView:isFull()
	for i,v in ipairs(self.scrollListData) do
		if tostring(v.partnerId) == "0" then
			return false
		end
	end
	return true
end

function WuXingSkillSettingView:doScrollItemClick(view,event)
	local data = view.data
	if self.scroll_1:isMoving() then
		return 
	end

	for i,v in ipairs(self.scrollListData) do
		if tonumber(v.index) == tonumber(data.index) then
			self.scrollListData[i].partnerId = "0"

			local scrollItem = self.scroll_1:getViewByData(v)
			if(scrollItem) then 
				self:updateScrollItem(scrollItem, v)
				return
			end
			-- echoError("___为什么没有view",i)

			break
		end
	end
 
	-- self.scroll_1:refreshCellView(1)
end

function WuXingSkillSettingView:doItemClick(view,event)
	local partnerId = view.partnerId
	if tonumber(partnerId) == 1 then
		partnerId = UserModel:avatar()

		local treasureId = TeamFormationModel:getCurTreaByIdx(1)
		local dataCfg = FuncTreasureNew.getTreasureDataById(treasureId)
    	local skillId
    	for i,v in ipairs(dataCfg.skill) do
    		local skillInfo = FuncTreasureNew.getTreasureSkillDataDataById(v)
    		if tonumber(skillInfo.priority) == 1 then
				skillId = v
				break
			end
    	end
    	local data = TreasureNewModel:getTreasureData(treasureId)
		local params = {treasureId = treasureId, skillId = skillId, index = index, data = data}
		local scene = WindowControler:getCurrScene()
	    local currentUi = WindowsTools:createWindow("TreasureSkillTips", params):addto(scene, 100):pos(GameVars.UIOffsetX,
	        GameVars.height - GameVars.UIOffsetY)
	    currentUi:registClickClose(nil,nil,true,true)
	    currentUi:startShow(view)
	else
		local partnerData = FuncPartner.getPartnerById(partnerId)
		local skillId 
		for i,v in ipairs(partnerData.skill) do
			local skillInfo = FuncPartner.getSkillInfo(v)
			if tonumber(skillInfo.priority) == 1 then
				skillId = v
				break
			end
		end

		local index = 1
		local _skillInfo = FuncPartner.getSkillInfo(skillId)
		local isUnlock, skillLevel =  PartnerModel:isUnlockSkillById(partnerId, skillId)
		local params = {partnerId = partnerId, id = skillId, level = skillLevel or 1, isUnlock = isUnlock, _index = index}
		local scene = WindowControler:getCurrScene()
	    local currentUi = WindowsTools:createWindow("PartnerSkillDetailView", params):addto(scene, 100):pos(GameVars.UIOffsetX,
	        GameVars.height - GameVars.UIOffsetY)
	    currentUi:registClickClose(nil,nil,true,true)
	    currentUi:startShow(view)		
	end
end

function WuXingSkillSettingView:doItemBegan(view, event)
	local partnerId = view.partnerId
	if self.scroll_1:isMoving() then
		return 
	end
	self.ctn_node:removeAllChildren()
    local xx,yy = view:getPosition()
    local globelPos = view:getParent():convertToWorldSpace(cc.p(xx+50,yy-40))

    local skin = ""
    if tonumber(partnerId) == 1 then   	
        partnerId = UserModel:avatar()
        skin = GarmentModel:getOnGarmentId()
    else    
        local partnerData = PartnerModel:getPartnerDataById(partnerId)
        local partnerCfg = FuncPartner.getPartnerById(partnerId)
        if partnerData then
            skin = partnerData.skin
        end
    end
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
    headMaskSprite:pos(-1, 0)
    headMaskSprite:setScale(0.88)    
    local iconSpr = FuncPartner.getPartnerIconByIdAndSkin(partnerId, skin)
    local iconSpine = FuncCommUI.getMaskCan(headMaskSprite, iconSpr)
    iconSpine:addto(self.ctn_node):pos(0, -20)
    -- spineView:setScaleX(-1)
    self.ctn_node.view = iconSpine
    self.ctn_node.view:opacity(120)
    self.ctn_node.partnerId = view.partnerId

    local cntParent = self.ctn_node:parent()
    local locaNode = cntParent:convertToNodeSpace(globelPos)
    self.ctn_node:pos(locaNode.x,locaNode.y)

    xx,yy = self.ctn_node:getPosition()
    self.ctnSrcPos = {x = xx,y = yy}
    self.startItemPos = {x = event.x, y = event.y}
    self.ctn_node.view:visible(false)
end
 
function WuXingSkillSettingView:doItemMove(view, event)
    local beginItemPos = self.startItemPos  
    if not beginItemPos  then
        return
    end
       
    local offsetX = event.x - beginItemPos.x
    local offsetY = event.y - beginItemPos.y

    self.ctn_node.view:visible(true)
    self.ctn_node:pos(self.ctnSrcPos.x + offsetX, self.ctnSrcPos.y + offsetY)
end

function WuXingSkillSettingView:doItemEnded(view, event)
	local x, y = event.x, event.y
    local pIdx = 0
    local targetMc 

    local index = self:getIndexByPosition(x, y)
    if index == 0 then
    	if view.data then
    		local view_index = view.data.index
    		local scrollItem = self.scroll_1:getViewByData(self.scrollListData[view_index])
    		self.scrollListData[view_index].partnerId = "0"
			if scrollItem then 
				self:updateScrollItem(scrollItem, self.scrollListData[view_index])
			end   		
    	end
    	self.ctn_node.view:visible(false)
   	else
   		local lastPartnerId = view.partnerId
   		local lastIndex = 0
   		if view.data then
   			lastIndex = view.data.index
   		end
   		
   		local exchangePartnerId = "0"
   		if self.scrollListData[index].partnerId ~= "0" then
   			exchangePartnerId = self.scrollListData[index].partnerId
   		end
   		if tostring(lastPartnerId) ~= tostring(exchangePartnerId) then
   			local scrollItem = self.scroll_1:getViewByData(self.scrollListData[index])
			self.scrollListData[index].partnerId = view.partnerId
			if scrollItem then 
				self:updateScrollItem(scrollItem, self.scrollListData[index])
			end

			if lastIndex ~= 0 then
				local lastScrollItem = self.scroll_1:getViewByData(self.scrollListData[lastIndex])
				self.scrollListData[lastIndex].partnerId = exchangePartnerId
				if lastScrollItem then 
					self:updateScrollItem(lastScrollItem, self.scrollListData[lastIndex])
				end
			end
   		end
   						
		self.ctn_node.view:visible(false)
    end
end

--[[
self.params = {
		{
			data = self.scrollListData,	        
	        createFunc = createCellFunc,
	        offsetX = 15,
	        offsetY = 130,
	        widthGap = 5,
	        heightGap = 0,
	        perFrame = 1,
	        perNums = 5,
	        itemRect = {x = 0, y = -240, width = 120, height = 120},
	        updateCellFunc = reuseUpdateCellFunc,
		}
	}]]



function WuXingSkillSettingView:checkScrollIndex(_x, _y)
	local resultIndex = 0
	local groupIndex = 0
	local xpos = _x
	local ypos = _y
	-- echo("\n\nx=", _x, "y=", _y)
	local node = self.scroll_1:getScrollNode()
	local localPos = node:convertToNodeSpaceAR(cc.p(_x, _y))
	local scroll_rect = self.scroll_1:getContainerBox()
	-- dump(localPos, "\n\nlocalPos===")
	-- dump(scroll_rect, "\n\nscroll_rect====")
    local targetpos  = self.scroll_1:convertToNodeSpaceAR(cc.p(_x, _y))
    local params = self.params[1]
	if cc.rectContainsPoint(scroll_rect, targetpos) then
		groupIndex, resultIndex = self.scroll_1:getGroupPos(0, true, -localPos.x, localPos.y)

		-- resultIndex = self.scroll_1:getViewIndex(localPos.x, localPos.y, params.itemRect, params.perNums, params.offsetX, params.offsetY, params.widthGap, params.heightGap, true)
		-- echoError("groupIndex===", groupIndex, "resultIndex==", resultIndex)
	end

	return resultIndex
end

function WuXingSkillSettingView:getIndexByPosition(x, y)
	local index = 0
	local allView = self.scroll_1:getAllView()
	local localPos = self:convertToNodeSpace(cc.p(x,y))
	for k = 1, 10, 1 do
            --已经开启的情况
            local nd = allView[k].currentView
            local nd_rect = nd:convertLocalToNodeLocalPos(self)
            if cc.rectContainsPoint(cc.rect(nd_rect.x, nd_rect.y - 120, 120, 120), localPos) then
                index = k
                break
            end
     end
     return index
end

function WuXingSkillSettingView:setFormationEnergy()
	local finalData = {}
	local index = 1
	for i,v in ipairs(self.scrollListData) do
		if tostring(v.partnerId) ~= "0" then
			finalData[tostring(index)] = tostring(v.partnerId)
			index = index + 1
		end
	end
	TeamFormationModel:setPvpFormationEnergy(finalData, self.systemId)
end

function WuXingSkillSettingView:clickCloseButton()
	WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_013"))
	self:setFormationEnergy()
	self:startHide()
	EventControler:dispatchEvent(TeamFormationEvent.PVP_SKILLVIEW_CLOSED)
end

function WuXingSkillSettingView:deleteMe()
	-- TODO

	WuXingSkillSettingView.super.deleteMe(self);
end

return WuXingSkillSettingView;
