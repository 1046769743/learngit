--[[
	Author:李朝野
	Date: 2017.07.26
	Modify: 2018.03.19
]]

--[[
	酒剑仙被动

	技能描述：
	回合开始时，如果自身受到负面状态或者对位中排没有敌人，释放斩妖咒，增加攻击力/格挡率

	脚本处理部分：
	回合开始前如果满足条件则释放斩妖咒，脚本负责计数，同时需要联动大招

	参数：
	@@lastRound 斩妖咒持续回合数
]]
local Skill_jiujianxian_4 = class("Skill_jiujianxian_4", SkillAiBasic)

function Skill_jiujianxian_4:ctor(skill,id,lastRound)
	Skill_jiujianxian_4.super.ctor(self,skill,id)

	self:errorLog(lastRound, "lastRound")

	self._lastRound = tonumber(lastRound or 0) -- 持续回合数
	-- 标记回合数
	self._round = 0
end

--[[
	回合开始检查是否触发加攻击力的效果
]]
function Skill_jiujianxian_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end
	-- 自己无法行动
	if not selfHero.data:checkCanAttack() then return end
	
	-- 判断条件做触发
	-- 判断负面状态
	local flag = selfHero.data:checkHasOneBuffKind(Fight.buffKind_huai)
	-- 判断对方中排
	flag = flag or not selfHero.logical:findHeroModel(selfHero.toCamp, 2 * 2 + selfHero.data.gridPos.y - 2)

	if flag then
		self:skillLog("酒剑仙被动满足触发条件")
		selfHero:setRoundReady(Fight.process_myRoundStart, false)
		selfHero.currentSkill = self._skill

		self._skill:clearAtkChooseArr()

		-- 标记使用技能
		self:useExSkill()

		selfHero:onMoveAttackPos(selfHero.currentSkill, true, true)
		selfHero.isAttacking = false

		if Fight.isDummy then
			selfHero:setRoundReady(Fight.process_myRoundStart, true)
		else
			selfHero:pushOneCallFunc(selfHero.totalFrames, "setRoundReady", {Fight.process_myRoundStart, true})
		end
	end
end

-- 我方回合结束后刷新回合
function Skill_jiujianxian_4:onMyRoundEnd(selfHero)
	if not self:isSelfHero(selfHero) then return end

	if self._round > 0 then self._round = self._round - 1 end

	self:refreshAction()
end

-- 酒剑仙使用酒神咒（主要用来标记使用刷新回合数）
function Skill_jiujianxian_4:useExSkill()
	-- 刷新回合
	self._round = self._lastRound

	self:refreshAction()
end

-- 刷新动作状态
function Skill_jiujianxian_4:refreshAction()
	local selfHero = self:getSelfHero()

	if self:isSpStatus() then
		selfHero:setUseSpStand(true)
	else
		selfHero:setUseSpStand(false)
	end
end

-- 是否是酒神咒状态
function Skill_jiujianxian_4:isSpStatus()
	return self._round > 0
end

return Skill_jiujianxian_4