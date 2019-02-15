--[[
	Author:李朝野
	Date: 2017.01.15
]]
--[[
	李忆如奇葩被动

	技能描述:
	开局时，召唤火猴，火猴会从忆如身边跑到敌方阵容随机一个目标身后，丢下爆竹怪，然后跑回忆如身边。
	当该目标承受X点伤害或被击倒后，触发爆竹效果，对周围距离为1的人造成Y点伤害；
	对方身上只会存在一个炸弹

	脚本处理部分:
	每回合开始检查对方身上是否有炸弹，如果没有则放一个技能;
	炸弹逻辑走buff

	参数:
]]
local Skill_xinliyiru_4 = class("Skill_xinliyiru_4", SkillAiBasic)

function Skill_xinliyiru_4:ctor(skill,id)
	Skill_xinliyiru_4.super.ctor(self, skill, id)
end

function Skill_xinliyiru_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end
	-- 不能攻击什么都不做
	if not selfHero.data:checkCanAttack() then return end

	local flag = true

	for _,hero in ipairs(selfHero.toArr) do
		-- 如果有炸弹
		if hero.data:checkHasOneBuffType(Fight.buffType_bomb) then
			flag = false
			break
		end
	end

	if flag then
		self:_giveSkill()
	end
end

-- 放技能
function Skill_xinliyiru_4:_giveSkill()
	local selfHero = self:getSelfHero()

	selfHero:setRoundReady(Fight.process_myRoundStart, false)
	-- selfHero:giveOutOneSkill(selfHero.data:getSkillByIndex(Fight.skillIndex_small),Fight.skillIndex_small)
	selfHero.currentSkill = self._skill
	-- selfHero.data:getSkillByIndex(Fight.skillIndex_small)
	-- 清理一下选敌
	self._skill:clearAtkChooseArr()

	selfHero:onMoveAttackPos(selfHero.currentSkill, nil, true)

	if Fight.isDummy then
		selfHero:setRoundReady(Fight.process_myRoundStart, true)
	else
		selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart, true})
	end
end

return Skill_xinliyiru_4