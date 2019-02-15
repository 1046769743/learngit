--[[
	Author:李朝野
	Date: 2018.01.08
]]

--[[
	主角法宝巫月神刀大招扩充1

	技能描述:
	连续6次选取敌方一人作为目标进行攻击；
	当目标被击杀后，立刻切换目标执行剩余攻击；
	在切换目标后，增加自身攻击力，持续该回合，可叠加；

	脚本处理部分:
	每次切换目标增加攻击力，处理buffId使之可叠加

	参数:
	@@buffId 增加攻击力的buff
]]
local Skill_wuyueshendao_3 = require("game.battle.skillAi.Skill_wuyueshendao_3")
local Skill_wuyueshendao_3_1 = class("Skill_wuyueshendao_3_1", Skill_wuyueshendao_3)

function Skill_wuyueshendao_3_1:ctor(skill,id, skills, buffId)
	Skill_wuyueshendao_3_1.super.ctor(self,skill,id,skills)

	self:errorLog(buffId, "buffId")

	self._buffId = buffId or 0
	self._flag = false -- 记录是否可能加攻击力
	self._buffcount = 0 -- 记录增加攻击力的buff次数，为了保证唯一buffId不互相覆盖
end

--[[
	杀人时记录将要增加攻击力，由于目前脚本不关注是否切换了目标，
	所以实现方式是，杀人后如果还将进行下一次攻击则加攻击力
]]
function Skill_wuyueshendao_3_1:onKillEnemy(attacker, defender)
	if not self:isSelfHero(attacker) then return end
	self._flag = true
end

-- 在大招攻击结束后做
function Skill_wuyueshendao_3_1:onAfterSkill(selfHero, skill)
	local result = true

	if self:chkGoOnSkill() then
		-- 会切换目标，加buff
		if self._flag then
			self._flag = false
			self._buffcount = self._buffcount + 1
			-- 作用给自己加的buff
			local tempObj = self:getBuff(self._buffId)

			tempObj.hid = string.format("%s_%s",tempObj.hid,self._buffcount)
			selfHero:checkCreateBuffByObj(tempObj, selfHero, self._skill)
			self:skillLog("巫月神刀条件满足，给自己加攻击力，buff:%s", tempObj.hid)
		end

		local isStitched = false
		if self._count > 1 then isStitched = true end

		-- 继续放下一段技能
		self:_giveSkill(self._skills[self._count], true, isStitched)
		result = false
	end

	return result
end

return Skill_wuyueshendao_3_1