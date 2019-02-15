--
--Author:      zhuguangyuan
--DateTime:    2017-10-24 08:40:35
--Description: 仙盟GVE活动
--Description: 选择队友界面
--


local GuildActivityTeamChooseView = class("GuildActivityTeamChooseView", UIBase);

function GuildActivityTeamChooseView:ctor(winName,myTeamId)
    GuildActivityTeamChooseView.super.ctor(self, winName)
	self._myTeamId = myTeamId

end

function GuildActivityTeamChooseView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:getCanInviteMembers(self._guildId)
end 

function GuildActivityTeamChooseView:registerEvent()
	GuildActivityTeamChooseView.super.registerEvent(self);
	self.UI_1.btn_close:setTap(c_func(self.onClose, self)) 
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
	
end
-- 关闭界面
function GuildActivityTeamChooseView:onClose()
	self:startHide()
end

function GuildActivityTeamChooseView:initData()
	self._guildId = UserModel:guildId()
	self._chooseMembers = {}
	self._chooseMembersFlag = {}
	self._chooseMembersNum = 0

	self._haveBeenInvites = GuildActMainModel:getRecordInvitedMembers()
	-- dump(self._haveBeenInvites,"已经被邀请过的玩家")
	self:updateData()
end

function GuildActivityTeamChooseView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_068")) 

	self.scrollList = self.scroll_1
	self.btn_1:setVisible(false)

	self:initScrollCfg()

	self.UI_1.mc_1:showFrame(1)
	local btnSure = self.UI_1.mc_1:getCurFrameView().btn_1
	btnSure:setTap(c_func(self.inviteAllies, self)) 
end
function GuildActivityTeamChooseView:inviteAllies()
	if table.isEmpty(self.canInviteMembers) then
		self:startHide()
		return
	end
	if self._chooseMembersNum == 0 then
		WindowControler:showTips( GameConfig.getLanguage("#tid_guild_069")) 
		return
	end

	local function callBack( serverData )
		if serverData.result then
			-- WindowControler:showTips( { text = "邀请成功！" })
			local inviteTime,_ = math.modf(serverData.result.serverInfo.serverTime/1000) 
			GuildActMainModel:recordInvitedMembers( self._chooseMembers,inviteTime )
			self:startHide()
		end
	end
	for k,v in pairs(self._chooseMembersFlag) do
		if v == true then
			table.insert(self._chooseMembers, k)
		end
	end
	-- dump(self._chooseMembers,"选中的盟友数组")
	GuildActivityServer:inviteAllies(self._guildId,self._myTeamId,self._chooseMembers,callBack)
end
function GuildActivityTeamChooseView:initScrollCfg()
	local function createMemberFunc( _oneMemberRid )
		-- dump(_oneMemberRid,"一个成员的id")
		local itemView = UIBaseDef:cloneOneView(self.btn_1)
		local btnPanel = itemView:getUpPanel()
		local playerInfo = GuildModel:getMemberInfo(_oneMemberRid)
		btnPanel.txt_1:setString(playerInfo.name)
		-- 头像
	    local icon = FuncUserHead.getHeadIcon(playerInfo.head,playerInfo.avatar)
	    icon = FuncRes.iconHero( icon )
		local iconSprite = display.newSprite(icon):pos(0,-3)
		-- btnPanel.panel_tou1.ctn_icon:removeAllChildren()
		-- btnPanel.panel_tou1.ctn_icon:addChild(iconSprite)
		-- iconSprite:setScale(1.2)
			
		local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
	    headMaskSprite:pos(-1,0)
	    headMaskSprite:setScale(0.99)

	    -- local iconSpr = display.newSprite(FuncRes.iconHead(iconName)) 
	    local _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSprite)
	    -- _spriteIcon:setScale(1.2)
	    btnPanel.panel_tou1.ctn_icon:removeAllChildren()
	    btnPanel.panel_tou1.ctn_icon:addChild(_spriteIcon)

		-- 头像框
		local frameicon = FuncUserHead.getHeadFramIcon(playerInfo.frame)
    	frameicon = FuncRes.iconHero( frameicon )
		local frameSprite = display.newSprite(frameicon)
		btnPanel.panel_tou1.ctn_tou:removeAllChildren()
		btnPanel.panel_tou1.ctn_tou:addChild(frameSprite)
		-- frameSprite:setScale(1.2)

		btnPanel.panel_tou1.txt_1:visible(false)
		btnPanel.panel_tou1.panel_lv.txt_3:setString(playerInfo.level)

		self._chooseMembersFlag[_oneMemberRid] = false
		btnPanel.panel_dui:setVisible(self._chooseMembersFlag[_oneMemberRid])
		-- self._chooseMembersNum = self._chooseMembersNum + 1

		itemView:setTap(function()
			if (self._chooseMembersNum >= 5) and (not self._chooseMembersFlag[_oneMemberRid]) then
				WindowControler:showTips( GameConfig.getLanguage("#tid_guild_070"))
				return 
			end
			if table.isKeyIn(self._haveBeenInvites,_oneMemberRid) then
				local curTime = TimeControler:getTime()
				local lastInviteTime = self._haveBeenInvites[_oneMemberRid].inviteTime 
				-- echo("\n\n\n 哈哈哈_________ curTime,lastInviteTime _________ ",curTime,lastInviteTime)
				if ( curTime - lastInviteTime) < 10 then
					WindowControler:showTips( { text = (10 - curTime + lastInviteTime)..GameConfig.getLanguage("#tid_guild_071") })
					return
				end
			end

			self._chooseMembersFlag[_oneMemberRid] = not self._chooseMembersFlag[_oneMemberRid]
			btnPanel.panel_dui:setVisible(self._chooseMembersFlag[_oneMemberRid])
			if self._chooseMembersFlag[_oneMemberRid] == true then
				self._chooseMembersNum = self._chooseMembersNum + 1
			else
				self._chooseMembersNum = self._chooseMembersNum - 1
			end
			echo("当前选中的盟友数量 = ",self._chooseMembersNum)

		end) 
		return itemView
	end

	self.listParams =  {
		{
		   	data = nil,
	        createFunc = createMemberFunc,
	        perNums = 2,
	        offsetX = 3,
	        offsetY = 10,
	        widthGap = 0, 
	        heightGap = 4,
	        itemRect = {x = 0,y = -100,width = 290,height = 100},
	        perFrame = 1,
	        cellWithGroup = 1
    	}
	}
end

function GuildActivityTeamChooseView:buildScrollParams( ... )
	-- dump(self.canInviteMembers,"队伍内所有成员的信息===")

	-- local params = nil
	-- local ListParams = {}
	-- for k,v in pairs(self.canInviteMembers) do
	-- 	params = table.deepCopy(self.listParams)
	-- 	params.data = {v}
	-- 	ListParams[#ListParams + 1] = params
	-- end
	self.listParams[1].data = self.canInviteMembers --self._onlinePlayers --
	return self.listParams 
end

function GuildActivityTeamChooseView:initViewAlign()
	-- TODO
end

function GuildActivityTeamChooseView:updateData()

end

function GuildActivityTeamChooseView:getCanInviteMembers(_guildId)
	self.canInviteMembers = {}
	local function callBack( serverData )
		-- 服务器返回房间列表
		if serverData.error then
			return
		end
		self.canInviteMembers = serverData.result.data.inviteRids
		dump(self.canInviteMembers,"服务器返回可被邀请的仙盟成员列表")
		if table.isEmpty(self.canInviteMembers) then  
			WindowControler:showTips( GameConfig.getLanguage("#tid_guild_072"))
		end
		self:updateUI()
	end
	GuildActivityServer:getCanInviteMembers(_guildId,callBack)
end

function GuildActivityTeamChooseView:getOnlinePlayers( _playerList,_callback22)
	-- 只邀请在线玩家
	local num1 = #_playerList
	local param = {}
    param.infos = {}
	for i = 1,20 do
        local rid = _playerList[i]
        if not rid then
        	break
        end
        param.infos[i] = {}
        param.infos[i].sec = ChatModel:getRidBySec(rid,true)
        param.infos[i].rid = rid
	end

	local function _callback(_param)
        -- dump(_param.result,"______________在线请求返回数据")
        if _param.result ~= nil then
            local onlinedata = _param.result.data.onlines
            for k,v in ipairs(onlinedata) do
            	if not self._onlinePlayers then
            		self._onlinePlayers = {}
            	end
            	self._onlinePlayers[#self._onlinePlayers + 1] = v
            end
            if _callback22 then
            	_callback22()
            end
        end
    end
	ChatServer:sendPlayIsonLine(param,_callback)
end
function GuildActivityTeamChooseView:updateUI()
	local data = self:buildScrollParams()
	self.scrollList:cancleCacheView()
    self.scrollList:styleFill(data)
    -- self.scrollList:styleFill(self.listParams)
end

function GuildActivityTeamChooseView:deleteMe()
	-- TODO

	GuildActivityTeamChooseView.super.deleteMe(self);
end

return GuildActivityTeamChooseView;
