--[[
	Author:李朝野
	Date: 2017.10.09
	Modify: 2018.08.09
]]

--[[
	李逍遥大招扩充2
	(从老代码复刻过来的)

	技能描述：
	自身生命越少，伤害提升越多（最多70%）

	脚本处理部分：
	自身生命越少，伤害提升越多

	参数：
	num 计数最大人数
	rate 每个人带来的加成
	buffIds 受到加成的buffId "xxx_xxx"
	
	ratioEx 每个人带来的概率加成
	ratioBuffIds 受到概率加成的buffId "xxx_xxx"

	ratio 加成最大值
]]
local Skill_lixiaoyao_3_1 = require("game.battle.skillAi.Skill_lixiaoyao_3_1")
local Skill_lixiaoyao_3_2 = class("Skill_lixiaoyao_3_2", Skill_lixiaoyao_3_1)

function Skill_lixiaoyao_3_2:ctor(skill,id,num,rate,buffIds,ratioEx,ratioBuffIds,ratio)
	Skill_lixiaoyao_3_2.super.ctor(self, skill, id, num,rate,buffIds,ratioEx,ratioBuffIds)
	
	self:errorLog(ratio, "ratio")

	self._ratio = tonumber(ratio) or 0

	-- 貌似还没实现这个方法
	-- if self._ratio < 0 then
	-- 	self._ratio = self._skill:getSkillParamsByValue(self._ratio)
	-- end
end

--[[
	不屈伤害加成
]]
function Skill_lixiaoyao_3_2:onCheckAttack(attacker,defender,skill,atkData, dmg  )
	--血量越少 伤害越高 最高给20%
	dmg = math.round(dmg * SkillBaseFunc:getBuquValue( attacker,defender,self._ratio ))  
	self:skillLog("李逍遥不屈效果触发", dmg)
	return dmg
end

return Skill_lixiaoyao_3_2