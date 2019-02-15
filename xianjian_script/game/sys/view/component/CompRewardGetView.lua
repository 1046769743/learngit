local CompRewardGetView = class("CompRewardGetView", UIBase);

--[[
    self.UI_comp_tc,
    self.btn_1,
    self.btn_close,
    self.scale9_1,
    self.scroll_list,
    self.txt_1,
]]

function CompRewardGetView:ctor(winName)
    CompRewardGetView.super.ctor(self, winName);
end

function CompRewardGetView:loadUIComplete()
	self:registerEvent();
end 

function CompRewardGetView:registerEvent()
	CompRewardGetView.super.registerEvent();
end


function CompRewardGetView:updateUI()
	
end


return CompRewardGetView;





