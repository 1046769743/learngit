local PlayerLogoutTipView = class("PlayerLogoutTipView", UIBase)

function PlayerLogoutTipView:ctor(winName,type)
	PlayerLogoutTipView.super.ctor(self, winName)

	self.tipType = type
end

function PlayerLogoutTipView:loadUIComplete()
	self:registerEvent()

    -- 标题名
    if self.tipType == 1 then
        self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_playerInfo_005"))
    elseif self.tipType == 2 then 
        self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_playerInfo_006"))
    end
    
end

function PlayerLogoutTipView:registerEvent()
    self.UI_1.mc_1:visible(false)
	self.UI_1.btn_close:setTap(c_func(self.startHide, self))
	self.btn_cancel:setTap(c_func(self.startHide, self))

	self.btn_confirm:setTap(c_func(self.onConfirm, self))

	self:registClickClose("out")
end

function PlayerLogoutTipView:onConfirm()
	self:startHide()

	-- 切换账号
	if self.tipType == 1 then
		LoginControler:doSwitchAccount()
	-- 切换服务器
	elseif self.tipType == 2 then
		-- 废弃不再调用
		-- LoginControler:goSwitchZoneView()
	end
end


return PlayerLogoutTipView