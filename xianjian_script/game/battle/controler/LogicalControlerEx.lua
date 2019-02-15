--
-- Author: xd
-- Date: 2018-01-08 16:30:11
--逻辑控制器 的扩展
-- 主要处理一些特殊战斗逻辑的类 
-- 以及处理布阵相关的逻辑

LogicalControlerEx  = class("LogicalControlerEx",LogicalControlerHandle)
local Fight = Fight

-- local BattleControler = BattleControler -- 2018.04.14注掉，以这种方式赋值，BattleControler无法被全局替换
local table = table

-- 检查该位置后方是否有怪物
function LogicalControlerEx:checkBackIsHaveMonster(posIndex )
	for j = 1,2 do
		local idx = posIndex + j * 2
		local posHero = self:findHeroModel(2,idx,false)
		if posHero then
			return posHero
		end
	end
	return nil
end
-- 移除宝物model、并抛一条获得宝物通知
function LogicalControlerEx:colletMonkey(posHero )
	if not Fight.isDummy then
		local posx,posy = posHero.pos.x,posHero.pos.y
		self.controler.gameUi:createDrop({{idx=1}},posx,-posy,self.controler.layer.a12,10)
	end
	posHero:doHeroDie(true)
	self:updateColletMonkeyNum()
end
-- 更新宝物个数
function LogicalControlerEx:updateColletMonkeyNum()
	self.missionNum = self.missionNum + 1
	-- 抛一条通知，获得一个宝物
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_MONKEY_CHANGE)
end
-- 轶事夺宝角色换位结束后调用
function LogicalControlerEx:changeMonsterPos(posHero,posIndex,isCollet)
	if isCollet then
		self:colletMonkey(posHero)
	else
		self:exchangeHeroPos(posHero.data.rid,posIndex,posHero.camp)
	end
	-- echo("移动结束==重新递归",posHero.data.posIndex,isCollet,posIndex,posHero.data.rid)
	self:colletMoveMonkey()
end
-- 递归让怪物往前刷新并填充传入的moveTbl
function LogicalControlerEx:colletMoveMonkey()
	-- for i=1,6 do
	-- 	local posHero = self:findHeroModel(2,i,false)
	-- 	if not posHero then
	-- 		echo("--%s位置为空",i)
	-- 	end
	-- end
	for i=1,6 do
		local posHero = self:findHeroModel(2,i,false)
		if posHero then
			-- 1、2为宝物则收集
			if i <= 2 and self.controler:checkMonsterIsBaoWu(posHero) then
				self:colletMonkey(posHero)
				-- echo("收集宝物===,重新递归",i)
				self:colletMoveMonkey()
				return
			end
		else
			-- echo("该位置不存在怪物、则检查后方是否有怪物，有则移动",i)
			local m = self:checkBackIsHaveMonster(i)
			if m then
				local tmpPosIdx = m.data.posIndex
				local isCollet = false
				if i <= 2 and self.controler:checkMonsterIsBaoWu(m) then
					isCollet = true
				end
				-- 这里直接修改值
				m:setMonsterToPosIndex(i)
				-- echo("怪物应该从:%s移动到哪里::%s===是否可收集:%s",tmpPosIdx,i,isCollet,m.data.hid)
				if (not Fight.isDummy) and  (not self.controler:isQuickRunGame() ) then
					-- 怪物位移、回调里面做处理
					local x,y = self.controler.reFreshControler:turnPosition(2,i,m.data:figure(),self.controler.middlePos)
					local posParams = {x= x,y = y,speed = Fight.enterSpeed,call = {"toColletMonkey",{i,isCollet}}}
					m:justFrame(Fight.actions.action_run )
					m:moveToPoint(posParams)
				else
					self:changeMonsterPos(m,i,isCollet)
				end
				return
			end
		end
	end
	self:refreshMonkey()
end
-- 轶事夺宝、敌方回合开始的时候做如下判断
-- 1、2位置如果有宝物、则宝物收入囊中，然后置空该位置；
-- 1、2、3、4、5、6位置为空，则后续的怪物都往前移动
function LogicalControlerEx:checkIsEmptyOrIsMonkey( ... )
	self:resetMoveData()
	local wait2move = false
	if BattleControler:getBattleLabel() == GameVars.battleLabels.missionMonkeyPve then
		local count = self.controler.reFreshControler:getRefreshCount()
		for i=1,6 do
			local posMonster = self:findHeroModel(2,i,false)
			-- 前两位置 有宝物怪
			if i <= 2 and posMonster and self.controler:checkMonsterIsBaoWu(posMonster) then
				wait2move = true
				break
			end
			if not posMonster then
				-- 任意一个位置是空并且有怪可刷
				if count > 0 then
					wait2move = true
					break
				else
					local m = self:checkBackIsHaveMonster(i)
					-- 前2位置为空、后面有宝物
					if i <= 2 then
						if m and self.controler:checkMonsterIsBaoWu(m) then
							wait2move = true
							break
						end
					end
					-- 如果空位置后方有怪
					if m then
						wait2move = true
						break
					end
				end
			end
		end
		if not wait2move then
			if #self.controler.campArr_2 == 0 and count == 0 then
				self.controler:enterGameWin()
			end
		else
			self:colletMoveMonkey()
		end
	end
	-- echo("checkIsEmptyOrIsMonkey=====",wait2move,#self.controler.campArr_2)
	return wait2move
end

-- 刷怪跑动结束(ModelMoveBasic 调用)
function LogicalControlerEx:onMoveComplete( )
	if not self._moveCount then
		return
	end
	if self._moveCount > 0 then
		self._currMoveIdx = self._currMoveIdx + 1 
		if self._currMoveIdx == self._moveCount then
			self:resetMoveData()
			self:checkRoundWait(self.currentCamp)
		end
	else
		self:resetMoveData()
		self:checkRoundWait(self.currentCamp)
	end
end
-- 重置移动的临时数据
function LogicalControlerEx:resetMoveData( )
	self._currMoveIdx = 0
	self._moveCount = 0
end
-- 根据传入位置table 刷新怪物
function LogicalControlerEx:refreshMonkey()
	self:resetMoveData()
	local attrArr = self:refreshMonster(2,Fight.enterType_runIn)
	self._moveCount = #attrArr

	if Fight.isDummy then
		self:resetMoveData()
		self:onMoveComplete()
	else
		-- 没有可刷新的怪物、刷新结束
		if self._moveCount == 0 then
			self:onMoveComplete()
		end
	end
end
function LogicalControlerEx:checkRefresh( ... )
	local isWait = false
	local attrArr = {} --炸药桶
	if BattleControler:getBattleLabel() == GameVars.battleLabels.missionBombPve then
		if not self:checkHasBomb() then
			local m = self:refreshBomb()
			if m then
				table.insert(attrArr,m)
			end
		end
	end
	local tmpArr = self:refreshMonster(Fight.camp_2,Fight.enterType_runIn)
	if #tmpArr > 0 or #attrArr > 0 then
		isWait = true
		if Fight.isDummy then
			self:checkRoundWait(self.currentCamp)
		else
			local lastHero
			-- 如果有怪刷，检查是否需要展示奇侠
			if #tmpArr > 0 then
				lastHero = tmpArr[#tmpArr]
			else
				lastHero = attrArr[#attrArr]
			end
			local time = math.floor((lastHero.data.posIndex - 1) / 2) * Fight.enterInterval + Fight.monsterRefreshFrame
			self.controler:pushOneCallFunc(time, c_func(self.checkShowParnter,self))
		end
		local dArr = tmpArr
		array.merge2(dArr,attrArr)
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_REFRESH_COUNT,dArr)
	end
	return isWait
end
function LogicalControlerEx:checkShowParnter( )
	-- 此时校验奇侠展示界面
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CHK_SHOW_PARNTER)

	self:checkRoundWait(self.currentCamp)
end
-- 检查场上是否有炸药桶
function LogicalControlerEx:checkHasBomb( )
	for k,v in pairs(self.controler.campArr_2) do
		if self.controler:checkMonsterIsBaoWu(v) then
			return true
		end
	end
	return false
end
-- 炸药桶玩法刷怪
function LogicalControlerEx:refreshBomb(  )
	local hid = self.controler:getMissionBaoWuId()
	local lvRevise = self.controler.levelInfo.__levelRevise
	local tlvRevise = self.controler.levelInfo:getTowerBattleLevelRevise()
	-- lvRevise,tlvRevise,pos,characterRid,
	local tmp = {}
	for i=1,6 do
		local posHero = self:findHeroModel(2,i,false)
		if not posHero then
			table.insert(tmp,i)
		end
	end
	if #tmp > 0 then
		local pos = tmp[BattleRandomControl.getOneRandomInt(#tmp+1,1)]
		local hero = self.controler.reFreshControler:createMonster(hid,Fight.camp_2,
							lvRevise,tlvRevise,pos,Fight.enterType_runIn)
		hero.data:initAure() --初始化光环
		hero:doHelpSkill()
		self:sortCampPos(2)
		return hero
	end
	return nil
end
-- 车轮战刷怪--- 返回刷怪的个数
function LogicalControlerEx:refreshMonster(camp,enterType)
	-- 检查该位置是否有怪，没有则刷新
	local attrArr = {}
	local count = self.controler.reFreshControler:getRefreshCount()
	-- 获取可刷的位置
	local posArr = {}
	for i=1,6 do
		local posHero = self:findHeroModel(camp,i,false)
		if not posHero then
			table.insert(posArr,i)
		end
	end
	local refreshCount = #posArr
	local _refresh = function( index )
		if not index then
			return
		end
		local hero = self.controler.reFreshControler:getRefreshEnemyAttr()
		if hero then
			hero.posIndex = index
			--这里做特殊处理，因为存在相同rid的bug
			local _rid = hero.hid.."_"..index.."_1"..(count + 1)
			-- echo("刷新哪个位置的怪----",i,hero.hid)
			local objHero = ObjectHero.new(hero.hid,hero) -- 此处的hero存的是attr
			objHero.rid = _rid 
			local modelHero = self.controler.reFreshControler:createHeroes(objHero,camp,index,enterType)
			modelHero.data:initAure() --初始化光环
			modelHero:doHelpSkill() -- 做协助技
			-- 召唤之后都要判断一下攻击状态
			modelHero:chkCanAttackByProfession()
			table.insert(attrArr,modelHero)

			-- 2018.01.22 只有车轮战需要加，普通刷怪ai不加
			-- 如果是车轮战,则需要将此怪物加入战斗结算面板中、所以加至waveData里(注意rid统计数据用到)
		    if self.controler.levelInfo:chkIsRefreshType() then
		    	hero.rid = _rid
		    	local wave = self.controler.__currentWave
		    	self.controler.levelInfo:insertOneWaveDataAttr(wave,hero)
		    end
		end
	end
	local _checkFigure = function(figure)
		if figure == 1 then
			if #posArr > 0 then
				_refresh(posArr[1])
				table.remove(posArr,1)
				return true
			end
		elseif figure == 2 then
			for i=1,5,2 do
				local k1,k2 = table.find(posArr,i),table.find(posArr,i+1)
				if k1 and k2 then
					_refresh(i)
					table.remove(posArr,k2) --先移除k2，再移除k1
					table.remove(posArr,k1)
					return true
				end
			end 
		elseif figure == 4 then
			if #posArr < 4 then
				return false
			end
			local have = true
			for j=1,4 do
				if not table.find(posArr,j) then
					have = false
					break
				end
			end
			if have then
				_refresh(1)
				for j=4,1,-1 do
					table.remove(posArr,j)
				end
				return true
			end
			have = true
			for j=3,6 do
				if not table.find(posArr,j) then
					have = false
				end
			end
			if have then
				_refresh(3)
				for j=6,3,-1 do
					table.remove(posArr,j)
				end
				return true
			end
		elseif figure == 6 then
			if #posArr < 6 then
				return false
			end
			_refresh(1)
			posArr = {}
			return true
		end
		return false
	end
	for i=1,refreshCount do
		local figure = self.controler.reFreshControler:getNextRefreshFigure()
		if figure then
			local canRefresh = _checkFigure(figure)
			-- 刷不出来怪了，就直接退出循环
			if not canRefresh then
				break
			end
		end
	end
	-- 如果刷出怪来，则需要排下序、否则可能出现大招选不中新刷出来的怪
	if #attrArr > 0 then
		self:sortCampPos(camp)
	end
	return attrArr
end
-- 统计死亡人数
function LogicalControlerEx:chkStatisticsNum(who )
	if BattleControler:getBattleLabel() == GameVars.battleLabels.missionBombPve then
		if who.camp ~= Fight.camp_1 and not self.controler:checkMonsterIsBaoWu(who) then
			self:updateColletMonkeyNum()
		end
	end
end


-- 试炼中角色拾取对应的buff、rid是发送该数据的玩家id
function LogicalControlerEx:onTrialDrop(info,rid)
	-- info.htype,info.rid,info.bid,info.pos
	if info.htype == Fight.trial_buffUse then--使用buff
		if info.rid then
			local hero = AttackChooseType:findHeroByHeroRid(info.rid,self.controler.campArr_1)
			if hero then
				self.controler:useBattleBuff(hero,info)
			end
		end
	elseif info.htype == Fight.trial_buffHand then--开始拖拽(多人的时候用，现在废弃)
	elseif info.htype == Fight.trial_buffOff then--取消拖拽(多人的时候用，现在废弃)
	end
end







-- -- 巅峰竞技场第一回合处理(废弃)
-- function LogicalControlerEx:crosspeakDoFirstRound( )
-- 	-- self:setCampRoundAuto(self.currentCamp) --手动释放技能
-- 	if not self:readSaveHandle() then
-- 		self:checkNextHandle(self.currentCamp)
-- 	end
	
-- 	-- 发送一条通知、隐藏UI
-- 	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CROSSPEAK_SURE)
-- end

-- 巅峰竞技场检查回合前换人
function LogicalControlerEx:chkchangeHero(camp)
	if Fight.isDummy or self.controler:isReplayGame() then
		return false
	end
	-- echo("LogicalControler巅峰竞技场回合前换人",self:checkIsAutoAttack(camp),self:chkHeroNumIsMax(camp),camp)
	-- 发送的是上回合对应的camp
	local oldCamp = camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
	local info = {camp = oldCamp,nextState = Fight.bzState_buzhen,canCtrl=1}
	-- 没有自动战斗
	-- if self:checkIsAutoAttack(camp) then
	-- 	return false
	-- end
	-- 检查是否能够上阵
	if not self:chkHeroNumIsMax(camp) then
		-- 未满人的情况下，有能上阵的奇侠才能进入换人阶段
		local campArr = self.controler.cpControler:getCanUpHeroArr(camp)
		if #campArr > 0 then
			info.nextState = Fight.bzState_change
		end
	end
	local rid
	if camp == BattleControler:getTeamCamp() then
		rid = self.controler:getUserRid()
	else
		rid = self.controler.levelInfo:getCrossPeakOtherRid()
	end
	if self.controler:checkUserIsAuthFlag(rid) then
		info.canCtrl = 0
	end
	self.controler.server:sendStartRoundHandle(info)
	return true
end
-- 更新战斗开始进入的状态
function LogicalControlerEx:updateStartRoundStatus( info )
	if BattleControler:checkIsCrossPeak() then
		local bState = self:getBattleState()
		-- 战前选人阶段需要校验是否选完，选完，则做一次战前协助技能处理
		if bState == Fight.battleState_formationBefore then
			self:doCrossPeakUpHeroFirst()
		end
		if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
			-- 仙界对决机器人且回合
			self.currentCamp = info.camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
			if info.nextState == Fight.bzState_buzhen then
				self:updateBattleState(Fight.battleState_formation)
			elseif info.nextState == Fight.bzState_change then
				self:updateBattleState(Fight.battleState_changePerson)
			end
			self:chkCrossPeakRobotAi(self.currentCamp)
		end
	else
		self:updateBattleState(Fight.battleState_formation)
		-- 共闯秘境敌方是机器人
		if info.camp == Fight.camp_2 and 
			BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
			self:realStartRound()
		end
	end
end
-- 更新仙剑对决布阵、换人状态
function LogicalControlerEx:chkMultyBattleStatus()
	if BattleControler:checkIsMultyBattle() then
		if BattleControler:checkIsCrossPeak() then
			-- 多人状态显示布阵
			self.controler.formationControler:doChangeHero()
		else
			if self:chkBeforeRoundBuZhen(self.currentCamp) then
				self.controler.formationControler:doChangeHero()
			else
				self:checkNextHandle(self.currentCamp)
			end
		end
	end
end
-- 检验多人同步至指定回合后再检查一次状态的问题
function LogicalControlerEx:checkMultyStatus( )
	local bState = self:getBattleState()
	if bState == Fight.battleState_none then
		-- 如果状态是空状态、然后还在回合中，则需要补发一次回合完成操作
		if self.isInRound then
			self:endRound(self.currentCamp)
		end
		if BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
			self:sendGuildBossGveStartRound()
		end
	end
	-- 刷新ui、状态同步
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_QUICK_TO_ROUND)
end
-- 检查人数
function LogicalControlerEx:chkHeroNumIsMax(camp)
	local oData = self.controler.levelInfo:getCrossPeakOtherData()
	local maxNum = FuncCrosspeak.getSegmentFightInStageMax(oData.seg)
	local count = self.controler:countLiveHero(self.controler:getCampArr(camp))
	if count >= maxNum then
		return true
	end
	return false
end

-- 根据获取到的时间搓更新剩余的布阵时间
function LogicalControlerEx:updateWaitTimeByHandle( leftTime )
	self._leftTIme = leftTime
end
-- 获取各个阶段的等待时间
function LogicalControlerEx:getWaitTime(  )
	local waitTime
	local bState = self:getBattleState()
	if bState == Fight.battleState_switch then
		waitTime = Fight.afterRoundFrame --这个时间不与服务器同步
		return waitTime
	elseif bState == Fight.battleState_formation then
		waitTime = Fight.beforeRoundFrame
	else
		if BattleControler:checkIsCrossPeak() then
			local rid =  self.controler:getUserRid()
			if not self.controler:chkIsOnMyCamp() then
				rid = self.controler.levelInfo:getCrossPeakOtherRid()
			end
			if bState == Fight.battleState_changePerson then
				waitTime = Fight.crossPeakChangeFrame
				-- 托管状态
				if self.controler:checkUserIsAuthFlag(rid) then
					waitTime = Fight.crossPeakLineOffFrame
				end
			elseif bState == Fight.battleState_changePerson then
				waitTime = Fight.crossPeakSkillFrame
				-- 托管状态
				if self.controler:checkUserIsAuthFlag(rid) then
					waitTime = Fight.crossPeakLineOffFrame
				end
			elseif bState == Fight.battleState_selectPerson then
				waitTime = Fight.crossPeakbpFrame
			elseif bState == Fight.battleState_formationBefore then
				waitTime = Fight.crossPeakBeforeChangeFrame
			end
		elseif BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
			if bState == Fight.battleState_spirit then
				waitTime = Fight.spiritPowerFrame
			end
		end
	end
	-- 因为多人战斗是双倍速度，所以时间也需要 * 倍数 [其实这么写不太友好，最好的方式是speed不改变倒计时快慢]
	if BattleControler:checkIsMultyBattle() then
		if self._leftTIme and self._leftTIme > 0 then
			waitTime = self._leftTIme * GameVars.GAMEFRAMERATE
		end
		if waitTime then
			waitTime = waitTime * Fight.doubleGameSpeed
		end
	end
	return waitTime
end
-- 设置换人后协助技能的处理
function LogicalControlerEx:doCrossPeakUpHeroFirst(camp)
	local _doCrossPeakFirst = function( i )
		local campArr = self.controler:getCampArr(i)
		for k,v in pairs(campArr) do
			-- 新上阵的伙伴做协助技、光环相关操作
			if v:isNewInCrossPeak() then
				v.data:initAure() --初始化光环
				v:doHelpSkill()
				v:setNewInCrossPeak(false)
				-- 做属性加成处理(星级品阶、连胜连败)
				self.controler.cpControler:doCrossPeakBuff(v,i)
			end
		end
	end
	if camp then
		_doCrossPeakFirst(camp)
	else
		for i=1,2 do
			_doCrossPeakFirst(i)
		end
	end
end
-- 设置巅峰竞技场换人完成、进入布阵放技能状态
function LogicalControlerEx:crossPeakChange2BuZhen( )
	self:doCrossPeakUpHeroFirst()

	if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
		if self:updateBattleState(Fight.battleState_formation) then
			self:chkCrossPeakRobotAi(self.currentCamp)
		end
	end
end
-- 仙界对决机器人Ai、camp为空说明是不论阵营都做ai操作(比如bp阶段)
function LogicalControlerEx:chkCrossPeakRobotAi(camp)
	if self.controler:chkIsResultComeOut() then
		return
	end
	if Fight.isDummy or self.controler:isReplayGame() then
		return
	end
	camp = camp or BattleControler:getOtherCamp()
	if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
		if camp == BattleControler:getOtherCamp() then
			local ctl = self.controler
			local cpCtrl = self.controler.cpControler
			local time = Fight.crossPeakRobotBPFrame
			local bState = self:getBattleState()
			if bState == Fight.battleState_selectPerson then
				ctl:pushOneCallFunc(time, c_func(cpCtrl.onCrossPeakRobotBP,cpCtrl))
			elseif bState == Fight.battleState_formationBefore then
				ctl:pushOneCallFunc(time, c_func(cpCtrl.onCrossPeakRobotBeforeChange,cpCtrl))
			elseif bState == Fight.battleState_formation then
				ctl:pushOneCallFunc(time, c_func(cpCtrl.onCrossPeakRobotOnBattleSure,cpCtrl))
			elseif bState == Fight.battleState_changePerson then
				ctl:pushOneCallFunc(time, c_func(cpCtrl.onCrossPeakRobotOnBattleChange,cpCtrl))
			end
		end
	end
end
-- 仙界对决战前上下人
-- {rid,partnerId[0代表下阵，1代表主角],posNum[0~6]}
function LogicalControlerEx:updateCrossPeakBeforeChange( info )
	local camp = self.ridCamp[info.rid]
	if tonumber(info.partnerId) == 0 then
		local targetHero = self:findHeroModel(camp, info.posNum, false)
		if targetHero then
			-- echoError ("hid====",targetHero.data.hid,targetHero.data.hid)
			local tmp = {rid = info.rid,pos = info.posNum,camp = camp,hid = targetHero.data.hid,ctype = Fight.change_down}
			self:crossPeakChange(tmp)
		end
	else
		local tmp = {rid = info.rid,pos = info.posNum,camp = camp,hid = info.partnerId,ctype = Fight.change_up}
		self:crossPeakChange(tmp)
	end
	-- 上下人后需要抛通知告知UI刷新确定按钮状态
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_BEFORECHANGE_CHECKSURE)
end

-- 换人上下阵操作
-- {rid,pos,hid,camp,ctype} ctype:0下阵  1上阵
function LogicalControlerEx:crossPeakChange(info )
	-- self:cancleFormation()
	-- 如果当前不是换人状态，那不能换位
	if self._battleState ~= Fight.battleState_changePerson and 
		self._battleState ~= Fight.battleState_formationBefore then
		echoWarn ("不在换人状态的时候-不能换人",self._battleState)
		return
	end
	local campArr = info.camp == Fight.camp_1 and self.controler.campArr_1 or self.controler.campArr_2
	-- 检查该位置是否有人，有则将其下阵(或者致死、否则会无限卡循环)
	local hid 
	local targetHero = self:findHeroModel(info.camp, info.pos, false)
	if targetHero then
		if targetHero.data.isCharacter then
			hid = "1"
		end
		targetHero:doHeroDie(true)
		self.savedFormation = nil --换人的时候并不能布阵
	end
	if info.ctype == Fight.change_up then
		-- 检查此人能否上阵
		local hero = self.controler.levelInfo:getBechHeroInfo(info.hid,info.camp,info.pos)
		if not hero then
			return
		end
		-- 这里检查人是否能上阵
		local cpData = self.controler.levelInfo:getCrossPeakOtherData()
		local maxNum = FuncCrosspeak.getSegmentFightInStageMax(cpData.seg)
		local count = self.controler:countLiveHero(self.controler:getCampArr(info.camp))
		if count >= maxNum then
			echo("上阵人数已满===",count,maxNum)
			return			
		end
		-- dump(info,"infp====")
		-- self.controler.levelInfo:updateBenchUp(info.camp,info.hid)

		local objHero = ObjectHero.new(hero.hid,hero.attr)
		objHero.rid = objHero.hid.."_"..info.pos.."_"..info.camp
		objHero.characterRid = self.controler:getUserRid()

		if objHero.isCharacter then
			hid = "1"
		else
			hid = objHero.hid
		end
		local hero1 = self.controler.reFreshControler:createHeroes(objHero,info.camp,info.pos,Fight.enterType_flash)
		hero1:setNewInCrossPeak(true)
		-- 此时还不能做协助技等，因为还有可能下阵
		-- 如果不是第一回合，说明是替补上阵的、替补上阵的奇侠首次释放大招不消耗怒气
		if self.roundCount ~= 1 then
			hero1:setHasPlayMaxSkill(true)
		end
		if not Fight.isDummy then
			if hero1.healthBar then
				hero1.healthBar:showOrHideBar(true)
			end
		end
	elseif info.ctype == Fight.change_down then
		-- 上面已经处理过了
		-- 发送一条消息，让ui重置该角色下阵了
		if not hid then
			hid = info.hid
		end
	end
	self.controler.levelInfo:updateCrossPeakUpData(info.camp,hid,info.ctype)
	self:sortCampPos(info.camp)

	-- 抛一条通知让UI处理
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_HERO_CHANGE,{hid = hid,posIndex = info.pos,ctype = Fight.change_down})

end

--插入一个英雄
function LogicalControlerEx:insertToMoveQuene( hero )
	local arr = hero.camp ==1 and self.queneArr_1 or self.queneArr_2
	table.insert(arr, hero)
	hero:showOrHideBuffAni(false)
end

--让英雄运动到 队列里面去
function LogicalControlerEx:moveToQuenePos(hero )
	self:insertToMoveQuene(hero)
	local arr = hero.camp ==1 and self.queneArr_1 or self.queneArr_2

end

--判断英雄是否在队列里面
function LogicalControlerEx:checkIsInQuene( hero )
	local arr = hero.camp ==1 and self.queneArr_1 or self.queneArr_2
	if table.indexof(arr, hero) then
		return true
	end
	return false
end


--然后所有的队列清除
function LogicalControlerEx:clearQueneAndInitPos( camp )
	local arr = camp ==1 and self.queneArr_1 or self.queneArr_2
	for i,v in ipairs(arr) do
		v:movetoInitPos(2)
		--显示buff特效
		v:showOrHideBuffAni(true)
	end
	--把他们清除
	table.clear(arr)
end



--移除某个英雄队列
function LogicalControlerEx:removeFromQuene( hero )
	local arr = hero.camp ==1 and self.queneArr_1 or self.queneArr_2
	table.removebyvalue(arr, hero)
end

--更新剩余comb时间
function LogicalControlerEx:updateCombFrame(  )
	if self.leftCombFrame > 0 then
		self.leftCombFrame = self.leftCombFrame -1
		--如果剩余帧数为0了 那么 取消连击
		if self.leftCombFrame == 0 then
		end
	end
end




-----------------------------阵形相关----------------
-----------------------------阵形相关----------------
-----------------------------阵形相关----------------

--[[
	检查回合前布阵
	返回是否需要等待布阵
]]
function LogicalControlerEx:chkBeforeRoundBuZhen(camp)
	echo("LogicalControler中回合前布阵")
	-- 检查序章布阵
	if not self.controler:chkXvZhangBuZhen() then
		return false
	end

	if Fight.isDummy or self.controler:isReplayGame() then
		return false
	end
	if not BattleControler:checkIsCrossPeak() then
		-- 阵营2不会进行布阵
		if camp == 2 then return false end
	end
	-- 自动战斗不布阵
	if self:checkIsAutoAttack(camp) then
		return false
	end

	local wait = true
	if self.roundModel == Fight.roundModel_normal then
		wait = false
	elseif self.roundModel == Fight.roundModel_semiautomated then
		wait = true
		self:setLeftAutoFrame(self:getWaitTime())
	elseif self.roundModel == Fight.roundModel_switch then
		wait = false
	end

	return wait
end

--[[
	检查回合间布阵
	返回是否需要等待布阵
]]
function LogicalControlerEx:chkInRoundBuZhen(camp)
	echo("LogicalControler中回合间布阵")
	--self.leftBuZhenFrame = Fight.buZhenFrame
	if Fight.isDummy or self.controler:isReplayGame() then
		return false
	end
	if not BattleControler:checkIsCrossPeak() then
	   -- 阵营2不会进行布阵
	   if camp == 2 then return false end
	end
	-- 自动战斗不布阵
	if self:checkIsAutoAttack(camp) then
		return false
	end
	
	local wait = false
	if self.roundModel == Fight.roundModel_normal then
		wait = true
		self:setLeftAutoFrame(Fight.autoFightFrame2)
	elseif self.roundModel == Fight.roundModel_semiautomated then
		wait = false
	elseif self.roundModel == Fight.roundModel_switch then
		wait = false
	end

	return wait
end


-- 强制所有人的布阵状态都修改为value值
function LogicalControlerEx:changeAllBuZhenStatus(value )
	local bLabel = BattleControler:getBattleLabel()
	for k,v in pairs(self.userStateMap) do
		v.buzhenState = value
	end
end
-- 检查某玩家是否是在线状态
function LogicalControlerEx:chkUserIsLineOff(rid)
	rid = rid or self.controler:getUserRid()
	if self.userStateMap[rid] and 
		self.userStateMap[rid].lineState == Fight.lineState_lineOff then
		return true
	end
	return false
end
-- 更新布阵按钮状态
function LogicalControlerEx:updateBuZhenStatus(value,rid )
	rid = rid or self.controler:getUserRid()
	self.userStateMap[rid].buzhenState = value
end

-- 检查自己布阵状态
function LogicalControlerEx:getBuzhenState(rid)
	rid = rid or self.controler:getUserRid()
	return self.userStateMap[rid].buzhenState
end

-- 检查布阵按钮显示与否、主要是多人布阵的时候用到
function LogicalControlerEx:checkFormationStatus(rid)
	--取消布阵操作
	self:cancleFormation()
end

-- 
function LogicalControlerEx:checkBZFinish(handleInfo,info)
	if not self.isInRound then
		echo("还没有在回合准备阶段，说明需要追进度")
		self.controler:runGameToTargetRound()
		return false
	end
	-- 如果是从战前布阵走过来的，需要做一下协助技
	local bState = self:getBattleState()
	if bState == Fight.battleState_formationBefore then
		self:doCrossPeakUpHeroFirst()
		self:toRoundStr() --打印一下阵容日志
	end
	-- 如果是某一方点击布阵完成，则只设置这一角色
	self:updateBuZhenStatus(true,handleInfo.rid)
	self:checkFormationStatus(handleInfo.rid)
	if bState == Fight.battleState_battle then
		return true
	end
	if BattleControler:checkIsCrossPeak() then
		if self.currentCamp ~= info.camp then
			-- echoError ("aa=====",self.currentCamp , info.camp)
			return false
		end
		self:updateBattleState(Fight.battleState_battle)
		self.controler.__gameStep = Fight.gameStep.battle
		-- 是否加加成buff
		self.controler.cpControler:checkAddCrosspeakRoundBuff(self.currentCamp)
		-- 仙界对决机器人处理
		if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
			if info.camp == BattleControler:getOtherCamp() then
				self:setCampRoundAuto(self.currentCamp)
			end
		end
		if Fight.isDummy then
			self:doAutoFightAi(handleInfo.rid,info.camp,true)
		else
			-- 这里延迟10帧在做自动战斗就能够避免在布阵阶段点大招结束布阵进入战斗阶段的时候被小技能先抢放
			self.controler:pushOneCallFunc(10,function( )
				-- 开始战斗
				self:doAutoFightAi(handleInfo.rid,info.camp,true)
			end)
		end
		return true
	else
		local wait = self.controler:chkXvZhangTutorialAfterBuzhen()
		if not wait then
			echo("开始战斗==")
			self:updateBattleState(Fight.battleState_battle)
			self.controler.__gameStep = Fight.gameStep.battle
			self:doAutoFightAi(handleInfo.rid)
			return true
		end
		return false
	end
end

-- 检查是否所有人都布阵结束
function LogicalControlerEx:checkIsALLbzFinish( )
	if self.currentCamp == 1 then
		for k,v in pairs(self.userStateMap) do
			if v.lineState == Fight.lineState_lineOn and v.roundAuto == false and v.buzhenState == false then
				return false
			end
		end
	end
	return true
end



--换阵之前阵容备份 { {hero = v,pos = posIndex},...			}
--数组结构
function LogicalControlerEx:backUpFormation(camp)

	--备份前先使用 防止因为网络原因在这个期间2次造成数据冲突
	self:useBackUpFormation(true)
	self.savedFormation = {}
	--只备份属于我自己的阵形 因为我不能操作别人
	-- local campArr = self.controler:getMyCampArr()
	local campArr = camp == Fight.camp_1 and self.controler.campArr_1 or self.controler.campArr_2
	for i,v in ipairs(campArr) do
		-- if v:isMineHero() then
			table.insert(self.savedFormation, {hero = v,pos = v.data.posIndex,camp = v.camp})
		-- end
	end
end


-- 使用clone阵形
-- formationBackUp时是为了先恢复原阵位再换位置，此时对于setToTargetPosIndex有些事情是不用做的
function LogicalControlerEx:useBackUpFormation(formationBackUp)
	if not self.savedFormation then
		return
	end
	for i,v in ipairs(self.savedFormation) do
		v.hero:setToTargetPosIndex(v.pos, formationBackUp,v.camp)
	end
	self.savedFormation = nil

end
-- 根据位置取备份前的伙伴
function LogicalControlerEx:getHeroBackupByPos(pos)
	local result = nil

	if self.savedFormation then
		for _,info in ipairs(self.savedFormation) do
			if info.pos == pos then
				result = info.hero
				break
			end
		end
	end

	return result
end
--获取伙伴备份前的阵容位置
function LogicalControlerEx:getHeroBackupBeforPos( hero )
	if not self.savedFormation then
		return hero.data.posIndex
	end
	for i,v in ipairs(self.savedFormation) do
		if v.hero == hero then
			return v.pos
		end
	end
	return hero.data.posIndex
end

-- 仙界对决交换伙伴位置
-- {rid,type[1:奇侠,2:五灵(暂无)],posSource,posTarget,posRid}
function LogicalControlerEx:updateCrossPeakBeforeChangePos( info )
	local camp = self.ridCamp[info.rid]
	self:exchangeHeroPos(info.posRid,info.posTarget,camp)
end
--交换伙伴的位置
function LogicalControlerEx:exchangeHeroPos( heroRid,posIndex,camp)

	local campArr = camp == Fight.camp_1 and self.controler.campArr_1 or self.controler.campArr_2
	local hero = AttackChooseType:findHeroByHeroRid(heroRid,campArr)
	if BattleControler:getBattleLabel() == GameVars.battleLabels.missionMonkeyPve and
	 camp == Fight.camp_2 then
		-- local monster = AttackChooseType:findHeroByHeroRid(heroRid,self.controler.campArr_2)
		if hero then
 			-- 角色往前走
			hero:setToTargetPosIndex(posIndex,nil,camp)
 		else
 			echoError("这地方不应该走到的",posIndex)
 		end
		self:sortCampPos(hero.camp)
 		return
 	end

 	-- 如果没有找到换位的主体说明复盘已经发生错误
 	if not hero then
 		self.controler:setCancelCheck("没有找到换位主体")
 		return
 	end

	--如果是我方换位的话 那么需要先复原阵形
	-- if hero:isMineHero() then
		--取消布阵操作（不是取消是恢复2017.8.1）
		-- self:cancleFormation()
		self:useBackUpFormation(true)
	-- end
	--清空cachePos
	if hero then
		hero.cachePos = nil
	end
	-- 先把要换的目标点位置换至我当前位置、再换我位置至目标点位置
	local targetHero = self:findHeroModel(camp, posIndex, false)
	if targetHero then
		targetHero:setToTargetPosIndex(hero.data.posIndex,nil,camp)
		--布阵完成通知改变状态
		local elementInfo = self.controler.formationControler:getElementInfoByPos(targetHero.camp,targetHero.data.posIndex)
		targetHero.data:dispatchEvent(BattleEvent.BATTLEEVENT_ELEMENT_FORMATION_FINISH,{posElement = elementInfo.element})
	end

	--[[
	if targetHero and targetHero ~= hero then
		--如果因为网络问题 造成同时抢位, 那么取消我这个操作
		if hero.data.characterRid ~= targetHero.data.characterRid then
			if self.savedFormation then
				--那么使用备份阵容 重新找一次人看看
				self:cancleFormation()
				targetHero = self:findHeroModel(1, posIndex, false)
			end
		end
	end

	if targetHero and targetHero ~= hero then
		--如果因为网络问题 造成同时抢位, 那么取消我这个操作
		if hero.data.characterRid ~= targetHero.data.characterRid then

			echoWarn("这不是我的伙伴targetRid:",targetHero.data.rid,targetHero.data.posIndex,"heroRid", hero.data.rid,hero.data.characterRid)
			self:cancleFormation()
			return
		end

		targetHero:setToTargetPosIndex(hero.data.posIndex)
		--布阵完成通知改变状态
		local elementInfo = self.controler.formationControler:getElementInfoByPos(targetHero.camp,targetHero.data.posIndex)
		targetHero.data:dispatchEvent(BattleEvent.BATTLEEVENT_ELEMENT_FORMATION_FINISH,{posElement = elementInfo.element})
	end
	]]
	hero:setToTargetPosIndex(posIndex,nil,camp)
	-- 布阵完成通知改变状态
	local elementInfo = self.controler.formationControler:getElementInfoByPos(hero.camp,hero.data.posIndex)
	hero.data:dispatchEvent(BattleEvent.BATTLEEVENT_ELEMENT_FORMATION_FINISH,{posElement = elementInfo.element})
	--给数组排序
	self:sortCampPos(hero.camp)
	-- 布阵完成通知UI刷新
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_BUZHEN_CHANGE)
end

--取消当前的布阵行为
function LogicalControlerEx:cancleFormation(noMessage)
	self:useBackUpFormation()
	if not noMessage then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_BUZHEN_CANCLE)
	end
end

--  ========= ###########共闯秘境GVE相关
-- 
function LogicalControlerEx:enterSpiritRound( info )
	self.controler.artifactControler:setUseSpiritUserRid(info.rid)
	self:updateBattleState(Fight.battleState_spirit)
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SPIRIT_START)
	if Fight.isDummy or self.controler:isQuickRunGame() or
	self.controler:isReplayGame() then
		self:readSaveHandle()
	end
end
-- 神力技能使用结束
function LogicalControlerEx:endSpiritRound()
	if Fight.isDummy or self.controler:isQuickRunGame() or
	self.controler:isReplayGame() then
		self:readSaveHandle()
	else
		self.controler.server:sendEndSpiritRound()
	end
end
-- 神力阶段结束
function LogicalControlerEx:doEndSpiritRound( ... )
	self:realStartRound()
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SPIRIT_END)
end
-- 第一回合的某些特殊处理
function LogicalControlerEx:checkHasFirstRoundEspecial(  )
	if BattleControler:checkIsCrossPeak() and 
		(not BattleControler:checkIsCrossPeakModeBP()) then
		if Fight.isDummy then
			return false
		end
		-- 仙界对决常规玩法第一回合不需要布阵、直接开战
		if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
			self.controler.server:sendBuZhenFinishHandle({camp = Fight.camp_1})
		else
			self.controler.server:loadBattleResOver() --等待服务器推送开战消息
		end
		return true
	end
	if BattleControler:checkIsTower() and self.controler:isTowerTouxiAndFirstWaveRound() then
		-- 如果是偷袭战、则不走布阵结果、并且自己给予一个玩家大招下过
		local hero = self.controler:getTowerTouxiHero()
		local skillType = Fight.operationType_BigSkill
		if not hero then
			if #self.controler.campArr_1 > 0 then
				hero = self.controler.campArr_1[1]
				if not hero.data:checkCanGiveSkill() then
					skillType = Fight.operationType_giveSkill
				end
			end
		end
		if hero then
			local opInfo = hero:chooseAppointHandle(skillType)
			self:insertOneHandle(opInfo)

			-- 此时UI不能显示
			if not Fight.isDummy then
				self.controler.gameUi:setIconViewVisible(false)
			end
		else
			echoError("没有可以放大招的英雄，理论上不会走这里")
		end
		return true
	end
	return false
end

-- 战斗服状态机状态(消息兼容)
function LogicalControlerEx:updateBattleState(bState)
	-- if self.controler:isQuickRunGame() then
	-- 	self._battleState = Fight.battleState_none
	-- 	return
	-- end
	if self._battleState == bState then
		return false
	end
	echo("aa====旧",self._battleState,"新",bState)
	self._battleState = bState
	if not Fight.isDummy then
		-- 如果状态机是战斗状态，则需要更新某些状态(ui的表现)
		-- 倒计时时间 、布阵状态
		if bState == Fight.battleState_battle or
			bState == Fight.battleState_wait then
			self:setLeftAutoFrame(nil)
			self:cancleFormation()
		elseif bState == Fight.battleState_formation or
			bState == Fight.battleState_switch or
			bState == Fight.battleState_selectPerson or
			bState == Fight.battleState_formationBefore or
			bState == Fight.battleState_spirit or 
			bState == Fight.battleState_changePerson then
			self:setLeftAutoFrame(self:getWaitTime())
		end
	end
	-- 发送事件给UI显示，用于显示头像等
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLESTATE_CHANGE)
	return true
end
-- 获取战斗状态
function LogicalControlerEx:getBattleState(  )
	return self._battleState
end

-- 加速器校验
function LogicalControlerEx:checkAccelerator(handleInfo,info)
	if Fight.isDummy or self.controler:isQuickRunGame() or (not BattleControler:checkIsMultyBattle()) then
		return
	end
	local _setJiaSuData = function()
		self.__jiasuData = {rid=handleInfo.rid,
							round = handleInfo.round,
							updateCount = self.controler.updateCount,
							time = TimeControler:getBattleServerMiliTime()
						}
	end
	if handleInfo.type == Fight.handleType_battle_small then
		if not self.__jiasuData then
			_setJiaSuData()
			return
		end
		-- 连续的两条小技能操作都是我发的，才做校验
		if self.__jiasuData.round == handleInfo.round then 
			if self.__jiasuData.rid == handleInfo.rid then
				local tmpCount = self.controler.updateCount - self.__jiasuData.updateCount
				local nowTime = TimeControler:getBattleServerMiliTime()
				local tmpTime = nowTime - self.__jiasuData.time
				-- 帧的差数算出来的时间
				local needTime = math.ceil(tmpCount * Fight.frame_time * 1000/Fight.doubleGameSpeed)
				if tmpTime < needTime/2 then
					if not self.__jiasuCount then
						self.__jiasuCount = 0
					end
					self.__jiasuCount = self.__jiasuCount + 1
				end
				self.__jiasuData.updateCount = self.controler.updateCount
			end
		end
		_setJiaSuData()
	end
end
-- 玩家是在加速(只有多人的时候才检查加速、)[废弃了]
function LogicalControlerEx:chekIsJiaSu( ... )
	if self.controler._gameResult ~= Fight.result_none then
		return false
	end
	if Fight.isDummy or self.controler:isQuickRunGame() or (not BattleControler:checkIsMultyBattle()) then
		return false
	end
	if self.__jiasuCount and self.__jiasuCount > 5 then
		if not self.__jiasuTip then
			self.__jiasuTip = true --弹一次tip提示
			WindowControler:showTips( GameConfig.getLanguage("#tid_crosspeak_tips_2030"))
		end
		return true
	end
	return false
end
-- 开始指派谁攻击的时候，记录一下此时对应的framedIdx
function LogicalControlerEx:updateSkillStartFrameIdx( )
	if Fight.isDummy and self.controler:isQuickRunGame() then
		return nil
	end
	self._skillStartIdx = self.controler.updateCount
end
-- 获取上一个技能对应的时间错
function LogicalControlerEx:getSkillFrameTime( )
	if Fight.isDummy and self.controler:isQuickRunGame() then
		return nil
	end
	if not self._skillStartIdx then
		return nil
	end
	local defCount = self.controler.updateCount - self._skillStartIdx
	local time = math.ceil((defCount - 10) * Fight.frame_time * 1000/Fight.thirdGameSpeed)
	if time < 0  then
		time = 0
	end
	return time
end

--输入回合前的日志信息
function LogicalControlerEx:toRoundStr(  )
	-- 记录战斗信息做验证用
	self:recordRoundStr()

	-- 如果关闭日志这些都没有必要做
	if not Fight.isOpenFightLogs then return end

	local function createLog(camp)
		local strT = {}
		table.insert(strT, string.format("回合:%s;种子step:%s,阵营:%s\n", self.roundCount, BattleRandomControl.getCurStep(), camp))
		local campArr = self.controler:getCampArr(camp)
		for i,v in ipairs(campArr) do
			local tmp = string.format("id:%s,pos:%s,hp:%s,energyCost:%s,bf:%s,atk:%s,def:%s,magdef:%s\n", v.data.hid,v.data.posIndex,v.data:hp(),v:getEnergyCost(),v.data:getBuffNums( ),v.data:atk(),v.data:def(),v.data:magdef())
			table.insert(strT, tmp)
		end
		return table.concat(strT)
	end

	local str = createLog(self.currentCamp)
	-- 额外打印一下防守方
	local toStr = createLog(self.currentCamp == 1 and 2 or 1)

	echo(str,"___回合开始时进攻方数据")
	echo(toStr,"___回合开始时防守方数据")

	
	
	return str

end

-- 记录回合前的校验信息
function LogicalControlerEx:recordRoundStr()
	local campArr = self.controler:getCampArr(self.currentCamp)
	local verifyCtrl = self.controler.verifyControler
	verifyCtrl:getOneRoundInfo(self.roundCount,self.currentCamp,BattleRandomControl.getCurStep())
	
	for i,v in ipairs(campArr) do
		verifyCtrl:getOneHeroInfo(v)
	end
end

-- 获取测试的日志
function LogicalControlerEx:getDebugLogsInfo( )
	return self.controler.verifyControler:getTableData()
end