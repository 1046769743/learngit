--[[
	Author: lcy
	Date: 2018.05.22
]]

--[[
	小鬼特殊被动

	技能描述:
	死后会对指定单位造成大量伤害

	脚本处理部分:
	如上

	参数:
	skillId 死亡技的技能Id
	monsterId 攻击的指定目标
]]
local Skill_xiaogui_4 = class("Skill_xiaogui_4", SkillAiBasic)

function Skill_xiaogui_4:ctor(skill,id,skillId,monsterId)
	Skill_xiaogui_4.super.ctor(self,skill,id)

	self:errorLog(skillId, "skillId")
	self:errorLog(monsterId, "monsterId")

	self._skillId = skillId or 0
	self._monsterId = monsterId or 0

	self._flag = false

	self._light = nil
end

--[[
	自己死亡时
]]
function Skill_xiaogui_4:onOneHeroDied(who, attacker)
	if not self:isSelfHero(attacker) then return end
	if self._flag then return end

	local monster = self:_getMonster()
	if not monster then return end

	self._flag = true
	
	local selfHero = self:getSelfHero()

	selfHero.willDieSkill = true
	if selfHero.healthBar then
		selfHero.healthBar:opacity(0)
	end

	local skill = self:_getExSkill()
	-- 指定攻击目标
	skill:setAppointAtkChooseArr({monster})

	selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
		selfHero.data:changeValue(Fight.value_health, 1, Fight.valueChangeType_num)
		selfHero.willDieSkill = false
		self:skillLog("小鬼死亡技释放")
		-- 放技能
		selfHero:checkSkill(skill, false, nil)
	end)
end

function Skill_xiaogui_4:onAfterSkill(selfHero, skill)
	if skill == self:_getExSkill() then
		-- 不是复活的
		if not selfHero:checkWillBeRelive() then
			selfHero:doHeroDie(true)
		else
			selfHero:setOpacity(0)
		end
	end

	return true
end

function Skill_xiaogui_4:_getExSkill(...)
	if not self._exskill then
		self._exskill = Skill_xiaogui_4.super._getExSkill(self,self._skillId,true)
		-- 重置一下伤害类型
		self._exskill.atkType = Fight.atkType_pure
	end

	return self._exskill
end

-- 找指定人物
function Skill_xiaogui_4:_getMonster()
	local result = nil
	local selfHero = self:getSelfHero()

	local campArr = selfHero.campArr

	for _,hero in ipairs(campArr) do
		if hero.data.hid == self._monsterId then
			result = hero
			break
		end
	end

	return result
end


-- 传递参数
function Skill_xiaogui_4:setParams(light)
	self._light = light
end

function Skill_xiaogui_4:onBeforeSkill( ... )
	if not Fight.isDummy and self._light then
		local selfHero = self:getSelfHero()
		local controler = selfHero.controler
		if controler and controler.viewPerform then
			for _,hero in pairs(self._light) do
				-- 层级也处理一下
				hero:onSkillBlack()
			end
			
			controler.viewPerform:setHeroLightOrDark(self._light)
		end
		self._light = nil
	end
end

return Skill_xiaogui_4