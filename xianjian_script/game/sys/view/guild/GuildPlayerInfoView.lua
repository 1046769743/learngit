-- GuildPlayerInfoView
-- Author: Wk
-- Date: 2017-10-10
-- 公会玩家详情界面
local GuildPlayerInfoView = class("GuildPlayerInfoView", UIBase);

function GuildPlayerInfoView:ctor(winName,playerdata)
    GuildPlayerInfoView.super.ctor(self, winName);
    self.playerdata = playerdata
end

function GuildPlayerInfoView:loadUIComplete()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_033")) 
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self.UI_1.mc_1:setVisible(false)
	self:registClickClose(-1, c_func( function()
        self:press_btn_close()
    end , self))
	self:registerEvent()
	self:setbutton()
	self:initData()
end 

function GuildPlayerInfoView:registerEvent()
	-- EventControler:addEventListener(GuildEvent.REFRESH_MEMBERS_LIST_EVENT, self.press_btn_close, self)
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

--初始化数据
function GuildPlayerInfoView:initData()

	dump(self.playerdata,"玩家数据界面",7)
	local playerdata = self.playerdata 
	local ability = playerdata.ability or 0
	local woodTotal = playerdata.woodTotal or 0
	self.txt_1:setString(playerdata.name or GameConfig.getLanguage("tid_common_2006")) 
	self.txt_2:setString(GameConfig.getLanguage("#tid_guild_034")..woodTotal) 
	self.txt_3:setString(GameConfig.getLanguage("#tid_guild_035")..ability) 

	-- local online = GuildModel.onLinePlayer
	local logoutTime = playerdata.logoutTime
	local stronline = GameConfig.getLanguage("#tid_guild_037") 
	local pramonline = 1
	if  logoutTime ~= 0 then
		pramonline = 2
		-- stronline = GameConfig.getLanguage("#tid_guild_036")
		local time  = FriendModel:getOutDDHHSSTime(logoutTime)
		stronline = "状态:"..time
	end

	self.mc_wenzi:showFrame(pramonline) --1在线,2不在线
	self.mc_wenzi:getViewByFrame(pramonline).txt_4:setString(stronline)

	-- self.txt_level:setString(playerdata.level)
	self.UI_2:setPlayerInfo(playerdata)
	
	-- ChatModel:setPlayerIcon(self.ctn_1,playerdata.head,playerdata.avatar ,0.9)


end

function GuildPlayerInfoView:setbutton()
	local callfun  = {
		[1] = self.addfriend,
		[2] = self.appointDeleader,
		[3] = self.appointmentelite,
		[4] = self.demise,
		[5] = self.outof,
	}
	local kickRight = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"kickRight")
	local appointRight = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"appointRight")
	local isboos = GuildModel:judgmentIsBoos()
	for i=1,5 do
		
		local btn = self["btn_"..i]
		if i ~= 1  then
			if i == 2 or i == 3 then
				if appointRight == 1 then
					isboos = true
				else
					isboos = false
				end
			elseif i == 5 then
				if kickRight ==1 then
					isboos = true
				else
					isboos = false
				end
			end
			if isboos then
				FilterTools.clearFilter(btn);
				btn:setTouchedFunc(c_func(callfun[i], self),nil,true);
			else
				FilterTools.setGrayFilter(btn);
				btn:setTouchedFunc(c_func(self.notpermissions, self),nil,true);
			end
		else
			self:addfriendButton()
		end
	end
	self:setTanHeButton()

end

--设置弹劾按钮
function GuildPlayerInfoView:setTanHeButton()
	-- local playerId = self.playerdata.rid
	local rigth =  self.playerdata.right
	-- local isboos = GuildModel:judgmentIsForZBoos()
	local appointRight = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"appointRight")
	if rigth == FuncGuild.MEMBER_RIGHT.LEADER then
		self.mc_1:showFrame(1)
		local tanHeButton = self.mc_1:getViewByFrame(1).btn_5
		tanHeButton:setTouchedFunc(c_func(self.impeachment, self),nil,true);
	else
		local tanHeButton = self.mc_1:getViewByFrame(2).btn_5
		self.mc_1:showFrame(2)
		if appointRight == 1 then
			FilterTools.clearFilter(tanHeButton);
			tanHeButton:setTouchedFunc(c_func(self.demotion, self),nil,true);
		else
			FilterTools.setGrayFilter(tanHeButton);
			tanHeButton:setTouchedFunc(c_func(self.notpermissions, self),nil,true);
		end
	end
end

function GuildPlayerInfoView:impeachment()

	local time = FuncDataSetting.getOriginalData("GuildWastage")
	-- local day =  math.floor(time/3600)
	local logoutTime = self.playerdata.logoutTime
	local serveTime = TimeControler:getServerTime()


	echo("========time======",time,serveTime - logoutTime)
	if logoutTime == 0 or serveTime - logoutTime < time then
		WindowControler:showTips(GameConfig.getLanguage("#tid_group_105"))
		return 
	end
	local function _callback( event )
		if event.result then
			dump(event.result,"====弹劾返回数据====")
			local newLeaderId = event.result.data.newLeaderId
			if newLeaderId then
				GuildModel:setLeaderIdInLose()
				GuildModel:setmembersInfo_right(newLeaderId,FuncGuild.MEMBER_RIGHT.LEADER)
				EventControler:dispatchEvent(GuildEvent.REFRESH_MEMBERS_LIST_EVENT)
			end
			WindowControler:showTips(GameConfig.getLanguage("#tid_group_104"))
			self:press_btn_close()
		end
	end
	GuildServer:sendImpeachmentEvent(_callback)
end

--降为成员
function GuildPlayerInfoView:demotion()

	local id  = self.playerdata._id
	local right = self.playerdata.right
	local name = self.playerdata.name
	if right == FuncGuild.MEMBER_RIGHT.PEOPLE then
		local str =  FuncTranslate._getLanguageWithSwap("#tid_group_108",name)
		WindowControler:showTips(str)
		return
	end

	local function callback(param)
        if (param.result ~= nil) then
        	dump(param.result,"====权限修改降为数据===")
        	GuildModel:setmembersInfo_right(id,4)
        	local str =  FuncTranslate._getLanguageWithSwap("#tid_group_108",name)
			WindowControler:showTips(str)
        	EventControler:dispatchEvent(GuildEvent.REFRESH_MEMBERS_LIST_EVENT) 	
        	self:press_btn_close()
        end
    end
	local params = {
		id = id,
		right = FuncGuild.MEMBER_RIGHT.PEOPLE,
	};
	GuildServer:modifyMEmberRight(params,callback)
end

function GuildPlayerInfoView:addfriendButton()
	local playerId = self.playerdata.rid 
	local isfriend = FriendModel:byIdISFriend(playerId)
	local btn = self.btn_1
	if isfriend == false then
		btn:getUpPanel().txt_1:setString(GameConfig.getLanguage("tid_friend_add_friend_first_1046")) 
		btn:setTouchedFunc(c_func(self.addfriend, self),nil,true);
	else
		btn:getUpPanel().txt_1:setString(GameConfig.getLanguage("tid_friend_remove_button_title_1043")) 
		btn:setTouchedFunc(c_func(self.removefriend, self),nil,true);
	end
end
--删除好友
function GuildPlayerInfoView:removefriend()
    local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.FRIEND)
    if not isopen then
        return 
    end
    local function callback(param)
        if (param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_remove_friend_ok_1042"));
             FriendModel:removeFriend(self.playerdata.rid)
            self:setbutton()
            self:press_btn_close();
        elseif (param.error.message == "friend_not_exists") then
            -- //好友不存在
            WindowControler:showTips(GameConfig.getLanguage("tid_common_2039"))--);
        end
    end
    local _param = { }
    local uid = ChatModel:getRidBySec(self.playerdata._id)
    _param.fuid = uid
    FriendServer:removeFriend(_param, callback);
end


function GuildPlayerInfoView:notpermissions()
	WindowControler:showTips(GameConfig.getLanguage("#tid_guild_032")) 
end
--添加好友
function GuildPlayerInfoView:addfriend()
    local _param = { };
    _param.ridInfos = {}
    local sce = LoginControler:getServerId()
    _param.ridInfos[1] = {[sce] = self.playerdata._id}
    FriendServer:applyFriend(_param, function () 
    	WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_1015")) 
    end);
end
--任命副盟主  GuildCompTextView
function GuildPlayerInfoView:appointDeleader()
	if not GuildControler:touchToMainview() then
		return
	end
	local isok =  self:judgmentInRight(2)
	if isok then
		WindowControler:showWindow("GuildCompTextView",1,self.playerdata);
	end
end
--任命精英
function GuildPlayerInfoView:appointmentelite()
	if not GuildControler:touchToMainview() then
		return 
	end
	local isok =  self:judgmentInRight(3)
	if isok then
		WindowControler:showWindow("GuildCompTextView",2,self.playerdata);
	end
end
--禅让
function GuildPlayerInfoView:demise()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showWindow("GuildCompTextView",3,self.playerdata);
end

--逐出
function GuildPlayerInfoView:outof()
	if not GuildControler:touchToMainview() then
		return
	end
	local function _cellBack()
		self:press_btn_close()
	end


	local function _callfun()
		self.playerdata =  GuildModel:getMemberInfo(self.playerdata._id)
		WindowControler:showWindow("GuildCompTextView",4,self.playerdata,_cellBack);
	end


	GuildControler:getMemberList("",_callfun)



	
end

function GuildPlayerInfoView:judgmentInRight(_right)
	local rigth =  self.playerdata.right
	if _right == rigth then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_038")) 
		return false
	else
		return true
	end
end



function GuildPlayerInfoView:press_btn_close()
	
	self:startHide()
end


return GuildPlayerInfoView;
