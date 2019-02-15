--[[
	Author:李朝野
	Date: 2017.08.10
	Modify: 2017.10.13
	Modify: 2018.03.08
]]

--[[
	赵灵儿被动

	技能描述：
	首个回合，释放技能降低两点怒气消耗，然后进入特殊待机动作，等此buff消失之后，恢复正常待机；攻击处于冰冻状态的目标，造成额外伤害(再次攻击)

	脚本处理部分：
	首回合放技能降低自己怒耗并改变动作状态，在攻击处于冰冻、沉默、眩晕、混乱等状态敌人时造成额外攻击

	参数：
	buffs 需要检查的buffs 1_2_3
	skillId 降低怒耗的技能Id
]]
local Skill_zhaolinger_4 = class("Skill_zhaolinger_4", SkillAiBasic)

function Skill_zhaolinger_4:ctor(skill,id,buffs,skillId)
	Skill_zhaolinger_4.super.ctor(self, skill, id)

	self:errorLog(buffs, "buffs")
	self:errorLog(skillId, "skillId")

	self._buffs = string.split(buffs, "_")

	table.map(self._buffs, function( v, k )
		return tonumber(v)
	end)

	self._exSkillId = skillId

	-- 判断是否触发（可能是打多个的所以需要用表）
	self._flag = {}

	-- 首回合
	self._firstRound = true
end

-- 首回合检查放技能（减怒耗技能）
function Skill_zhaolinger_4:onMyRoundStart(selfHero)
	if self:isSelfHero(selfHero) and self._firstRound then
		self._firstRound = false

		self:skillLog("赵灵儿首回合释放减怒耗技能")

		selfHero:setRoundReady(Fight.process_myRoundStart, false)
		local exSkill = self:_getExSkill(self._exSkillId)
		selfHero.currentSkill = exSkill

		selfHero:onMoveAttackPos(selfHero.currentSkill,true,true)
		selfHero.isAttacking = false

		if Fight.isDummy then
			selfHero:setRoundReady(Fight.process_myRoundStart, true)
		else
			selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart, true})
		end

		-- 置为特殊状态
		selfHero:setUseSpStand(true)
	end
end

--[[
	攻击时检测是否有对应buff
]]
function Skill_zhaolinger_4:onCheckAttack(attacker,defender,skill,atkData, dmg)
	-- 如果放了大招特殊状态置回
	if skill.skillIndex == Fight.skillIndex_max then
		attacker:setUseSpStand(false)
	end

	-- 赵灵儿额外攻击的特殊攻击包也不处理
	if skill == self._skill or atkData.__zhaolingerEx then return dmg end

	for _,buffType in ipairs(self._buffs) do
		if defender.data:checkHasOneBuffType(buffType) then
			self._flag[defender] = true
			break
		end
	end

	return dmg
end

-- 攻击结束根据buff接技能，打指定的人
function Skill_zhaolinger_4:onAfterSkill(selfHero, skill)
	local result = true

	if skill == self._skill then
		return result
	end

	-- 查找攻击目标
	local flag = false
	local enemyArr = {}
	for defender,value in pairs(self._flag) do
		if value and SkillBaseFunc:isLiveHero(defender) then
			flag = true
			enemyArr[#enemyArr + 1] = defender
		end

		self._flag[defender] = false
	end

	if flag then
		self:skillLog("赵灵儿触发额外攻击", #enemyArr)
		self._skill:setAppointAtkChooseArr()
		self._skill:setAppointAtkChooseArr(enemyArr)

		self._skill.isStitched = true

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			-- 如果当前自己不能行动或对方已经死亡则不会进行攻击
			if SkillBaseFunc:isLiveHero(selfHero) and selfHero.data:checkCanAttack() then
				selfHero:checkSkill(self._skill, false, self._skill.skillIndex)
			else
				-- 执行下一项
				selfHero.triggerSkillControler:excuteTriggerSkill()
			end
		end)
	end

	return result
end

-- 回合结束后重置标记
function Skill_zhaolinger_4:willNextAttack(attacker)
	if not self:isSelfHero(selfHero) then return end

	for k,v in pairs(self._flag) do
		self._flag[k] = false
	end
end

return Skill_zhaolinger_4