--[[
	Author:李朝野
	Date: 2017.09.26
]]

--[[
	火神大招

	技能描述：
	用于火神切换场景使用，特殊性比较强，相关逻辑直接写死了
]]
local Skill_trail_huoshen_changjing = class("Skill_trail_huoshen_changjing", SkillAiBasic)

function Skill_trail_huoshen_changjing:ctor( ... )
	Skill_trail_huoshen_changjing.super.ctor(self, ...)
end

--[[
	放技能的时候检查播哪个动画
]]
function Skill_trail_huoshen_changjing:onHeroStartAttck(selfHero, targetHero, skill)
	if Fight.isDummy then return end

	if self:isSelfHero(targetHero) and self._skill == skill then
		local ani = self:_getAni()
		if not ani then return end
		-- 回合
		local round = math.ceil(selfHero.logical.roundCount/2)
		if round <= 3 then
			ani:playWithIndex(1)
		elseif round == 4 then
			-- 第四回合大招变蓝
			ani:playWithIndex(2)
			self:_changeColor(ani, 1)
		elseif round == 5 then
			-- 第五回合变回红色
			ani:playWithIndex(5)
			self:_changeColor(ani, 0)
		end
	end
end
--[[
	辅助函数
	color 1 蓝 0 原色
]]
function Skill_trail_huoshen_changjing:_changeColor(ani, color)
	if color == 1 then
		FilterTools.setViewFilter(ani:getBoneDisplay("beijing"),FilterTools.colorMatrix_huoshen_changjing_blue,10)
		FilterTools.setViewFilter(ani:getBoneDisplay("qianceng"),FilterTools.colorMatrix_huoshen_changjing_blue,10)
		FilterTools.setViewFilter(ani:getBoneDisplay("dilie"),FilterTools.colorMatrix_huoshen_dilie_blue,10)
	else
		FilterTools.clearFilter(ani:getBoneDisplay("beijing") ,10 )
		FilterTools.clearFilter(ani:getBoneDisplay("qianceng") ,10 )
		FilterTools.clearFilter(ani:getBoneDisplay("dilie") ,10 )
	end
end
--[[
	辅助函数
	获取需要控制的动画
]]
function Skill_trail_huoshen_changjing:_getAni()
	local selfHero = self:getSelfHero()
	local mapControler = selfHero.controler.map

	if not mapControler then
		return nil
	end

	if not mapControler.map then
		return nil
	end

	if not mapControler.map.panel_land_1_100 then
		return nil
	end

	local ani = mapControler.map.panel_land_1_100.ani_c_0_0

	return ani
end

return Skill_trail_huoshen_changjing