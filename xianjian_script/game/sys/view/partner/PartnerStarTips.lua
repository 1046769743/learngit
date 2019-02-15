

local PartnerStarTips = class("PartnerStarTips", InfoTipsBase);


function PartnerStarTips:ctor(winName, params)
    PartnerStarTips.super.ctor(self, winName);
    self.data = params;

end

function PartnerStarTips:loadUIComplete()
	self:registerEvent();
	self:updateUI();
end 

function PartnerStarTips:registerEvent()
	PartnerStarTips.super.registerEvent();
end

function PartnerStarTips:updateUI()
    local str = PartnerModel:getDesStaheTable(self.data)
	self.txt_1:setString(str);
    self.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(self.data.key)])
end


return PartnerStarTips;
