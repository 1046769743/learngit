--[[
	Author:李朝野
	Date: 2017.12.22
]]

--[[
	沼泽怪被动
	
	脚本处理部分：
	每回合给自己加buff 同时 Buff叠加

	参数：
	buffId 增加攻击力的buffId
	times 生效次数
]]
local Skill_zhaozeguai_4 = class("Skill_zhaozeguai_4", SkillAiBasic)

function Skill_zhaozeguai_4:ctor(skill,id, buffId, times)
	Skill_zhaozeguai_4.super.ctor(self, skill, id)

	self:errorLog(buffId, "buffId")
	self:errorLog(times, "times")

	self._buffId = buffId or 0
	self._times = tonumber(times or 0)

	-- 记录施加buff次数，为了保证唯一buffId不互相覆盖
	self._counter = 0
end

-- 回合开始前
function Skill_zhaozeguai_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end
	if self._times <= 0 then return end

	self._counter = self._counter + 1
	-- 作用给自己加的buff
	local tempObj = self:getBuff(self._buffId)
	-- table.copy(self._buffObj)
	tempObj.hid = string.format("%s_%s",tempObj.hid,self._counter)
	selfHero:checkCreateBuffByObj(tempObj, selfHero, self._skill)

	self:skillLog("阵营:%s,%s号位,回合前给自己加buff,buff:%s", selfHero.camp, selfHero.data.posIndex, tempObj.hid)

	self._times = self._times - 1
end

return Skill_zhaozeguai_4