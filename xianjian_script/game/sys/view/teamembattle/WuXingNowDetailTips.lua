--[[
	Author: TODO
	Date:2017-11-09
	Description: TODO
]]

local WuXingNowDetailTips = class("WuXingNowDetailTips", UIBase);

function WuXingNowDetailTips:ctor(winName,isMulit,systemId)
    WuXingNowDetailTips.super.ctor(self, winName)
    self.isMulit = isMulit
    self.systemId = systemId
end

function WuXingNowDetailTips:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingNowDetailTips:registerEvent()
	WuXingNowDetailTips.super.registerEvent(self);

	local coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), true):addto(self._root, 0)
	-- coverLayer:zorder(-1)
    coverLayer:pos(-15,  105)
    coverLayer:setTouchedFunc(c_func(self.needHideDetailView, self))
    coverLayer:setTouchSwallowEnabled(false)

	-- self:registClickClose(-1, c_func(function()
	-- 	self:startHide()
	-- end,self))
	EventControler:addEventListener(TeamFormationEvent.TEAMVIEW_HAS_CLOSED, self.startHide, self)
end

function WuXingNowDetailTips:needHideDetailView()
	EventControler:dispatchEvent(TeamFormationEvent.CLOSE_WUXING_DETAILVIEW)
end

function WuXingNowDetailTips:refreshDetailView()
	self:initData()
	self:initView()
	self:updateUI()
end

function WuXingNowDetailTips:initData()
	self.wulingDes = {
		[1] = GameConfig.getLanguage("#tid_fivesoul_tips_1"),
		[2] = GameConfig.getLanguage("#tid_fivesoul_tips_2"),
		[3] = GameConfig.getLanguage("#tid_fivesoul_tips_3"),
		[4] = GameConfig.getLanguage("#tid_fivesoul_tips_4"),
		[5] = GameConfig.getLanguage("#tid_fivesoul_tips_5"),
	}

	self.des = GameConfig.getLanguage("#tid_fivesoul_tips_6")
	self.xianshuDengji = GameConfig.getLanguage("#tid_wuxing_001")
	local teamData = nil
	if self.isMulit then
		teamData = TeamFormationMultiModel:getTempFormation()
	else
		teamData = TeamFormationModel:getTempFormation()
	end

	self.datas = {}
	for i = 1, 6, 1 do
		if tostring(teamData.partnerFormation["p"..i].partner.partnerId) ~= "0" and
			tostring(teamData.partnerFormation["p"..i].element.elementId) ~= "0" then
			table.insert(self.datas, teamData.partnerFormation["p"..i])
		end
	end

	if self.systemId == FuncTeamFormation.formation.guildBossGve then
		self.mateInfo = GuildBossModel:getGuildBossMateInfo()
	end
end

function WuXingNowDetailTips:initView()
	-- self._root:setPositionX(-(GameVars.width - GameVars.gameResWidth) / 2)
	-- self:initAllEffect()
	self.panel_qixiaxiangqing.panel_1:visible(false)
	local createCellFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_qixiaxiangqing.panel_1)
		self:updateItemView(itemData, view)
		return view
	end

	local reuseCellFunc = function (itemData, view)
		self:updateItemView(itemData, view)
	end

	local params = {
		{
			data = self.datas,
			createFunc = createCellFunc,
			updateFunc = reuseCellFunc,
			perNums = 1,
			perFrame = 1,
			offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -72, width = 550, height = 72}, 
		}
	}

	self.panel_qixiaxiangqing.scroll_1:styleFill(params)
	self.panel_qixiaxiangqing.scroll_1:hideDragBar()

	if #self.datas == 0 then
		local view = self.panel_qixiaxiangqing.panel_1
		view.txt_name:setString(GameConfig.getLanguage("#tid_wuxing_002"))
		view.txt_1:setString("")
		view.txt_2:setString("")
		view.txt_3:setString("")
		view.txt_4:setString("")
		view:setVisible(true)
	end
end

function WuXingNowDetailTips:initViewAlign()
	
end

function WuXingNowDetailTips:updateUI()
	-- TODO
end

function WuXingNowDetailTips:updateItemView(itemData, view)
	if self.isMulit then
		--todo
	else
		local fiveSouls = nil
		if itemData.element.rid ~= UserModel:rid() then					
			fiveSouls = self.mateInfo.fivesouls
		end
		local tempLevel = WuLingModel:getWuLingLevelById(itemData.element.elementId, fiveSouls)
		local firstProperty,secondProperty = WuLingModel:getWuLingProperty(itemData.element.elementId, tempLevel)
		local partnerId = itemData.partner.partnerId
		local wulingType = WuLingModel:switchTextById(itemData.element.elementId)
		if tostring(partnerId) == "1" then
			local curTreasureId = TeamFormationModel:getCurTreaByIdx(1)
			if self.systemId == FuncTeamFormation.formation.guildBossGve then
				_, curTreasureId = TeamFormationModel:getMultiTreasureOwnerAndId()
			end
			local tempTreasure = FuncTreasureNew.getTreasureDataById(curTreasureId)
	        local name = UserModel:name()
	        if itemData.partner.rid ~= UserModel:rid() then
	        	name = self.mateInfo.name
	        end
	        view.txt_name:setString(name..":")
	        if tonumber(itemData.element.elementId) == tonumber(tempTreasure.wuling) then			        	
				view.txt_1:setString(self.wulingDes[tonumber(itemData.element.elementId)])
				view.txt_2:setString(wulingType.."+"..firstProperty.."%")
				view.txt_3:setString(self.des)
				view.txt_4:setString(self.xianshuDengji.."+"..secondProperty)
			else
				view.txt_1:setString(self.wulingDes[tonumber(itemData.element.elementId)])
				view.txt_2:setString(wulingType.."+"..firstProperty.."%")
				view.txt_3:setString("")
				view.txt_4:setString("")
			end
		else
			if FuncWonderland.isWonderLandNpc(partnerId) or FuncTower.isConfigEmployee(tostring(partnerId)) then
				local staticNpcInfo = ObjectCommon.getPrototypeData("level.EnemyInfo", partnerId)
				local partnerName = FuncTranslate._getLanguage(staticNpcInfo.name)
				view.txt_name:setString(partnerName..":")
				view.txt_1:setString(self.wulingDes[tonumber(itemData.element.elementId)])
				view.txt_2:setString(wulingType.."+"..firstProperty.."%")
				view.txt_3:setString("")
				view.txt_4:setString("")
			else
				local partnerData = FuncPartner.getPartnerById(partnerId)
				local partnerName = FuncPartner.getPartnerName(partnerId)
				view.txt_name:setString(partnerName..":")
				if tonumber(itemData.element.elementId) == tonumber(partnerData.elements) then
					view.txt_1:setString(self.wulingDes[tonumber(itemData.element.elementId)])
					view.txt_2:setString(wulingType.."+"..firstProperty.."%")
					view.txt_3:setString(self.des)
					view.txt_4:setString(self.xianshuDengji.."+"..secondProperty)
				else
					view.txt_1:setString(self.wulingDes[tonumber(itemData.element.elementId)])
					view.txt_2:setString(wulingType.."+"..firstProperty.."%")
					view.txt_3:setString("")
					view.txt_4:setString("")
				end
			end
		end
	end
end

function WuXingNowDetailTips:initAllEffect()	
	local teamData = nil 
	self.panel_qixiaxiangqing.panel_1:visible(false)
	local tempRatio = 0
	-- 仙术等级汉字
	local xianshuDengji = GameConfig.getLanguage("#tid_wuxing_001")
	if self.isMulit then
		teamData = TeamFormationMultiModel:getTempFormation()
		for k,v in pairs(teamData.partnerFormation) do
			if v.partner.partnerId ~= "0" and v.element.elementId ~= "0" and v.partner.rid == UserModel:rid() then
				local view = UIBaseDef:cloneOneView(self.panel_1.txt_name1)
				local tempLevel = WuLingModel:getWuLingLevelById(v.element.elementId)
				local firstProperty,secondProperty = WuLingModel:getWuLingProperty(v.element.elementId,tempLevel)
				local partnerId = v.partner.partnerId
				local wulingType = WuLingModel:switchTextById(v.element.elementId)
				if tostring(partnerId) == "1" then
					local tempTreasure = nil
			        if self.isMuilt then
			            local curTreaData = TeamFormationMultiModel:getCurTreaByIdx(1)
			            tempTreasure = FuncTreasureNew.getTreasureDataById(curTreaData.id)
			        else    
			            tempTreasure = FuncTreasureNew.getTreasureDataById(TeamFormationModel:getCurTreaByIdx(1))
			        end
			        local nowWuXingData = FuncTeamFormation.getWuXingDataById()
			        if tonumber(v.element.elementId) == tonumber(tempTreasure.wuling) then
						view:setString("   "..UserModel:name().." : "..wulingType.."+"..firstProperty.."%   "..xianshuDengji.."+"..secondProperty)
					else
						view:setString("   "..UserModel:name().." : "..wulingType.."+"..firstProperty.."%")
					end
					self.panel_1:addChild(view)
					view:pos(0,40*tempRatio)
					tempRatio = tempRatio +1
				else
					local partnerData = FuncPartner.getPartnerById(partnerId)
					local partnerName = FuncPartner.getPartnerName(partnerId)
					if tonumber(v.element.elementId) == tonumber(partnerData.elements) then
						view:setString("   "..partnerName.." : "..wulingType.."+"..firstProperty.."%   "..xianshuDengji.."+"..secondProperty)
					else
						view:setString("   "..partnerName.." : "..wulingType.."+"..firstProperty.."%")
					end
					self.panel_1:addChild(view)
					view:pos(0,-40*tempRatio)
					tempRatio = tempRatio +1
				end
			end	
		end	
	else	
		teamData = TeamFormationModel:getTempFormation()
		local mateInfo = nil
		if self.systemId == FuncTeamFormation.formation.guildBossGve then
			mateInfo = GuildBossModel:getGuildBossMateInfo()
		end	
		for k,v in pairs(teamData.partnerFormation) do
			if v.partner.partnerId ~= "0" and v.element.elementId ~= "0" then
				local view = UIBaseDef:cloneOneView(self.panel_qixiaxiangqing.panel_1)
				local fiveSouls = nil
				if v.element.rid ~= UserModel:rid() then					
					fiveSouls = mateInfo.fivesouls
				end
				local tempLevel = WuLingModel:getWuLingLevelById(v.element.elementId, fiveSouls)
				local firstProperty,secondProperty = WuLingModel:getWuLingProperty(v.element.elementId,tempLevel)
				local partnerId = v.partner.partnerId
				local wulingType = WuLingModel:switchTextById(v.element.elementId)
				if tostring(partnerId) == "1" then
					local tempTreasure = nil
			        if self.isMuilt then
			            local curTreaData = TeamFormationMultiModel:getCurTreaByIdx(1)
			            tempTreasure = FuncTreasureNew.getTreasureDataById(curTreaData.id)
			        else    
			            tempTreasure = FuncTreasureNew.getTreasureDataById(TeamFormationModel:getCurTreaByIdx(1))
			        end
			        local nowWuXingData = FuncTeamFormation.getWuXingDataById()
			        local name = UserModel:name()
			        if v.partner.rid ~= UserModel:rid() then
			        	name = mateInfo.name
			        end
			        view.txt_name:setString(name..":")
			        if tonumber(v.element.elementId) == tonumber(tempTreasure.wuling) then			        	
						view.txt_1:setString(self.wulingDes[tonumber(v.element.elementId)])
						view.txt_2:setString(wulingType.."+"..firstProperty.."%")
						view.txt_3:setString(self.des)
						view.txt_4:setString(xianshuDengji.."+"..secondProperty)
					else
						view.txt_1:setString(self.wulingDes[tonumber(v.element.elementId)])
						view.txt_2:setString(wulingType.."+"..firstProperty.."%")
						view.txt_3:setString("")
						view.txt_4:setString("")
					end
					self.panel_qixiaxiangqing:addChild(view)
					view:pos(20, -65 * tempRatio - 15)
					tempRatio = tempRatio + 1
				else
					if FuncWonderland.isWonderLandNpc(partnerId) or FuncTower.isConfigEmployee(tostring(partnerId)) then
						local staticNpcInfo = ObjectCommon.getPrototypeData("level.EnemyInfo", partnerId)
						local partnerName = FuncTranslate._getLanguage(staticNpcInfo.name)
						view.txt_name:setString(partnerName..":")
						view.txt_1:setString(self.wulingDes[tonumber(v.element.elementId)])
						view.txt_2:setString(wulingType.."+"..firstProperty.."%")
						view.txt_3:setString("")
						view.txt_4:setString("")
					else
						local partnerData = FuncPartner.getPartnerById(partnerId)
						local partnerName = FuncPartner.getPartnerName(partnerId)
						view.txt_name:setString(partnerName..":")
						if tonumber(v.element.elementId) == tonumber(partnerData.elements) then
							view.txt_1:setString(self.wulingDes[tonumber(v.element.elementId)])
							view.txt_2:setString(wulingType.."+"..firstProperty.."%")
							view.txt_3:setString(self.des)
							view.txt_4:setString(xianshuDengji.."+"..secondProperty)
						else
							view.txt_1:setString(self.wulingDes[tonumber(v.element.elementId)])
							view.txt_2:setString(wulingType.."+"..firstProperty.."%")
							view.txt_3:setString("")
							view.txt_4:setString("")
						end
					end
					self.panel_qixiaxiangqing:addChild(view)
					view:pos(20, -65 * tempRatio - 15)
					tempRatio = tempRatio + 1
				end
			end	

		end
	end
	if tempRatio == 0 then
		local view = UIBaseDef:cloneOneView(self.panel_qixiaxiangqing.panel_1)
		self.panel_qixiaxiangqing:addChild(view)
		view.txt_name:setString(GameConfig.getLanguage("#tid_wuxing_002"))
		view.txt_1:setString("")
		view.txt_2:setString("")
		view.txt_3:setString("")
		view.txt_4:setString("")
	end
end

function WuXingNowDetailTips:deleteMe()
	-- TODO

	WuXingNowDetailTips.super.deleteMe(self);
end

return WuXingNowDetailTips;
