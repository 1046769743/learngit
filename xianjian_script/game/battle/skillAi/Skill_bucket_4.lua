--[[
	Author:李朝野
	Date: 2017.12.22
	Modify: 2018.03.03
]]

--[[
	爆炸桶被动

	描述：
	当被击杀时，释放当前被动技能;

	参数：
	
]]
local Skill_bucket_4 = class("Skill_bucket_4", SkillAiBasic)

function Skill_bucket_4:ctor(skill,id)
	Skill_bucket_4.super.ctor(self, skill, id)

	self._flag = false
end

-- 当自己死亡时
function Skill_bucket_4:onOneHeroDied( attacker, defender )
	local selfHero = self:getSelfHero()

	if selfHero ~= defender then return end -- 不是自己不爆炸

	if not self._flag then
		self._flag = true
		selfHero.willDieSkill = true -- 标记为会复活是为了对象不删除（讨巧做法）
		if selfHero.healthBar then
			-- 不能用visible因为上面有点击事件
			selfHero.healthBar:opacity(0)
		end

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			selfHero.data:changeValue(Fight.value_health, 1, Fight.valueChangeType_num)
			selfHero.willDieSkill = false
			-- 放技能
			selfHero:checkSkill(self._skill, false, nil)
		end)
	end
end

function Skill_bucket_4:onAfterSkill(selfHero,skill)
	if skill == self._skill then
		-- 不是复活的
		if not selfHero:checkWillBeRelive() then
			selfHero:doHeroDie(true)
		else
			selfHero:setOpacity(0)
		end
	end

	return true
end

return Skill_bucket_4