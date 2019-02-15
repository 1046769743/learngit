
-- Author:庞康宁
-- Date: 2017.09.13
-- des: 盗宝者 替换刷怪逻辑

local Skill_trial_daobaozhe_3 = class("Skill_trial_daobaozhe_3", SkillAiBasic)

function Skill_trial_daobaozhe_3:ctor(skill,id)
	Skill_trial_daobaozhe_3.super.ctor(self,skill,id)
end
function Skill_trial_daobaozhe_3:ctor(skill,id,hp,...)
	Skill_trial_daobaozhe_3.super.ctor(self,skill,id,...)
	self.weight = {} --掉落权重
	self.buffId = {} --buffid
	self.hpPercent = tonumber(hp) --掉血比例
	local tbl = {...}
	for k,v in pairs(tbl) do
		local ids = string.split(v,"_")
		if #ids == 2 then
			table.insert(self.buffId,ids[1])
			table.insert(self.weight,tonumber(ids[2]))
		else
			echoError("找策划，配置的盗宝者特殊技能后面跟随的buff格式不对，buffId,weight;")
		end
	end
	if #self.buffId < 2 then
		echoError("找策划，配置的盗宝者随机掉落buff少于2")
	end
end
--[[
	我方回合开始前
]]
function Skill_trial_daobaozhe_3:onMyRoundStart( selfHero )
	selfHero:setRoundReady(Fight.process_myRoundStart, false)

	selfHero.currentSkill = self._skill

	selfHero:onMoveAttackPos(selfHero.currentSkill,true,true)

	--召唤完毕后判定 roundReady完毕
	if Fight.isDummy  then
		selfHero:setRoundReady(Fight.process_myRoundStart, true)
	else
		selfHero:pushOneCallFunc(selfHero.totalFrames,"setRoundReady",{Fight.process_myRoundStart, true} )
	end
end

function Skill_trial_daobaozhe_3:onDoSummon( selfHero, atkData )
	local summonInfo = atkData:sta_summon()
	if not summonInfo then return end
	-- if selfHero.data:boss() == 1 then
	-- 	echo("前三回合都召唤小怪、保持屏幕怪物个数为4，如果该位置有怪，则覆盖、并且是一只掉buff、一只掉法宝")
	-- 	local trailRandBuff = BattleRandomControl.getOneGroupIndex(4,2,nil)
	-- 	local haveDropBuff = false
	-- 	for i=1,4 do
	-- 		local posHero = selfHero.logical:findHeroModel(2,i,true)
	-- 		if posHero then
	-- 			echo("直接让怪物死亡-并替换")
	-- 			posHero:doHeroDie(true)--这个地方
	-- 		end
	-- 		-- 随机一只怪
	-- 		local tInfo = BattleRandomControl.randomOneGroupArr(summonInfo)
	-- 		tInfo[1].pos = i

	-- 		local hero = selfHero:summonOneTarget(tInfo[1])
	-- 		if hero and atkData:sta_aniArr() then
	-- 			hero:createEffGroup(atkData:sta_aniArr(),false,nil,selfHero)
	-- 		end
	-- 		if table.keyof(trailRandBuff,i) then
	-- 			if not haveDropBuff then
	-- 				hero:loadRadomDropBuff()
	-- 				haveDropBuff = true
	-- 			else
	-- 				-- self:dropOneTreasure(hero)
	-- 			end
	-- 		end
	-- 		if hero and hero.healthBar then
	-- 			hero.healthBar:showOrHideBar(true)
	-- 		end
	-- 		-- 排序
	-- 		selfHero.logical:sortCampPos(selfHero.camp)
	-- 	end
	-- end
end

--被击之后
function Skill_trial_daobaozhe_3:onAfterHited( selfHero,attacker,skill,atkData,damage)
	-- 2018.01.23 pangkangning 去掉掉落法宝和buff的逻辑
	-- local totalDamage = selfHero:getSkillDamage(attacker,skill) or 0
	-- local percent = math.round(totalDamage/selfHero.data:maxhp()*100)
	-- if percent >= self.hpPercent then
	-- 	echo("伤害超过%s则掉落指定buff",self.hpPercent)
	-- 	local randomInt = BattleRandomControl.getOneIndexByGroup(self.weight)
	-- 	local bId = self.buffId[randomInt]
	-- 	if bId then
	-- 		local posx,posy = selfHero.pos.x,selfHero.pos.y
	-- 		selfHero.controler:dropTrialBuff({id = bId,type= Fight.drop_buff },posx,-posy,selfHero.data.posIndex)--a12
	-- 	end
	-- 	self:dropOneTreasure(selfHero)
	-- 	local drop = selfHero:getTrialDropItems()
	-- 	if drop.id then
	-- 		local posx,posy = selfHero.pos.x,selfHero.pos.y
	-- 		selfHero.controler:dropTrialBuff(drop,posx,-posy,selfHero.data.posIndex)--a12
	-- 	end
	-- end

end
function Skill_trial_daobaozhe_3:dropOneTreasure(hero)
	-- local treasures = BattleControler:getTrialDropTreasure()
	-- if #treasures > 0 then
	-- 	local idx = BattleRandomControl.getOneRandomInt(#treasures+1,1)
	-- 	hero:loadRadomDropTreasure(tostring(treasures[idx].id))
	-- end
end
return Skill_trial_daobaozhe_3