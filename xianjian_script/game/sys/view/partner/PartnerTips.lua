

local PartnerTips = class("PartnerTips", InfoTipsBase);


function PartnerTips:ctor(winName, params)
    PartnerTips.super.ctor(self, winName);
    self._id = params.id;
    self._type = params._type
    self.isChar = FuncPartner.isChar(self._id)
end

function PartnerTips:loadUIComplete()
    echo("-----------------regesitShowPartnerTipView 2")
	self:registerEvent();
	self:updateUI();
end 

function PartnerTips:registerEvent()
	PartnerTips.super.registerEvent();

end

function PartnerTips:updateUI()
    local str = "主角提示 策划快点配";
    if self._type == FuncPartner.TIPS_TYPE.QUALITY_TIPS then --
        if self.isChar then
            str = GameConfig.getLanguage("#tid_partner_22")
        else
            str = GameConfig.getLanguage("#tid_partner_1")
        end
    elseif self._type == FuncPartner.TIPS_TYPE.PARTNER_TYPE_TIPS then --
        if self.isChar then
            str = GameConfig.getLanguage("#tid_partner_26")
        else
            str = GameConfig.getLanguage("#tid_partner_5")
        end
    elseif self._type == FuncPartner.TIPS_TYPE.STAR_TIPS then --
        if self.isChar then
            str = GameConfig.getLanguage("#tid_partner_27")
        else
            str = GameConfig.getLanguage("#tid_partner_6")
        end 
    elseif self._type == FuncPartner.TIPS_TYPE.POWER_TIPS then -- 
        if self.isChar then
            str = GameConfig.getLanguage("#tid_partner_23")
        else
            str = GameConfig.getLanguage("#tid_partner_2")
        end
    elseif self._type == FuncPartner.TIPS_TYPE.DESCRIBE_TIPS then -- 
        if self.isChar then
            str = GameConfig.getLanguage("#tid_partner_25")
        else
            str = GameConfig.getLanguage("#tid_partner_4")
        end
    elseif self._type == FuncPartner.TIPS_TYPE.LIKABILITY_TIPS then -- 
        if self.isChar then
            str = GameConfig.getLanguage("#tid_partner_24")
        else
            str = GameConfig.getLanguage("#tid_partner_3")
        end
    end
	self.rich_1:setString(str);
    
    self.rich_1:setVerticalAlign(cc.TEXT_ALIGNMENT_CENTER)

end


return PartnerTips;
