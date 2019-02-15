--[[
	Author: lxh
	Date:2018-07-11
	Description: 幻境协战主界面
]]

local ShareBossNewMainView = class("ShareBossNewMainView", UIBase);

function ShareBossNewMainView:ctor(winName)
    ShareBossNewMainView.super.ctor(self, winName)

    self.maxCountEveryBoss = FuncDataSetting.getDataByConstantName("MaxShareBossAttackEveryBoss")
    self.maxCountEveryDay = FuncDataSetting.getDataByConstantName("MaxShareBossAttackEveryDay")
    self.maxShareBossRescue = FuncDataSetting.getDataByConstantName("MaxShareBossRescue")
    -- ShareBossModel:setCurrentGroup(1)
    self.switchEaseTime = 0.2
    ShareBossModel:setCurrentDetailData(nil)
    self.needShowTips = true
end

function ShareBossNewMainView:loadUIComplete()
	self:registerEvent()
	self:initViewAlign()
	self:initView()
	self:updateViewData()
end 

function ShareBossNewMainView:registerEvent()
	ShareBossNewMainView.super.registerEvent(self);

	self.btn_back:setTouchedFunc(c_func(self.startHide, self))
	self.btn_wen:setTouchedFunc(c_func(self.touchedRuleBtn, self))

	--当幻境数据发生变化时 需要刷新界面
	EventControler:addEventListener(ShareBossEvent.SHAREBOSS_DATA_CHANGED, self.shareBossDataChanged, self)
	--监听打开boss详情界面事件
	EventControler:addEventListener(ShareBossEvent.OPEN_ONE_DETAILVIEW, self.showBossDetailView, self)
	--监听隐藏boss详情界面事件
	EventControler:addEventListener(ShareBossEvent.HIDE_BOSS_DETAILVIEW, self.hideBossDetailView, self)
	--监听加入仙盟事件
	EventControler:addEventListener(GuildEvent.CLOSE_ADD_GUILD_VIEW_EVENT, self.updateViewForDataChanged, self)

	--点击左侧箭头切换到上一层
	self.btn_1:setTouchedFunc(c_func(self.switchToPreviousGroup, self))
	--点击右侧箭头切换到下一层
	self.btn_2:setTouchedFunc(c_func(self.switchToNextGroup, self))
end

function ShareBossNewMainView:updateViewForDataChanged()
	ShareBossModel:setAllBossDatas()
end

--弹出 规则界面
function ShareBossNewMainView:touchedRuleBtn()
	WindowControler:showWindow("ShareBossHelpView")
end

--刷新函数
function ShareBossNewMainView:updateFrame()
	if self.isStop then
		return
	end

	self.frameCount = self.frameCount + 1

	--每秒刷新一次  拿到滚动条上所有的view  然后取出每一个view中的数据 进行处理 
    if self.frameCount % (GameVars.GAMEFRAMERATE) == 0 then
    	local compViews = self.scroll_1:getAllView()
    	for i,v in ipairs(compViews) do
    		local bossViews = v.view:getBossViews()
    		if #bossViews > 0 then
    			local itemData = v.view:getBossDatas()
    			for ii,vv in ipairs(itemData) do
		        	if not vv.isDead then
				    	local leftTime = vv.expireTime - TimeControler:getServerTime()
				    	--如果有过期的幻境 则删掉对应的数据 并发送数据变化事件 更新界面	    	
				    	if leftTime <= 0 then
				    		self.isStop = true
				    		ShareBossModel:deleteExpireShareBossData(vv._id)
				    	else
				    		local view = bossViews[ii]
				    		local time = math.ceil(leftTime / 60)
				    		if view and view.mc_1 and view.mc_1.currentView.txt_3 then
				    			view.mc_1.currentView.txt_3:setString(" "..time)
				    		end	    		
				    	end
		        	end
		    	end
    		end
    	end
    end
end

--加载主界面  并根据数据判断需要跳转到哪一层幻境  
function ShareBossNewMainView:updateViewData()
	self:initData()
	self:updateUI()
	self:updateTxtView()
	self:updateBtnStatus()
	
	--处于打开详情界面和关闭详情界面下 需要分开处理
	if not self.isShowDetail then
		--判断是否需要跳转到最大星的层数 并将当前层数保存到model中
		if ShareBossModel:getNeedFindMaxStar() and self.maxStarGroup then
			self.scroll_1:pageEaseMoveTo(self.maxStarGroup, 1, 0)
			ShareBossModel:setCurrentGroup(self.maxStarGroup)
		else
			--读取保存的层数 并跳转 如果该层已经没有数据需要跳转到最近的有数据的层数
			local currentGroup = ShareBossModel:getCurrentGroup() or 1
			for i = currentGroup, 1, -1 do
				if self.scrollData[i] and (i == 1 or i < #self.scrollData) then
					self.scroll_1:pageEaseMoveTo(i, 1, 0)
					ShareBossModel:setCurrentGroup(i)
					break
				end
			end
		end	
	else
		--判断是否需要关闭详情界面  如果不关闭 需要更新详情界面信息
		if self.isDetailBossDisappeared then
			self.bossDetailView:setVisible(false)
			self.isShowDetail = false
			local currentGroup = ShareBossModel:getCurrentGroup() or 1
			for i = currentGroup, 1, -1 do
				if self.scrollData[i] then
					self.scroll_1:pageEaseMoveTo(i, 1, 0)
					ShareBossModel:setCurrentGroup(i)
					break
				end
			end
		else
			self:easeMoveScrollView(0)
			ShareBossModel:setCurrentGroup(self._group)
			self.bossDetailView:updateShareBossView(self.detailViewData)
		end
	end
	--进入主界面后 将是否需要跳转最大星的参数重置
	ShareBossModel:setNeedFindMaxStar(false)
end

--数据发生变化 刷新主界面
function ShareBossNewMainView:shareBossDataChanged()
	self:updateViewData()
end

--初始化数据
function ShareBossNewMainView:initData()
	self.bossDatas = ShareBossModel:getAllBossDatas()
	self.scrollData = {}
	self.maxStar = 0
	--用于判断是否需要关闭主界面
	self.isDetailBossDisappeared = true
	--用于删除过期数据时 防止计时器出现异常
	self.isStop = false

	--将数据分组 每三个为一组
	for i,v in ipairs(self.bossDatas) do
		local group = math.floor((i - 1) / 3) + 1
		if not self.scrollData[group] then
			self.scrollData[group] = {}
			table.insert(self.scrollData[group], v)
			ShareBossModel:setCurMaxIndex(group)
		else
			table.insert(self.scrollData[group], v)
		end

		--获取最大星数 以及 所在的层数
		local star = FuncShareBoss.getBossStarById(v.bossId)
		if not v.isDead and self.maxStar < tonumber(star) then
			self.maxStar = tonumber(star)
			self.maxStarGroup = group
		end

		--处于打开详情界面下的数据处理 如果是打开的幻境依然存在 则不需要关闭详情界面
		if self.detailViewData then
			if self.detailViewData._id == v._id then
				self._group = group
				self._index = (i - 1) % 3 + 1
				self.detailViewData = v
				self.isDetailBossDisappeared = false
			end
		end
	end

	--如果详情界面需要关闭 则将保存在model中的详情数据重置 主要用于各层数上boss的显示和隐藏
	if self.isDetailBossDisappeared then
		ShareBossModel:setCurrentDetailData(nil)
	end
end

function ShareBossNewMainView:initView()
	self.panel_1:setVisible(false)
	self.panel_hei:setVisible(false)
	self.panel_bai:setVisible(false)
end

function ShareBossNewMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_name, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_wen, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.txt_1, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.txt_2, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_1, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_2, UIAlignTypes.Right)
	FuncCommUI.setScrollAlign(self.widthScreenOffset, self.scroll_1, UIAlignTypes.Middle, 1, 0,nil,true)
end

function ShareBossNewMainView:updateUI()
	--由于打开详情界面需要做平移效果 所以需要在滚动条最后额外加一屏没有数据的界面
	if #self.scrollData == 0 then
		self.scrollData = {1}
	else 
		self.scrollData[#self.scrollData + 1] = {1}
	end

	--这里复用的是nd  实际依然是每次都移除之前的界面 然后新建
	local createView = function (itemData, index)
		local view = WindowsTools:createWindow("ShareBossCompView", itemData, index)
		local nd = display.newNode()
		view:addto(nd)
		nd.view = view
		return nd
	end

	local reuseCellView = function (itemData, nd, index)
		nd:removeAllChildren()
		local view = WindowsTools:createWindow("ShareBossCompView", itemData, index)
		view:addto(nd)
		nd.view = view
	end

	local params = {
		{
			data = self.scrollData,
			createFunc = createView,
	        offsetX = 0,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -768, width = 1136, height = 768},
	        updateCellFunc = reuseCellView,
		}
	}


	self.scroll_1:setScrollPage(1, 100, 0, nil, c_func(self.scrollMoveEndCallBack, self))
	self.scroll_1:disabledPageClick(true)
	self.scroll_1:styleFill(params)
	self.scroll_1:hideDragBar()
	self.scroll_1:setBounceDistance(1)

	--开启一个计时器
	self.frameCount = 0
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self), 0)

	if self.needShowTips and #self.scrollData <= 1 then
		self.needShowTips = false
		WindowControler:showTopWindow("ShareBossNoBossTipsView")
	end
end

--更新左侧参战次数
function ShareBossNewMainView:updateTxtView()
	local allCount = self.maxCountEveryDay + self.maxShareBossRescue
	local currentCount = CountModel:getShareBossChallengeCount()
	self.txt_2:setString(currentCount.."/"..allCount)
end

--更新两侧的箭头状态
function ShareBossNewMainView:updateBtnStatus()
	local currentGroup =  ShareBossModel:getCurrentGroup() or 1

	self.btn_1:setVisible(true)
	self.btn_2:setVisible(true)

	if currentGroup == 1 then
		self.btn_1:setVisible(false)
	end

	if (#self.scrollData > 1 and (currentGroup == #self.scrollData - 1 or currentGroup == #self.scrollData))
		or #self.scrollData == 1 then
		self.btn_2:setVisible(false)
	end
end

--每次滚动条滚动后设置新的状态
function ShareBossNewMainView:scrollMoveEndCallBack(index, group)
	ShareBossModel:setCurrentGroup(index)
	self:updateBtnStatus()
end

--切换到上一组boss界面
function ShareBossNewMainView:switchToPreviousGroup()
	if self.switchPrevious then
		return 
	end

	self.switchPrevious = true
	local currentGroup = ShareBossModel:getCurrentGroup() or 1
	if currentGroup == 1 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_shareboss_406"))
	else
		ShareBossModel:setCurrentGroup(currentGroup - 1)
		self.scroll_1:pageEaseMoveTo(currentGroup - 1, 1, 0.4)
	end

	self:updateBtnStatus()
	self:delayCall(function ()
			self.switchPrevious = false
		end, 0.5)
end

--切换到下一组boss界面
function ShareBossNewMainView:switchToNextGroup()
	if self.switchNext then
		return 
	end

	self.switchNext = true
	local currentGroup =  ShareBossModel:getCurrentGroup()
	if currentGroup == #self.scrollData then
		WindowControler:showTips(GameConfig.getLanguage("#tid_shareboss_406"))
	else
		ShareBossModel:setCurrentGroup(currentGroup + 1)
		self.scroll_1:pageEaseMoveTo(currentGroup + 1, 1, 0.4)
	end

	self:updateBtnStatus()
	self:delayCall(function ()
			self.switchNext = false
		end, 0.5)
end

--存在详情界面时 切换到上一个boss  需要同时更新详情界面 以及 平移滚动条到指定的位置
function ShareBossNewMainView:switchToPreviousBossView()
	local groupData = self.scrollData[self._group]
	
	if self._index == 1 then
		if self._group == 1 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_shareboss_406"))
			return
		else
			local previousGroupData = self.scrollData[self._group - 1]
			if not previousGroupData then
				WindowControler:showTips(GameConfig.getLanguage("#tid_shareboss_406"))
				return
			else
				self._group = self._group - 1
				ShareBossModel:setCurrentGroup(self._group)

				self._index = #previousGroupData	
				local bossData = previousGroupData[self._index]
				self.detailViewData = bossData
				self.bossDetailView:updateShareBossView(self.detailViewData)
				self:easeMoveScrollView(self.switchEaseTime)
				self:delayCall(function ()
						EventControler:dispatchEvent(ShareBossEvent.SWITCH_BOSSVIEW, 
										{_group = self._group, _index = self._index})
					end, 0.05)
			end
		end
	else
		self._index = self._index - 1
		local bossData = groupData[self._index]
		self.detailViewData = bossData
		self.bossDetailView:updateShareBossView(self.detailViewData)
		self:easeMoveScrollView(self.switchEaseTime)
		EventControler:dispatchEvent(ShareBossEvent.SWITCH_BOSSVIEW, {_group = self._group, _index = self._index})
	end
end

----存在详情界面时 切换到下一个boss  需要同时更新详情界面 以及 平移滚动条到指定的位置
function ShareBossNewMainView:switchToNextBossView()
	local groupData = self.scrollData[self._group]
	
	if self._index == #groupData then
		local nextGroupData = self.scrollData[self._group + 1]
		if #nextGroupData == 1 and nextGroupData[1] == 1 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_shareboss_406"))
			return
		else
			self._group = self._group + 1
			ShareBossModel:setCurrentGroup(self._group)

			self._index = 1
			
			local bossData = nextGroupData[self._index]
			self.detailViewData = bossData
			self.bossDetailView:updateShareBossView(self.detailViewData)
			self:easeMoveScrollView(self.switchEaseTime)
		end
	else
		self._index = self._index + 1
		local bossData = groupData[self._index]
		self.detailViewData = bossData
		self.bossDetailView:updateShareBossView(self.detailViewData)
		self:easeMoveScrollView(self.switchEaseTime)
	end
	EventControler:dispatchEvent(ShareBossEvent.SWITCH_BOSSVIEW, {_group = self._group, _index = self._index})
end

--平移滚动条  switchEaseTime传入的滚动时间
function ShareBossNewMainView:easeMoveScrollView(switchEaseTime)
	local offsetX = 0
	local offsetY = 0
	if self._index == 1 then
		offsetX = 0
		offsetY = 0
		self.easeTime = 0.2
	elseif self._index == 2 then
		offsetX = -340
		offsetY = -100
		self.easeTime = 0.3
	else
		offsetX = -680
		offsetY = 0
		self.easeTime = 0.4
	end

	local easeTime = self.easeTime
	if switchEaseTime then
		easeTime = switchEaseTime
	end

	self.scroll_1:easeMoveto(offsetX + (1 - self._group) * 1136 + GameVars.UIOffsetX, offsetY, easeTime)
end

--打开一个幻境的详情界面
function ShareBossNewMainView:showBossDetailView(event)
	if self.isShowDetail then
		return 
	end

	local _data = event.params._data
	self._group = event.params._group
	self._index = event.params._index
	
	local callFunc = function ()
		self.bossDetailView:setLeftBtnFideIn()
		self.scroll_1:setCanScroll(false)
	end

	self.isShowDetail = true
	self:easeMoveScrollView()
	if not self.bossDetailView then
		self.detailViewData = _data
		self.bossDetailView = WindowsTools:createWindow("ShareBossDetailView", self, self.detailViewData)
		self.bossDetailView:addto(self._root)
		self.bossDetailView:pos(GameVars.width, 0)
		self.bossDetailView:setLeftBtnOpacity(0)
		self:setBtnVisible(false)
		self.bossDetailView:stopAllActions()
		self.bossDetailView:runAction(act.sequence(act.moveto(self.easeTime, 0, 0), act.callfunc(callFunc)))
	else
		self.detailViewData = _data
		self.bossDetailView:updateShareBossView(self.detailViewData)
		self.bossDetailView:setLeftBtnOpacity(0)
		self:setBtnVisible(false)
		self.bossDetailView:pos(GameVars.width, 0)
		self.bossDetailView:setVisible(true)
		self.bossDetailView:stopAllActions()
		self.bossDetailView:runAction(act.sequence(act.moveto(self.easeTime, 0, 0), act.callfunc(callFunc)))
	end
end

--隐藏一个幻境的详情界面
function ShareBossNewMainView:hideBossDetailView()
	local callFunc = function ()
		self:setBtnVisible(true)
		self:updateBtnStatus()
		self.scroll_1:setCanScroll(true)
		self.bossDetailView:setVisible(false)
		EventControler:dispatchEvent(ShareBossEvent.SET_BOSSVIEW_VISIBLE)
	end

	self.isShowDetail = false
	if self._index == 1 then
		--todo
	else
		local offsetX = GameVars
		self.scroll_1:easeMoveto(-(self._group - 1) * 1136 + GameVars.UIOffsetX, 0, self.easeTime)
	end
	
	self.bossDetailView:stopAllActions()
	self.bossDetailView:setLeftBtnOpacity(0)
	self.bossDetailView:runAction(act.sequence(act.moveto(self.easeTime, GameVars.width, 0), act.callfunc(callFunc)))
end

function ShareBossNewMainView:setBtnVisible(isVisible)
	self.btn_1:setVisible(isVisible)
	self.btn_2:setVisible(isVisible)
end

function ShareBossNewMainView:deleteMe()
	-- TODO

	ShareBossNewMainView.super.deleteMe(self);
end

return ShareBossNewMainView;
