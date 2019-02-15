--[[
	Author: lxh
	Date:2018-05-02
	Description: 排行榜主界面
]]

local RankListMainView = class("RankListMainView", UIBase);

function RankListMainView:ctor(winName)
    RankListMainView.super.ctor(self, winName)
    self.RankListLocalTag = UserModel:rid().."_OpenRankListTime"
	self.RankListRefreshCd = FuncDataSetting.getDataByConstantName("RankListRefreshCd")
	
    self.maxIntervalNum = FuncDataSetting.getDataByConstantName("RankListRefresh")
    self.beginRank = 1
	self.endRank = self.maxIntervalNum
	self.maxRankDisplayNum = FuncDataSetting.getDataByConstantName("RankListDisplay")
	self.rankListNumMax = FuncDataSetting.getDataByConstantName("RankListNumMax")
	local curTime = TimeControler:getServerTime()
	local lastOpenRankListTime = LS:prv():get(self.RankListLocalTag)
	LS:prv():set(self.RankListLocalTag, curTime)
	if lastOpenRankListTime then
		if curTime > lastOpenRankListTime + self.RankListRefreshCd then
			RankListModel:clearCacheRankListData()
			RankListModel:clearCacheRankListDataForSelf()
		end
	end

	self.winNames = {
		[1] = "RankListAbilityInfoView",
		[2] = "RankListPartnerInfoView",
		[3] = "RankListAbilityInfoView",
		[4] = "RankListAbilityInfoView",
		[5] = "RankListArtifactInfoView",
		[6] = "RankListTreasureInfoView",
		[7] = "RankListGuildInfoView",
	}
end

function RankListMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
end 

function RankListMainView:registerEvent()
	RankListMainView.super.registerEvent(self);

	self.tag_panel = self.panel_Rui.panel_1

	self.btn_back:setTouchedFunc(c_func(self.startHide, self))
	for i = 1, #RankListModel.rankTabsKeys, 1 do
		self.tag_panel["mc_"..i]:setTouchedFunc(c_func(self.changedTagType, self, i))
	end

	self.tag_panel.mc_8:setVisible(false)
end

function RankListMainView:changedTagType(_tagType)
	if not self.isUpdateEnd then
		return
	end

	if self.curSelectTag == _tagType then
		return
	else
		-- self:disabledUIClick()
		RankListModel:clearCachePlayerInfo()
		self.needScrollTop = true
		self.scrollTag = nil
		local _begainAndEnd = RankListModel:getCacheScrollParamsByType(_tagType)
		if _begainAndEnd then
			self.beginRank = _begainAndEnd.rank
			self.endRank = _begainAndEnd.rankEnd
		else
			self.beginRank = 1
			self.endRank = self.maxIntervalNum
		end

		self.clickTagType = _tagType
		self.tag_panel["mc_"..self.curSelectTag]:showFrame(1)
		self.tag_panel["mc_".._tagType]:showFrame(2)
		local tagKey = RankListModel.rankTabsKeys[_tagType]
		self.curRankListType = RankListModel.rankListType[tagKey]
		--请求数据后再加载排行榜界面
		self.curRankList = RankListModel:getCacheRankListDataByType(_tagType)
		if not self.curRankList then
			RankServer:getRankList(self.curRankListType, self.beginRank, self.endRank, c_func(self.getRankListCallBack, self))
		else
			self:updateUI(self.curRankList, _tagType)
		end
	end
end

function RankListMainView:initData()
	self:createSrollCfg()
	
	self.listScroll = self.panel_2.scroll_1
	self.isUpdateEnd = false
	self.curSelectTag = RankListModel:getCurrentSelectTag()
	local tagKey = RankListModel.rankTabsKeys[self.curSelectTag]
	self.curRankListType = RankListModel.rankListType[tagKey]
	--请求数据后再加载排行榜界面
	self.curRankList = RankListModel:getCacheRankListDataByType(self.curSelectTag)
	if not self.curRankList then
		RankServer:getRankList(self.curRankListType, self.beginRank, self.endRank, c_func(self.getRankListCallBack, self))
	else
		self:updateUI(self.curRankList, self.curSelectTag)
	end
end

function RankListMainView:getServeData(rank, endRank)
	RankServer:getRankList(self.curRankListType, rank, endRank, c_func(self.getRankListCallBack, self))
end

function RankListMainView:getRankListCallBack(event)
	if event.result then
		if self.clickTagType then
			self.curSelectTag = self.clickTagType
		end
		local curRankList = event.result.data
		if self.scrollTag and table.length(curRankList.list) ~= 0 then
			self.beginRank = #self.data + 1
			self.endRank = #self.data + self.maxIntervalNum
			RankListModel:cacheScrollParamsByType(self.curSelectTag, {rank = self.beginRank,
		                									  		  rankEnd = self.endRank})
		end
		local handledRankList = {}
		for k,v in pairs(curRankList.list) do
			v.rid = tostring(k)
			handledRankList[tostring(v.rank)] = v
		end
		curRankList.list = handledRankList

		if self.curRankList then
			curRankList = self:mergeRankListData(self.curRankList, curRankList)
		end
		RankListModel:cacheRankListDataByType(self.curSelectTag, curRankList)
		self.curRankList = curRankList
		self:updateUI(self.curRankList, self.curSelectTag)		
	else
		echoError("返回排行数据错误， 类型为", self.curSelectTag)
	end
end

function RankListMainView:initView()
	self.tag_panel["mc_"..self.curSelectTag]:showFrame(2)
	self:delayCall(function () self.isUpdateEnd = true end, 0.5)
end

function RankListMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_back, UIAlignTypes.RightTop)
end

function RankListMainView:updateUI(curRankList, _tagType)
	if _tagType then
		self.curSelectTag = _tagType
	end
	-- dump(curRankList, "\n\ncurRankList=====")
	self.panel_2.mc_3:showFrame(self.curSelectTag)

	local dataForSelf = RankListModel:getCacheRankListDataForSelfByType(self.curSelectTag)
	if not dataForSelf then
		--构造自己的数据并加载下方自身view
		dataForSelf = {
			rank = curRankList.rank or 0,
			score = curRankList.score or 0,
			head = UserModel:head(),
			frame = UserModel:frame(),
			avatar = UserModel:avatar(),
			level = UserModel:level(),
			name = UserModel:name(),
			rid = UserModel:rid(),
			isSelf = true,
			partnerId = curRankList.partnerId,
		}
		
		if self.curSelectTag == RankListModel.rankTabsType.RANK_TYPE_GUILD then
			local myGuild = curRankList.myGuild	
			if UserModel:guildId() and UserModel:guildId() ~= "" then
				dataForSelf.rid = UserModel:guildId()
				dataForSelf.name = myGuild.name
				dataForSelf.afterName = myGuild.afterName
				dataForSelf.logo = myGuild.logo
				dataForSelf.color = myGuild.color
				dataForSelf.icon = myGuild.icon
			end		
		end
		RankListModel:setCacheRankListDataForSelfByType(self.curSelectTag, dataForSelf)
	end
	
	self:updateItemView(self.panel_2.panel_4, dataForSelf)

	local list = curRankList.list
	self.data = {}
	--构造滚动条参数的数据 并根据排名排序
	for k,v in pairs(list) do
		table.insert(self.data, v)
	end

	local sortFunc = function (a, b)
		return a.rank < b.rank
	end
	table.sort(self.data, sortFunc)
	self.listLength = #self.data

	self.scrollParams[1].data = self.data
	-- self.listScroll:cancleCacheView()
	self.listScroll:styleFill(self.scrollParams)
	-- self.listScroll:refreshCellView(1)
	if self.needScrollTop then
		self.listScroll:gotoTargetPos(1, 1, 0, 0)
		self.needScrollTop = false
	end
	
	self.listScroll:hideDragBar()
	self.listScroll:onScroll(c_func(self.onMoveScrollListEnd, self))
	
	--加载左侧立绘及信息
	self:updateLeftFirstView(curRankList.first)
	
	RankListModel:setCurrentSelectTag(self.curSelectTag)
end

function RankListMainView:mergeRankListData(_oldData, _newData)
	local rankList = {}
	rankList.first = _oldData.first
	rankList.rank = _newData.rank
	rankList.score = _newData.score
	rankList.list = _oldData.list
	for k,v in pairs(_newData.list) do
		rankList.list[tostring(k)] = v
	end
	return rankList
end

function RankListMainView:updateLeftFirstView(firstData)
	if not firstData or not firstData._id then
		self.mc_1:showFrame(2)
	else
		self.mc_1:showFrame(1)
		local panel_first = self.mc_1.currentView.panel_1
		panel_first.ctn_1:removeAllChildren()
		--根据avatar和garmentId获取spine
		local avatar = firstData.avatar
		local garmentId = ""
		if firstData.userExt and firstData.userExt.garmentId then
			garmentId = firstData.userExt.garmentId
		end
		local spine = FuncGarment.getSpineViewByAvatarAndGarmentId(avatar, garmentId)
		spine:setScale(1.5)
		panel_first.ctn_1:addChild(spine)

		--如果是仙盟的排行 则显示第二帧
		if self.curSelectTag ~= RankListModel.rankTabsType.RANK_TYPE_GUILD then
			panel_first.mc_1:showFrame(1)
		else
			panel_first.mc_1:showFrame(2)
		end

		local panel_info = panel_first.mc_1.currentView
		panel_info.txt_1:setString(firstData.name)
		panel_info.txt_3:setString(firstData.level)
		--如果玩家没有仙盟则隐藏仙盟相关显示
		if firstData.guildName then
			panel_info.panel_guild:setVisible(true)
			panel_info.panel_guild.txt_4:setString(firstData.guildName)
		else
			panel_info.panel_guild:setVisible(false)
		end
	end
end

function RankListMainView:createSrollCfg()
	self.panel_2.panel_2:setVisible(false)

	local createCellFunc = function (_itemData)
		local view = UIBaseDef:cloneOneView(self.panel_2.panel_2)
		self:updateItemView(view, _itemData)
		return view
	end

	local reuseCellFunc = function (_itemData, view)
		self:updateItemView(view, _itemData)
	end

	self.scrollParams = {
		{
			data = {},
			createFunc = createCellFunc,
			updateCellFunc = reuseCellFunc,
			offsetX = 25,
			offsetY = -2,
			widthGap = 0,
			heightGap = 0,
			perFrame = 1,
			perNums = 1,
			itemRect = {x = 0, y = 330, width = 682, height = 58},
		}
	}
end

function RankListMainView:onMoveScrollListEnd(event)
    -- dump(event,"滚动监听事件")
    if event.name == "scrollEnd" then
    	if #self.data < self.rankListNumMax then
	    	local groupIndex, posIndex = self.listScroll:getGroupPos(2)
	        if groupIndex == 1 then 
	        	if math.fmod(#self.data, self.maxIntervalNum) == 0  then  
	        		local rank = self.beginRank + self.maxIntervalNum
	        		local rankEnd = self.endRank + self.maxIntervalNum
	        		if rankEnd >= self.rankListNumMax then
	        			rankEnd = self.rankListNumMax 
	        		end
	        		if rank >= self.rankListNumMax then
	        			rank = self.beginRank
	        		end
		            if posIndex == #self.data then
		                self.scrollTag = true
						self:getServeData(rank, rankEnd)
		            end
		        end
	        end
	    end
    elseif event.name == "moved" then

    end
end

--加载滚动条cell
function RankListMainView:updateItemView(_view, _itemData)
	-- echo("\n\nupdateItemView=====", self.curSelectTag)
	_view.mc_2:showFrame(self.curSelectTag)
	local curView = _view.mc_2.currentView
	if _itemData.isSelf then
		_view.mc_1:showFrame(3)
		curView.panel_ziji:setVisible(true)
	else
		_view.mc_1:showFrame(1)
		curView.panel_ziji:setVisible(false)
	end
	
	local isNotInRank = false
	if _itemData.rank and _itemData.rank > 0 then
		if _itemData.rank < 4 then
			curView.mc_1:showFrame(_itemData.rank)
		elseif _itemData.rank <= self.maxRankDisplayNum then
			curView.mc_1:showFrame(4)
			curView.mc_1.currentView.txt_1:setString(_itemData.rank)
		else
			curView.mc_1:showFrame(5)
		end
	else
		curView.mc_1:showFrame(5)
	end
	
	if self.curSelectTag == RankListModel.rankTabsType.RANK_TYPE_GUILD then
		if _itemData.rank > 0 then
			local guildLevel = math.floor(_itemData.score / 1000)
			local buildingLevel = _itemData.score % 1000
			curView.txt_qu:setString(guildLevel)
			curView.txt_3:setString(buildingLevel)
			local iconData = {
				borderId = _itemData.logo,
				bgId = _itemData.color,
				iconId = _itemData.icon,
			}
			curView.UI_1:initData(iconData)
			local afterName = FuncGuild.guildNameType[tonumber(_itemData.afterName)]
			curView.txt_name:setString(_itemData.name..afterName)
			curView.txt_qu:setVisible(true)
			curView.txt_3:setVisible(true)
			curView.UI_1:setVisible(true)
		else
			curView.txt_qu:setVisible(false)
			curView.txt_3:setVisible(false)
			curView.UI_1:setVisible(false)
			curView.txt_name:setString(GameConfig.getLanguage("#tid_chat_005"))			
		end
		

		-- if _itemData.rid == UserModel:guildId() then
		-- 	curView.panel_ziji:setVisible(true)
		-- else
		-- 	curView.panel_ziji:setVisible(false)
		-- end
	else
		curView.txt_name:setString(_itemData.name)
		local rid_string = string.split(_itemData.rid, ":")
		-- if tostring(rid_string[1]) == UserModel:rid() then
		-- 	curView.panel_ziji:setVisible(true)
		-- else
		-- 	curView.panel_ziji:setVisible(false)
		-- end

		if self.curSelectTag == RankListModel.rankTabsType.RANK_TYPE_ABILITY
			or self.curSelectTag == RankListModel.rankTabsType.RANK_TYPE_CIMELIA 
			or self.curSelectTag == RankListModel.rankTabsType.RANK_TYPE_TREASURE then

			if self.curSelectTag == RankListModel.rankTabsType.RANK_TYPE_TREASURE
				and _itemData.isSelf and _itemData.rank == 0 then
				_itemData.score = TreasureNewModel:getAllTreasStarAbility()
			end
			curView.txt_lv:setString(_itemData.score)			
			curView.UI_3:updateUI(_itemData.avatar, _itemData.head, _itemData.frame, _itemData.level)
		elseif self.curSelectTag == RankListModel.rankTabsType.RANK_TYPE_PARTNER then
			if _itemData.partnerId then
				_itemData.partners = PartnerModel:getPartnerDataById(_itemData.partnerId)
			else
				if not rid_string[2] then
					_itemData.partners = PartnerModel:getMaxAbilityPartnerData()
				end
			end
			
			local partnerData = _itemData.partners
			curView.panel_lv.txt_1:setString(partnerData.level)
			curView.UI_1:updataUIByPartnerData(partnerData)
			curView.txt_lv:setString(_itemData.score)
		elseif self.curSelectTag == RankListModel.rankTabsType.RANK_TYPE_PARTNER_COUNT then
			local partnerCount = math.floor(_itemData.score / 1000)
			local partnerStar = _itemData.score % 1000
			curView.txt_qu:setString(partnerCount)
			curView.txt_3:setString(partnerStar)
		elseif self.curSelectTag == RankListModel.rankTabsType.RANK_TYPE_PARTNER_AWAKE then
			local partnerAwakeCount = math.floor(_itemData.score / 1000)
			local equipmentAwakeCount = _itemData.score % 1000
			curView.txt_qu:setString(partnerAwakeCount)
			curView.txt_3:setString(equipmentAwakeCount)	
		end
		
	end

	if _itemData.rank and _itemData.rank > 0 and
		self.curSelectTag ~= RankListModel.rankTabsType.RANK_TYPE_PARTNER_AWAKE and
		 self.curSelectTag ~= RankListModel.rankTabsType.RANK_TYPE_PARTNER_COUNT then
		_view:setTouchedFunc(c_func(self.clickOneCell, self, self.curSelectTag, _itemData))
	else
		_view:setTouchedFunc(c_func(function () end))
	end
end


function RankListMainView:clickOneCell(_curSelectTag, _itemData)
	self:updateDetailViewLogic(_curSelectTag, _itemData)
end

function RankListMainView:updateDetailViewLogic(_curSelectTag, _itemData)
	local rid = _itemData.rid
	if _curSelectTag == RankListModel.rankTabsType.RANK_TYPE_PARTNER then
		local rid_string = string.split(_itemData.rid, ":")
		rid = tostring(rid_string[1])
	end

	local winName = self.winNames[_curSelectTag]
	local _playerInfo = RankListModel:getCachePlayerInfoByRid(rid)
	if not _playerInfo then
		if _curSelectTag == RankListModel.rankTabsType.RANK_TYPE_GUILD then
			RankServer:getGuildInfo(rid, function (event)
					if event.result then
						_playerInfo = event.result.data.guild
						RankListModel:cachePlayerInfoByRid(_itemData.rid, _playerInfo)
						WindowControler:showWindow(winName, _curSelectTag, _itemData, _playerInfo)
					else
						echoError("获取玩家信息返回数据报错")
						return
					end
				end)
		else
			RankServer:getPlayInfo(rid, function (event)
					if event.result then
						_playerInfo = event.result.data.data
						RankListModel:cachePlayerInfoByRid(_itemData.rid, _playerInfo)
						WindowControler:showWindow(winName, _curSelectTag, _itemData, _playerInfo)
					else
						echoError("获取玩家信息返回数据报错")
						return
					end
				end)
		end
		
	else
		WindowControler:showWindow(winName, _curSelectTag, _itemData, _playerInfo)
	end
end

function RankListMainView:deleteMe()
	-- TODO
	RankListMainView.super.deleteMe(self);
	RankListModel:clearCachePlayerInfo()
	RankListModel:clearCacheScrollParams()
end

return RankListMainView;
