--[[
	Author: caocheng
	Date:2017-10-23
	Description: 五行查看阵容界面(他人触发)
]]

local WuXingCheckTeamEmbattleView = class("WuXingCheckTeamEmbattleView", UIBase);

function WuXingCheckTeamEmbattleView:ctor(winName)
    WuXingCheckTeamEmbattleView.super.ctor(self, winName)
end

function WuXingCheckTeamEmbattleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingCheckTeamEmbattleView:registerEvent()
	WuXingCheckTeamEmbattleView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.doBackClick,self))
end

function WuXingCheckTeamEmbattleView:initData()
	self.npcsData = LineUpModel:getOtherTeamFormationData()
end

function WuXingCheckTeamEmbattleView:initView()
    self.mc_title:showFrame(3)
	self:initPower()
	self:initTreaView()
	self:initPartnerView()
	self:initBtnView()
end

function WuXingCheckTeamEmbattleView:initViewAlign()
	FuncCommUI.setScale9Align(self.widthScreenOffset,self.mc_title, UIAlignTypes.LeftTop)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_fb10, UIAlignTypes.RightTop)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_power, UIAlignTypes.RightTop)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.mc_two, UIAlignTypes.MiddleBottom)
end

function WuXingCheckTeamEmbattleView:updateUI()
	-- TODO
end

function WuXingCheckTeamEmbattleView:initPartnerView()
	self.partnerView = WindowsTools:createWindow("WuXingTeamPartnerView",self.systemId,false,true)
    self.ctn_cc:addChild(self.partnerView)
end

function  WuXingCheckTeamEmbattleView:initPower()
	local power = self.npcsData.totalAbility or 0
	self.panel_power.UI_power:setPower(power)
end

function WuXingCheckTeamEmbattleView:initTreaView()
     local otherTeamFormationData  = LineUpModel:getOtherTeamFormation()
    local curTrea = otherTeamFormationData.treasureFormation["p1"]

    if curTrea ~= nil then
        local treaData = TeamFormationModel:getTreaById( curTrea )
        local mc = self.panel_fb10["mc_fbzt"..2]
        mc:showFrame(1)
              
        local icon = FuncRes.iconTreasureNew( curTrea )

        mc.currentView.panel_fbzt2.panel_tuijian:visible(false)
        --对号
        mc.currentView.panel_fbzt2.panel_duihao:visible(false)
        mc.currentView.panel_fbzt2.txt_1:visible(false)
        mc.currentView.panel_fbzt2.mc_1:showFrame(self.npcsData.treasures[tostring(otherTeamFormationData.treasureFormation["p1"])].star)
        local tsp = display.newSprite(icon):size(80,70)
        mc.currentView.panel_fbzt2.ctn_goodsicon:removeAllChildren()
        tsp:addto(mc.currentView.panel_fbzt2.ctn_goodsicon)
    else
        self.panel_fb10["mc_fbzt"..2]:showFrame(2)
    end
end
function WuXingCheckTeamEmbattleView:doBackClick()
	 self:startHide()
end

function WuXingCheckTeamEmbattleView:initBtnView()
    self.mc_1:visible(false)
    self.panel_12:visible(false)
    self.mc_two:showFrame(2)
    self.mc_two.currentView.panel_zan:visible(false)
    self.mc_two.currentView.btn_1:setTap(c_func(self.enterDetailView,self))
end

function WuXingCheckTeamEmbattleView:enterDetailView()
 	WindowControler:showWindow("OtherTeamFormationDetailView")
end

function WuXingCheckTeamEmbattleView:deleteMe()
	-- TODO
	WuXingCheckTeamEmbattleView.super.deleteMe(self);
end

return WuXingCheckTeamEmbattleView;
