--[[
	Author:庞康宁
	Date: 2017.11.13
	Detail: 大招扩充2：当敌方处于某些Buff类型时，延长这些Buff的回合数，+1；
	modefi:
	当主角释放炫龙拳以前，如果获得了增益类Buff，另一个大招必定附带减防效果（有了大招扩充的逻辑，配表即可)
]]
local Skill_treasureLongxing_3_1 = require("game.battle.skillAi.Skill_treasureLongxing_3_1")
local Skill_treasureLongxing_3_2 = class("Skill_treasureLongxing_3_2", Skill_treasureLongxing_3_1)

-- buffs:某种buff列表
function Skill_treasureLongxing_3_2:ctor(...)
	Skill_treasureLongxing_3_2.super.ctor(self,...)
end
-- -- 攻击检测的时候、延长某些buff
-- function Skill_treasureLongxing_3_2:onCheckAttack(attacker,defender,skill,atkData, dmg  )
-- 	for k,v in ipairs(self._buffs) do
-- 		if defender.data:checkHasOneBuffType(v) then
-- 			defender.data:extendBuffByKind(v)
-- 		end
-- 	end
-- 	return dmg
-- end

return Skill_treasureLongxing_3_2