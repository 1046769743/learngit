--[[
	Author:李朝野
	Date: 2018.01.06
	Modify: 2018.05.11
]]

--[[
	幽月辰辉伞被动

	技能描述:
	普通仙术后，造成的伤害量将一部分转换为吸收盾，为己方气血比例最低者增加护盾

	脚本处理部分:
	将伤害记录下来，将值赋给护盾加给指定人物

	参数:
	@@buffId 护盾buff的Id
	@@changeR 伤害转化比例（万分）
]]
local Skill_youyuechenhui_4 = class("Skill_youyuechenhui_4", SkillAiBasic)

function Skill_youyuechenhui_4:ctor(skill,id, buffId, changeR)
	Skill_youyuechenhui_4.super.ctor(self, skill, id)

	self:errorLog(buffId, "buffId")
	self:errorLog(changeR, "changeR")

	self._buffId = buffId or 0
	self._changeR = tonumber(changeR or 0)

	self._dmgRecoder = {} -- 用于记录血量来计算实际伤害
end

-- 技能攻击之前记录一下血量
function Skill_youyuechenhui_4:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 不是普通仙术直接返回
	if skill.skillIndex ~= Fight.skillIndex_small then return dmg end

	self._dmgRecoder[defender] = {
		dmg = defender.data:hp(),
		cal = false, -- 标记是否经过计算
	}

	return dmg
end

-- 最后一个攻击包时计算一下造成的伤害
function Skill_youyuechenhui_4:onAfterAttack(attacker, defender, skill, atkData)
	if self._dmgRecoder[defender] then
		self._dmgRecoder[defender].dmg = self._dmgRecoder[defender].dmg - defender.data:hp()
		self._dmgRecoder[defender].cal = true
	end
end

-- 在技能最后根据伤害情况计算护盾
function Skill_youyuechenhui_4:onAfterSkill(selfHero, skill)
	-- 统计数值
	local value = 0
	for _,info in pairs(self._dmgRecoder) do
		if info.cal then
			value = value + info.dmg
		end
	end

	-- 清空
	self._dmgRecoder = {}

	value = math.round(value * self._changeR / 10000)

	if value > 0 then
		local tHero = nil
		local tHp = nil
		-- 寻找血量最低的
		for _,hero in ipairs(selfHero.campArr) do
			local hpPer = hero.data:getAttrPercent(Fight.value_health)
			if not tHp or hpPer < tHp then
				tHp = hpPer
				tHero = hero
			end
		end
		if tHero then
			local tempObj = self:getBuff(self._buffId)
			tempObj.value = value

			tHero:checkCreateBuffByObj(tempObj, selfHero, self._skill)
			self:skillLog("幽月辰辉伞，为阵营:%s-%s号位，提供护盾值:%s", tHero.camp, tHero.data.posIndex, value)
		end
	end

	return true
end

return Skill_youyuechenhui_4