--
--Author:      zhuguangyuan
--DateTime:    2017-10-24 08:42:11
--Description: 组队主界面
--


local GuildActivityTeamMainView = class("GuildActivityTeamMainView", UIBase);

function GuildActivityTeamMainView:ctor(winName)
    GuildActivityTeamMainView.super.ctor(self, winName)
end

function GuildActivityTeamMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	
	self:initViewAlign()
	self:initView()
end 


--=================================================================================
--=================================================================================
function GuildActivityTeamMainView:registerEvent()
	GuildActivityTeamMainView.super.registerEvent(self);
	self.UI_1.btn_1:setTap(c_func(self.onClose, self)) 

	self.btn_1:setTap(c_func(self.getTeamList, self)) 

	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_CREATE_SUCCEED, self.joinTeamSucceed, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_JOIN_TEAM_SUCCEED, self.joinTeamSucceed, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_LEAVE_TEAM_SUCCEED, self.leaveTeamSucceed, self)
    EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_BE_KICKOUT_BY_TEAMLEADER, self.leaveTeamSucceed, self)
 	
    EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_MEMBERS_CHANGE, self.onTeamMembersChanged, self)
    -- 队伍开始挑战则关闭组队界面
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_START_CHALLENGE, self.onClose, self)

	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_ONE_TEAM_DISMISS, self.getTeamList, self)

	
end
--关闭界面
function GuildActivityTeamMainView:onClose()
	self:startHide()
end

function GuildActivityTeamMainView:onTeamMembersChanged()
	self:getTeamList()
end

function GuildActivityTeamMainView:beginChallenge()
	-- self:getTeamList()
	self:startHide()
end


function GuildActivityTeamMainView:joinTeamSucceed( event )
	-- dump(event.params,"成功加入队伍")
	self:gotoTeamView()
	self:getTeamList()
	WindowControler:showWindow("GuildActivityTeamCreateView")
end
function GuildActivityTeamMainView:leaveTeamSucceed( event )
	-- dump(event.params,"成功离开队伍")
	self:getTeamList()
	self:gotoTeamView()
end
--=================================================================================
--=================================================================================
function GuildActivityTeamMainView:initData()
	self._guildId = UserModel:guildId()
	self:getTeamList()
	self.maxMemberNum = 3
end

function GuildActivityTeamMainView:getTeamList()
	self.teamList = {}
	local function callBack( serverData )
		if serverData.error then
			return
		end		
		self.teamList = serverData.result.data.teams
		-- dump(self.teamList,"服务器返回房间列表")
		self:updateUI()
	end
	if not GuildActMainModel:isInNewGuide() then
		GuildActivityServer:getTeamList(self._guildId,callBack)
	end
end

function GuildActivityTeamMainView:createTeam(_guildId)
	if not GuildActMainModel:isInNewGuide() then
		GuildActMainModel:createTeam(_guildId)
	else
		WindowControler:showWindow("GuildActivityTeamCreateView")
		self:startHide()
	end
end
function GuildActivityTeamMainView:joinTeam(_guildId,_teamId)
	self:getTeamList()
	GuildActMainModel:joinTeam(_guildId,_teamId)
end

--=================================================================================
--=================================================================================
function GuildActivityTeamMainView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_075")) 
	self.panel_2:setVisible(false)
	self.teamScrollList = self.scroll_1
	self:initTeamScroll()

	self:gotoTeamView()
end

--加入队伍
function GuildActivityTeamMainView:gotoTeamView()
	if not GuildActMainModel:getMyTeamId() then
		self.btn_2:setBtnStr(GameConfig.getLanguage("#tid_guild_079"),"txt_1")
		self.btn_2:setTap(c_func(self.createTeam,self,self._guildId))
	else
		self.btn_2:setBtnStr(GameConfig.getLanguage("#tid_guild_080"),"txt_1")
		self.btn_2:setTap(function() 
			local myTeamData = self.teamList[GuildActMainModel:getMyTeamId()]
			WindowControler:showWindow("GuildActivityTeamCreateView",myTeamData)
		end) 
	end
end
function GuildActivityTeamMainView:initTeamScroll( ... )
	local function createTeamFunc( _oneTeamData )
		-- dump(_oneTeamData,"一只队伍的信息===")
		local itemView = UIBaseDef:cloneOneView(self.panel_2)
		self:updateOneTeamView( _oneTeamData,itemView )
		return itemView
	end
	local function refreshTeamFunc( _oneTeamData,itemView )
		self:updateOneTeamView( _oneTeamData,itemView )
		return itemView
	end
	self.teamListParams =  {
	   	data = nil,
        createFunc = createTeamFunc,
        updateCellFunc = refreshTeamFunc,
        perNums= 1,
        offsetX = 10,
        offsetY = 10,
        widthGap = 0,
        heightGap = 10,
        itemRect = {x = 0,y = -150,width = 967,height = 150},
        perFrame = 1,
        cellWithGroup = 1
	}
end

function GuildActivityTeamMainView:updateOneTeamView( _itemData,_itemView )
	local memberNum = 0 
	-- _itemView.mc_1:setVisible(false)
	for k,v in pairs(_itemData.members) do
		local function _callBack( ... )
			self:gotoTeamView()
			self:updateUI()
		end
		echo("___ k,UserModel:rid() , GuildActMainModel:getMyTeamId()___",k,UserModel:rid() , GuildActMainModel:getMyTeamId())
		if (k == UserModel:rid()) and (not GuildActMainModel:getMyTeamId()) then
			local _data = {}
			_data["teamInfo"] = _itemData
			-- dump(_data, "__________ 不同客户端登录同一个rid _")
			GuildActMainModel:updateTeamInfo( _data,_callBack )
		end

		memberNum = memberNum + 1
		if memberNum > self.maxMemberNum then
			echoError("_________队伍成员数量超过默认最大数量_________________")
			return
		end

		-- for i=1,3 do
			local panelView = _itemView["panel_tou"..memberNum]
			local playerInfo = GuildModel:getMemberInfo(k)
			dump(playerInfo, "==== 组队是玩家信息 playerInfo")
			-- 头像
		    local icon = FuncUserHead.getHeadIcon(playerInfo.head,playerInfo.avatar)
		    icon = FuncRes.iconHero( icon )
			local iconSprite = display.newSprite(icon):pos(0,-3)
			-- panelView.ctn_icon:removeAllChildren()
			-- panelView.ctn_icon:addChild(iconSprite)

			local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
		    headMaskSprite:pos(-1,0)
		    headMaskSprite:setScale(0.99)

		    -- local iconSpr = display.newSprite(FuncRes.iconHead(iconName)) 
		    local _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSprite)
		    -- _spriteIcon:setScale(1.2)
		    panelView.ctn_icon:removeAllChildren()
		    panelView.ctn_icon:addChild(_spriteIcon)

			-- iconSprite:setScale(1.2)
			-- 头像框
			local frameicon = FuncUserHead.getHeadFramIcon(playerInfo.frame)
	    	frameicon = FuncRes.iconHero( frameicon )
			local frameSprite = display.newSprite(frameicon)
			panelView.ctn_tou:removeAllChildren()
			panelView.ctn_tou:addChild(frameSprite)
			-- frameSprite:setScale(1.2)
		-- end


    -- local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
    -- headMaskSprite:pos(-1,0)
    -- headMaskSprite:setScale(0.99)

    -- local iconSpr = display.newSprite(FuncRes.iconHead(iconName)) 
    -- local _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
    -- _spriteIcon:setScale(1.2)
    -- ctn:removeAllChildren()
    -- ctn:addChild(_spriteIcon)
    -- return _spriteIcon

			panelView.panel_lv.txt_3:setString(playerInfo.level)
			panelView.txt_1:setString(playerInfo.name)

		-- local memberView = _itemView["mc_"..memberNum]
		-- memberView:showFrame(1)

		-- local contentView = memberView:getCurFrameView()
		-- local playerInfo = GuildModel:getMemberInfo(k)
		-- dump(playerInfo, "playerInfo")

		-- -- HomeModel:setPlayerIcon( contentView.panel_avatar.ctn_1)
		-- contentView.txt_1:setString(playerInfo.name)
		-- contentView.panel_avatar.txt_1:setString(playerInfo.level)
		-- -- contentView.UI_1.panel_lv.txt_3:setString(playerInfo.level)
		-- -- contentView.UI_1.mc_dou:setVisible(false)
		-- -- contentView.UI_1.mc_kuang:showFrame(17)
		-- -- contentView.UI_1.mc_di:showFrame(16)
		-- --头像
	 --    local icon = FuncUserHead.getHeadIcon(playerInfo.head,playerInfo.avatar)
	 --    icon = FuncRes.iconHero( icon )
		-- local iconSprite = display.newSprite(icon):pos(0,-3)
		-- local avatarCtn = contentView.panel_avatar.ctn_1
		-- avatarCtn:removeAllChildren()
		-- avatarCtn:addChild(iconSprite)
		-- iconSprite:setScale(1)
	end
	for i = memberNum + 1,3 do
		local panelView = _itemView["panel_tou"..i]
		panelView.panel_lv:setVisible(false)
		panelView.txt_1:setVisible(false)
	end
	-- 加入队伍
	if not GuildActMainModel:getMyTeamId() then
		_itemView.btn_1:setTap(c_func(self.joinTeam,self,self._guildId,_itemData.id))
	else
		FilterTools.setGrayFilter(_itemView.btn_1)
	end
	return _itemView
end

function GuildActivityTeamMainView:buildScrollParams( ... )
	-- dump(self.teamList,"所有队伍信息===")
	local params = nil
	local ListParams = {}
	if not table.isEmpty(self.teamList) then
		for k,v in pairs(self.teamList) do
			params = table.deepCopy(self.teamListParams)
			params.data = {v}
			ListParams[#ListParams + 1] = params
		end
	end
	return ListParams 
end

--=================================================================================
--=================================================================================
function GuildActivityTeamMainView:initViewAlign()
	-- TODO
end





--=================================================================================
--=================================================================================
function GuildActivityTeamMainView:updateUI()
	self.teamScrollList:cancleCacheView()
	local data = self:buildScrollParams()
	if not table.isEmpty(data) then
		self.teamScrollList:setVisible(true)
	    self.teamScrollList:styleFill(data)
	else
		self.teamScrollList:setVisible(false)
	end
end

function GuildActivityTeamMainView:deleteMe()
	-- TODO

	GuildActivityTeamMainView.super.deleteMe(self);
end

return GuildActivityTeamMainView;
