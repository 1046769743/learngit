--[[
	Author: caocheng
	Date:2017-07-28
	Description: 锁妖塔界面--NPC事件--囚友界面
				 可以选择救他或者趁火打劫
	
	--Author:      zhuguangyuan
	--DateTime:    2017-12-21 11:21:06
	--Description: 
]]

local TowerNpcChooseView = class("TowerNpcChooseView", UIBase);

function TowerNpcChooseView:ctor(winName,npcID,npcPos)
    TowerNpcChooseView.super.ctor(self, winName)
    self.npc = npcID
    self.npcPos = npcPos
end

function TowerNpcChooseView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initView()
	self:updateUI()
end 

function TowerNpcChooseView:registerEvent()
	TowerNpcChooseView.super.registerEvent(self);
	 self:registClickClose("out")
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close,self))
end

function TowerNpcChooseView:initData()
	self.npcData = FuncTower.getNpcData(self.npc)
end

function TowerNpcChooseView:initView()
	self.UI_1.mc_1:showFrame(3)
	self.UI_1.txt_1:setString(GameConfig.getLanguage(self.npcData.name))
	local spineData = FuncTreasure.getSourceDataById(self.npcData.spine)
	local npcSpineName = spineData.spine
	local npcSpine = FuncRes.getArtSpineAni(npcSpineName)
	npcSpine:setPositionY(-80)
	npcSpine:gotoAndStop(1)
	self.ctn_1:addChild(npcSpine) 
	self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_048"))
	self.UI_1.mc_1.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_049"))
	self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.savePrisoner,self))
	self.UI_1.mc_1.currentView.btn_2:setTouchedFunc(c_func(self.killHelpNpc,self))
end

function TowerNpcChooseView:updateUI()

end

function TowerNpcChooseView:deleteMe()
	TowerNpcChooseView.super.deleteMe(self);
end
	
-- 救囚友
function TowerNpcChooseView:savePrisoner()
	local params = {
		eventId = self.npcData.event[2],
		x = self.npcPos.x,
		y = self.npcPos.y,
	}
	
	TowerServer:chooseNpcEvent(params,c_func(self.helpNpcEffect,self))
end
-- 趁火打劫
function TowerNpcChooseView:killHelpNpc()
	local levelId = FuncTower.getLevelIdByNpcEventId(self.npcData.event[1])
	local params = {	
		x = self.npcPos.x,
		y = self.npcPos.y,
		eventId = self.npcData.event[1],
	}
	params[FuncTeamFormation.formation.pve_tower] = {raidId = levelId}
	WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve_tower,params,false,false,true)
	self:startHide()
end	

function TowerNpcChooseView:helpNpcEffect(event)
	if event.error then
		 WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_050"))
	else
		TowerMainModel:updateData(event.result.data)
		WindowControler:showWindow("TowerThanksEventView")
	end
	self:startHide()
end

function TowerNpcChooseView:press_btn_close()
	self:startHide()
end

return TowerNpcChooseView;
