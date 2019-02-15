--[[
	Author: lcy
	Date: 2018.05.18
]]

--[[
	雾魂神力
	
	技能描述:
	拖拽两个敌方单位，使其交换位置

	脚本处理:
	嗯……就赋值个skillexpand

	参数:
	
]]

local Skill_spirit_wuhun = class("Skill_spirit_wuhun", SkillAiBasic)

function Skill_spirit_wuhun:ctor(skill,id)
	Skill_spirit_wuhun.super.ctor(self,skill,id)

	self._params = nil
end

-- 处理攻击范围
--[[
 	-- 此技能参数即为换位需要的参数
	LogicalControlerEx:exchangeHeroPos( heroRid,posIndex,camp)

	params = {
		heroRid = , -- 换的人的rid
		posIndex = , -- 换到的位置
		camp = , -- 所属阵营
	}
]]
function Skill_spirit_wuhun:getSpiritSkillArr(params)
	-- 保存技能参数

	self._params = params

	return {}
end

function Skill_spirit_wuhun:onAfterSkill(selfHero, skill)
	-- 调用controler的方法进行换位
	local logical = selfHero.logical
	-- 如果存在
	if logical and self._params then
		-- 调用交换方法
		logical:exchangeHeroPos(self._params.heroRid, self._params.posIndex, self._params.camp)
	else
		echoError("雾魂神力缺少控制器或交换参数",logical,self._params)
	end

	self._params = nil

	return true
end

return Skill_spirit_wuhun