--
--Author:      zhuguangyuan
--DateTime:    2017-10-24 08:40:55
--Description: 仙盟GVE活动
--Description: 创建队伍界面 传入队伍信息
--


local GuildActivityTeamCreateView = class("GuildActivityTeamCreateView", UIBase);

function GuildActivityTeamCreateView:ctor(winName)
    GuildActivityTeamCreateView.super.ctor(self, winName)
end

function GuildActivityTeamCreateView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	-- self:initPopUpBubble(self.panel_bubble)
end 

--=================================================================================
--=================================================================================
function GuildActivityTeamCreateView:registerEvent()
	GuildActivityTeamCreateView.super.registerEvent(self);
	-- self.UI_1.btn_1:setTap(c_func(self.onClose, self)) 
	self.btn_1:setTap(c_func(self.leaveTeamReconfirm, self)) 
	self.btn_talk:setTap(c_func(self.showChatView, self))

	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_LEAVE_TEAM_CONFIRM, self.leaveTeam, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_LEAVE_TEAM_SUCCEED, self.leaveTeamSucceed, self)

    EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_MEMBERS_CHANGE, self.onTeamMembersChanged, self)
    EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_BE_KICKOUT_BY_TEAMLEADER, self.beKickOutByTeamLeader, self)

    EventControler:addEventListener("notify_guild_activity_chat_5660",self.receiveOneMessage,self);

    -- 队伍开始挑战则关闭队伍界面
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_START_CHALLENGE, self.onClose, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
end
function GuildActivityTeamCreateView:onClose()
	self:startHide()
end

-- 收到一条消息
function GuildActivityTeamCreateView:receiveOneMessage( serverData )
	dump(serverData.params, "收到聊天信息")
	local data = serverData.params.params.data
	local _rid = data.rid
	local _view = self.ridToViewMap[_rid]
	local words = data.content
	local panelView = _view:getCurFrameView().panel_bubble
	if panelView then
		self:popUpBubble(panelView,words)
	end
end
-- 弹出对话气泡
function GuildActivityTeamCreateView:popUpBubble(_view,words)
	if _view then
		_view:visible(true)
		local scaleto_1 = act.scaleto(0.1,1.2,1.2)
		local scaleto_2 = act.scaleto(0.05,1.0,1.0)
		local delaytime_2 = act.delaytime(4)
	 	local scaleto_3 = act.scaleto(0.1,0)
	 	local delaytime_3 = act.delaytime(2)
	 	local callfun = act.callfunc(function ()
	 		echo("_______words_________",words)
			_view.rich_1:setString(ChatModel:toStringExchangleImage(words))
	 	end)
		local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)
		_view:runAction(seqAct)
	end
end

-- 弹出聊天框
function GuildActivityTeamCreateView:showChatView()
	if GuildActMainModel:isInNewGuide() then
		return
	end
	ChatModel:settematype("guild")
	-- FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.CHAT)
	WindowControler:showWindow("ChatMainView", 4)
end
function GuildActivityTeamCreateView:chatBtnClick()
	FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.CHAT)
end

-- 离开队伍确认
function GuildActivityTeamCreateView:leaveTeamReconfirm(  )
	if GuildActMainModel:isInNewGuide() then
		self:startHide()
		return 
	end
	local viewType = FuncGuildActivity.tipViewType.quitTeam
	local params = {}
	WindowControler:showWindow("GuildActivityTeamQuitReconfirmView",viewType,params)
end
-- 离开队伍
function GuildActivityTeamCreateView:leaveTeam()	
	GuildActMainModel:leaveTeam(self._guildId,self._myTeamId)
end
-- 离开队伍成功
function GuildActivityTeamCreateView:leaveTeamSucceed( event )
	-- dump(event.params,"成功离开队伍")
	echo("_______成功离开队伍_______________")
	
	ChatModel:setTeamMessage({})
	ChatModel:settematype(nil)
	self:delayCall(c_func(self.startHide), 0.1)
end

function GuildActivityTeamCreateView:beKickOutByTeamLeader( event )
	WindowControler:showTips( GameConfig.getLanguage("#tid_guild_073")) 
	EventControler:dispatchEvent(ChatEvent.REMOVE_CHAT_UI)
	ChatModel:settematype(nil)
	self:delayCall(c_func(self.startHide), 0.1)
end
-- 根据是否是队长显示决定是否显示开始挑战按钮
function GuildActivityTeamCreateView:openInteractView( )
	if GuildActMainModel:isInNewGuide() then
		self.btn_2:setVisible(true)
		local function gotoScene()
			-- 初始化用于教学的怪
			GuildActMainModel:setDefaultMonsterArr()
			WindowControler:showWindow("GuildActivityInteractView")	
			self:startHide()	
		end
		self.btn_2:setTap(c_func(gotoScene)) 
		self:showPlayerAndLittleSister()
		return
	end

	local isLeader = (self._teamleaderRid == UserModel:_id()) and true or false
	if not isLeader then
		self.btn_2:setVisible(false)
	else
		self.btn_2:setVisible(true)
		self.btn_2:setTap(c_func(self.checkOpenCondition, self)) 
	end
end

-- 新手引导时显示玩家和说话的小姐姐的战斗立绘在队伍
function GuildActivityTeamCreateView:showPlayerAndLittleSister( ... )
	-- 玩家名字立绘
	self.mc_qian1:showFrame(1)
	local contentView = self.mc_qian1:getCurFrameView()
	contentView.panel_bubble:visible(false)
	contentView.btn_qingli:visible(false)
	contentView.panel_dui:visible(true)

	contentView.panel_1:setVisible(true)
	contentView.panel_1.txt_1:setString(UserModel:name())
	local garmentId = GarmentModel:getOnGarmentId()
	local playerSpine = GarmentModel:getSpineViewByAvatarAndGarmentId(UserModel:avatar(), garmentId);
	contentView.ctn_1:addChild(playerSpine)
	-- 蓝葵名字立绘
	self.mc_qian2:showFrame(1)
	local contentView2 = self.mc_qian2:getCurFrameView()
	contentView2.panel_bubble:visible(false)
	contentView2.btn_qingli:visible(false)
	contentView2.panel_dui:visible(false)

	local littleSisterId = "5018" -- 蓝葵的partnerId
	contentView2.panel_1:setVisible(true)
	contentView2.panel_1.txt_1:setString(FuncPartner.getPartnerName(littleSisterId))
	local playerSpine2 = FuncPartner.getHeroSpineByPartnerIdAndSkin( littleSisterId,"" )
	contentView2.ctn_1:addChild(playerSpine2)
	-- 等待玩家加入
	self.mc_qian3:showFrame(2)
end

function GuildActivityTeamCreateView:checkOpenCondition()
	local isMemberNumOk = self:getTeamMemberNum(self._membersList) >= self.minMemberNum and true or false
    if not isMemberNumOk then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_074")) 
    else
    	-- 发送开始挑战请求
    	GuildActMainModel:startChallenge(self._guildId,self._myTeamId)
    	-- self:startHide()
    	-- WindowControler:showWindow("GuildActivityInteractView")
    end
end


function GuildActivityTeamCreateView:onTeamMembersChanged()
	self:updateData()
	self:updateUI()
end

function GuildActivityTeamCreateView:getTeamLeader(_members)
	if not _members then
		return nil
	end
	for k,v in pairs(_members) do
		if v.captain then
			return k
		end
	end
	return nil
end

function GuildActivityTeamCreateView:getTeamMemberNum(_members)
	if not _members then
		return 0
	end
	local num = 0
	for k,v in pairs(_members) do
		num = num + 1
	end
	return num
end

--=================================================================================
--=================================================================================
function GuildActivityTeamCreateView:initData()
	self.maxMemberNum = 3
	self.minMemberNum = 1

	self.ridToViewMap = {} -- 玩家对应view

	self._guildId = UserModel:guildId()
	self._myTeamId = GuildActMainModel:getMyTeamId()
	self._membersList = GuildActMainModel:getCurTeamMembers()
	self._teamleaderRid = self:getTeamLeader(self._membersList)
	-- dump(self._membersList,"当前队伍的成员")
end


--=================================================================================
--=================================================================================
function GuildActivityTeamCreateView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_075")) 
	self.UI_1.btn_1:visible(false)
	-- self:openInteractView()

	for i=1,self.maxMemberNum do
		local mcView = self["mc_qian" .. i]
		mcView:showFrame(1)
		mcView.currentView.panel_1:setVisible(false)
		mcView:showFrame(2)
		mcView.currentView.panel_1:setVisible(false)
	end
end

function GuildActivityTeamCreateView:sortMembers()
	if GuildActMainModel:isInNewGuide() then
		return
	end
	
	local teamleaderData = self._membersList[self._teamleaderRid]
	-- 队长排在第一位
	if teamleaderData then
		self.mc_qian1:setVisible(true)
		self:updataOneMemberView(teamleaderData, self.mc_qian1)
		self.ridToViewMap[teamleaderData.rid] = self["mc_qian"..1]
	end

	local i = 2
	for k,v in pairs(self._membersList) do
		if not v.captain then
			self["mc_qian"..i]:setVisible(true)
			self:updataOneMemberView(v, self["mc_qian"..i])
			self.ridToViewMap[v.rid] = self["mc_qian"..i]
			i = i + 1
		end
	end

	for j = i,self.maxMemberNum do
		-- self["mc_qian"..j]:showFrame(2)
		self["mc_qian"..j]:setVisible(true)
		self:updataOneMemberView({}, self["mc_qian"..j])
	end
end
-- 
function GuildActivityTeamCreateView:updataOneMemberView(_oneMemberData, itemView)
	dump(_oneMemberData, "_oneMemberData", nesting)
	if GuildActMainModel:isInNewGuide() then
		return 
	end
	if not table.isEmpty(_oneMemberData) then
		itemView:showFrame(1)

		contentView = itemView:getCurFrameView()
		contentView.panel_bubble:visible(false)

		local playerInfo = GuildModel:getMemberInfo(_oneMemberData.rid)
		if FuncGuildActivity.isDebug then
			dump(playerInfo,"组队时玩家详细信息")
		end
		-- 玩家名字
		contentView.panel_1:setVisible(true)
		contentView.panel_1.txt_1:setString(playerInfo.name)
		-- 玩家spine
		local garmentId = GarmentModel.DefaultGarmentId
		if playerInfo.garmentId ~= 0 then
			garmentId = playerInfo.garmentId
		end
		local playerSpine = GarmentModel:getSpineViewByAvatarAndGarmentId(playerInfo.avatar, garmentId);
		contentView.ctn_1:removeAllChildren()
		contentView.ctn_1:addChild(playerSpine)

		-- 请离开图标
		local flag = false
		contentView.btn_qingli:setVisible(flag)
		local node = display.newNode()

		-- 点击区域测试代码
		local color = color or cc.c4b(255,0,0,120)
		local layer = cc.LayerColor:create(color)
		-- node:addChild(layer)
		node:setTouchEnabled(true)
		node:setTouchSwallowEnabled(true)

		node:addto(contentView.ctn_1,1):size(150,150)
		node:anchor(0,0)
		node:pos(-73,0)
		-- layer:setContentSize(node:getContentSize() )
		node:setTouchedFunc(c_func(self.showKickOutView,self,contentView,_oneMemberData.rid));	

		-- 显示队长图标
		if _oneMemberData.captain then
			contentView.panel_dui:setVisible(true)
		else
			contentView.panel_dui:setVisible(false)
		end
	else -- 邀请盟友图标
		itemView:showFrame(2)
		contentView = itemView:getCurFrameView()
		contentView.panel_lv:setTouchEnabled(true)
		contentView.panel_lv:setTouchedFunc(function()
			WindowControler:showWindow("GuildActivityTeamChooseView",self._myTeamId)
		end) 
	end
end


function GuildActivityTeamCreateView:showKickOutView( _contentView,_memberRid )
	if UserModel:rid() ~= self._teamleaderRid then
		echo("___ 队长才能踢人")
		return
	end
	if UserModel:rid() == _memberRid then
		echo("___ 不能自己踢自己")
		return
	end
	flag = not flag
	_contentView.btn_qingli:setVisible(flag)
	if flag == true then
		_contentView.btn_qingli:setTap(c_func(self.kickoutOneperson,self,_memberRid))
	end
end

function GuildActivityTeamCreateView:kickoutOneperson(_trid)
	GuildActMainModel:kickOutOnePerson(self._guildId,self._myTeamId,_trid)
end
--=================================================================================
--=================================================================================
function GuildActivityTeamCreateView:initViewAlign()
	-- TODO
end
function GuildActivityTeamCreateView:updateData()
	self._membersList = GuildActMainModel:getCurTeamMembers()
	self._teamleaderRid = self:getTeamLeader(self._membersList)
end
function GuildActivityTeamCreateView:updateUI()
	self:openInteractView( )
	self:sortMembers()
end

function GuildActivityTeamCreateView:deleteMe()
	-- TODO

	GuildActivityTeamCreateView.super.deleteMe(self);
end

return GuildActivityTeamCreateView;
