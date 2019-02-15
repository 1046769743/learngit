--guan
--2016.2.25

local TrailSweepInfoView = class("TrailSweepInfoView", UIBase);

--[[
    self.panel_Bg,
    self.panel_Bg.btn_1,
    self.panel_Bg.btn_close,
    self.panel_Bg.scale9_1,
    self.panel_Bg.scroll_list,
    self.txt_1,
    self.txt_biaoti,
]]

function TrailSweepInfoView:ctor(winName, kind)
    TrailSweepInfoView.super.ctor(self, winName);
    self._kind = kind;
end

function TrailSweepInfoView:loadUIComplete()
	self:registerEvent();
    self:initlUI();
end 

function TrailSweepInfoView:registerEvent()
	TrailSweepInfoView.super.registerEvent();
    self.panel_Bg.btn_close:setTap(c_func(self.press_panel_Bg_btn_close, self));
    self.panel_Bg.btn_1:setTap(c_func(self.press_panel_Bg_btn_1, self));

    self:registClickClose("out");
end

function TrailSweepInfoView:initlUI()
    local str = GameConfig.getLanguage("#tid" .. tostring(2015 - 1 + self._kind),
         "zh_CN");
    self.txt_1:setString(str);
end


function TrailSweepInfoView:press_panel_Bg_btn_close()
    self:startHide();
end

function TrailSweepInfoView:press_panel_Bg_btn_1()
    self:startHide();
end


function TrailSweepInfoView:updateUI()
	
end


return TrailSweepInfoView;




