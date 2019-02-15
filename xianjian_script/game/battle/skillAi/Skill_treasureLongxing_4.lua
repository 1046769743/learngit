--[[
	Author:庞康宁
	Date: 2017.11.19
	Detail: 被动：生命低于35%之后，提升自身攻击力，此效果不可被驱散，生命恢复后效果仍然存在；只会触发一次
	hpper:血量万分比
	atkId:攻击包
]]

local Skill_treasureLongxing_4 = class("Skill_treasureLongxing_4", SkillAiBasic)


function Skill_treasureLongxing_4:ctor(skill,id,hpper,atkId)
	Skill_treasureLongxing_4.super.ctor(self,skill,id,hpper,atkId)
	self._atkData = ObjectAttack.new(atkId)
	self._hpper = tonumber(hpper or 0)/10000
	-- 记录被动是否生效
	self._flag = false
	-- 标记在是否可以触发被动
	self._trigger = false
end
-- 监听血量变化
function Skill_treasureLongxing_4:_onHpChange(event)
	local selfHero = self:getSelfHero()
	-- 已经触发过、则不再触发
	if self._flag then return end
	local currHpPer = selfHero.data:getAttrPercent(Fight.value_health)
	-- 没触发血量够设为触发
	if not self._trigger and currHpPer < self._hpper then
		self._trigger = true
		self._flag = true
	end
end
function Skill_treasureLongxing_4:onSetHero(selfHero)
	selfHero.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH, self._onHpChange, self)
end
-- 回合开始前检测
function Skill_treasureLongxing_4:onMyRoundStart(selfHero )
	if self:isSelfHero(selfHero) then
		-- 触发一次
		if self._trigger then
			self._trigger = false
			self:skillLog("法宝龙醒被动触发")

			-- 给自己加攻击力相关的攻击包
			selfHero:sureAttackObj(selfHero, self._atkData, self._skill)
		end
	end
end
return Skill_treasureLongxing_4