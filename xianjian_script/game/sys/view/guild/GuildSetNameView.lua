-- GuildSetNameView
-- Author: Wk
-- Date: 2017-09-29
-- 公会创建取名界面
local GuildSetNameView = class("GuildSetNameView", UIBase);

function GuildSetNameView:ctor(winName)
    GuildSetNameView.super.ctor(self, winName);
    self.guildname = ""
    self.guildnameType = 1  ---默认选着盟

end

function GuildSetNameView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:setGuildName()
	self:initGuildTypeName()
end 

function GuildSetNameView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)

	self.btn_1:setTouchedFunc(c_func(self.nextButton, self,i),nil,true);
end

--初始化数据
function GuildSetNameView:initData()

end

--取名的控件
function GuildSetNameView:setGuildName()
	self.panel_1.input_name:setAlignment("left", "center")
	self:showguildnameType()
end

--显示仙盟类型名称
function GuildSetNameView:showguildnameType()
	self.panel_1.mc_wenzi:showFrame(self.guildnameType)
end

---下一步返回函数
function GuildSetNameView:setCellFun( cellBack )
	self.cellBack = cellBack
end

function GuildSetNameView:nextButton()
	local text = self.panel_1.input_name:getText()
	if text == "" or text == nil then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_043")) 
		return 
	end
	-- echo("=====公会名称=======",text)
	-- echo("=====公会类型=======",self.guildnameType)
	if string.find(text," ") ~= nil then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_044"))
		return 
	end
	local len = string.len4cn2(text)
	if len < 4 or len > 12 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_045"))
		return
	end

    local isbadword,text = Tool:checkIsBadWords(text)
    if isbadword == true then
        _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
        WindowControler:showTips(_tipMessage);
        return
    end
    local guildName = {
    	name = text,
		_type = self.guildnameType,
	}
    GuildModel:setGuildName(guildName)
    self.cellBack()

end
function GuildSetNameView:initGuildTypeName()
	for i=1,#FuncGuild.guildNameType do 
		self.panel_2["panel_"..i]:setTouchedFunc(c_func(self.selectguildicon, self,i),nil,true);
	end
	self:selectguildicon(self.guildnameType)
end
function GuildSetNameView:selectguildicon(itemID)
	self.guildnameType = itemID
	self:showguildnameType()
	local panel = self.panel_2["panel_"..itemID]
	local _x = panel:getPositionX()
	local _y = panel:getPositionY()

	local size = panel:getContainerBox()

	self.panel_2.panel_dui:setPosition(cc.p(_x + size.width/2 - 5,_y - size.height/2-5))

end

return GuildSetNameView;
