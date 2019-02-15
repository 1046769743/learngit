
local Fight = Fight
local table = table
AttackChooseType = {}

--[[
	辅助函数
	根据攻击包的buffs数据给人物的 __tempBuffObjs 属性赋值，用于显示连线上的buff提示
	resultArr 是人物的数组
]]
function AttackChooseType:_setTempBuffs( resultArr, atkData, skill )
	local buffs = atkData:getTempBuffs(skill)

	if resultArr and buffs then
		for i,v in ipairs(resultArr) do
			if not v.__tempBuffObjs then v.__tempBuffObjs = {} end

			for ii,vv in ipairs(buffs) do
				table.insert(v.__tempBuffObjs, vv)
			end
		end
	end

	return resultArr
end

function AttackChooseType:atkChooseByType(attacker, atkData,attTarget, myCampArr, toCampArr,skill  )
	
	-- local st = GameStatistics:costTimeBegin("AttackChooseType:atkChooseByType")
	-- 如果有技能指定的攻击目标则直接赋值给攻击包
	if skill and skill:getAppointAtkChooseArr() then
		atkData.hasChooseArr = skill:getAppointAtkChooseArr()
	end
	--如果是这个攻击包已经有筛选过的人了 那么直接返回
	local resultArr = atkData.hasChooseArr
	if resultArr and #resultArr > 0  then
		if not Fight.isDummy  then
			-- 记录下 临时的buff  只做显示用 在modelHero 做连线用的
			AttackChooseType:_setTempBuffs( resultArr, atkData, skill )
		end

		return resultArr
	end
	-- local st = GameStatistics:costTimeBegin( "AttackChooseType:atkChooseByType" )
	-- 先过滤一遍不该打的人（傀儡）
	myCampArr = self:arrayFilter(myCampArr)
	toCampArr = self:arrayFilter(toCampArr)

	local campArr 
	local xArr = atkData.xChooseArr
	local yType = atkData.yChooseType

	local useWay = atkData:sta_useWay()
	local firstHero 
	if useWay == 1 then
		campArr = myCampArr
		--x方向偏移
		firstHero = self:findFirstHero(campArr,attacker,atkData.xChooseArr,atkData.yChooseType,skill)
	else
		campArr = toCampArr
	end

	
	local  startXIndex ,startYIndex
	if not skill then
		startXIndex = 1
		startYIndex = 1
	else
		startXIndex = skill.startXIndex
		startYIndex = skill.startYIndex
	end
	--如果是作用在我方的
	if useWay == 1 then
		if not firstHero then
			return 
		end
		startXIndex = firstHero.data.gridPos.x
		resultArr = self:findHeroesBySkillPos( startXIndex,startYIndex,xArr,yType,firstHero, campArr,attacker )
	else
		if attacker.logical.attackSign and attacker.logical.attackSign.camp ~= attacker.camp then
			firstHero = attacker.logical.attackSign
		end
		resultArr = self:findHeroesBySkillPos( startXIndex,startYIndex,xArr,yType,nil, campArr,attacker )
	end

	local filteObj = atkData.filterObj
	if filteObj then
		filteObj.heroModel = attacker
		local tempValue 
		-- 如果有特殊ai那么就不应该依赖于前面的筛选2017.6.30
		resultArr = nil
		tempValue,resultArr = filteObj:startChoose(attacker, attTarget, resultArr, skill)
		-- echoError(#resultArr,"___________走到这里来了",atkData.hid)
	end

	
	--[[
	if not Fight.isDummy  then
		local buffs = atkData:getTempBuffs(skill)
		--记录下 临时的buffid  只做显示用 在modelHero 做连线用的

		if resultArr and buffs then
			-- echo("__走到这里来了---------------")
			for i,v in ipairs(resultArr) do
				-- v.__tempBuffObjs =  buffObjArr
				if not v.__tempBuffObjs then v.__tempBuffObjs = {} end

				for ii,vv in ipairs(buffs) do
					table.insert(v.__tempBuffObjs, vv)
				end
			end
		end	
	end
	]]
	
	

	--这里要把这个攻击选择过的人缓存起来
	atkData.hasChooseArr = resultArr
	-- st = GameStatistics:costTimeEnd( "AttackChooseType:atkChooseByType",st )
	-- local st = GameStatistics:costTimeEnd("AttackChooseType:atkChooseByType",st)
	return resultArr
end

--找对位的第一个英雄
function AttackChooseType:findFirstYposHero( attacker,heroArr )
	local hero1 = heroArr[1]
	local hero2 = heroArr[2]
	if not hero2 then
		return hero1
	end

	--如果是大体型的 直接返回第一个
	if attacker.data:isBigger() then
		return hero1
	end
	if hero2.data.gridPos.x ~= hero1.data.gridPos.x then
		return hero1
	end
	if hero2.data.gridPos.y == attacker.data.gridPos.y then
		return hero2
	end
	return hero1


end


--根据各种条件筛选符合条件的人
function AttackChooseType:secondChooseHeroes( targetArr,chooseTypeArr,atkNums )
	targetArr = targetArr or {}
	--给hero 临时定义排序属性 __tempValue
	local sortByProp = function (hero1,hero2  )
		for i,v in ipairs(chooseTypeArr) do

			local key = v.k
			local value = v.v
			local chooseType = v.t
			--如果是按照属性选择 目前只有属性选择
			if chooseType == "1" then
				--如果是 越大 越靠前
				if value == 1 then
					if hero1.data[key](hero1.data) > hero2.data[key](hero2.data) then
						return true
					elseif hero1.data[key](hero1.data) < hero2.data[key](hero2.data) then
						return false
					end
				else
					if hero1.data[key](hero1.data) > hero2.data[key](hero2.data) then
						return false
					elseif hero1.data[key](hero1.data) < hero2.data[key](hero2.data) then
						return true
					end
				end
			end
		end
		return false
	end
	--如果有特殊排序方式
	if #targetArr >= 2 and chooseTypeArr then
		--如果是走随机的,单独先随机这个数组
		if #chooseTypeArr > 0 and chooseTypeArr[1].t =="0" then
			targetArr = BattleRandomControl.randomOneGroupArr(arr, index)
		else
			table.sort(targetArr,sortByProp)
		end
	end
	if not atkNums or atkNums == -1 then
		return targetArr
	end
	--在按照攻击数量
	local resultArr = {}
	for i=1,atkNums do
		if targetArr[i] then
			table.insert(resultArr, targetArr[i])
		end
	end
	return  resultArr

end


--


--找第一个能打的人
function AttackChooseType:findFirstHero( campArr, attacker,xArr,yType,skill )
	-- 如果有钦定选敌就赋值钦定选敌寻找
	if skill and skill:getAppointAtkChooseArr() then
		campArr = skill:getAppointAtkChooseArr()
	end
	local controler = attacker.controler
	if not controler:isLineFirst() then
		local hero1 = campArr[1]
		local hero2 = campArr[2]


		local targetHero,targetHero2
		if yType == 3 then
			--只要找到了对应y上面的人 就不换行
			--如果只有一个人
			local yIndex = attacker.data.gridPos.y
			if #xArr == 1 then
				targetHero = self:findHeroByIndex(xArr[1], yIndex, campArr)

				if not targetHero then
					targetHero = self:findHeroByIndex(xArr[1], yIndex == 1 and 2 or 1, campArr)
				end
				if targetHero then
					return targetHero
				end
			--如果是有选择2个x方向的
			elseif #xArr == 2 then
				targetHero = self:findHeroByIndex(xArr[1], yIndex, campArr)
				targetHero2 = self:findHeroByIndex(xArr[2], yIndex, campArr)
				--找对应位置的人  如
				if targetHero  then
					return targetHero
				end
				if targetHero2  then
					return targetHero2
				end
				yIndex = yIndex ==1 and 2 or 1
				argetHero = self:findHeroByIndex(xArr[1], yIndex, campArr)
				targetHero2 = self:findHeroByIndex(xArr[2], yIndex, campArr)

				if targetHero  then
					return targetHero
				end
				if targetHero2  then
					return targetHero2
				end
			end
		else 
			for i,v in ipairs(xArr) do
				targetHero = self:findHeroByIndex(v, 1, campArr)
				if targetHero then
					return targetHero
				end
				targetHero = self:findHeroByIndex(v, 2, campArr)
				if targetHero then
					return targetHero
				end
			end
		end


		if not hero2 then
			return hero1
		end
		--如果 网格x坐标不相等 肯定是选择 最靠前的人
		if hero1.data.gridPos.x ~= hero2.data.gridPos.x then
			return hero1
		end

		--在来判断 网格坐标 优先选择 y坐标相等的人
		if hero1.data.gridPos.y == attacker.data.gridPos.y then
			return hero1
		else
			return hero2
		end
	else
		-- 寻找某一行的人（先找对应位置，后按照顺序取）
		local function _findHero(xArr, yType)
			local targetHero,tTargetHero
			local xMap = {[1] = false, [2] = false, [3] = false}
			-- 初始化
			for _,xType in ipairs(xArr) do
				xMap[xType] = true
			end
			for xType,first in ipairs(xMap) do
				local hero = self:findHeroByIndex(xType, yType, campArr)
				if hero then
					if xMap[xType] then
						targetHero = hero
						break
					else
						-- 不是指定位置的人，则是此方向从前向后找的第一个
						if not tTargetHero then
							tTargetHero = hero
						end
					end
				end
			end

			return targetHero and targetHero or tTargetHero
		end
		-- echo("来查错",yType)
		-- for i,hero in ipairs(campArr) do
		-- 	echo("剩余的位置",hero.data.posIndex)
		-- end
		-- for i,v in ipairs(xArr) do
		-- 	print(i,v)
		-- end
		local targetHero
		-- 如果是打全体，直接找第一个人
		if yType == 0 and #xArr == 3 then
			targetHero = campArr[1]
			return targetHero
		end
		
		-- 优先找某个y上对应位置是否有人
		local targetY = (yType == 3 or yType == 0) and attacker.data.gridPos.y or yType

		targetHero = _findHero(xArr, targetY)

		if targetHero then
			return targetHero
		end

		-- 另一个方向上对应位置是否有人
		targetY = targetY == 1 and 2 or 1

		local targetHero = _findHero(xArr, targetY)

		return targetHero
	end
end

--根据技能的起始位置获取hero
function AttackChooseType:findHeroesBySkillPos( startXIndex,startYIndex,xArr,yType,targetHero, campArr,attacker )
	local resultArr = {}
	startXIndex = startXIndex or 1
	startYIndex = startYIndex or targetHero.data.gridPos.y
	local firstXIndex = xArr[1] + startXIndex -1
	local endXIndex = xArr[#xArr] + startXIndex -1
	--这里需要判断
	for i,v in ipairs(campArr) do
		--这里需要判断yType
		--如果是指定打上下排的
		local gridPos = v.data.gridPos
		--必须在x选择范围之类
		if gridPos.x >= firstXIndex and gridPos.x <= endXIndex then
			--如果是
			if yType == 1 or yType ==2 then
				if gridPos.y == yType  then
					table.insert(resultArr, v)
				end
			elseif yType == 0 then
				table.insert(resultArr, v)
			--如果是打对应Index
			elseif yType ==3 then
				if gridPos.y ==startYIndex or v.data:isBigger() then
					table.insert(resultArr, v)
				end
			end
		end
	end
	-- echo(#resultArr,"__打到的人的数量",startXIndex,firstXIndex,endXIndex)
	return  resultArr
end


--根据xChooseArr 和 当前锁定的人  返回 能选择到的人
function AttackChooseType:findFirstBySign( xArr,yType, targetHero, campArr,attacker)
	--有个前提就是 xArr里面的数必须是连续的 不允许分散开 否则就会出问题
	--如果是找对应 x方向的
	local hero1 = campArr[1]
	local hero2 = campArr[2]

	--找到xIndex
	local xIndex = targetHero.data.gridPos.x
	local yIndex = targetHero.data.gridPos.y

	local firstHero 
	--如果是打对应y列的 而且目标是大体形怪
	if yType == 3 and targetHero.data:isBigger() then
		yIndex = attacker.data.gridPos.y
	end

	--如果目标xIndex 在我的x范围内
	if xIndex >= xArr[1] and xIndex <= xArr[#xArr] then
		for i,v in ipairs(xArr) do
			firstHero = self:findHeroByIndex(v, yIndex, campArr)
			if firstHero then
				return firstHero
			end
		end
	--如果靠左了 那么直接返回追击目标
	elseif xIndex < xArr[1] then
		firstHero = targetHero
		return firstHero
	else
		--如果靠右  那么需要做偏移
		local xOff = xIndex - xArr[#xArr]
		for i,v in ipairs(xArr) do
			firstHero = self:findHeroByIndex(v + xOff, yIndex, campArr)
			if firstHero then
				return firstHero
			end
		end
	end
	dump(xArr,"xArr_yType"..yType)
	echoError("不应该走到这里来",targetHero.data.posIndex)

	return firstHero
end

--找指定位置的人 根据gridPos
function AttackChooseType:findHeroByIndex( xIndex,yIndex,campArr )
	local function findByIdx( xIdx, yIdx )
		local posIndex = (xIdx -1) * 2 + xIdx
		return self:findHeroByPosIndex(posIndex,campArr)
	end
	-- 确定位置
	if xIndex and yIndex then
		local posIndex = (xIndex -1) * 2 + yIndex
		return self:findHeroByPosIndex(posIndex,campArr)
	elseif xIndex or yIndex then
		local result = nil
		local max = three(xIndex,2,3)
		for i=1,max do
			local posIndex = ((xIndex or i) -1) * 2 + (yIndex or i)
			local hero = self:findHeroByPosIndex(posIndex,campArr)
			if hero then
				if not result then result = {} end
				table.insert(result, hero)
			end
		end
		return result
	end
end

--根据posIndex 找到指定的人
function AttackChooseType:findHeroByPosIndex( posIndex,campArr )
	for i,v in ipairs(campArr) do
		--所有找人的地方都得把体形参与计算
		if posIndex >=  v.data.posIndex  and posIndex <=  v.data.posIndex + v.data:figure() -1  then
			return v
		end
	end
	return nil
end

--根据rid 找到指定的人
function AttackChooseType:findHeroByHeroRid(heroRid, campArr )
	for i,v in ipairs(campArr) do
		if v.data.rid == heroRid then
			return v
		end
	end
	return nil

end

--[[
	根据hid 找到指定的人
	hid 为 "1" 则认为是主角
]]
function AttackChooseType:findHeroByHid(hid, campArr)
	local character = (hid == "1")

	for i,v in ipairs(campArr) do
		if (character and v.data.isCharacter) or v.data.hid == hid then
			return v
		end
	end

	return nil
end

-- 过滤一下不能选的人（傀儡不能被攻击）
function AttackChooseType:arrayFilter( campArr )
	local resultArr = {}

	for _,hero in ipairs(campArr) do
		if not hero:hasNotAliveBuff() 
			-- 不能检查hp>0 因为要鞭尸 人物在final才会死亡
			and not hero.hasHealthDied
		then
			table.insert(resultArr, hero)
		end
	end
	return resultArr
end

--获取技能攻击点  skipRandom是否跳过随机选择,这个很重要否则会出现结果不一样
function AttackChooseType:getSkillAttackPos( controler,model, skill ,skipRandom)
	local chooseType = skill:sta_appear()

	local keepDistance = Fight.attackKeepDistance
	local xpos ,ypos
	local toCampArr = model.toArr
	toCampArr = self:arrayFilter(toCampArr)
	local myCampArr = model.campArr
	myCampArr = self:arrayFilter(myCampArr)
	local firstHero

	local specialAtk = skill.speciaFilterAtkData

	local chooseArr 
	--[[
	-- 如果存在特殊ai那么这里找到firstHero也没有意义了2017.6.30
	]]
	-- 标记使用了特殊ai选敌
	local isUseSpAtk = false
	if specialAtk then
		if skipRandom and specialAtk.hasAtkRandom  then
		
		else
			chooseArr = self:atkChooseByType(model, specialAtk,nil, myCampArr, toCampArr,skill  )
			if chooseArr and #chooseArr> 0 then
				firstHero = chooseArr[1]
				isUseSpAtk = true
			end
		end
		
	end
	

	if not firstHero then
		if controler.logical.attackSign then
			firstHero = self:findFirstBySign(skill.xChooseArr,skill.yChooseType, controler.logical.attackSign, toCampArr,model)
		else
			firstHero = self:findFirstHero(toCampArr,model,skill.xChooseArr,skill.yChooseType,skill)
		end
	end
		
	if not firstHero then
		if chooseType == Fight.skill_appear_normal 
		or 	chooseType == Fight.skill_appear_ymiddle
		then -- 只有这两个模式必须在此时找到firstHero
			-- 如果对面有人就强行选一个
			if toCampArr and #toCampArr > 0 then
				firstHero = toCampArr[1]
			else
				-- 一定是异常情况
				local myNum = 0
				if myCampArr and #myCampArr > 0 then
					myNum = #myCampArr
				end
				local toNum = 0
				if toCampArr and #toCampArr > 0 then
					toNum = #toCampArr
				end
				echo("没有找到fristHero，可能是空放了", skill.hid, myNum, toNum)

				xpos, ypos = model.pos.x,model.pos.y
				return xpos, ypos
			end
		else
			echo("没有找到fristHero, 但当前不需要firstHero", chooseType)
		end
	end

	if firstHero then
		skill.firstHeroPosIndex = firstHero.data.posIndex
		-- 不使用特殊攻击包选首个人的技能才要做偏移，否则如果全体技能里混入特殊选敌会导致无法攻击到全体
		if not isUseSpAtk then
			--找到第一个攻击点的位置偏移
			skill.startXIndex = firstHero.data.gridPos.x - skill.xChooseArr[1] + 1
			skill.startYIndex = firstHero.data.gridPos.y
			-- 如果是大体型，y方向以自己的y为准
			if firstHero.data:isBigger() then
				skill.startYIndex = model.data.gridPos.y
			end
		end
		--记录能打到的第一个人的model
		skill.firstHeroModel = firstHero
	end


	local xRange = skill.xRange
	-- 是否偏移
	local isShift = false
	if skill.startXIndex ~= 1 and math.abs(skill.startXIndex - 1) < xRange then
		isShift = true
	end
	
	-- 计算位置时的方向由阵营来决定 2017.7.1
	local realWay = model.camp == 1 and Fight.myWay or Fight.enemyWay
	
	--获得控制器（用于转换坐标）
	local reFreshControler = controler.reFreshControler
	local middlePos = controler.middlePos
	-- 获取基准位置
	-- local function getBasePos(firstHero)
	local function getBasePos(camp,gridX,gridY,figure)
		if Fight.isDummy then
			return 1,1
		end
		local baseX,baseY = nil,nil
		
		local yIndex = gridY
		-- local posIdx = skill.xChooseArr[1] * yIndex
		local posIdx = 2 * gridX + gridY - 2
		baseX,baseY = reFreshControler:turnPosition(camp, posIdx, figure, middlePos)
		-- baseY = firstHero._initPos.y

		return baseX,baseY
	end

	-- echo("起始位置%d,第一个人位置:%d,攻击者位置:%d", skill.startXIndex,firstHero.data.posIndex,model.data.posIndex,skill.xChooseArr[1])
	--如果是跑第一个攻击目标人面前
	-- 2018.3.2 为了及时反击，将Fight.skill_appear_normal 的 _initPos 修改为 Pos 保证能打到当前位置
	--[[
		2018.3.15 A攻击B将之击飞后紧接着继续攻击选取的位置会是击飞后的位置，B又跑回来了位置就发生了偏移
		目前无法区分反击和再次攻击的区别，决定采用在技能上加标记做判断，其他技能依然使用_initPos
	]]
	-- 理论上讲只有单体才会配这个了所以偏移不偏移的问题不重要了但是代码保留
	if chooseType == Fight.skill_appear_normal then
		--基准位置
		local baseX,baseY = nil,nil
		--位置没有发生偏移
		if not isShift then
			baseX,baseY = firstHero._initPos.x, firstHero._initPos.y
			if skill._isFightBack then
				baseX = firstHero.pos.x
				baseY = firstHero.pos.y
			end
		else-- 发生偏移
			baseX, baseY = getBasePos(firstHero.camp, skill.xChooseArr[1], firstHero.data.gridPos.y, firstHero.data:figure())
		end
		
		-- xpos, ypos = firstHero._initPos.x - realWay * keepDistance,firstHero._initPos.y
		xpos, ypos = baseX - realWay * keepDistance,baseY
		--如果大体型的
		if firstHero.data:isBigger() then
			ypos = Fight.initYpos_3
		end
	elseif chooseType == Fight.skill_appear_normalEx then
		--基准位置
		local baseX,baseY = nil,nil

		local gridX = firstHero.data.gridPos.x
		local gridY = firstHero.data.gridPos.y
		-- 如果是大体型，y方向以自己的y为准
		if firstHero.data:isBigger() then
			gridY = model.data.gridPos.y
		end
		-- 如果发生了偏移修正x位置
		if isShift then
			gridX = skill.xChooseArr[1]
		end

		baseX,baseY = getBasePos(firstHero.camp, gridX, gridY, 1)
		-- firstHero._initPos.x, firstHero._initPos.y
		if skill._isFightBack then
			baseX = firstHero.pos.x
			baseY = firstHero.pos.y
		end
		
		xpos, ypos = baseX - realWay * keepDistance,baseY
	--如果是站在y轴中间
	elseif chooseType == Fight.skill_appear_ymiddle then
		--基准位置
		local baseX,baseY = nil,nil
		--位置没有发生偏移
		if not isShift then
			baseX,baseY = firstHero._initPos.x, firstHero._initPos.y
		else-- 发生偏移
			baseX, baseY = getBasePos(firstHero.camp, skill.xChooseArr[1], firstHero.data.gridPos.y, firstHero.data:figure())
		end
		
		xpos, ypos = baseX - realWay * keepDistance,baseY
		-- xpos, ypos = firstHero._initPos.x - realWay * keepDistance
		ypos = Fight.initYpos_3

	elseif chooseType == Fight.skill_appear_myFirst or chooseType == Fight.skill_appear_myyMiddle   then
		
		local atkData = skill.attackInfos[1][3]
		local chooseArr
		--如果是跳过随机的
		if skipRandom and atkData.hasAtkRandom then
			chooseArr = nil
		else
			chooseArr = AttackChooseType:atkChooseByType(model, skill.attackInfos[1][3],nil, myCampArr, toCampArr,skill  )
		end
		
		if chooseArr and chooseArr[1] then
			firstHero =chooseArr[1]
			xpos, ypos = firstHero._initPos.x + realWay * keepDistance,firstHero._initPos.y
			-- echo("____",xpos,firstHero.pos.x, firstHero.data.posIndex,firstHero.camp)
		else
			--如果没人
			xpos, ypos = model.pos.x,model.pos.y
			xpos = xpos  + realWay
			return xpos,ypos
			-- echoError("没有选择到人,技能id:%s",skill.hid)
		end
		
		skill.firstHeroPosIndex = firstHero.data.posIndex
		--找到第一个攻击点的位置偏移
		skill.startXIndex = firstHero.data.gridPos.x - skill.xChooseArr[1] + 1
		skill.startYIndex = firstHero.data.gridPos.y
		skill.firstHeroModel = firstHero
		--如果大体型的 或者是出现在选择人的中间
		if firstHero.data:isBigger() or chooseType == Fight.skill_appear_myyMiddle  then
			ypos = Fight.initYpos_3
		end

	--如果是屏幕中心
	elseif chooseType == Fight.skill_appear_toMiddle then
		-- 在屏幕正中间
		xpos = controler.logical:getAttackMiddlePos(model.toCamp)
		ypos = Fight.initYpos_3
	--如果是我方屏幕中心
	elseif chooseType == Fight.skill_appear_myMiddle then
		-- 在屏幕正中间
		xpos = controler.logical:getAttackMiddlePos(model.camp)
		ypos = Fight.initYpos_3
	elseif chooseType == Fight.skill_appear_myplace then
		-- 原地施法
		xpos = model.pos.x
		ypos = model.pos.y
	else
		echoWarn("错误的技能选择模式:",chooseType,"skillid:",skill.hid)
	end

	local offsetPos = skill:sta_pos()
	if offsetPos then
		xpos = xpos +offsetPos[1] * realWay
		ypos = offsetPos[2] + ypos
	end

	return xpos,ypos
end


--根据攻击区域 选择能攻击到的人, 目前暂时从最左边一个人数起
function AttackChooseType:getCanAttackEnemy(atkData,campArr,chooseType  )
	
	local length = #campArr
	if #campArr ==0 then
		return {}
	end
	local area = atkData:sta_area()
	if not area then
		echoError("没有配置攻击区域,hid:",atkData.hid)
		return {}
	end
	local dis = numEncrypt:getNum(area[2]) -numEncrypt:getNum(area[1])
	local start = 0
	local resultArr ={}
	if dis < 0 then
		echoError("攻击区域配范围小于0了,",atkData.hid)
		return {}
	end

	local first = campArr[1]
	table.insert(resultArr, first)
	for i=2,length do
		local enemy = campArr[i]
		if math.abs(enemy.pos.x - first.pos.x ) < dis then
			table.insert(resultArr,enemy)
		else
			break
		end
	end
	return resultArr
end


--[[
获取一个技能能够攻击到的位置
]]
function AttackChooseType:getSkillCanAtkPos(hero,skill,skipRandom)
	--如果攻击包中没有带有Final标记  并且不是打全体的攻击包  则返回getSkillCannAtkEnemy方法的
	--否则  回去攻击包的可以攻击的位置就可以了
	--attackInfos   frame,attack;frame,attack  
	local attackInfos = skill.attackInfos
	if attackInfos.isFinal == 1 or
		 attackInfos:sta_attackNums() == -1
	then

	else
		return self:getSkillCanAtkEnemy( hero,skill,skipRandom )
	end

end




--获取一个技能能打到的人
function AttackChooseType:getSkillCanAtkEnemy( hero,skill,skipRandom )

	-- local st = GameStatistics:costTimeBegin( "AttackChooseType:getSkillCanAtkEnemy" )

	local attackInfos = skill.attackInfos
	local heroArr = {}
	-- 注掉，因为选敌不一定在选对方2018.01.29
	-- if #hero.toArr == 0 then
	-- 	return heroArr
	-- end
	if not Fight.isDummy  then
		--清除临时buffid
		for i,v in ipairs(hero.toArr) do
			v.__tempBuffObjs = nil
		end
		for i,v in ipairs(hero.campArr) do
			v.__tempBuffObjs = nil
		end
	end
	

	AttackChooseType:getSkillAttackPos(hero.controler,hero,skill,skipRandom)
	-- local x,y = hero.controler.reFreshControler:turnPosition(2, 1,2 ,hero.controler.middlePos )
	-- x = x + (hero.controler.middlePos - x) / 3 * 2
	-- 作为占位用的随机人物
	local tempHero = {
		camp = 2,
		pos = {x = 0, y = 0},
		data = {
			posIndex = 10086,
			viewSize = {50, 100}
		},
		randomHero = true
	}
	for i,v in ipairs(attackInfos) do
		if v[1] == Fight.skill_type_attack then
			--显示技能展示区域是不能做攻击标记的
			local atkData = v[3]
			local chooseArr
			if atkData.hasAtkRandom and skipRandom then
				-- 随机直接用随机人物站位
				chooseArr = {tempHero}
				-- 赋值一下__tempBuffObjs属性
				AttackChooseType:_setTempBuffs( chooseArr, atkData,skill )
			else
				chooseArr = AttackChooseType:atkChooseByType(hero, v[3],nil, hero.campArr, hero.toArr,skill  )
			end
			if chooseArr then
				for ii,vv in ipairs(chooseArr) do
					if not table.indexof(heroArr, vv) then
						-- 插入的时候才对阵营等赋值，保证插入的信息一定是正确的
						if vv.randomHero then
							local camp = atkData:sta_useWay() or 2
							vv.camp = camp
							local x,y = hero.controler.reFreshControler:turnPosition(camp, 1,2 ,hero.controler.middlePos )
							x = x + (hero.controler.middlePos - x) / 2
							vv.pos.x,vv.pos.y = x,y
						end
						table.insert(heroArr, vv)
					end
				end
			end
		end
	end
	-- local st = GameStatistics:costTimeEnd( "AttackChooseType:getSkillCanAtkEnemy" ,st)
	return  heroArr
end

--确定一个技能标记谁
function AttackChooseType:getSkillAttackSign( hero,skill)
	local lockType = skill:sta_lock()
	lockType = lockType or 1
	--如果已经有集火目标了  那么不需要
	if hero.logical.attackSign then
		return nil
	end
	--如果是没有攻击性行为的
	if lockType == 0 then
		return nil
	end
	local toArr = hero.toArr
	local targetHero = self:findHeroByIndex(lockType,hero.data.gridPos.y,toArr)
	if not targetHero then
		targetHero = self:findFirstYposHero(hero, toArr)
	end

	return targetHero

end

--获取技能应该打人的占位
function AttackChooseType:getSkillCanAttackPos( hero,skill )
	local xChooseArr = skill.xChooseArr
	local yChooseType = skill.yChooseType
	local posIndexArr = {}

	if not skill.isAttackSkill then
		return {}
	end

	local index
	--确定y的选择范围
	local yIndexArr 
	if yChooseType == 0 then
		yIndexArr = {1,2}
	elseif yChooseType == 3 then
		
		yIndexArr = {skill.startYIndex	}
	else
		yIndexArr = {yChooseType}
	end

	--如果是选择多人的 那么不参考startXindex了
	if #xChooseArr == 1 then
		xChooseArr  = {skill.startXIndex}
	else
		
	end

	for i,v in ipairs(xChooseArr) do
		for ii,vv in ipairs(yIndexArr) do
			index = (v-1) * 2 + vv

			table.insert(posIndexArr, index)
		end
	end

	-- dump(xChooseArr,"__xChooseArr")
	-- dump(yIndexArr,"__yIndexArr")
	-- dump(posIndexArr,"__posIndexArr")

	return posIndexArr

end


--返回技能能打到的第一个目标,以及是否是中后排,true表示是中后排 第三个值是返回 技能打到的所有人
function AttackChooseType:getSkillFirstAtkEnemy( hero,skill )

	local firstHero = self:getSkillAttackSign(hero, skill)
	if not firstHero then
		return nil  ,false
	end
	local toArr = hero.toArr
	local isHoupai = false
	if firstHero.data.gridPos.x ~= toArr[1].data.gridPos.x then
		if firstHero.camp ~= hero.camp then
			isHoupai = true
		end
	end

	return firstHero  ,isHoupai
end

--判断一个人能否达到另外一个人  以及是否是集火目标 ,
-- 返回 true true 表示 能打到 而且 这个人是集火目标 
function AttackChooseType:checkSkillCanAtkEnemy( attacker,skill,defender )
	local firstHero,isHoupai = self:getSkillFirstAtkEnemy(attacker,skill)
	local heroArr = self:getSkillCanAtkEnemy(attacker, skill,true)
	local  canAtk = table.indexof(heroArr, defender) and true or false
	local isSign = firstHero == defender
	-- echo(canAtk,isSign,"___________aaaaa,canAtc",firstHero.data.posIndex, defender.data.posIndex,attacker.data.posIndex,#heroArr)
	return  canAtk,isSign
end


--找身前或者身后的人 disXIndex  -1 表示身后 1 表示身前 -2 表示身后2格 2表示身前2个格
function AttackChooseType:findNearHero( hero,disXIndex )
	local campArr = hero.campArr
	local heroGridX = hero.data.gridPos.x
	local heroGridY = hero.data.gridPos.y

	local posIndex = (heroGridX - disXIndex) * 2 + heroGridY - 2

	return self:findHeroByPosIndex(posIndex, campArr)
end

--找身前或者身后一排的人 disXIndex  -1 表示身后 1 表示身前 -2 表示身后2格 2表示身前2个格
function AttackChooseType:findNearHeroGroup( hero,disXIndex )
	local campArr= hero.campArr
	local resultArr = {}
	local heroGridX = hero.data.gridPos.x
	local heroGridY = hero.data.gridPos.y

	local gridXs = {}
	local gridX = nil
	-- 最多身前/后两个
	for i=1,2 do
		gridX = heroGridX - i * disXIndex
		if gridX >= 1 and gridX <= 3 then
			table.insert(gridXs, gridX)
		end
	end

	local posIndex = nil
	for _,gridX in ipairs(gridXs) do
		posIndex = gridX * 2 + heroGridY - 2
		local hero = self:findHeroByPosIndex(posIndex, campArr)
		if hero then
			table.insert(resultArr, hero)
		end
	end

	-- 因为大体型存在需要排重
	resultArr = array.toSet(resultArr)
	
	return  resultArr
end

-- 根据位置返回落在哪个区域
function AttackChooseType:getAreaPosIndex(posArr, posx,posy)
	--记录6个区域
	-- local posArr = gameControler.heroPosArea
	local disY = Fight.initYpos_2- Fight.initYpos_1
	local index  = 0
	--判断落在哪个区域
	for i,v in ipairs(posArr) do
		local dx = v.x - posx 
		local dy = v.y - posy
		if math.abs(dx) < Fight.position_xdistance/2 and math.abs(dy) < disY/2 then
			index = i
			break
		end
	end

	return index
end

-- 打地板的选敌逻辑
function AttackChooseType:atkLatticeChooseByType(attacker, atkData, formationControler, skill)
	-- 直接把所有满足的格子拿进来，没有不存在的情况
	local resultArr = {}

	local xArr = atkData.xChooseArr
	local yType = atkData.yChooseType

	local useWay = atkData:sta_useWay()

	local campArr = formationControler:getLatticeByCamp(useWay == 1 and attacker.camp or attacker.toCamp)

	for _,lattice in ipairs(campArr) do
		local x = math.floor((lattice.data.posIndex - 1)/2) + 1
		local y = (lattice.data.posIndex - 1) % 2 + 1

		local ay = attacker.data.posIndex % 2

		local flag = true
		-- x不符合
		if x < xArr[1] or x > xArr[#xArr] then
			flag = false
		end

		if yType == 0 then

		elseif yType == 3 then
			if ay ~= y then
				flag = false
			end
		elseif yType ~= y then
			flag = false
		end

		if flag then
			table.insert(resultArr, lattice)
		end
	end

	return resultArr
end

return AttackChooseType