--[[
	Author:李朝野
	Date: 2017.08.23
]]

--[[
	狐妖女小技能

	技能描述:
	为自己和同排队友增加攻击力若同排队友无人，则为身后一排队友加攻击力；
	如果狐妖女处于最后一排并且同排没有队友，则为自身增加攻击力；
	
	脚本处理部分：
	根据己方情况选择释放的技能

	参数：
	skills 2_3 给后排加的技能_给自己加的技能
]]
local Skill_huyaonv_2 = class("Skill_huyaonv_2", SkillAiBasic)

function Skill_huyaonv_2:ctor(skill,id, skills)
	Skill_huyaonv_2.super.ctor(self, skill, id)

	self:errorLog(skills, "skills")

	self._skills = string.split(skills, "_")
end

--[[
	根据己方站位情况选择释放技能
]]
function Skill_huyaonv_2:onBeforeCheckSkill(selfHero, skill)
	local result = skill

	-- 同排
	local colS = math.floor((selfHero.data.posIndex - 1) / 2)
	-- 后排
	local colB = colS + 1

	-- 遍历敌方统计每排人数
	local count = {[0] = 0, [1] = 0, [2] = 0, [3] = 0}

	for _,hero in ipairs(selfHero.campArr) do
		local col = math.floor((hero.data.posIndex - 1) / 2)
		count[col] = count[col] + 1
	end

	if count[colS] == 2 then -- 同排有人放原技能
		self:skillLog("狐妖女释放同排技能")
	elseif count[colB] > 0 then -- 后排有人放后排
		self:skillLog("狐妖女释放后排技能")
		result = self:_giveSkill(1, true)
	else -- 给自己加
		self:skillLog("狐妖女释放给自己的技能")
		result = self:_giveSkill(2, true)
	end

	return result
end

--[[
	idx 放的技能idx
	isExpand 是否继承扩展行为
]]
function Skill_huyaonv_2:_giveSkill(idx, isExpand)
	local selfHero = self:getSelfHero()
	local skill = self._skill
	-- 取技能
	local exSkill = ObjectSkill.new(self._skills[idx], 1, "A1", skill.skillParams)
	-- 设置hero
	exSkill:setHero(selfHero)
	-- 设置法宝
	exSkill:setTreasure(skill:getTreasure(), skill:getSkillIndex())

	if isExpand then
		-- 继承扩展行为
		exSkill.skillExpand = skill.skillExpand
	end

	return exSkill
end

return Skill_huyaonv_2