--[[
	Author:李朝野
	Date: 2017.10.23
]]


--[[
	掌门李逍遥被动

	技能描述：
	回合开始前，若敌方任意成员处于增益状态时，则蜀山掌门李逍遥攻击力提升并且持续本回合；

	脚本处理部分：
	回合开始前检查敌方成员状态，有增益状态则为李逍遥施加攻击包

	参数：
	atkId 带有增加攻击力buff的攻击包
]]
local Skill_zhangmenlixiaoyao_4 = class("Skill_zhangmenlixiaoyao_4", SkillAiBasic)

function Skill_zhangmenlixiaoyao_4:ctor(skill,id, atkId)
	Skill_zhangmenlixiaoyao_4.super.ctor(self, skill, id)
	
	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

function Skill_zhangmenlixiaoyao_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end

	local toCampArr = selfHero.toArr

	local flag = false
	for _,hero in ipairs(toCampArr) do
		if SkillBaseFunc:isLiveHero(hero) and hero.data:checkHasKindBuff(Fight.buffKind_hao) then
			flag = true
			break
		end
	end
	if flag then
		self:skillLog("掌门李逍遥被动生效")
		selfHero:sureAttackObj(selfHero,self._atkData,self._skill)
	end
end

return Skill_zhangmenlixiaoyao_4