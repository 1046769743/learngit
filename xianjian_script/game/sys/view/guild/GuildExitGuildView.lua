-- GuildExitGuildView
-- Author: Wk
-- Date: 2017-10-10
-- 退出公会界面
local GuildExitGuildView = class("GuildExitGuildView", UIBase);

function GuildExitGuildView:ctor(winName)
    GuildExitGuildView.super.ctor(self, winName);
end

function GuildExitGuildView:loadUIComplete()
 
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_028")) 
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self.UI_1.mc_1:showFrame(2)
	self.UI_1.mc_1:getViewByFrame(2).btn_1:setTouchedFunc(c_func(self.yesButton, self),nil,true);
	self.UI_1.mc_1:getViewByFrame(2).btn_2:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:registClickClose("out")
	self:registerEvent()
end 


--确认按钮
function GuildExitGuildView:yesButton()
	if not GuildControler:touchToMainview() then
		return 
	end
	local id = GuildModel._baseGuildInfo._id
	local function _callback(_param)
		dump(_param.result,"退出公会数据返回",8)
		if _param.result then
			GuildModel:reductionInitData()
			EventControler:dispatchEvent(GuildEvent.CLOSE_ALL_VIEW_EVENT)
			self:press_btn_close()
		else
			--错误和没查找到的情况
		end
	end 

	local params = {
		id = id
	};	

	GuildServer:quitGuild(params,_callback)
	
end


function GuildExitGuildView:registerEvent()
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end


function GuildExitGuildView:press_btn_close()
	
	self:startHide()
end


return GuildExitGuildView;
