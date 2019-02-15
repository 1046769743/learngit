local CompBuySpView = class("CompBuySpView", UIBase);

--[[
    self.UI_comp_maitili,
    self.btn_1,
    self.btn_2,
    self.btn_close,
    self.scale9_1,
    self.txt_1,
    self.txt_2,
    self.txt_3,
    self.txt_4,
    self.txt_5,
    self.txt_6,
    self.txt_7,
    self.txt_biaoti,
]]

function CompBuySpView:ctor(winName)
    CompBuySpView.super.ctor(self, winName);
end

function CompBuySpView:loadUIComplete()
	self:registerEvent();

    self:updateUI();
end 

function CompBuySpView:registerEvent()
	CompBuySpView.super.registerEvent();
    self:registClickClose("out")
    self.UI_1.btn_close:setTap(c_func(self.pressButtonClose,self));
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.pressButtonClose,self));
end
--//关闭页面
function   CompBuySpView:pressButtonClose()
          self:startHide();
end

function CompBuySpView:updateUI()
         local      _count=CountModel:getSpBuyCount();
	     local      _content=GameConfig.getLanguageWithSwap("tid_common_1020",_count,5);
         self.txt_6:setString(_content);
end


return CompBuySpView;
