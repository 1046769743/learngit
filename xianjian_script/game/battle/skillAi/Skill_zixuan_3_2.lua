--[[
	Author:李朝野
	Date: 2018.03.13
]]

--[[
	紫萱大招扩充2

	技能描述：
	释放怒气仙术时，每有一个傀儡增加X点攻击力
	
	脚本处理部分：
	释放大招之前，根据傀儡数量增加攻击力

	参数：
	@@buffId 加攻buffId
	@@frame 执行加攻的帧数，需要在第一个攻击包之前才能生效
	@@atkId 给傀儡加攻的攻击包
]]
local Skill_zixuan_3_1 = require("game.battle.skillAi.Skill_zixuan_3_1")

local Skill_zixuan_3_2 = class("Skill_zixuan_3_2", Skill_zixuan_3_1)

function Skill_zixuan_3_2:ctor(skill,id, buffId, frame, atkId)
	Skill_zixuan_3_2.super.ctor(self,skill,id, buffId, frame)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

-- 技能结束后给所有傀儡加攻击力
function Skill_zixuan_3_2:onAfterSkill(selfHero, skill)
	-- 寻找敌我双方的傀儡加攻击力
	local function enhanceKuiLei(arr)
		for _,hero in ipairs(arr) do
			if hero.data:checkHasOneBuffType(Fight.buffType_kuilei) 
				and hero.puppeteer == selfHero.camp 
			then
				selfHero:sureAttackObj(hero, self._atkData, skill)
			end
		end
	end

	self:skillLog("紫萱大招扩充2结束给所有傀儡加攻击力")

	enhanceKuiLei(selfHero.campArr)
	enhanceKuiLei(selfHero.toArr)

	return true
end

return Skill_zixuan_3_2