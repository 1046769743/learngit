
-- Author:庞康宁
-- Date: 2018.01.04
-- des: 传送门召唤怪、需要走相关的技能配置
-- level表中leveltype必须为2，并且需要填写refresh（会覆盖attack攻击包中的summon字段）

local Skill_gate_3 = class("Skill_gate_3", SkillAiBasic)

function Skill_gate_3:ctor(...)
	Skill_gate_3.super.ctor(self,...)
end
--[[
	我方回合开始前
]]
function Skill_gate_3:onMyRoundStart( selfHero )
	-- 做召唤逻辑
	selfHero:setRoundReady(Fight.process_myRoundStart, false)

	selfHero.currentSkill = self._skill

	selfHero:onMoveAttackPos(selfHero.currentSkill,true,true)

	--召唤完毕后判定 roundReady完毕
	if Fight.isDummy  then
		selfHero:setRoundReady(Fight.process_myRoundStart, true)
	else
		selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart, true} )
	end
end


function Skill_gate_3:onDoSummon( selfHero, atkData )
	local controler = selfHero.controler
	local lvType = controler.levelInfo:getLevelType()
	if lvType and lvType == Fight.levelType_gate then
		local refreshArr = controler.reFreshControler:getRefreshArr()
	    if not refreshArr then
	    	echoError ("找策划，level 表中refresh 字段没有填相关的刷怪逻辑")
	    	return
	    end
	    controler.logical:refreshMonster(Fight.camp_2,Fight.enterType_gate)
		-- self.controler.reFreshControler:getRefreshCount()
		-- 传送门没法攻击
		selfHero.hasAutoMove = true
		selfHero.hasOperate = true
	else
		echoError ("传送门玩法level表中levelType没有配置为2")
	end
end

return Skill_gate_3