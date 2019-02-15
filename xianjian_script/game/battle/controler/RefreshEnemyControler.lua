local Fight = Fight
-- local BattleControler = BattleControler

RefreshEnemyControler = class("RefreshEnemyControler")

function RefreshEnemyControler:ctor(controler)
	self._refreshIndex = 0 -- --保证刷怪唯一性
	self._waveIdx = 1 --Fight.refresh_wave 刷怪方式时刷的波
	self.controler = controler
end

--创建一个英雄 第几号位
--noMove表示不需要处理移动（只有初始化人物的时候会传）
function RefreshEnemyControler:createHeroes(objData, camp,posIndex,enterType,noMove)
	enterType = enterType or Fight.enterType_stand

	local trailType = BattleControler:checkIsTrail()
	local hero 
	if camp == 2 then
		hero = ModelEnemy.new(self.controler,objData)
	else
		if trailType ~= Fight.not_trail then
			hero = ModelTrialHero.new(self.controler,objData)
		else
			hero = ModelHero.new(self.controler,objData)
		end
	end
	if BattleControler:checkIsPVP() then
		-- 竞技场初始化的时候、双方血量增加
		local addHp = hero.data:maxhp() * Fight.pvp_init_hp_add/100
		hero.data:changeValue(Fight.value_maxhp, addHp)
		hero.data:changeValue(Fight.value_health, addHp)
	elseif BattleControler:checkIsCrossPeak() then
		-- 竞技场初始化的时候、双方血量增加
		local addHp = hero.data:maxhp() * Fight.crosspeak_init_hp_add/100
		hero.data:changeValue(Fight.value_maxhp, addHp)
		hero.data:changeValue(Fight.value_health, addHp)
	end
	--记录初始坐标
	--计算坐标
	local  middlePos = self.controler.middlePos
	
	local x,y = self:turnPosition(camp,posIndex,objData:figure(),middlePos)
	hero:setInitPos({x=x,y=y,z=0})

	if not Fight.isDummy then
		local view = ViewSpine.new(hero.data.curSpbName,nil,nil,hero.data.curArmature,nil,hero.data.sourceData) -- defArmature curArmature
		hero:initView(self.controler.layer.a122,view)
		
		local inAction = hero.data.sourceData.inAction
		-- 配置的方式与资源不符
		if not inAction and 
			(enterType == Fight.enterType_inAction or enterType == Fight.enterType_summon)
		then
			echoError("配置的入场类型:%s,却没有动作inAction",enterType)
			enterType = Fight.enterType_stand
		end

		-- 锁妖塔偷袭没有办法从表中判断
		if self.controler:isTowerTouxi() then
			enterType = Fight.enterType_stand
		end

		if enterType == Fight.enterType_runIn then
			local moveDis = 300
			local moveComplete = "standAction"

			if camp == Fight.camp_2 and BattleControler:getBattleLabel() == GameVars.battleLabels.missionMonkeyPve then
				moveDis = 500
				moveComplete = "onRefreshMoveComplete"
			end

			if camp == Fight.camp_2 then
				hero:setPos(x + moveDis ,y,0)
			else
				hero:setPos(x - moveDis ,y,0)
			end

			hero:setCamp(camp,true)
			if not noMove then
				local posParams = {x= x,y = y,speed = Fight.enterSpeed,call = {moveComplete}}
				hero:justFrame(Fight.actions.action_run)
				hero:moveToPoint(posParams)
			end
		-- 开场入场动作（这里需要分拨入场）
		elseif enterType == Fight.enterType_inAction then
			-- 由于涉及到时间计算等内容，所以此处不做入场动作，外面自己处理了
			hero:setPos(x,y,0)
			hero:setCamp(camp,true)
			hero:setOpacity(0)
		elseif enterType == Fight.enterType_summon then
			--那么直接跳转到 入场动作
			hero:setPos(x,y,0)
			hero:setCamp(camp,true)
			hero:justFrame(Fight.actions.action_inAction)
		elseif enterType == Fight.enterType_gate then
			local tmpX,tmpY = self:turnPosition(camp,5,2,middlePos) --获取传送门位置
			hero:setPos(tmpX ,tmpY,0)
			hero:setCamp(camp,true)
			local posParams = {x= x,y = y,speed = Fight.enterSpeed,call = {"standAction"} }
			hero:justFrame(Fight.actions.action_run )
			hero:moveToPoint(posParams)
		else -- Fight.enterType_stand 或其他
			--那么直接跳转到 入场动作
			hero:setPos(x,y,0)
			hero:setCamp(camp,true)
		end
	else
		hero:setCamp(camp, true)
	end

	hero.data:setHeroModel(hero)

	self.controler:insertOneObject(hero)

	hero:onInitComplete()
	return hero
end

-- nothero 不是为战斗人物获取位置
function RefreshEnemyControler:turnPosition( camp,posIndex,figure,middlePos, notHero)
	figure = figure or 1
	
	local xIndex = math.ceil( posIndex /2 )
	local yIndex = posIndex %2 
	if yIndex == 0 then
		yIndex = 2
	end
	local way = camp == 1 and 1 or -1
	

	local xjiange = Fight.position_xdistance
	--离中线的距离
	local middleDistance = Fight.position_middleDistance
	local offsetPos = Fight.position_offset

	local xpos
	local ypos
	if yIndex == 1 then
		xpos = middlePos - (middleDistance + xjiange*(xIndex -1) ) * way
		ypos = Fight.initYpos_1
	else
		xpos = middlePos - ( middleDistance +offsetPos + xjiange*(xIndex -1) ) * way
		ypos = Fight.initYpos_2
	end

	--还得左下体形修正
	xpos = xpos + (math.ceil( figure/2 ) -1) * xjiange/2 * -way
	--如果体型大于1
	if figure > 1 then
		if yIndex ~= 1 then
			echoWarn("有大体型怪的时候 yIndex 必须是1,检查关卡配置")
		end
		ypos = Fight.initYpos_3
		if not notHero then
			xpos = xpos - (offsetPos / 2) * way
		end
	end

	return xpos,ypos
end


--布局一方 enterType 入场方式
function RefreshEnemyControler:distributionOneCamp( datas,camp,wave ,enterType,withFrame,callFunc)

	local onCreateEnd = function(  )
		self.controler.logical:sortCampPos(camp)
		if callFunc then
			callFunc()
		end
	end

	if Fight.isDummy or (not withFrame) then
		if datas and #datas>0 then
			for i,v in ipairs(datas) do
				local objHero = ObjectHero.new(v.hid,v)
				self:createHeroes(objHero,camp,v.posIndex,enterType,camp == Fight.camp_1) -- 阵营1不处理移动
			end
			
		end
		--每次布局以后进行顺序刷新 这个很重要 对后面的逻辑遍历提高很大效率
		onCreateEnd()
	else -- 现在的逻辑这种分帧创建方式根本就不能用了2018.3.23
		local createHero = function (data, enterType )
			local objHero = ObjectHero.new(data.hid,data)
			self:createHeroes(objHero,camp,data.posIndex,enterType,camp == Fight.camp_1)
		end

		if datas and #datas>0 then
			--分帧创建主角
			for i,v in ipairs(datas) do
				self.controler:pushOneCallFunc(i-1, createHero, {v,enterType})
			end
		end
	end
	
end

-- 获取刷怪对应的attr
function RefreshEnemyControler:getRefreshEnemyAttr()
	local refreshAi = self.controler.levelInfo:getRefreshAi()
	local index,heroArr = 1,nil
	local _getHeroArr = function( arr,index )
		local heroArr = arr[index]
		if heroArr and refreshAi.isLoop == 0 then
			table.remove(arr,index)
		end
		return heroArr
	end
	if refreshAi.type == Fight.refresh_sequence then
		heroArr = _getHeroArr(refreshAi.enemyArr,index)
	elseif refreshAi.type == Fight.refresh_random then
		index = BattleRandomControl.getOneRandomInt(#refreshAi.enemyArr +1,1)
		heroArr = _getHeroArr(refreshAi.enemyArr,index)
	elseif refreshAi.type == Fight.refresh_wave then
		if #refreshAi.enemyArr >= self._waveIdx then
			heroArr = _getHeroArr(refreshAi.enemyArr[self._waveIdx],index)
		end
	end
	return heroArr
end
-- 刷怪ai是否计入结算
function RefreshEnemyControler:checkIsFinish(  )
	local refreshAi = self.controler.levelInfo:getRefreshAi()
	if refreshAi.isFinish and refreshAi.isFinish == 0 then
		return true
	end
	return false
end
-- 获取还有几个可刷新的怪物
function RefreshEnemyControler:getRefreshCount( )
	local refreshAi = self.controler.levelInfo:getRefreshAi()
	if refreshAi.type == Fight.refresh_wave then
		if #refreshAi.enemyArr >= self._waveIdx then
			return table.length(refreshAi.enemyArr[self._waveIdx])
		end
		return 0
	end
	return #refreshAi.enemyArr
end
-- 获取刷怪的数据
function RefreshEnemyControler:getRefreshArr( )
	local refreshAi = self.controler.levelInfo:getRefreshAi()
	if #refreshAi.enemyArr > 0 then
		if refreshAi.type == Fight.refresh_wave then
			if #refreshAi.enemyArr >= self._waveIdx then
				return refreshAi.enemyArr[self._waveIdx]
			end
		else
			return refreshAi.enemyArr
		end
	end
	return {}
end

-- 获取车轮战要刷的怪的体型（1、2、4、6），
function RefreshEnemyControler:getNextRefreshFigure( )
    if self.controler.levelInfo:chkIsRefreshType() then
		local refreshAi = self.controler.levelInfo:getRefreshAi()
		if refreshAi.type == Fight.refresh_sequence and #refreshAi.enemyArr > 0 then
			return refreshAi.enemyArr[1].figure
		end
		return 1
	else
		return 1
	end
end

--[[
序章刷新主角
]]
function RefreshEnemyControler:XvZhangRefreshZhujue()
	if self.controler:chkIsXvZhang() then
		local sex = FuncChar.getCharSex(LoginControler:getLocalRoleId())
		
		local camp = Fight.camp_1
		local objHero = sex == 1 and self.controler.levelInfo.xuzhangshuaxin or self.controler.levelInfo.xuzhangshuaxinnv
		objHero.posIndex = Fight.xvzhangParams.zhujueShowPos

		local hero = self:createHeroes(objHero,camp,Fight.xvzhangParams.zhujueShowPos,Fight.enterType_runIn)
		-- 注掉东海龙王的内容
		-- local eff = hero:createEff("eff_plot_10002_zjflytoland2", 0, 0, 1, nil,nil,true,nil,nil,nil,hero)
		-- hero:justFrame("defined4")
		if self.controler.gameUi then
			self.controler.gameUi.icon_view:reFreshAllIcon()
		end
	end
end

--[[
	刷新3-3龙幽
]]
function RefreshEnemyControler:level3_3RefreshLongyou(pos)
	if self.controler:chkIsLevel_splongyou() then
		local longyou = self.controler.levelInfo.longyoushuaxin
		-- 龙幽出现在6号位
		longyou.posIndex = pos or 6
		
		local camp= Fight.camp_1
		local objHero = ObjectHero.new(longyou.hid,longyou)
		local hero = self:createHeroes(objHero,camp,longyou.posIndex,Fight.enterType_runIn)

		if self.controler.gameUi then
			self.controler.gameUi.icon_view:reFreshAllIcon()
		end
	end
end

--[[
	特殊刷新赵灵儿
]]
function RefreshEnemyControler:level2_5RefreshZhaolinger(pos)
	if self.controler:chkIsLevel_spzhaolinger() then
		local zhaolinger = self.controler.levelInfo.zhaolingershuaxin
		-- 出现
		zhaolinger.posIndex = pos or 6

		local camp= Fight.camp_1
		local objHero = ObjectHero.new(zhaolinger.hid,zhaolinger)
		local hero = self:createHeroes(objHero,camp,zhaolinger.posIndex,Fight.enterType_runIn)

		if self.controler.gameUi then
			self.controler.gameUi.icon_view:reFreshAllIcon()
		end
	end
end

--创建hero
function RefreshEnemyControler:createHeroByHid( hid,camp,posIndex ,characterRid,rid)
	local enemyInfo  = ObjectLevel:createEnemyInfo(hid,camp,posIndex,false) 

	local exArr = {
		rid =rid,
		characterRid = characterRid,--记录 每个英雄属于哪个伙伴
	}
	enemyInfo:setExAttr(exArr)
	
	local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
	local hero = self:createHeroes(objHero, camp, posIndex, Fight.enterType_stand )
	return hero
end
-- 创建monster
function RefreshEnemyControler:createMonster(hid,camp,lvRevise,tlvRevise,pos,enterType)
	self._refreshIndex = self._refreshIndex + 1
	local enemyInfo  =  EnemyInfo.new(hid,lvRevise,tlvRevise) --添加关卡修正系数
	enemyInfo.attr.rid = enemyInfo.hid.."_".. pos.."_1".."_"..self._refreshIndex
	enemyInfo.attr.posIndex = pos
	local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
	local hero = self:createHeroes(objHero,camp,pos,enterType )
	return hero
end

-- 检查是否需要刷怪 返回true代表需要刷怪
function RefreshEnemyControler:checkNeedRefresh()
	local refreshAi = self.controler.levelInfo:getRefreshAi()
	if refreshAi.type == Fight.refresh_wave then
		-- 需要检查当前波数至数组最大波数是否还有怪可刷
		for i = self._waveIdx,#refreshAi.enemyArr do
			if table.length(refreshAi.enemyArr[i]) > 0 then
				echo ("还有怪需要刷=====当前波数",i,table.length(refreshAi.enemyArr[i]))
				return true
			end
		end
	end
	return false
end
-- 更新刷怪的波数
function RefreshEnemyControler:updateRefreshWave(  )
	local refreshAi = self.controler.levelInfo:getRefreshAi()
	if refreshAi.type == Fight.refresh_wave then
		for i = self._waveIdx,#refreshAi.enemyArr do
			if table.length(refreshAi.enemyArr[i]) > 0 then
				self._waveIdx = i
				echo("更新刷怪波数=====",self._waveIdx)
				break
			else
				self._waveIdx = #refreshAi.enemyArr
			end
		end
	end
end
function RefreshEnemyControler:getCurrentWaveIndex( )
	return self._waveIdx
end
-- 检查刷怪
function RefreshEnemyControler:checkRefreshMonster( camp)
	local ctrl = self.controler
	if not self:checkNeedRefresh() then
		return false
	end
	-- 只有敌方需要刷怪，camp_1 不需要刷、没有活人
	if ctrl:chkLiveHero(ctrl.campArr_2) then
		echo("场上还有人，不需要刷怪")
		return false
	end
	local countArr = {} --刷出来的怪的数组
	local refreshAi = ctrl.levelInfo:getRefreshAi()
	local refreshCamp = Fight.camp_2 --这里刷的都是阵营2的怪
	-- 获取刷怪的波数
	local _getCurrRefreshIdx = function( )
		local tmpIdx = self._waveIdx
		for i = tmpIdx,#refreshAi.enemyArr do
			if table.length(refreshAi.enemyArr[i]) > 0 then
				tmpIdx = i
				break
			end
		end
		return tmpIdx
	end
	local isCanAttack = true --刷出来的怪是否能够攻击
	local _currRefreshIdx = _getCurrRefreshIdx() --当前刷怪的波数
	if _currRefreshIdx ~= self._waveIdx then
		isCanAttack = false
	end
	-- 更新刷怪的数据
	local _updateEnemyArr = function(_widx)
		-- 丢弃掉第一个值,后面的值往前挪1 此处不能用table.remove()，因为key不连续
		local tmpArr = {}
		for k,v in pairs(refreshAi.enemyArr[_widx]) do
			if k > 1 then
				tmpArr[k-1] = v
			end
		end
		refreshAi.enemyArr[_widx] = tmpArr
	end
	-- 刷新一个怪
	local _refreshOneEnemy = function( _widx,idx)
		local modelHero,enemyInfo,tmpIdx
		if table.length(refreshAi.enemyArr[_widx]) <= 0 then
			return 
		end
		-- dump(refreshAi.enemyArr[_widx],"bbb",1)
		enemyInfo = refreshAi.enemyArr[_widx][1]
		if enemyInfo then
			-- 如果怪存在，先把怪致死
			local tmpHero = ctrl.logical:findHeroModel(refreshCamp,idx)
			if tmpHero then
				tmpHero:doHeroDie(true)
			end
			enemyInfo.posIndex = idx
			--这里做特殊处理，因为存在相同rid的bug
			local _rid = enemyInfo.hid.."_"..idx.."_1_"..#refreshAi.enemyArr[_widx]
			local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo)
			objHero.rid = _rid 
			modelHero = self:createHeroes(objHero,refreshCamp,idx,Fight.enterType_runIn)
			if not isCanAttack then
				-- 这个怪当前回合不能攻击
				modelHero:setCanNotAttack()
			end
			modelHero.data:initAure() --初始化光环
			modelHero:doHelpSkill()
			echo("波数刷怪====",refreshCamp,isCanAttack,idx)
		end
		return modelHero
	end
	local _refreshWaveEnemy = function(_widx)
		local lastHero
		for i=1,6 do
			local nEnemy = refreshAi.enemyArr[_widx][1] --下一个要刷的怪
			if nEnemy then
				local posIdx = self:getRefreshIdxByFigure(refreshCamp,nEnemy.figure,i)
				if posIdx then
					-- echo("aa===",i,posIdx)
					local tmpModel = _refreshOneEnemy(_widx,posIdx)
					if tmpModel then
						lastHero = tmpModel
						table.insert(countArr,tmpModeil)
						_updateEnemyArr(_widx)
					end
				else
					-- 有位置，但是刷不出来(可能有傀儡，先不移除，下一波刷)
				end
			else
				_updateEnemyArr(_widx)
			end
		end
		return lastHero
	end
	if refreshAi.type == Fight.refresh_wave then
		local refreshCamp = Fight.camp_2 --目前只有敌方能够刷怪
		local lastHero = _refreshWaveEnemy(_currRefreshIdx)
		if not lastHero then
			-- 当前波没有可刷的怪了，则往后刷怪(此波怪本回合无法攻击)
			_currRefreshIdx = _getCurrRefreshIdx()
			lastHero = _refreshWaveEnemy(_currRefreshIdx)
		else
			-- echoError("检查本波还有没有怪，没有则修改为下拨")
			_currRefreshIdx = _getCurrRefreshIdx()
		end
		if lastHero then
			ctrl.logical._isrefreshing = true
			-- 刷完怪后做下排序
			ctrl.logical:sortCampPos(refreshCamp)
			local campArr = camp == Fight.camp_1 and ctrl.campArr_1 or ctrl.campArr_2
			-- 让攻击的一方回位
			for i,v in ipairs(campArr) do
				v:movetoInitPos(2)
			end
			-- 更新下一波怪的数据
			if Fight.isDummy then
				ctrl.logical._isrefreshing = false
				ctrl.logical:checkNextHandle(camp)
			else
				-- 抛通知刷新剩余怪个数
				FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_WAVE_REFRESH,countArr)
				local time = math.floor((lastHero.data.posIndex - 1) / 2) * Fight.enterInterval
				ctrl:pushOneCallFunc(time,function( )
					ctrl.logical._isrefreshing = false
					ctrl.logical:checkNextHandle(camp)
					echo("刷怪结束---继续攻击",camp)
					FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_WAVE_REFRESH)
				end)
			end

			return true
		else
			-- echoError ("如果此时场上没人(有傀儡)、并且还有大体型怪未刷出来，则将场上的傀儡致死")
			-- 先致死阵营上的怪
			for i=1,6 do
				local tmpHero = ctrl.logical:findHeroModel(refreshCamp,i)
				if tmpHero then
					tmpHero:doHeroDie(true)
				end
			end
			_currRefreshIdx = _getCurrRefreshIdx()
			_refreshWaveEnemy(_currRefreshIdx)
		end
	end
	return false
end
-- 检查刷怪的位置及对应的怪
function RefreshEnemyControler:getRefreshIdxByFigure(camp,figure,chckIdx)
	if chckIdx then
		if figure == 1 then
			local posHero = self.controler.logical:findHeroModel(camp,chckIdx,false)
			if not posHero then
				return chckIdx
			end
		else
			echoWarn ("figure = ",figure,"无法做固定位置刷怪")
		end
	end
	-- 获取可刷的位置
	local posArr = {}
	for i=1,6 do
		local posHero = self.controler.logical:findHeroModel(camp,i,false)
		if not posHero then
			table.insert(posArr,i)
		end
	end
	if #posArr <= 0 then
		return nil
	end
	if figure == 1 then
		return posArr[1]
	elseif figure == 2 then
		for i=1,5,2 do
			local k1,k2 = table.find(posArr,i),table.find(posArr,i+1)
			if k1 and k2 then
				return i
			end
		end 
	elseif figure == 4 then
		if #posArr < 4 then
			return
		end
		local have = true
		for j=1,4 do
			if not table.find(posArr,j) then
				have = false
				break
			end
		end
		if have then
			return 1 --1 号位的可以刷
		end
		have = true
		for j=3,6 do
			if not table.find(posArr,j) then
				have = false
				break
			end
		end
		if have then
			return 3 -- 3号位的可以刷
		end
	elseif figure == 6 then
		if #posArr < 6 then
			return
		end
		return 1
	end
end

return RefreshEnemyControler