--[[
	Author:李朝野
	Date: 2017.11.02
]]

--[[
	蓝葵大招
	
	技能描述：
	攻击全体，如果被攻击的目标带有增益效果，则对敌人施加易伤效果——免伤率降低；

	脚本处理部分：
	攻击全体，如果被攻击的目标带有增益效果，则对敌人施加易伤效果——免伤率降低；

	参数：
	atkId 带有buff的攻击包
]]

local Skill_lankui_3 = class("Skill_lankui_3", SkillAiBasic)

function Skill_lankui_3:ctor(skill,id,atkId)
	Skill_lankui_3.super.ctor(self,skill,id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

function Skill_lankui_3:onBeforeAttack(attacker,defender,skill,atkData)
	--如果对方有增益效果,那么执行攻击包
	if defender.data:checkHasKindBuff(Fight.buffKind_hao ) then
		attacker:sureAttackObj(defender,self._atkData,self._skill)
		self:skillLog("蓝葵攻击阵营:%s,%s号位触发大招效果",defender.camp,defender.data.posIndex)
	end
end

return Skill_lankui_3