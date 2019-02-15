--[[
	Author: TODO
	Date:2018-07-04
	Description: TODO
]]

local GuildExploreMainView = class("GuildExploreMainView", UIBase);

function GuildExploreMainView:ctor(winName)
    GuildExploreMainView.super.ctor(self, winName)
end

function GuildExploreMainView:loadUIComplete()
	self:initViewAlign()
	GuildExploreModel:setEntranceRed(false)

	local y1 = self.panel_t.panel_task1:getPositionY()
	local y2 = self.panel_t.panel_task2:getPositionY()
	self.taskPanelPos = {
		[1] = y1,
		[2] = y2,
	}
	self:createThreeCellNotify()
	self.eventListNotifyData = {}
	self._rect = {x = self.btn_t:getPositionX(),y = self.btn_t:getPositionY()}
	self.panel_t_y = self.panel_t:getPositionY()
	self:registerEvent()
	self:initData()
	

	self:initView()
	self:updateUI()
	-- self:createEnterAni()
	self:initButtonRed()

	--隐藏tips
	self:showOrHideTips(false)

	self.panel_map1:setVisible(false)
	self.panel_map2:setVisible(false)
	self.panel_map3:setVisible(false)
	self.panel_map4:setVisible(false)
	self.panel_map5:setVisible(false)
	self.panel_map6:setVisible(false)
	
	self.panel_map:setVisible(false)
	self.panel_map.scale9_me:parent(self.panel_map.ctn_1,9999999)


	--初始隐藏移动提示
	self:showOrHideWalkCue(false)
	self.panel_stop.txt_1:setVisible(false)

	-- self:delayCall(c_func(self.updateEquipmentPos,self,true),1)

	self:updateEquipmentPos(true)

	self:setDownButton()
	self:leftBottomButtonRunaction()
	self:setRewardButton()
	self:showBuffUI()
	GuildExploreModel:getAlleventsData()
	self:setEnergy()
	self:getBurronRedInfo()
	self.updateFrameTime = 1
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
	self:taskRunaction()
	self:showTaskView()
	self:getEventListData()
	self:showComplete()

	self:notShowUIResIcon()



end 



--不显示通用资源的加号
function GuildExploreMainView:notShowUIResIcon()
	self.panel_5.UI_1.btn_tianfujiahao:setVisible(false)
	self.panel_5.UI_2.btn_tianfujiahao:setVisible(false)
	self.panel_5.UI_4.btn_lingshijiahao:setVisible(false)
	self.panel_5.UI_5.btn_xianyujiahao:setVisible(false)
	local node = display.newNode()
	node:anchor(0,1)
	node:size(700,80)
	self.panel_5:addChild(node)
	node:setTouchedFunc(c_func(function () end), nil, true)
end

function GuildExploreMainView:getEventListData()
	local function callBack(data)
		local allData = data
		local recordList = allData.recordList
		-- dump(recordList,"44444444444444444")
		self:showEventListView(recordList)
	end
	GuildExploreEventModel:showMapEventUI(false,callBack)
end


function GuildExploreMainView:showEventListView(data)
	local index = 1

	table.sort(data,function(a,b)
        return a.ctime > b.ctime
    end)


	if data then
		for i=1,#data do
			if data[i] then
				local eventData = FuncGuildExplore.getCfgDatas( "ExploreRecord",data[i].tid)
				local data = GuildExploreModel:getEventData( data[i].id ,true)
				if data then
					if eventData then
						if eventData.isShow and eventData.isShow == 1 then
							if index <= 3 then
								local panel = self.inviteBseCell[index]
								if panel then
									if not panel:isVisible() then
										self:showEventListNotifyPanel(panel,data[i])
									end
								end
								index = index + 1
							end
						end
					end
				end
			end
		end
	end
end

function GuildExploreMainView:setTaskFinishEfft(ctn)

    if not ctn then
    	return
    end
    ctn:setVisible(true)
    local btneffect = ctn:getChildByName("effect")
    if not btneffect  then
        local lockAni = self:createUIArmature("UI_task","UI_task_renwu05", ctn, true, function ()
        end)
        lockAni:setName("effect")
        lockAni:setScaleX(0.85)
        lockAni:setScaleY(0.96)
    end
end

function GuildExploreMainView:showTaskView()


	self.panel_t.panel_task1:setVisible(false)
	self.panel_t.panel_task2:setVisible(false)

	local createFunc1 = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_t.panel_task1);
        self:setTaskCell1(baseCell, itemData)
        return baseCell;
    end
    local updateCellFunc1 = function (itemData,view)
    	self:setTaskCell1(view, itemData)
	end
	
	local createFunc2 = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_t.panel_task2);
        self:setTaskCell2(baseCell, itemData)
        return baseCell;
    end
     local updateCellFunc2 = function (itemData,view)
    	self:setTaskCell2(view, itemData)
	end


	 local  _scrollParams = {}
	local singeData,manyPeopleData = GuildExploreModel:getShowTaskData()

	if singeData then
		local params =  {
            data =  {singeData},
            createFunc = createFunc1,
            updateCellFunc= updateCellFunc1,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -75, width = 220, height = 75},
            perFrame = 0,
        }
        table.insert(_scrollParams,params)

	end

	if manyPeopleData then
		local params =  {
            data =  {manyPeopleData},
            createFunc = createFunc2,
            updateCellFunc= updateCellFunc2,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -75, width = 220, height = 75},
            perFrame = 0,
        }

        table.insert(_scrollParams,params)
	end
	if #_scrollParams ~= 0 then
	    self.panel_t.scroll_1:refreshCellView( 1 )
	    self.panel_t.scroll_1:styleFill(_scrollParams);
	    self.panel_t.scroll_1:hideDragBar()
	    self.panel_t.scroll_1:setCanScroll( false )
	end
	if not singeData  and  not manyPeopleData then
		self.btn_t:setVisible(false)
		self.panel_t:setVisible(false)
	else
		self.btn_t:setVisible(true)
		self.panel_t:setVisible(true)
	end

end



function GuildExploreMainView:setTaskCell1(baseCell, itemData)
	local panel_task1 = baseCell
	panel_task1:setVisible(true)
	panel_task1.mc_1:showFrame(1)
	local isFinsh,data = GuildExploreModel:isGetTaskIsFinish(itemData,FuncGuildExplore.taskType.single)
	local str  = data.."/"..itemData.condition
	panel_task1.rich_1:setString(GameConfig.getLanguageWithSwap(itemData.des,str))
	panel_task1.txt_2:setVisible(false)
	local ctn = panel_task1.ctn_s
	ctn:setVisible(false)
	local node = display.newNode()
	node:anchor(0,1)
	node:size(220,78)
	baseCell:addChild(node,1000)
	if isFinsh then
		panel_task1.txt_2:setString("领取")
		panel_task1.txt_2:setVisible(true)
		node:setTouchedFunc(c_func(self.getRewardButton,self,itemData.id), nil, true)
		self:setTaskFinishEfft(ctn)
	else
		-- panel_task1.txt_2:setString(data.."/"..itemData.condition)
		node:setTouchedFunc(c_func(self.jumpToTask,self,FuncGuildExplore.taskType.single), nil, true)
	end
end

function GuildExploreMainView:setTaskCell2( baseCell, itemData )
	local panel_task2 = baseCell
	panel_task2:setVisible(true)
	panel_task2.mc_1:showFrame(2)
	local isFinsh,data = GuildExploreModel:isGetTaskIsFinish(itemData,FuncGuildExplore.taskType.manyPeople)
	local str = data.."/"..itemData.condition
	panel_task2.rich_1:setString(GameConfig.getLanguageWithSwap(itemData.des,str))
	panel_task2.txt_2:setVisible(false)
	local ctn = panel_task2.ctn_s
	ctn:setVisible(false)
	local node = display.newNode()
	node:anchor(0,1)
	node:size(220,78)
	baseCell:addChild(node,1000)
	if isFinsh then
		panel_task2.txt_2:setString("领取")
		panel_task2.txt_2:setVisible(true)
		node:setTouchedFunc(c_func(self.getRewardButton,self,itemData.id), nil, true)
		self:setTaskFinishEfft(ctn)
	else
		-- panel_task2.txt_2:setString(data.."/"..itemData.condition)
		node:setTouchedFunc(c_func(self.jumpToTask,self,FuncGuildExplore.taskType.manyPeople), nil, true)
	end
end










function GuildExploreMainView:jumpToTask(_type)
	self:openTaskView(_type)
end

--领取奖励按钮
function GuildExploreMainView:getRewardButton(questId)
	-- echo("==========奖励任务ID========",questId)
	local function callBack( event )
		if event.result then
			-- dump(event.result,"领取任务返回数据==============")
			local task = event.result.data.task
			local reward = event.result.data.reward
			GuildExploreModel:setGetTaskRewardData(task.tid)

			local data = FuncGuildExplore.getFuncData( "ExploreQuest",questId)
			local rewardData = 	data.reward
			-- local rewardData = GuildExploreModel:rewardTypeConversion(reward) --GuildExploreEventModel:getShowRewardUIData(reward)
			-- dump(rewardData,"领取任务数据")
			WindowControler:showWindow("RewardSmallBgView", rewardData);
			EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_REFESH_RED)
			EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_TASK_REFRESH)
		end
	end

	local params = {
		tid = questId,
	}

	GuildExploreServer:getTaskReward(params,callBack)
end





function GuildExploreMainView:updateFrame()
	if math.fmod(self.updateFrameTime,30*30) == 0 then
		self:getBurronRedInfo()
	end
	self.updateFrameTime = self.updateFrameTime + 1

	if self.updateFrameTime % 30 == 0 then
		if self.panel_tips:isVisible() then
			self:showOrHideTips(true)
		end
	end
	

end



---获取界面红点
function GuildExploreMainView:getBurronRedInfo()
	local function callBack(event)
		if event.result then
			-- dump(event.result,"========获取界面红点========")
			if event.result.data.result == 0 then
				local redPoint = event.result.data.redPoint
				self.redPoint = redPoint
				self:setButtonRed()
			end
		end

	end
	GuildExploreServer:explore_heartbeat(callBack)
end


--根据类型获得红点
function GuildExploreMainView:getRedByType(_type)
	if self.redPoint then
		local valuer = self.redPoint[tostring(_type)]
		if valuer then
			if valuer == 1 then
				return true
			end
		end
	end
	return false
end

function GuildExploreMainView:setButtonRed()
	-- self.:getUpPanel().panel_red:visible(false)
	local isAllRed = false
	for i=1,5 do
		local isRed = false
		if i == 1 then
			isRed = ChatModel:getPrivateDataRed()
			isAllRed = isRed
		elseif i == 4 then
			isRed = self:getRedByType(1)
			isAllRed = isRed
		elseif i == 3 then
			isRed = self.eventListRed or false
			isAllRed = isRed
		elseif i == 2 then
			isRed =	GuildExploreModel:getMapSendFinishRewardRed()
			isAllRed = isRed
		end
		local btn = self.panel_6["btn_"..i]
		if btn then
			local panel_red = btn:getUpPanel().panel_red
			if panel_red then
				panel_red:visible(isRed)
			end
		end
	end
	self.btn_3:getUpPanel().panel_red:visible(isAllRed)


	for i=1,3 do
		local panel_red = self["mc_yeqian"..i]:getViewByFrame(1).panel_red
		if panel_red then
			local isShow = GuildExploreModel:getEquipRed(i)
			panel_red:setVisible(isShow)
		end
	end

end

function GuildExploreMainView:initButtonRed()
		
	for i=1,5 do
		local btn = self.panel_6["btn_"..i]
		if btn then
			local panel_red = btn:getUpPanel().panel_red
			if panel_red then
				panel_red:visible(false)
			end
		end
	end
	self.btn_3:getUpPanel().panel_red:visible(false)

	for i=1,3 do
		local panel_red = self["mc_yeqian"..i].panel_red
		if panel_red then
			panel_red:setVisible(false)
		end
	end
end




function GuildExploreMainView:registerEvent()
	GuildExploreMainView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.button_close,self))
	
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLOREEVENT_HIPP_BUFF_CHANGE, self.showBuffUI, self)

	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLOREEVENT_ENERGYCHANGED, self.setEnergy,self)

	
	EventControler:addEventListener(GuildExploreEvent.GUILD_EXPLORE_OFF_LINE_REWARD, self.setRewardButton,self)
	EventControler:addEventListener(GuildExploreEvent.GUILD_EXPLORE_BUFFOPEN, self.updateEquipmentPos,self)

	-- self.panel_map.scale9_3:setTouchedFunc(c_func(self.onClickMiniMap,self), nil, true)
	self.panel_map:setVisible(false)
	self.panel_title:setTouchedFunc(c_func(self.setrule,self), nil, true)

	self:scheduleUpdateWithPriorityLua(c_func(self.getEnergy, self) ,0)

	self.btn_1:setTap(c_func(self.showOrHideMiniMap,self,true))
	self.panel_map.btn_back:setTouchedFunc(c_func(self.showOrHideMiniMap,self,false))


	EaseMapControler:startEaseMapAndDrag(self.panel_map,c_func(self.onMiniMapPosChange,self) ,nil, nil ,c_func(self.onClickMiniMap,self) )



	EventControler:addEventListener(GuildExploreEvent.RES_EXCHANGE_REFRESH, self.refreshUI, self)


	-- self.UI_2:setTouchedFunc(c_func(self.nullCellfun,self), nil, true)

	EventControler:addEventListener("notify_guild_remove_player_1356",self.removeGuild, self)

	EventControler:addEventListener(GuildExploreEvent.GUILD_EXPLORE_MAIN_ISSHOW,self.showMainButton, self)

	EventControler:addEventListener(GuildExploreEvent.GUILD_EXPLORE_REFESH_RED,self.getBurronRedInfo, self)


	EventControler:addEventListener("notify_explore_map_pushEvent", self.eventListNotify, self)

	
	

	EventControler:addEventListener(GuildExploreEvent.GUILD_EXPLORE_TASK_REFRESH,self.showTaskView, self)
	
	

	if IS_EXPLORE_GM_RES then
		self.panel_jingli:setTouchedFunc(c_func(function ()
			GuildExploreModel:getResGM(10)
		end),nil,true,c_func(self.onJingliBtnDonw,self),nil,nil,c_func(self.onJingliBtnGlobalUp,self));
	else
		self.panel_jingli:setTouchedFunc(GameVars.emptyFunc,nil,true,c_func(self.onJingliBtnDonw,self),nil,nil,c_func(self.onJingliBtnGlobalUp,self))
	end


end

function GuildExploreMainView:refreshUI()
	self:setEnergy()
	self:setButtonRed()
end


function GuildExploreMainView:onJingliBtnDonw(  )
	self:showOrHideTips(true)
end

function GuildExploreMainView:onJingliBtnGlobalUp(  )
	self:showOrHideTips(false)
end


--创建三个推送事件列表
function GuildExploreMainView:createThreeCellNotify()
	local panel = self.panel_invite
	panel:setVisible(false)
	local x = self.panel_invite:getPositionX()
	local y = self.panel_invite:getPositionY()
	self.inviteBseCell = {}
	for i=1,3 do
		self.inviteBseCell[i] = UIBaseDef:cloneOneView(panel)
		self.inviteBseCell[i]:setPosition(cc.p(0,(i - 1)*45))
		self.inviteBseCell[i]:setVisible(false)
		self.ctn_event:addChild(self.inviteBseCell[i])
	end
	-- for i=1,3 do
	-- 	if self.inviteBseCell[i] then
	-- 		self.inviteBseCell[i]:setVisible(false)
	-- 	end
	-- end
end


-- function GuildExploreMainView:taskListNotify()

-- 	self:showTaskView()

-- end



function GuildExploreMainView:eventListNotify(event)
	local newData = event.params.params
	-- dump(newData,"事件推送数据 ============")
	local eventData = FuncGuildExplore.getCfgDatas( "ExploreRecord",newData.tid)
	if eventData then
		if eventData.isShow and eventData.isShow == 1 then
			if self.inviteBseCell then
				for i=1,3 do
					local panel = self.inviteBseCell[i]
					if panel then
						if not panel:isVisible() then
							self:showEventListNotifyPanel(panel,newData)
							break
						end
					end
				end
			end
		end
	end
	local view = WindowControler:getWindow( "GuildExploreEventView" )
	if not view then
		self.eventListRed = true
		self:setButtonRed()
	end
end

function GuildExploreMainView:showEventListNotifyPanel(panel,newData)
	
	local itemData = newData --self.eventListNotifyData[index]
	-- dump(itemData,"显示的数据====")
	if itemData then
		panel:setVisible(true)
		panel:setOpacity(255)
		local des = GuildExploreEventModel:getEventStr(itemData,true)
		panel.rich_1:setString(des)
		panel:setTouchedFunc(c_func(self.eventJumpTo, self,itemData),nil,true);
		panel:runAction(act.sequence(act.delaytime(5.0),act.fadeto( 0.2,0),act.callfunc(function ()
			panel:setVisible(false)
		end)))
	end
end

function GuildExploreMainView:eventJumpTo(itemData)
	dump(itemData,"主城事件推送数据 ========")
	GuildExploreEventModel:eventJumpToView(itemData)
end


function GuildExploreMainView:onMiniMapPosChange( x,y )
	-- echo(x,y,'___onMiniMapPosChange__',self.mapControler:turnMiniToWorldPos( -x,-y ))
	x,y = self.mapControler:turnMiniToWorldPos( -x,-y )
	self.mapControler.currentMoveState = 0
	self.mapControler:onPosChange(x,y)

end

--点击小地图
function GuildExploreMainView:onClickMiniMap( e )
	local targetPos = self.panel_map.ctn_1:convertToNodeSpaceAR(e)
	if targetPos.x > 10 or targetPos.x < -ExploreMapControler.miniMapWidth-100 or targetPos.y > 30 or targetPos.y < -ExploreMapControler.miniMapHeight-10 then
		self:showOrHideMiniMap(false)
		return
	end
	--转化坐标
	local x,y = self.controler.mapControler:turnMiniToWorldPos( targetPos.x,targetPos.y )
	self.controler.mapControler:setFollowToTargetByPos({x=x,y=y},false)

	-- self:showOrHideMiniMap(false)
end

--更新mini地图位置
function GuildExploreMainView:updateMiniPos(  )
	if not self.mapControler then
		return
	end
	local focusPos = self.mapControler.currentPos
	local x,y = self.mapControler:turnWorldPosToMiniMap(focusPos.x,focusPos.y)
	self.panel_map.scale9_me:pos(-x,-y)
end



--主城按钮是否显示
function GuildExploreMainView:showMainButton(event)
	local ishow = event.params.isShow

	self.mc_yeqian1:setVisible(ishow)
	self.mc_yeqian2:setVisible(ishow)
	self.mc_yeqian3:setVisible(ishow)
	self.panel_jingli:setVisible(ishow)
	self.btn_back:setVisible(ishow)
	self.btn_1:setVisible(ishow)
	self.panel_title:setVisible(ishow)
	self.panel_res:setVisible(ishow)
	self.UI_2:setVisible(ishow)
	self.btn_dingwei:setVisible(ishow)
	
	if not ishow then
		self.panel_5:setVisible(ishow)
		self.btn_3:setVisible(ishow)
		self.panel_6:setVisible(ishow)
		self.panel_t:setVisible(ishow)
		self.btn_t:setVisible(ishow)
	else
		self.btn_3:setVisible(ishow)
		self.panel_t:setVisible(ishow)
		self.btn_t:setVisible(ishow)
		if self.openResButton then
			self.panel_5:setVisible(true)
		else
			self.panel_5:setVisible(false)
		end
	end
end

--显示或者隐藏移动提示
function GuildExploreMainView:showOrHideWalkCue( value )
	self.panel_stop:setVisible(value)
	if value then
		if not self.panelStopAni  then
			self.panelStopAni = self:createUIArmature("UI_xianmengtansuo", "UI_xianmengtansuo_dianji", self.panel_stop, true)
			self.panelStopAni:pos(131,0)
		end
	end
end

function GuildExploreMainView:showOrHideTips( value )
	self.panel_tips:visible(value)
	if value then
		local buyNums = GuildExploreModel:getBuyEnergyCount(  )
		local maxNums = FuncGuildExplore.getSettingDataValue("ExploreEnergyBuyNum","num")
		self.panel_tips.txt_1:setString(buyNums .. "/"..maxNums)
		self.panel_tips.txt_2:setString((FuncGuildExplore.getSettingDataValue("ExploreRecoveryTime","num") /60).."分钟")
		--获取恢复全部精力时间
		self.panel_tips.txt_3:setString(GuildExploreModel:getEnegryFullTimeStr())
	end
end


--显示或者隐藏minimap
function GuildExploreMainView:showOrHideMiniMap(value )
	self.panel_map:setVisible(value)
	if not self.panel_map.coverbg then
		self.panel_map.coverbg = WindowControler:createCoverLayer( nil,nil ,0,true):addto(self.panel_map,-1)
	end
end


function GuildExploreMainView:setrule( ... )
	local pames = {
        title = "仙盟探索规则",
        tid = "#tid_Explore_rule_101",
    }
	WindowControler:showWindow("TreasureGuiZeView",pames)
end


function GuildExploreMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.LeftTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_map, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_6, UIAlignTypes.LeftBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_3,UIAlignTypes.LeftBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_yeqian1,UIAlignTypes.RightBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_yeqian2,UIAlignTypes.RightBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_yeqian3,UIAlignTypes.RightBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res,UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_5,UIAlignTypes.MiddleTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_2, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_jingli,UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_dingwei,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_stop,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_invite, UIAlignTypes.LeftBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_t,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_event, UIAlignTypes.LeftBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_t, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_tips, UIAlignTypes.MiddleTop)

end


function GuildExploreMainView:initData()
	-- TODO
end

function GuildExploreMainView:initView()
	-- TODO
end

function GuildExploreMainView:updateUI()
	-- TODO
end

--点击小地图
function GuildExploreMainView:pressClickMiniMap(  )
	echo("======点击小地图===========")
end


--设置灵力
function GuildExploreMainView:setEnergy()
	local sum = GuildExploreModel:getMaxEnergy(  )
	local num = GuildExploreModel:getEnegry( ) 
	self.panel_jingli.txt_1:setString(num.."/"..sum)
	local percent = (num/sum)*100
	self.panel_jingli.progress_1:setPercent(percent)

	--如果是满的
	if num == sum then
		if self._energyAni then
			self._energyAni:setVisible(false)
		end
	else
		--计算坐标
		local wid = 200
		local xpos = math.round(wid * num/sum)
		if not self._energyAni then
			self._energyAni = self:createUIArmature("UI_xianmengtansuo_a", "UI_xianmengtansuo_a_jindutiao", self.panel_jingli, true)
			self._energyAni:pos(xpos,-10)
		else
			self._energyAni:setVisible(true)
			self._energyAni:stopAllActions()
			self._energyAni:moveTo(0.2,xpos,-10)
		end
	end

	
end


function GuildExploreMainView:getEnergy()
	if self.getEnergyTime  then
		if (self.getEnergyTime%300) == 0 then
			self:setEnergy()
		end
		self.getEnergyTime = self.getEnergyTime + 1
	else
		self.getEnergyTime = 1
	end
end



--设置灵泉buff的界面显示
function GuildExploreMainView:showBuffUI(event)
	local isShow =  GuildExploreModel:getbuffList()
	echo("===isShow  buff  list ======",isShow)
	if isShow then
		self.UI_2:setVisible(true)

		local params = event and event.params or false

		--延迟10帧去做
		self.UI_2:delayCall(c_func(self.UI_2.initData,self.UI_2,params),0.8)
		-- self.UI_2:initData(event and event.params or nil)
	else
		self.UI_2:setVisible(false)
	end
end



function GuildExploreMainView:setRewardButton()
	

	local isok,isHaveReward = GuildExploreModel:getoffLineReward() --GuildExploreEventModel:getMonsterGetReward()
	if isHaveReward and table.length(isHaveReward) ~= 0 then
		self.btn_2:setVisible(true)
	else
		self.btn_2:setVisible(false)
	end

end

function GuildExploreMainView:openRewardUI()
	WindowControler:showWindow("GuildExploreRewardView");
end



--设置左下按钮点击事件
function GuildExploreMainView:setDownButton()
	local cellFunc = {
		[1] = self.openChatView,
		[2] = self.checkSendPartner,
		[3] = self.openEventView,
		[4] = self.openTaskView,
		[5] = self.openRankView,

	}
	for i=1,5 do
		self.panel_6["btn_"..i]:setTouchedFunc(c_func(cellFunc[i], self,nil),nil,true);
		if i== 5 then
			self.panel_6["btn_"..i]:setVisible(false)
		end
	end

	for i=1,3 do
		self["mc_yeqian"..i]:setTouchedFunc(c_func(self.showEquipment, self,i),nil,true);
	end

	self.btn_2:setTouchedFunc(c_func(self.openRewardUI, self),nil,true);
end

--打开聊天界面
function GuildExploreMainView:openChatView()
	if self.panel_stop:isVisible() then
		return
	end
	WindowControler:showWindow("ChatMainView",3);
end

--打开派遣记录
function GuildExploreMainView:checkSendPartner()
	if self.panel_stop:isVisible() then
		return
	end
	GuildExploreEventModel:showGuildExploreCheckDispatchView()
	-- WindowControler:showWindow("GuildExploreCheckDispatchView");
end

--打开事件记录界面
function GuildExploreMainView:openEventView()
	if self.panel_stop:isVisible() then
		return
	end
	echo("======事件记录界面======")
	GuildExploreEventModel:showMapEventUI(true)
	self.eventListRed = false
	self:setButtonRed()
end


--打开任务界面
function GuildExploreMainView:openTaskView(_type)
	if self.panel_stop:isVisible() then
		return
	end
	if _type then
		if type(_type) == "table" then
			_type = nil
		end
	end
	local function callBack( event )
		if event.result then
			local allData = event.result.data
			-- dump(allData,"============任务界面的数据=============")
			WindowControler:showWindow("GuildExploreQuestView",_type,allData)
		end
	end


	local params = {}
	GuildExploreServer:getTaskListData(params,callBack)
	
end

--排行榜界面
function GuildExploreMainView:openRankView()
	if self.panel_stop:isVisible() then
		return
	end
	-- GuildExploreEventModel:showRankUI()
end

function GuildExploreMainView:equipmentButton()
	for i=1,3 do
		self["mc_yeqian"..i]:showFrame(1)
	end
end

--显示装备界面
function GuildExploreMainView:showEquipment(_type)
	if self.panel_stop:isVisible() then
		return
	end
	-- local view = WindowControler:createWindowNode("BulleTip")
	self["mc_yeqian".._type]:showFrame(2)
	local function cellFunc()
		self:equipmentButton()
	end

	local function callBack(event)
		if event.result then
			local data = event.result.data 
			-- dump(data,"======获取装备信息========= ")
			WindowControler:showWindow("GuildExploreEquipmentView",_type,data,cellFunc);
		end
	end

	local params = {
		tid = _type,
	}

	GuildExploreServer:getEquipmentData(params,callBack)
end




function GuildExploreMainView:leftBottomButtonRunaction()
	self.panel_6:setVisible(false)
	self.panel_5:setVisible(false)
	self.btn_3:setTouchedFunc(c_func(self.toRight,self),nil,true)
	self.panel_6.btn_shou:setTouchedFunc(c_func(self.toLeft,self),nil,true)
	self.panel_res.btn_1:setTouchedFunc(c_func(self.clickLeftAndRight,self),nil,true)
	self.btn_dingwei:setTouchedFunc(c_func(self.getCharPos,self),nil,true)
	self.panel_5:setTouchedFunc(c_func(function ()end),nil,true)
	self:toRight()
end

function GuildExploreMainView:getCharPos()
	self.controler.mapControler:setMapFollowPlayer()
end

function GuildExploreMainView:clickLeftAndRight()
    local open = self.openResButton
    if not self.selectbtn_1 then
    	self.selectbtn_1 = true
	    if open then
	        self.panel_res.btn_1:setScaleY(1)
	        self:toup()
	    else
	       	self.panel_res.btn_1:setScaleY(-1)
	        self:todown()
	    end
	end
end


---退出
function GuildExploreMainView:toup()
	self.btn_3:setTouchEnabled(false)
	self.panel_res.btn_1:setTouchEnabled(false)
    local function _closeCallback()
        self.openResButton = false
        self.panel_res.btn_1:setTouchEnabled(true)
        self.panel_5:setVisible(false)
        self.selectbtn_1 = false
    end
    local  _rect = self.panel_5:getContainerBox();
    local  _otherx,_othery=self.panel_5:getPosition()
    local  _mAction=cc.MoveTo:create(0.2,cc.p(_otherx,_othery + _rect.height));
    local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(_closeCallback));
    self.panel_5:runAction(_mSeq);
end 

function GuildExploreMainView:todown()
	self.panel_res.btn_1:setTouchEnabled(false)
    self.panel_5:setVisible(true)
     local function callback()
     	self.openResButton = true
        self.panel_res.btn_1:setTouchEnabled(true)
        self.selectbtn_1 = false
    end
    local  _otherx,_othery=self.panel_5:getPosition();
    local  panelx,panely=self.panel_res:getPosition();
    self.panel_5:setPositionY(panely+100)
    local  _mAction = cc.MoveTo:create(0.2,cc.p(_otherx,panely -50 ));
    local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(callback));
    self.panel_5:runAction(_mSeq);
end


---退出
function GuildExploreMainView:toLeft()
	self.btn_3:setTouchEnabled(false)
	self.panel_6.btn_shou:setTouchEnabled(false)
    local function _closeCallback()
        self.panel_6:setVisible(false)
        self.btn_3:setTouchEnabled(true)
        self.panel_6.btn_shou:setTouchEnabled(true)
        self.btn_3:setVisible(true)
        self.openLeftButton = false
    end
    local  _rect = self.panel_6:getContainerBox();
    local  _otherx,_othery=self.btn_3:getPosition()
    local  _mAction=cc.MoveTo:create(0.2,cc.p(_otherx-_rect.width,_othery));
    local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(_closeCallback));
    self.panel_6:runAction(_mSeq);

end 

function GuildExploreMainView:taskRunaction()
	self.panel_t:setVisible(true)
	self.btn_t:setVisible(true)
	self.panel_t.btn_2:setTouchedFunc(c_func(self.closeTaskView, self),nil,true);
	self.btn_t:setTouchedFunc(c_func(self.showComplete, self),nil,true);
end

---退出
function GuildExploreMainView:closeTaskView()
    if not self.close_UI then
        local  _otherx,_othery=self.btn_t:getPosition();
    	local function _closeCallback()
            self.close_UI = true
    	end
    	local  _mAction=cc.MoveTo:create(0.2,cc.p(self._rect.x - 450,_othery))-- - _rect.width*1.5,_othery));
    	local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(_closeCallback));
    	self.panel_t:runAction(_mSeq);
        self.btn_t:setVisible(true)
    end
end     

--打开
function GuildExploreMainView:showComplete()

    if self.close_UI then
        ---界面加入弹出动画
        local  _otherx,_othery=self.btn_t:getPosition();
        local  _mAction = cc.MoveTo:create(0.2,cc.p(self._rect.x,_othery));
        local time = act.delaytime(0.5)
        local function _closeCallback()
                self.close_UI = false
        end
        self.panel_t:runAction(cc.Sequence:create(_mAction,time,cc.CallFunc:create(_closeCallback)));
        self.btn_t:setVisible(false)
    end
end




function GuildExploreMainView:toRight()
	self.btn_3:setTouchEnabled(false)
	self.btn_3:setVisible(false)
	self.panel_6.btn_shou:setTouchEnabled(false)
    self.panel_6:setVisible(true)
     local function callback()
     	self.openLeftButton = true
        self.btn_3:setTouchEnabled(true)
        self.panel_6.btn_shou:setTouchEnabled(true)
    end
    -- local  _rect = self.panel_6:getContainerBox();
    local  _otherx,_othery=self.btn_3:getPosition();
    local  panelx,panely=self.panel_6:getPosition();
    local _rect = self.panel_6:getContainerBox()
    self.panel_6:setPositionX(panelx - _rect.width)
    -- self.panel_6:setPosition(cc.p(_otherx - _rect.width,_othery));
    local  _mAction = cc.MoveTo:create(0.2,cc.p(_otherx,panely));
    local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(callback));
    self.panel_6:runAction(_mSeq);

    if self.panel_t:isVisible() then
    	local x = self.panel_t:getPositionX()
    	local  _mAction = cc.MoveTo:create(0.2,cc.p(x,self.panel_t_y));
	    local  _mSeq=cc.Sequence:create(_mAction);
	    self.panel_t:runAction(_mSeq);
    end
end

--当退出战斗时 需要缓存的数据 以便 恢复这个ui时 记录数据
function GuildExploreMainView:getEnterBattleCacheData(  )
    return  {mapPos= self.controler.mapControler.currentPos }
end

--当退出战斗后 恢复这个ui时 ,会把这个cacheData传递给ui
function GuildExploreMainView:onBattleExitResume(cacheData )
    local mapPos = cacheData.mapPos
    if mapPos then
    	self.controler.mapControler:updatePos(mapPos.x,mapPos.y,true)
    	self.controler.mapControler:setWillRefreshCount(1)
    end

end

function GuildExploreMainView:button_close()
	self:startHide()
	--退出战场
	GuildExploreServer:onExitExplore( )
end

--播放开场动画
function GuildExploreMainView:createEnterAni()
	local ani = self:createUIArmature("UI_arena","UI_arena_yunceng", self._root, false)
	ani:gotoAndPause(1)
	ani:pos(GameVars.gameResWidth/2,-GameVars.gameResHeight/2)

	local tempFunc = function (  )
		ani:play()
		-- self:showComplete()
	end

	--15帧之后播放这个动画
	ani:delayCall(tempFunc, 0.5)
	return 
end

--当ui被加载到舞台时
function GuildExploreMainView:onAddtoParent( )
	require("game.sys.view.guildExplore.init")
	self.controler = ExploreControler.new(self)
	GuildExploreModel:setControler( self.controler )
	self.mapControler = self.controler.mapControler
	--计算mini node的宽高
	local w = GameVars.width  *self.mapControler.miniScaleX
	local h = GameVars.height  *self.mapControler.miniScaleY
	self.panel_map.scale9_me:setContentSize(cc.size(w,h))
	self.panel_map.scale9_me:anchor(1,1)

end




--初始化装备图标位置
function GuildExploreMainView:updateEquipmentPos( isInit )
	local openArr =GuildExploreModel:getBuffOpenState(  )
	if not self._initXpos then
		self._initXpos,self._initYpos = self.mc_yeqian3:getPosition()
	end

	local index =0
	for i=#openArr,1,-1 do
		local panel = self["mc_yeqian"..i]
		if openArr[i] then
			if isInit == true then
				panel:pos(self:getEquipmentPos(index))
			else
				--创建必须是隐藏状态的才会飞入
				if not panel:isVisible() then
					panel:setVisible(true)
					self:createBuffAni(i,index)
				else
					panel:pos(self:getEquipmentPos(index))
				end
			end
			
			index = index+1
		else
			panel:visible(false)
		end
	end

end

function GuildExploreMainView:createBuffAni( index ,posIndex )
	local aniArr = {
		"UI_xianmengtansuo_a_buff_gongi_tingliu", "UI_xianmengtansuo_a_buff_fangyu_tingliu", "UI_xianmengtansuo_a_buff_jiasu"
	}

	local ani2Arr = {
		"UI_xianmengtansuo_a_gongjifajue","UI_xianmengtansuo_a_fangyufajue","UI_xianmengtansuo_a_shenxingfajue"
	}
	index = tonumber(index)
	local offsetArr = {
		{250,-GameVars.halfResHeight},
		{300,-GameVars.halfResHeight},
		{280,-GameVars.halfResHeight+20},
	}

	local offset = offsetArr[index]
	local offset2 = {GameVars.halfResWidth,-GameVars.halfResHeight-200}
	local aniName = aniArr[(index)]
	local aniName2 = ani2Arr[(index)]

	--停留时间
	local timeArr = {1.5,1.8,1.5 }
	local time = timeArr[(index)]

	
	local ani = self:createUIArmature("UI_xianmengtansuo_a", aniName, self._root)
	ani:pos(offset[1],offset[2])
	FuncArmature.setArmaturePlaySpeed( ani ,1)
	

	

	local tempFunc = function (  )
		local ani = self:createUIArmature("UI_xianmengtansuo_a", aniName2, self._root)
		ani:pos(offset2[1],offset2[2])
	end

	local panel = self["mc_yeqian"..index]
	self:delayCall(tempFunc,0.2 )
	panel:setVisible(true)
	local targetX,targetY = self:getEquipmentPos(posIndex)
	panel:zorder(1)
	panel:pos(GameVars.halfResWidth ,-GameVars.halfResHeight )
	panel:scale(0)
	panel:setOpacity(0)

	local actionDealy = act.delaytime(time)
	local action1 = act.scaleto(0.5,1.5)
	local actionScaleBounce = act.bounceout(action1)

	local actionfade = act.fadeto(0.1,255)

	local spawan = act.spawn(actionScaleBounce,actionfade)

	local action2 = act.moveto(0.5,targetX, targetY )
	local actionMoveSine = act.sinout(action2)

	-- local spawan = act.spawn(action1,actionfade,actionMoveSine)	

	local act4 = act.scaleto(0.2, 1)
	local seq = act.sequence(actionDealy,spawan,  actionMoveSine,act4)
	panel:runAction(seq)

end

--获取某个装备坐标的相对位置
function GuildExploreMainView:getEquipmentPos( index )
	return self._initXpos - (tonumber(index)) *80 ,self._initYpos 
end



--被剔除仙盟
function GuildExploreMainView:removeGuild()
	WindowControler:showTips(GameConfig.getLanguage("#tid_group_xianmeng_001"))
	GuildExploreServer:onExitExplore( )
end



function GuildExploreMainView:deleteMe()
	if self.controler then
		self.controler:deleteMe()
		self.controler = nil
	end


	GuildExploreMainView.super.deleteMe(self);
end

--获得资源按钮的位置
function GuildExploreMainView:getResPos(_type)
	echo("========_type=======",_type)

 	if tonumber(_type) == 10 then
		endPos = cc.p(self.panel_jingli:getPosition())
	elseif tonumber(_type) <= 4 then
		local panel = self.panel_res.UI_res["panel_".._type]
		local pos = cc.p(panel:getPosition())
		endPos = panel:convertLocalToNodeLocalPos(self,{x=0,y=0})
		endPos.x = endPos.x + 5
		endPos.y = endPos.y - 10
	else
		local btn_1 = self.panel_res.btn_1
		endPos  = btn_1:convertLocalToNodeLocalPos(self,{x=0,y=0})
		endPos.x = endPos.x -20
		endPos.y = endPos.y +15
	end
	return endPos
end

return GuildExploreMainView;
