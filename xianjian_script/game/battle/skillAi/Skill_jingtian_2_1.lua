--[[
	Author: lcy
	Date: 2018.03.27
]]

--[[
	景天小技能扩充1

	技能描述：
	如果造成击杀则获得一枚金币；

	脚本处理部分:
	击杀获得金币

	参数：
	@@ratio 造成额外伤害的比例 如 1500
	@@slots 需要控制的slots的名字 _ 分割 如"fu5_fu6_fu7_fu8" 填写顺序就是显示顺序
	@@num 击杀增加金币数
]]
local Skill_jingtian_2 = require("game.battle.skillAi.Skill_jingtian_2")
local Skill_jingtian_2_1 = class("Skill_jingtian_2_1", Skill_jingtian_2)

function Skill_jingtian_2_1:ctor(skill,id,ratio,slots,num)
	Skill_jingtian_2_1.super.ctor(self,skill,id, ratio, slots)

	self:errorLog(num, "num")

	self._num = tonumber(num or 0)
end

-- 击杀
function Skill_jingtian_2_1:onKillEnemy(attacker, defender)
	if not self:isSelfHero(attacker) then return end

	-- 造成击杀 加num个硬币
	self:skillLog("景天小技能击杀获得金币",self._num)
	self:addRune(self._num)
end

return Skill_jingtian_2_1