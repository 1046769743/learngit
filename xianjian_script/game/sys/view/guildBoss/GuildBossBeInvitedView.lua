-- GuildBossBeInvitedView
--Author:      wk
--DateTime:    2018-05-15 
--Description: 被邀请共闯秘境的邀请界面
--


local GuildBossBeInvitedView = class("GuildBossBeInvitedView", UIBase);

function GuildBossBeInvitedView:ctor(winName)
    GuildBossBeInvitedView.super.ctor(self, winName)
end

function GuildBossBeInvitedView:loadUIComplete()
	self.panel_1:setVisible(false)
	self:registerEvent()

	self.btn_close:setTouchedFunc(c_func(self.close, self))
	-- self:registClickClose("out")
	self:registClickClose(-1, c_func( function() 
		self:close()
	end))


	self:initData()
end 

function GuildBossBeInvitedView:registerEvent()
	GuildBossBeInvitedView.super.registerEvent(self);

		--共闯秘境的邀请推送
	EventControler:addEventListener("notify_guildBoss_invite_team_6230", self.initData, self)

	-- EventControler:addEventListener("notify_guildBoss_invite_team_6230", self.inviteAddTeam, self)
	EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP,self.onUIShowComp,self)
	
end

function GuildBossBeInvitedView:onUIShowComp()
	local battleView = WindowControler:getWindow( "BattleView" )
	if battleView then
		GuildBossModel.notifyView:setVisible(false)
	end
end

function GuildBossBeInvitedView:initData(event)
	if event then
		local data = event.params.params.data
		data[1].time = TimeControler:getServerTime()
		local haveData = false
		for k,v in pairs(GuildBossModel.inviteAddTeamList) do
			if v[1]._id == data[1]._id then
				GuildBossModel.inviteAddTeamList[k] = data
				haveData = true
			end
		end
		if not haveData then
			table.insert(GuildBossModel.inviteAddTeamList,data)
		end
	end
	GuildBossModel:offShowNotifyView()

	self.invitedList = GuildBossModel:getInviteAddTeamList()

	local sortFunc = function ( t1,t2 )
        return t1[1].time > t2[1].time
    end

    table.sort(self.invitedList,sortFunc)

	self:setlist()

end

function GuildBossBeInvitedView:setlist()

	local function createCellFunc(itemBaseData)
        local itemView = UIBaseDef:cloneOneView(self.panel_1)        		
		self:updateCellView(itemView, itemBaseData)
		return itemView

    end

    local function reuseUpdateCellFunc(itemBaseData, itemView)
        self:updateCellView(itemView, itemBaseData)
    end

	local scrollParams = {
		{
			data = self.invitedList,	        
	        createFunc = createCellFunc,
	        offsetX = 5,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        perNum = 1,
	        itemRect = {x = 0, y = -95, width = 650, height = 95},
		}
	}
	self.scroll_1:cancleCacheView();
	self.scroll_1:styleFill(scrollParams)
	self.scroll_1:hideDragBar()
end



function GuildBossBeInvitedView:updateCellView(_cell,basedata)

	dump(basedata,"2222222222222222222222")

	local data = basedata[1]


	_cell.UI_1:setPlayerInfo(data)

	_cell.txt_1:setString(data.name or "少侠")

	-- _cell.txt_3:setString(data.abilityNew.formationTotal or 1000)

	_cell.UI_power:setPower(data.abilityNew.formationTotal or 1000)

	local bossID = data.guildBossId or "1"
	local bossNameTid = FuncGuildBoss.getBossNameById(bossID)
	local tid = "#tid_guildboss_1003"
	local bossName  = GameConfig.getLanguage(bossNameTid)
	local str = FuncTranslate._getLanguageWithSwap(tid,bossName)

	_cell.txt_4:setString(str)

	-- local  = GameConfig.getLanguage("#tid_guildboss_1004")
	 
	local time = FuncGuild.getOutDDHHSSTime(data.time)
	_cell.txt_7:setString(time)

	_cell.btn_1:setTouchedFunc(c_func(self.gotoGuildBossView, self,data))
end



--前往共闯秘境邀请界面
function GuildBossBeInvitedView:gotoGuildBossView(groupData)
	echo("==========前往共闯秘境邀请界面=============")
	dump(groupData,"====加入队伍的数据====")
	local function _callback( event )
		if event.result then
			dump(event.result,"========加入队伍返回数据====1111====")

			self:getguildInfoData(groupData)
			-- 
			GuildBossModel:removeInviteAddTeamList(groupData) 
			self:close()
		else

		end
	end
	local params = {
		groupId = groupData.groupId
	}

	GuildBossServer:addGuildBoss(params,_callback)
end

--跳转到邀请界面
function GuildBossBeInvitedView:getguildInfoData(groupData)
	local function _callfun(event)
		if event.result then
			dump(event.result,"========加入队伍返回数据=====222222===")

			local dataList = event.result.data.inviteList
			GuildBossModel:setInviteList(dataList)

			if GuildModel._baseGuildInfo._id == nil then
				local function _callfun()
					WindowControler:showWindow("GuildBossInviteView",groupData.guildBossId or "1",false,groupData)
				end
				GuildControler:getMemberList("",_callfun)
			else
				WindowControler:showWindow("GuildBossInviteView",groupData.guildBossId or "1",false,groupData)
			end


			
		-- local otherData = 
		-- WindowControler:showWindow("GuildBossInviteView",groupData.guildBossId,true,otherData)
		end
	end

	GuildBossServer:getInvitedList({},_callfun)
end



function GuildBossBeInvitedView:close()
	-- GuildBossModel:setInviteAddTeamList({})
	self:startHide()
end
function GuildBossBeInvitedView:deleteMe()
	GuildBossBeInvitedView.super.deleteMe(self);
end

return GuildBossBeInvitedView;
