--[[
	Author:李朝野
	Date: 2017.12.26
]]

--[[
	须臾仙境水魔兽

	技能描述：
	当对方的NPC怪死亡后，释放秒杀;只考虑对方有且只有一个NPC的情况

	脚本处理部分：
	每回合开始前检查NPC是否低于额定血量，若低于则直接放技能（被动技能）

	参数:
	hpPer 血量（万分）
]]
local Skill_xvyu_shuimoshou_4 = class("Skill_xvyu_shuimoshou_4", SkillAiBasic)

function Skill_xvyu_shuimoshou_4:ctor(skill,id, hpPer)
	Skill_xvyu_shuimoshou_4.super.ctor(self, skill, id)

	self:errorLog(hpPer, "hpPer")

	self._hpPer = tonumber(hpPer or 0) / 10000
end

function Skill_xvyu_shuimoshou_4:onMyRoundStart(selfHero)
	if self:isSelfHero(selfHero) then
		-- 查找是否符合放技能的条件
		local flag = true
		local toArr = selfHero.toArr
		for _,hero in ipairs(toArr) do
			-- 是npc
			if hero.data:isRobootNPC() then
				-- 是活人并且不小于规定血量
				if SkillBaseFunc:isLiveHero(hero) 
					and hero.data:getAttrPercent(Fight.value_health) >= self._hpPer
				then
					flag = false
				end
			end
		end

		if flag then
			self:skillLog("对方已无NPC须臾仙境水魔兽释放秒杀技能,skillId:%s",self._skill.hid)

			-- 放技能，直接放被动上挂的技能
			selfHero:setRoundReady(Fight.process_myRoundStart, false)
			selfHero.currentSkill = self._skill

			-- 清理一下选敌
			self._skill:clearAtkChooseArr()
			
			selfHero:onMoveAttackPos(selfHero.currentSkill,true,true)

			if Fight.isDummy then
				selfHero:setRoundReady(Fight.process_myRoundStart, true)
			else
				selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart, true})
			end
		end
	end
end

return Skill_xvyu_shuimoshou_4