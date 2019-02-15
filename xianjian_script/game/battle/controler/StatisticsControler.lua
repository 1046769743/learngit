--
-- Author: xd
-- Date: 2016-06-20 11:27:10
--
local Fight = Fight
-- local BattleControler = BattleControler
StatisticsControler = {}

--记录每回合每个技能造成的伤害
StatisticsControler.roundSkillDamage = nil

--每回合造成的总伤害
StatisticsControler.totalDamage = nil 

-- 奇侠出手次数
StatisticsControler.handleCount = nil --目前先这么写，以后拓展这个字段为某个奇侠某回合的出手次数

--[[
	--数据格式
	{	
		wave = {
			roundCount = {
				rid = {
					treat = 0 --治疗量
					skillId = 1001
					damage = 0 --伤害量(打出的伤害有可能有伤害溢出)
					realDamage = 0 --真实伤害
					hurt=0 -- 承受到的伤害伤害[正数]
				}
			} 
		}
	}

]]

function StatisticsControler:init(controler )
	self.controler = controler
	self.handleCount = {}
	self.totalDamage = {}
end
-- 统计出手次数
function StatisticsControler:addHandleNumber(camp)
	if not self.handleCount[camp] then
		self.handleCount[camp] = 0
	end
	self.handleCount[camp] = self.handleCount[camp] + 1
end
-- 获取出手次数
function StatisticsControler:getHandleCount(camp)
	if not self.handleCount[camp] then
		return 0
	end
	return self.handleCount[camp]
end

--统计伤害
function StatisticsControler:statisticsdamage(attacker,defender, skill , damage,realDamage)
	if defender:getHeroProfession() == Fight.profession_obstacle then
        return
    end

	if not attacker then
		echoError ("这个理论上不会为空")
		return
	end
	--
	local rid = attacker.data.rid
	local dRid = defender.data.rid
	local wave = self.controler.__currentWave
	local round = self.controler.logical.roundCount
	if not self.totalDamage[wave] then
		self.totalDamage[wave] = {}
	end
	if not self.totalDamage[wave][round] then
		self.totalDamage[wave][round]  = {}
	end
	if not self.totalDamage[wave][round][rid] then
		self.totalDamage[wave][round][rid] = {treat = 0,damage =0,realDamage=0, countDamage = {}, skillId = skill.hid,hurt=0,camp=1}
	end
	local info = self.totalDamage[wave][round][rid]
	info.damage = info.damage + damage
	info.realDamage = info.realDamage + realDamage
	info.camp = attacker.camp
	-- 统计一下每次出手的伤害
	local dmg = info.countDamage[attacker.atkTimes] or 0
	dmg = dmg + damage
	info.countDamage[attacker.atkTimes] = dmg
	-- 统计defender承受到伤害
	-- local dRid = defender.data.rid
	if not self.totalDamage[wave][round][dRid] then
		self.totalDamage[wave][round][dRid] = {treat = 0,damage =0,realDamage=0, countDamage = {}, skillId = skill.hid,hurt=0,camp=1}
	end
	local info1 = self.totalDamage[wave][round][dRid]
	info1.hurt = info1.hurt + realDamage
	info1.camp = defender.camp
end

-- 获取某回合的统计信息
function StatisticsControler:getDamageInfo( wave, round, hero )
	if not self.totalDamage[wave] then return end
	if not self.totalDamage[wave][round] then return end
	if not self.totalDamage[wave][round][hero.data.rid] then return end

	return self.totalDamage[wave][round][hero.data.rid]
end

--统计治疗
function StatisticsControler:statisticsTreat(attacker,defender, skill , treat  )
	local rid = attacker.data.rid
	local wave = self.controler.__currentWave
	local round = self.controler.logical.roundCount
	if not self.totalDamage[wave] then
		self.totalDamage[wave] = {}
	end
	if not self.totalDamage[wave][round] then
		self.totalDamage[wave][round]  = {}
	end
	if not self.totalDamage[wave][round][rid] then
		self.totalDamage[wave][round][rid] = {treat = 0,damage =0,realDamage=0, countDamage = {}, skillId = skill.hid,hurt=0 }
	end
	local info = self.totalDamage[wave][round][rid]
	info.treat = info.treat + treat
end

--获取当前回合的总伤害
function StatisticsControler:getRoundTotalDamage(  )
	local wave = self.controler.__currentWave
	local round = self.controler.logical.roundCount
	local waveInfo = self.totalDamage[wave]
	if not waveInfo then
		return 0
	end
	local roundInfo = waveInfo[round]
	if not roundInfo then
		return 0
	end
	local damage = 0
	for k,v in pairs(roundInfo) do
		damage = damage + math.round(v.damage)
	end

	return damage

end


--获取当前回合某个人的伤害
-- 获取每次出手的伤害2017.7.25修改，有的人会重置攻击出手多次，这个时候的伤害值不能取总的
function StatisticsControler:getRidDamage( rid,times )
	local times = times or 1
	local wave = self.controler.__currentWave
	local round = self.controler.logical.roundCount
	local waveInfo = self.totalDamage[wave]
	if not waveInfo then
		return 0
	end
	local roundInfo = waveInfo[round]
	if not roundInfo then
		return 0
	end
	local rInfo = roundInfo[rid]
	if not rInfo then
		return 0
	end
	local dmg = rInfo.countDamage[times]
	
	if not dmg then
		return 0
	end
	-- return rInfo.damage
	return dmg
end
-- 获取整场战斗所有伙伴的总伤害
function StatisticsControler:getAllTotalDamage(camp)
	local damage = 0
	for wave,waveInfo in pairs(self.totalDamage) do
		for round,roundInfo in pairs(waveInfo) do
			local roundInfo = waveInfo[round]
			if roundInfo then
				for k,v in pairs(roundInfo) do
					if camp == v.camp then
						damage = damage + math.round(v.realDamage)
					end
				end
			end
		end
	end
	return damage
end

--获取某个人的整场战斗的总伤害
function StatisticsControler:getRidTotalDamage( rid )
	local damage = 0
	-- for k,v in pairs(self.totalDamage) do
	-- 	if v[rid] then
	-- 		damage = damage + v[rid].damage
	-- 	end
	-- end

	for wave,waveInfo in pairs(self.totalDamage) do
		for round,roundInfo in pairs(waveInfo) do
			if roundInfo[rid] then
				damage = damage + roundInfo[rid].realDamage
			end
		end
	end

	return damage
end
-- 获取某个人的整场战斗的总承受伤害量
function StatisticsControler:getRidTotalHurt(rid )
	local hurt = 0
	-- for k,v in pairs(self.totalDamage) do
	-- 	if v[rid] then
	-- 		hurt = hurt + v[rid].hurt
	-- 	end
	-- end

	for wave,waveInfo in pairs(self.totalDamage) do
		for round,roundInfo in pairs(waveInfo) do
			if roundInfo[rid] then
				hurt = hurt + roundInfo[rid].hurt
			end
		end
	end

	return hurt
end

-- 根据试炼类型获取MVP角色
--[[
	输出(山神)试炼评比造成伤害最高者
	生存(火神)试炼评比承受伤害最高者
	主角(盗宝者)试炼评比造成伤害最高者
]]
function StatisticsControler:getTrailStatisData(  )
    local controler = BattleControler.gameControler
    local trailType = BattleControler:checkIsTrail()
    local max = 0
    local totalValue = 0
    local mvpObj = {hid=0,value=0,icon=0,name=0,quality=1,star=1,lv=1}
    for i,v in ipairs(controler.levelInfo.campData1) do
    	local value
    	if trailType == Fight.trail_huoshen then
    		value = StatisticsControler:getRidTotalHurt( v.rid )
    	else
    		value = StatisticsControler:getRidTotalDamage( v.rid )
    	end
        totalValue = totalValue + value
        local treasure = v.treasures[next(v.treasures)]
        local treaObj = ObjectTreasure.new(treasure.hid,treasure)
        if value >= max then
        	max = value
	        --构建返回数据
	        local tb = {}
	        mvpObj.hid = v.hid
	        mvpObj.value = value
	        mvpObj.icon = treaObj:sta_icon()
	        mvpObj.name = GameConfig.getLanguage(treaObj:sta_name())
	        mvpObj.quality = v.quality or 1
	        mvpObj.star = v.star or 1
	        mvpObj.lv = v.lv or 1
	       	mvpObj.isCharacter = v.isCharacter
        end
    end
    return mvpObj,math.round(totalValue)
end

--获取统计伤害数据

function StatisticsControler:getStatisDatas( isPVE)
	 -- echo("打开排名列表",isPVE)
    --构建战斗数据
    local controler = BattleControler.gameControler
    local battleUser = controler.levelInfo.battleInfo.battleUsers
    local enemyName  = nil --机器人主角名称
	local myName = nil --我方名字
    local campDataArr1 = controler.levelInfo.campData1
    local campDataArr2 = controler.levelInfo.waveDatas[1]
    if not isPVE then
	    if battleUser then
	    	enemyName = battleUser[2].name
	    end
	else
		if BattleControler:getBattleLabel() == GameVars.battleLabels.missionBattlePve then
			if battleUser then
		    	myName = battleUser[1].name
		    	enemyName = battleUser[2].name
			end
		end
	    campDataArr2 ={}
	    for k,v in pairs(controler.levelInfo.waveDatas) do
	    	for m,n in pairs(v) do
	    		table.insert(campDataArr2,n)
	    	end
	    end
    end

    local countGroupInfo = function (campDataArr ,isEnemy)
        local totalDamageTb = {damage = 0}
        local groupArr = {}

        --[[
        [5001] = {
                    hid = 5001,
                    damage = 100,
                    icon = "lixiaoyao",
                    percent = 40,
                    name = "张三",
                    maxDamage = 40000,
                },

        ]]
        for i,v in ipairs(campDataArr) do
            local damage = StatisticsControler:getRidTotalDamage( v.rid )
            totalDamageTb.damage = damage + totalDamageTb.damage
            -- 获取角色是否是中立或者木桩(不进入统计处理)
            local treasure = v.treasures[next(v.treasures)]
            local treaObj = ObjectTreasure.new(treasure.hid,treasure)
            if treaObj:sta_profession() ~= 6 and treaObj:sta_profession() ~= 7 then
	            --构建table
	            local tb = {}
	            tb.hid = v.hid
	            tb.damage = damage
	            tb.icon = treaObj:sta_icon()
	            tb.name = GameConfig.getLanguage(treaObj:sta_name())
	            tb.quality = v.quality or 1
	            tb.star = v.star or 1
	            if v.isCharacter then
	            	if isEnemy then
	            		tb.name = enemyName or tb.name
	            	else
		            	tb.name = myName or tb.name
	            	end
	            	
	            end
	            tb.lv = v.lv or 1
	            table.insert(groupArr, tb)
	        end
        end

        if totalDamageTb.damage == 0 then
        	totalDamageTb.damage = 1
        end
        --计算伤害百分比
        for i,v in ipairs(groupArr) do
            v.percent = math.round(v.damage / totalDamageTb.damage *100)
        end
        --按照伤害百分比排序
        local sortFunc = function ( t1,t2 )
            return t1.damage > t2.damage
        end

        table.sort(groupArr,sortFunc)
        return groupArr
    end

    local groupArr1 = countGroupInfo(campDataArr1)
    local groupArr2 = countGroupInfo(campDataArr2,true)
    --我方和地方位置互换
    return {camp2 =groupArr1,camp1 = groupArr2 }
end

-- 重置信息
function StatisticsControler:resetStatisticsInfo()
	self.handleCount = {}
	self.totalDamage = {}
end

function StatisticsControler:deleteMe(  )
	self.controler = nil
end