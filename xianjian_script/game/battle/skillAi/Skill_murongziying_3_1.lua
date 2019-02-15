--[[
	Author:李朝野
	Date: 2017.06.24
	Modify:	2017.10.12
	Modify:	2017.10.14
]]

--[[
	慕容紫英大招扩充1
	
	技能描述：
	如果怒气仙术造成击杀，则不增长怒气消耗；

	脚本处理部分：
	如果怒气仙术造成击杀，则不增长怒气消耗；

	参数：
	atkId 带有不增加怒气消耗buff的攻击包
	atkId1 带有不记次buff的攻击包 2017.11.13 pangkangning 修改
]]
local Skill_murongziying_3 = require("game.battle.skillAi.Skill_murongziying_3")

local Skill_murongziying_3_1 = class("Skill_murongziying_3_1", Skill_murongziying_3)

function Skill_murongziying_3_1:ctor(skill,id, atkId, atkId1)
	Skill_murongziying_3_1.super.ctor(self, skill,id,atkId)

	self:errorLog(atkId1, "atkId1")

	self._atkData1 = ObjectAttack.new(atkId1)
end

function Skill_murongziying_3_1:onKillEnemy( attacker,defender )
	Skill_murongziying_3_1.super.onKillEnemy(self,attacker,defender)
	if not self:isSelfHero(attacker) then return end
	self:skillLog("慕容紫英击杀阵营:%s,%s号位，对自己施加攻击包:%s",defender.camp,defender.data.posIndex,self._atkData1.hid)
	attacker:sureAttackObj(attacker,self._atkData1,self._skill)
end

return Skill_murongziying_3_1