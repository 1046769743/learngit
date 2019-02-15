--[[
	Author: lcy
	Date: 2018.08.10
]]

--[[
	蜂灵技能扩充2

	技能描述：
	追击不再造成攻击力衰减

	参数:
	@@maxCount 最大触发次数
	@@atk 赋给神器的攻击力
	
	@@maxNum 最大追击次数
]]
local Skill_artifact_fengling_1 = require("game.battle.skillAi.Skill_artifact_fengling_1")
local Skill_artifact_fengling_2 = class("Skill_artifact_fengling_2", Skill_artifact_fengling_1)

function Skill_artifact_fengling_2:ctor(...)
	Skill_artifact_fengling_2.super.ctor(self, ...)
end

-- 攻击前处理攻击力
function Skill_artifact_fengling_2:onBeforeCheckSkill(selfHero, skill)
	-- 改变神器的攻击力
	selfHero.data:setAttribute(Fight.value_atk, math.round(self._atk))
	selfHero.data:setHeroElement(Fight.element_non)

	return skill
end

return Skill_artifact_fengling_2