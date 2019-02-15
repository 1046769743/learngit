local CompFivePosView = class("CompFivePosView", UIBase);


function CompFivePosView:ctor(winName)
    CompFivePosView.super.ctor(self, winName);
end

function CompFivePosView:loadUIComplete()
	self:registerEvent();
end 

function CompFivePosView:registerEvent()
	CompFivePosView.super.registerEvent();
    
end


function CompFivePosView:updateUI(id)
    local frame = 1
    if not FuncPartner.isChar(id) then
        local data = FuncPartner.getPartnerById(id);
        frame = data.elements + 1
    else
        -- 去法宝 定位
    end
    self.panel_xxnn.mc_tu2:showFrame(tonumber(frame))
    self.panel_xxnn.mc_tu3:showFrame(tonumber(frame))
end


return CompFivePosView;
