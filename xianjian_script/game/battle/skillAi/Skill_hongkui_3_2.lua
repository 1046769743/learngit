--[[
	Author:李朝野
	Date: 2017.06.22
	Modify: 2018.03.07
]]

--[[
	红葵大招
	
	技能描述：
	附带红葵最大气血10%额外伤害

	脚本处理部分：
	大招附加自身最大生命百分比的额外伤害

	参数：
	buffIdAM 减攻攻击包id	atkminus
	buffIdAP 加攻buffid（值由减功攻击包作用值决定）atkplus
	AMLimitR 减攻上限比例（万分）
	buffIdDM 减防攻击包id
	buffIdDP 加防buffid（值由减防攻击包作用值决定）
	DMLimitR 减防上限比例（万分）
	exSkillId 特殊大招的技能Id
	skillRatio 释放特殊大招的概率
	dmgRage 最大生命值伤害的百分比
]]
local Skill_hongkui_3_1 = require("game.battle.skillAi.Skill_hongkui_3_1")

local Skill_hongkui_3_2 = class("Skill_hongkui_3_2", Skill_hongkui_3_1)

function Skill_hongkui_3_2:ctor(skill,id, buffIdAM,buffIdAP,AMLimitR,buffIdDM,buffIdDP,DMLimitR,exSkillId,skillRatio,dmgRage)
	Skill_hongkui_3_2.super.ctor(self, skill,id, buffIdAM,buffIdAP,AMLimitR,buffIdDM,buffIdDP,DMLimitR,exSkillId,skillRatio)

	self:errorLog(dmgRage, "dmgRage")

	self._dmgRage = tonumber(dmgRage) or 0
end

--[[
	大招附加自身最大生命百分比的额外伤害
]]
function Skill_hongkui_3_2:onCheckAttack( attacker,defender,skill,atkData,dmg )
	local dmg = Skill_hongkui_3_2.super.onCheckAttack(self, attacker,defender,skill,atkData,dmg)
	-- 最大生命值
	local maxHp = attacker.data:maxhp()
	-- echoError("伤害", dmg)
	dmg = math.round(dmg + maxHp * self._dmgRage / 10000)
	self:skillLog("红葵大招扩充2最终伤害",dmg)
	-- echo("额外伤害", dmg)
	return dmg
end

return Skill_hongkui_3_2