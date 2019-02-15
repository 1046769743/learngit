--[[
	Author:李朝野
	Date: 2017.08.07
]]


--[[
	唐雪见大招

	技能描述：
	为己方同排单位增加吸收盾持续两回合；
	该护盾具有一定生命，并在护盾持续期间，己方队友暴击率和破击率均有提升；
	-- 怒气仙术被附加者如果生命低于35%，则暴击和破击提升效果翻倍；
	修改版：
	怒气仙术被附加者如果生命低于35%，则必定暴击，暴击强度提升效果翻倍

	脚本处理部分：
	-- 怒气仙术被附加者如果生命低于35%，则暴击和破击提升效果翻倍；
	
	备注：
	技能本身提升的暴击和破击保留，当满足条件的时候用双倍数值的buff覆盖
	这里配置的buff要与技能本身的buff相同

	参数：
	hpPer 满足的血量比例（万分）
	buffId1 暴击buffId
	buffId2 必暴击buffId
]]
local Skill_tangxuejian_3 = require("game.battle.skillAi.Skill_tangxuejian_3")
local Skill_tangxuejian_3_1 = class("Skill_tangxuejian_3_1", Skill_tangxuejian_3)


function Skill_tangxuejian_3_1:ctor(skill,id,hpPer,buffId1,buffId2)
	Skill_tangxuejian_3_1.super.ctor(self,skill,id)

	self:errorLog(hpPer, "hpPer")
	self:errorLog(buffId1, "buffId1")
	self:errorLog(buffId2, "buffId2")

	self._hpPer = tonumber(hpPer) or 0

	-- self._buffObj1 = ObjectBuff.new(buffId1, self._skill)
	self._buffId1 = buffId1 or 0
	-- self._buffObj2 = ObjectBuff.new(buffId2, self._skill)
	self._buffId2 = buffId2 or 0
	-- 改变其值
	-- self._buffObj1.value = self._buffObj1.value * 2
	-- self._buffObj2.value = self._buffObj2.value * 2

	-- 标记是否满足条件
	self._flag = false
end
--[[
	判断是否满足条件
]]
-- function Skill_tangxuejian_3_1:onCheckAttack( attacker,defender,skill,atkData,dmg )
-- 	local hpPer = defender.data:hp() / defender.data:maxhp()
-- 	if hpPer < self._hpPer / 10000 then
-- 		-- 满足条件
-- 		self._flag = true
-- 	end

-- 	return dmg
-- end
--[[
	加提升后的暴击和破击
]]
function Skill_tangxuejian_3_1:onAfterAttack( attacker,defender,skill,atkData )
	local hpPer = defender.data:hp() / defender.data:maxhp()
	if hpPer < self._hpPer / 10000 then
		self:skillLog("唐雪见为满足血量条件的人加护盾，提升暴击效果，并加必暴击buff")
		local buffObj1 = self:getBuff(self._buffId1)
		buffObj1.value = buffObj1.value * 2
		local buffObj2 = self:getBuff(self._buffId2)

		defender:checkCreateBuffByObj(buffObj1, attacker, self._skill)
		defender:checkCreateBuffByObj(buffObj2, attacker, self._skill)
	end
	self._flag = false
end

return Skill_tangxuejian_3_1