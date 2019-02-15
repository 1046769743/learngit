--[[
	Author: lcy
	Date: 2018.06.08
]]

--[[
	玄霄·冰 小技能

	技能描述:

	脚本处理部分:
	用来传递对应火技能的id

	参数:
	@@fireId 对应等级的火技能id
]]

local Skill_xuanxiao_ice_2 = class("Skill_xuanxiao_ice_2", SkillAiBasic)

function Skill_xuanxiao_ice_2:ctor(skill,id, fireId)
	Skill_xuanxiao_ice_2.super.ctor(self,skill,id)

	self:errorLog(fireId, "fireId")

	self._fireId = fireId or 0
end

function Skill_xuanxiao_ice_2:getFireId()
	return self._fireId
end

return Skill_xuanxiao_ice_2