--[[
	Author:李朝野
	Date: 2017.7.18
	Modify: 2018.03.12
]]

--[[
	王小虎被动

	技能描述：
	

	脚本处理部分：
	目前用于辅助大招扩充1实现部分功能
]]
local Skill_wangxiaohu_4 = class("Skill_wangxiaohu_4", SkillAiBasic)

function Skill_wangxiaohu_4:ctor(...)
	Skill_wangxiaohu_4.super.ctor(self, ...)

	---------配合大招的方法---------
	self._rate = nil -- 取自大招的降低伤害比例
	self._round = 0 -- 剩余回合数
end

----------------------------------配合大招的方法----------------------------------
--我方回合开始前
function Skill_wangxiaohu_4:onMyRoundStart(selfHero )
	if self._round > 0 then self._round = self._round - 1 end
	-- 处理动作
	if self._round == 0 then
		selfHero:setUseSpStand(false)
	end
end

function Skill_wangxiaohu_4:setExtraParams(rate, round)
	self._rate = rate
	self._round = round
	-- 处理动作
	if self._round > 0 then
		local selfHero = self:getSelfHero()
		selfHero:setUseSpStand(true)
	end
end

function Skill_wangxiaohu_4:onCheckBeAttack(attacker, defender, skill, atkData, dmg)
	-- 如果对方有虎魂标记，则做相关内容
	if self._round > 0 and attacker.data:checkHasOneBuffType(Fight.buffType_huhun) then
		self:skillLog("王小虎虎魂生效降低伤害比例",self._rate)
		dmg = math.round(dmg - dmg * self._rate / 10000)
		-- 保留一点伤害
		if dmg < 1 then dmg = 1 end
	end

	return dmg
end
----------------------------------配合大招的方法----------------------------------

return Skill_wangxiaohu_4