--
-- Author: ZhangYanguang
-- Date: 2015/08/06
-- 战斗奖品掉落

local BattleAward = class("BattleAward", UIBase)

function BattleAward:ctor(winName)
	BattleAward.super.ctor(self,winName)
	self:registerEvent();

end

function BattleAward:loadUIComplete()
	BattleAward.super.loadUIComplete();
	self:setTouchSwallowEnabled(true);
	self:setTouchEnabled(true);

	self.txt_shuliang:setString("99")
end

-- UI显示完毕
function BattleAward:showComplete()
end


return BattleAward;