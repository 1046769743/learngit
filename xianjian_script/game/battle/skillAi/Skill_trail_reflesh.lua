
-- Author:庞康宁
-- Date: 2017.07.22
-- des: 火神试炼中boss召唤小怪逻辑

--[[
	Modify: 2018.01.09

	改为给山神使用，提供一个参数标记位置，最终检查如果位置都没人则召唤

	参数:
	@pos 需要检查的位置 1_2
]]

local Skill_trail_reflesh = class("Skill_trail_reflesh", SkillAiBasic)

function Skill_trail_reflesh:ctor(skill,id, pos)
	Skill_trail_reflesh.super.ctor(self,skill,id)

	self:errorLog(pos, "pos")

	self._pos = string.split(pos, "_")
	table.map(self._pos, function( v, k )
		return tonumber(v)
	end)
end
--[[
	我方回合开始前
]]
function Skill_trail_reflesh:onMyRoundStart( selfHero )
	-- 判断是否要召唤
	local flag = true

	for _,pos in ipairs(self._pos) do
		-- 位置有人，不满足
		if selfHero.logical:findHeroModel(selfHero.camp,pos,true) then
			flag = false
			break
		end
	end

	if not flag then return end

	-- 做召唤逻辑
	selfHero:setRoundReady(Fight.process_myRoundStart, false)

	selfHero.currentSkill = self._skill
	self._skill:clearAtkChooseArr()

	selfHero:onMoveAttackPos(selfHero.currentSkill,true,true)

	--召唤完毕后判定 roundReady完毕
	if Fight.isDummy  then
		selfHero:setRoundReady(Fight.process_myRoundStart, true)
	else
		selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart, true} )
	end
end


function Skill_trail_reflesh:onDoSummon( selfHero, atkData )
	local summonInfo = atkData:sta_summon()
	-- local controller = selfHero.controler
	-- local count = #controller.campArr_2

	-- -- if selfHero.data:boss() == 1 and count == 1 then
	-- if true then
	-- 	-- echo("只有boss存活，则召唤4个小怪、并且随机一只有buff")
	-- 	local trailRandBuff = BattleRandomControl.getOneGroupIndex(#self._pos,1,nil)
	-- 	for i=1,#self._pos do
	-- 		-- 随机一只怪
	-- 		local tInfo = BattleRandomControl.randomOneGroupArr(summonInfo)
	-- 		tInfo[1].pos = self._pos[i]
	-- 		local hero = selfHero:summonOneTarget(tInfo[1])
	-- 		if not hero then return end
	-- 		if hero and atkData:sta_aniArr() then
	-- 			hero:createEffGroup(atkData:sta_aniArr(),false,nil,selfHero)
	-- 		end
	-- 		-- 如果有掉落，则显示掉落物品
	-- 		if table.keyof(trailRandBuff,i) then
	-- 			hero:loadRadomDropBuff()
	-- 		end
	-- 		-- 显示召唤的血条
	-- 		if hero.healthBar then
	-- 			hero.healthBar:showOrHideBar(true)
	-- 		end
	-- 		-- 排序
	-- 		selfHero.logical:sortCampPos(selfHero.camp)

	-- 	end
	-- end

end

return Skill_trail_reflesh