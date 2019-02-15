--[[
	Author: TODO
	Date:2018-01-19
	Description: TODO
]]

local EndlessBossRankView = class("EndlessBossRankView", UIBase);

function EndlessBossRankView:ctor(winName, data)
    EndlessBossRankView.super.ctor(self, winName)
    self.data = data.list
    self.rank = data.rank
    self.endlessId = data.score
    self.score = data.score
end

function EndlessBossRankView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function EndlessBossRankView:registerEvent()
	EndlessBossRankView.super.registerEvent(self);
	self.panel_1.btn_back:setTouchedFunc(c_func(self.close, self))
	self:registClickClose("out")
	self.panel_1.mc_yeqian1:getViewByFrame(1).btn_baoxiang1:setTouchedFunc(c_func(self.changedTag, self, FuncEndless.RANK_TAG.ALL))
	self.panel_1.mc_yeqian1:getViewByFrame(2).btn_baoxiang2:setTouchedFunc(c_func(self.changedTag, self, FuncEndless.RANK_TAG.ALL))
	self.panel_1.mc_yeqian2:getViewByFrame(1).btn_baoxiang1:setTouchedFunc(c_func(self.changedTag, self, FuncEndless.RANK_TAG.GUILD))
	self.panel_1.mc_yeqian2:getViewByFrame(2).btn_baoxiang2:setTouchedFunc(c_func(self.changedTag, self, FuncEndless.RANK_TAG.GUILD))
	self.panel_1.mc_yeqian3:getViewByFrame(1).btn_quanbu1:setTouchedFunc(c_func(self.changedTag, self, FuncEndless.RANK_TAG.FRIEND))
	self.panel_1.mc_yeqian3:getViewByFrame(2).btn_quanbu2:setTouchedFunc(c_func(self.changedTag, self, FuncEndless.RANK_TAG.FRIEND))
end

function EndlessBossRankView:initData()
	self.friendAndGuildData = EndlessModel:getFriendAndGuildData()
	local sortFunc = function (a, b)
		if tonumber(a.rank) < tonumber(b.rank) then
			return true
		else
			return false
		end
	end

	local sortFunc1 = function (a, b)
		if tonumber(a.score) > tonumber(b.score) then
			return true
		elseif tonumber(a.score) < tonumber(b.score) then
			return false
		end

		if tonumber(a.endlessTime) < tonumber(b.endlessTime) then
			return true
		else
			return false
		end
	end
	--获取全服排行数据
	self.rankData = {}
	for k,v in pairs(self.data) do
		v.rid = k
		if v.score > 0 then
			table.insert(self.rankData, v)
		end		
	end

	table.sort(self.rankData, sortFunc)

	--获取好友排行数据
	self.friendRankData = {}
	local friendList = self.friendAndGuildData.friends or {}
	for k,v in pairs(friendList) do
		if v.userExt and v.userExt.endlessId and v.userExt.endlessId > 0 then
            local data = {}
            data.rid = v._id
            data.name = v.name
            data.avatar = v.avatar
            data.score = v.userExt.endlessId
            data.endlessTime = v.userExt.endlessTime
            table.insert(self.friendRankData, data)
        end
	end

	if UserExtModel:endlessId() > 0 then
		local self_data = {
			rid = UserModel:rid(),
			name = UserModel:name(),
			avatar = UserModel:avatar(),
			score = UserExtModel:endlessId(),
			endlessTime = UserExtModel:endlessTime(),
		}
		table.insert(self.friendRankData, self_data)
	end

	table.sort(self.friendRankData, sortFunc1)
	--给每一个数据加上rank字段
	for i,v in ipairs(self.friendRankData) do
		v.rank = i
	end

	--获取仙盟排行所有数据
	self.guildRankData = {}
	local guildList = self.friendAndGuildData.members or {}
	for k,v in pairs(guildList) do
        if v.endlessId and v.endlessId > 0 then
            local data = {}
            data.rid = k
            data.name = v.name
            data.avatar = v.avatar
            data.score = v.endlessId
            data.endlessTime = v.endlessTime
            table.insert(self.guildRankData, data)        
        end
    end

    table.sort(self.guildRankData, sortFunc1)
    --给每一个数据加上rank字段
	for i,v in ipairs(self.guildRankData) do
		v.rank = i
	end

	self.selectedTag = FuncEndless.RANK_TAG.ALL
	self.panel_1.mc_yeqian1:showFrame(2)
	self:updateRankData(self.selectedTag)
	self:updateScrollView()
	self:updateBottomPanel()
end

--对获取的排行数据进行排序
function EndlessBossRankView:updateRankData(_curTag)
	self.curRankData = {}
	if _curTag == FuncEndless.RANK_TAG.FRIEND then
		self.curRankData = self.friendRankData
	elseif _curTag == FuncEndless.RANK_TAG.GUILD then
		self.curRankData = self.guildRankData
	else
		self.curRankData = self.rankData
	end
end

function EndlessBossRankView:changedTag(_clickedTag)
	if self.selectedTag == _clickedTag then
		return
	end

	self.panel_1["mc_yeqian"..self.selectedTag]:showFrame(1)
	self.panel_1["mc_yeqian".._clickedTag]:showFrame(2)
	self.selectedTag = _clickedTag
	self:updateRankData(self.selectedTag)
	self:updateScrollView()
	self:updateBottomPanel()
end

function EndlessBossRankView:initView()
	-- TODO
end

function EndlessBossRankView:initViewAlign()
	-- TODO
end

function EndlessBossRankView:updateUI()
	-- TODO
end

function EndlessBossRankView:updateScrollView()

	local createCellFunc = function (rankData, index)
		local _view = UIBaseDef:cloneOneView(self.panel_1.panel_2)        		
		self:updateRankCellView(_view, rankData)
		return _view
	end

	local reuseUpdateCellFunc = function (rankData, view, index)       		
		self:updateRankCellView(view, rankData)
		return _view
	end

	self.params = {
		{
			data = self.curRankData,	        
	        createFunc = createCellFunc,
	        offsetX = 0,
	        offsetY = 35,
	        widthGap = 0,
	        heightGap = -2,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -100, width = 634, height = 62},
	        updateCellFunc = reuseUpdateCellFunc,
		}
	}

	self.panel_1.scroll_1:styleFill(self.params)
	self.panel_1.scroll_1:hideDragBar()
end

function EndlessBossRankView:updateRankCellView(_view, _rankData)
	if _rankData.rank < 4 then
		_view.mc_1:showFrame(_rankData.rank)
	else
		_view.mc_1:showFrame(4) 
		_view.mc_1.currentView.txt_1:setString(_rankData.rank)
	end

	local name = GameConfig.getLanguage("#tid_endless_tips_7")
	if _rankData.name then
		name = _rankData.name
	end
	_view.txt_name:setString(name)  

	local floor, section = FuncEndless.getFloorAndSectionById(_rankData.score)
	_view.txt_jifen:setString(string.format(GameConfig.getLanguage("#tid_endless_tips_6"), floor, section))

	if _rankData.rid == UserModel:rid() then
		_view.panel_ziji:setVisible(true)
	else
		_view.panel_ziji:setVisible(false)
	end
end

function EndlessBossRankView:updateBottomPanel()
	if self.selectedTag == FuncEndless.RANK_TAG.ALL then
		if self.rank then
			self.panel_1.panel_2:setVisible(true)
			local data = {
				rank = self.rank,
				name = UserModel:name(),
				score = self.score,
				rid = UserModel:rid()
			}
			local panel = self.panel_1.panel_2
			self:updateRankCellView(panel, data)
			self.panel_1.txt_2:setVisible(false)
		else
			self.panel_1.panel_2:setVisible(false)
			self.panel_1.txt_2:setVisible(true) 
			self.panel_1.txt_2:setString(GameConfig.getLanguage("#tid_endless_tips_8"))
		end
	else
		--是否显示下方panel
		local showBottomPanel = false
		for i,v in ipairs(self.curRankData) do
			if v.rid == UserModel:rid() then
				local panel = self.panel_1.panel_2
				self:updateRankCellView(panel, v)
				showBottomPanel = true
				break
			end
		end

		if showBottomPanel then
			self.panel_1.panel_2:setVisible(true)
			self.panel_1.txt_2:setVisible(false)
		else
			self.panel_1.panel_2:setVisible(false)
			self.panel_1.txt_2:setVisible(true)  
			if self.selectedTag == FuncEndless.RANK_TAG.GUILD and not GuildModel:isInGuild() then
				self.panel_1.txt_2:setString(GameConfig.getLanguage("#tid_endless_tips_9"))
			else
				self.panel_1.txt_2:setString(GameConfig.getLanguage("#tid_endless_tips_8"))
			end
		end
	end
end

function EndlessBossRankView:close()
	self:startHide()
end

function EndlessBossRankView:deleteMe()
	-- TODO

	EndlessBossRankView.super.deleteMe(self);
end

return EndlessBossRankView;
