--[[
	Author: TODO
	Date:2017-10-31
	Description: TODO
]]

local WuLingUpgradeMatrixMethod = class("WuLingUpgradeMatrixMethod", UIBase);

function WuLingUpgradeMatrixMethod:ctor(winName,oldAbility)
    WuLingUpgradeMatrixMethod.super.ctor(self, winName)
end

function WuLingUpgradeMatrixMethod:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuLingUpgradeMatrixMethod:registerEvent()
	WuLingUpgradeMatrixMethod.super.registerEvent(self);
	self:registClickClose(-1, c_func(self.press_btn_close,self))
end

function WuLingUpgradeMatrixMethod:initData()
	-- TODO
end

function WuLingUpgradeMatrixMethod:initView()
	self.txt_jixu:setVisible(false)
	self.panel_bao.txt_deng1:setString(GameConfig.getLanguage("#tid_wuling_004")..(UserModel:fiveSoulLevel()-1))
	self.panel_bao.txt_deng2:setString(GameConfig.getLanguage("#tid_wuling_004")..UserModel:fiveSoulLevel())
	local nowMatrixMethod = FuncWuLing.getFiveSoulMatrixMethodByLevel(UserModel:fiveSoulLevel())
	local lastMatrixMethod = FuncWuLing.getFiveSoulMatrixMethodByLevel(UserModel:fiveSoulLevel()-1)
  	
	local showType = FuncDataSetting.getMatrixMethodDetail(UserModel:fiveSoulLevel())
	self.tempView2 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_bagua",self.mc_1,true)
	self.tempView2:pos(69,-69)
	self.tempView1 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_jiemian",self,true)
	self.tempView1:pos(820,-130)
	self.mc_1:pos(-65,65)
	FuncArmature.changeBoneDisplay(self.tempView1,"node1",self.mc_1)
	self.tempView1:doByLastFrame(false,false)
	FuncArmature.changeBoneDisplay(self.tempView1,"node7",self.panel_bao)
	self.panel_bao:pos(-110,-40)
	-- FuncArmature.setArmaturePlaySpeed(self.tempView1,0.4)
	if showType then
		self.mc_x1:showFrame(1)
		local textStr = WuLingModel:switchMatrixMethodByLevel(UserModel:fiveSoulLevel())
		self.mc_x1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_wuling_005")..textStr)
		self.mc_x1.currentView.panel_bao.txt_3:setString(lastMatrixMethod.get)
		FuncArmature.changeBoneDisplay(self.tempView1,"node3",self.mc_x1.currentView.txt_1)
		FuncArmature.changeBoneDisplay(self.tempView1,"node4",self.mc_x1.currentView.panel_bao)
		self.mc_x1.currentView.txt_1:pos(-270,0)
		self.mc_x1.currentView.panel_bao:pos(-90,0)
	else
		self.mc_x1:showFrame(2)
		self.mc_x1.currentView.panel_bao.txt_3:setString(lastMatrixMethod.get)
		FuncArmature.changeBoneDisplay(self.tempView1,"node3",self.mc_x1.currentView.panel_bao)
		self.mc_x1.currentView.panel_bao:pos(-90,0)
	end	
	self.tempView1:visible(false)
	FuncCommUI.addCommonBgEffect(self.ctn_biaoti,FuncCommUI.EFFEC_TTITLE.HOISTING,function ()
		self.tempView1:visible(true)
		
	end)
	
end

function WuLingUpgradeMatrixMethod:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shipei, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_yun1, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_yun2, UIAlignTypes.Right)
end

function WuLingUpgradeMatrixMethod:updateUI()
	-- TODO
end

function WuLingUpgradeMatrixMethod:press_btn_close()
	-- EventControler:dispatchEvent(WuLingEvent.WULINGEVENT_POWER_UPDATA)
	self:startHide()
end

function WuLingUpgradeMatrixMethod:deleteMe()
	-- TODO

	WuLingUpgradeMatrixMethod.super.deleteMe(self);
end

return WuLingUpgradeMatrixMethod;
