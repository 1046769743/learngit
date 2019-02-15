--[[
	Author: lcy
	Date: 2018.05.15
]]

--[[
	玄霄·冰 大招扩充2

	技能描述:
	玄冰，如果目标带有寒冰效果，则恢复造成伤害的30%气血。

	脚本处理部分:
	同上

	参数:
	@@fireId 对应等级的火技能id
	@@buffId 冰冻buffId
	@@dmgrate 伤害转血比例
	@@buffId2 加血buffId（类型为值，value由脚本动态赋值）
]]

local Skill_xuanxiao_ice_3_1 = require("game.battle.skillAi.Skill_xuanxiao_ice_3_1")
local Skill_xuanxiao_ice_3_2 = class("Skill_xuanxiao_ice_3_2", Skill_xuanxiao_ice_3_1)

function Skill_xuanxiao_ice_3_2:ctor(skill,id, fireId, buffId, dmgrate, buffId2)
	Skill_xuanxiao_ice_3_2.super.ctor(self,skill,id, fireId, buffId)

	self:errorLog(dmgrate, "dmgrate")
	self:errorLog(buffId2, "buffId2")

	self._dmgrate = tonumber(dmgrate or 0)
	self._buffId2 = buffId2 or 0
end

-- 攻击完检查
function Skill_xuanxiao_ice_3_2:onAfterAttack(attacker,defender,skill,atkData)
	if self._flag[defender] then
		local buffObj = self:getBuff(self._buffId2)
		buffObj.value = math.round(self._flag[defender] * self._dmgrate / 10000)
		self._flag[defender] = nil
		
		self:skillLog("玄霄·冰大招扩充2攻击有寒冰效果的敌人",defender.camp, defender.data.posIndex)
		attacker:checkCreateBuffByObj(buffObj, attacker, self._skill)
	end
end

return Skill_xuanxiao_ice_3_2