--[[
	Author: lxh
	Date:2018-05-02
	Description: 排行榜中战力排行详情查看界面
]]

local RankListAbilityInfoView = class("RankListAbilityInfoView", UIBase);

function RankListAbilityInfoView:ctor(winName, _curSelectTag, _itemData, _playerInfo)
    RankListAbilityInfoView.super.ctor(self, winName)
    self.itemData = _itemData
    self.rankTagType = _curSelectTag
    self.playerInfo = _playerInfo
end

function RankListAbilityInfoView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI(self.playerInfo)
end 

function RankListAbilityInfoView:registerEvent()
	RankListAbilityInfoView.super.registerEvent(self);

	self.panel_bg.btn_close:setTouchedFunc(c_func(self.startHide, self))
	self:registClickClose("out")
end

function RankListAbilityInfoView:initData()
	-- self.panel_2:setVisible(false)
	-- self.panel_3:setVisible(false)
		
end

function RankListAbilityInfoView:initView()
	self.panel_bg.txt_1:setString(GameConfig.getLanguage("#tid_ranklisttitle_1001"))
end

function RankListAbilityInfoView:initViewAlign()
	-- TODO
end


function RankListAbilityInfoView:getPlayerInfoCallBack(event)
	if event.result then
		local _playerInfo = event.result.data.data
		RankListModel:cachePlayerInfoByRid(self.itemData.rid, _playerInfo)
		self:updateUI(_playerInfo)
	else
		echoError("获取玩家主线阵容信息返回数据报错")
	end
end

function RankListAbilityInfoView:updateUI(_playerInfo)
	self.panel_2.UI_1:updateUI(_playerInfo.avatar, _playerInfo.head, _playerInfo.frame, _playerInfo.level)
	if self.rankTagType == RankListModel.rankTabsType.RANK_TYPE_ABILITY then
		self.panel_2.mc_1:showFrame(1)
		if self.itemData.score then		
			self.panel_2.mc_1.currentView.panel_1.UI_1:setPower(self.itemData.score)
		else
			if _playerInfo.abilityNew and _playerInfo.abilityNew.formationTotal then
				self.panel_2.mc_1.currentView.panel_1.UI_1:setPower(_playerInfo.abilityNew.formationTotal)
			end
		end	
	else
		local count1 = math.floor(self.itemData.score / 1000)
		local tatolCount = self.itemData.score % 1000
		if self.rankTagType == RankListModel.rankTabsType.RANK_TYPE_PARTNER_COUNT then
			self.panel_2.mc_1:showFrame(2)
			self.panel_2.mc_1.currentView.txt_huanxingqixaishunumber:setString(count1)
			self.panel_2.mc_1.currentView.txt_qixaizongxingshunumber:setString(tatolCount)
		elseif self.rankTagType == RankListModel.rankTabsType.RANK_TYPE_PARTNER_AWAKE then
			self.panel_2.mc_1:showFrame(3)
			self.panel_2.mc_1.currentView.txt_juexingqixiashunumber:setString(count1)
			self.panel_2.mc_1.currentView.txt_zhuangbeijuexingshunumber:setString(tatolCount)
		end
	end
	self.panel_2.mc_1.currentView.txt_playername:setString(_playerInfo.name)
	if not self.itemData.rank then
		if _playerInfo.level then
			self.panel_2.UI_1.panel_1:visible(false)
			local str = GameConfig.getLanguageWithSwap("#tid_head_004", _playerInfo.level)
			self.panel_2.mc_1.currentView.txt_playerpaiming:setString(str)
			self.panel_2.mc_1.currentView.txt_playerpaimingnumber:visible(false)
		else
			self.panel_2.mc_1.currentView.txt_playerpaimingnumber:visible(false)
			self.panel_2.mc_1.currentView.txt_playerpaiming:visible(false)
		end
	else
		if self.itemData.rank == 0 then
			self.panel_2.mc_1.currentView.txt_playerpaimingnumber:setString("未上榜")
		else
			self.panel_2.mc_1.currentView.txt_playerpaimingnumber:setString(self.itemData.rank)
		end
	end
	

	-- self.panel_2:setVisible(true)
	self:updateFormationInfo(_playerInfo)
end

function RankListAbilityInfoView:updateFormationInfo(_playerInfo)
	local partnersData = _playerInfo.partners or {}
	local treasureFormation = _playerInfo.treasureFormation
	--加载主线阵容 奇侠
	local index = 1
	local charData = {
		id = _playerInfo.avatar or "101",
		level = _playerInfo.level or 1,
		quality = _playerInfo.quality or 1,
		star = _playerInfo.star or 1,
		isChar = true,
	}

	if _playerInfo.userExt and _playerInfo.userExt.garmentId then
		charData.skin = _playerInfo.userExt.garmentId
	else
		charData.skin = ""
	end

	self.panel_3["UI_"..index]:updataUIByPartnerData(charData)
	self.panel_3["UI_"..index]:setTouchedFunc(c_func(self.clickOnePartnerView, self, charData, _playerInfo))

	for k,v in pairs(partnersData) do
		index = index + 1
		local partnerId = tostring(k)
		if self.panel_3["UI_"..index] then
			local partnerData = partnersData[tostring(partnerId)]
			self.panel_3["UI_"..index]:updataUIByPartnerData(partnerData)
			local itemData = {}
			itemData.partners = partnerData
			self.panel_3["UI_"..index]:setTouchedFunc(c_func(self.clickOnePartnerView, self, itemData, _playerInfo))
		end		
	end

	for i = 1, 6, 1 do
		if i > index then
			self.panel_3["UI_"..i]:setVisible(false)
		else
			self.panel_3["UI_"..i]:setVisible(true)
		end		
	end

	--加载主线阵容 法宝
	local treasureId = "404"
	if treasureFormation then
		treasureId = tostring(treasureFormation["p1"])
	end

	local treasureData = _playerInfo.treasures[treasureId]
	if not treasureData then
		return
	end
	-- local _iconPath = FuncRes.iconTreasureNew(treasureData.id)
    local _iconSprite = FuncTreasureNew.getTreasLihui(treasureId)
    _iconSprite:setScale(0.6)
    self.panel_3.panel_1.ctn_1:removeAllChildren()
    self.panel_3.panel_1.ctn_1:addChild(_iconSprite)
    self.panel_3.panel_1.mc_1:showFrame(treasureData.star)
    -- _iconSprite:setScale(0.9)
    _iconSprite:pos(0, 5)
    self.panel_3.panel_1:setTouchedFunc(c_func(self.clickTreasureView, self, treasureData, _playerInfo))
	-- self.panel_3:setVisible(true)
end

function RankListAbilityInfoView:clickOnePartnerView(_itemData, _playerInfo)
	WindowControler:showWindow("RankListPartnerInfoView", self.rankTagType, _itemData, _playerInfo)
end

function RankListAbilityInfoView:clickTreasureView(treasureData, _playerInfo)
	WindowControler:showWindow("RankListTreasureDetailView", treasureData, _playerInfo)
end

function RankListAbilityInfoView:deleteMe()
	-- TODO

	RankListAbilityInfoView.super.deleteMe(self);
end

return RankListAbilityInfoView;
