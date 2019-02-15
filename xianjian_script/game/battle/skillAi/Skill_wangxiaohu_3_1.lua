--[[
	Author: lcy
	Date: 2018.03.12
]]

--[[
	王小虎大招扩充1

	技能描述:
	释放过技能后进入特殊状态，带有虎魂标记的人对王小虎伤害降低20%

	脚本处理部分:
	需要将相关值传入被动，依赖备注技能辅助实现;

	参数:
	@@rate 伤害降低率
	@@lastRound 持续回合数
]]

local Skill_wangpengxu_3_1 = class("Skill_wangpengxu_3_1", SkillAiBasic)

function Skill_wangpengxu_3_1:ctor(skill,id, rate, lastRound)
	Skill_wangpengxu_3_1.super.ctor(self, skill, id)

	self:errorLog(rate, "rate")
	self:errorLog(lastRound, "lastRound")

	self._rate = tonumber(rate or 0)
	self._lastRound = tonumber(lastRound or 0)
end

-- 每次放大招激活被动即可
function Skill_wangpengxu_3_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 传递参数
	local selfHero = self:getSelfHero()

	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if skill4expand then 
		skill4expand:setExtraParams(self._rate,self._lastRound)
	end

	return dmg
end

return Skill_wangpengxu_3_1