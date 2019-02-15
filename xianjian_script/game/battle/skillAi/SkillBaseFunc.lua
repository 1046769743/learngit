--
-- Author: xd
-- Date: 2017-03-14 16:11:51
--
--技能相关的一些基础函数
SkillBaseFunc = {}
local comeparaMap = {
	da = 1,
	dadeng = 2,
	deng = 3,
	xiaodeng = 4,
	xiao = 5
}


--排列属性
--[[
sortKey = {
	key 属性名,valueT 1 按绝对值还是百分比, type 1增序,2减序
	{key = "atk",valueT = 1,type = 1}		
}
]]
function SkillBaseFunc:sortProp( campArr,sortKey )
	local sortFunc = function ( hero1,hero2 )
		for i,v in ipairs(sortKey) do
			local key = v.key
			local value2
			local value1
			--判断是按绝对值还是百分比
			if v.valueT == 1 then
				value1 = hero1.data:getAttrByKey(key)
				value2 = hero2.data:getAttrByKey(key)
			else
				value1 = hero1.data:getAttrPercent(key)
				value2 = hero2.data:getAttrPercent(key)
			end
			--1增序  2减序
			if v.type == 1 then
				if value1 < value2 then
					return true
				elseif value1 > value2 then
					return false
				end
			else
				if value1 > value2 then
					return true
				elseif value1 < value2 then
					return false
				end
			end
		end
		return hero1.data.posIndex > hero2.data.posIndex
	end
	table.sort(campArr,sortFunc)
end

--判断位置是否正确 判断某个英雄是否在攻击范围内
function SkillBaseFunc:checkPos(xArr,yType,attacker, hero )
	if hero.data.gridPos.x < xArr[1] or hero.data.gridPos.x > xArr[#xArr] then
		return false
	end
	if hero.data:isBigger() then
		return true
	end
	if yType == 1 or yType == 2 then
		if hero.data.gridPos.y ~= yType then
			return false
		end
		return true
	elseif yType == 0 then
		return true
	else
		if hero.data.gridPos.y ~= attacker.data.gridPos.y then
			return false
		end
		return true
	end
	return true
end

--判断阵营
function SkillBaseFunc:checkCamp( hero,camp )
	if camp == 0 then
		return true
	end
	return hero.camp == camp
end

--判断性别
function SkillBaseFunc:checkSex( hero,sex )
	if sex == 0 then
		return true
	end
	return hero.data:getCurrTreasureSex() == sex
end

-- 判断主角
function SkillBaseFunc:checkCharacter(hero)
	return hero.data.isCharacter
end
--判断职业 profession 0 表示全职业
function SkillBaseFunc:checkProfession( profession,hero )
	--暂时判定正确
	if profession == 0 then
		return true
	end
	-- 2017.08.09 pangkangning 修改获取角色职业
	return profession == hero:getHeroProfession()
	-- return profession == hero.data:profession()
end


--截取人数 -1 表示全部 不改变数组 返回新数组
function SkillBaseFunc:cutChooseNums(chooseNum,heroArr  )
	chooseNum = chooseNum or 12 
	if chooseNum == -1 then
		chooseNum = 12
	end
	if chooseNum > #heroArr  then
		chooseNum = #heroArr
	end
	local resultArr = {}
	for i=1,chooseNum do
		if heroArr[i] then
			table.insert(resultArr,heroArr[i])
		end
	end
	
	return resultArr
end

--获取人数越少伤害越高带来的加成  camp 0表示敌我双方都包含, maxPercent万分比
function SkillBaseFunc:getPersonAddDmg(attacker,defender, maxPercent,camp )
	local maxNums = camp == 0 and Fight.maxCampNums or Fight.maxCampNums*2
	local targetNums = 0
	if camp == 0 then
		targetNums = #attacker.campArr + #attacker.toArr
	elseif camp == 1 then
		targetNums = #attacker.campArr
	else
		targetNums = #attacker.toArr
	end
	return 1+ maxPercent/10000 / (1-maxNums)  * (targetNums-maxNums) 

end


--判断比较 true 返回成  false 返回比较失败
--1大于,2大于等于,3等于,4小于等于,5小于)
function SkillBaseFunc:checkCompare( value1,value2,compareType )
	if compareType == comeparaMap.da then
		return  value1 > value2
	elseif compareType == comeparaMap.dadeng then
		return  value1 >= value2
	elseif compareType == comeparaMap.deng then
		return  value1 == value2
	elseif compareType == comeparaMap.xiaodeng then
		return  value1 <= value2
	elseif compareType == comeparaMap.xiao then
		return  value1 < value2
	else
		echoError("错误的比较模式:",compareType,"filterhid",self.hid)
		return false
	end
end

--获取不屈带来的伤害加成 maxPercent 最大伤害万分比加成,满血是没有额外伤害加成的,空血就是最大加成
function SkillBaseFunc:getBuquValue( attacker,defender,maxPercent )
	local hpPercent = attacker.data:hp()/attacker.data:maxhp()
	return (1-hpPercent) * (maxPercent/10000) + 1
end

-- 判断是否是活人(有傀儡则非活人)
function SkillBaseFunc:isLiveHero(hero)
	local isMission = (BattleControler:getBattleLabel() == GameVars.battleLabels.missionMonkeyPve)
	local isBomb = (BattleControler:getBattleLabel() == GameVars.battleLabels.missionBombPve)
	local hasDied = false
	if isMission or isBomb then
		hasDied = (hero.data:hp() <=0 or hero._isDied or hero:hasNotAliveBuff())
	else
		hasDied = (hero.data:hp() <=0 or hero._isDied or hero:hasNotAliveBuff() or hero:getHeroProfession() == Fight.profession_neutral or hero:getHeroProfession() == Fight.profession_obstacle)
	end
	return not hasDied
end

-- 检查是否还有活人
function SkillBaseFunc:chkLiveHero( campArr )
	if not campArr then return false end
	
	local result = false
	for _,hero in ipairs(campArr) do
		if self:isLiveHero(hero) then
			result = true
			break
		end
	end

	return result
end

-- 获取队列中血量最少的
function SkillBaseFunc:getMinHpHero(campArr)
	local hero = nil
	for _,h in ipairs(campArr) do
		-- 活人
		if SkillBaseFunc:isLiveHero(h) then
			if not hero 
				or h.data:getAttrPercent(Fight.value_health) < hero.data:getAttrPercent(Fight.value_health)
			then 
				hero = h 
			end
		end
	end

	return hero
end