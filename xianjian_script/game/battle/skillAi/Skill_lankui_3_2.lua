--[[
	Author:李朝野
	Date: 2017.11.02
]]

--[[
	蓝葵大招扩充2
	
	技能描述：
	攻击全体，如果被攻击的目标带有增益效果，则立刻获得1张技能卡（随机，并且计次）
	每有1个带有增益效果的敌人，则己方随机一人怒气消耗降低，每有1人减一点
	如果被攻击者有增益状态的角色  概率眩晕buff

	脚本处理部分：
	如果被攻击的目标带有增益效果，则立刻获得1张技能卡
	每有1个带有增益效果的敌人，则己方随机一人怒气消耗降低，每有1人减一点
	如果被攻击者有增益状态的角色  概率眩晕buff

	参数：
	atkId 带有免伤降低buff的攻击包
	buffId 带有怒气降低buff的Id
	atkId1 带有眩晕buff的攻击包
]]
local Skill_lankui_3_1 = require("game.battle.skillAi.Skill_lankui_3_1")
local Skill_lankui_3_2 = class("Skill_lankui_3_2", Skill_lankui_3_1)

function Skill_lankui_3_2:ctor(skill,id,atkId,buffId,atkId1)
	Skill_lankui_3_2.super.ctor(self,skill,id,atkId,buffId)

	self:errorLog(atkId1, "atkId1")

	self._atkData1 = ObjectAttack.new(atkId1)
end

function Skill_lankui_3_2:onBeforeAttack( attacker,defender,skill,atkData )
	-- 先处理父类的逻辑
	Skill_lankui_3_2.super.onBeforeAttack(self,attacker,defender,skill,atkData)

	--如果对方有增益效果,那么执行攻击包
	if not defender.data:checkHasKindBuff(Fight.buffKind_hao ) then
		return 
	end
	self:skillLog("蓝葵大招扩充2攻击阵营:%s,%s号位,施加攻击包",defender.camp,defender.data.posIndex)
	attacker:sureAttackObj(defender,self._atkData1,self._skill)
end

return Skill_lankui_3_2