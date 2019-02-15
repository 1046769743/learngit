--[[
	Author:李朝野
	Date: 2017.10.13
	Modify: 2018.03.09 不再继承大招扩充1的特性
]]

--[[
	唐雨柔大招扩充2
	
	技能描述：
	释放大招时，如果唐雨柔自身生命低于30%，此次大招消耗怒气量减少1点；

	脚本处理部分：
	释放大招时，如果唐雨柔自身生命低于x，此次大招消耗怒气量减少x点；

	参数：
	hprate 触发血限
	energy 怒气量减少值
]]
-- local Skill_tangyurou_3_1 = require("game.battle.skillAi.Skill_tangyurou_3_1")
local Skill_tangyurou_3_2 = class("Skill_tangyurou_3_2", SkillAiBasic)

function Skill_tangyurou_3_2:ctor(skill,id, hprate,energy)
	Skill_tangyurou_3_2.super.ctor(self,skill,id)

	self:errorLog(hprate, "hprate")
	self:errorLog(energy, "energy")

	self._hprate = tonumber(hprate or 0)/10000
	self._energy = tonumber(energy or 0)

	-- 标记是否已经触发
	self._flag = false
end

--[[
	注册血量的监听
]]
function Skill_tangyurou_3_2:onSetHero(selfHero)
	-- echoError("几个监听？",selfHero.camp)
	selfHero.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH, self._onHpChange, self)
end
--[[
	监听唐雨柔血量变化
]]
function Skill_tangyurou_3_2:_onHpChange(event)
	local selfHero = self:getSelfHero()
	local hprate = selfHero.data:getAttrPercent(Fight.value_health)
	-- 未触发过且血量满足
	if not self._flag and hprate < self._hprate then
		self._flag = true
		-- 不需要限制最小值
		local min = -99
		self:skillLog("唐雨柔血量:%s,大招消耗怒气将减少:%s",hprate,self._energy)
		-- 将初始怒气消耗量降低
		selfHero.data:changeValue(Fight.value_maxenergy, -self._energy, Fight.valueChangeType_num, min)
		-- 通知UI变化显示
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_COST_CHANGE,{model=selfHero})
	end

	-- 触发过且血量不满足
	if self._flag and hprate >= self._hprate then
		self._flag = false
		self:skillLog("唐雨柔血量:%s,大招消耗怒气将恢复",hprate)
		-- 将初始怒气消耗量提升
		selfHero.data:changeValue(Fight.value_maxenergy, self._energy, Fight.valueChangeType_num)
		-- 通知UI变化显示
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_COST_CHANGE,{model=selfHero})
	end	
end

return Skill_tangyurou_3_2