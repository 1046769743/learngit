--[[
	Author:李朝野
	Date: 2017.08.10
]]

--[[
	法宝剑大招

	技能描述：
	对主目标所在行内的辅助类型角色造成等量伤害；
	
	脚本处理部分：
	对主目标所在行内的配置类型角色造成等量伤害；

	参数：
	pro 角色类型
	rate 额外伤害系数（万分）
]]
local Skill_treasurejian_3 = require("game.battle.skillAi.Skill_treasurejian_3")
local Skill_treasurejian_3_1 = class("Skill_treasurejian_3_1", Skill_treasurejian_3)


function Skill_treasurejian_3_1:ctor(...)
	Skill_treasurejian_3_1.super.ctor(self,...)

	-- 标记是否处理了阴影显示
	self._flag = false
end
--[[
	给同行内的配置类型角色造成伤害
]]
function Skill_treasurejian_3_1:onHitHero(attacker,defender,skill,atkData,atkResult,dmg)
	local heroArr = {}
	local tPos = defender.data.posIndex
	local target = tPos % 2
	local flag = false
	for _,hero in ipairs(defender.campArr) do
		local hPos = hero.data.posIndex
		if hPos ~= tPos and hPos % 2 == target then
			if SkillBaseFunc:checkProfession(self._pro, hero) then
				table.insert(heroArr, hero)
				AttackUseType:damageHit(atkResult,math.abs(dmg),attacker,hero, atkData,skill,true)
				self:skillLog("阵营%s,%s号位职业为%s，满足法宝剑的条件被额外攻击",hero.camp,hero.data.posIndex,self._pro)
			end
		end
	end
	-- 最后一个攻击包检查死亡
	if atkData.isFinal then
		for _,hero in ipairs(heroArr) do
			if hero.data:hp() <= 0 then
				hero:doHeroDie()
			end
		end
	end

	-- 纯显示相关不需要处理
	if not self._flag and not Fight.isDummy then
		-- 处理阴影显示
		table.insert(heroArr, defender)
		local controler = attacker.controler
		if controler and controler.viewPerform then
			controler.viewPerform:setHeroViewAlpha(heroArr,attacker,outBlack)
		end
		-- 层级也处理一下
		for _,hero in ipairs(heroArr) do
			hero:onSkillBlack()
		end
		self._flag = true
	end
end
--[[
	重置一下标记
]]
function Skill_treasurejian_3_1:onAfterSkill(selfHero,skill)
	self._flag = false
	return true
end

return Skill_treasurejian_3_1