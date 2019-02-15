-- 仙界对决控制器
-- Author: pangkangning
-- Date: 2018-08-03
--

CrossPeakControler = class("CrossPeakControler")


function CrossPeakControler:ctor( controler )
	self.controler = controler
	self.levelInfo = self.controler.levelInfo
	self.logical = self.controler.logical
end
-- 获取先手的阵营
function CrossPeakControler:getHandleCamp( ... )
	local camp = Fight.camp_1
	-- local ran = BattleRandomControl.getOneRandom()
	-- if ran * 100 > 50 then
	-- 	-- 阵营二先出手
	-- 	camp = 2
	-- end
	return camp
end
-- 下阵一个角色
function CrossPeakControler:downOneHero(model)
	local bState = self.logical:getBattleState()
	if bState == Fight.battleState_changePerson then
		local hid = model.data.hid
		if model.data.isCharacter then
			hid = "1"
		end
		-- 下阵操作
		local info = {rid = self.controler:getUserRid(),pos = model.data.posIndex,
			hid = hid,camp = model.camp,ctype = Fight.change_down}
		self.controler.server:sendChangeHandle(info)
	elseif bState == Fight.battleState_formationBefore then
		local info = {rid = self.controler:getUserRid(),posNum = model.data.posIndex,
			partnerId = 0}
		self.controler.server:sendBeforeChangeHandle(info)
	end
end
-- 战前获取新上阵的角色
function CrossPeakControler:getCampNewUpCount( camp )
	local campArr = self.controler:getCampArr(camp)
	local count = 0
	for k,v in pairs(campArr) do
		-- 排除傀儡
		if v:isNewInCrossPeak() then
			count = count + 1
		end
	end
	return count
end
-- 校验巅峰竞技场满回合后谁胜[人数多的赢，伤害高的赢]
function CrossPeakControler:chkCrossPeakEnd( )
	local bResult = {}
	for i=1,2 do
		bResult[i] = {liveCount = 0,hpTotal = 0,totalDamage = 0}
		local tmp = bResult[i]
		local campArr = self.controler:getCampArr(i)
		-- 取场上存活人数
		for k,v in pairs(campArr) do
			if self.controler:isLiveHero(v) then
				tmp.liveCount = tmp.liveCount + 1
				tmp.hpTotal = tmp.hpTotal + v.data:getAttrByKey(Fight.value_health)
			end
		end
		-- 取替补未上场人数
		tmp.liveCount = tmp.liveCount + self.levelInfo:getUnUpPartnerCount(i)
		-- 获取总伤害
		tmp.totalDamage = StatisticsControler:getAllTotalDamage(i)
	end
	local camp1Win = false
	if bResult[1].liveCount == bResult[2].liveCount then
		if bResult[1].totalDamage > bResult[2].totalDamage then
			camp1Win = true
		end
		-- if bResult[1].hpTotal >= bResult[2].hpTotal then
		-- 	camp1Win = true
		-- end
	elseif bResult[1].liveCount > bResult[2].liveCount then
		camp1Win = true
	end
	if camp1Win then
		self.controler:enterGameWin()
	else
		self.controler:enterGameLose()
	end
end
-- 仙界对决战前上阵人数
function CrossPeakControler:getMaxUpCountByIdx(camp,index )
	local cNumArr = Fight.crosspeak_num
	local cpData = self.levelInfo:getCrossPeakOtherData()
	local max = FuncCrosspeak.getSegmentFightInStageMax(cpData.seg)
	local db = cNumArr[max]
	if not db then
		echoError ("未在constvalue中配置仙界对决上阵模式，使用默认3人上阵数据",max)
		db = cNumArr[3]
	end
	return db[camp][index] or 0
end

-- 仙界对决发送bp结果
function CrossPeakControler:sendCrossPeakBP(cards,camp,idx)
	if Fight.isDummy then
		self.logical:readSaveHandle()
		return
	end
	-- 此时不读数据、等加载完成了再读数据
	if self.controler:isReplayGame() or self.controler:checkIsInProgress() then
		return
	end
	-- 发送选牌id
	local info = {team = camp,selectList = {}}
	for i,v in ipairs(cards) do
		local teamId = camp
		if not idx then
			idx = 1
			local ran = RandomControl.getOneRandom( )--复盘读操作，不走这里
			if ran * 100 > 50 then
				idx = 2
			end
		end
		if i ~= idx then
			teamId = camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
		end
		info.selectList[i] = {cardId = v.cardId,cardType = v.cardType,team = teamId}
	end
	self.controler.server:sendBPHandle(info)
end
-- 仙界对决bp阶段
function CrossPeakControler:enterCrossPeakBP( )
	echo ("推送仙界选牌开始====")
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENTER_CROSSPEAK_BATTLE,{result = 1})
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOW_GAMEUI)
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOW_SKILLICON)

	self.logical:chkCrossPeakRobotAi()
	-- 加载仙人掌
	self:chkAddCrossPeakObstacleData()
end
-- 如果是仙人掌玩法，需要加载仙人掌数据
function CrossPeakControler:chkAddCrossPeakObstacleData( )
	if self.levelInfo:getCrosspeakPlayType() == Fight.crosspeak_obstacle then
		local posIndex,monsterId = FuncDataSetting.getCrossPeakObstaclePlay()
		-- monsterId = 117011
		local oData = self.levelInfo:getCrossPeakOtherData()
		for i=1,2 do
			--  检查场上是否有仙人掌
			local hero = EnemyInfo.new(tostring(monsterId))
			hero.attr.posIndex = posIndex
			-- hero.attr.characterRid = oData.rid[i]
			local objHero = ObjectHero.new(tostring(monsterId),hero.attr)
			objHero.characterRid = oData.rid[i]
			objHero.rid = tostring(monsterId).."_"..posIndex.."_"..i
			local model = self.controler.reFreshControler:createHeroes(objHero,i,posIndex,Fight.enterType_flash)
			model.data:initAure() --初始化光环
			model:doHelpSkill() -- 做协助技
			local posIndex,monsterId = FuncDataSetting.getCrossPeakObstaclePlay()
			if monsterId == model.data.hid then
				model:setIsCrossPeakObstacle(true)
				model:chkCanAttackByProfession() --重置仙人掌的攻击状态
			end
		end
		self.logical:sortCampPos(i)
	end
end
-- 当倒计时结束时校验当前bp的阶段状态
function CrossPeakControler:chkCrossPeakBpByTimeOut( )
	local camp = BattleControler:getTeamCamp( )
	local selectIds = self.levelInfo:getBPPartnerByCampIndex(camp)
	if selectIds then
		-- 这个地方有点绕，倒计时结束、需要加载资源，然后等待资源结束后才能校验bp阶段
		-- 所以当还有牌可选的时候，此处就先置换为1，倒计时为0的时候再校验一次
		self.logical:setLeftAutoFrame(1)
	else
		selectIds = self.levelInfo:getBPTreasureByCampIndex(camp)
		if selectIds then
			self.logical:setLeftAutoFrame(1)
		end
	end
end
-- 仙界对决机器人模式下战前上下阵倒计时结束校验
function CrossPeakControler:chkCrossPeakBeforeChangeByTimeOut( )
	if self.controler:chkIsResultComeOut() then
		return
	end
	if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
		local oData = self.levelInfo:getCrossPeakOtherData()
		local camp  = BattleControler:getTeamCamp()
		local now = self:getCampNewUpCount(camp)
		local max = self:getMaxUpCountByIdx(camp,oData.upNum[camp])
		local num = max - now
		if num > 0 then
			echo("我方没上齐，需要补位",now,max,camp)
			local pArr = self:getRandomParnterPos(camp,num)
			for k,v in ipairs(pArr) do
				local info = {rid = self.controler:getUserRid(),posNum = v.pos,
					partnerId = v.partnerId}
				self.controler.server:sendBeforeChangeHandle(info)
				-- local info = {rid = self.controler:getUserRid(),pos = v.pos,
		  --   		hid = v.partnerId,camp = camp,ctype = Fight.change_up}
		  --   	self.controler.server:sendChangeHandle(info)
			end
		end
		-- 如果此时所有阵营已经都选完上阵的角色了，则开始发开战操作
		local otherCamp = BattleControler:getOtherCamp()
		if oData.upNum[otherCamp] < Fight.crosspeak_changeNum then
			local info = {team=otherCamp}
			self.controler.server:sendEnterBeforeChangeHandle(info)
		else
			self:crossPeakChange2Battle(otherCamp)
		end
	end
end
-- 仙界对决开战后的逻辑处理
function CrossPeakControler:checkCrossPeakBattle2Start( )
	local bLabel = BattleControler:getBattleLabel()
	if BattleControler:checkIsCrossPeakModeBP() then
		if Fight.isDummy or self.controler:isReplayGame()  then
			self.logical:readSaveHandle()
		else
			-- 如果是机器人，则发送进入pb阶段请求，否则等待服务端推送进入bp状态消息
			if bLabel == GameVars.battleLabels.crossPeakPve then
				self.controler.server:sendEnterEnterBPHandle()
			else
				self.controler.server:loadBattleResOver()
			end
		end
	else
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENTER_CROSSPEAK_BATTLE,{result = 1})
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOW_GAMEUI)
		if Fight.isDummy then
			self.logical:startRound()
		else
			self.controler:pushOneCallFunc(60, c_func(self.crosspeakNormalMode2Battle, self))
		end
	end
end
-- 仙界绝对普通玩法开始战斗
function CrossPeakControler:crosspeakNormalMode2Battle(  )
	self.controler.gameUi:playKaiZhanTeXiao(function( )
    	self.logical:startRound()
    end)
end
-- 机器人bp
function CrossPeakControler:onCrossPeakRobotBP()
	local ctrl = self.controler
	local camp = BattleControler:getOtherCamp( )
	local selectIds = self.levelInfo:getBPPartnerByCampIndex(camp)
	if selectIds then
		self:sendCrossPeakBP(selectIds,camp)
		ctrl:pushOneCallFunc(Fight.crossPeakRobotBPFrame, c_func(self.onCrossPeakRobotBP, self))
	else
		selectIds = self.levelInfo:getBPTreasureByCampIndex(camp)
		if selectIds then
			--机器人选法宝
			self:sendCrossPeakBP(selectIds,camp)
		end
	end
end
-- 仙界对决机器人战前选人完成切换至开战
function CrossPeakControler:crossPeakChange2Battle(camp )
	self.logical:doCrossPeakUpHeroFirst()
	self.controler.server:sendBuZhenFinishHandle({camp = camp})
end
-- 仙界对决更新bp数据
function CrossPeakControler:updateCrossPeakBPData(info)
	local ctrl = self.controler
	local heroArr = self.levelInfo:updateBPData(info)
	local isMyChoose = false
	if info.team == BattleControler:getTeamCamp( ) then
		isMyChoose = true
	end
	if not Fight.isDummy then
		-- -- 加载角色纹理
		self.controler.resControler:cacheOtherRes(heroArr,c_func(self.onOtherHeroResloadComp,self,isMyChoose))
	else
		self.logical:readSaveHandle()
	end
end
-- 角色资源加载完成
function CrossPeakControler:onOtherHeroResloadComp(isMyChoose)
	if self.controler:isReplayGame() or self.controler:checkIsInProgress() then
		self.logical:readSaveHandle()
		return
	end
	if isMyChoose then
		-- 只有是我方资源加载完成，才会刷新倒计时
		local camp = BattleControler:getTeamCamp( )
		local selectIds = self.levelInfo:getBPPartnerByCampIndex(camp)
		if selectIds then
			self.logical:setLeftAutoFrame(self.logical:getWaitTime())
		else
			selectIds = self.levelInfo:getBPTreasureByCampIndex(camp)
			if selectIds then
				self.logical:setLeftAutoFrame(self.logical:getWaitTime())
			else
				self.logical:setLeftAutoFrame(self:getBPWaitTime())
			end
		end
	end
	-- bp结束并且没有缓存队列
	if self:chkBPIsOver() and not self.controler.resControler:chkHaveCacheList()  then
		self:crossPeakBPEnd()
	end
	-- 发送选角资源加载完成通知
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_BP_RES_COMPLETE,isMyChoose)
end
-- 仙界对决pb结束进入下一状态
function CrossPeakControler:crossPeakBPEnd( )
	if Fight.isDummy or self.controler:isReplayGame() or 
		self.controler:checkIsInProgress() 
		then
		self.logical:readSaveHandle()
		return
	end
	-- bp结束，如果机器人则发送进入战前上下阵请求，否则等待服务器推送
	if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
		local info = {team=Fight.camp_1} --team1 先布阵
		self.controler.server:sendEnterBeforeChangeHandle(info)
	else
		self.logical:setLeftAutoFrame(self:getBPWaitTime())
	end
end
-- 仙界对决选角所花时间
function CrossPeakControler:updateUseTime(t )
	if not self._cwaitTime then
		self._cwaitTime = 0
	end
	self._cwaitTime = self._cwaitTime + t
end
-- 获取剩余bp时间
function CrossPeakControler:getBPWaitTime( )
	local time = self._cwaitTime or 1
	return time
end
-- 检查是否已经bp结束
function CrossPeakControler:chkBPIsOver( )
	for i=1,2 do
		-- 检查有无英雄未选
		local selectIds = self.levelInfo:getBPPartnerByCampIndex(i)
		if selectIds then
			return false
		else
			-- 检查有无法宝未选
			selectIds = self.levelInfo:getBPTreasureByCampIndex(i)
			if selectIds then
				return false
			end
		end
	end
	return true
end
-- 开始进入战前上下阵阶段
function CrossPeakControler:enterCrossPeakBeforeChange(info)
	self.logical.isInRound = true
	self.logical:cancleFormation()
	local ctrl = self.controler
	local oData = self.levelInfo:getCrossPeakOtherData()
	-- 检查是否上满人
	local _checkAllReady = function( )
		local isAllReady = true
		for i=1,2 do
			local now = ctrl:countLiveHero(ctrl:getCampArr(i))
			local max = FuncCrosspeak.getSegmentFightInStageMax(oData.seg)
			if now < max then
				isAllReady = false 
				break
			end
		end
		return isAllReady
	end
	local _enterBeforeChange = function( )
		local camp = info.team
		local oldCamp = camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
		self.logical:doCrossPeakUpHeroFirst(oldCamp)
		self.levelInfo:updateCrossPeakChangeCamp(camp)

		if Fight.isDummy or ctrl:isReplayGame() or ctrl:checkIsInProgress() then
			self.logical:readSaveHandle()
			return
		end

		-- 机器人检查双方阵容已经都上满人了，则可以开战了(单人肯定是阵营1开打)
		if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
			if _checkAllReady() then
				self:crossPeakChange2Battle(Fight.camp_1)
			end
		end

		self.logical:updateBattleState(Fight.battleState_formationBefore)
		self.logical:setLeftAutoFrame(self.logical:getWaitTime())
		
		self.logical:chkCrossPeakRobotAi(camp)
		-- 发送通知让UI刷新
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENTER_BEFORECHANGE)
	end
	if Fight.isDummy then
		_enterBeforeChange()
	else
		if not oData.changeCamp then
			-- 第一次进入战前选人状态，添加开战特效
			ctrl.gameUi:playKaiZhanTeXiao(function( )
				_enterBeforeChange()
				ctrl.gameUi:showBeforeChange()
	    		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_BP_SHOW)
		    end)
		else
			_enterBeforeChange()
			ctrl.gameUi:showBeforeChange()
		end
	end
end
-- 战中机器人发起进攻
function CrossPeakControler:onCrossPeakRobotOnBattleSure( )
	-- echo("仙界对决机器人发起进攻---")
	self.controler.server:sendBuZhenFinishHandle({camp = BattleControler:getOtherCamp()})
end
-- 战中机器人上下人
function CrossPeakControler:onCrossPeakRobotOnBattleChange( )
	local ctrl = self.controler
	local camp = BattleControler:getOtherCamp()
	local oData = self.levelInfo:getCrossPeakOtherData()
	local rid = oData.rid[camp]
	local pArr = self:getRandomParnterPos(camp,1)
	if #pArr == 0 then
		-- 没有可上阵的角色了
		ctrl.server:sendChangeHeroFinishHandle({change=0,camp = camp})
		return 
	end
	for k,v in ipairs(pArr) do
		local info = {rid = rid,pos = v.pos,
    		hid = v.partnerId,camp = camp,ctype = Fight.change_up}
    	ctrl.server:sendChangeHandle(info)
	end
	-- 检查人够了没有，没有继续
	local now = ctrl:countLiveHero(ctrl:getCampArr(camp))
	local max = FuncCrosspeak.getSegmentFightInStageMax(oData.seg)
	if now >= max then
		-- echo("仙界对决机器人进入到布阵换人阶段---")
		ctrl.server:sendChangeHeroFinishHandle({change=0,camp = camp})
	else
		ctrl:pushOneCallFunc(Fight.crossPeakRobotBPFrame, c_func(self.onCrossPeakRobotOnBattleChange, self))
	end
end
-- 机器人上下人阶段
function CrossPeakControler:onCrossPeakRobotBeforeChange( )
	local ctrl = self.controler
	local camp = BattleControler:getOtherCamp()
	-- 检查人够了没有，没有继续
	local now = self:getCampNewUpCount(camp)
	local oData = self.levelInfo:getCrossPeakOtherData()
	local pArr = self:getRandomParnterPos(camp,1)
	for k,v in ipairs(pArr) do
    	local info = {rid = oData.rid[camp],posNum = v.pos,
    		partnerId = v.partnerId}
    	ctrl.server:sendBeforeChangeHandle(info)
	end
	-- 检查人够了没有，没有继续
	local now = self:getCampNewUpCount(camp)
	local max = self:getMaxUpCountByIdx(camp,oData.upNum[camp])
	if now >= max then
		-- 进入到我方阶段(从机器人方切换至我方)
		local info = {team=BattleControler:getTeamCamp()}
		ctrl.server:sendEnterBeforeChangeHandle(info)
		-- echoError ("进入到对方上人阶段")
	else
		ctrl:pushOneCallFunc(Fight.crossPeakRobotBPFrame, c_func(self.onCrossPeakRobotBeforeChange, self))
	end
end

-- 根据阵营获取是否有可上阵的角色数组
function CrossPeakControler:getCanUpHeroArr(camp )
	local allHero = self.levelInfo:getAllHeroByCamp(camp)
	-- 随机一个伙伴
	local pArr = {}
	for k,v in pairs(allHero) do
		if v.__isUp == Fight.partner_notUp then
			table.insert(pArr,v.__cardId)
		end
	end
	return pArr
end
-- 根据阵营随机上阵伙伴，返回{{parnterId,pos}}
function CrossPeakControler:getRandomParnterPos(camp,count)
	local rArr = {}
	-- 随机一个伙伴
	local pArr = self:getCanUpHeroArr(camp)
	-- 没有可上阵的角色了
	if #pArr == 0 then
		return rArr
	end
	local partnerArr = RandomControl.getNumsByGroup(pArr,count)
	for i=1,count do
		table.insert(rArr,{partnerId = partnerArr[i],pos = nil})
	end
	local _setParnterPos = function( pos )
		for i=1,count do
			if not rArr[i].pos then
				rArr[i].pos = pos
				return true
			end
		end
		return false
	end
	-- 查找位置
	for i=1,6 do
		local posHero = self.logical:findHeroModel(camp,i,false)
		if not posHero then
			-- 给对应的伙伴填充位置
			if not _setParnterPos(i) then
				break
			end
		end
	end
	for i=#rArr,1,-1 do
		if not rArr[i].pos then
			table.remove(rArr,i)
		end
	end
	return rArr
end
-- 获取仙剑对决战报额外数据
function CrossPeakControler:getCrossPeakParams( ... )
	local tmpArr = {}
	local _findHero = function( arr,hid )
		for k,v in pairs(arr) do
			if v.hid == hid then
				return true
			end
		end
		return false
	end
	local _getLifeHeroInfo = function ( camp )
		local rTbl = {}
		local campArr = self.controler:getCampArr(camp)
		for k,hero in ipairs(campArr) do
			if (not hero:isSummon()) and (not hero:hasNotAliveBuff()) and
				(hero:getHeroProfession() ~= Fight.profession_obstacle) then
				
				local currHp = hero.data:hp()
				local maxHp = hero.data:getInitValue(Fight.value_maxhp)
				if currHp >= maxHp then currHp = maxHp end
				local hid = hero.data.hid 
				if hero.data.isCharacter then
					hid = "1"
				end
				local tmp = {hid = hid,isChar = hero.data.isCharacter,currHp = currHp,
				maxHp = maxHp}
				table.insert(rTbl,tmp)
			end
		end
		local cpAllHero = self.levelInfo:getAllHeroByCamp(camp)
		for k,v in pairs(cpAllHero) do
			local isDead = true
			if v.__isUp == Fight.partner_notUp then
				isDead = false
			else
				if _findHero(rTbl,v.__cardId) then
					isDead = false
				end
			end
			local isChar = v.__cardId == "1" and true or false
			if isDead then
				local tmp = {hid = v.__cardId,isChar = isChar,currHp = 0,
				maxHp = v:getInitValue(Fight.value_maxhp)}
				table.insert(rTbl,tmp)
			else
				if not _findHero(rTbl,v.__cardId) then
					local tmp = {hid = v.__cardId,isChar = isChar,currHp = v:getInitValue(Fight.value_health),
					maxHp = v:getInitValue(Fight.value_maxhp)}
					table.insert(rTbl,tmp)
				end
			end
		end
		-- 格式化数据 死亡奇侠,我方剩余奇侠,剩余血量
		local tmp = {deadArr={},lifeArr={},hpPercent=0}
    	local currHp,totalHp = 0,0
    	for k,v in pairs(rTbl) do
    		totalHp = totalHp + v.maxHp
    		currHp = currHp + v.currHp
    		local partnerId = v.hid
    		if v.hid ~= "1" then
    			partnerId = FuncCrosspeak.getPartnerMapping(v.hid).partnerId
	    	end
    		if v.currHp == 0 then
    			table.insert(tmp.deadArr,partnerId)
    		else
    			table.insert(tmp.lifeArr,partnerId)
    		end
    	end
    	if currHp > totalHp then currHp = totalHp end
    	tmp.hpPercent = math.round(currHp/totalHp*10000)
		tmpArr[camp] = tmp
	end
    local resultArr = {round=math.ceil(self.logical.roundCount/2),situation = {}}
    -- 获取基础的数值
    for i=1,2 do
    	_getLifeHeroInfo(i)
    end
    -- 根据阵营获取对应的数值
    local _getResultInfo = function ( camp )
    	local oCamp = camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
    	return {
    		beatPartners=tmpArr[oCamp].deadArr,
    		remainPartners=tmpArr[camp].lifeArr,
    		hpPercent = tmpArr[camp].hpPercent
    	}
    end

    -- 我方数据
    local userRid = self.controler:getUserRid()
    resultArr.situation[userRid] = _getResultInfo(BattleControler:getTeamCamp())
    -- 敌方数据
    local otherRid = self.levelInfo:getCrossPeakOtherRid()
    resultArr.situation[otherRid] = _getResultInfo(BattleControler:getOtherCamp())
    return resultArr
end

-- 仙界对对决上人后的额外buff处理
function CrossPeakControler:doCrossPeakBuff(model,camp )
	if BattleControler:checkIsMultyBattle() then
		local oData = self.levelInfo:getCrossPeakOtherData()
		-- 连负处理
		local losingStreak = oData.cp[camp].losingStreak
		if losingStreak > 0 then
			local data = FuncCrosspeak.getLosingProperty(losingStreak)
			if data.subAttr and #data.subAttr > 0 then
				for k,v in pairs(data.subAttr) do
					-- echo("仙界对决连败属性加成")
					self.controler:changeModelDataValue(model,v)
				end
			end
		end
		-- 伙伴拥有品阶加成加成
		if not model.data.isCharacter then
			local pData = FuncCrosspeak.getMoneyProperty(model.data.hid)
			local mData = FuncCrosspeak.getPartnerMapping(model.data.hid)
			local partner = self.levelInfo:getCrossPeakPartnerById(mData.partnerId,camp)
			if pData and partner then
				-- 品阶
				for k,v in pairs(pData.subGradeAttr) do
					if v.grade == partner.quality then
						-- echo("仙界对决品阶加成",mData.partnerId,partner.quality)
						self.controler:changeModelDataValue(model,v)
					end
				end
				-- 星级
				for k,v in pairs(pData.subStarAttr) do
					if v.star == partner.star then
						-- echo("仙界对决星级符合",mData.partnerId,partner.quality)
						self.controler:changeModelDataValue(model,v)
					end
				end
			end
		end
	end
	-- 仙界对决机器人属性衰减处理(敌方阵营)
	if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve and 
		BattleControler:getTeamCamp() ~= camp then
		local rid = self.levelInfo:getCrossPeakOtherRid()
		local pData = FuncCrosspeak.getRobotDataById(rid)
		if pData and #pData.delAttr > 0 then
			for k,v in pairs(pData.delAttr) do
				-- echo("仙界对机器人属性衰减")
				self.controler:changeModelDataValue(model,v,true)
			end
		end
	end
end
-- 单数的大回合给后手加buff，偶数给先手加
function CrossPeakControler:checkAddCrosspeakRoundBuff(currentCamp)
	local isAdd = false
	local _addFastProperty = function( model,round )
		local pData = FuncCrosspeak:getFasterPropertyByRound(round)
		if pData and #pData.subAttr > 0 then
			for m,v in pairs(pData.subAttr) do
				self.controler:changeModelDataValue(model,v)
			end
			-- echo("仙界对决伤害增加===",round,model.camp,model.data.posIndex)
			if not isAdd then
				isAdd = true
			end
			model:checkCreateBuff(self.levelInfo:getCrossPeakBuff(),model)
		end
		model.__curCPRound = round --当前加成加到第几回合了
	end
	local nowRound = math.ceil(self.controler:getCurrRound()/2)
	local camp = self:getHandleCamp()
	if nowRound%2 == 0 then
		camp = camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
	end
	-- 等到对应的阵营的时候再加属性
	if currentCamp ~= camp then
		return
	end
	local campArr = self.controler:getCampArr(camp)
	for k,model in pairs(campArr) do
		local notRound = model.__curCPRound
		if not model.__curCPRound then
			notRound = self:getHandleCamp()
		end
		for i=notRound+2,nowRound,2 do
			_addFastProperty(model,i)
		end
	end

	local pData = FuncCrosspeak:getFasterPropertyByRound(nowRound)
	if pData and #pData.subAttr > 0 then
		local camp = self:getHandleCamp()
		if nowRound%2 == 0 then
			camp = camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
		end
	end
	if isAdd and not Fight.isDummy then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CROSSPEAK_ADDBUFF)
	end
end
-- 仙界对决认输
function CrossPeakControler:updateCrossPeakGiveUp(info )
	if self.controler:chkIsResultComeOut() then
		return
	end
	self.controler:setIsGiveUp(true)
	-- 这里判断是否已经出结果了(以阵营1战斗结果为准)
	self.controler:setGameStep(Fight.gameStep.result)
	if info.team == Fight.camp_1 then
		self.controler:setBattleResult(Fight.result_lose)
	else
		self.controler:setBattleResult(Fight.result_win)
	end
	if self.controler:isReplayGame() then
		BattleControler:saveBattleInfo()
	end
	self.controler:pushOneCallFunc(5,function( )
		self.controler:submitGameResult(false)
	end)
	if not Fight.isDummy then
		if info.team == BattleControler:getOtherCamp() then
			WindowControler:showTips(GameConfig.getLanguage("#tid_battle_5") )
		else
			WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_028"))
		end
		if self.controler:checkIsInProgress() and not self.controler:isReplayGame() then
			BattleControler:onExitBattle()
		end
	end
end

return CrossPeakControler