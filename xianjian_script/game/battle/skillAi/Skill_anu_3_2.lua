--[[
	Author:李朝野
	Date: 2017.7.31
	Modify: 2017.10.12
]]

--[[
	阿奴大招扩充2
	
	技能描述：
	攻击敌方横排；并附带概率沉默效果（通用沉默特效）；
	若大招未造成沉默效果，则敌人释放怒气仙术消耗量临时增加1点；
	大招攻击沉默角色时，使其降低攻击力；

	脚本处理部分：
	大招攻击沉默角色时，使其降低攻击力；

	参数：
	atkId 带有使对方释放怒气消耗量增加buff的攻击包
	atkId1 降低沉默角色攻击力的攻击包
]]
local Skill_anu_3_1 = require("game.battle.skillAi.Skill_anu_3_1")
local Skill_anu_3_2 = class("Skill_anu_3_2", Skill_anu_3_1)

function Skill_anu_3_2:ctor(skill,id,atkId,atkId1)
	Skill_anu_3_2.super.ctor(self,skill,id,atkId)

	self:errorLog(atkId1, "atkId1")

	self._atkData1 = ObjectAttack.new(atkId1)
end
--[[
	攻击沉默角色时使其降低攻击力
]]
function Skill_anu_3_2:onCheckAttack(attacker,defender,skill,atkData, dmg)
	-- 受击者中了沉默buff
	if defender.data:checkHasOneBuffType(Fight.buffType_chenmo) then
		attacker:sureAttackObj(defender,self._atkData1,self._skill)
		self:skillLog("阿奴攻击被沉默的角色阵营:%s,%s号位，对其施加减功攻击包",defender.camp,defender.data.posIndex)
	end

	return dmg
end

return Skill_anu_3_2