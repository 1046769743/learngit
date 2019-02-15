--[[
	Author: TODO
	Date:2018-05-15
	Description: TODO
]]

local WuXingEnemyDetailView = class("WuXingEnemyDetailView", UIBase);

function WuXingEnemyDetailView:ctor(winName)
    WuXingEnemyDetailView.super.ctor(self, winName)
end

function WuXingEnemyDetailView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingEnemyDetailView:registerEvent()
	WuXingEnemyDetailView.super.registerEvent(self);
end

function WuXingEnemyDetailView:initData()
	-- TODO
end

function WuXingEnemyDetailView:updateEnemyView(_enemyData, _params)
	if _enemyData then
		self:updatePveEnemyView(_enemyData)
	else
		if _params.isPvpAttack then
			self:updatePvpEnemyView(_params)
		elseif _params.isMissionPvp then
			self:updateMissionPvpEnemyView(_params)
		end	
	end
end

function WuXingEnemyDetailView:setItemsVisibleFalse(_view)
	_view.panel_prop:setVisible(false)
	_view.panel_qipao:setVisible(false)
	_view.panel_tiao:setVisible(false)
	_view.mc_1:setVisible(false)
	_view.mc_star:setVisible(false)
	_view.mc_you:setVisible(false)
	_view.txt_name:setVisible(false)
	_view.panel_1:setVisible(false)
end

function WuXingEnemyDetailView:updateWuLingIcon(_view, _elementId, _offSetY)
	if _elementId and tostring(_elementId) ~= "0" then
		_view.mc_you:showFrame(1)
		_view.mc_you:setVisible(true)
		local nowWuXingData = FuncTeamFormation.getWuXingDataById(_elementId)
	    local wuxingIcon = FuncRes.iconWuXing(nowWuXingData.iconResou)
		local sp1 = display.newSprite(wuxingIcon)
	    _view.mc_you.currentView.ctn_tu2:removeAllChildren()
	    _view.mc_you.currentView.ctn_tu2:addChild(sp1)
	    local smallWuXingPosIcon = FuncRes.iconWuXing(nowWuXingData.iconBott)
	    local sp2 = display.newSprite(smallWuXingPosIcon)
	    _view.mc_you.currentView.ctn_tu3:removeAllChildren()
	    _view.mc_you.currentView.ctn_tu3:addChild(sp2)
	    _view.mc_you:setPositionY(_offSetY)
	end	
end

function WuXingEnemyDetailView:updateOnePveEnemy(_view, _emermyData, scale)
	self:setItemsVisibleFalse(_view)

	local elementId = "0"
	local curElements = "0"
	if _emermyData then
		_view.txt_name:setString(GameConfig.getLanguage(_emermyData.name))
		local baseTreaData = FuncTeamFormation.getEnemyTreaDataById(_emermyData.baseTrea)
		local sourceId = baseTreaData.source
		local sourceCfg = FuncTreasure.getSourceDataById(sourceId)
		local spine = FuncRes.getSpineViewBySourceId(sourceId, nil, false, sourceCfg)
		_view.ctn_player:removeAllChildren()
		_view.ctn_player:addChild(spine)
		spine:pos(0, -50)
		if scale > 2 then
			spine:setScale(0.6)
		end
		
		if baseTreaData.elements then
			curElements = baseTreaData.elements[1]
		end
		
		local offSetY = sourceCfg.viewSize[2] or 160
		self:updateWuLingIcon(_view, curElements, offSetY)
		elementId = _emermyData.elementId
	end

	local nowWuXingCfg = FuncTeamFormation.getWuXingDataById(elementId)
    local elementIcon = FuncRes.iconWuXing(nowWuXingCfg.iconPosi)
    local elementSp = display.newSprite(elementIcon)
	_view.panel_ft.ctn_di:removeAllChildren()
	_view.panel_ft.ctn_di:addChild(elementSp)

	elementSp:setScale(1 * scale)
	if tostring(elementId) ~= "0" and tostring(elementId) == tostring(curElements) then
		local animName = FuncWuLing.ANIM_NAME[tonumber(elementId)]
		local anim = self:createUIArmature("UI_wulingchuzhan", animName, _view.panel_ft.ctn_di, true)
		anim:pos(-4, -2)
		anim:setScale(scale)
	end
end

function WuXingEnemyDetailView:initOnePvePos(_view)
	self:setItemsVisibleFalse(_view)

	local nowWuXingCfg = FuncTeamFormation.getWuXingDataById("0")
    local elementIcon = FuncRes.iconWuXing(nowWuXingCfg.iconPosi)
    local elementSp = display.newSprite(elementIcon)
	_view.panel_ft.ctn_di:removeAllChildren()
	_view.panel_ft.ctn_di:addChild(elementSp)

	elementSp:setScale(1)
end

function WuXingEnemyDetailView:updatePveEnemyView(_enemyData)
	for i = 1, 6, 1 do
		if self["panel_1"..i] then
			self:initOnePvePos(self["panel_1"..i])
		end
		
		if self["panel_2"..i] then
			self["panel_2"..i]:setVisible(false)
		end
		if self["panel_4"..i] then
			self["panel_4"..i]:setVisible(false)
		end
		if self["panel_6"..i] then
			self["panel_6"..i]:setVisible(false)
		end
	end

	for i = 1, 6, 1 do		
		if _enemyData["e"..i] then
			local elementId = "0"
			if _enemyData.elementsEnemyPosition then
				elementId = _enemyData.elementsEnemyPosition[i]
			end
			local enemyId = _enemyData["e"..i]
			local enemyData = FuncTeamFormation.getEnemyDataById(enemyId)
			if enemyData then
				enemyData.elementId = elementId
				local figure = enemyData.figure or 1
				local scale = 1
				if figure > 1 then
					self["panel_"..figure..i]:setVisible(true)
					for index = 1, figure, 1 do
						self["panel_1"..(i + index - 1)]:setVisible(false)				
					end
					scale = figure / 2
				end	
				self:delayCall(c_func(self.updateOnePveEnemy, self, self["panel_"..figure..i], enemyData, scale), 0.1 * i)		
			end
		end
	end
end

--登仙台里面的数据与六界轶事比武切磋的数据不一样  需要区别处理
function WuXingEnemyDetailView:updatePvpEnemyView(_params)
	local partnerFormation = _params.formations.partnerFormation
	--六界轶事取的是主线阵容
	if _params.isMissionPvp then
		partnerFormation = _params.formations[tostring(FuncTeamFormation.formation.pve)].partnerFormation
	end
	if _params.isRobot then
		local charPos = _params.charPos
		partnerFormation["p"..charPos] = "1"
	end
	for i = 1, 6, 1 do
		if self["panel_2"..i] then
			self["panel_2"..i]:setVisible(false)
		end
		if self["panel_4"..i] then
			self["panel_4"..i]:setVisible(false)
		end
		if self["panel_6"..i] then
			self["panel_6"..i]:setVisible(false)
		end

		local _view = self["panel_1"..i]
		self:setItemsVisibleFalse(_view)

		local partnerId = "0"
		local elementId = "0"
		if _params.isRobot then
			if partnerFormation["p"..i] then
				partnerId = partnerFormation["p"..i]
			end
		else
			partnerId = tostring(partnerFormation["p"..i].partner.partnerId)
			elementId = tostring(partnerFormation["p"..i].element.elementId)
		end

		local loadPvpSpine = function ()
			local spine
			local curElements
			if partnerId == "1" then
				_view.mc_you:setVisible(true)
				_view.mc_you:showFrame(2)
				local curTrea = "404"
				if _params.formations.treasureFormation then
					curTrea = _params.formations.treasureFormation["p1"]
				end			
                local icon = display.newSprite(FuncRes.iconTreasureNew(curTrea)):size(30, 30)				
				_view.mc_you.currentView.panel_xxaxx.ctn_goodsicon:removeAllChildren()
				_view.mc_you.currentView.panel_xxaxx.ctn_goodsicon:addChild(icon)
				local treaData = FuncTreasureNew.getTreasureDataById(curTrea)
				curElements = treaData.wuling
		        local nowWuXingData = FuncTeamFormation.getWuXingDataById(treaData.wuling)
		        local wuxingIcon = FuncRes.iconWuXing(nowWuXingData.iconResou)
		        local sp1 = display.newSprite(wuxingIcon)
		        _view.mc_you.currentView.ctn_tu2:removeAllChildren()
		        _view.mc_you.currentView.ctn_tu2:addChild(sp1)
		        local smallWuXingPosIcon = FuncRes.iconWuXing(nowWuXingData.iconBott)
		        local sp2 = display.newSprite(smallWuXingPosIcon)
		        _view.mc_you.currentView.ctn_tu3:removeAllChildren()
		        _view.mc_you.currentView.ctn_tu3:addChild(sp2)

				local avatar = _params.avatar
				local garmentId = _params.garmentId or ""
				--六界轶事带userExt参数
				if _params.userExt then
					garmentId = _params.userExt.garmentId or ""
				end
				spine = FuncGarment.getSpineViewByAvatarAndGarmentId(avatar, garmentId, false)
				_view.ctn_player:removeAllChildren()
				_view.ctn_player:addChild(spine)
				spine:pos(0, -50)
			elseif partnerId ~= "0" then
				_view.mc_you:setVisible(true)
				local partnerCfg = FuncPartner.getPartnerById(partnerId)
				_view.mc_you:showFrame(1)
				curElements = partnerCfg.elements
	            local nowWuXingData = FuncTeamFormation.getWuXingDataById(partnerCfg.elements)
	            local wuxingIcon = FuncRes.iconWuXing(nowWuXingData.iconResou)
	            local sp1 = display.newSprite(wuxingIcon)
		        _view.mc_you.currentView.ctn_tu2:removeAllChildren()
		        _view.mc_you.currentView.ctn_tu2:addChild(sp1)
		        local smallWuXingPosIcon = FuncRes.iconWuXing(nowWuXingData.iconBott)
		        local sp2 = display.newSprite(smallWuXingPosIcon)
		        _view.mc_you.currentView.ctn_tu3:removeAllChildren()
		        _view.mc_you.currentView.ctn_tu3:addChild(sp2)

				local partnerData = {}
				if _params.partners then
					partnerData = _params.partners[tostring(partnerId)]
					
				end
				--六界轶事有partnerSkins字段，没有partners字段
				if _params.partnerSkins then
					partnerData.skin = _params.partnerSkins[tostring(partnerId)]
				end

				local spineId, sourceId = FuncTeamFormation.getSpineNameByHeroId(partnerId, false, partnerData.skin)
				local sourceData = FuncTreasure.getSourceDataById(sourceId)
	        	spine = ViewSpine.new(spineId, {}, nil, spineId, nil,sourceData)
	        	spine:playLabel("stand", true)
	        	_view.ctn_player:removeAllChildren()
				_view.ctn_player:addChild(spine)
				spine:pos(0, -50)	
			end

			local nowWuXingCfg = FuncTeamFormation.getWuXingDataById(elementId)
	        local elementIcon = FuncRes.iconWuXing(nowWuXingCfg.iconPosi)
	        local elementSp = display.newSprite(elementIcon)
			_view.panel_ft.ctn_di:removeAllChildren()
			_view.panel_ft.ctn_di:addChild(elementSp)
			-- elementSp:setScale(0.3)
			if tostring(elementId) ~= "0" and tostring(elementId) == tostring(curElements) then
				local animName = FuncWuLing.ANIM_NAME[tonumber(elementId)]
				local anim = self:createUIArmature("UI_wulingchuzhan", animName, _view.panel_ft.ctn_di, true)
				anim:pos(-4, -2)
			end
		end
		
		self:delayCall(c_func(loadPvpSpine), 0.1 * i)
	end 
end

--正常来说 都会有formations，但内网经常会出现没有的账号  所以在后面做了兼容处理
function WuXingEnemyDetailView:updateMissionPvpEnemyView(_params)
	if _params.formations then
		self:updatePvpEnemyView(_params)
	else
		for i = 1, 6, 1 do
			if self["panel_2"..i] then
				self["panel_2"..i]:setVisible(false)
			end
			if self["panel_4"..i] then
				self["panel_4"..i]:setVisible(false)
			end
			if self["panel_6"..i] then
				self["panel_6"..i]:setVisible(false)
			end

			local _view = self["panel_1"..i]
			self:setItemsVisibleFalse(_view)

			local elementId = "0"
			if i == 1 then
				_view.mc_you:setVisible(true)
				_view.mc_you:showFrame(2)
				local avatar = _params.avatar
				local garmentId = _params.garmentId or ""
				spine = FuncGarment.getSpineViewByAvatarAndGarmentId(avatar, garmentId, false)
				_view.ctn_player:removeAllChildren()
				_view.ctn_player:addChild(spine)
				spine:pos(0, -50)

				local curTrea = "404"		
                local icon = display.newSprite(FuncRes.iconTreasureNew(curTrea)):size(33.3, 33.3)				
				_view.mc_you.currentView.panel_xxaxx.ctn_goodsicon:removeAllChildren()
				_view.mc_you.currentView.panel_xxaxx.ctn_goodsicon:addChild(icon)
				local treaData = FuncTreasureNew.getTreasureDataById(curTrea)
		        local nowWuXingData = FuncTeamFormation.getWuXingDataById(treaData.wuling)
		        local wuxingIcon = FuncRes.iconWuXing(nowWuXingData.iconResou)
		        local sp1 = display.newSprite(wuxingIcon)
		        _view.mc_you.currentView.ctn_tu2:removeAllChildren()
		        _view.mc_you.currentView.ctn_tu2:addChild(sp1)
		        local smallWuXingPosIcon = FuncRes.iconWuXing(nowWuXingData.iconBott)
		        local sp2 = display.newSprite(smallWuXingPosIcon)
		        _view.mc_you.currentView.ctn_tu3:removeAllChildren()
		        _view.mc_you.currentView.ctn_tu3:addChild(sp2)	
			end

			local nowWuXingCfg = FuncTeamFormation.getWuXingDataById(elementId)
	        local elementIcon = FuncRes.iconWuXing(nowWuXingCfg.iconPosi)
	        local elementSp = display.newSprite(elementIcon)
			_view.panel_ft.ctn_di:removeAllChildren()
			_view.panel_ft.ctn_di:addChild(elementSp)
			-- elementSp:setScale(0.3)
		end
	end
end

function WuXingEnemyDetailView:initView()
	-- TODO
end

function WuXingEnemyDetailView:initViewAlign()
	-- TODO
end

function WuXingEnemyDetailView:updateUI()
	-- TODO
end

function WuXingEnemyDetailView:deleteMe()
	-- TODO

	WuXingEnemyDetailView.super.deleteMe(self);
end

return WuXingEnemyDetailView;
