--
-- Author: gs
-- Date: 2016-10-12 14:51:47
--
local BattlePVPHpView = class("BattlePVPHpView", UIBase)


function BattlePVPHpView:loadUIComplete(  )
    FuncCommUI.setViewAlign(self.widthScreenOffset,self,UIAlignTypes.MiddleTop)


	self.panel_1.panel_2:visible(false)
	self.panel_3.panel_1:visible(false)

    --FuncCommUI.setViewAlign(self.widthScreenOffset,self.scale9_bg,UIAlignTypes.LeftBottom)


    --FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)

end


function BattlePVPHpView:initView(  )
end




function BattlePVPHpView:initControler( view,controler )
	--echoError("===================================")
    self._battleView = view
    self.controler = controler
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundChanged, self)
    self.panel_1.panel_1.progress_1:setPercent(100)
    self.panel_3.panel_2.progress_1:setPercent(100)
    -- self:initMyHpBar()
    -- self:initEnemyHpBar()
    -- self:onMyHpChanged()
    -- self:onEnemyHpChanged()
end


function BattlePVPHpView:onRoundChanged(  )
	if Fight.isDummy or self.controler:isQuickRunGame() then
        return
    end
	self:initMyHpBar()
    self:initEnemyHpBar()
    self:onMyHpChanged()
    self:onEnemyHpChanged()
end


--[[
我方血量发生变化
]]
function BattlePVPHpView:onMyHpChanged(  )
	--math.round( view.hero.data:hp()/ view.hero.data:maxhp() *100 )
	if self.controler:isQuickRunGame() then
		return
	end
	local allHp = 0
	local curHp = 0
	local myCamp = self.controler.campArr_1
	for k,v in pairs(myCamp) do
		allHp = allHp + v.data:maxhp()
		curHp = curHp + v.data:hp()
	end
	if self.allMyHp ~= nil then allHp = self.allMyHp else self.allMyHp = allHp end
	local percent = math.round(curHp/allHp*100)
	--self.panel_1.panel_1.progress_1:tweenToPercent(percent)
	self.panel_3.panel_2.progress_1:tweenToPercent(percent)
end


--[[
敌方血量发生变化
]]
function BattlePVPHpView:onEnemyHpChanged(  )
	if self.controler:isQuickRunGame() then
		return
	end
	local allHp = 0
	local curHp = 0
	local enemyCamp = self.controler.campArr_2
	for k,v in pairs(enemyCamp) do
		allHp = allHp + v.data:maxhp()
		curHp = curHp + v.data:hp()
	end
	if self.allEnemyHp ~= nil then allHp = self.allEnemyHp else self.allEnemyHp = allHp end
	local percent = math.round(curHp/allHp*100)
	--self.panel_3.panel_2.progress_1:tweenToPercent(percent)
	self.panel_1.panel_1.progress_1:tweenToPercent(percent)
end


--[[
初始化我方血条
]]
function BattlePVPHpView:initMyHpBar(  )
	if self.iconInitedMyCamp  then 
		return 
	end
	
	self.panel_3.panel_1:visible(false)

	self.iconInitedMyCamp  = true

	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH, self.onMyHpChanged, self)
end

--[[
初始化地方血条
]]
function BattlePVPHpView:initEnemyHpBar(  )
	if self.iconInitedEnemyCamp then
		return 
	end
	
	self.panel_1.panel_2:visible(false)
	self.iconInitedEnemyCamp = true

	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH, self.onEnemyHpChanged, self)
end





return BattlePVPHpView