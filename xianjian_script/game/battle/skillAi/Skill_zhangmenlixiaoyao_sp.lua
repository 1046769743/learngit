--[[
	Author:李朝野
	Date: 2017.10.23
]]


--[[
	掌门李逍遥协助攻击的脚本

	技能描述：
	

	脚本处理部分：
	掌门李逍遥在天罡剑阵状态下会进行协助攻击（谁挨打了，李逍遥也跟着打一次），
	此脚本在技能逻辑执行之前，将技能攻击包选敌都替换为记录的人

	参数：

]]

local Skill_zhangmenlixiaoyao_sp = class("Skill_zhangmenlixiaoyao_sp", SkillAiBasic)

function Skill_zhangmenlixiaoyao_sp:ctor(skill,id)
	Skill_zhangmenlixiaoyao_sp.super.ctor(self, skill, id)


end
--[[
	技能之前替换选敌
]]
function Skill_zhangmenlixiaoyao_sp:onBeforeSkill(selfHero, skill)
	-- 获取要打的人
	local maxSkill = selfHero.data:getSkillByIndex(Fight.skillIndex_max)
	local maxSkillExpand = maxSkill and maxSkill.skillExpand or nil

	-- 替换攻击包内的人
	local atkArr = maxSkillExpand:getEnemyArr()
	local attackInfos = skill.attackInfos
	for _,info in ipairs(attackInfos) do
		local atkData = info[3]
		atkData.hasChooseArr = atkArr
	end
end

return Skill_zhangmenlixiaoyao_sp