

local TreasureNewTips = class("TreasureNewTips", InfoTipsBase);


function TreasureNewTips:ctor(winName, str)
    TreasureNewTips.super.ctor(self, winName);
    self.str = str
end

function TreasureNewTips:loadUIComplete()
    echo("-----------------regesitShowPartnerTipView 2")
	self:registerEvent();
	self:updateUI();
end 

function TreasureNewTips:registerEvent()
	TreasureNewTips.super.registerEvent();

end

function TreasureNewTips:updateUI()
    
	self.rich_1:setString(self.str);
end


return TreasureNewTips;
