--新生成的伙伴
--2017-1-9 11:10:08
--@Author:xiaohuaxiong
local PartnerNewPartnerView = class("PartnerNewPartnerView",UIBase)

function PartnerNewPartnerView:ctor(_window_name,_partnerId)
    PartnerNewPartnerView.super.ctor(self,_window_name)
    self._partnerId= _partnerId
end

function PartnerNewPartnerView:loadUIComplete()
    self:registerEvent()
    self:updateNewPartnerView()
end

function PartnerNewPartnerView:registerEvent()
    PartnerNewPartnerView.super.registerEvent(self)
    self:registClickClose("out")
end

--设置新获得的伙伴UI
function PartnerNewPartnerView:updateNewPartnerView()
    --name
    local _partner_item = FuncPartner.getPartnerById(self._partnerId)
    self.txt_1:setString(GameConfig.getLanguage(_partner_item.name))
    --star
    self.mc_1:showFrame(_partner_item.initStar)
    --Spine animate
    local _spineAnimate = PartnerModel:initNpc(self._partnerId)
    self.ctn_1:addChild(_spineAnimate)
end

return PartnerNewPartnerView