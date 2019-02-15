--[[
	Author: lcy
	Date: 2018.05.28
	继承skill，处理一些只有神器/神力有的逻辑
]]

ObjectArtifactSkill = class("ObjectArtifactSkill", ObjectSkill)

ObjectArtifactSkill.isArtifactSkill = false -- 标记神器技能
ObjectArtifactSkill.isSpiritSkill = false -- 标记神力技能

function ObjectArtifactSkill:ctor(hid,origin, charIdx,skillParams)
	ObjectArtifactSkill.super.ctor(self, hid,origin, charIdx,skillParams)

	self.isArtifactSkill = origin.isArtifactSkill
	self.priority = origin.priority or 99

	self.isSpiritSkill = origin.isSpiritSkill

	self.energyCost = origin.energyCost
	self.applyType = origin.applyType
	self.combineId = origin.combineId -- 神器组合id
end

-- 获取组合id
function ObjectArtifactSkill:getCombineId()
	return self.combineId
end

-- 获取怒气消耗
function ObjectArtifactSkill:getEnergyCost()
	return self.energyCost
end

-- 获取作用类型
function ObjectArtifactSkill:getApplyType()
	return self.applyType
end

-- 设置法宝
function ObjectArtifactSkill:setTreasure(treasure)
	local skillIndex = self.isSpiritSkill and Fight.skillIndex_spirit or Fight.skillIndex_artifact
	ObjectArtifactSkill.super.setTreasure(self, treasure, skillIndex)
end

-- 返回技能是否能使用
function ObjectArtifactSkill:artifactCanUse(applyType, currentCamp, chance)
	return (self.skillExpand and self.skillExpand:artifactCanUse(applyType, currentCamp, chance))
end

return ObjectArtifactSkill