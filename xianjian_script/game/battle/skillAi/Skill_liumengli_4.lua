--[[
	Author:李朝野
	Date: 2017.10.09
	Modify: 2018.03.14
]]

--[[
	柳梦璃被动

	技能描述：
	恢复10%柳梦璃攻击力的气血，驱散目标减益BUFF；此技能只会触发一次；

	脚本处理部分：
	某人快死时保护其不死，并且做加血等

	参数：
	@@atkId 加血等攻击包（可带表现）
	@@action 触发成功动作
]]
local Skill_liumengli_4 = class("Skill_liumengli_4", SkillAiBasic)

function Skill_liumengli_4:ctor(skill,id, atkId, action)
	Skill_liumengli_4.super.ctor(self, skill, id)
	
	self:errorLog(atkId, "atkId")
	self:errorLog(action, "action")

	self._atkData = ObjectAttack.new(atkId)
	self._action = action or "none"
	-- 记录生效次数
	self._counter = 0
end

function Skill_liumengli_4:beforeRealDied(attacker, defender)
	local selfHero = self:getSelfHero()
	-- 自己活着
	if selfHero.data:hp() <= 0 then return end
	-- 是队友
	if selfHero.camp ~= defender.camp then return end
	-- 不是自己
	if self:isSelfHero(defender) then return end
	-- 生效一次
	if self._counter >= 1 then return end

	self._counter = self._counter + 1

	local selfHero = self:getSelfHero()
	
	-- 把血量拉回来
	-- defender.data:changeValue(Fight.value_health, defender.data:getDataBeforeHited(Fight.value_health))
	-- 给一点血量
	defender.data:changeValue(Fight.value_health, 1)
	-- 后加buff
	selfHero:sureAttackObj(defender,self._atkData,self._skill)
	self:skillLog("柳梦璃被动触发将阵营:%s,%s号位血量恢复",defender.camp,defender.data.posIndex)

	if not Fight.isDummy then
		-- isDark说明本次攻击与自己无关，可以做一些表现上的事情
		if self._action ~= "none" and selfHero._isDark then
			selfHero:justFrame(self._action)

			local controler = selfHero.controler
			if controler and controler.viewPerform then
				controler.viewPerform:setHeroLightOrDark({selfHero})
			end

			-- 层级也处理一下
			selfHero:onSkillBlack()

			-- 做完这个动作恢复人物该有的状态（不做重置处理因为可能会状态混乱）
			-- local totalFrames = selfHero:getTotalFrames(self._action)

			-- selfHero:pushOneCallFunc(tonumber(totalFrames), function()
			-- 	if controler and controler.viewPerform then
			-- 		controler.viewPerform:setHeroLightOrDark(nil,{selfHero})
			-- 	end

			-- 	selfHero:resumeZorder()
			-- end, {})
		end
	end
end

return Skill_liumengli_4