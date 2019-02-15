--[[
	神器实例

	继承自ModleHero主要为了避免大量重写技能相关的方法，神器本身没有显示逻辑，只负责放技能
]]
local Fight = Fight
-- local BattleControler = BattleControler

ModelArtifact = class("ModelArtifact", ModelHero)

ModelArtifact._onAttackComplete = nil -- 攻击完成后回调

ModelArtifact.isArtifact = true -- 标记model是神器
--[[
	用于存放管理可以主动释放的技能
	当前技能只由技能的生效次数决定
	（未来可能扩展成每个技能可以使用多次，但每回合使用一次可以通过在次字段加标记进行管理）
	--------
	字段为nil时在第一次做相关判断时会做初始化，
	字段为空{}时则认为已经没有可以主动释放的技能了
]]
ModelArtifact._canUseArtifact = nil 

function ModelArtifact:ctor( controler,obj )
	ModelArtifact.super.ctor(self, controler,obj, Fight.modelType_artifact)

	-- self.modelType = Fight.modelType_artifact
end

-- 需要重写一些不需要的方法规避报错或无用内容 --

function ModelArtifact:getViewData( ... )
	self.viewData = {}
end

function ModelArtifact:checkFullEnergyStyle()
	
end

function ModelArtifact:insterEffWord( ... )

end

-- 需要重写一些不需要的方法规避报错或无用内容 --

function ModelArtifact:justFrame( ... )
	-- self.totalFrames = 100
end

function ModelArtifact:getTotalFrames( label )
	-- self.totalFrames = 100
	return self.totalFrames
end

-- 重写放技能的方法主要为了处理 技能帧长度
function ModelArtifact:onMoveAttackPos( skill, isOldPlace, noComplete )
	self.totalFrames = skill:sta_artifactSkill()
	if not skill:sta_artifactSkill() then
		echoError("此神器技能没有配置帧长度",skill.hid)
		self.totalFrames = 100
	end

	echo("此技能为神器技能",skill.hid, self.totalFrames)
	ModelArtifact.super.onMoveAttackPos(self, skill, isOldPlace, noComplete)
end
-- function ModelArtifact:checkSkill()
-- 	-- body
-- end

-- 获取所有技能
function ModelArtifact:getAllSkills()
	return self.data:getAllSkills()
end

-- 获取所有神器技能
function ModelArtifact:getArtifactSkill(atSkillType)
	return self.data:getArtifactSkill(atSkillType)
end

-- 根据id获取神器技能
function ModelArtifact:getArtifactSkillById(...)
	return self.data:getArtifactSkillById(...)
end

-- 获取所有神力技能
function ModelArtifact:getAllSpiritSkill()
    return self.data:getAllSpiritSkill()
end

-- 根据id获取神力技能
function ModelArtifact:getSpiritSkillById(skillId)
	return self.data:getSpiritSkillById(skillId)
end

-- 设置攻击结束事件
function ModelArtifact:setAttackCompleteCall( call, ... )
	self._onAttackComplete = {
		call = call,
		params = {...},
	}
end

-- 攻击结束
function ModelArtifact:onAttackComplete()
	-- 每打完一个人，隐藏总伤害的显示
    local totalEff = self.controler.__totalDamageEff
    if totalEff and totalEff.setShowEnd then
    	totalEff:setShowEnd(true)
    end

	if self._onAttackComplete then
		local call = self._onAttackComplete.call
		local params = self._onAttackComplete.params
		self._onAttackComplete = nil
		return call(unpack(params))
	end
end

-- 重写下
function ModelArtifact:getHeroMass()
	return 1
end

-- 获取怒气消耗，神器技能的消耗绑定在skill上，所以需要skillId
function ModelArtifact:getEnergyCost(skillId)
	if skillId then
		return self:getArtifactSkillById(Fight.atSkill_applyType_manual, skillId):getEnergyCost()
	end

	return 0
end

-- 重写消息参数
function ModelArtifact:chooseAppointHandle(skillId)
	local operationInfo = self:getBaseOperationInfo()

	operationInfo.type = Fight.operationType_artifactSKill
	operationInfo.params = Fight.skillIndex_artifact
	operationInfo.skillId = tostring(skillId)
	--记录一个出手次数 作为唯一性校验
	operationInfo.atkTimes = self.atkTimes

	return operationInfo
end

function ModelArtifact:chooseOneAutoHandle(roundModel)
	local skills = self:getCanUseManualSkill(self.camp, true)
	-- 第一个技能即为优先级最高的
	local opInfo = self:chooseAppointHandle(skills[1].hid)

	return opInfo
end

-- 重写点击发出攻击指令的操作
function ModelArtifact:doAttackClick(skillId,isUITouch)
	isUITouch = isUITouch or false

	local opInfo = self:chooseAppointHandle(skillId)

	-- 如果是在别人普通攻击时发出的指令
	if self.logical.attackingHero and self.logical.attackingHero ~= self then
		local currentSkill = self.logical.attackingHero.currentSkill
		-- 如果是小技能会打断
		if currentSkill and currentSkill.skillIndex == Fight.skillIndex_small then
			opInfo.timely = true
		end
	end

	self.controler.server:sendOneClickHandle(opInfo)
end

function ModelArtifact:getCanUseManualSkill(camp, withenergy)
	local result = nil

	for _,skill in ipairs(self:getArtifactSkill(Fight.atSkill_applyType_manual)) do
		-- 可以使用
		if skill:artifactCanUse(Fight.atSkill_applyType_manual) then
			if not withenergy or (withenergy and self.controler.energyControler:isEnergyEnough(skill:getEnergyCost(),camp)) then
				if not result then result = {} end
				result[#result + 1] = skill
			end
		end
	end

	return result
end

-- 重写获取五灵的方法
function ModelArtifact:getHeroElement()
	return self.data:getHeroElement()
end

-- 重写放技能方法发消息
--[[
技能执行前
]]
function ModelArtifact:checkBeforeSkill(skill)
	ModelArtifact.super.checkBeforeSkill(self, skill)

	-- 给UI发一条消息
	if not Fight.isDummy then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ARTIFACT_MANUAL_SKILL)
	end
end

return ModelArtifact