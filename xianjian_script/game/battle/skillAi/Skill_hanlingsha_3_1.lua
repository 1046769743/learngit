--[[
	Author:李朝野
	Date: 2017.09.14
	Modify: 2018.03.03
]]

--[[
	韩菱纱大招扩充1

	技能描述：
	怒气仙术如果未击杀目标，则为目标进行标记，持续两回合；
	韩菱纱攻击该目标时暴击率提升100%，破挡率提升100%;

	脚本处理部分：
	脚本用来接收参数，做标记，标志开启大招扩充1
	攻击提升属性的特性需要靠被动技能辅助实现；

	攻击带有buff的人之前给自己增加buff攻击完后去掉

	参数：
	buffId1 提升暴击率的buff
	buffId2 提升破挡率的buff
]]
local Skill_hanlingsha_3_1 = class("Skill_hanlingsha_3_1", SkillAiBasic)

function Skill_hanlingsha_3_1:ctor(skill,id, buffId1, buffId2)
	Skill_hanlingsha_3_1.super.ctor(self, skill, id)
	
	self:errorLog(buffId1, "buffId1")
	self:errorLog(buffId2, "buffId2")

	self._buffId1 = buffId1
	self._buffId2 = buffId2
	-- self._buffId3 = buffId3

	-- 是否传递了参数
	self._haspass = false
end
-- 检查释放大招
function Skill_hanlingsha_3_1:onCheckAttack(attacker,defender,skill,atkData, dmg)
	if not self._haspass then
		self._haspass = true
		local selfHero = self:getSelfHero()

		local specialSkill = selfHero.data:getSpecialSkill()
		local skill4expand = specialSkill and specialSkill.skillExpand or nil

		if skill4expand then 
			skill4expand:setExtraParams(self._skill,self._buffId1,self._buffId2)
		end
	end
	
	return dmg
end
-- 攻击结束后看受击者是否已经死亡
-- function Skill_hanlingsha_3_1:onAfterAttack(attacker,defender,skill,atkData)
-- 	-- 受击者没死
-- 	if SkillBaseFunc:isLiveHero(defender) then
-- 		local buffObj3 = self:getBuff(self._buffId3, self._skill)
-- 		defender:checkCreateBuffByObj(buffObj3, attacker, self._skill)
-- 	end
-- end

return Skill_hanlingsha_3_1