
-- Author:庞康宁
-- Date: 2017.09.13
-- des: 盗宝者 被攻击>=5%时掉buff、法宝逻辑

local Skill_trial_daobaozhe_4 = class("Skill_trial_daobaozhe_4", SkillAiBasic)

function Skill_trial_daobaozhe_4:ctor(skill,id,hp,...)
	Skill_trial_daobaozhe_4.super.ctor(self,skill,id,...)
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
	我方回合开始前(为防止有召唤，所以在此也做roundReady处理)
]]
function Skill_trial_daobaozhe_4:onMyRoundStart( selfHero )
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
--被击之后
function Skill_trial_daobaozhe_4:onAfterHited( selfHero,attacker,skill,atkData,damage)
	-- 2018.01.23 pangkangning 去掉掉落法宝和buff的逻辑
	-- local totalDamage = selfHero:getSkillDamage(attacker,skill) or 0 --容错，也有可能为空
	-- local percent = math.round(totalDamage/selfHero.data:maxhp()*100)
	-- if percent >= self.hpPercent then
	-- 	echo("伤害超过%s则掉落指定buff",self.hpPercent)
	-- 	local randomInt = BattleRandomControl.getOneIndexByGroup(self.weight)
	-- 	local bId = self.buffId[randomInt]
	-- 	if bId then
	-- 		local posx,posy = selfHero.pos.x,selfHero.pos.y
	-- 		selfHero.controler:dropTrialBuff({id = bId,type= Fight.drop_buff },posx,-posy,selfHero.data.posIndex)--a12
	-- 	end
	-- end

end

return Skill_trial_daobaozhe_4