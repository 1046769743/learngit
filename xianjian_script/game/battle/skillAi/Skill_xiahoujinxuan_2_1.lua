--[[
	Author: lcy
	Date: 2018.03.28
]]

--[[
	夏侯瑾轩小技能扩充1

	技能描述：
	小技能，如果每有一个被攻击目标带有增益状态，则在技能之后为同排队友增加1份攻击力

	脚本处理部分：
	根据带有增益状态的攻击目标的个数给同排添加buff

	参数:
	@@buffId 增加攻击力buff
]]
local Skill_xiahoujinxuan_2_1 = class("Skill_xiahoujinxuan_2_1", SkillAiBasic)

function Skill_xiahoujinxuan_2_1:ctor(skill,id, buffId)
	Skill_xiahoujinxuan_2_1.super.ctor(self,skill,id)

	self:errorLog(buffId, "buffId")

	self._buffId = buffId or 0
	self._count = 0
end

-- 记录带有增益状态的被击目标个数
function Skill_xiahoujinxuan_2_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	if defender.data:checkHasOneBuffKind(Fight.buffKind_hao) then
		self._count = self._count + 1
	end
end

function Skill_xiahoujinxuan_2_1:onAfterSkill(selfHero, skill)
	if self._count > 0 then
		local num = self._count
		self._count = 0

		-- 同排有人
		local pos = math.ceil(selfHero.data.posIndex / 2)
		local flag = nil

		for _,hero in ipairs(selfHero.campArr) do
			if hero.data.gridPos.x == pos and hero ~= selfHero then
				flag = hero
				break
			end
		end

		if flag then
			local buffObj = self:getBuff(self._buffId)
			buffObj.value = tonumber(buffObj.value) * num
			if buffObj.calValue then
				buffObj.calValue.rate = tonumber(buffObj.calValue.rate) * num
				buffObj.calValue.n = tonumber(buffObj.calValue.n) * num
			end

			self:skillLog("带有增益的人的个数", num)
			-- 加buff
			flag:checkCreateBuffByObj(buffObj, selfHero, skill)
		end
	end

	return true
end

return Skill_xiahoujinxuan_2_1