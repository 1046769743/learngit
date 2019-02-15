-- GuildLapseView
-- Author: Wk
-- Date: 2017-10-16
-- 公会功能失效
local GuildLapseView = class("GuildLapseView", UIBase);

function GuildLapseView:ctor(winName)
    GuildLapseView.super.ctor(self, winName);
end

function GuildLapseView:loadUIComplete()

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_1,UIAlignTypes.MiddleBottom)
    -- self:registClickClose("out")
    self:setButton()

end 
function GuildLapseView:setButton()
	-- self.btn_2:setTouchedFunc(c_func(self.goingDonation, self),nil,true);
end
function GuildLapseView:goingDonation()
	-- self:press_btn_close()
	-- WindowControler:showWindow("GuildMainBuildView")
end

function GuildLapseView:press_btn_close()
	
	self:startHide()
end


return GuildLapseView;
