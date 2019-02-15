--[[
	Author:李朝野
	Date: 2017.06.28
]]

--[[
	小鬼（喜怒哀）
	
	技能描述：
	当喜怒哀同时在场时，攻击放合体技能

	脚本处理部分：
	当喜怒哀同时在场时，攻击放合体技能

	参数：
	合体技能需要配成特殊技
	relations 触发技能需要的相关技能Id 在场另外合体小鬼的技能id(100431_100432)
]]
local Skill_xiaogui_2 = class("Skill_xiaogui_2", SkillAiBasic)

function Skill_xiaogui_2:ctor(skill,id,relations)
	Skill_xiaogui_2.super.ctor(self,skill,id)

	self:errorLog(relations, "relations")

	self._relations = {} -- 存相关id

	local t = string.split(relations, "_")
	self._num = #t

	for _,hid in ipairs(t) do
		self._relations[hid] = true
	end
end

function Skill_xiaogui_2:onBeforeCheckSkill( selfHero, skill )
	-- 没配返回
	if self._num == 0 then return end

	local result = skill

	-- 寻找满足条件的人
	local relations = {}
	local count = 0

	local key = nil
	if self._skill.skillIndex == Fight.skillIndex_small then
		key = "hasAutoMove"
	elseif self._skill.skillIndex == Fight.skillIndex_max then
		key = "hasOperate"
	end

	for _,hero in ipairs(selfHero.campArr) do
		local skill = hero.data:getSpecialSkill()
		local hid = nil

		if skill then
			hid = skill.hid
		end
		
		if hid 
			and hero ~= selfHero -- 不是自己
			and SkillBaseFunc:isLiveHero(hero) -- 是活人
			and hero.data:checkCanAttack() -- 可攻击
			and self._relations[hid] -- 是相关人
			and not relations[hid] -- 尚未找到
			and (not key or not hero[key]) -- 此技能没有使用过
		then
			count = count + 1
			relations[hid] = hero -- 存人
		end

		if count == self._num then break end
	end

	-- 满足条件的人都找齐了
	if count == self._num then
		-- 释放特殊技
		result = selfHero.data:getSpecialSkill()
		local light = {}
		-- 大家一起做动作，并标记为已攻击过
		for _,hero in pairs(relations) do
			hero:justFrame(hero.data:getSpecialSkill():sta_action())
			if key and hero[key] ~= nil then
				hero[key] = true
			end
			if not Fight.isDummy then
				table.insert(light, hero)
			end
		end
		
		if result.skillExpand then
			result.skillExpand:setParams(light)
		end
	end

	return result
end

function Skill_xiaogui_2:checkBeforeSkill( ... )
	if not Fight.isDummy then
		local selfHero = self:getSelfHero()
		local controler = selfHero.controler
		if controler and controler.viewPerform then
			controler.viewPerform:setHeroLightOrDark(self._light)
		end
		self._light = {}
	end
end

return Skill_xiaogui_2