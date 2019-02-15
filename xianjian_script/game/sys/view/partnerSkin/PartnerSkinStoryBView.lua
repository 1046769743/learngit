--张强
--2017.5.16 

local PartnerSkinStoryBView = class("PartnerSkinStoryBView", UIBase);

function PartnerSkinStoryBView:ctor(winName, skinId,partnerId)
    PartnerSkinStoryBView.super.ctor(self, winName);
    self._skinId = skinId;
    self._partnerId = partnerId
    echo("故事 ID == ",skinId)
end

function PartnerSkinStoryBView:loadUIComplete()
	self:registerEvent();
    self:uiAdjust();
    self:initUI();
end 

function PartnerSkinStoryBView:registerEvent()
	PartnerSkinStoryBView.super.registerEvent();

    self:registClickClose(-1, c_func( function()
            self:startHide()
    end , self))

end

function PartnerSkinStoryBView:initUI()
    --故事
    local strotyStr = FuncPartnerSkin.getStoryStr(self._skinId);
    FuncCommUI.setVerTicalTXT( {str = strotyStr, space = 3, txt = self.txt_1} );

    --伙伴名字
    local partnerNameStr = FuncPartnerSkin.getPartnerName(self._skinId);
    self.txt_name:setString(partnerNameStr);

    --皮肤名字
    local skinNameStr = FuncPartnerSkin.getSkinName(self._skinId);
    self.txt_name:setString(skinNameStr);

    --图片  
    local partnerId = FuncPartnerSkin.getValueByKey( self._skinId,"partnerId")
    local artSp = FuncPartner.getPartnerLiHuiByIdAndSkin(partnerId,self._skinId )
    self.ctn_icon:addChild(artSp);
    artSp:setScale(0.8)

    local btnZt = PartnerSkinModel:getSkinStage(self._partnerId,self._skinId)
    if btnZt < 4 then
        self.txt_name2:setString(GameConfig.getLanguage("#tid_partnerskin_008")) 
    elseif btnZt == 4 then 
        self.txt_name2:setString(GameConfig.getLanguage("#tid_partnerskin_009"))
    elseif btnZt > 4 then 
        self.txt_name2:setString("")
    end
    
    -- 属性加成
    self.mc_1:visible(false)
    local attr = FuncPartnerSkin.getAttr(self._skinId)
    if attr then
        self.mc_1:visible(true)
        self.mc_1:showFrame(#attr)
        local index = 1
        for i,v in pairs(attr) do
            self.mc_1.currentView["txt_shu"..index]:setString(FuncPartnerSkin.getDesStahe(v))
            index = index + 1
        end
    else
        self.mc_1:visible(true)
        self.mc_1:showFrame(1) 
        self.mc_1.currentView["txt_shu"..1]:setString(GameConfig.getLanguage("#tid_partnerskin_010"))
    end
end

--分辨率适配
function PartnerSkinStoryBView:uiAdjust()
    
end


return PartnerSkinStoryBView;






