-- GuildAnnouncement
-- Author: Wk
-- Date: 2017-10-10
-- 公会公告描述
local GuildAnnouncement = class("GuildAnnouncement", UIBase);

function GuildAnnouncement:ctor(winName,_type,cellfunc)
    GuildAnnouncement.super.ctor(self, winName);
    self._type = _type
    self.cellfunc = cellfunc
end

function GuildAnnouncement:loadUIComplete()

	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	-- self:registClickClose(-1, c_func( function()
 --        self:press_btn_close()
 --    end , self))
    self:registClickClose("out")
    self.UI_1:setTouchEnabled(true)
    self.UI_1.mc_1:showFrame(1)
    self.UI_1.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.confirmButton, self),nil,true);

    if self._type == 1 then 
    	self.txt_1:setString(GameConfig.getLanguage("#tid_guildAnnoun_001"))
    	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guildAnnoun_002"))
    	self.input_name:set_defaultstr(LoginControler:getServerMark())
		
    	local str =	 GuildModel._baseGuildInfo.desc
    	if str == nil or str == "" then
    		str = FuncGuild.getdefaultDec()
    	end
    	self.input_name:set_defaultstr(str)
    elseif self._type == 2 then 
    	self.txt_1:setString(GameConfig.getLanguage("#tid_guildAnnoun_003"))
    	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guildAnnoun_004"))
    	local str =	 GuildModel._baseGuildInfo.notice
    	if str == nil or str == "" then
    		str = FuncGuild.getdefaultNotice()
    	end
    	self.input_name:set_defaultstr(str)

    elseif self._type == 3 then
    	self.txt_1:setString(GameConfig.getLanguage("#tid_group_guild_1501"))
    	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_group_guild_1502"))
    	self.input_name:set_defaultstr(GameConfig.getLanguage("#tid_group_guild_1501"))
    end
    self.input_name:initDefaultText()

end 

--确认按钮
function GuildAnnouncement:confirmButton()
	if not GuildControler:touchToMainview() then
		return 
	end
	local gettext = self.input_name:getText()
	echo("=====gettext=====修改宣言=======",gettext)
	if gettext == "" or gettext == nil then
		-- WindowControler:showTips("输入不能为空")
		-- return 	
		gettext =    FuncGuild.getdefaultDec() --"本盟大力收人了，大家快来呀！"
	end
	local len = string.len4cn2(gettext)
	-- echo("========",len)
	local lengthnum = 0
	local minlength = 0
	local strlrngth = 0
	if self._type == 1 then
		lengthnum = 40
		strlrngth = GameConfig.getLanguage("#tid_guildAnnoun_001")
	elseif self._type == 2 then
		lengthnum = 100
		strlrngth = GameConfig.getLanguage("#tid_guildAnnoun_003")

	elseif self._type == 3 then
		minlength = 6
		lengthnum = 10
		strlrngth = GameConfig.getLanguage("#tid_group_guild_1501")
	end

	if  len < minlength  or len > lengthnum then
		WindowControler:showTips(strlrngth)
		return
	end


	local function _callback(_param)
		dump(_param.result,"宣言",8)
		if _param.result then
			local str = gettext
			if self._type == 1 then
				GuildModel:setdesc(str)
				WindowControler:showTips(GameConfig.getLanguage("#tid_guildAnnoun_005"))
			elseif self._type == 2 then
				GuildModel:setnotice(str)
				WindowControler:showTips(GameConfig.getLanguage("#tid_guildAnnoun_006"))
			elseif self._type == 3 then
				GuildModel:setGroupID(str)
				WindowControler:showTips(GameConfig.getLanguage("#tid_group_guild_1503"))
			end
			EventControler:dispatchEvent(GuildEvent.AMEND_STR_EVENT)
			EventControler:dispatchEvent(GuildEvent.REFRESH_MEMBERS_LIST_EVENT)
			if self.cellfunc then
				self.cellfunc()
			end
			self:press_btn_close()
		end
	end 
	local params = nil
	if self._type == 1 then
		params = {
			desc = gettext,   ---宣言
		};

	elseif self._type == 2 then
		params = {
			notice = gettext,  --公告
		};
	elseif self._type == 3 then
		params = {
			qqGroup = gettext,  --公告
		};	
	end
	GuildServer:modifyConfig(params,_callback)
end

function GuildAnnouncement:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end


function GuildAnnouncement:press_btn_close()
	
	self:startHide()
end


return GuildAnnouncement;
