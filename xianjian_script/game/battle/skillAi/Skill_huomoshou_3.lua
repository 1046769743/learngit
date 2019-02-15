
--[[
	Author:庞康宁
	Date: 2017.11.07
	Detail: 
	火魔兽特殊技能，在回合开始的时候，检测如果敌方有火种标记(buffId)，则触发释放火种攻击能
	并对被标记的角色后方位置做等量伤害攻击
]]
local Skill_huomoshou_3 = class("Skill_huomoshou_3", SkillAiBasic)

-- 添加对应的攻击包
function Skill_huomoshou_3:ctor(skill,id)
	Skill_huomoshou_3.super.ctor(self, skill,id)

	self._beforeSkill = skillId
	self._buffType = Fight.buffType_sign

	self._isPlay = false
end

-- 回合开始前判定
function Skill_huomoshou_3:onMyRoundStart( selfHero )
	if self:isSelfHero(selfHero) then
		for i,v in ipairs(selfHero.toArr) do
			if v.data:checkHasOneBuffType(self._buffType) then
				self._isPlay = true
			end
		end
		-- for _,buffType in ipairs(self._buffs) do
		-- 		local buffs = selfHero.data:getBuffsByType(buffType)
		-- 		if buffs then
		-- 			self._flag = true
		-- 			selfHero.data:clearBuffByType(buffType)
		-- 		end
		-- 	end
			
		if self._isPlay then
			selfHero:setRoundReady(Fight.process_myRoundStart, false)
			selfHero.currentSkill = self._skill
			-- 清一次选怪逻辑
			selfHero.currentSkill:clearAtkChooseArr()
			selfHero:onMoveAttackPos(selfHero.currentSkill,true,true)

			if Fight.isDummy then
				selfHero:setRoundReady(Fight.process_myRoundStart, true)
			else
				selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart,true})
			end
		end
	end
end
-- 对技能伤害的后方位置做等量伤害攻击
function Skill_huomoshou_3:onHitHero(attacker,defender,skill,atkData,atkResult,dmg)
 	if skill == attacker.currentSkill then
		local tPos = defender.data.posIndex
		local posHero = attacker.logical:findHeroModel(1,tPos + 2,false)
		if posHero then
			-- 对身后做伤害、这里应该做移除buff标记
			-- echoError("角色身后收到等量伤害",posHero.data.hid,posHero.data.posIndex,dmg)
			AttackUseType:damageHit(atkResult,dmg,attacker,posHero, atkData,skill,true)
			if posHero.data:hp() <= 0 then
				posHero:doHeroDie()
			end
		end
		-- 清掉角色身上的标记buff
		defender.data:clearBuffByType(self._buffType)
	end
end

return Skill_huomoshou_3


