--[[
	Author: lcy
	Date: 2018.03.14
]]

--[[
	柳梦璃大招

	技能描述：
	群体伤害，10%概率眩晕;

	脚本处理部分：
	由于大招扩充2中需要动态改变眩晕概率，所以此处眩晕操作提到脚本里

	参数：
	@@buffId 概率眩晕buff
]]
local Skill_liumengli_3 = class("Skill_liumengli_3", SkillAiBasic)

function Skill_liumengli_3:ctor(skill,id, buffId)
	Skill_liumengli_3.super.ctor(self, skill, id)
	
	self:errorLog(buffId, "buffId")

	self._buffId = buffId or 0
end

--[[
	最后一个攻击包对受击者做眩晕
]]
function Skill_liumengli_3:onAfterAttack(attacker,defender,skill,atkData)
	local buffObj = self:getBuff(self._buffId)
	self:skillLog("柳梦璃对阵营%s,%s号位做眩晕buff",defender.camp,defender.data.posIndex)
	-- 做眩晕
	defender:checkCreateBuffByObj(buffObj, attacker, skill)
end

return Skill_liumengli_3