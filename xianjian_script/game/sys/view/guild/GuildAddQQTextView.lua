-- GuildAddQQTextView
-- Author: Wk
-- Date: 2017-09-29
-- 公会创建添加QQ群号
local GuildAddQQTextView = class("GuildAddQQTextView", UIBase);

function GuildAddQQTextView:ctor(winName)
    GuildAddQQTextView.super.ctor(self, winName);
end

function GuildAddQQTextView:loadUIComplete()
	self:registerEvent()
end 

function GuildAddQQTextView:registerEvent()
	self.input_1:setAlignment("left", "center")
	self.btn_1:setTouchedFunc(c_func(self.nextButton, self,i),nil,true);
end

function GuildAddQQTextView:initData()


end

---下一步返回函数
function GuildAddQQTextView:setCellFun( cellBack )
	self.cellBack = cellBack
end
function GuildAddQQTextView:nextButton()
	local text = self.input_1:getText()
	if text == "" or text == nil then
		WindowControler:showTips(GameConfig.getLanguage("#tid_group_guild_1505")) 
		return 
	end
	-- echo("=====公会名称=======",text)
	-- echo("=====公会类型=======",self.guildnameType)



	if string.find(text," ") ~= nil then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_044"))
		return 
	end


	local len = string.len4cn2(text)
	if len < 6 or len > 10 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_group_guild_1501"))
		return
	end

	local lenInByte = #text
	for i=1,lenInByte do
		local curByte = string.byte(text, i)
	 	if curByte > 97 then
	 		WindowControler:showTips(GameConfig.getLanguage("#tid_group_guild_1507"))
	 		return 
	 	end
	end


    local isbadword,text = Tool:checkIsBadWords(text)
    if isbadword == true then
        _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
        WindowControler:showTips(_tipMessage);
        return
    end
    local groupID = text
    GuildModel:setGuildGroup(groupID)

    self.cellBack()

end



return GuildAddQQTextView;
