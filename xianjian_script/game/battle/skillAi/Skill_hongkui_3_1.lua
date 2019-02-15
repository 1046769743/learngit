--[[
	Author:李朝野
	Date: 2017.06.22
	Modify: 2018.03.07
]]

--[[
	红葵大招
	
	技能描述：
	50%概率额外伤害10%目标最大气血，特殊动作

	脚本处理部分：
	（特殊表现特效）做两套大招。有一定概率释放第二套大招

	参数：
	buffIdAM 减攻攻击包id	atkminus
	buffIdAP 加攻buffid（值由减功攻击包作用值决定）atkplus
	AMLimitR 减攻上限比例（万分）
	buffIdDM 减防攻击包id
	buffIdDP 加防buffid（值由减防攻击包作用值决定）
	DMLimitR 减防上限比例（万分）
	exSkillId 特殊大招的技能Id
	skillRatio 释放特殊大招的概率
]]
local Skill_hongkui_3 = require("game.battle.skillAi.Skill_hongkui_3")

local Skill_hongkui_3_1 = class("Skill_hongkui_3_1", Skill_hongkui_3)

function Skill_hongkui_3_1:ctor(skill,id, buffIdAM,buffIdAP,AMLimitR,buffIdDM,buffIdDP,DMLimitR,exSkillId,skillRatio)
	Skill_hongkui_3_1.super.ctor(self,skill,id, buffIdAM,buffIdAP,AMLimitR,buffIdDM,buffIdDP,DMLimitR)

	self:errorLog(exSkillId, "exSkillId")
	self:errorLog(skillRatio, "skillRatio")

	self._exSkillId = exSkillId
	self._ratio = tonumber(skillRatio) or 0
end

-- 可能释放两种技能
function Skill_hongkui_3_1:onBeforeCheckSkill(selfHero, skill)
	local result = skill
	
	-- 判断满足概率
	if self._exSkillId and self._ratio > BattleRandomControl.getOneRandomInt(10001,1) then
		result = self:_getExSkill(self._exSkillId, true)
	end

	return result
end

return Skill_hongkui_3_1