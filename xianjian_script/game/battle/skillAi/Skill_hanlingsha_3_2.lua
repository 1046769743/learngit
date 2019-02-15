--[[
	Author:李朝野
	Date: 2017.09.14
	Modify: 2018.01.06
	Modify: 2018.03.03 修改为触发后释放
]]

--[[
	韩菱纱大招扩充2

	技能描述：
	获得额外暴击率，击杀目标后，追击一次相同攻击

	脚本处理部分：
	击杀后再次攻击

	参数：
	buffId1 提升暴击率的buff
	buffId2 提升破挡率的buff
]]
local Skill_hanlingsha_3_1 = require("game.battle.skillAi.Skill_hanlingsha_3_1")
local Skill_hanlingsha_3_2 = class("Skill_hanlingsha_3_2", Skill_hanlingsha_3_1)


function Skill_hanlingsha_3_2:ctor(...)
	Skill_hanlingsha_3_2.super.ctor(self, ...)

	-- 记录是否触发
	self._flag = false
end

--[[
	杀敌检测
]]
function Skill_hanlingsha_3_2:onKillEnemy( attacker,defender )
	if not self:isSelfHero(attacker) then return end
	self._flag = true
end

--[[
	技能结束之后
]]
function Skill_hanlingsha_3_2:onAfterSkill(selfHero,skill)
	local flag = self._flag
	-- 先将标记重置回
	self._flag = false
	-- 造成击杀进行追击
	if flag and SkillBaseFunc:isLiveHero(selfHero) and SkillBaseFunc:chkLiveHero( selfHero.toArr ) then
		
		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			--- 放技能
			selfHero:checkSkill(skill, false, skill.skillIndex)
		end)
	end

	return true
end

return Skill_hanlingsha_3_2