--[[
	Author:李朝野
	Date: 2017.10.09
	Modify: 2018.03.14
]]

--[[
	柳梦璃大招扩充1

	技能描述：
	每有一个队友阵亡，提高4%眩晕概率

	脚本处理部分：
	统计队友阵亡数量提高眩晕概率

	参数：
	@@buffId 概率眩晕buff
	@@ratio 每个阵亡队友提供的概率加成
]]
local Skill_liumengli_3 = require("game.battle.skillAi.Skill_liumengli_3")

local Skill_liumengli_3_1 = class("Skill_liumengli_3_1", Skill_liumengli_3)

function Skill_liumengli_3_1:ctor(skill,id, buffId, ratio)
	Skill_liumengli_3_1.super.ctor(self, skill,id, buffId)

	self._count = 0 -- 统计阵亡人数

	self._ratio = tonumber(ratio or 0)
end

-- 有人死亡时记录阵亡人数
function Skill_liumengli_3_1:onOneHeroDied(attacker, defender)
	if self:isSelfHero(defender) then return end

	local selfHero = self:getSelfHero()
	-- 是否是队友
	if selfHero.camp ~= defender.camp then return end

	self._count = self._count + 1
end

--[[
	统计队友阵亡数量提高眩晕概率
]]
function Skill_liumengli_3_1:onAfterAttack(attacker,defender,skill,atkData)
	local buffObj = self:getBuff(self._buffId)
	buffObj.ratio = buffObj.ratio + self._ratio * self._count

	self:skillLog("柳梦璃对阵营%s,%s号位做眩晕buff，我方阵亡人数:%s",defender.camp,defender.posIndex,self._count)

	-- 做眩晕
	defender:checkCreateBuffByObj(buffObj, attacker, skill)
end

return Skill_liumengli_3_1