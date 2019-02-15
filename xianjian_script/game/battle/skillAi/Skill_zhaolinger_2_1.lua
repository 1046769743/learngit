--[[
	Author: lcy
	Date: 2018.03.28
]]

--[[
	赵灵儿小技能扩充1

	技能描述：
	小技能，攻击处于冰冻状态下的目标对目标周围单位造成一定攻击力伤害

	脚本处理部分：
	攻击主目标的同时做检查如果符合条件对周围目标造成伤害（需要处理赵灵儿换法宝的情况）

	参数:
	@@atkId 对周围做攻击的攻击包
]]
local Skill_zhaolinger_2_1 = class("Skill_zhaolinger_2_1", SkillAiBasic)

function Skill_zhaolinger_2_1:ctor(skill,id, atkId)
	Skill_zhaolinger_2_1.super.ctor(self,skill,id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

-- 攻击时检查相关条件
function Skill_zhaolinger_2_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 如果主目标被冰冻
	if defender.data:checkHasOneBuffType(Fight.buffType_bingdong) then
		-- 需要按位置找人，不然大体型的人无法找到
		local campArr = defender.campArr
		local posIndex = defender.data.posIndex
		local line = math.floor((posIndex - 1) / 2)

		for pos=1,6 do
			if math.abs(pos - posIndex)	== 2 or math.floor((pos - 1)/2) == line then
				local hero = AttackChooseType:findHeroByPosIndex(pos, campArr)
				if hero ~= nil and hero ~= defender and SkillBaseFunc:isLiveHero(hero) then
					self:skillLog("阵营:%s,%s号位被赵灵儿溅射",hero.camp,hero.data.posIndex)
					attacker:sureAttackObj(hero, self._atkData, skill)
				end
			end
		end
	end
end

return Skill_zhaolinger_2_1