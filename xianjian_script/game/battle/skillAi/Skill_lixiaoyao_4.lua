--[[
	Author:李朝野
	Date: 2017.07.24
	Modify: 2018.03.14
]]
--[[
	李逍遥被动

	技能描述：
	暴击后，将一定伤害比例转换为自身生命值；
	并且清除自身减益效果；
	需要支持配置转伤比例和atk包

	脚本处理部分：
	暴击后，将一定伤害比例转换为自身生命值；
	并且清除自身减益效果；

	参数：
	rate 伤害转换比例
	atkId 清除减益效果的攻击包id
]]
local Skill_lixiaoyao_4 = class("Skill_lixiaoyao_4", SkillAiBasic)

function Skill_lixiaoyao_4:ctor(skill,id,rate,atkId)
	Skill_lixiaoyao_4.super.ctor(self, skill, id)

	self:errorLog(rate, "rate")
	self:errorLog(atkId, "atkId")

	self._rate = tonumber(rate) or 0
	self._atkData = ObjectAttack.new(atkId)

	-- 记录增加的血量和暴击结果
	self._flag = false
	self._addHp = 0
end

--[[
	暴击时做一些事情
]]
function Skill_lixiaoyao_4:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local atkResult = defender:getDamageResult(attacker, skill)
	-- 本次攻击暴击了
	if atkResult == Fight.damageResult_baoji or atkResult == Fight.damageResult_baojigedang then
		-- 增加的血量
		local addHp = math.round(dmg * self._rate / 10000)
		--[[
		attacker.data:changeValue(Fight.value_health, addHp, 1, 0)
		AttackUseType:checkkMultyAttackEffect(attacker,atkData,Fight.hitType_zhiliao ,addHp, 1)
	
		-- 做净化的攻击包
		attacker:sureAttackObj(attacker,self._atkData,self._skill)
		self:skillLog("李逍遥暴击被动触发，增加血量%s,并且做净化的攻击包",addHp)
		]]
		self._flag = true
		self._addHp = addHp
	end

	return dmg
end

--[[
	暴击之后做一些事
]]
function Skill_lixiaoyao_4:onAfterAttack(attacker,defender,skill,atkData)
	if self._flag then
		-- 增加的血量
		local addHp = self._addHp
		attacker.data:changeValue(Fight.value_health, addHp, 1, 0)
		AttackUseType:checkkMultyAttackEffect(attacker,atkData,Fight.hitType_zhiliao ,addHp, 1)
		
		-- 做净化的攻击包
		attacker:sureAttackObj(attacker,self._atkData,self._skill)
		self:skillLog("李逍遥暴击被动触发，增加血量%s,并且做净化的攻击包",addHp)

		self._flag = false
		self._addHp = 0
	end
end

return Skill_lixiaoyao_4