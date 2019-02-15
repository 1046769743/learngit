--[[
	Author: caocheng
	Date:2017-10-31
	Description: 注灵成功
]]

local WuLingUpgradeSpirit = class("WuLingUpgradeSpirit", UIBase);

function WuLingUpgradeSpirit:ctor(winName,nowWuLingId,oldAbility)
    WuLingUpgradeSpirit.super.ctor(self, winName)
    self.wuLingId = nowWuLingId
end

function WuLingUpgradeSpirit:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuLingUpgradeSpirit:registerEvent()
	WuLingUpgradeSpirit.super.registerEvent(self);
	self:registClickClose(-1, c_func(self.press_btn_close,self))
end

function WuLingUpgradeSpirit:initData()
	-- TODO
end

function WuLingUpgradeSpirit:initView()
	self.txt_jixu:setVisible(false)
	self.mc_1:showFrame(self.wuLingId)
	local tempLevel = WuLingModel:getWuLingLevelById(self.wuLingId)
	local level_before = tempLevel - 1
	local resistance,skillLevel = WuLingModel:getWuLingProperty(self.wuLingId,tempLevel)
	local resistance_before, skillLevel_before = WuLingModel:getWuLingProperty(self.wuLingId,level_before)
	local nextData = WuLingModel:getSingleWuLing(self.wuLingId,tempLevel)
	local data_before = WuLingModel:getSingleWuLing(self.wuLingId,level_before)
	local dataNum = nextData.fastness/100
	local dataNum_before = data_before.fastness/100
	self.panel_bao.txt_deng1:setString(GameConfig.getLanguage("#tid_wuling_004")..tempLevel-1)
	self.panel_bao.txt_deng2:setString(GameConfig.getLanguage("#tid_wuling_004")..tempLevel)
	local strText = WuLingModel:switchTextById(self.wuLingId)
	self.panel_xin1.txt_1:setString(strText.." +"..resistance_before.."%")
	self.panel_xin1.txt_5:setString(resistance.."%")
	if self.wuLingId == 1 then
		self.tempView2 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_changzhu2",self.mc_1,true)
	elseif self.wuLingId == 2 then
		self.tempView2 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_changzhu4",self.mc_1,true)
	elseif self.wuLingId == 3 then
		self.tempView2 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_changzhu5",self.mc_1,true)
	elseif self.wuLingId == 4 then
		self.tempView2 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_wulingchangzhu",self.mc_1,true)
	elseif self.wuLingId == 5 then
		self.tempView2 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_changzhu3",self.mc_1,true)
	end		
	self.tempView2:pos(66,-65)

	self.tempView1 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_jiemian",self,true)
	self.tempView1:pos(820,-130)
	self.mc_1:pos(-65,65)
	FuncArmature.changeBoneDisplay(self.tempView1,"node1",self.mc_1)
	self.tempView1:doByLastFrame(false,false)
	FuncArmature.changeBoneDisplay(self.tempView1,"node7",self.panel_bao)
	FuncArmature.changeBoneDisplay(self.tempView1,"node3",self.panel_xin1)
	self.panel_bao:pos(-110,-40)
	self.panel_xin1:pos(-180,0)
	if nextData.skill then
		self.panel_xin2:visible(true)
		self.panel_xin2.txt_1:setString(GameConfig.getLanguage("tid_common_2067").." +"..skillLevel_before)
		self.panel_xin2.txt_5:setString(skillLevel)
		FuncArmature.changeBoneDisplay(self.tempView1,"node4",self.panel_xin2)
		self.panel_xin2:pos(-180,0)
	else
		self.panel_xin2:visible(false)	
	end	
  	self.tempView1:visible(false)
  	FuncCommUI.addCommonBgEffect(self.ctn_biaoti,FuncCommUI.EFFEC_TTITLE.NOTESPRIT,function ()
		self.tempView1:visible(true)
		
	end)
end

function WuLingUpgradeSpirit:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shipei, UIAlignTypes.Left)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_yun1, UIAlignTypes.Left)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_yun2, UIAlignTypes.Right)
end

function WuLingUpgradeSpirit:updateUI()
	-- TODO
end

function WuLingUpgradeSpirit:press_btn_close()
	EventControler:dispatchEvent(WuLingEvent.WULINGEVENT_POWER_UPDATA)
	self:startHide()
end

function WuLingUpgradeSpirit:deleteMe()
	-- TODO

	WuLingUpgradeSpirit.super.deleteMe(self);
end

return WuLingUpgradeSpirit;