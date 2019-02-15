--[[
	Author:李朝野
	Date: 2017.08.10
	Modify: 2017.12.11
	Modify: 2017.12.12
]]

--[[
	法宝剑被动

	技能描述：
	如果自身攻击目标该行有辅助类型角色，小技能获得额外怒气；
	修改为自身所在行有xxxx
	修改为只触发一次
	
	脚本处理部分：
	如果自身攻击目标该行有配置类型角色，小技能获得额外怒气；
	修改为自身所在行有xxxx
	修改为只触发一次

	参数：
	pro 生效角色类型
	atkId 加怒攻击包
]]
local Skill_treasurejian_4 = class("Skill_treasurejian_4", SkillAiBasic)

function Skill_treasurejian_4:ctor(skill,id,pro,atkId)
	Skill_treasurejian_4.super.ctor(self, skill,id)
	
	self:errorLog(pro, "pro")
	self:errorLog(atkId, "atkId")

	self._pro = tonumber(pro) or 0
	self._atkData = ObjectAttack.new(atkId)

	self._flag = false -- 标志只触发一次
end

--[[
	是否为小技能，受击者同行是否有配置类型的角色
	修改为判定自身同行是否有配置类型角色
]]
function Skill_treasurejian_4:onCheckAttack(attacker,defender,skill,atkData, dmg)
	if skill.skillIndex == Fight.skillIndex_small and not self._flag then
		local tPos = attacker.data.posIndex
		local target = tPos % 2
		local flag = false
		for _,hero in ipairs(defender.campArr) do
			local hPos = hero.data.posIndex
			-- if hPos ~= tPos and hPos % 2 == target then
			if hPos % 2 == target then
				if SkillBaseFunc:checkProfession(self._pro, hero) then
					self:skillLog("阵营%s,%s号位职业为%s，满足法宝剑被动的条件",hero.camp,hero.data.posIndex,self._pro)
					flag = true
					break
				end
			end
		end
		-- 同行有配置类型
		if flag then
			self._flag = true
			attacker:sureAttackObj(attacker,self._atkData,self._skill)
		end
	end

	return dmg
end

--[[
	重置一下标记
]]
function Skill_treasurejian_4:onAfterSkill(selfHero,skill)
	self._flag = false
	return true
end

return Skill_treasurejian_4