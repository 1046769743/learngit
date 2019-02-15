-- GuildCreateAndAddView
-- Author: Wk
-- Date: 2017-09-29
-- 公会创建和加入界面
local GuildCreateAndAddView = class("GuildCreateAndAddView", UIBase);

function GuildCreateAndAddView:ctor(winName)
    GuildCreateAndAddView.super.ctor(self, winName);
end

function GuildCreateAndAddView:loadUIComplete()
	-- local size = self.panel_sp:getContainerBox()
	-- self.panel_sp:setScaleX(GameVars.width/size.width)
	-- self:registClickClose(-1, c_func( function()
 --        self:press_btn_close()
 --    end , self))

    self.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);

 	-- local size = self.panel_di:getContainerBox()
	-- self.panel_di:setScaleX(GameVars.width/size.width)
	self:registClickClose("out")
	self:registerEvent()
	self:buttonShowRed()
	self:initData()
end 

function GuildCreateAndAddView:registerEvent()
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	EventControler:addEventListener(GuildEvent.GUILD_REFRESH_invite_EVENT, self.buttonShowRed, self)
end
function GuildCreateAndAddView:buttonShowRed()
	local num =  GuildModel.invitedToList
	local ishow = false
	if #num ~= 0 then
		ishow  = true
	end
	self.btn_2:getUpPanel().panel_red:setVisible(ishow)

end
function GuildCreateAndAddView:initData()
	--创建
	self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	--加入
	self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

--创建
function GuildCreateAndAddView:creaGuild()
	echo("======创建=========")
	self:closeGuildTime(1)
	
end
function GuildCreateAndAddView:closeGuildTime(_type)
	local iscd =GuildModel:closeGuildTime()
	if not iscd then
		if _type == 1 then
			WindowControler:showWindow("GuildCreateView");
		else
			GuildControler:getAddGuildDataList(_type)
		end
		self:press_btn_close()
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_023")) 
	end
end
--加入
function GuildCreateAndAddView:addGuild()
	echo("=======加入========")
	self:closeGuildTime(2)
end

function GuildCreateAndAddView:press_btn_close()
	
	self:startHide()
end


return GuildCreateAndAddView;
