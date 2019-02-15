--[[
	Author:李朝野
	Date: 2017.06.24
	Modify: 2017.10.12
	Modify: 2017.11.02
	Modify: 2018.03.09 不再继承大招的脚本
]]
--[[
	云天河

	技能描述：
	释放大招时，此次攻击每有一个目标被暴击，则有一定概率使本次大招获得额外怒气；

	脚本处理部分：
	此次攻击每有一个目标被暴击，则有一定概率使本次大招获得额外怒气；

	参数：
	atkId 带有需要buff的攻击包
	ratio 释放攻击包的概率
]]
-- local Skill_yuntianhe_3 = require("game.battle.skillAi.Skill_yuntianhe_3")

local Skill_yuntianhe_3_1 = class("Skill_yuntianhe_3_1", SkillAiBasic)

function Skill_yuntianhe_3_1:ctor(skill,id,atkId,ratio)
	Skill_yuntianhe_3_1.super.ctor(self,skill,id)

	self:errorLog(atkId, "atkId")
	self:errorLog(ratio, "ratio")

	self._atkData  = ObjectAttack.new(atkId)
	self._ratio = tonumber(ratio) or 0

	self._flag = true -- 标记保证一次攻击只获得一次
end

--[[
	目标生命百分比越高附加额外伤害越高
	有概率给自己加怒气
]]
function Skill_yuntianhe_3_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local dmg = Skill_yuntianhe_3_1.super.onCheckAttack(self, attacker, defender, skill, atkData, dmg)
	local atkResult = defender:getDamageResult(attacker, skill)
	-- 本次攻击暴击了，有一定概率作用攻击包
	if atkResult == Fight.damageResult_baoji or atkResult == Fight.damageResult_baojigedang then
		-- 判定概率
		if self._ratio > BattleRandomControl.getOneRandomInt(10001,1) and self._flag then
			self._flag = false
			self:skillLog("云天河暴击，为自己释放获得buff的攻击包")
			attacker:sureAttackObj(attacker,self._atkData,self._skill)
		end
	end

	return dmg
end

--[[
	最后重置
]]
function Skill_yuntianhe_3_1:onAfterSkill(selfHero, skill)
	self._flag = true
	return true
end

return Skill_yuntianhe_3_1