--[[
	Author: lcy
	Date: 2018.07.04
	
	重写一些控制战斗流程的方法
]]

MiniLogicalControler = class("MiniLogicalControler", LogicalControlerEx)

function MiniLogicalControler:ctor( ... )
	MiniLogicalControler.super.ctor(self, ...)

	self._showSkillProcess = nil
	self._firstRoundCamp = nil
	self._processIdx = 1 -- 表示序列进行到了哪一步

	self._saveRandomSeed = nil 
end

-- override
function MiniLogicalControler:startRound()
	-- 记录一下重启点的随机数种子
	echo("-------------- 重置点的随机种子",BattleRandomControl.getCurStep())
	if not self._saveRandomSeed then
		self._saveRandomSeed = BattleRandomControl.getCurStep()
	end
	MiniLogicalControler.super.startRound(self)
end

-- 重置循环点种子
function MiniLogicalControler:resetCycleRandomSeed()
	BattleRandomControl.gotoTargetStep(self._saveRandomSeed)
end

-- override
function MiniLogicalControler:realStartRound()
	self.controler.viewPerform:resumeViewAlpha()

	self.controler:setGameStep(Fight.gameStep.battle)

	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ROUNDSTART,self.currentCamp)

	-- 读配置序列开始攻击
	return self:excuteShowSkillProcess()
end

-- 执行序列内容
function MiniLogicalControler:excuteShowSkillProcess()
	if self.__gameStep == Fight.gameStep.result then
		echo("退出战斗,不再执行序列")
		return
	end

	-- 所有序列内容执行完毕，调用重置方法
	if self._processIdx > #self._showSkillProcess then
		-- todo 重置
		self._processIdx = 1
		return self.controler:resetMiniGame()
	end

	local info = self._showSkillProcess[self._processIdx]
	self._processIdx = self._processIdx + 1

	-- 显示条幅
	if info.text then
		self.controler.gameUi:showDes(GameConfig.getLanguage(info.text))
	end
	
	if info.atype == Fight.miniProcess_attack then -- 攻击
		local hero = self:findHeroModel(info.camp, info.posIndex)

		self.attackingHero = hero

		-- 是否为主角
		if hero.data.isCharacter then
			return hero:checkTreasure(info.skillIndex)
		else
			return hero:checkSkill(nil,false,info.skillIndex) 
		end
	elseif info.atype == Fight.miniProcess_switch then -- 回合切换
		return self:endRound(self.currentCamp)
	elseif info.atype == Fight.miniProcess_wait then -- 等待时间
		-- 等待后继续进行
		return self.controler:pushOneCallFunc(info.delay, "excuteShowSkillProcess", {})
	end
end

-- 初始化展示技能的信息
function MiniLogicalControler:initShowInfo(showInfo)
	self._firstRoundCamp = showInfo.firstRound
	self._showSkillProcess = showInfo.process

	if #self._showSkillProcess == 0 then
		echoError("奇侠展示序列没有任何操作，请检查当前关卡配置!!")
	end
end

function MiniLogicalControler:initWaveData()
	MiniLogicalControler.super.initWaveData(self)
	
	self.currentCamp = self._firstRoundCamp
end

--[[
	攻击完成方法重写下，读另一个人的攻击
]]
function MiniLogicalControler:onAttackComplete(lastHero,lastSkillIndex)
	--攻击完成切换成空闲状态
	self:updateBattleState(Fight.battleState_none)
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ATTACK_COMPLETE,{camp = lastHero.camp})
	self.attackingHero = nil
	self.preAttackingHero = nil

	-- 攻击结束之后将阵位隐藏（人物被攻击时如果受到阵位保护，阵位会显示出来）
	self.controler.formationControler:doFinishBuZhen()

	self.controler.screen:setFollowType(2,{x=self.controler.middlePos,y = GameVars.halfResHeight})
	self.controler.camera:setScaleTo({10,1},{x=self.controler.middlePos,y = Fight.initYpos_3 })

	-- 如果有协助攻击
	if self:chkDoAssistAttack(lastHero,lastSkillIndex) then
		return
	end

	-- 读配置序列开始攻击
	self:excuteShowSkillProcess()
end

-- function MiniLogicalControler:endRound(camp)
-- 	return self:doEndRound(camp)
-- end

return MiniLogicalControler