--[[
	Author:李朝野
	Date: 2017.10.12
]]

--[[
	阿奴大招扩充1
	
	技能描述：
	攻击敌方横排；并附带概率沉默效果（通用沉默特效）；
	若大招未造成沉默效果，则敌人释放怒气仙术消耗量临时增加1点；

	脚本处理部分：
	大招攻击沉默角色时，使其降低攻击力；

	参数：
	atkId 带有使对方释放怒气消耗量增加buff的攻击包
]]

local Skill_anu_3_1 = class("Skill_anu_3_1", SkillAiBasic)

function Skill_anu_3_1:ctor(skill,id,atkId)
	Skill_anu_3_1.super.ctor(self,skill,id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

--[[
	技能结束检查对方是否被自己沉默了
]]
function Skill_anu_3_1:onAfterAttack(attacker,defender,skill,atkData)
	-- 检查是否有来自阿奴的沉默buff
	local selfHero = self:getSelfHero()
	local flag = false
	local buffs = defender.data:getBuffsByType(Fight.buffType_chenmo)
	if buffs then
		for _,buff in pairs(buffs) do
			-- 是阿奴给的buff
			if buff.hero == selfHero then
				flag = true
				break
			end
		end
	end

	if not flag then
		self:skillLog("阿奴没有对阵营:%s,%s号位造成沉默，施加攻击包:%s",defender.camp,defender.data.posIndex,self._atkData.hid)
		attacker:sureAttackObj(defender,self._atkData,self._skill)
	end
end

return Skill_anu_3_1