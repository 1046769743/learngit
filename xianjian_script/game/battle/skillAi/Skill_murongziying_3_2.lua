--[[
	Author:李朝野
	Date: 2017.06.24
	Modify:	2017.10.12
	Modify:	2017.10.14
]]

--[[
	慕容紫英大招扩充2
	
	技能描述：
	自身气血比例高于70%时，增加40%伤害

	脚本处理部分：
	自身气血比例高于x时，增加y伤害

	参数：
	atkId 带有不增加怒气消耗buff的攻击包
	atkId1 带有不记次buff的攻击包 2017.11.13 pangkangning 修改
	hprate 血限比例
	dmgrate 增伤比例
]]
local Skill_murongziying_3_1 = require("game.battle.skillAi.Skill_murongziying_3_1")

local Skill_murongziying_3_2 = class("Skill_murongziying_3_2", Skill_murongziying_3_1)

function Skill_murongziying_3_2:ctor(skill,id, atkId, atkId1, hprate, dmgrate)
	Skill_murongziying_3_2.super.ctor(self, skill, id, atkId, atkId1)

	self:errorLog(hprate, "hprate")
	self:errorLog(dmgrate, "dmgrate")

	self._hpRate = tonumber(hprate or 0)
	self._dmgRate = tonumber(dmgrate or 0)
end

--[[
	进行增伤计算
]]
function Skill_murongziying_3_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local hprate = attacker.data:hp() / attacker.data:maxhp()
	if hprate >= self._hpRate/10000 then
		local exDmg = math.round(dmg * self._dmgRate/10000)
		dmg = dmg + exDmg
		self:skillLog("慕容紫英血量比例:%s，增伤:%s", hprate, exDmg)
	end

	return dmg
end

return Skill_murongziying_3_2