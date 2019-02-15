--[[
	Author: lxh
	Date:2018-05-02
	Description: 排行榜中神器排行信息查看界面
]]

local RankListArtifactInfoView = class("RankListArtifactInfoView", UIBase);

function RankListArtifactInfoView:ctor(winName, _curSelectTag, _itemData, _playerInfo)
    RankListArtifactInfoView.super.ctor(self, winName)
    self.itemData = _itemData
    self.rankTagType = _curSelectTag
    self._playerInfo = _playerInfo
end

function RankListArtifactInfoView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI(self._playerInfo)
end 

function RankListArtifactInfoView:registerEvent()
	RankListArtifactInfoView.super.registerEvent(self);

	self.panel_bg.btn_close:setTouchedFunc(c_func(self.startHide, self))
	self:registClickClose("out")
end

function RankListArtifactInfoView:initData()
	self.panel_2:setVisible(false)
	self.panel_3:setVisible(false)
	self.allArtifactData = table.deepCopy(FuncArtifact.getAllcimeliaCombine())

	-- local playerInfo = RankListModel:getCachePlayerInfoByRid(self.itemData.rid)
	-- if playerInfo then
	-- 	self:updateUI(playerInfo)
	-- else	
	-- 	RankServer:getPlayInfo(self.itemData.rid, c_func(self.getPlayerInfoCallBack, self))
	-- end
end

function RankListArtifactInfoView:getPlayerInfoCallBack(event)
	if event.result then
		local _playerInfo = event.result.data.data
		RankListModel:cachePlayerInfoByRid(self.itemData.rid, _playerInfo)
		self:updateUI(_playerInfo)
	else
		echoError("获取玩家主线阵容信息返回数据报错")
	end
end

function RankListArtifactInfoView:initView()
	self.panel_bg.txt_1:setString(GameConfig.getLanguage("#tid_ranklisttitle_1003"))
end

function RankListArtifactInfoView:initViewAlign()
	-- TODO
end

function RankListArtifactInfoView:updateUI(_playerInfo)
	self.panel_2.UI_1:updateUI(self.itemData.avatar, self.itemData.head, self.itemData.frame, self.itemData.level)
	self.panel_2.txt_playername:setString(self.itemData.name)
	self.panel_2.txt_playerpaimingnumber:setString(self.itemData.rank)
	self.panel_2.panel_power.UI_1:setPower(self.itemData.score)
	
	self.panel_2:setVisible(true)
	local artifactData = _playerInfo.cimeliaGroups
	self:updateArtifactInfoView(artifactData)
end

function RankListArtifactInfoView:updateArtifactInfoView(_artifactData)
	--神器数据处理
	self.artifactData_show = {}
	for k,v in pairs(_artifactData) do
		if self.allArtifactData[tostring(k)] then
			self.allArtifactData[tostring(k)].qualityData = v
		end
	end

	for k,v in pairs(self.allArtifactData) do
		table.insert(self.artifactData_show, v)
	end

	table.sort(self.artifactData_show, function (a, b)
			if tonumber(a.combineColor) > tonumber(b.combineColor) then
				return true
			elseif tonumber(a.combineColor) < tonumber(b.combineColor) then
				return false
			end

			if tonumber(a.rank) > tonumber(b.rank) then
				return true
			else
				return false
			end
		end)

	self:updateArtifactScrollView()
end

function RankListArtifactInfoView:updateArtifactScrollView()
	local createCellFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_3)
		self:updateArtifactItemView(view, itemData)
		return view
	end

	local reuseCellFunc = function (itemData, view)
		self:updateArtifactItemView(view, itemData)
	end

	local scrollParams = {
		{
			data = self.artifactData_show,
			createFunc = createCellFunc,
			updateCellFunc = reuseCellFunc,
			offsetX = 13,
			offsetY = 20,
			widthGap = 10,
			heightGap = 8,
			perFrame = 1,
			perNums = 4,
			itemRect = {x = 0, y = -104, width = 122, height = 104},
		}
	}

	self.scroll_1:styleFill(scrollParams)
	self.scroll_1:hideDragBar()
end

function RankListArtifactInfoView:updateArtifactItemView(_view, _itemData)
	local icon =   FuncRes.iconCimelia(_itemData.combineicon) ---FuncRes.iconTalent( iconname)
	local spriteIcon = display.newSprite(icon)
	_view.ctn_1:removeAllChildren()
	-- spine:setScale(0.25)
	_view.ctn_1:addChild(spriteIcon)
	spriteIcon:setScale(0.9)
	_view.panel_c.mc_2:showFrame(_itemData.combineColor)
	_view.mc_1:showFrame(_itemData.combineColor - 1)
	if _itemData.qualityData and _itemData.qualityData.quality > 0 then
		local quality = _itemData.qualityData.quality
		_view.panel_c.mc_2.currentView.txt_1:setString("+"..quality)
		_view.panel_c:setVisible(true)
		FilterTools.clearFilter(spriteIcon)
	else
		_view.panel_c:setVisible(false)
		FilterTools.setGrayFilter(spriteIcon)
	end
	
	_view:setTouchedFunc(c_func(self.clickOneArtifactCell, self, _itemData))
end

function RankListArtifactInfoView:clickOneArtifactCell(_itemData)
	WindowControler:showWindow("RankListArtifactDetailView", _itemData)
end

function RankListArtifactInfoView:deleteMe()
	-- TODO

	RankListArtifactInfoView.super.deleteMe(self);
end

return RankListArtifactInfoView;
