--[[
	Author:李朝野
	Date: 2018.01.09
]]

--[[
	夏侯瑾轩被动

	技能描述:
	碧波挽月，在夏侯瑾轩释放任意仙术之后，使下一个攻击的队友在造成伤害后，额外附加一个atk——额外伤害，取值自身攻击力一定比例系数；

	脚本处理部分:
	在自己释放指定仙术后，对下一个攻击的人施加携带攻击包的buff

	参数:
	@@skillIdxs 支持激活的仙术类型 2_3(小技能、大招)
	@@atkId 做buff的攻击包
	@@action 给别人加的时候的动作
]]
local Skill_xiahoujinxuan_4 = class("Skill_xiahoujinxuan_4", SkillAiBasic)

function Skill_xiahoujinxuan_4:ctor(skill,id, skillIdxs, atkId, action)
	Skill_xiahoujinxuan_4.super.ctor(self, skill, id)

	self:errorLog(skillIdxs, "skillIdxs")
	self:errorLog(atkId, "atkId")
	self:errorLog(action, "action")

	self._skillIdxs = string.split(skillIdxs, "_")
	table.map(self._skillIdxs, function(v, k)
		return tonumber(v)
	end)

	self._atkData = ObjectAttack.new(atkId)
	self._action = action

	self._isActive = false -- 标记激活状态
end

-- 当有人行动的时候
function Skill_xiahoujinxuan_4:onHeroStartAttck(selfHero, targetHero)
	-- 必须是我方阵营
	if selfHero.camp ~= targetHero.camp then return end
	-- 必须是自己能行动
	if not selfHero.data:checkCanAttack() then return end
	-- 如果没激活不执行
	if not self._isActive then return end
	
	self._isActive = false

	self:skillLog("阵营:%s,%s号位行动，夏侯瑾轩对其施加攻击包",targetHero.camp,targetHero.data.posIndex)

	--那么做攻击包
	selfHero:sureAttackObj(targetHero,self._atkData,self._skill)

	if not Fight.isDummy 
		and selfHero ~= targetHero -- 目标人物不是自己才做动作，不然可能打断自己的动作
		and self._action 
		and self._action ~= "none" 
	then
		-- 做施法动作
		selfHero:justFrame(self._action)
		-- 做完这个动作恢复人物该有的状态
		local totalFrames = selfHero:getTotalFrames(self._action)
		selfHero:pushOneCallFunc(tonumber(totalFrames), "checkFullEnergyStyle",{})
	end
end

-- 放技能检查是否激活
function Skill_xiahoujinxuan_4:onAfterSkill(selfHero,skill)
	-- 生效的类型
	if array.isExistInArray(self._skillIdxs, skill.skillIndex) then
		self:skillLog("夏侯瑾轩被动激活")
		self._isActive = true
	end

	return true
end

-- 回合结束后取消激活状态
function Skill_xiahoujinxuan_4:onMyRoundEnd(selfHero)
	if not self:isSelfHero(selfHero) then return end

	self._isActive = false
end

return Skill_xiahoujinxuan_4