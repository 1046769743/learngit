--
--Author:      zhuguangyuan
--DateTime:    2017-10-24 08:41:10
--Description: 仙盟GVE活动
--Description: 被邀请的邀请盟内成员的收到的信息小框，点击可跳转
--


local GuildActivityTeamInviteView = class("GuildActivityTeamInviteView", UIBase);

function GuildActivityTeamInviteView:ctor(winName,data)
    GuildActivityTeamInviteView.super.ctor(self, winName)
    self._data = data
    if FuncGuildActivity.isDebug then
   		dump(self._data,"传进邀请界面的数据") 
   	end
   	
    if not self._data then
    	self._data = {
    	["name"]   = "终极416",
		["rid"]    = "dev_2099",
		["teamId"] = "activity_171214_11",
    	}
    end

    --  准备guildModel的伙伴数据
    GuildControler:getMemberList("")
end

function GuildActivityTeamInviteView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildActivityTeamInviteView:registerEvent()
	GuildActivityTeamInviteView.super.registerEvent(self);
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self), 0);

	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_JOIN_TEAM_SUCCEED, self.joinTeamSucceed, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
end
--关闭界面
function GuildActivityTeamInviteView:onClose()
	self:startHide()
end

function GuildActivityTeamInviteView:joinTeamSucceed( event )
	-- dump(event.params,"成功加入队伍")
	self._myTeamId = event.params.teamId 
	self:unscheduleUpdate()

	WindowControler:showWindow("GuildActivityTeamCreateView")
	GuildActMainModel:inviteViewSetVisible(false)
	self:startHide()
end

-- 更新关闭倒计时进度 倒计时8秒
function GuildActivityTeamInviteView:updateFrame()
	if self.leftTime < 0 then
		self:unscheduleUpdate()
		-- GuildActMainModel:inviteViewSetVisible(false)
		if self.leftTime < 0 then
			self:startHide()
		end
	end
	if (self.frameCount % GameVars.GAMEFRAMERATE == 0) then 
		self.UI_1.mc_1:getCurFrameView().btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_guild_076").."("..self.leftTime..")")
		self.leftTime = self.leftTime - 1

		-- local preogress = self.panel_1.progress_1
	 --    local percent = self.leftTime / 8 * 100
	 --    preogress:setDirection(ProgressBar.l_r)
	 --    preogress:setPercent(percent)
	end
	self.frameCount = self.frameCount + 1
end

function GuildActivityTeamInviteView:initData()
	self._guildId = UserModel:guildId()
	-- self._teamId = 1

end

function GuildActivityTeamInviteView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_077")) 
	self.UI_1.btn_close:setVisible(false)
	self.UI_1.mc_1:showFrame(2)

	local currentView = self.UI_1.mc_1:getCurFrameView()
	local text1 = GameConfig.getLanguageWithSwap("#tid_food_tip_3005",self._data.name)
	self.rich_1:setString(text1)
	currentView.btn_2:setTouchedFunc(c_func(self.refuseInvitation,self),nil,true)
	-- currentView.btn_2:getUpPanel().txt_1:setString("丑拒")
	currentView.btn_1:setTouchedFunc(c_func(self.acceptInvitation,self),nil,true)
	currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_guild_078"))
end
function GuildActivityTeamInviteView:refuseInvitation( ... )
	echo("—————————————————— 丑拒 —————————————————— ")
	-- GuildActMainModel:inviteViewSetVisible(false)
	self:startHide()
end
function GuildActivityTeamInviteView:acceptInvitation( ... )
	if self.havedSentRequest then
		echo("发送请求还未返回")
		return
	end

	if GuildActMainModel:getMyTeamId() then
		echo("已经加入队伍了")
		WindowControler:showWindow("GuildActivityTeamCreateView")
		self:startHide()
		return
	end
	local function prepareGVEDataCallBack( ... )
		local function callBack( serverData )
			self.havedSentRequest = false
			GuildActMainModel:inviteViewSetVisible(false)
			if serverData.error then
				self:startHide()
				return
			end
		end
		GuildActivityServer:joinTeam(self._guildId,self._data.teamId,callBack)
	end
	GuildActMainModel:requestGVEData(prepareGVEDataCallBack)
	self.havedSentRequest = true
end

function GuildActivityTeamInviteView:initViewAlign()
	-- TODO
end

function GuildActivityTeamInviteView:updateUI(data)
	if data then
		self._data = data
	end
	
	self.leftTime = 8
	self.frameCount = 0
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self), 0);
end

function GuildActivityTeamInviteView:deleteMe()
	-- TODO

	GuildActivityTeamInviteView.super.deleteMe(self);
end

return GuildActivityTeamInviteView;
