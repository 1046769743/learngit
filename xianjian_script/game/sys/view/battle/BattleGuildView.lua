
-- 
-- Author: pangkangning
-- Note: 共闯秘境UI
-- Date: 2018-05-15 
--
local BattleGuildView = class("BattleGuildView", UIBase)

function BattleGuildView:loadUIComplete(  )
    self._selectSpiritId = nil -- 神力选择id
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_toptips,UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_fanhui2,UIAlignTypes.MiddleBottom)

    self.btn_fanhui2:setTap(c_func(self.cancelUse,self))

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SPIRIT_START, self.onSpiritEnter, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SPIRIT_USE, self.onSpiritUse, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SPIRIT_END, self.onSpiritUse, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_QUICK_TO_ROUND, self.reloadUIByQuick, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BATTLESTATE_CHANGE, self.reloadUIByQuick, self)
end

function BattleGuildView:initControler( view,controler )
    self._battleView = view
    self.controler = controler
	self.panel_toptips:visible(false) -- 神力提示信息
end

-- 刷新ui
function BattleGuildView:reloadUIByQuick( )
	local bState = self.controler.logical:getBattleState()
	-- echo("s-s---",bState,bState == Fight.battleState_spirit)
	if bState == Fight.battleState_spirit then
		-- self:updateSpiritUse(true)
		self:updateSPViewVisible(true)
	else
		self:updateSpiritUse(false)
		self:updateSPViewVisible(false)
	end
end
function BattleGuildView:onSpiritEnter( )
	self:updateSPViewVisible(true) -- 神力显示与否
end
function BattleGuildView:onSpiritUse( )
	self._spiritData = nil
	self:updateSPViewVisible(false)
	self:updateSpiritUse(false)--隐藏自己
end
-- 更新神力选择界面
function BattleGuildView:updateSPViewVisible(b )
    if self.controler:isReplayGame() then
    	return
    end
	if self.controler:isQuickRunGame() then
		return
	end
	if b then
		if not self._spView then
			self._spView = WindowControler:showBattleWindow("BattleShenLiView",self.controler)
		end
		self._spView:showSpiritView()
	else
		if self._spView then
			self._spView:startHide()
			self._spView = nil
		end
	end
end
-- 更新神力介绍
function BattleGuildView:updateSpiritUse(b, sid)
    if self.controler:isReplayGame() then
    	return
    end
	if self.controler:isQuickRunGame() then
		return
	end
	self.btn_fanhui2:visible(b)
	self.panel_toptips:visible(b)
	self:visible(b)
	if b then
		self:updateSPViewVisible(false)
        local csData = FuncGuildBoss.getConcertSkillDataById(sid)
        self._spiritData = csData
        local _desArr = csData.describe2
        local aa = GameConfig.getLanguage(_desArr[1])
		self.panel_toptips.txt_1:setString(GameConfig.getLanguage(_desArr[1]))
	end
end
-- 显示第二行提示文字
function BattleGuildView:showNextTip( )
    local _desArr = self._spiritData.describe2
	if _desArr and #_desArr >= 2 then
		self.panel_toptips.txt_1:setString(GameConfig.getLanguage(_desArr[2]))
	end
end
-- 取消使用神力
function BattleGuildView:cancelUse( )
	self:updateSpiritUse(false)
	self:updateSPViewVisible(true)
end
-- 返回当前选择的神力Id
function BattleGuildView:getSelectedId( )
	if self._spiritData then
		return self._spiritData.mapSkill
	end
	return nil
end
-- 重置神力id
function BattleGuildView:resetSelectedId( )
	self._spiritData = nil
end
-- 获取神力的操作阵营
function BattleGuildView:getSelectedCamp( )
	if self._spiritData then
		return self._spiritData.camp
	end
	return nil
end
-- 获取神力技能操作方式
function BattleGuildView:getSpiritOType( )
	if self._spiritData then
		return self._spiritData.operationType
	end
	return nil
end
return BattleGuildView
