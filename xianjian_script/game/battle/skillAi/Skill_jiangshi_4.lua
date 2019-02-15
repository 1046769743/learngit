--[[
	Author: lcy
	Date: 2018.05.09
]]

--[[
	僵尸怪被动

	技能描述:
	当被击杀的时候，变为不可选中不可攻击的状态（类似中立+傀儡），若干回合后恢复

	脚本处理部分:
	同上

	参数:
	buffs 每回合用于做表现的buff a_b_c
	actiondie 由人变为墓碑的动作
	actionlive 由墓碑变成人的动作
]]

local Skill_jiangshi_4 = class("Skill_jiangshi_4", SkillAiBasic)

function Skill_jiangshi_4:ctor(skill,id, buffs, actiondie, actionlive)
	Skill_jiangshi_4.super.ctor(self, skill, id)

	self:errorLog(buffs, "buffs")
	self:errorLog(actiondie, "actiondie")
	self:errorLog(actionlive, "actionlive")

	self._buffs = string.split(buffs, "_")
	table.map(self._buffs, function(v, k)
		return tonumber(v)
	end)

	self._actiondie = actiondie or ""
	self._actionlive = actionlive or ""

	self._num = #self._buffs -- 回到战场的回合数

	self._count = 0 -- 死后回合计数
	self._flag = false -- 标记墓碑状态
end

-- 真正死亡之前
function Skill_jiangshi_4:beforeRealDied(attacker, defender)
	-- 不是自己
	if not self:isSelfHero(defender) then return end
	-- 墓碑状态不再处理
	if self._flag then return end

	self._flag = true

	local selfHero = self:getSelfHero()

	self:skillLog("小怪墓碑变起来")

	-- 把血量拉回来
	selfHero.data:changeValue(Fight.value_health, 1)
	-- 清掉其他buff
	selfHero.data:clearAllBuff()
	-- 加标记的buff
	selfHero:checkCreateBuff(self._buffs[self._count+1], selfHero, self._skill)
	-- 做个动作
	if not Fight.isDummy then
		-- 做个动作
		selfHero:justFrame(self._actiondie)
		-- 转为特殊待机状态
		selfHero:setUseSpStand(true)
	end
end

-- 回合开始前
function Skill_jiangshi_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end
	-- 如果是墓碑状态
	if self._flag then
		self._count = self._count + 1
		-- 满足复活回合数
		if self._count == self._num then
			self._flag = false
			self._count = 0
			self:skillLog("回合满足墓碑变回来")
			-- 清除标记buff
			selfHero.data:clearBuffByType(Fight.buffType_tag_mubei, true)
			-- 血量拉满
			selfHero.data:changeValue(Fight.value_health, selfHero.data:getAttrByKey(Fight.value_maxhp))
			-- 做动作
			if not Fight.isDummy then
				selfHero:setRoundReady(Fight.process_myRoundStart, false)
				
				selfHero:justFrame(self._actionlive)

				selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart, true})
				-- 取消特殊待机
				selfHero:setUseSpStand(false)
			end
		else -- 不满足
			-- 加新buff
			selfHero:checkCreateBuff(self._buffs[self._count+1], selfHero, self._skill)
		end
	end
end

return Skill_jiangshi_4