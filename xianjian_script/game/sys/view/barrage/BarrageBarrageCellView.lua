-- BarrageBarrageCellView
-- Aouth wk
-- time 2018/1/30

local BarrageBarrageCellView = class("BarrageBarrageCellView", UIBase);

local linehight = 30  --默认一行高 30像素

function BarrageBarrageCellView:ctor(winName)
    BarrageBarrageCellView.super.ctor(self, winName);
end

function BarrageBarrageCellView:loadUIComplete()

	self:registerEvent();
end 

function BarrageBarrageCellView:registerEvent()

end






function BarrageBarrageCellView:clickButtonBack()
    self:startHide();
end




return BarrageBarrageCellView;
