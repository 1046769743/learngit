

local PartnerCharDWTiShiView = class("PartnerCharDWTiShiView" ,UIBase)

function PartnerCharDWTiShiView:ctor(_winName)
    PartnerCharDWTiShiView.super.ctor(self,_winName)
end

function PartnerCharDWTiShiView:loadUIComplete()
    self:registerEvent()

    self:updataUI()
end

function PartnerCharDWTiShiView:registerEvent()
    PartnerCharDWTiShiView.super.registerEvent(self)
    --注册事件监听,伙伴的信息发生了变化
    self.btn_close:setTap(c_func(self.close,self))
    self:registClickClose("out")
end


function PartnerCharDWTiShiView:updataUI()
    
end

function PartnerCharDWTiShiView:close()
    self:startHide()
end

return PartnerCharDWTiShiView