--
-- Author: xd
-- Date: 2017-03-16 11:48:17
--当我方单位进行行动后，有一定概率为其恢复一定的生命
--配置 Skill_lankui_4;atkId(恢复一定的生命攻击包);概率(万分数);

--[[
	modify lichaoye 2017.7.20
	action 行动成功做的动作
	atkId 加血的攻击包
	ratio 加血的概率
]]
local Skill_lankui_4 = class("Skill_lankui_4", SkillAiBasic)


function Skill_lankui_4:ctor(skill,id,action,atkId,ratio  )
	Skill_lankui_4.super.ctor(self, skill, id)

	self:errorLog(action, "action")
	self:errorLog(atkId, "atkId")
	self:errorLog(ratio, "ratio")

	self.atkData = ObjectAttack.new(atkId)
	self._ratio = tonumber(ratio) or 5000
	self._action = action
end

--当有人行动的时候 targetHero 是行动的英雄
function Skill_lankui_4:onHeroStartAttck(selfHero, targetHero )
	if selfHero == targetHero then
		return
	end
	--必须是我方阵营
	if selfHero.camp ~= targetHero.camp then
		return
	end
	--必须是自己能行动
	if not selfHero.data:checkCanAttack() then
		return
	end
	-- 必须不是神器
	if targetHero.isArtifact then
		return 
	end

	local random = BattleRandomControl.getOneRandom()
	if random *10000 < self._ratio  then
		--那么做攻击包
		selfHero:sureAttackObj(targetHero,self.atkData,self._skill)
		if not Fight.isDummy then
			--当我方有人行动时 我做施法动作（施法成功时）
			-- 不在原位不播动作 
			if selfHero:isAtInitPos() then
				selfHero:justFrame(self._action)
			end
			
			-- 如果此时自己是暗状态处理下显示
			if selfHero._isDark then
				local controler = selfHero.controler
				if controler and controler.viewPerform then
					controler.viewPerform:setHeroLightOrDark({selfHero})
				end
				-- 层级也处理一下
				selfHero:onSkillBlack()

				-- 做完这个动作恢复人物该有的状态
				local totalFrames = selfHero:getTotalFrames(self._action)

				selfHero:pushOneCallFunc(tonumber(totalFrames), function()
					if controler and controler.viewPerform then
						controler.viewPerform:setHeroLightOrDark(nil,{selfHero})
					end

					selfHero:resumeZorder()
				end, {})
			end
		end

		self:skillLog("___蓝葵为其恢复生命---")
	end
end

return Skill_lankui_4