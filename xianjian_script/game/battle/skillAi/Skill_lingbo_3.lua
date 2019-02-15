--[[
	Author:李朝野
	Date: 2017.08.07
]]


--[[
	凌波大招

	技能描述：
	选取3次随机目标，攻击重复目标时，造成额外伤害；

	脚本处理部分：
	选取3次随机目标，攻击重复目标时，造成额外伤害；

	参数：
	rate 额外伤害的攻击力比例（万分）
]]
local Skill_lingbo_3 = class("Skill_lingbo_3", SkillAiBasic)

function Skill_lingbo_3:ctor(skill,id, rate)
	Skill_lingbo_3.super.ctor(self, skill, id)
	
	self:errorLog(rate, "rate")

	self._rate = tonumber(rate) or 0
	-- 记录是否攻击过
	self._record = {}
	self:_resetRecord()

	self._count = 0 -- 攻击次数
end

-- 重置记录
function Skill_lingbo_3:_resetRecord()
	-- for i=1,6 do
	-- 	self._record[i] = false
	-- end
	self._count = 0

	for k,v in pairs(self._record) do
		self._record[k] = false
	end
end
--[[
	附加伤害
]]
function Skill_lingbo_3:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local posIndex = defender.data.posIndex
	-- 攻击过
	if self._record[posIndex] then
		local exDmg = math.round(attacker.data:atk() * self._rate / 10000)
		dmg = dmg + exDmg
		self:skillLog("凌波重复攻击阵营%s，%s号位，附加伤害%s", defender.camp, posIndex, exDmg)
	else -- 未攻击过
		self._record[posIndex] = true
	end

	self._count = self._count + 1

	if self._count > 1 then
		-- 第一段之后伪装成拼接技能，最后再重置
		skill.isStitched = true
	end

	return dmg
end
--[[
	重置攻击信息，否则对于重复的人不会检查onCheckAttack
]]
function Skill_lingbo_3:onAfterAttack( selfHero, skill )
	-- 重置敌人身上关于我本回合的伤害信息
	selfHero:resetCurEnemyDmgInfo()
end

--[[
	回合结束重置攻击记录
]]
function Skill_lingbo_3:onAfterSkill( selfHero,skill )
	self:_resetRecord()
	
	-- 重置
	skill.isStitched = false

	return true
end
return Skill_lingbo_3