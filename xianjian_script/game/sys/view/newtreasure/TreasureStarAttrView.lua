

local TreasureStarAttrView = class("TreasureStarAttrView", UIBase);


function TreasureStarAttrView:ctor(winName, id)
    TreasureStarAttrView.super.ctor(self, winName);
    self.treaId = id
end

function TreasureStarAttrView:loadUIComplete()
    echo("-----------------regesitShowPartnerTipView 2")
	self:registerEvent();
	self:updateUI();
end 

function TreasureStarAttrView:registerEvent()
	TreasureStarAttrView.super.registerEvent();
	self:registClickClose("out")
end

function TreasureStarAttrView:updateUI()
    local starAttrT = FuncTreasureNew.getStarAttrMap( self.treaId )
    local attrData = FuncChar.getAttributeData()
    for i,v in pairs(starAttrT) do
        local attrName = GameConfig.getLanguage(attrData[tostring(starAttrT[i].attr[1].key)].name)
		local _str1 = GameConfig.getLanguage("#tid_treature_ui_011") 
        local _str2 = GameConfig.getLanguage("#tid_treature_ui_002") 
        self.panel_1["txt_"..i]:setString(i.._str1..attrName.._str2)
    end
    self.panel_1["txt_"..7]:visible(false)
end


return TreasureStarAttrView;
