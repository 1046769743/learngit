-- GuildBossInviteView
--Author:      wk
--DateTime:    2018-05-15 
--Description: 共闯秘境的邀请界面
--

local GuildBossInviteView = class("GuildBossInviteView", UIBase);

local dataType = {
	MeData = 1,
	otherData = 2,

}
local addGroupType = {
	notifyAdd = 1

}


function GuildBossInviteView:ctor(winName,bossId,_me,otherData)
    GuildBossInviteView.super.ctor(self, winName)
    self.bossId = bossId
    self._me = _me

    dump(otherData,"其他玩家的数据 =======")
    self.otherData = otherData
end

function GuildBossInviteView:loadUIComplete()
	self:registerEvent()
	local panel = self.panel_mengyoulist
	panel.panel_2:setVisible(false)
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
	self:initData(addGroupType.notifyAdd)
end 

function GuildBossInviteView:registerEvent()
	GuildBossInviteView.super.registerEvent(self);
	-- self.btn_close:setTouchedFunc(c_func(self.close, self))
	self.panel_bg.btn_close:setTouchedFunc(c_func(self.close, self))

	EventControler:addEventListener(GuildBossEvent.REMOVE_OTHER_DATA,self.removeOtherData, self)

	---推送有人加入队伍
	EventControler:addEventListener("notify_guildBoss_add_team_6232", self.notifyAddTeam, self)

	---推送有人退出队伍
	EventControler:addEventListener("notify_guildBoss_remove_team_6234", self.notifyRemoveTeam, self)
	---被踢出队伍
	EventControler:addEventListener("notify_guildBoss_add_team_6236", self.notifyKickOutTeam, self)
	--进入布阵 关闭界面
	EventControler:addEventListener(GuildBossEvent.CLOSE_INVITE_VIEW, self.startHide, self)
end

--踢出队伍
function GuildBossInviteView:notifyKickOutTeam(pames)
	dump(pames.pames,"推送踢出队伍的数据 ==== ") 
	WindowControler:showTips(GameConfig.getLanguage("#tid_guildboss_1006"))
	self:startHide()
end




function GuildBossInviteView:notifyRemoveTeam(pames)
	dump(pames.pames,"推送有人退出队伍的数据 ==== ") 

	self.otherData = nil
	self._me = true
	self:initData(addGroupType.notifyAdd)


end

function GuildBossInviteView:notifyAddTeam(event)
	

	local data = event.params.params.data
	dump(data,"邀请推送的数据 ==== ")
	local trid = data.trid
	local plarerData  =  GuildModel:getMemberInfo(trid)----玩家的数据
	self.otherData = plarerData

	self:initData(addGroupType.notifyAdd)
end

function GuildBossInviteView:removeOtherData()
	self.otherData = nil
	self:initData(addGroupType.notifyAdd)

end

----其他玩家进入的队伍中
function GuildBossInviteView:otherPerpleInto()
	local plarerData = {} --玩家数据
	self:initLeftOtherData(dataType.otherData,plarerData)
end


function GuildBossInviteView:initData(_type)


	local myself --= dataType.MeData
	local other --= dataType.otherData

	if _type == addGroupType.notifyAdd  then
		myself = dataType.MeData
		other = dataType.otherData
	else
		myself = dataType.otherData
		other = dataType.MeData
	end

	local otherPlayerData = nil
	if self.otherData ~= nil then
		otherPlayerData = self.otherData
	end
	self:initLeftMySelfData(myself,otherPlayerData)
	self:initLeftOtherData(other,otherPlayerData)
	self:initRightList()
	self:starBattleButton()
end

--开始战斗按钮
function GuildBossInviteView:starBattleButton()

	local  btn_kaizhan = self.panel_mengyoulist.btn_kaizhan
	btn_kaizhan:setTouchedFunc(c_func(self.starBattle, self))
	if self._me  then
		btn_kaizhan:setVisible(true)
	else
		btn_kaizhan:setVisible(false)
	end 

end

-- 开始战斗
function GuildBossInviteView:starBattle()
	echo("========开始战斗===")

	local leftChallengeTimes = GuildBossModel:getLeftChallengeTimes(UserModel:rid()) --self:getLeftChallengeTimes( _selectedEctypeData, )
	-- echo("========leftChallengeTimes=======",leftChallengeTimes)
	if leftChallengeTimes > 0 then

	else
		WindowControler:showTips( GameConfig.getLanguage("#tid_guildBoss_004"))
		return
	end


	---邀请到了，是多人战斗
	if self.otherPlayData then
		echo("========开始战斗= 进布阵界面==")
		GuildBossModel:startBattle(self.bossId)
	else---没有邀请到了，去单人确定战斗界面
		WindowControler:showWindow("GuildBossGoAloneView",nil,1,self.bossId)
	end
end

function GuildBossInviteView:initRightList()
	
	self.guildMembersList =  GuildBossModel:getInviteList()
	-- {
	-- 	[1] = {
	-- 		id = "dev16_12529",
	-- 		guildBossCount = 0,
 --        	logoutTime     = 0,
	-- 	},


	-- }  --GuildBossModel:getInviteList() --GuildModel:getGuildMembersInfo()

	-- dump(self.guildMembersList,"3333333333333333")

	local panel = self.panel_mengyoulist
	panel.panel_2:setVisible(false)
	local function createCellFunc(itemBaseData)
        local itemView = UIBaseDef:cloneOneView(panel.panel_2)        		
		self:updateCellView(itemView, itemBaseData)
		return itemView

    end

    local function updateFunc(itemBaseData, itemView)
        self:updateCellView(itemView, itemBaseData)
    end

	local scrollParams = {
		{
			data = self.guildMembersList,	        
	        createFunc = createCellFunc,
	        updateFunc = updateFunc,
	        offsetX = 5,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -45, width = 395, height = 45},
		}
	}

	panel.scroll_1:styleFill(scrollParams)
	panel.scroll_1:hideDragBar()


end

function GuildBossInviteView:updateCellView(_cell,itemData)

	local id = itemData.id
	-- dump( GuildModel._membersInfo,"000000000000000")
	local data = GuildModel:getMemberInfo(id)
	-- dump(data,"玩家数据 ======11111111111=======")
	local isline = false  --是否在线
	if itemData.logoutTime == 0 then
		isline = true
	end
	
	local frame = 1
	if isline then
		frame = 1
		_cell.mc_list:showFrame(frame)
		_cell.mc_wanjiadi:showFrame(3)
	else
		frame = 2
		_cell.mc_list:showFrame(frame)
		_cell.mc_wanjiadi:showFrame(2)
	end

	local panel = _cell.mc_list:getViewByFrame(frame)

	panel.txt_name:setString(data.name or "少侠")
	panel.txt_dengji:setString(data.level or 1)
	panel.txt_lv:setString(data.ability or 1000)
	local num = FuncGuildBoss.getBossAttackTimes()
	if not self.otherData then
		_cell.mc_2:setVisible(true)
		if frame == 1 then  ---在线 
			if itemData.guildBossCount < num then  --次数打完前
				local isapp = false --是否被邀请
				local appTime = itemData.appTime
				if appTime then
					isapp = true
				end
				if isapp then
					_cell.mc_2:showFrame(3)
					local text =  _cell.mc_2:getViewByFrame(3).txt_time
					local time = appTime - TimeControler:getServerTime() --临时用的数据
					if time <= 0 then
						_cell.mc_2:showFrame(1)
						_cell.mc_2:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.inviteButton, self,data))
					else
						text:setString(time.."s")
					end

				else
					_cell.mc_2:showFrame(1)
					_cell.mc_2:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.inviteButton, self,data))
				end
			else
				_cell.mc_2:setVisible(false)
			end
		elseif frame == 2 then
			_cell.mc_2:showFrame(2)
		end
	else
		_cell.mc_2:setVisible(false)
	end

end


--邀请按钮
function GuildBossInviteView:inviteButton(playerData)
	dump(playerData,"====邀请对象的数据====")
	local function _callback( event )
		if event.result then
			dump(event.result,"========邀请返回数据========")
			-- WindowControler:showWindow("GuildBossInviteView")
			GuildBossModel:setinviteListAppTime(playerData._id,true)
			WindowControler:showTips(GameConfig.getLanguage("#tid_guildboss_1002")) --"#tid_guild_007")
		else

		end
	end
	local params = {
		trid = playerData._id
	}
	GuildBossServer:inviteGuildBossInvite(params,_callback)

end





--初始化左边自己的数据
function GuildBossInviteView:initLeftMySelfData(_type,plarerData)


	local panel = self["panel_mengyou".._type]
	panel.mc_1:showFrame(1)
	local cell = panel.mc_1:getViewByFrame(1)
	panel.btn_T:setVisible(false)

	local level = UserModel:level()
	cell.txt_playerlever:setString(level)
	local name = UserModel:name()
	cell.txt_playername:setString(name)
	local power =  UserModel:getcharSumAbility()
	cell.UI_1:setPower(power)

	local spinenode = GarmentModel:getCharGarmentSpine()
	-- spinenode:setScale(1.2)
	panel.ctn_1:removeAllChildren()
	panel.ctn_1:addChild(spinenode)
end

--初始化左边邀请的玩家数据
function GuildBossInviteView:initLeftOtherData(_type,playData)

	dump(playData,"33333333333333",_type)
	self.otherPlayData = playData
	local panel = self["panel_mengyou".._type]
	if playData ~= nil then
		panel.mc_1:showFrame(1)
		local cell = panel.mc_1:getViewByFrame(1)
		panel.btn_T:setVisible(true)
		panel.btn_T:setTouchedFunc(c_func(self.kickOut, self,playData))
		local level = playData.level or 1
		cell.txt_playerlever:setString(level)
		local name = playData.name or "少侠"
		cell.txt_playername:setString(name)
		local ability = 1000
		if playData.abilityNew then
			if type(playData.abilityNew) == "table" then
				ability = playData.abilityNew.formationTotal
			else
				ability = playData.ability
			end
		else
			ability = playData.ability
		end
		local power =  ability
		cell.UI_1:setPower(power)
		local avatarId = playData.avatar
		local garmentId = nil
		if playData.userExt then
			garmentId = playData.userExt.garmentId 
		else
			garmentId = playData.garmentId
			if garmentId and garmentId == 0 then
				garmentId = ""
			end
		end

		local sp = GarmentModel:getSpineViewByAvatarAndGarmentId(avatarId, garmentId)
		panel.ctn_1:removeAllChildren()
		-- sp:setScale(1.2)
		panel.ctn_1:addChild(sp)

		if self._me  then
			panel.btn_T:setVisible(true)
		else
			panel.btn_T:setVisible(false)
		end 
	else
		panel.ctn_1:removeAllChildren()
		panel.mc_1:showFrame(2)
		panel.btn_T:setVisible(false)
	end

end

--踢出
function GuildBossInviteView:kickOut(playData)
	WindowControler:showWindow("GuildBossGoAloneView",playData,2,self.bossId)
end


--计时刷新时间
function GuildBossInviteView:updateFrame()
	

	local scroll_1 = self.panel_mengyoulist.scroll_1
	if self.guildMembersList ~= nil then
		for k,v in pairs(self.guildMembersList) do
			local _cell = scroll_1:getViewByData(v);
			if _cell then
				self:updateCellView(_cell,v)
			end
		end
	end
end


function GuildBossInviteView:close()
	self:leaveTeam()
	self:startHide()
end


function GuildBossInviteView:deleteMe()
	GuildBossInviteView.super.deleteMe(self);
end

--离开房间
function GuildBossInviteView:leaveTeam()
	local function _callback( event )
		if event.result then
			dump(event.result,"========离开房间返回数据========")
			WindowControler:showTips(GameConfig.getLanguage("#tid_guildboss_1001"))
		else

		end
	end

	local params = {}
	GuildBossServer:leaveGuildBoss(params,_callback)
end

return GuildBossInviteView;
