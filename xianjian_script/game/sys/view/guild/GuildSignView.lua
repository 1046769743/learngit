-- GuildSignView
-- Author: Wk
-- Date: 2017-09-30
-- 公会签到界面
local GuildSignView = class("GuildSignView", UIBase);

function GuildSignView:ctor(winName)
    GuildSignView.super.ctor(self, winName);
end

function GuildSignView:loadUIComplete()

	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_046")) 
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	-- self:registClickClose(-1, c_func( function()
 --        self:press_btn_close()
 --    end , self))
	self:registClickClose("out")
    self.UI_1.mc_1:showFrame(1)
    self.UI_1.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.confirmButton, self),nil,true);

    local gettext = FuncGuild.getSignLanguage()
    echo("===========gettext==========",gettext)
    self.input_name:set_defaultstr(gettext)
    self.input_name:initDefaultText()
end 




--确认按钮
function GuildSignView:confirmButton()
	if not GuildControler:touchToMainview() then
		return 
	end
	local count = CountModel:getGuildSignCount()
	if count ~= 0 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_047"))
		return 
	end

	local gettext = self.input_name:getText()
	echo("=====gettext====签到========",gettext)
	if gettext == "" or gettext == nil then
		gettext = FuncGuild.getSignLanguage()
	end


	local len = string.len4cn2(gettext)
	if len > 20 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_048"))
		return
	end

    local isbadword,text = Tool:checkIsBadWords(gettext)
    if isbadword == true then
        _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
        WindowControler:showTips(_tipMessage);
        return
    end


	local level = GuildModel:getGuildLevel()
	local data = FuncGuild.getGuildLevelByPreserve(level)
	local signReward = nil

	local function _callback(_param)
		dump(_param.result,"签到",8)
		if _param.result then
			--发送到仙盟频道聊天
			-- self:press_btn_close()
			local  chatparam={};
	        chatparam.type = 1;
	        chatparam.target= UserModel:rid();
	        chatparam.content= gettext;
	        -- echo("=========_rid======",_rid)
         	ChatServer:sendLeagueMessage(chatparam)
         	local signReward = _param.result.data.reward
         	EventControler:dispatchEvent(GuildEvent.REFRESH_SIGN_EVENT)
			
			WindowControler:showWindow("RewardSmallBgView", signReward,c_func(self.rewardCallBack, self));
			
		else
			--错误和没查找到的情况
		end

	end 
	local params = {}
	GuildServer:sendSign(params,_callback)
	

end
function GuildSignView:rewardCallBack()
	self:press_btn_close()
end
function GuildSignView:registerEvent()

end


function GuildSignView:press_btn_close()
	
	self:startHide()
end

return GuildSignView;
