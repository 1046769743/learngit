--[[
	Author:李朝野
	Date: 2017.07.24
	Modify: 2018.01.22
	Modify: 2018.03.08 废弃
]]
--[[
	彩依小技能

	技能描述：
	为同排队友增加情怜效果，持续两回合——使其攻击力提升；如果被施加的伙伴已经拥有情怜效果，则额外获得一定攻击力加成；

	脚本处理部分：
	如果被施加的伙伴已经拥有情怜效果，则额外获得一定攻击力加成；

	参数：
	@@bufftype 如果已被施加的bufftype（来自彩依）
	@@atkId 额外增加攻击力的攻击包id
	
	@@skillId 备选技能的技能Id
]]

--[[
	Modify: 加入如果选敌失败则使用一个替代技能的逻辑
]]


local Skill_caiyi_2 = class("Skill_caiyi_2", SkillAiBasic)


function Skill_caiyi_2:ctor(skill,id,bufftype,atkId,skillId)
	Skill_caiyi_2.super.ctor(self, skill, id)
	-- self._flag = false

	self:errorLog(bufftype, "bufftype")
	self:errorLog(atkId, "atkId")
	self:errorLog(skillId, "skillId")

	self._bufftype = tonumber(bufftype) or 0
	self._atkData = ObjectAttack.new(atkId)

	self._exSkillId = skillId

	-- 标志防止递归
	self._flag = false
end

--[[
	当是彩依小技能的时候检查被加buff的人身上有没有由彩依做的加攻击力的效果
]]
function Skill_caiyi_2:onOneBeUseBuff(attacker, defender, skill, buffObj)
	local selfHero = self:getSelfHero()
	-- 如果不是自己加的返回
	if not self:isSelfHero(attacker) then return end
	-- 如果不是当前自己的技能返回
	if skill ~= self._skill then return end
	-- 如果不是自己人返回
	if selfHero.camp ~= defender.camp then return end
	-- 如果已经在检查了，返回
	if self._flag then return end

	-- 检查有没有彩依的buff
	if defender.data:checkHasBuffFromOne(self._bufftype, selfHero) then
		self:skillLog("彩依小技能判定成功为阵营%s, %s号位添加额外buff", defender.camp, defender.data.posIndex)
		self._flag = true
		selfHero:sureAttackObj(defender,self._atkData,self._skill)
	end

	self._flag = false
end

function Skill_caiyi_2:onBeforeCheckSkill(selfHero, skill)
	local result = skill
	local chooseArr = AttackChooseType:getSkillCanAtkEnemy(selfHero,skill,true)

	-- 检查要不要换
	local flag = true
	for _,hero in ipairs(chooseArr) do
		-- 除了替代的人还有其他人就认为找到人了
		if not hero.randomHero then
			flag = false
		end
	end

	if flag then
		-- 新获得一个技能（伤害系数走原技能的）
		result = self:_getExSkill(self._exSkillId, false)
	end

	return result
end

return Skill_caiyi_2