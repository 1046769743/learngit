--[[
	Author:李朝野
	Date: 2017.08.10
]]

--[[
	法宝剑大招

	技能描述：
	对敌方单体造成大量伤害；
	如果被攻击目标同一行有敌方任何辅助类角色，则对敌人造成额外伤害；
	
	脚本处理部分：
	如果被攻击目标同一行有敌方任何配置的角色，则对敌人造成额外伤害；

	参数：
	pro 角色类型
	rate 额外伤害系数（万分）
]]
local Skill_treasurejian_3 = class("Skill_treasurejian_3", SkillAiBasic)

function Skill_treasurejian_3:ctor(skill,id,pro,rate)
	Skill_treasurejian_3.super.ctor(self, skill,id)
	
	self:errorLog(pro, "pro")
	self:errorLog(rate, "rate")

	self._pro = tonumber(pro) or 0
	self._rate = tonumber(rate) / 10000 or 0
end
--[[
	查看受击者同行是否有辅助类角色
]]
function Skill_treasurejian_3:onCheckAttack(attacker,defender,skill,atkData, dmg)
	local tPos = defender.data.posIndex
	local target = tPos % 2
	local flag = false
	for _,hero in ipairs(defender.campArr) do
		local hPos = hero.data.posIndex
		if hPos ~= tPos and hPos % 2 == target then
			if SkillBaseFunc:checkProfession(self._pro, hero) then
				self:skillLog("阵营%s,%s号位职业为%s，满足法宝剑的条件",hero.camp,hero.data.posIndex,self._pro)
				flag = true
				break
			end
		end
	end
	-- 同行有配置类型
	if flag then
		local exDmg = math.round(attacker.data:atk() * self._rate)
		dmg = dmg + exDmg
		self:skillLog("法宝剑大招附加额外伤害%s", exDmg)
	end

	return dmg
end

return Skill_treasurejian_3