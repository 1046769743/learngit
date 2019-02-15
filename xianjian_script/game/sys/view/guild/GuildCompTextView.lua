-- GuildCompTextView
-- Author: Wk
-- Date: 2017-10-10
-- 公会二次确认界面
local GuildCompTextView = class("GuildCompTextView", UIBase);

--(_type)1任命副盟主 2任命精英 3禅让 4逐出  
function GuildCompTextView:ctor(winName,_type,plarerData,_cellBack)
    GuildCompTextView.super.ctor(self, winName);
    self._type = _type
    self._cellBack = _cellBack
    -- echo("========_type============",_type)
    self.plarerData = plarerData
    self._cellBack = _cellBack
    -- self.plarerData.name  = "玩蟹"
    -- dump(self.plarerData,"详情数据",9)
end

function GuildCompTextView:loadUIComplete()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guildCompText_001")) 
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:registClickClose(-1, c_func( function()
        self:press_btn_close()
    end , self))

    self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.yesButton, self),nil,true);
	self:registerEvent()
	self:initData()

end 

function GuildCompTextView:registerEvent()
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

function GuildCompTextView:initData()
	if self._type == 1 then
		self:appointDeleader()
	elseif self._type == 2 then
		self:appointmentelite()
	elseif self._type == 3 then
		self:demise()
	elseif self._type == 4 then
		self:outof()
	end

end
--任命副盟主  GuildCompTextView
function GuildCompTextView:appointDeleader()
	self.mc_1:showFrame(3)
	local rich = self.mc_1:getViewByFrame(3).rich_1
	-- local str = "确定要任命"..self.plarerData.name.."为副盟主？"
	local str = FuncTranslate._getLanguageWithSwap("#tid_group_110",self.plarerData.name)
	rich:setString(str)
end

--任命精英
function GuildCompTextView:appointmentelite()
	self.mc_1:showFrame(1)
	local rich = self.mc_1:getViewByFrame(1).rich_1
	-- local str = "确定要任命"..self.plarerData.name.."为精英?"
	local str = FuncTranslate._getLanguageWithSwap("#tid_group_111",self.plarerData.name)
	rich:setString(str)
end

--禅让
function GuildCompTextView:demise()
	local playerId = self.plarerData._id
	local onlineday = GuildModel:demiseFun(playerId)

	if not onlineday then
		self.mc_1:showFrame(4)
		local rich = self.mc_1:getViewByFrame(4).rich_1
		-- local str = "确定要将盟主职位禅让给"..self.plarerData.name.."?" 
		local str = FuncTranslate._getLanguageWithSwap("#tid_group_112",self.plarerData.name)
		rich:setString(str)
	else
		self.mc_1:showFrame(2)
		local rich = self.mc_1:getViewByFrame(2).rich_1
		-- local str = self.plarerData.name.."离线超过三天,不可禅让"
		local str = FuncTranslate._getLanguageWithSwap("#tid_group_113",self.plarerData.name)
		rich:setString(str)
	end

end

--逐出
function GuildCompTextView:outof()
	local playerId = self.plarerData._id
	local onlineday = GuildModel:outofFilsTime(playerId)
	local cost =   self.plarerData.woodTotal or 0 --FuncGuild.deleteGuidplayerCost()
	if onlineday then
		self.mc_1:showFrame(5)
		local rich = self.mc_1:getViewByFrame(5).rich_1
		-- local str = "确定要将"..self.plarerData.name.."逐出仙盟?"
		local str = FuncTranslate._getLanguageWithSwap("#tid_group_114",self.plarerData.name)
		rich:setString(str)
		local rich2 = self.mc_1:getViewByFrame(5).rich_2
		local day = FuncGuild.outofGuildTime()
		rich2:setString(FuncTranslate._getLanguageWithSwap("#tid_group_Event_116",day))
	else
		self.mc_1:showFrame(6)
		local rich = self.mc_1:getViewByFrame(6).rich_1  
		-- local str = "确定要将"..self.plarerData.name.."逐出仙盟?"
		local str = FuncTranslate._getLanguageWithSwap("#tid_group_114",self.plarerData.name)
		rich:setString(str)
		self.mc_1:getViewByFrame(6).txt_2:setString(cost)
	end
	
end



function GuildCompTextView:yesButton()
	if not GuildControler:touchToMainview() then
		return 
	end
	if self._type == 1 then
		self:sendAppointDeleader()
	elseif self._type == 2 then
		self:sendAppointmentelite()
	elseif self._type == 3 then
		self:sendDemise()
	elseif self._type == 4 then
		self:sendOutof()
	end

	
	
end

--任命副盟主
function GuildCompTextView:sendAppointDeleader()
	local isfull =  GuildModel:appointchampionsNum() 
	if isfull then
		return 
	end

	local id = self.plarerData._id
	local right = FuncGuild.MEMBER_RIGHT.SUPER_MASTER
	local function callback(param)
        if (param.result ~= nil) then
        	dump(param.result,"权限修改副盟主数据",7)
        	GuildModel:setmembersInfo_right(id,right)
        	WindowControler:showTips(GameConfig.getLanguage("#tid_guildCompText_002")) 
        	EventControler:dispatchEvent(GuildEvent.REFRESH_MEMBERS_LIST_EVENT)
        	self:press_btn_close()
        else
            --错误的情况
        end
    end
	local params = {
		id = id,
		right = right
	};
	GuildServer:modifyMEmberRight(params,callback)


	-- GuildServer:
end
--任命精英
function GuildCompTextView:sendAppointmentelite()
	
	local isfull =  GuildModel:appointeliteNum()  --GuildModel:appointchampionsNum()
	if isfull then
		return 
	end

	local id = self.plarerData._id
	local right = FuncGuild.MEMBER_RIGHT.MASTER
	local function callback(param)
        if (param.result ~= nil) then
        	dump(param.result,"权限修改精英数据",7)

        	GuildModel:setmembersInfo_right(id,right)
        	WindowControler:showTips(GameConfig.getLanguage("#tid_guildCompText_003")) 
        	EventControler:dispatchEvent(GuildEvent.REFRESH_MEMBERS_LIST_EVENT)
        	self:press_btn_close()
        else
            --错误的情况
        end
    end
	local params = {
		id = id ,
		right = right,
	};
	GuildServer:modifyMEmberRight(params,callback)

end

--禅让
function GuildCompTextView:sendDemise()
	

	local id  = self.plarerData._id
	local isDemise = GuildModel:demiseFun(id)
	if isDemise then 
		WindowControler:showTips( (self.plarerData.name or "" )..GameConfig.getLanguage("#tid_guildCompText_004"))
		return 
	end

	local right = FuncGuild.MEMBER_RIGHT.LEADER
	local function callback(param)
        if (param.result ~= nil) then
        	dump(param.result,"权限修改禅让数据",7)
        	GuildModel:setmembersInfo_right(id,4)
        	WindowControler:showTips(GameConfig.getLanguage("#tid_guildCompText_005"))
        	EventControler:dispatchEvent(GuildEvent.REFRESH_MEMBERS_LIST_EVENT) 	
        	self:press_btn_close()
        else
            --错误的情况
        end
    end
	local params = {
		id = id,
		right = right, --FuncGuild.MEMBER_RIGHT.LEADER
	};
	GuildServer:modifyMEmberRight(params,callback)
end

--逐出
function GuildCompTextView:sendOutof()
	local id = self.plarerData._id
	local cost = self.plarerData.woodTotal or 0 --FuncGuild.deleteGuidplayerCost()
	local isoutcount  = GuildModel:guildpeopleNum()
	if not isoutcount then
		return
	end

	local havegold =  GuildModel:getWoodCount()  --UserModel:getGold()
	if havegold >= cost/2 then

	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_guildCompText_006")) 
		return 
	end

	local function callback(param)
        if (param.result ~= nil) then
        	dump(param.result,"权限修改逐出数据",7)
        	GuildModel:delMembersInfo(id)
        	WindowControler:showTips(GameConfig.getLanguage("#tid_guildCompText_007")) 
        	EventControler:dispatchEvent(GuildEvent.REFRESH_MEMBERS_LIST_EVENT)
        	if self._cellBack then
        		self._cellBack()
        	end
        	self:press_btn_close()
        else
            --错误的情况
        end
    end


	local params = {
		id = id,
	};
	GuildServer:kickMember(params,callback)

end


function GuildCompTextView:press_btn_close()
	
	self:startHide()
end


return GuildCompTextView;
