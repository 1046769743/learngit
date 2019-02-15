--[[
	Author:李朝野
	Date: 2017.11.02
]]

--[[
	蓝葵大招扩充1
	
	技能描述：
	攻击全体，如果被攻击的目标带有增益效果，则立刻获得1张技能卡（随机，并且计次）
	每有1个带有增益效果的敌人，则己方随机一人怒气消耗降低，每有1人减一点

	脚本处理部分：
	如果被攻击的目标带有增益效果，则立刻获得1张技能卡
	每有1个带有增益效果的敌人，则己方随机一人怒气消耗降低，每有1人减一点

	参数：
	atkId 带有免伤降低buff的攻击包
	buffId 带有怒气降低buff的Id
]]
local Skill_lankui_3 = require("game.battle.skillAi.Skill_lankui_3")
local Skill_lankui_3_1 = class("Skill_lankui_3_1", Skill_lankui_3)

function Skill_lankui_3_1:ctor(skill,id,atkId,buffId)
	Skill_lankui_3_1.super.ctor(self,skill,id,atkId)

	self:errorLog(buffId, "buffId")

	-- self._buffObj = ObjectBuff.new(buffId, self._skill)
	self._buffId = buffId or 0

	self._count = 0 -- 记录有增益的人的个数

	self._flag = true -- 保证只会加一次
end
--[[
	在攻击到第一个人时就做检查
]]
function Skill_lankui_3_1:onBeforeAttack(attacker,defender,skill,atkData)
	Skill_lankui_3_1.super.onBeforeAttack(self, attacker,defender,skill,atkData)
	if not self._flag then return end
	
	self._flag = false

	local toArr = attacker.toArr
	for _,hero in ipairs(toArr) do
		if hero.data:checkHasKindBuff(Fight.buffKind_hao ) then
			self._count = self._count + 1
		end
	end
	if self._count > 0 then
		self:skillLog("蓝葵触发大招扩充1效果，敌方增益人数",self._count)
		-- 从己方选一人加buff
		local campArr = attacker.campArr
		local idx = BattleRandomControl.getOneRandomInt(#campArr+1,1)
		local hero = campArr[idx]
		local buffObj = self:getBuff(self._buffId)
		buffObj.value = -self._count
		hero:checkCreateBuffByObj(buffObj, attacker, self._skill)
	end
end

function Skill_lankui_3_1:onAfterSkill(selfHero,skill)
	self._flag = true
	self._count = 0

	return true
end

return Skill_lankui_3_1