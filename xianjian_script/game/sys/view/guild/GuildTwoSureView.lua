-- GuildTwoSureView
-- Author: Wk
-- Date: 2017-10-17
-- 公会建筑二级升级确认界面
local GuildTwoSureView = class("GuildTwoSureView", UIBase);

function GuildTwoSureView:ctor(winName,_callback)
    GuildTwoSureView.super.ctor(self, winName);
    self._callback = _callback
end

function GuildTwoSureView:loadUIComplete()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_common_2040")) 
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	-- self:registClickClose(-1, c_func( function()
 --        self:press_btn_close()
 --    end , self))
    self:registClickClose("out")


	self:iniData()
end 

function GuildTwoSureView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end
function GuildTwoSureView:iniData()
	self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.surebutton, self),nil,true);


end

function GuildTwoSureView:surebutton()
	self._callback()
	self:press_btn_close()
end




function GuildTwoSureView:press_btn_close()
	
	self:startHide()
end


return GuildTwoSureView;
