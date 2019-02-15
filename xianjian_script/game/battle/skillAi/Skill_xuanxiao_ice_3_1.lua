--[[
	Author: lcy
	Date: 2018.05.15
]]

--[[
	玄霄·冰 大招扩充1

	技能描述:
	玄冰，攻击带有寒冰效果的敌人使敌人冰冻（寒冰效果不消失）;

	脚本处理部分:
	如上

	参数:
	@@fireId 对应等级的火技能id
	@@buffId 冰冻buffId
]]
local Skill_xuanxiao_ice_3 = require("game.battle.skillAi.Skill_xuanxiao_ice_3")
local Skill_xuanxiao_ice_3_1 = class("Skill_xuanxiao_ice_3_1", Skill_xuanxiao_ice_3)

function Skill_xuanxiao_ice_3_1:ctor(skill,id, fireId, buffId)
	Skill_xuanxiao_ice_3_1.super.ctor(self,skill,id,fireId)

	self:errorLog(buffId, "buffId")

	self._buffId = buffId or 0

	self._flag = {} -- 攻击前受击者是否有寒冰效果
end
-- 攻击时检查
function Skill_xuanxiao_ice_3_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 有寒冰效果
	if defender.data:checkHasOneBuffType(Fight.buffType_hanbing) then
		self:skillLog("玄霄·冰大招扩充1攻击有寒冰效果的敌人",defender.camp,defender.data.posIndex)
		defender:checkCreateBuff(self._buffId, attacker, self._skill)
		self._flag[defender] = dmg
	end

	return dmg
end

return Skill_xuanxiao_ice_3_1