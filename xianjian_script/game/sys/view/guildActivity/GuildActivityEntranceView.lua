--
--Author:      zhuguangyuan
--DateTime:    2017-11-20 17:01:58
--Description: gve活动入口界面
--



local GuildActivityEntranceView = class("GuildActivityEntranceView", UIBase);

function GuildActivityEntranceView:ctor(winName)
    GuildActivityEntranceView.super.ctor(self, winName)
end

function GuildActivityEntranceView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	self:addRewardShow()
end 

function GuildActivityEntranceView:addRewardShow()
	for systemId = 1,3 do
		local data = FuncGuild.getGuildActive(systemId)
		local view = self["panel_"..systemId]
		for i=1,3 do
			local ui = view["UI_"..i]
			local reward = data.icon[i]
			ui:setResItemData({reward = reward})
			ui:showResItemNum(false)
			local res = string.split(reward, ",")
	        local rewardType = res[1]      ----类型
	        local rewardNum = res[3]   ---总数量
	        local rewardId = res[2]          ---物品ID
	        -- rewardView:setScxa
	        FuncCommUI.regesitShowResView(ui,
	                rewardType, rewardNum, rewardId, reward, true, true);
                
		end
	end
end
--=================================================================================
--=================================================================================
function GuildActivityEntranceView:registerEvent()
	GuildActivityEntranceView.super.registerEvent(self);

	EventControler:addEventListener(GuildEvent.GUILD_ACTIVITY_REDPOINT_CHANGED, self.updateRedPointStatus, self)

	-- 更新gve活动红点
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_GOT_REWARD, self.updateGveRedPoint, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP_WEEK, self.updateGveRedPoint, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_SOMEONE_INPUT_INGREDIENTS, self.updateGveRedPoint, self)
	EventControler:addEventListener(GuildExploreEvent.GUILDE_EXPLORE_ROKOU_RED_FRESISH, self.updateGuildExploreRedPoint, self)
	-- -- 更新仙盟副本红点
	-- EventControler:addEventListener(GuildBossEvent.GUILDBOSS_ONE_ECTYPE_OPEN, self.updateGuildBossRedPoint, self)
	-- EventControler:addEventListener(GuildBossEvent.GUILDBOSS_TIMER_ECTYPE_TIME_OUT, self.updateGuildBossRedPoint, self)
	-- EventControler:addEventListener(GuildBossEvent.GUILDBOSS_ONE_ECTYPE_PASS, self.updateGuildBossRedPoint, self)
	-- EventControler:addEventListener(GuildBossEvent.GUILDBOSS_TIMER_RESET_DAY_COUNT, self.updateGuildBossRedPoint, self)
	-- EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.updateGuildBossRedPoint, self)

	self.btn_back:setTap(c_func(self.onClose, self))  -- 返回
end

--
function GuildActivityEntranceView:updateRedPointStatus( event )
	local sysType = event.params.sysType
	if sysType == "gve" then
		self:updateGveRedPoint()
	elseif sysType == "guildBoss" then
		self:updateGuildBossRedPoint()
	else
		self:updateGuildExploreRedPoint()
	end
end

function GuildActivityEntranceView:updateGuildExploreRedPoint()
	local isshow = GuildExploreModel:getEntranceRed()
	self.panel_3.panel_red:setVisible(isshow)
end
-- 更新gve红点
function GuildActivityEntranceView:updateGveRedPoint( event )
	local isshow = GuildActMainModel:isShowGuildActRedPoint()
	self.panel_1.panel_red:setVisible(isshow)
end
-- 更新仙盟boss 红点
function GuildActivityEntranceView:updateGuildBossRedPoint( event )
	local isshow = GuildBossModel:isShowGuildBossRedPoint() --false --GuildActMainModel:isShowGuildActRedPoint()
	self.panel_2.panel_red:setVisible(isshow)
end

--关闭按钮
function GuildActivityEntranceView:onClose()
	self:startHide()
end

--=================================================================================
--=================================================================================
function GuildActivityEntranceView:initData()

end


--=================================================================================
--=================================================================================
function GuildActivityEntranceView:initView()
	-- gve
	-- self._curActivityId = "1"
	local sysName = FuncCommon.SYSTEM_NAME.GUILDACTIVITY
	local open = FuncCommon.isSystemOpen(sysName)
	if open then
		self.panel_1.panel_off:visible(false)
		-- FilterTools.clearFilter( self.panel_1 ) -- self.panel_1:setVisible(true)
	else
		self.panel_1.panel_off:visible(true)
		-- TODO 五测临时屏蔽仙盟酒家系统
		self.panel_1:visible(false)
		-- FilterTools.setGrayFilter( self.panel_1 ,120 ) -- self.panel_1:setVisible(false)
	end
	self.panel_1:setTouchedFunc(c_func(self.openActivity, self,self._curActivityId))
	self:updateGveRedPoint()
	-- self.panel_1:setVisible(false)

	-- gveboss
	self.panel_2:setTouchedFunc(c_func(self.openGuildBossMainView, self))
	self.panel_2:setVisible(false)
	local textArr = FuncGuild.setOpenTimeText()
	self.panel_2.txt_2:setString("每日"..textArr[1][1].."-"..textArr[1][2]..","..textArr[2][1].."-"..textArr[2][2])

	self:updateGuildBossRedPoint()


	self.panel_3:setTouchedFunc(c_func(self.guildExplore, self))

	self:updateGuildExploreRedPoint()
end

function GuildActivityEntranceView:guildExplore()
	-- GuildExploreServer:startGetServerInfo(  )
	local isopen = FuncGuildExplore.isOnTime()
	if isopen then
		GuildExploreServer:startGetServerInfo(  )
	else
		WindowControler:showTips("未到开启时间")
	end
end


--=================================================================================
--=================================================================================
function GuildActivityEntranceView:initViewAlign()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
end

function GuildActivityEntranceView:updateUI()
end

-- 进入仙盟gve活动界面
function GuildActivityEntranceView:openActivity( _curActivityId )
	-- local sysName = FuncCommon.SYSTEM_NAME.GUILDACTIVITY
	-- local open = FuncCommon.isSystemOpen(sysName)
	-- if not open then
	-- 	WindowControler:showTips("33级开启活动")
	-- 	return 
	-- end
	-- local function callBack()
	-- 	WindowControler:showWindow("GuildActivityMainView")
	-- end
	-- GuildActMainModel:requestGVEData(callBack)
	GuildActMainModel:enterGuildActMainView()
end

-- 进入仙盟副本界面
function GuildActivityEntranceView:openGuildBossMainView()
	-- GuildBossModel:enterGuildBossMainView() 0--GuildBossOpenView
	-- WindowControler:showWindow("GuildBossOpenView")
	GuildControler:showGuildBossUI()

end

function GuildActivityEntranceView:deleteMe()
	GuildActivityEntranceView.super.deleteMe(self);
end

return GuildActivityEntranceView;
