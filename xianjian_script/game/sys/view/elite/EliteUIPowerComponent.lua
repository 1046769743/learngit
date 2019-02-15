--
--Author:      zhuguangyuan
--DateTime:    2018-04-06 15:06:51
--Description: 精英的战力组件 有不同于通用组件的需求
--

local PowerComponent = require("game.sys.view.component.PowerComponent")

local EliteUIPowerComponent = class("EliteUIPowerComponent", PowerComponent);

function EliteUIPowerComponent:ctor(winName)
    EliteUIPowerComponent.super.ctor(self, winName)
end

function EliteUIPowerComponent:loadUIComplete()
    self:registerEvent();
    --初始的坐标偏移是13
    self.initOffset = 0
    -- --数字1的 一半偏移是 7
    -- self.numeOneOffset = 0;
    -- --每一个数字的平均宽度是16
    -- self.perWidth = 16
    self:setNumOneOffsetAndPerWidth(16,0)
end 


function EliteUIPowerComponent:deleteMe()
	EliteUIPowerComponent.super.deleteMe(self);
end

return EliteUIPowerComponent;
