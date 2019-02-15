--[[
	Author: TODO
	Date:2018-01-19
	Description: TODO
]]

local EndlessMainView = class("EndlessMainView", UIBase);

function EndlessMainView:ctor(winName, _data)
    EndlessMainView.super.ctor(self, winName)
    self.endlessData = _data
    -- dump(self.endlessData, "\n\nself.endlessData===")
end

function EndlessMainView:loadUIComplete()	
	self:initData()
	self:registerEvent()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	self:delayCall(c_func(self.openNeededEndlessId, self), 0 / GameVars.GAMEFRAMERATE)	
end 

function EndlessMainView:registerEvent()
	EndlessMainView.super.registerEvent(self);
	self.btn_back:setTouchedFunc(c_func(self.close, self))
	self.btn_gl:setTouchedFunc(c_func(self.enterRankView, self))
	-- self.panel_left:setTouchedFunc(c_func(self.switchFloor, self, self.switchType.NEXT))
	-- self.panel_right:setTouchedFunc(c_func(self.switchFloor, self, self.switchType.LAST))
	self.btn_rule:setTouchedFunc(c_func(self.showRuleView, self))
	-- EventControler:addEventListener(EndlessEvent.ENDLESS_DATA_CHANGED, self.updateMainView, self)
	EventControler:addEventListener(EndlessEvent.ENDLESS_BOX_STATUS_CHANGED, self.updateBottomBoxView, self)
	EventControler:addEventListener(EndlessEvent.RESUME_UI_CLICK, self.resumeScroll, self)
	EventControler:addEventListener(EndlessEvent.OPEN_ONE_DETAIL_VIEW, self.openOneDetailView, self)
	EventControler:addEventListener(EndlessEvent.CLOSE_BOSS_DETAIL_VIEW, self.hideBossDetailView, self)
end

function EndlessMainView:initData()
	self.endlessId = EndlessModel:getCurEndlessId()
	self.floorData = FuncEndless.floorMap
	self.switchType = {
		NEXT = 1,
		LAST = 2,
	}

	self.isNeedSwitch = EndlessModel:isChallengeNewEndless()

	if self.endlessId then
		self.defaultFloor = FuncEndless.getFloorAndSectionById(self.endlessId)
	else
		if UserExtModel:endlessId() == FuncEndless.getFinalEndlessId() then
			self.defaultFloor = FuncEndless.getFloorAndSectionById(UserExtModel:endlessId())
		else
			self.defaultFloor = FuncEndless.getFloorAndSectionById(UserExtModel:endlessId() + 1)
		end
	end
		
	if not self.isNeedSwitch then
		local currentFloor = EndlessModel:getCurrentFloor()
		self.defaultFloor = currentFloor or self.defaultFloor
	end
	EndlessModel:setInitFloor(self.defaultFloor)
end

function EndlessMainView:openNeededEndlessId()
	if self.endlessId then
		EventControler:dispatchEvent(EndlessEvent.OPEN_ONE_DETAIL_VIEW, {endlessId = self.endlessId}) 
		self.endlessId = nil
	end
end

function EndlessMainView:initView()
	self:updatePercentLeftBottomTxt()
	-- self:updateCharSpine()
	-- self:delayCall(c_func(self.updateCharSpine, self), 0.5)
end

function EndlessMainView:openOneDetailView(event)
	local endlessId = event.params.endlessId
	local endFunc = function ()
		self:setDetailViewMoveingStatus(false)		
	end

	if self.isDetailViewMoving then
		return
	end
	if not self.detailView then
		self.detailView = WindowsTools:createWindow("EndlessBossDetailView", endlessId)
		self.detailView:addto(self._root):pos(400+GameVars.UIOffsetX, 0)
		self.panel_right:setVisible(false)
		self.panel_yue:setVisible(false)

		self.detailView:stopAllActions()
		self:setDetailViewMoveingStatus(true)
		self.detailView:runAction(act.sequence(act.moveto(0.3, GameVars.UIOffsetX - GameVars.toolBarWidth , 0), act.callfunc(endFunc)))
	else
		self.detailView:setVisible(true)
		self.panel_right:setVisible(false)
		self.panel_yue:setVisible(false)
		self.detailView:setEndlessId(endlessId)

		self.detailView:stopAllActions()
		self:setDetailViewMoveingStatus(true)
		self.detailView:runAction(act.sequence(act.moveto(0.3, GameVars.UIOffsetX- GameVars.toolBarWidth, 0), act.callfunc(endFunc)))
	end
end

function EndlessMainView:setDetailViewMoveingStatus(_bool)
	self.isDetailViewMoving = _bool
end

function EndlessMainView:hideBossDetailView()
	if self.isDetailViewMoving then
		return
	end
	if self.detailView then
		self.detailView:stopAllActions()
		self:setDetailViewMoveingStatus(true)
		local endFunc = function ()
			self.detailView:setVisible(false)
			self:setDetailViewMoveingStatus(false)
			if self.curFloor ~= 1 then
				self.panel_right:setVisible(true)
			end
			if self.hidePercentTxt then
				self.panel_yue:setVisible(false)
			else
				self.panel_yue:setVisible(true)
			end		
		end

		self.detailView:runAction(act.sequence(act.moveto(0.3, 400+GameVars.UIOffsetX, 0), act.callfunc(endFunc)))		
	end	
end

-- 战斗进入与恢复
function EndlessMainView:getEnterBattleCacheData()
    return  {
            	lastEndlessId = UserExtModel:endlessId(),
            	lastPosition = self.curPosition,
            	lastFloor = self.curFloor,
            }
end

function EndlessMainView:onBattleExitResume(cacheData)
    EndlessMainView.super.onBattleExitResume(cacheData)
    if cacheData and cacheData.lastEndlessId then   	
    	self.lastEndlessId = cacheData.lastEndlessId
    	self.lastPosition = cacheData.lastPosition
    	self.lastFloor = cacheData.lastFloor
    end
end

function EndlessMainView:updateCharMoveAnimation(lastEndlessId, lastPosition, lastFloor)
	if lastEndlessId < UserExtModel:endlessId() and UserExtModel:endlessId() < FuncEndless.getFinalEndlessId() then
    	self.scroll_1:setCanScroll(false)
    	-- echo("\n\nlastEndlessId===", lastEndlessId, "UserExtModel:endlessId()", UserExtModel:endlessId())
    	if self.charSpine then
    		echo("\n\ncharSpine______exit_______")
    	else
    		echo("\n\ncharSpine______not exit_______")
    	end
    	if self.charSpine then
        	local offsetX = 200
			local offsetY = -200
        	self.charSpine:setVisible(false)
        	local spineEndlessId = UserExtModel:endlessId() + 1
			if spineEndlessId > FuncEndless.getAllEndlessCount() then
				self.scroll_1:setCanScroll(true)
				return 
			end
        	local newPosition = FuncEndless.getBossPositionByEndlessId(spineEndlessId)
        	local floor, section = FuncEndless.getFloorAndSectionById(spineEndlessId)
        	local curFloorNode = self.scroll_1:getViewByData(floor)
			local node = self.scroll_1:getScrollNode()
			newPosition = curFloorNode:convertLocalToNodeLocalPos(node, cc.p(newPosition[1] + offsetX, newPosition[2] + offsetY))
        	-- echo("\n\nfloor====", floor, "lastFloor===", lastFloor)
        	if floor > lastFloor then 
        		self.charSpine:playLabel("crossrange", true)
        	else
        		if tonumber(newPosition.x) > tonumber(lastPosition.x) then
	        		if tonumber(newPosition.y) > tonumber(lastPosition.y) then
		        		self.charSpine:playLabel("leanup", true)
		        		-- self.charSpine:setScaleX(-0.75)
	        		else
		        		self.charSpine:playLabel("leandown", true)
		        		self.charSpine:setScaleX(-0.75)
		        	end
		        else
		        	if tonumber(newPosition.y) > tonumber(lastPosition.y) then
		        		self.charSpine:playLabel("crossrange", true)
		        	else
		        		self.charSpine:playLabel("leandown", true)
		        	end
	        	end
        	end
        	
        	self.charSpine:pos(lastPosition.x, lastPosition.y)
        	self.charSpine:setVisible(true)
    		self.scroll_1:_pageEaseMoveTo(#self.floorData - lastFloor + 1, 1, 0)
        	local moveFunc = function (charSpine)
        		local delayTime = 1
        		if floor > lastFloor then      			
        			self.scroll_1:_pageEaseMoveTo(#self.floorData - floor + 1, 1, 2)
        			delayTime = 2
        			charSpine:moveTo(delayTime, newPosition.x, newPosition.y)
        		else
        			charSpine:moveTo(delayTime, newPosition.x, newPosition.y)
        		end
        		self.lastPosition = newPosition
        		self.scroll_1:setCanScroll(true)
        		
        		local endFunc = function (charSpine)
        			charSpine:playLabel("crossrange", true)
        			self.charSpine:setScaleX(0.75)
        		end
        		self:delayCall(c_func(endFunc, self.charSpine), delayTime)
        	end
        	
        	self:delayCall(c_func(moveFunc, self.charSpine), 0.5)
        end
    end
end

function EndlessMainView:updateCharSpine()
	local spineEndlessId = UserExtModel:endlessId() + 1
	if spineEndlessId > FuncEndless.getAllEndlessCount() then
		spineEndlessId = FuncEndless.getAllEndlessCount()
	end
	-- echo("\n\nspineEndlessId======", spineEndlessId)
	local offsetX = 200
	local offsetY = -200
	local floor, section = FuncEndless.getFloorAndSectionById(spineEndlessId)
	local posInFloor = FuncEndless.getBossPositionByEndlessId(spineEndlessId)
	local curFloorNode = self.scroll_1:getViewByData(floor)
	local node = self.scroll_1:getScrollNode()

	if curFloorNode then
		-- echo("\n\n_____updateCharSpine____")
		local position = curFloorNode:convertLocalToNodeLocalPos(node, cc.p(posInFloor[1] + offsetX, posInFloor[2] + offsetY))
	
		if not self.charSpine then
			local charSex = UserModel:sex()
			local garmentId = GarmentModel:getOnGarmentId()
			local spineName = FuncGarment.getWorldSpineById(charSex, garmentId)
			self.charSpine = ViewSpine.new(spineName)
			self.charSpine:addto(node)
			self.charSpine:zorder(1)
			self.charSpine:setScale(0.75)			
			self.charSpine:playLabel("crossrange", true)
			self.charSpine:setRotationSkewY(180)
			self.charSpine:pos(position.x, position.y)
			self.curPosition = {x = position.x, y = position.y}
			self.curFloor = floor
		end		
	else
		-- echo("\n\n_____updateCharSpine__no curFloorNode__")
	end

	if self.lastEndlessId and (self.lastEndlessId + 1) == UserExtModel:endlessId() then
		-- echo("\n\n_______self.lastEndlessId_____________", self.lastEndlessId)
		self:updateCharMoveAnimation(self.lastEndlessId, self.lastPosition, self.lastFloor)
	end
end

function EndlessMainView:resumeScroll()
	self.scroll_1:setCanScroll(true)
end

function EndlessMainView:initViewAlign()
	FuncCommUI.setScrollAlign(self.widthScreenOffset, self.scroll_1, UIAlignTypes.Middle, 1, 0,nil,true)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_jdt, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_yue, UIAlignTypes.RightBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_gl, UIAlignTypes.LeftBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_icon, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_ceng, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_right, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_left, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_rule, UIAlignTypes.LeftTop)
end

function EndlessMainView:updatePercentLeftBottomTxt()
	local friendList = self.endlessData.friends or {}
	local guildList = self.endlessData.members or {}
	self.friendAndGuildList = EndlessModel:getFriendAndGuildRankList(friendList, guildList)
	local showTxt = false
	local rank = 0
	for i,v in ipairs(self.friendAndGuildList) do
		if v.rid == UserModel:rid() then
			rank = v.rank
			showTxt = true
		end
	end

	EndlessModel:setTheFastData(self.friendAndGuildList)

	if showTxt and #self.friendAndGuildList > 1 then
		local percentTxt = string.format("%.1f", (#self.friendAndGuildList - rank) / (#self.friendAndGuildList - 1) * 100)
		self.panel_yue.rich_1:setString(GameConfig.getLanguageWithSwap("#tid_endless_friends_3", percentTxt.."%"))
		self.panel_yue:setVisible(true)
		self.hidePercentTxt = false
	else
		self.hidePercentTxt = true
		self.panel_yue:setVisible(false)
	end
end

function EndlessMainView:updateMainView()
	-- local nextFloor = nil
	-- if UserExtModel:endlessId() == FuncEndless.getFinalEndlessId() then
	-- 	nextFloor = FuncEndless.getFloorAndSectionById(UserExtModel:endlessId())
	-- else
	-- 	nextFloor = FuncEndless.getFloorAndSectionById(UserExtModel:endlessId() + 1)
	-- end
	
	-- local isNeedSwitch = EndlessModel:isChallengeNewEndless()
	-- if nextFloor > self.defaultFloor and isNeedSwitch then
	-- 	self.curFloor = nextFloor
	 	-- self.scroll_1:_pageEaseMoveTo(#self.floorData - self.curFloor + 1, 1, 0.4)
	-- end

	if self.curFloor <= FuncEndless.getFloorCount() then
		self:updateFloorTitle(self.curFloor)
		self:updateBottomBoxView()
		self:updatePercentLeftBottomTxt()
	end	
end

function EndlessMainView:updateUI()
	local creatFloorView = function (itemData, index)
		local view = WindowsTools:createWindow("EndlessFloorBaseView", itemData)
		local nd = display.newNode()
		view:addto(nd)
		return nd
	end

	local reuseCellView = function (itemData, nd, index)
		nd:removeAllChildren()
		local view = WindowsTools:createWindow("EndlessFloorBaseView", itemData)
		view:addto(nd) 
	end

	local params = {
		{
			data = self.floorData,
			createFunc = creatFloorView,
	        offsetX = 0,
	        offsetY = 64,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -768, width = 1136, height = 768},
	        updateCellFunc = reuseCellView,
		}
	}

	self.scroll_1:setScrollPage(1, 200, 0, nil, c_func(self.scrollMoveEndCallBack, self))
	self.scroll_1:disabledPageClick(true)
	self.scroll_1:styleFill(params)
	self.curFloor = self.defaultFloor
	self.scroll_1:pageEaseMoveTo(#self.floorData - self.curFloor + 1, 1, 0)
	self:updateFloorTitle(self.curFloor)
	self:updateBottomBoxView()
	self.scroll_1:setBounceDistance(0.5)
	self.scroll_1:hideDragBar()
	self.scroll_1:setOnCreateCompFunc(c_func(self.updateCharSpine, self))
	-- self.scroll_1:setVisible(false)
	-- self.scroll_1:setCanScroll(false)
end

function EndlessMainView:scrollMoveEndCallBack(index, group)
	self.curFloor = #self.floorData - index + 1
	if self.curFloor <= 60 then
		self:updateFloorTitle(self.curFloor)
		self:updateBottomBoxView()
		EndlessModel:setCurrentFloor(self.curFloor)
		if not self.charSpine then
			self:updateCharSpine()
		end		
		-- self:delayCall(c_func(self.updateCharSpine, self), 0.1)
	end	
end

--更新左上角名字
function EndlessMainView:updateFloorTitle()
	local floorName = GameConfig.getLanguageWithSwap("#tid_endless_floorname_1", FuncEndless.getFloorStrByFloorId(self.curFloor))
	self.panel_ceng.txt_1:setString(floorName)
end

--更新下方宝箱奖励状态
function EndlessMainView:updateBottomBoxView()
	if self.curFloor == 1 then
		self.panel_left:setVisible(true)
		self.panel_right:setVisible(false)
	elseif self.curFloor == 60 then
		self.panel_left:setVisible(false)
		self.panel_right:setVisible(true)
	else
		self.panel_left:setVisible(true)
		self.panel_right:setVisible(true)	
	end

	self.star_table = FuncEndless.getFloorStarById(self.curFloor)
	local persent = 0
	for i = 1, 3, 1 do
		local view = self.panel_jdt["panel_box"..i]
		self:updateEveryBox(view, i)
	end
	local stars = EndlessModel:getCurStarsByFloor(self.curFloor)
	local panel_progress = self.panel_jdt.panel_jin
	percent = math.round(stars / self.star_table[3] * 100)
	echo("\n\nself.star_table[3]===", self.star_table[3], stars)
	-- if percent <= 0  then
	-- 	percent = 0
	-- elseif percent <= 10 then
	-- 	percent = 6
	-- elseif percent <= 14 then
	-- 	percent = 9
	-- elseif percent <= 20 then
	-- 	percent = 11
	-- elseif percent <= 27 then
	-- 	percent = 15
	-- elseif percent <= 34  then
	-- 	percent = 18
	-- elseif percent <= 40  then
	-- 	percent = 22
	-- elseif percent <= 47  then
	-- 	percent = 25
	-- elseif percent <= 54  then
	-- 	percent = 29
	-- elseif percent <= 60  then
	-- 	percent = 33
	-- elseif percent <= 67  then
	-- 	percent = 45
	-- elseif percent <= 74 then
	-- 	percent = 56	
	-- elseif percent <= 80 then
	-- 	percent = 67
	-- end

	panel_progress.progress_huang:setPercent(percent)
end

--更新下方每一个箱子的状态
function EndlessMainView:updateEveryBox(view, index)
	local starNum = self.star_table[index]
	local boxStatus = EndlessModel:getBoxStatusByFloorAndBoxType(self.curFloor, index)
	if boxStatus == FuncEndless.boxRewardType.NOTRECEIVED then
		view.mc_box:showFrame(1)
		self:playStarBoxAnim(view, false)	
	elseif boxStatus == FuncEndless.boxRewardType.HASRECEIVED then
		view.mc_box:showFrame(2)
		self:playStarBoxAnim(view, false)
	else
		view.mc_box:showFrame(1)
		self:playStarBoxAnim(view, true)
	end
	--点击获取箱子中的奖励
	view:setTouchedFunc(c_func(self.showBoxRewardView, self, index, boxStatus, self.curFloor, starNum))
	view.txt_1:setString(starNum)
end

--播放宝箱闪光动画
function EndlessMainView:playStarBoxAnim(panelBox, isPlay)  
-- isPlay,true表示播放动画；false表示不播放动画，如果ctn已经有动画，需要做换装的反动作，并删除动画
	local ctnBox = panelBox.ctn_xing1
	if isPlay then
		if ctnBox:getChildrenCount() == 0 then
			panelBox.mc_box:setVisible(false)
			local mcView = UIBaseDef:cloneOneView(panelBox.mc_box)
			local anim = self:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",ctnBox, false, GameVars.emptyFunc)
	    	-- anim:pos(0,0)
	    	mcView.currentView:pos(-1,5)
	    	FuncArmature.changeBoneDisplay(anim,"node",mcView)
	    	anim:startPlay(true)
		end
	else
		if ctnBox:getChildrenCount() > 0 then
			panelBox.mc_box:setVisible(true)
			ctnBox:removeAllChildren()
		end
	end
end

function EndlessMainView:showBoxRewardView(index, boxStatus, curFloor, starNum)
	local ownStar = EndlessModel:getCurStarsByFloor(curFloor)
	local data = {
		_boxIndex = index,
		_boxStatus = boxStatus,
		_curFloor = curFloor,
		_ownStar = ownStar,
		_needStarNum = starNum,
	}
	WindowControler:showWindow("EndlessBoxRewardView", data)
end

-- function EndlessMainView:getBoxReward(index, boxStatus)
-- 	if boxStatus == FuncEndless.boxRewardType.CANRECEIVED then
-- 		EndlessServer:getBoxReward(self.curFloor, index, c_func(self.showRewards, self))
-- 	elseif boxStatus == FuncEndless.boxRewardType.HASRECEIVED then
-- 		WindowControler:showTips("该宝箱已被领取")
-- 	else
-- 		WindowControler:showTips("未达成领取条件")
-- 	end
-- end

-- function EndlessMainView:showRewards(event)
-- 	if event.result then
-- 		local rewards = event.result.data.reward
-- 		FuncCommUI.startRewardView(rewards)
-- 		EventControler:dispatchEvent(EndlessEvent.ENDLESS_BOX_STATUS_CHANGED)
-- 	end
-- end

function EndlessMainView:switchFloor(_type)
	if _type == self.switchType.NEXT then
		if self.curFloor == #self.floorData then
			WindowControler:showTips(GameConfig.getLanguage("#tid_endless_tips_11"))
			return  
		else
			self.curFloor = self.curFloor + 1
			self.scroll_1:pageEaseMoveTo(#self.floorData - self.curFloor + 1, 1, 0.4)
			self:updateFloorTitle(self.curFloor)
			self:updateBottomBoxView()
		end
	else
		if self.curFloor == 1 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_endless_tips_12"))
			return 
		else
			self.curFloor = self.curFloor - 1
			self.scroll_1:pageEaseMoveTo(#self.floorData - self.curFloor + 1, 1, 0.4)
			self:updateFloorTitle(self.curFloor)
			self:updateBottomBoxView()
		end
	end
	EndlessModel:setCurrentFloor(self.curFloor)
end

function EndlessMainView:enterRankView()
	local _beginRank = 1
	local _endRank = 50
	EndlessModel:enterEndlessRankView(_beginRank, _endRank)
end

function EndlessMainView:showRuleView()
	WindowControler:showWindow("EndlessRuleView")
end

function EndlessMainView:close()
	EndlessModel:setChallengeNewEndless(UserExtModel:endlessId() + 1)
	EndlessModel:setCurrentFloor(nil)
	self:startHide()
end

function EndlessMainView:deleteMe()
	-- TODO

	EndlessMainView.super.deleteMe(self);
end

return EndlessMainView;
