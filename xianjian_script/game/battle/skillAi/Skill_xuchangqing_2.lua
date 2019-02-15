--[[
	Author:李朝野
	Date: 2017.08.01
	Modify: 2018.03.16
]]

--[[
	徐长卿小技能（联动被动）

	技能描述:
	攻击单体，有符文的时候，消耗1枚符文，为己方气血比例最低增加一定格挡率；
	
	脚本处理部分：
	计算符文数，做加增益

	参数：
	atkId 带有增加格挡率buff的攻击包
]]
local Skill_xuchangqing_2 = class("Skill_xuchangqing_2", SkillAiBasic)

function Skill_xuchangqing_2:ctor(skill,id, atkId)
	Skill_xuchangqing_2.super.ctor(self, skill, id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

-- 检查增加格挡率情况
function Skill_xuchangqing_2:onAfterSkill(selfHero, skill)
	-- 被动技能
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if not skill4expand then return end

	local count = skill4expand:getRuneNum()

	if count > 0 then
		local hero = SkillBaseFunc:getMinHpHero(selfHero.campArr)

		if hero then
			self:skillLog("徐长卿符文数:%s，小技能使用符文给己方:%s号位增加格挡率", count, hero.data.posIndex)

			selfHero:sureAttackObj(hero,self._atkData,skill)
			-- 联动被动技能修改符文数量
			skill4expand:useRune(1)
		end
	end

	return true
end

return Skill_xuchangqing_2