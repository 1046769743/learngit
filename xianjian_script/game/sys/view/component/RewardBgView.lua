--
-- Author: ZhangYanguang
-- Date: 2016-02-19
-- 公用奖励背景界面

local RewardBgView = class("RewardBgView", UIBase);

function RewardBgView:ctor(winName)
    RewardBgView.super.ctor(self, winName);
end

function RewardBgView:loadUIComplete()
	self:registerEvent();
end 

function RewardBgView:registerEvent()
	RewardBgView.super.registerEvent();
end

function RewardBgView:updateUI()
    
end


return RewardBgView;
