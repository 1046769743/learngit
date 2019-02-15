--[[
	Author: lcy
	Date: 2017.08.04
]]
--[[
	苏媚被动

	技能描述：
	忘魂，攻击苏媚的人在攻击结束后获得忘魂效果（最后一击打死，则无此效果）；
	己方回合开始前，若敌方带有忘魂数量大于3人时，苏媚为己方全体增加攻击力

	参数：
	被动技能本身是给所有人加攻击力，触发时释放
	
	buffId 忘魂buffId
	num 触发忘魂的人数
]]
local Skill_sumei_4 = class("Skill_sumei_4", SkillAiBasic)

function Skill_sumei_4:ctor(skill,id, buffId, num)
	Skill_sumei_4.super.ctor(self, skill, id)

	self:errorLog(buffId, "buffId")
	self:errorLog(num, "num")

	self._buffId = buffId or 0
	self._num = tonumber(num or 3)
end

--[[
	挨打后给对方加buff
]]
function Skill_sumei_4:onAfterHited(selfHero, attacker, skill, atkData)
	-- 自己活着才生效
	if not SkillBaseFunc:isLiveHero(selfHero) then return end 

	self:skillLog("苏媚被打为阵营%s %s号位加忘魂",attacker.camp, attacker.data.posIndex)
	-- 给敌方加忘魂
	attacker:checkCreateBuffByObj(self:getBuff(self._buffId), selfHero, self._skill)
end

--[[
	回合开始前判定
]]
function Skill_sumei_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end

	-- 判断敌方带有忘魂的人的数量
	local count = 0
	for _,hero in ipairs(selfHero.toArr) do
		if hero.data:checkHasOneBuffType(Fight.buffType_wanghun) then
			count = count + 1
		end
	end

	-- 数量不满足条件
	if count < self._num then return end

	selfHero:setRoundReady(Fight.process_myRoundStart, false)
	selfHero.currentSkill = self._skill

	selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
		-- 重置敌人身上关于我本回合的伤害信息
		selfHero:resetCurEnemyDmgInfo()

		selfHero:checkSkill(self._skill, false, self._skill.skillIndex)
	end)
	-- 触发技能
	selfHero.triggerSkillControler:excuteTriggerSkill(function()
		selfHero:movetoInitPos(2)
		selfHero:setRoundReady(Fight.process_myRoundStart, true)
	end)
end

return Skill_sumei_4