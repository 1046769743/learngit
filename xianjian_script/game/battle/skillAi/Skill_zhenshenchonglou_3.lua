--[[
	Author:李朝野
	Date: 2017.06.29
]]

--[[
	真身重楼

	技能描述：
	对敌方单体造成伤害，并根据目标当前怒气值，附加额外伤害；
	若此次攻击造成击杀，则溢出伤害转嫁至敌方生命比例最高者。（额外的特效表现）

	脚本处理部分：
	对敌方单体造成伤害，并根据目标当前怒气值，附加额外伤害；
	若此次攻击造成击杀，则溢出伤害转嫁至敌方生命比例最高者。

	参数：
	@@dmgRate 怒气转换伤害的比率
	@@atkId 溢出伤害的攻击包
]]

local Skill_zhenshenchonglou_3 = class("Skill_zhenshenchonglou_3", SkillAiBasic)

function Skill_zhenshenchonglou_3:ctor(skill,id,dmgRate, atkId)
	Skill_zhenshenchonglou_3.super.ctor(self, skill, id)

	self:errorLog(dmgRate, "dmgRate")
	self:errorLog(atkId, "atkId")

	self._dmgRate = tonumber(dmgRate) or 0
	self._atkData = ObjectAttack.new(atkId)
	self._overDmg = 0
	self._overAtk = false
end

-- 辅助函数计算加成伤害
function Skill_zhenshenchonglou_3:calExEnergydmg( defender, dmg )
	-- 取敌方当前怒气值百分比
	local energyPer = defender.data:energy() / defender.data:maxenergy()
	-- 附加伤害值
	local exdmg = energyPer * self._dmgRate / 10000
	dmg = math.round(dmg + exdmg)

	self:skillLog("重楼怒气加成伤害:%d，加后伤害%d",exdmg, dmg)

	return dmg
end
-- 辅助函数处理溢出伤害
function Skill_zhenshenchonglou_3:calOverDmg( defender, dmg )
	-- 护盾
	local hudunValue = defender.data:getOneBuffValue(Fight.buffType_hudun )

	local overdmg = dmg - hudunValue - defender.data:hp()

	self:skillLog("真身重楼大招伤害溢出:%d，敌方护盾值:%d", overdmg, hudunValue)

	if overdmg > 0 then
		self._overDmg = overdmg
	else
		self._overDmg = 0
	end
end
--[[
	根据当前怒气值附加额外伤害
	计算溢出伤害
]]
function Skill_zhenshenchonglou_3:onCheckAttack( attacker,defender,skill,atkData,dmg )
	if atkData._zhenshenchonglou then -- 真身重楼特殊攻击包
		-- 伤害使用溢出伤害 不使用计算的伤害
		dmg = self._overDmg

		self._overDmg = 0
		self._overAtk = false
		self:skillLog("重楼对%d号位造成%d伤害，此伤害为溢出伤害。",defender.data.posIndex, dmg)
	else
		-- 计算怒气加成伤害
		dmg = self:calExEnergydmg(defender, dmg)
	end

	--[[
		计算溢出伤害
		考虑护盾
	]]
	self:calOverDmg(defender, dmg)

	return dmg
end


--[[
	如果击杀则伤害转嫁
]]
function Skill_zhenshenchonglou_3:onKillEnemy( attacker,defender )
	-- 如果有溢出伤害
	if self._overDmg > 0 then
		self._overAtk = true
	else
		self._overAtk = false
	end
end
--[[
	最后给一个人一次额外攻击
]]
function Skill_zhenshenchonglou_3:onAfterSkill( selfHero, skill )
	local result = true
	if self._overAtk then
		-- 寻找生命比例最高的人
		local targetHero = nil
		local maxP = nil
		for i=1,#selfHero.toArr do
			local hero = selfHero.toArr[i]
			local hpP = hero.data:hp() / hero.data:maxhp()
			if not maxP or maxP < hpP then
				targetHero = hero
				maxP = hpP
			end
		end

		if targetHero and targetHero.data:hp() > 0 then
			-- 直接调用函数造成伤害
			-- self:skillLog("重楼对%d号位造成%d溢出伤害",targetHero.data.posIndex, self._overDmg)
			-- AttackUseType:damageHit(Fight.damageResult_normal, self._overDmg,selfHero,targetHero, self._atkData, self._skill)
			
			self:skillLog("真身重楼对%d号位使用特殊攻击包", targetHero.data.posIndex)
			-- 重置敌人身上关于我本回合的伤害信息
			selfHero:resetCurEnemyDmgInfo()
			self._atkData._zhenshenchonglou = true -- 标记真身重楼特殊攻击包
			self._atkData.isFinal = true -- 不为final人物不会死亡
			-- 调用特殊攻击包
			selfHero:sureAttackObj(targetHero,self._atkData,skill)
		else
			self._overDmg = 0
		end

		result =false
		-- 若干帧后再调用技能结束，目前先取10
		selfHero:pushOneCallFunc(10, "onSkillActionComplete")
	end

	-- self._overAtk = false

	return result
end

return Skill_zhenshenchonglou_3