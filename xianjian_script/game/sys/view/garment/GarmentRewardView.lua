--[[
	Author: TODO
	Date:2017-09-29
	Description: TODO
]]

local GarmentRewardView = class("GarmentRewardView", UIBase);

function GarmentRewardView:ctor(winName, partnerId, garmentId)
    GarmentRewardView.super.ctor(self, winName)
    self.partnerId = partnerId
    self.garmentId = garmentId
end

function GarmentRewardView:loadUIComplete()

	FuncCommUI.addBlackBg(self.widthScreenOffset, self._root, 200)
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GarmentRewardView:registerEvent()
	GarmentRewardView.super.registerEvent(self)
	self.panel_1.btn_1:setTouchedFunc(c_func(self.clickBtnConfirm, self))
end

function GarmentRewardView:initData()
	
end

function GarmentRewardView:initView()
	local nameStr = ""
	local artSp = nil
	if FuncPartner.isChar(self.partnerId) then
        nameStr = FuncGarment.getGarmentName(self.garmentId)
        artSp = FuncGarment.getGarmentLihui(self.garmentId, UserModel:avatar(),"dynamic")
        artSp:setPosition(-120, 0)
        if tonumber(UserModel:avatar()) == 101 and tonumber(self.garmentId) == 2 then
        	artSp:setRotationSkewY(180)
        end
    else
        nameStr = FuncPartnerSkin.getSkinName(self.garmentId)
        artSp = FuncPartner.getPartnerLiHuiByIdAndSkin(self.partnerId, self.garmentId)
        artSp:setPosition(-100, 0)
    end
    self.panel_1.txt_1:setString(nameStr)
    -- self.ctn_1:setPosition(50, 100)
    artSp:setScaleX(-0.7)
    artSp:setScaleY(0.7)
    
    self.panel_1.ctn_1:removeAllChildren()
    self.panel_1.ctn_1:addChild(artSp)
end

function GarmentRewardView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.Middle)
end

function GarmentRewardView:updateUI()
	-- TODO
end

function GarmentRewardView:clickBtnConfirm()
	self:startHide()
end

function GarmentRewardView:deleteMe()
	-- TODO

	GarmentRewardView.super.deleteMe(self);
end

return GarmentRewardView;
