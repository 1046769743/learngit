--[[
	Author: 张燕广
	Date:2017-07-31
	Description: 锁妖塔怪物事件类
]]

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerMonsterModel = class("TowerMonsterModel",TowerEventModel)

function TowerMonsterModel:ctor( controler,gridModel)
	TowerMonsterModel.super.ctor(self,controler,gridModel)
	self:initData()
end

function TowerMonsterModel:initData()
	-- 怪被绕过后透明度
	self.skipedOpacity = 100
	self.monsterScale = 0.8

	local gridInfo = self.grid:getGridInfo()
	local monsterId = gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
	local monsterStatus = gridInfo[FuncTowerMap.GRID_BIT.TYPE_PARAM]
	self:setStatus(monsterStatus)
	self:setEventId(monsterId)
end

function TowerMonsterModel:registerEvent()
	TowerMonsterModel.super.registerEvent(self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_TOWER_DATA_UPDATE,self.updateHp,self)
	-- 杀怪成功
	EventControler:addEventListener(TowerEvent.TOWEREVENT_MONSTER_DIE,self.onKillMonsterSuccess,self)
end

-- 每帧刷新
function TowerMonsterModel:dummyFrame()
	self:updateMonsterStatus()
	-- 检查怪绕过状态
	self:checkSkipStatus()
	-- TODO 2017-12-28 屏蔽该代码，稍候删除相关代码
	-- 检查怪被偷窃状态
	-- self:checkStealedStatus()
	-- 检查警戒怪状态
	self:checkAlertStatus()
end

-- 怪事件回应
function TowerMonsterModel:onEventResponse()
	if self.controler and self.controler.charModel:checkGiveItemSkill() then
		echo("主角将要释放道具....")
		return
	end
	dump(self:getEventId(),"当前怪物ID")
	-- 检查怪绕过状态
	self:checkSkipStatus()

	-- 如果与主角重叠了，不再弹出事件窗口
	if self.isOverlapWithChar then
		return
	end

	if not self:isValid() then
		echo("monster事件无效")
		return
	end
	local grid = self.grid
	local status = nil
	if  self.gridInfo[FuncTowerMap.GRID_BIT.TYPE_PARAM] then
		status = self.gridInfo[FuncTowerMap.GRID_BIT.TYPE_PARAM]
	else
		status = self:getStatus()
	end
	local monsterId = self:getEventId()
	local pos = cc.p(grid.xIdx,grid.yIdx)

	-- 毒ID
	local poisonId = nil
	if self.controler.charModel:checkBePoisoned() then
		poisonId = self.controler.charModel:getGridModel():getEventModel():getEventId()
	end

	local monsterHpData = TowerMainModel:getMonsterInfo(tostring(self.eventId))
	local monsterHpNum = monsterHpData.levelHpPercent or 10000
	local extInfo = self.gridInfo.ext
	if extInfo and extInfo.hpPercentReduce then
		monsterHpNum = monsterHpNum - extInfo.hpPercentReduce 
	end
	WindowControler:showWindow("TowerMonsterView",monsterId,pos,status,poisonId,monsterHpNum)
end

-- 杀怪成功,将怪所在格子对怪model的索引置空,再删除怪model
function TowerMonsterModel:onKillMonsterSuccess(event)
	if event and event.params then
		local monsterId = event.params.monsterId
		if self.eventId == monsterId then
			if self.grid then
				self.grid.eventModel = nil
			end
			self:doMonsterDie()
		end
	end
end

-- 当怪死亡
function TowerMonsterModel:doMonsterDie()
	self:playDieAnim(c_func(self.deleteMe,self))
end

-- 设置是否作弊模式
function TowerMonsterModel:setCheatStatus(isCheat)
	TowerMonsterModel.super.setCheatStatus(self,isCheat)
	if isCheat then
		if self.monsterAnim then
			self.monsterAnim:setVisible(false)
		end
	end
end

-- 创建怪view
function TowerMonsterModel:createEventView()
	local monsterId = self.eventId
	local monsterData = self.monsterData
	local spineId = monsterData.spineId
	local spine = self.controler:createNpcSpineById(spineId)

	local viewCtn = self.grid.viewCtn
	local x = self.grid.pos.x
	local y = self.grid.pos.y
	local z = 0

	local gridZOrder = self.grid:getZOrder()
	-- 创建怪动画，在格子的上层，怪的下层
	self.monsterAnim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_yigejingshi", 
								viewCtn, true, GameVars.emptyFunc);
	self.monsterAnim:pos(x,y)
	self.monsterAnim:zorder(gridZOrder)
	self.monsterAnim:startPlay(true)
	-- 格子也创建了这个红色的格子动画,为了防止重叠动画对玩家造成误解,隐藏掉格子的动画
	self.grid:showAlertedView(false)

	-- 读取怪spine的尺寸
	local npcSourceData = FuncTreasure.getSourceDataById(spineId)
	local size = cc.size(npcSourceData.viewSize[1],npcSourceData.viewSize[2])

	local monsterHpData = TowerMainModel:getMonsterInfo(tostring(self.eventId))
	local monsterHpNum = monsterHpData.levelHpPercent or 10000
	local extInfo = self.gridInfo.ext
	if extInfo and extInfo.hpPercentReduce then
		monsterHpNum = monsterHpNum - extInfo.hpPercentReduce 
	end
	local progressNum = monsterHpNum/100
	if tonumber(progressNum) > 0 then
		self.monsterBtn = UIBaseDef:createPublicComponent( "UI_tower_grid","btn_jian")
		self.hpProgress = UIBaseDef:createPublicComponent( "UI_tower_grid","panel_progress")
		-- 星怪
		if monsterData.star == FuncTowerMap.MONSTER_STAR_TYPE.STAR then
			self.startIcon= UIBaseDef:createPublicComponent( "UI_tower_grid","panel_dingwei")
			self.startIcon:pos(-80,size.height+10)
			spine:addChild(self.startIcon)
		end	
		self.hpProgress:pos(-45,size.height)
		self.monsterBtn:pos(20,30)
		local p = progressNum
		if p > 1 then
			p = math.floor(p)
		else
			p = string.format("%.2f",p)
		end
		self.hpProgress.progress_1:setPercent(progressNum)
		self.hpProgress.txt_1:setString(p.."%")
		
		self.monsterBtn:visible(true)
		spine:addChild(self.monsterBtn)
		spine:addChild(self.hpProgress)
	end	

	self:initView(viewCtn,spine,x,y,z,size)
	self:setViewScale(self.monsterScale)
	local zorder = gridZOrder + 1
	self:setZOrder(zorder)
end

-- 是否与主角重叠在一个格子上
function TowerMonsterModel:isOverlapChar()
	return self.isOverlapWithChar
end

-- 设置事件ID
function TowerMonsterModel:setEventId(eventId)
	TowerMonsterModel.super.setEventId(self,eventId)
	
	self.monsterData = FuncTower.getMonsterData(eventId)
	self.monsterType = self.monsterData.type
	self.monsterStar = self.monsterData.star
end

-- 1正常怪物,2沉睡,3警戒状态
function TowerMonsterModel:updateMonsterStatus()
	local status = self.gridInfo[FuncTowerMap.GRID_BIT.TYPE_PARAM]
	self.monsterStatus = tonumber(status)
	self:checkSleepAnim()
end

-- 播放怪死亡动画
function TowerMonsterModel:playDieAnim(callBack)
	local anim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_guaiwuxiaoshi", 
		self.viewCtn, false, GameVars.emptyFunc);
	anim:pos(self.pos.x,self.pos.y)

	local zorder = self.grid:getZOrder() + 1
	anim:zorder(zorder)

	local animCallBack = function()
		anim:setVisible(false)
		if callBack then
			callBack()
		end
	end

	anim:registerFrameEventCallFunc(26,1,animCallBack)
	anim:startPlay(false,true)
end

-- 检查是否播放沉睡动画
function TowerMonsterModel:checkSleepAnim()
	if not self.grid:hasExplored() then
		return
	end

	if tonumber(self.monsterStatus) == FuncTowerMap.MONSTER_STATUS.SLEEP 
		or tonumber(self.monsterStatus) == FuncTowerMap.MONSTER_STATUS.SKIPED then
		if self.isOverlapWithChar then
			self:playSleepAnim(false)
		else
			self:playSleepAnim(true)
		end
	elseif tonumber(self.monsterStatus) == FuncTowerMap.MONSTER_STATUS.NORMAL then
		self:playSleepAnim(false)
	end
end

function TowerMonsterModel:isSleepMonster()
	return tonumber(self.monsterStatus) == FuncTowerMap.MONSTER_STATUS.SLEEP
		or tonumber(self.monsterStatus) == FuncTowerMap.MONSTER_STATUS.SKIPED
end

-- 播放沉睡动画
function TowerMonsterModel:playSleepAnim(visible)
	if not self.myView then
		return
	end

	-- 不显示睡眠动画且没有睡眠动画
	if not visible and not self.sleeAnim then
		return
	end

	if not self.sleeAnim then
		local anim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_zzz", 
		self.viewCtn, false, GameVars.emptyFunc);
		anim:pos(self.pos.x+40,self.pos.y+self.mySize.height - 50)

		local zorder = self.grid:getZOrder() + 1
		anim:zorder(zorder)

		self.sleeAnim = anim
		self.sleeAnim:startPlay(true)
	end

	self.sleeAnim:setVisible(visible)
end

-- 是否是警戒怪
function TowerMonsterModel:isAlertMonster()
	-- echo("self.monsterStatus------",self.monsterStatus)
	if self.monsterStatus == FuncTowerMap.MONSTER_STATUS.ALERT then
		return true
	end

	return false
end

-- 判断怪是否被绕过
function TowerMonsterModel:checkSkipStatus(event)
	-- if self.monsterStatus == FuncTowerMap.MONSTER_STATUS.SKIPED then
	if self:isSleepMonster() then
		local charModel = self.controler.charModel
		local charGrid = charModel:getGridModel()

		if self.myView and charGrid then
			-- 主角走到了怪的身上
			if charGrid.xIdx == self.grid.xIdx and charGrid.yIdx == self.grid.yIdx then
				self.myView:opacity(self.skipedOpacity)
				self.isOverlapWithChar = true
			else
				self.myView:opacity(255)
				self.isOverlapWithChar = false
			end
		end
	end
end

-- 检查怪是否被偷状态
function TowerMonsterModel:checkStealedStatus()
	if self.controler.isSelectTargetEvent and self.isPreStealed then
		self:updateStealedAnim()
	else
		if self.steadAnim then
			self.steadAnim:setVisible(false)
		end
	end
end

-- 检查警戒怪状态
function TowerMonsterModel:checkAlertStatus()
	if self:isAlertMonster() then
		self:playAlertAnim(true)
	else
		self:playAlertAnim(false)
	end
end

-- 更新警戒动画
function TowerMonsterModel:playAlertAnim(visible)
	if not self.myView then
		return
	end

	if not  visible and not self.alertAnim then
		return
	end

	if not self.alertAnim then
		self.alertAnim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_gantaohao", 
			self.viewCtn, true, GameVars.emptyFunc);
		local zorder = self.grid:getZOrder()
		self.alertAnim:zorder(zorder+1)
		self.alertAnim:pos(self.pos.x+40,self.pos.y+self.mySize.height - 10)
		self.alertAnim:startPlay(true)
	end

	if self.alertAnim and not tolua.isnull(self.alertAnim) then
		self.alertAnim:setVisible(visible)
	end
	-- self.alertAnim:setVisible(true)
end

-- 更新被偷动画
function TowerMonsterModel:updateStealedAnim()
	if not self.steadAnim then
		self.steadAnim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_jihuo", 
			self.viewCtn, true, GameVars.emptyFunc);
		local zorder = self.grid:getZOrder()
		self.steadAnim:zorder(zorder)
		self.steadAnim:pos(self.pos.x,self.pos.y)

		self.steadAnim:startPlay(true)
	end

	self.steadAnim:setVisible(true)
end

-- 设置准备被偷
function TowerMonsterModel:setPreStealed(preStealed)
	self.isPreStealed = preStealed
end

-- 获取怪的类型
function TowerMonsterModel:getMonsterType()
	return self.monsterType
end

-- 获取怪的星，1表示野怪 2表示星怪
function TowerMonsterModel:getMonsterStar()
	return self.monsterStar
end

-- 是否是星怪
function TowerMonsterModel:isStarMonster()
	local monsterData = FuncTower.getMonsterData(self.eventId)
	return monsterData.star == FuncTowerMap.MONSTER_STAR_TYPE.STAR
end

-- 获取怪状态
function TowerMonsterModel:getMonsterStatus()
	return self.monsterStatus
end

function TowerMonsterModel:deleteMyView()
	if self.monsterAnim and not tolua.isnull(self.monsterAnim) then
		self.monsterAnim:removeFromParent()
	end

	if self.sleeAnim and not tolua.isnull(self.sleeAnim) then
		self.sleeAnim:removeFromParent()
	end

	if self.alertAnim and not tolua.isnull(self.alertAnim) then
		self.alertAnim:removeFromParent()
	end

	TowerMonsterModel.super.deleteMyView(self)
end

function TowerMonsterModel:deleteMe()
	self:deleteMyView()

	TowerMonsterModel.super.deleteMe(self)
end

-- 这个函数的调用可以放到dummy函数里
-- 从而去掉对底层model数据更新完毕的消息侦听
-- todo
function TowerMonsterModel:updateHp()
	local monsterHpData = TowerMainModel:getMonsterInfo(tostring(self.eventId))
	local monsterHpNum = 0
	if monsterHpData then
		monsterHpNum = monsterHpData.levelHpPercent or 10000
	end	

	local extInfo = self.gridInfo.ext
	if extInfo and extInfo.hpPercentReduce then
		monsterHpNum = monsterHpNum - extInfo.hpPercentReduce 
		if extInfo.reduceNum and (extInfo.reduceNum > 0) then
			echo("__________ 怪物血量减少量 = _______________",extInfo.reduceNum)
			local monsterName = GameConfig.getLanguage(self.monsterData.name)
			local tips = GameConfig.getLanguageWithSwap("#tid_tower_ui_075",monsterName,(extInfo.reduceNum/100).."%")
			if not TowerMainModel:checkIsMonsterKilled( self.eventId ) then
				-- tips = GameConfig.getLanguageWithSwap("#tid_tower_ui_095",monsterName)
				WindowControler:showTips(tips)
			end
		end
	end

	local progressNum = monsterHpNum/100
	if tonumber(progressNum) ~= 0 and tonumber(progressNum) ~= 100 then
		echo(tolua.isnull(self.hpProgress),"__________!!!!!_____@@@@@@@@@@@@@____________________________")
		echo("__________ 都走到这里了 血量progressNum____________",progressNum)
		if self.hpProgress and self.hpProgress.progress_1 then
			echo("__________ 走到这里算血量设置成功! 血量progressNum____________",progressNum)
			self.hpProgress.progress_1:setPercent(progressNum)
			local p = progressNum
			if p > 1 then
				p = math.floor(p)
			else
				p = string.format("%.2f",p)
			end
			self.hpProgress.txt_1:setString(p.."%")
		end
	end	
end

-- 获取上次挑战该怪的选择的星级难度
function TowerMonsterModel:getLastStar()
	local extInfo = self.gridInfo.ext
	local star = 0
	if extInfo then
		star = extInfo.star
	end
	return star
end

return TowerMonsterModel
