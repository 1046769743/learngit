--[[
	Author: lxh
	Date:2018-05-02
	Description: 排行榜中法宝排行信息查看界面
]]

local RankListTreasureInfoView = class("RankListTreasureInfoView", UIBase);

function RankListTreasureInfoView:ctor(winName, _curSelectTag, _itemData, _playerInfo)
    RankListTreasureInfoView.super.ctor(self, winName)
    self.itemData = _itemData
    self.rankTagType = _curSelectTag
    self._playerInfo = _playerInfo
end

function RankListTreasureInfoView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI(self._playerInfo)
end 

function RankListTreasureInfoView:registerEvent()
	RankListTreasureInfoView.super.registerEvent(self);

	self.panel_bg.btn_close:setTouchedFunc(c_func(self.startHide, self))
	self:registClickClose("out")
end

function RankListTreasureInfoView:initData()
	self.panel_2:setVisible(false)
	self.panel_3:setVisible(false)
	-- local playerInfo = RankListModel:getCachePlayerInfoByRid(self.itemData.rid)
	-- if playerInfo then
	-- 	self:updateUI(playerInfo)
	-- else
	-- 	RankServer:getPlayInfo(self.itemData.rid, c_func(self.getPlayerInfoCallBack, self))
	-- end	
end

function RankListTreasureInfoView:getPlayerInfoCallBack(event)
	if event.result then
		local _playerInfo = event.result.data.data
		RankListModel:cachePlayerInfoByRid(self.itemData.rid, _playerInfo)
		self:updateUI(_playerInfo)
	else
		echoError("获取玩家主线阵容信息返回数据报错")
	end
end

function RankListTreasureInfoView:initView()
	self.panel_bg.txt_1:setString(GameConfig.getLanguage("#tid_ranklisttitle_1005"))
end

function RankListTreasureInfoView:initViewAlign()
	-- TODO
end

function RankListTreasureInfoView:updateUI(_playerInfo)
	self.panel_2.UI_1:updateUI(self.itemData.avatar, self.itemData.head, self.itemData.frame, self.itemData.level)
	self.panel_2.txt_playername:setString(self.itemData.name)
	self.panel_2.txt_playerpaimingnumber:setString(self.itemData.rank)
	self.panel_2.panel_power.UI_1:setPower(self.itemData.score)

	self.panel_2:setVisible(true)
	self._playerInfo = _playerInfo
	self:updateTreasureInfoView()
end

function RankListTreasureInfoView:updateTreasureInfoView()
	self.treasures_show = {}
	for k,v in pairs(self._playerInfo.treasures) do
		local treasureCfg = FuncTreasureNew.getTreasureDataById(v.id)
		v.aptitude = treasureCfg.aptitude
		table.insert(self.treasures_show, v)
	end

	table.sort(self.treasures_show, function (a, b)
			if a.aptitude > b.aptitude then
				return true
			elseif a.aptitude < b.aptitude then
				return false
			end

			if a.star > b.star then
				return true
			else
				return false
			end
		end)

	self:updateTreasureScrollView()
end

function RankListTreasureInfoView:updateTreasureScrollView()
	local createCellFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_3)
		self:updateItemView(view, itemData)
		return view
	end

	local reuseCellFunc = function (view, itemData)
		self:updateItemView(view, itemData)
	end

	local scrollParams = {
		{
			data = self.treasures_show,
			createFunc = createCellFunc,
			updateCellFunc = reuseCellFunc,
			offsetX = 55,
			offsetY = 25,
			widthGap = 30,
			heightGap = 10,
			perFrame = 1,
			perNums = 4,
			itemRect = {x = 0, y = -102, width = 102, height = 102},
		}
	}

	self.scroll_1:styleFill(scrollParams)
	self.scroll_1:hideDragBar()
end

function RankListTreasureInfoView:updateItemView(_view, _itemData)
	local treasureId = _itemData.id
	local colorFrame = FuncTreasureNew.getKuangColorFrame(treasureId)
	-- local treasureSpine = FuncTreasureNew.getTreasLihui(treasureId)
	local iconPath = FuncRes.iconTreasureNew(treasureId)
    local treasureIcon = display.newSprite(iconPath)
	_view.mc_1:showFrame(_itemData.star)
	_view.mc_2:showFrame(colorFrame)
	_view.mc_2.currentView.ctn_1:removeAllChildren()
	_view.mc_2.currentView.ctn_1:addChild(treasureIcon)
	-- treasureSpine:setScale(0.35)
	-- treasureSpine:pos(2, -5)

	_view:setTouchedFunc(c_func(self.clickOneTreasureCellView, self, _itemData))
end

function RankListTreasureInfoView:clickOneTreasureCellView(_itemData)
	WindowControler:showWindow("RankListTreasureDetailView", _itemData, self._playerInfo)
end

function RankListTreasureInfoView:deleteMe()
	-- TODO

	RankListTreasureInfoView.super.deleteMe(self);
end

return RankListTreasureInfoView;
