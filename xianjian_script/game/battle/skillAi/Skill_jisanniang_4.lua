--[[
	Author: lcy
	Date: 2018.06.05 
]]

--[[
	姬三娘被动

	技能描述:
	普攻攻击/怒气仙术会给 目标添加标记，攻击标记，获得必定暴击，必定破挡

	脚本处理部分:
	给受击者添加标记，攻击受到标记的目标

	参数:
	做判断的标记使用通用标记,标记直接配置在技能里

	buffId1 提升暴击率的buff
	buffId2 提升破挡率的buff
]]
local Skill_jisanniang_4 = class("Skill_jisanniang_4", SkillAiBasic)

function Skill_jisanniang_4:ctor(skill,id, buffId1, buffId2)
	Skill_jisanniang_4.super.ctor(self, skill, id)

	self:errorLog(buffId1, "buffId1")
	self:errorLog(buffId2, "buffId2")

	self._buffId1 = buffId1
	self._buffId2 = buffId2

	self._useBuff = false
end

-- 检查伤害类型前加强
function Skill_jisanniang_4:onBeforeDamageResult(attacker, defender, skill, atkData)
	local attacker = self:getSelfHero()
	-- 判断目标身上是否有相应buff
	if defender.data:checkHasOneBuffType(Fight.buffType_tag_common, attacker) then
		self:skillLog("姬三娘攻击有标记的人，给自己加buff:",self._buffId1, self._buffId2)
		self._useBuff = true
		-- 给自己加增强的buff
		attacker:checkCreateBuff(self._buffId1, attacker, self._skill)
		attacker:checkCreateBuff(self._buffId2, attacker, self._skill)
	end
end

-- 检查完攻击类型后去掉相关buff
function Skill_jisanniang_4:onCheckAttack(attacker, defender, skill, atkData, dmg)
	if self._useBuff then
		self._useBuff = false
		self:skillLog("姬三娘去掉增强buff:",self._buffId1,self._buffId2)
		attacker.data:clearOneBuffByHid(self._buffId1)
		attacker.data:clearOneBuffByHid(self._buffId2)
	end

	return dmg
end

return Skill_jisanniang_4