--[[
	Author: lcy
	Date: 2018.05.21
]]

--[[
	魔魈王

	技能描述:
	每有一个单位死亡，增加攻击力，播放攻击力增加动作，攻击力达到指定层数后，转换为特殊待机

	脚本处理部分:
	同上

	参数:
	buffId 增加攻击力的buffId
	num 播放特殊待机需要的层数
	action 增加攻击力的指定动作
]]
local Skill_moxiaowang_4 = class("Skill_moxiaowang_4", SkillAiBasic)

function Skill_moxiaowang_4:ctor(skill,id,buffId,num,action)
	Skill_moxiaowang_4.super.ctor(self,skill,id)

	self:errorLog(buffId, "buffId")
	self:errorLog(num, "num")
	self:errorLog(action, "action")

	self._buffId = buffId or 0
	self._num = tonumber(num or 4)
	self._action = action

	self._count = 0
end

-- 有人死亡则触发
function Skill_moxiaowang_4:onOneHeroDied(attacker, defender)
	if self:isSelfHero(defender) then return end

	local selfHero = self:getSelfHero()

	self:skillLog("有人死亡魔魈王增加buff")
	selfHero:checkCreateBuff(self._buffId, selfHero, self._skill)
	-- 视图相关内容
	if not Fight.isDummy then
		self._count = self._count + 1
		-- 做死亡触发动作
		selfHero:justFrame(self._action)
		-- 满足满足条件切换动作
		if self._count >= self._num then
			selfHero:setUseSpStand(true)
		end
	end
end

return Skill_moxiaowang_4