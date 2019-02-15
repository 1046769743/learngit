--[[
	Author:李朝野
	Date: 2017.08.04
]]
--[[
	景天被动

	技能描述：
	每成功完成一次攻击后（一次大招连击也计数1次），提升自身攻击力，持续两回合；

	脚本处理部分：
	每成功完成一次攻击后（一次大招连击也计数1次），提升自身攻击力，持续两回合；

	参数：
	buffId 增加攻击力的buffId
]]
local Skill_jingtian_4 = class("Skill_jingtian_4", SkillAiBasic)

function Skill_jingtian_4:ctor(skill,id,buffId)
	Skill_jingtian_4.super.ctor(self, skill, id)

	self:errorLog(buffId, "buffId")

	-- self._buffObj = ObjectBuff.new(buffId, self._skill)
	self._buffId = buffId or 0

	-- 记录增加攻击力次数，为了保证唯一buffId不互相覆盖
	self._counter = 0
end
--[[
	大招结束之后给自己增加攻击力
]]
function Skill_jingtian_4:onAfterSkill( selfHero,skill )
	-- 不是景天失败攻击才加
	if not skill.__jtFail then
		self._counter = self._counter + 1
		-- 作用给自己加的buff
		local tempObj = self:getBuff(self._buffId)
		-- table.copy(self._buffObj)
		tempObj.hid = string.format("%s_%s",tempObj.hid,self._counter)
		selfHero:checkCreateBuffByObj(tempObj, selfHero, self._skill)
		self:skillLog("景天被动触发，给自己加攻击力，buff:%s", tempObj.hid)
	end

	return true
end

return Skill_jingtian_4