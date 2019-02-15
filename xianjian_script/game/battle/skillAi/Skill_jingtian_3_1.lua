--[[
	Author:李朝野
	Date: 2017.06.26
]]


--[[
	景天

	技能描述：
	单体，并有一定几率连续再次对目标触发怒气技能攻击，最大连击上限5次；
	扩展怒气技，如果怒气技能对目标造成了击杀，则恢复自身15%最大生命。

	脚本处理部分：
	并有一定几率连续再次对目标触发怒气技能攻击，最大连击上限5次；
	如果怒气技能对目标造成了击杀，则恢复自身15%最大生命。

	参数：
	@@maxTimes 最大连击次数
	@@ratios 每次的触发概率 "1000_2000"这样配为了减少参数个数
	@@skills 每次成功触发播放的skillId "xxxxxx_xxxxxx"
	@@failSkill 判定失败时播放的skillId "xxxxxx"
	@@atkId 击杀恢复的生命值的攻击包
]]
local Skill_jingtian_3 = require("game.battle.skillAi.Skill_jingtian_3")
local Skill_jingtian_3_1 = class("Skill_jingtian_3_1", Skill_jingtian_3)


function Skill_jingtian_3_1:ctor(skill,id,maxTimes,ratios,skills,failSkill,atkId)
	Skill_jingtian_3_1.super.ctor(self,skill,id,maxTimes,ratios,skills,failSkill)
	
	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

--[[
	击杀获得生命值
]]
function Skill_jingtian_3_1:onKillEnemy( attacker,defender )
	self:skillLog("景天大招击杀进行给自己加血的攻击包")
	Skill_jingtian_3_1.super.onKillEnemy(self, attacker, defender)
	attacker:sureAttackObj(attacker,self._atkData,self._skill)
end

return Skill_jingtian_3_1