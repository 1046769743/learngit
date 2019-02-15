--
-- Author: xd
-- Date: 2016-11-14 16:46:54
--筛选过滤器
--
local globalCfgKey = {
	"hid","area","back","camp","skillState",
	"skillSort","xspe","x","y","sex",
	"pro","round","chance","attrC","numsC",
	"attrS","trigCount","chooseNum","isRandom",
	"buffType","buffKind","priority","followAtk",
	"character","beHit","xp","latticeBuffType"
}

ObjectFilterAi = class("ObjectFilterAi")
ObjectCommon.mapFunction(ObjectFilterAi,globalCfgKey)
--初始化 筛选器
function ObjectFilterAi:ctor(id)
	self.hid = id
	self.__staticData = ObjectCommon.getPrototypeData( "battle.FilterAi",id )
	self.trigCount = self:sta_trigCount() or 1
	--如果配置0 表示无限次触发
	if self.trigCount == 0 then
		self.trigCount = 9999
	end
	--阵营是全阵营
	self.camp = self:sta_camp() or 0
	--性别是全性别
	self.sex = self:sta_sex() or 0
	--职业是全职业
	self.profession = self:sta_pro() or 0
	--判断是级回合
	self.roundCount = self:sta_round() or  0
	--任意情况
	self.chance = self:sta_chance() or 0
	self.area = self:sta_area() or 0
	--人数比较
	self.numCompare = self:sta_numsC()
	--优先级筛选
	self.priority = self:sta_priority()
	if self.numCompare then
		self.numCompare = self.numCompare[1]
	end

	self.attrCompares = self:sta_attrC()
	-- 有优先级的x
	self.xpXChoose = self:sta_xp()

	self.xChooseArr = self:sta_x() or {0}
    if self.xChooseArr[1] == 0 then
    	self.xChooseArr = {1,2,3}
    end
    self.yChooseType = self:sta_y() or 0

end

--开始筛选
function ObjectFilterAi:startChoose(attacker,defender, targetArr ,skill )
	--如果技能配置了动作 但是自身是被控制了,那么就不应该触发
	if skill and skill:sta_action() and not self.heroModel.data:checkCanAttack(true) then
		return false,nil
	end

	local toArr = {}
	local campArr= {}
	--筛选结果数组
	local resultArr = {}
	if self.trigCount == 0 then
		return false, resultArr
	end
	local result = true
	

	--当有人死亡时 那么筛选数组就优先判定为死亡对象了
	if self.chance == Fight.chance_onDied  then
		--必须为同一阵营
		if self.heroModel.camp ~= defender.camp  then
			return
		end
		if defender.reliveState ~= 0 then
			campArr  = {}
			return false,campArr
		else
			campArr =  {defender}
		end
	else
		if targetArr then
			campArr = table.copy(targetArr)
			
		else
			--阵营筛选
			--如果是全阵营的
			if self.camp == 0 then
				campArr = array.merge(attacker.campArr ,attacker.toArr)
			else
				if self.camp ==1  then
					campArr = table.copy(attacker.campArr) 
				else
					campArr = table.copy(attacker.toArr)
				end
			end
		end

		--区域筛选
		if self.area == 1 then
			campArr = {self.heroModel}
		--如果是指定进攻着
		elseif self.area == 2 then
			campArr = attacker and {attacker} or {}
		--如果是非自己
		elseif self.area == 3 then
			table.removebyvalue(campArr, self.heroModel)
		--如果是排除进攻过的人
		elseif self.area == 4 then
			local length = #campArr
			for i=length,1,-1 do
				local hero = campArr[i]
				--如果已经攻击过
				if hero:hasAttacked() then
					table.remove(campArr,i)
				end
			end
		--5是指定传递进来的人
		elseif self.area == 5 then
			if defender then
				campArr = {defender}
			end

		--6 是排除被我攻击过的人
		elseif self.area == 6 then
			local length = #campArr
			for i=length,1,-1 do
				local toHero = campArr[i]
				--如果是有技能伤害的
				if toHero:getSkillDamage(attacker,skill) then
					table.remove(campArr,i)
				end
			end


		--7 选择我打过的人
		elseif self.area == 7 then
			local newArr = {}
			local length = #campArr
			for i=length,1,-1 do
				local toHero = campArr[i]
				--如果是有技能伤害的
				if toHero:getSkillDamage(attacker,skill) then
					table.insert(newArr, toHero)
				end
			end

			campArr = newArr
		elseif self.area == 8 then
			local rid = self.heroModel:getLastAttackerRid()
			if rid then
				for i=#campArr,1,-1 do
					local toHero = campArr[i]
					if toHero.data.rid == rid and toHero.data:hp() > 0 then
						campArr = {toHero}
						break
					end
				end
			end
		-- -- 只选主角
		-- elseif self.area == 8 then
		-- 	local newArr = {}
		-- 	for i=#campArr,1,-1 do
		-- 		local toHero = campArr[i]
		-- 		if toHero.data.isCharacter then
		-- 			table.insert(newArr, toHero)
		-- 		end
		-- 	end
		-- 	campArr = newArr
		end

		--xspe筛选选
		campArr = self:checkXSpc(campArr, defender)
	end
	-- 过滤不能被选中的人
	campArr = self:arrayFilter(campArr)

	--对自己身上记录的信息进行筛选
	campArr = self:followAtk(campArr, attacker, skill)

	--对技能状态进行筛选
	campArr = self:checkSkillState(campArr)


	--对人数进行 初步筛选
	campArr = self:chooseOneCampArr(campArr,attacker)
	local tempArr = {}
	--遍历满足属性比较的数组
	for i,v in ipairs(campArr) do
		if self:compareAttr(defender, v) then
			table.insert(tempArr, v)
		end
	end
	-- 赋值
	campArr = tempArr
	--筛选buffKind
	campArr = self:chooseBuffKind(campArr)
	--筛选buffType
	campArr = self:chooseBuffType(campArr)
	--筛选主角/伙伴
	campArr = self:chooseByCharacter(campArr)
	--筛选本回合受击情况
	campArr = self:chooseByHited(campArr)
	--筛选有优先级的x
	campArr = self:chooseByXpX(campArr)
	-- 预处理格子
	self:preprocessLatticeBT(attacker, attacker.controler)
	--筛选lattice
	campArr = self:chooseLatticeBuffType(campArr)

	--按照优先级选择
	if self.priority then
		campArr = self:choosePriority(campArr, defender)
	else
		--随机多少个人
		if self:sta_isRandom() then
			campArr = self:randomResultArr(self:sta_isRandom(),campArr)
		end
	end

	-- 兼容以前的逻辑把这个选择调到上面的else里面
	--随机多少个人
	-- if self:sta_isRandom() then
	-- 	resultArr = self:randomResultArr(self:sta_isRandom(),resultArr)
	-- end

	
	--如果有人数比较的
	if self.numCompare then
		--如果是和敌方比较人数 那么重新比较人数
		if self.numCompare.num == 0 then
			campArr = self:chooseOneCampArr(self.heroModel.campArr,self.heroModel)
			toArr = self:chooseOneCampArr(self.heroModel.toArr,self.heroModel)
			result = self:checkCompare( #campArr,#toArr,self.numCompare.compare )
			resultArr = self:cutChooseNums(self:sta_chooseNum(),campArr)
		else
			result = self:checkCompare( #campArr,self.numCompare.num,self.numCompare.compare )
			resultArr = self:cutChooseNums(self:sta_chooseNum(),campArr)
		end
	else
		--截取人数
		resultArr = self:cutChooseNums(self:sta_chooseNum(),campArr)
	end


	if #resultArr == 0 then
		return false ,resultArr
	end

	--如果技能是带召唤的,那么还附带特殊判定条件
	if skill and skill.hasSummonInfo then
		if not self:checkSkillSummon(skill) then
			return false, resultArr
		end
	end

	--如果满足结果判定了 那么减少一次筛选次数 直到不能筛选了
	if result then
		self.trigCount = self.trigCount - 1
	end


	--那么直接返回true
	return result, resultArr

end
--[[
	过滤不能被选中的人（傀儡）
]]
function ObjectFilterAi:arrayFilter( campArr )
	local resultArr = {}
	for _,hero in ipairs(campArr) do
		if not hero:hasNotAliveBuff() then
			table.insert(resultArr, hero)
		end
	end

	return resultArr
end

--[[
	检查自己记录的伤害信息
]]
function ObjectFilterAi:followAtk( campArr, attacker, skill )
	if not self:sta_followAtk() then
		return campArr
	end

	local atkId = self:sta_followAtk()
	local result = {}

	for _,defender in ipairs(campArr) do
		local dmgInfo = attacker:getRecordDmgInfo(defender, skill)
		if dmgInfo then
			-- 查找攻击包
			if dmgInfo.atkDatas[atkId] then
				table.insert(result, defender)
			end
			-- for _,atkData in ipairs(dmgInfo.atkDatas) do
			-- 	if atkData.hid == atkId then
			-- 		table.insert(result, defender)
			-- 		break
			-- 	end
			-- end
		end
	end

	return result
end
--[[
	有优先级的x选择 1;2;3;表示优先1再2再3
]]
function ObjectFilterAi:chooseByXpX( campArr)
	if not self:sta_xp() then
		return campArr
	end

	-- 按排分类
	local tempT = {}
	for i =1,#campArr do
		local hero = campArr[i]
		local pos = math.floor((hero.data.posIndex - 1) / 2) + 1
		if not tempT[pos] then tempT[pos] = {} end
		table.insert(tempT[pos], hero)
	end
	
	local result = {}
	-- 从前到后筛选
	for _,pos in ipairs(self.xpXChoose) do
		if tempT[pos] then
			result = tempT[pos]
			break
		end
	end

	return result
end
--[[
	检查x方向
]]
function ObjectFilterAi:chkXpos(hero, noPriority)
	if not noPriority and self:chkHasPriority("x") then return true end

	local xArr = self.xChooseArr
	if hero.data.gridPos.x < xArr[1] or hero.data.gridPos.x > xArr[#xArr] then
		return false
	end
	-- 老代码，不对，先注掉
	-- if hero.data:isBigger() then
	-- 	return true
	-- end
	return true
end
--[[
	检查y方向
]]
function ObjectFilterAi:chkYpos(hero, noPriority)
	if not noPriority and self:chkHasPriority("y") then return true end

	local yType = self.yChooseType
	local attacker = self.heroModel

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
--[[
	身份筛选，主角还是伙伴
	@@noPriority 是否不考虑优先级
]]
function ObjectFilterAi:chkCharacter( hero )
	if not self:sta_character() then return true end

	local needChar = self:sta_character() == 1

	local flag = hero.data.isCharacter == true
	if not needChar then
		flag = not flag
	end

	return flag
end
function ObjectFilterAi:chooseByCharacter( campArr,noPriority )
	if not self:sta_character() then
		return campArr
	end

	if not noPriority and self:chkHasPriority("character") then return campArr end

	-- 筛选
	local result = {}
	for i=1,#campArr do
		local hero = campArr[i]
		if self:chkCharacter(hero) then
			table.insert(result, hero)
		end
	end

	return result
end

--[[
	受击情况筛选，本回合是否被攻击过
	@@noPriority 是否不考虑优先级
]]
function ObjectFilterAi:chkHitedNowRound( hero )
	-- echo("beHit",self:sta_beHit())
	if not self:sta_beHit() then return true end

	local needBeHit = self:sta_beHit() == 1

	local controler = hero.controler
	local wave = controler.__currentWave or 1
	local round = controler.logical.roundCount
	local dmgInfo = StatisticsControler:getDamageInfo(wave, round, hero)

	local flag = false

	-- echo("受到过伤害没有",needBeHit,hero.data.posIndex, dmgInfo == nil)

	if needBeHit then
		-- 受过伤害
		flag = (dmgInfo ~= nil and dmgInfo.hurt ~= nil and dmgInfo.hurt > 0)
	else
		-- 没受过伤害
		flag = (dmgInfo == nil or (dmgInfo and dmgInfo.hurt == 0))
	end


	return flag
end
function ObjectFilterAi:chooseByHited( campArr,noPriority )
	if not self:sta_beHit() then
		return campArr
	end

	if not noPriority and self:chkHasPriority("beHit") then return campArr end

	-- 筛选
	local result = {}
	for i=1,#campArr do
		local hero = campArr[i]
		if self:chkHitedNowRound(hero) then
			table.insert(result, hero)
		end
	end

	return result
end
--[[
	buffKind筛选
	@@noPriority 是否不考虑优先级
]]
function ObjectFilterAi:chkBuffKind( hero )
	for k,v in ipairs(self:sta_buffKind()) do
		local flag = hero.data:checkHasKindBuff(v.value)
		-- 1为满足次条件0为相反
		if v.type == 0 then flag = not flag end

		if not flag then return false end
	end

	return true
end
function ObjectFilterAi:chooseBuffKind( campArr,noPriority )
	if not self:sta_buffKind() then
		return campArr
	end

	if not noPriority and self:chkHasPriority("buffKind") then return campArr end

	-- 筛选
	local result = {}
	for i=1,#campArr do
		local hero = campArr[i]
		if self:chkBuffKind(hero) then
			table.insert(result, hero)
		end
	end

	return result
end

--[[
	latticeBuffType预处理
]]
function ObjectFilterAi:preprocessLatticeBT(attacker, controler)
	self.vaildLattice = nil

	if not self:sta_latticeBuffType() then return end
	if self.camp == 0 then return end
	
	local camp = self.camp == 1 and attacker.camp or attacker.toCamp

	self.vaildLattice = {}

	local campArr = controler.formationControler:getLatticeByCamp(camp)

	for _,lattice in ipairs(campArr) do
		if self:chkLatticeBuffType(lattice) then
			table.insert(self.vaildLattice, lattice)
		end
	end
end

-- 判断格子是否满足
function ObjectFilterAi:chkLatticeBuffType(lattice)
	-- 组合类型 1且 0或
	local combineType = self:sta_latticeBuffType()[1].combineType

	if combineType == 1 then
		for k,v in ipairs(self:sta_latticeBuffType()) do
			local flag = lattice:checkHasOneBuffType(v.value)
			-- 1为满足次条件0为相反
			if v.type == 0 then flag = not flag end

			if not flag then return false end
		end

		return true
	else
		for k,v in ipairs(self:sta_latticeBuffType()) do
			local flag = lattice:checkHasOneBuffType(v.value)
			-- 1为满足次条件0为相反
			if v.type == 0 then flag = not flag end

			if flag then return true end
		end

		return false
	end
end

-- 判断hero是否满足格子条件
function ObjectFilterAi:chkHeroLattice(hero)
	if not self:sta_latticeBuffType() then return true end
	
	if empty(self.vaildLattice) then return false end

	for _,lattice in ipairs(self.vaildLattice) do
		if hero.camp == lattice.camp and hero.data.posIndex == lattice.data.posIndex then
			return true
		end
	end

	return false
end
-- 根据格子筛选
function ObjectFilterAi:chooseLatticeBuffType(campArr, noPriority)
	if not self:sta_latticeBuffType() then
		return campArr
	end

	if not noPriority and self:chkHasPriority("latticeBuffType") then return campArr end

	-- 筛选
	local result = {}
	for i=1,#campArr do
		local hero = campArr[i]
		if self:chkHeroLattice(hero) then
			table.insert(result, hero)
		end
	end

	return result
end
--[[
	buffType筛选
	@@noPriority 是否不考虑优先级
]]
function ObjectFilterAi:chkBuffType( hero )
	-- 组合类型 1且 0或
	local combineType = self:sta_buffType()[1].combineType

	if combineType == 1 then
		for k,v in ipairs(self:sta_buffType()) do
			local flag = hero.data:checkHasOneBuffType(v.value)
			-- 1为满足次条件0为相反
			if v.type == 0 then flag = not flag end

			if not flag then return false end
		end

		return true
	else
		for k,v in ipairs(self:sta_buffType()) do
			local flag = hero.data:checkHasOneBuffType(v.value)
			-- 1为满足次条件0为相反
			if v.type == 0 then flag = not flag end

			if flag then return true end
		end

		return false
	end
end
function ObjectFilterAi:chooseBuffType( campArr,noPriority )
	if not self:sta_buffType() then
		return campArr
	end

	if not noPriority and self:chkHasPriority("buffType") then return campArr end

	-- 筛选
	local result = {}
	for i=1,#campArr do
		local hero = campArr[i]
		if self:chkBuffType(hero) then
			table.insert(result, hero)
		end
	end

	return result
end
--[[
	按照优先级选择
]]
function ObjectFilterAi:choosePriority( campArr, defender )
	--[[
		分人
		把满足高优先级的分到前面的组里会被优先选到
	]]
	local funcMap = {
		sex = c_func(self.checkSex, self, self.sex), -- 检查性别
		pro = c_func(self.checkProfession, self, self.profession), -- 检查职业
		attrC = c_func(self.compareAttr, self, defender), -- 属性比较
		buffKind = c_func(self.chkBuffKind, self), -- 检查buff类型
		buffType = c_func(self.chkBuffType, self), -- 检查buff具体种类
		character = c_func(self.chkCharacter, self), -- 主角/伙伴
		beHit = c_func(self.chkHitedNowRound, self), -- 回合受击情况
		x = c_func(self.chkXpos, self), -- x位置检查
		y = c_func(self.chkYpos, self), -- y位置检查
		latticeBuffType = c_func(self.chkHeroLattice, self), -- 格子选择检查
	}

	-- 存放人物满足的最高优先级,用于随机时用
	local pTable = {}

	-- 根据优先级排序
	local function sortFunc( a, b )
		for j=1,#self.priority do
			local key = self.priority[j]
			local rst1 = funcMap[key](a, true)
			local rst2 = funcMap[key](b, true)
			if rst1 then
				-- 目前从语义来看这里应该是 pTable[a] > j 以前 pTable[a] < j 可能写错了，先更正过来看情况
				if not pTable[a] or pTable[a] > j then
					pTable[a] = j
				end
			end
			if rst2 then
				if not pTable[b] or pTable[b] > j then
					pTable[b] = j
				end
			end
			-- 都符合或都不符合
			if rst1 == rst2 then
			else
				if rst1 and not rst2 then
					return true
				end
				if rst2 and not rst1 then
					return false
				end
			end
		end

		-- 通过优先级没有比较出来按位置比
		return a.data.posIndex < b.data.posIndex
	end

	table.sort(campArr, sortFunc)

	local result = {}
	local priorityNums = #self.priority
	for i=1,priorityNums + 1 do -- 初始化结果储存表
		result[i] = {}
	end
	-- echo("=========",priorityNums)
	-- dump(self.priority)

	-- 如果有随机
	if self:sta_isRandom() then
		local chooseNum = self:sta_chooseNum() or 12
		if chooseNum == -1 then chooseNum = 12 end
		if chooseNum >= #campArr then
			-- 不用随机了，所有人都会被选中
		else
			local count = 0
			local pre = nil
			for i,hero in ipairs(campArr) do
				local hPri = pTable[hero] or priorityNums + 1
				if pre ~= hPri then
					pre = hPri
					count = count + 1 
				end
				table.insert(result[count], hero)
			end

			for i=1,#result do
				result[i] = self:randomResultArr(true, result[i])
			end

			campArr = array.merge(unpack(result))
		end
	end

	return campArr
end

--[[
	获取某列名是否配置了按照优先级筛选
]]
function ObjectFilterAi:chkHasPriority( name )
	if not self.priority then return false end

	return array.isExistInArray(self.priority, name)
end

--[[
相对位置筛选
]]
function ObjectFilterAi:checkXSpc( campArr,defender )
	if not self:sta_xspe()  then
		return campArr
	end
	local resultArr = {}
	local xspe = self:sta_xspe()
	if xspe == 1 or xspe == 8 then
		--和目标同排
		local posIndex = self.heroModel.data.posIndex 
		local targetIndex
		if posIndex%2 ==0 then
			targetIndex = posIndex-1
		else
			targetIndex = posIndex+1
		end
		local hero =  AttackChooseType:findHeroByPosIndex( targetIndex,campArr )
		-- 这种选敌情况应该首先排除自己
		if hero ~= nil and hero ~= self.heroModel then
			table.insert(resultArr, hero)
		end

		if xspe == 8 then
			table.insert(resultArr, self.heroModel)
		end
	elseif xspe == 2 or xspe == 9 then
		local posIndex = self.heroModel.data.posIndex 
		--和目标同列
		for pos=1,6 do
			-- 此时应当先排除自己
			if pos ~= posIndex and pos % 2 == posIndex % 2 then
				local hero = AttackChooseType:findHeroByPosIndex( pos,campArr ) 
				if hero ~= nil then
					table.insert(resultArr,hero)
				end
			end
		end

		if xspe == 9 then
			table.insert(resultArr, self.heroModel)
		end
	elseif xspe == 3  then
		--溅射 目标上下左右
		local posIndex = self.heroModel.data.posIndex
		local line = math.floor((posIndex - 1)/2)

		-- 修改按位置招人，不然无法选中虚占位置的大体型怪
		for pos=1,6 do
			-- 不含自己
			if math.abs(pos - posIndex) == 2 or math.floor((pos - 1)/2) == line then
				local hero = AttackChooseType:findHeroByPosIndex( pos,campArr )
				if hero ~= nil and hero ~= self.heroModel then
					table.insert(resultArr, hero)
				end
			end
		end
	elseif xspe == 10 then -- 目标周围，含目标
		if defender then
			--溅射 目标上下左右
			local posIndex = defender.data.posIndex
			local line = math.floor((posIndex - 1)/2)

			-- 修改按位置招人，不然无法选中虚占位置的大体型怪
			for pos=1,6 do
				-- 含自己
				if (math.abs(pos - posIndex) == 2 or math.floor((pos - 1)/2) == line) then
					local hero = AttackChooseType:findHeroByPosIndex( pos,campArr )
					-- 先不含自己最后再插入自己 防止找到多个自己（大体型）
					if hero ~= nil and hero ~= defender then
						table.insert(resultArr, hero)
					end
				end
			end

			table.insert(resultArr, defender)
		end
	elseif xspe == 4 then
		--目标身后
		local posIndex = self.heroModel.data.posIndex

		local hero = AttackChooseType:findNearHero( self.heroModel,-1 )
		-- 自己身后不应该有自己（方法选出来的本来就不含自己）
		if hero ~= nil then
			table.insert(resultArr,hero)
		end
	elseif xspe == 5 then
		--目标身后一排
		local posIndex = self.heroModel.data.posIndex
		resultArr = AttackChooseType:findNearHeroGroup( self.heroModel,-1 )
		
	elseif  xspe == 6 then
		--目标身前
		local hero = AttackChooseType:findNearHero( self.heroModel,1 )
		if hero ~= nil then
			table.insert(resultArr,hero)
		end
	elseif  xspe == 7 then
		--目标身前一排
		local posIndex = self.heroModel.data.posIndex
		resultArr = AttackChooseType:findNearHeroGroup( self.heroModel,1 )
	end
	return resultArr
end



--技能条件筛选
function ObjectFilterAi:checkSkillState( campArr )
	local skillState = self:sta_skillState()
	local length = #campArr
	if skillState == 0 or not skillState then
		return campArr
	--如果是伤害技
	elseif skillState == 1 then
		for i=length,1,-1 do
			local hero = campArr[i]
			local skill = hero:getNextSkill()
			--如果不是攻击技能
			if not skill.isAttackSkill then
				table.remove(campArr,i)
			end
		end
	--如果是辅助技能
	elseif skillState == 2 then
		for i=length,1,-1 do
			local hero = campArr[i]
			local skill = hero:getNextSkill()
			--移除掉伤害技
			if  skill.isAttackSkill then
				table.remove(campArr,i)
			end
		end
	end
	return campArr

end


--判断技能召唤条件是否满足
function ObjectFilterAi:checkSkillSummon( skill )
	local atkInfos = skill.attackInfos
	local logical = skill.heroModel.logical

	--必须是boss才触发召唤
	if self.heroModel.data:boss() ~= 1 then
		return false
	end

	for i,v in ipairs(atkInfos) do
		local atkData = v[3]
		local summonInfo = atkData:sta_summon()
		--判断指定位置上是否有人,如果没有人 直接判定为true
		if summonInfo then
			for kk,vv in pairs(summonInfo) do
				if not logical:findHeroModel(skill.heroModel.camp,vv.pos) then
					return true
				end
			end
		end
	end
	return false
end



--截取人数
function ObjectFilterAi:cutChooseNums(chooseNum,campArr  )
	chooseNum = chooseNum or 12 
	if chooseNum == -1 then
		chooseNum = 12
	end

	--在来排序
	local sortKey = self:sta_attrS()
	if sortKey then
		self:sortProp(campArr)
	end

	campArr = self:sortSkillState(campArr)

	local resultArr = {}
	for i=1,chooseNum do
		if campArr[i] then
			table.insert(resultArr,campArr[i])
		end
	end
	
	return resultArr
end

--[[
	对结果进行乱序排列
]]
function ObjectFilterAi:randomResultArr(isRandom,resultArr)
	isRandom = isRandom  or false
	if isRandom then
		resultArr = BattleRandomControl.randomOneGroupArr(resultArr)
	end
	return resultArr
end


--选取对应的人数
function ObjectFilterAi:chooseOneCampArr( campArr,attacker )
	local resultArr = {}

	for i,v in ipairs(campArr) do
		--判断性别 坐标
		if self:checkSex(self.sex, v) and self:checkPos(self.xChooseArr, self.yChooseType, attacker, v)  
			and self:checkProfession(self.profession,v) 
		then
			table.insert(resultArr, v)
		end
	end
	--返回resultArr
	return resultArr

end

--判断职业@@noPriority 是否不考虑优先级
function ObjectFilterAi:checkProfession( profession,hero,noPriority )
	if not noPriority and self:chkHasPriority("pro") then return true end
	--暂时判定正确
	if profession == 0 then
		return true
	end
	-- return profession == hero.data:profession()
	-- 2017.08.09 pangkangning  修改获取角色职业
	return profession == hero:getHeroProfession()
end


--判断位置是否正确
function ObjectFilterAi:checkPos(xArr,yType,attacker, hero )
	return self:chkXpos(hero) and self:chkYpos(hero)
end


--判断性别@@priority 是否 不考虑优先级
function ObjectFilterAi:checkSex( sex,hero,noPriority )
	-- echo("noPriority", noPriority, "chkSex", self:chkHasPriority("sex"))
	if not noPriority and self:chkHasPriority("sex") then return true end

	if sex ==0 then
		return true
	end

	return hero.data:getCurrTreasureSex() == sex
end

--对筛选结果排序
function ObjectFilterAi:soreResultArr( resultArr )
	-- skillSort 先是技能筛选排序


end


--技能排序
function ObjectFilterAi:sortSkillState( resultArr )
	local skillSort = self:sta_skillSort()
	if skillSort == 0 or not skillSort then
		return resultArr
	--如果是全体随机
	elseif skillSort == 3 then
		-- resultArr = BattleRandomControl.randomOneGroupArr(resultArr )
		-- return resultArr
	end
	
	local aoeGroup = {}
	local oneGroup = {}
	local noAtkGroup = {}
	for i,v in ipairs(resultArr) do
		if skillSort == 3 then
			if v.data:checkCanAttack()  then
				table.insert(aoeGroup, v)
			else
				table.insert(noAtkGroup, v)
			end
		else
			local skill = v:getNextSkill()
			local atkNums = skill:getAtkNums() 
			--优先选择能攻击的
			if  v.data:checkCanAttack() then
				if atkNums > 1 then
					table.insert(aoeGroup, v)
				elseif atkNums == 1 then
					table.insert(oneGroup, v)
				else
					table.insert(noAtkGroup, v)
				end
			else
				table.insert(noAtkGroup, v)
			end
		end
		
		
	end

	aoeGroup =BattleRandomControl.randomOneGroupArr(aoeGroup )
	oneGroup =BattleRandomControl.randomOneGroupArr(oneGroup )
	noAtkGroup =BattleRandomControl.randomOneGroupArr(noAtkGroup )


	

	--如果是优先选aoe的
	if skillSort == 1 then
		resultArr = array.merge(aoeGroup,oneGroup,noAtkGroup)
	--优先选单体的
	elseif skillSort == 2 then
		resultArr = array.merge(oneGroup,aoeGroup,noAtkGroup)
	elseif skillSort == 3 then
		resultArr = array.merge(oneGroup,aoeGroup,noAtkGroup)
	end
	return  resultArr

end


--排列属性
function ObjectFilterAi:sortProp( campArr )
	local sortKey = self:sta_attrS()
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


--比较属性@@noPriority 是否不考虑优先级
function ObjectFilterAi:compareAttr( defender,attacker,noPriority )
	if not noPriority and self:chkHasPriority("attrC") then return true end
	--如果是有属性比较的
	local result
	if self.attrCompares then
		for i,v in ipairs(self.attrCompares) do
			--如果是和防守方比较
			--比较属性 
			local value1 = attacker.data:getAttrByKey(v.key)
			local value2 = v.value
			if v.value == 0 then
				--如果没有防守方  那么返回空
				if not defender then
					return false
				end
				value2 = defender.data:getAttrByKey(v.key)
				--必须所有的 比较条件都满足才行
				result = self:checkCompare(value1,value2,v.compare)
				if not result then
					return false
				end
			else
				--如果是按比例比较
				if v.valueT == Fight.valueChangeType_ratio  then
					local value1 = attacker.data:getAttrPercent(v.key)* 100
					result = self:checkCompare(value1,value2,v.compare)
					-- echo(value1,value2,v.compare,"___比例比较属性",attacker.data.posIndex,attacker.camp)
					if not result then
						return false
					end
				--按固定数值比较
				elseif v.valueT == Fight.valueChangeType_num  then
					result = self:checkCompare(value1,value2,v.compare)
					if not result then
						return false
					end
				end
			end
		end
	end
	return true
end


--判断是否触发
function ObjectFilterAi:checkCanTrigger( roundCount,chance )
	local turnRound = math.ceil(roundCount/2)

	if self.trigCount == 0 then
		return false
	end

	--如果回合数不符合
	-- echo(self.roundCount,roundCount, self.chance, chance)
	if self.roundCount ~= 0 and self.roundCount > turnRound then
		return false
	end

	if self.chance ~= 0 and self.chance ~= chance  then
		return false
	end
	--回合数 和 chance 都满足了 就可以进行下一步筛选了
	return true

end

--判断比较 true 返回成  false 返回比较失败
--1大于,2大于等于,3等于,4小于等于,5小于)
function ObjectFilterAi:checkCompare( value1,value2,compareType )
	if compareType == 1 then
		return  value1 > value2
	elseif compareType == 2 then
		return  value1 >= value2
	elseif compareType == 3 then
		return  value1 == value2
	elseif compareType == 4 then
		return  value1 <= value2
	elseif compareType == 5 then
		return  value1 < value2
	else
		echoError("找策划,错误的比较模式:",compareType,"filterhid",self.hid)
		return false
	end

end

--判断是否具备随机性
function ObjectFilterAi:checkHasRandom(  )
	--如果有技能筛选随机排序的
	if self:sta_skillSort()  and self:sta_skillSort() ~= 0 then
		return true
		
	elseif self:sta_isRandom() and self:sta_isRandom()> 0 then
		return true 
	end
	return false
end