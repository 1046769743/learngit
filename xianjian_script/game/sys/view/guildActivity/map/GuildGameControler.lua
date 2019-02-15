--[[
	Author: 张燕广
	Date:2017-10-25
	Description: 公会活动小游戏控制器
]]

local GuildCharModelClazz = require("game.sys.view.guildActivity.model.GuildCharModel")
local GuildPlayerModelClazz = require("game.sys.view.guildActivity.model.GuildPlayerModel")

local GuildMonsterModelClazz = require("game.sys.view.guildActivity.model.GuildMonsterModel")
local GuildGridModelClazz = require("game.sys.view.guildActivity.model.GuildGridModel")

local GuildGameMapClazz = require("game.sys.view.guildActivity.map.GuildGameMap")

GuildGameControler = class("GuildGameControler")

function GuildGameControler:ctor(ui)
	echo("______ 控制器初始化 —————————————————— ")
	self.ui = ui
	self.updateCount = 0
	self:registerEvent()
	self:initData()
	self:initMap()

	self:createGrids()
	self:createChar()
	self:createOtherPlayers()
	
	-- 被冻住的玩家
	self.frozenRid = ""
end

function GuildGameControler:registerEvent()
	-- 标记和取消标记怪
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_MARK_MONSTER, self.markMonster, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_UNMARK_MONSTER, self.unMmarkMonster, self)
	-- 某人打败了一个怪
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_SOMEONE_DEFEAT_MONSTER, self.someoneDefeatMonster, self)
	
	-- 一轮战斗结算数据准备完成 移动出怪展示
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_GUIDE_TRIGGER_COMBO, self.onOneRoundAccountDataReady, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_TEAM_ACCOUNT_DATA_READY, self.onOneRoundAccountDataReady, self)
	
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_SOMEONE_QUIT, self.onSomeOneQuit, self)
	EventControler:addEventListener("notify_guild_activity_sync_player_pos_5666", self.syncPlayerPosition, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_CHECK_SIM_ERROR, self.onCheckSIMError, self)
end
function GuildGameControler:markMonster( event )
	local index = event.params.index
	local rid = event.params.rid
	echo("\n\n _________ 收到标记怪消息 index,rid ___ ",index,rid)
	if self.monsterModelArr and self.monsterModelArr[index] then
		self.monsterModelArr[index]:updateFlag( true )
	end
end
function GuildGameControler:unMmarkMonster( event )
	local index = event.params.index
	local rid = event.params.rid
	echo("\n\n _________ 收到 【取消】 标记怪消息，index,rid ___ ",index,rid)
	if self.monsterModelArr and self.monsterModelArr[index] then
		self.monsterModelArr[index]:updateFlag( false )
	end
end

function GuildGameControler:someoneDefeatMonster( event )
	local _data = event.params.data
	if FuncGuildActivity.isDebug then
		dump(_data, "场景中收到== 某人打败了一个怪")
	end
	self:showMonsterKilledEffect( _data )
end

function GuildGameControler:showMonsterKilledEffect( _data )
	local killedData = _data
	-- 进入此函数 则特效展示算是走过 清除相关缓存
	GuildActMainModel:clearMonsterKilledCache(killedData.index) 
	local monsterData = GuildActMainModel:getMonsterByIndex(killedData.index)
	local monsterId = "被打败的怪id初始化为"

	if monsterData then
		monsterId = monsterData.id
	end
	local monsterType = FuncGuildActivity.getMonsterTypeByMonsterId( monsterId )
	-- 播放炸开动画
	if killedData.isBoom then
		local delayShowBoomEff =  function()
			if self.gridArr[killedData.index] then
				self.gridArr[killedData.index]:playAnimation()
			end
		end
		self.ui:delayCall(c_func(delayShowBoomEff),killedData.boomDelayTime)
	end

	-- 冻住玩家
	if killedData.isFrozenChar then
		self.frozenRid = killedData.rid
		self:addFrozenEffect()
	end
	-- 展示进包裹奖励
	if killedData.gotReward then
		if FuncGuildActivity.isDebug then
			dump(killedData.gotReward, "击杀金怪奖励")
		end
		FuncCommUI.startRewardView(killedData.gotReward)
		local dataArr = string.split(killedData.gotReward[1],",")
		local itemName = FuncItem.getItemName(dataArr[2]) 
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_084"),1.5)
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_085")..itemName,1.5)
		-- if self.gridArr[killedData.index] then
		-- 	self.gridArr[killedData.index]:playAnimation()
		-- end
	end

	-- 注意可能在队伍信息回复过程中,另一个玩家打败了这个怪时这个怪还没创建完毕
	-- 所以要先判断是否存在
	if not self.monsterModelArr[killedData.index] then
		echoWarn("___这个怪物不存在,",killedData.index)
	else
		self.monsterModelArr[killedData.index]:deleteMe()
		self.monsterModelArr[killedData.index] = nil
	end

	-- 更新食材和积分
	if killedData.score then
		self.ui:updateTeamScore()
	end
	if killedData.ingredients then
		for k,v in pairs(killedData.ingredients) do
			self.ui:updateTeamMaterials(k)
		end
	end
end

-- todo 
-- 增加冰冻 效果
function GuildGameControler:addFrozenEffect()
	-- body
end
-- 某个玩家退出挑战
function GuildGameControler:onSomeOneQuit( event )
	local rid = event.params.rid
	if not self.playerModelArr[rid] then
		echoWarn("_____ 没有这个角色:",rid)
	else
		self.playerModelArr[rid]:deleteMe()
		self.playerModelArr[rid] = nil
	end
end

-- 一轮战斗结算 碰撞相消
function GuildGameControler:onOneRoundAccountDataReady( event )
	dump(event.params,"onOneRoundAccountDataReady event.params--------------------")
	
	for k,v in pairs(self.monsterModelArr) do
		v:updateFlag(false)	
		v:updateClickFlag(false)	
	end

	if event.params and event.params.totalReward then
		self.isLastRound = true
		self.totalReward = event.params.totalReward
		dump(event.params,"event.params-------------------")
	end

	-- dump(event.params,"onOneRoundAccountDataReady event.params--------------------")

	local curRound = GuildActMainModel:getChallengeRound()
	echo("______ onOneRoundAccountDataReady curRound=______ ",curRound,self.totalReward)

	-- TODO 目前看为nil表示玩法结束
	if not curRound then
		curRound = GuildActMainModel:getMaxRound() + 1
		self.isLastRound = true
	end
	echo("curRound==========",curRound)

	if GuildActMainModel.hasNotCombo[curRound-1] == true or GuildActMainModel:isInNewGuide() then
		-- 设置处于碰撞状态
		echo("______ onOneRoundAccountDataReady 设置为碰撞中 ______ ")
		GuildActMainModel:setIsInCombo(true)
		-- 获取碰撞前的怪数组
		self._monsterList = GuildActMainModel:getPreComboMonsters()

		if GuildActMainModel:isInNewGuide() then
			self._monsterList = GuildActMainModel:getMonsterList( )
			echo("引导中.....")
			dump(self._monsterList,"self._monsterList--------------")
		else
			echo("非引导中.....")
		end

		-- 碰撞前消除被冻住玩家的效果
		-- 一轮寿命的怪自己爆掉
		self.frozenRid = ""  
		GuildActMainModel.frozenRid = nil
		for k,v in pairs(self._monsterList) do
			local monsterType = FuncGuildActivity.getMonsterTypeByMonsterId( v.id )
			if monsterType == FuncGuildActivity.monsterType.gold 
				or monsterType == FuncGuildActivity.monsterType.blue then
				local tips = "_________蓝色怪和金色怪combo前消掉 == 场景中做表现 __________"
				echo(tips)
				-- WindowControler:showTips( { text = tips } )
				local index = tostring(v.index)
				if self._monsterList[index] then
					self._monsterList[index].status = 1
					self._monsterList[index].id 	= nil
					self._monsterList[index].index  = nil
				end
				echo("____________  删除第k个怪model",index)
				if self.monsterModelArr[index] then
					if self.gridArr[index] then
						self.gridArr[index]:playAnimation()
					end
					self.monsterModelArr[index]:deleteMe()
					self.monsterModelArr[index] = nil
				end
			end
		end
		-- dump(self._monsterList, "碰撞前的怪数组 ____")
		-- self._haveBeatMonsters = false
		self.moveArr = {}
		self:moveMonsters()
		GuildActMainModel.hasNotCombo[curRound-1] = false
	end
end

function GuildGameControler:syncPlayerPosition( serverData )
	if FuncGuildActivity.isDebug then 
		dump(serverData.params, "同步玩家走动坐标")
	end
	if serverData.params.params.data then
		local _data = serverData.params.params.data
		-- dump(_data, "服务器推送:玩家走动坐标")
		local rid = _data.rid
		if tostring(rid) ~= self.frozenRid then
			local targetPos = {}
			targetPos.x = _data.posX
			targetPos.y = _data.posY
			targetPos.speed = 9
			if self.playerModelArr[rid] then
				self.playerModelArr[rid]:moveToPoint(targetPos)
			end
		else
			-- WindowControler:showTips( { text = "玩家已经被冻住" } )
		end
	end
end

-- 校验错误 强制同步服务器数据
function GuildGameControler:onCheckSIMError( event )
	for k,v in pairs(self.monsterModelArr) do
		v:deleteMe()
	end
	self.monsterModelArr = {}
	self:resumeMonsterAtOnce()
end



--========================================================
function GuildGameControler:initData()
	-- 格子数组,通过格子id可以索引
	self.gridArr = {}
	-- 小怪数组，通过格子id可以索引
	self.monsterModelArr = {}

	self.charSize = {width=180,height=180}
	self.playerModelArr = {}
end

function GuildGameControler:initMap()
	self.map = GuildGameMapClazz.new(self)
	self.map:initMap()

	local backLayer = self.map.backLayer
	local frontLayer = self.map.frontLayer
	local sence = FuncGuildActivity.getActivityBg(_activityId)
	echo("___________ sence ________",sence)
	self.sceneControler = MapControler.new(backLayer, frontLayer, sence, false);
	self.sceneControler:updatePos(0,0)

	self.map:scheduleUpdateWithPriorityLua(c_func(self.updateMonsterFrame,self),0)

	self.mapTargetPos = GuildActMainModel:getMapPos()
	-- 如果是新手引导期间则 默认回到最右边
	if GuildActMainModel:isInNewGuide() then
		self.mapTargetPos = {x=0,y=0}
	end
	-- if not self.mapTargetPos then
	dump(self.mapTargetPos, "self.mapTargetPos", nesting)
	-- local pos = GuildActMainModel:getMapPos()
	-- local worldX = -1200
	-- local worldY = 0
	-- local pos = {x=1280,y=0}
	-- self:moveMap(worldX,worldY)
	-- self:moveMap(pos)
end

function GuildGameControler:moveToTargetPoint( targetPos )
	local originPos = self.map:getMapPos()
	if targetPos.x > FuncGuildActivity.mapOffsetMaxX then
		targetPos.x = FuncGuildActivity.mapOffsetMaxX
	elseif targetPos.x < FuncGuildActivity.mapOffsetMinX then 
		targetPos.x = FuncGuildActivity.mapOffsetMinX
	end
	if targetPos.x - originPos.x > 30 then
		self:moveMap({x=originPos.x+10,y=originPos.y})
	elseif targetPos.x - originPos.x < -30 then
		self:moveMap({x=originPos.x-10,y=originPos.y})
	else
		self.mapTargetPos = nil
	end
end

function GuildGameControler:moveToTargetPointOnStep()
	if self.mapTargetPos then
		local x = self.mapTargetPos.x
		local y = self.mapTargetPos.y
		self:moveMap({x=x,y=y})

		self.mapTargetPos = nil
	end
end

function GuildGameControler:moveMap( pos )
	if pos then
		-- dump(pos, "\n\n\n\n\n ================================= 移动地图", nesting)
		self.map:moveMap(pos.x,pos.y)
	end
end

function GuildGameControler:getGameMap()
	return self.map
end

--=====================================================================
-- 创建格子
--=====================================================================
function GuildGameControler:createGrids()
	for k=20,1,-1 do
		self:createOneGrid(tostring(k))
	end
	local posx,posy = self:getGridPosition( 20 )
	posx = posx - 100

	local panelList = self.map:getCachePanel()
  	local ctn_guo = UIBaseDef:cloneOneView(panelList[2])
  	ctn_guo:parent( self.map:getMiddleLayer() )
  	ctn_guo:setPositionX(posx-20)
  	ctn_guo:setPositionY(posy+20)
	if not self.xuanzhuanAni then
		self.xuanzhuanAni = self.ui:createUIArmature("UI_xianmenggve","UI_xianmenggve_chuansongmen", ctn_guo, true,GameVars.emptyFunc)
		-- self.xuanzhuanAni:setScaleX(0.5)
	end
	self.xuanzhuanAni:startPlay(true)
end
function GuildGameControler:createOneGrid( _Idx )
	local middleLayer = self.map:getMiddleLayer()
	local gridModel = GuildGridModelClazz.new(self,_Idx)
	local xpos,ypos = self:getGridPosition( _Idx )
	-- echo("\n__________ xpos,ypos",xpos,ypos)
	-- echo("\n__________ xpos-900,ypos-550",xpos-900,ypos-550)

	local panelList = self.map:getCachePanel()
	local gridView = UIBaseDef:cloneOneView(panelList[1])
	local size = gridView:getContentSize()

	gridView.mc_liangzhen:setVisible(false)
	gridView.panel_da:setVisible(false)
	-- -- 点击区域测试代码
	-- local node = display.newNode()	
	-- local color = color or cc.c4b(255,0,0,120)
	-- local layer = cc.LayerColor:create(color)
	-- node:addChild(layer)
	-- node:setTouchEnabled(true)
	-- node:setTouchSwallowEnabled(true)

	-- node:addto(middleLayer,1):size(10,10)
	-- node:anchor(0,0)
	-- node:pos(0,0)
	-- node:parent(gridView)
	-- layer:setContentSize(node:getContentSize() )
	--============

	gridModel:initView(middleLayer,gridView,xpos,ypos,0,size)
	-- 创建格子位置的怪消除动画
	gridModel:createComboAmature(xpos,ypos)
	self.gridArr[_Idx] = gridModel
end

--=====================================================================
-- 创建怪
--=====================================================================
-- 出怪 在GuildActivityInteractView中调用
function GuildGameControler:setAppearControlVar()
	self.beginAppearMonster = true
	self._monsterNum = 20
	self._frameCount = 0
end


function GuildGameControler:showSceneView()
	-- 引导中的时间是不正式的
	if GuildActMainModel:isInNewGuide() then
		self.ui:oneRoundCountdown()
		echo("引导中，一轮倒计时............")
		return
	end

	local curRound = GuildActMainModel:getChallengeRound()
	local cdName = GuildActMainModel.eventName_oneRoundTimer..curRound
	local leftTime = TimeControler:getCdLeftime(cdName)
	local configTime =  FuncDataSetting.getOneAccountTime()
	local curHitEndTime = GuildActMainModel:getHitEndTime(curRound)
	echo("_______ leftTime,configTime,curRound,curHitEndTime", leftTime,configTime,curRound,curHitEndTime)
	echo("_______ GuildActMainModel.isInReconnection,GuildActMainModel.isInBattleResume", GuildActMainModel.isInReconnection,GuildActMainModel.isInBattleResume)
	if (leftTime > configTime) 
		and (not curHitEndTime) 
		and not GuildActMainModel.isInReconnection 
		and not GuildActMainModel.isInBattleResume 
	then
		echo("___不是重连,不是战斗后恢复,剩余时间超过配置时间,没有设置hitEndTime,=== 发送hitEndTime请求___ ", GuildActMainModel.isInBattleResume)
		local function callBack()
			self.ui:delayCall(c_func(self.ui.oneRoundCountdown,self.ui),0.5)
		end
		GuildActMainModel:sentStartCountDown(callBack)
	else
		if (leftTime <= configTime) then
			GuildActMainModel:setIsInCombo( false )
		end
		echo("_______倒计时开始 ... ____________")
		GuildActMainModel.isInReconnection =  false
		GuildActMainModel.isInBattleResume =  false
		self.ui:oneRoundCountdown()
	end
end

function GuildGameControler:monsterAppear()
	if not self.beginAppearMonster then
		return
	end
	if self._monsterNum < 1 then
		self.beginAppearMonster = nil
		self:showSceneView()
		return
	end
	if (self._frameCount % 5 == 0) then
		local gridIdx = tostring(self._monsterNum)

		-- local monsterList = GuildActMainModel:getRandomMonsterData( _gridIdx )
		local data = GuildActMainModel:getRandomMonsterData( gridIdx )
		if data.status == 0 then
			local params = {
				index = gridIdx,
				monsterId = data.id,
			}
			self:createOneMonster(params)
		end
		self._monsterNum = self._monsterNum - 1
	end
	self._frameCount = self._frameCount + 1
end

-- 战斗后瞬间恢复怪
-- 如果是本轮则直接恢复怪后进入剩余倒计时
-- 如果已经接到新一轮结算,还没演示本轮碰撞,则不演示碰撞 直接出最终的怪
-- 防止在碰撞的时候,别人已经开始在标记了,造成状态混乱
function GuildGameControler:resumeMonsterAtOnce(_callback)
	for monsterNum = 20,1,-1 do
		local gridIdx = tostring(monsterNum)
		-- local monsterList = GuildActMainModel:getRandomMonsterData( _gridIdx )
		local data = GuildActMainModel:getRandomMonsterData( gridIdx )
		local curRound = GuildActMainModel:getChallengeRound()
		local cdName = GuildActMainModel.eventName_oneRoundTimer..curRound
		local leftTime = TimeControler:getCdLeftime( cdName )
		GuildActMainModel:setIsInCombo( false )
		self.ui:initTeamMaterials()
		self.ui:updateTeamScore()
		local configTime =  FuncDataSetting.getOneAccountTime()
		if (leftTime > configTime)-- and (GuildActMainModel.hasNotCombo[curRound-1] == true) 
			--and (not GuildActMainModel.isInReconnection) 
			and not GuildActMainModel:getHitEndTime(curRound) then
			GuildActMainModel:setIsInCombo( true )
			-- data = GuildActMainModel:getOldMonsterData( gridIdx )
			self.ui:initTeamMaterials()
			self.ui:updateTeamScore()
		end
		-- dump(data,"获取到的一个怪数据")
		if data and data.status == 0 then
			local params = {
				index = gridIdx,
				monsterId = data.id,
			}
			self:createOneMonster(params)
		else
			-- 检查是否有还需要做的爆炸特效
			self:checkRemainToShowBoom(gridIdx)
		end
		monsterNum = monsterNum - 1
	end
	if _callback then
		echo("_______ 迅速恢复怪完毕 _________ ")
		_callback()
	end
	self:showSceneView()
end

function GuildGameControler:createOneMonster(params,isCreateFromHead)
	local gameMiddleLayer = self.map:getGameMiddleLayer()
	local monsterModel = GuildMonsterModelClazz.new(self,params)
	local enemyInfoCfg = require("level.EnemyInfo")
	local spineId = enemyInfoCfg[tostring(params.monsterId)]["baseTrea"]
	local spine = self:createNpcSpineById(spineId)
	spine:scale(0.7)

	local xpos = nil
	local ypos = nil
	if isCreateFromHead then
		xpos,ypos = self:getGridPosition( 20 )
		xpos = xpos - 80
	else
		xpos,ypos = self:getGridPosition( params.index )
	end
	local zpos = 0

	-- 读取怪spine的尺寸
	local npcSourceData = FuncTreasure.getSourceDataById(spineId)
	local size = cc.size(npcSourceData.viewSize[1],npcSourceData.viewSize[2])
	size.width = size.width * 1.5
	monsterModel:initView(gameMiddleLayer,spine,xpos,ypos,zpos,size)

	monsterModel:initFlag()
	if not self.monsterModelArr then
		self.monsterModelArr = {}
	end
	
	-- 2018.10.08容错处理，尝试解决怪spine重叠问题
	local tempMonsterModel = self.monsterModelArr[params.index]
	if tempMonsterModel and tempMonsterModel.deleteMe then
		tempMonsterModel:deleteMe()
	end
    self.monsterModelArr[params.index] = monsterModel
end

-- 创建npcId spine动画
function GuildGameControler:createNpcSpineById(npcId)
	local npcSourceData = FuncTreasure.getSourceDataById(npcId)

	local npcAnimName = npcSourceData.spine
    local npcAnimLabel = npcSourceData.stand

    local npcNode = nil
    local npcAnim = nil
    if npcId == nil or npcAnimName == nil or npcAnimLabel == nil then
        echoError("npcId =",npcId,",npcAnimName=",npcAnimName,",npcAnimLabel=",npcAnimLabel)
    else
        local spbName = npcAnimName .. "Extract"
        npcAnim = ViewSpine.new(spbName, {}, nil,npcAnimName);
        npcAnim:playLabel(npcAnimLabel);
        npcAnim:setScale(1.0)
    end
    return npcAnim
end

-- 检查待做特效
--Author:      zhuguangyuan
--DateTime:    2018-01-16 20:46:04
--Description: 
function GuildGameControler:checkRemainToShowBoom( _index )
	local index = tostring(_index)
	local boomCachedData = GuildActMainModel:getMonsterKilledCache(index)
	if boomCachedData then
		echo("____________ 战斗后迅速恢复怪过程中检查是否需要播放 特效______________")
		-- self.ui:delayCall(c_func(self.showMonsterKilledEffect,self,boomCachedData),2)
		self:showMonsterKilledEffect( boomCachedData )
	end
end
--=====================================================================
-- 创建主角
--=====================================================================
function GuildGameControler:createChar()
	echo("创建主角_________ ")
	local charOffsetY = self.charOffsetY

	local gameFrontLayer = self.map:getGameMiddleLayer() -- self.map:getGameMiddleLayer()
	local cacheCharPos = GuildActMainModel:getCharPos()

	local xpos = cacheCharPos.x or self.map.initCharPos.x
	local ypos = cacheCharPos.y or  self.map.initCharPos.y
	local zpos = 0

	local charSex = UserModel:sex()
	self.charModel = GuildCharModelClazz.new(self,charSex)
	self.charSpineNode = self:getCharSpine(charSex)
	self.charModel:initView(gameFrontLayer,self.charSpineNode,xpos,ypos,zpos,self.charSize)
	-- 初始化主角名字和头衔
	local panelList = self.map:getCachePanel()
	local playerTitleView = UIBaseDef:cloneOneView(panelList[4])

	-- self.curMemberList = GuildActMainModel:getCurTeamMembers()
	local playerInfo = GuildModel:getMemberInfo(UserModel:rid())
	self.charModel:initPlayerNameAndTitle( self.charSpineNode,playerTitleView,playerInfo )
	self.playerModelArr[UserModel:rid()] = self.charModel
end

-- 创建主角spine动画
function GuildGameControler:getCharSpine(sex)
	local playerSpine = GarmentModel:getCharGarmentSpine()
	return playerSpine
end

-- 创建其他玩家
function GuildGameControler:createOtherPlayers()
	self.curMemberList = GuildActMainModel:getCurTeamMembers()
	local playerNum = 1
	for k,v in pairs(self.curMemberList) do
		if v.rid ~= UserModel:rid() then
			local playerInfo = GuildModel:getMemberInfo(v.rid)
			local gameMiddleLayer = self.map:getGameMiddleLayer() -- self.map:getGameMiddleLayer()
			local xpos = self.map.initOtherPlayersPos[playerNum].x
			local ypos = self.map.initOtherPlayersPos[playerNum].y
			local zpos = 0

			local playerSex = FuncChar.getCharSex(playerInfo.avatar)
			local garmentId = playerInfo.garmentId ~= 0 and playerInfo.garmentId or GarmentModel.DefaultGarmentId
			local playerSpine = GarmentModel:getSpineViewByAvatarAndGarmentId(playerInfo.avatar, garmentId)
			local playerModel = GuildPlayerModelClazz.new(self,playerSex)
			playerModel:initView(gameMiddleLayer,playerSpine,xpos,ypos,zpos,self.charSize)
			-- 初始化玩家名字和头衔
			local panelList = self.map:getCachePanel()
			local playerTitleView = UIBaseDef:cloneOneView(panelList[4])
			playerModel:initPlayerNameAndTitle( playerSpine,playerTitleView,playerInfo )

			self.playerModelArr[v.rid] = playerModel
			playerNum = playerNum + 1
		end
	end
end

--=====================================================================
-- 每帧刷新方法
--=====================================================================
function GuildGameControler:updateMonsterFrame(dt)
	self.updateCount = self.updateCount +1
	self:monsterAppear()
	if self.monsterModelArr then
		for k,v in pairs(self.monsterModelArr) do
			v:updateFrame()
		end
	end
	if self.playerModelArr then
		for k,v in pairs(self.playerModelArr) do
			v:updateFrame()
		end
	end
	--深度排列
	self:depthSort()

	if self.mapTargetPos then
		self:moveToTargetPoint(self.mapTargetPos)
	end
end


function GuildGameControler:depthSort(  )
	if self.updateCount %30 ~= 1 then
		return
	end
	local layer = self.map.gameMiddleLayer
	local children = layer:getChildren()
	local sortFunc = function ( a,b )
		local x1,y1 = a:getPosition()
		local x2,y2 = b:getPosition()
		return  y1 > y2
	end

	table.sort( children, sortFunc )
	for i,v in ipairs(children) do
		v:setLocalZOrder(i)
	end

end

function GuildGameControler:deleteMe()
	if self._died then
		echoError("为什么会重复销毁")
		return
	end
	self._died = true
	echo("____删除GuildGameControler")
	EventControler:clearOneObjEvent(self)
	--做好销毁
	self:deleteGrids()
	self:deleteMonsters()

	for k,v in pairs(self.playerModelArr) do
		v:deleteMe()
	end
	self.playerModelArr = nil
	
	if self.map then
		self.map:deleteMe()
	end

	self.map:unscheduleUpdate()
end

-- todo
function GuildGameControler:deleteGrids()
	if self.gridArr then
		for k,v in pairs(self.gridArr) do
			v:deleteMe()
		end
		self.gridArr = nil
	end
end
--todo
function GuildGameControler:deleteMonsters()
	if self.monsterModelArr then
		for k,v in pairs(self.monsterModelArr) do
			v:deleteMe()
		end
		self.monsterModelArr = nil
	end
end


--=====================================================================
-- 怪相消展示
-- self._monsterList 是否被打败的标记vector
-- self.monsterModelArr 怪modelvector
-- self.moveArr 移动数组
--=====================================================================
-- 移动怪并填充
function GuildGameControler:moveMonsters()
	echo("@@@@@__________________ 新一轮移动怪 ________________ ")
	if not self._doNotInitDistance then
		echo("________ 重新初始化距离")
		for k,v in pairs(self._monsterList) do
			v.distance = 0
			v.lastDistance = 0
		end
	end
	self.haveMoveNum = 0
	self.needToMoveNum = 0

	local golbalDistance = 0
	local _index = nil
	local _preIndex = nil
	for i=1,20 do
		_index = tostring(i)
		_preIndex = tostring(i-golbalDistance)

		if self._monsterList[_index].status == 0 and (golbalDistance > 0) then
			local moveArr = self:getMoveArr( i-1,tonumber(_preIndex))
			if table.length(moveArr) > 0 then
				self:moveOneMonster(moveArr,_preIndex,_index )
			end
		elseif self._monsterList[_index].status == 1 then
			-- echo("________ 被打败 _index_____",_index)
			golbalDistance = golbalDistance + 1
		end
	end

	local function callback()
		-- 2018.09.14 引导中强制为0，解决引导不comp导致的卡死问题 by ZhangYanguang
		-- 本次问题解决第1处修改，共2处
		if GuildActMainModel:isInNewGuide() then
			self.needToMoveNum = 0
		end

		if self.needToMoveNum == 0 then
			self:getComboIndex()
		end
	end
	self:bornNewMonsters( golbalDistance,callback )
end

function GuildGameControler:bornNewMonsters( golbalDistance,callback )
	if (self._monsterList["20"].status == 1) and (not self._newComboRound) then
		local i = 0 
		self.newComeOutNum = 0
		while(golbalDistance>self.newComeOutNum) do
			self.newComeOutNum = self.newComeOutNum + 1
			-- 创建怪
			local newMonsterId = GuildActMainModel:getOneNewMonsterId()
			echo(" ### 出新怪 id = ",newMonsterId)
			_index = tostring(20+self.newComeOutNum)
			local params = {
				index = _index,
				monsterId = newMonsterId,
			}
			local isCreateFromHead = true
			self:createOneMonster(params,isCreateFromHead)
			if not self._monsterList[_index] then
				self._monsterList[_index] = {}
			end
			self._monsterList[_index].id = newMonsterId
			self._monsterList[_index].index = _index
			self._monsterList[_index].status = 0
			self._monsterList[_index].distance = 0 

			-- 移动
			local _preIndex = tostring(tonumber(_index)-golbalDistance)
			local moveArr = self:getMoveArr(tonumber(_index)-1,tonumber(_preIndex))
			if table.length(moveArr) > 0 then
				self:moveOneMonster(moveArr,_preIndex,_index )
			end
		end
	end
	if callback then
		callback()
	end
end


function GuildGameControler:getMoveArr( _begin,_end )
	local moveArr = {}
	for n=_begin,_end,-1 do
		local targetPos  = {}
		targetPos.x, targetPos.y = self:getGridPosition( n )
		-- echo("__________n targetPos.x, targetPos.y  ",n,targetPos.x, targetPos.y)
		targetPos.speed = 5
		moveArr[#moveArr + 1] = targetPos
	end
	return moveArr
end

function GuildGameControler:moveOneMonster(moveArr, _preIndex,_index )
	if not self.needToMoveNum then
		self.needToMoveNum = 0
	end
	self.needToMoveNum = self.needToMoveNum + 1
	self._monsterList[_preIndex].status 	= self._monsterList[_index].status
	self._monsterList[_preIndex].id 	  	= self._monsterList[_index].id
	self._monsterList[_preIndex].index  	= self._monsterList[_index].index
	self._monsterList[_preIndex].distance 	= self._monsterList[_index].distance + (tonumber(_index) - tonumber(_preIndex))
	if self._monsterList[_index].distance > 0 and (tonumber(_index) < 21) then
		self._monsterList[_preIndex].lastDistance = self._monsterList[_index].distance
	end
	self._monsterList[_index].status 	= 1
	self._monsterList[_index].id 	  	= nil
	self._monsterList[_index].index  	= nil
	self._monsterList[_index].distance  = nil

	local function movedCallBack( arriveNode )
		if not self.haveMoveNum then
			self.haveMoveNum = 0 
		end
		if arriveNode and arriveNode.stopRuning then
			arriveNode:stopRuning()
		end

		self.haveMoveNum = self.haveMoveNum + 1
		if self.haveMoveNum == self.needToMoveNum then
			-- echo("\n\n\n\n\n ________ 移动怪结束")
			for i=1,20 do
				local data = self._monsterList[tostring(i)]
				if data.distance and data.distance > 0 then
					local lastDis = 0
					if data.lastDistance then
						lastDis = data.lastDistance
					end
					local oldIndex = tostring(i+data.distance-lastDis)
					local newIndex = tostring(i)
					-- echo("_______newIndex___oldIndex",newIndex,oldIndex)
					if newIndex ~= oldIndex then
						self.monsterModelArr[newIndex] = self.monsterModelArr[oldIndex]
						self.monsterModelArr[newIndex]:setIndex( newIndex )
						self.monsterModelArr[oldIndex] = nil
						self._monsterList[newIndex].lastDistance = data.distance
					end
				end
			end
			self:getComboIndex()
		end
	end
	local function callBack2( ... )
		-- echo("__________ 注册回调函数成功__ _index",_index)
		if self.monsterModelArr and self.monsterModelArr[_index] then
			self.monsterModelArr[_index]:moveByPointArr(moveArr)
		end
	end
	if self.monsterModelArr and self.monsterModelArr[_index] then
		local arriveNode = self.monsterModelArr[_index]
		self.monsterModelArr[_index]:setMoveToPosCallBack( c_func(movedCallBack,arriveNode), c_func(callBack2))
	end
end

-- 取得消除的index并消除，消除后status为1，等效于打赢
function GuildGameControler:getComboIndex()
	echo("_______ combo并更新积分和奖励 self.newComeOutNum _______ ",self.newComeOutNum)
	echo("self._newComeoutIndex=",self._newComeoutIndex)
	-- dump(self._monsterList, "______ 消除时的self._monsterList")

	-- 用status做标记
	local isCombo = false
	local count = 1
	if self.newComeOutNum then
		if not self._newComeoutIndex then
			echo("_______ self._newComeoutIndex  ______________________ ",self._newComeoutIndex)
			self._newComeoutIndex = 20 - self.newComeOutNum + 1
		end
		-- echo("self._newComeoutIndex===",self._newComeoutIndex)
		for i = 1,20 do
			-- 有新出的怪才可能相消 新出的怪开始之后的都不能作为碰撞起始点
			if self._newComeoutIndex and i < self._newComeoutIndex and (self._monsterList[tostring(i)].status == 0) then
			-- if (self._monsterList[tostring(i)].status == 0) then
				count = 1
				local monsterId = self._monsterList[tostring(i)].id
				local distance1 = self._monsterList[tostring(i)].distance
				local isMovingCrash = false
				for k = i+1,20 do
					-- echo("___k, self._monsterList[tostring(k)].id,monsterId ________ ",k,self._monsterList[tostring(k)].id,monsterId)
					if k <= 20 and (tostring(self._monsterList[tostring(k)].id) == tostring(monsterId)) then
						count = count + 1
						if distance1 ~= self._monsterList[tostring(k)].distance then
							isMovingCrash = true
						end
					else
						break
					end
				end
				-- echo("count=and isMovingCrash==",count,isMovingCrash)
				if (count >= 3) and (isMovingCrash == true) then
					echo("三个以上的消除 起止=",i,i+count-1)
					local monsterId = self._monsterList[tostring(i)].id
					isCombo = true
					for j = i,i+count-1 do
						local index = tostring(j)
						-- echo("________ 播放动画 index________  ")
						self.gridArr[index]:playAnimation()
						self._monsterList[index].status = 1
						self._monsterList[index].id 	= nil
						self._monsterList[index].index  = nil
						self._monsterList[index].distance = nil
						-- echo("____________  删除第k个怪model",index)
						
						-- 2018.09.14 引导中强制为0，解决引导不comp导致的卡死问题 by ZhangYanguang
						-- 本次问题解决第2处修改，共2处
						if self.monsterModelArr[index] then
							self.monsterModelArr[index]:deleteMe()
							self.monsterModelArr[index] = nil
						end
					end
					self:updateScoreAndIngredients( monsterId,count )

					-- 如果是红怪 则炸左右
					local monsterType = FuncGuildActivity.getMonsterTypeByMonsterId( monsterId )
					if monsterType == FuncGuildActivity.monsterType.red then
						local leftIndex = tostring(i - 1)
						local rightIndex = tostring(i+count)

						if tonumber(leftIndex) >= tonumber(FuncGuildActivity.minIndex) then
							count = count + 1
							local delayShowBoomEff =  function()
								self:updateScoreAndIngredients( self._monsterList[leftIndex].id,1 )

								if self.gridArr[leftIndex] then
									self.gridArr[leftIndex]:playAnimation()
								end
								self._monsterList[leftIndex].status = 1
								self._monsterList[leftIndex].id 	= nil
								self._monsterList[leftIndex].index  = nil
								self._monsterList[leftIndex].distance = nil
								-- echo("____________  删除第k个怪model",leftIndex)
								self.monsterModelArr[leftIndex]:deleteMe()
								self.monsterModelArr[leftIndex] = nil
							end
							self.ui:delayCall(c_func(delayShowBoomEff),0.5)
						end
						if rightIndex <= tonumber(FuncGuildActivity.maxIndex) then
							count = count + 1
							local delayShowBoomEff =  function()
								self:updateScoreAndIngredients( self._monsterList[rightIndex].id,1 )

								if self.gridArr[rightIndex] then
									self.gridArr[rightIndex]:playAnimation()
								end
								self._monsterList[rightIndex].status = 1
								self._monsterList[rightIndex].id 	= nil
								self._monsterList[rightIndex].index  = nil
								self._monsterList[rightIndex].distance = nil
								-- echo("____________  删除第k个怪model",rightIndex)
								self.monsterModelArr[rightIndex]:deleteMe()
								self.monsterModelArr[rightIndex] = nil
							end
							self.ui:delayCall(c_func(delayShowBoomEff),0.7)
						end
					end

					if GuildActMainModel:isInNewGuide() then
						GuildActMainModel:setIsInCombo( false )
						echo("_______ 引导中的 移动消除结束 _______________")
						local function guideIsFinishAndReturn( ... )
							GuildActMainModel:resetTeamInfo()
							GuildActMainModel:resetTeamReward()
							GuildActMainModel._myTeamIngredients = nil
							GuildActMainModel._myTeamScore = nil
							GuildActMainModel.isInBattleResume = false
							GuildActMainModel.isInReconnection = false
							EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_GUIDE_TRIGGER_REWARD,{})
							self.ui:onClose()
						end
						self.ui:delayCall(c_func(guideIsFinishAndReturn),1)
						return
					end

					self._newComeoutIndex = self._newComeoutIndex - count
					self._newComboRound = true
					self._doNotInitDistance = true
					self.ui:delayCall(c_func(self.moveMonsters,self),1)
					return
				end
			end
		end
		if not isCombo then
			echo("___________ 置空 再移动怪")
			self.newComeOutNum = nil
			self._newComeoutIndex = nil
			self._newComboRound = nil
			self._doNotInitDistance = false 
			self.ui:delayCall(c_func(self.moveMonsters,self),1)
			return
		end
	end

	echo("\n\n-- 有消除则继续出怪 否则若是最后一轮则显示奖励 否则倒计时开始")
	echo("\n\n-- isCombo, self.isLastRound ________  ",isCombo, self.isLastRound)
	-- if self._haveBeatMonsters ~= true then
	-- 	WindowControler:showTips( { text = "本轮次没有打怪!" })
	-- 	self._haveBeatMonsters = false
	-- end

	GuildActMainModel:setIsInCombo( false )
	-- if GuildActMainModel:isInNewGuide() then
	-- 	echo("_______ 引导中的 移动消除结束 _______________")
	-- 	local function guideIsFinishAndReturn( ... )
	-- 		GuildActMainModel:resetTeamInfo()
	-- 		GuildActMainModel:resetTeamReward()
	-- 		GuildActMainModel._myTeamIngredients = nil
	-- 		GuildActMainModel._myTeamScore = nil
	-- 		GuildActMainModel.isInBattleResume = false
	-- 		GuildActMainModel.isInReconnection = false
	-- 		EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_GUIDE_TRIGGER_REWARD,{})
	-- 		self.ui:onClose()
	-- 	end
	-- 	self.ui:delayCall(c_func(guideIsFinishAndReturn),0)
	-- 	return
	-- end

	if self.isLastRound then
		self:onLastRoundEnd()
	else
		local isOK = GuildActMainModel:checkSIM(self._monsterList)
		if not isOK then
			echo("发送消息 进行怪强制更新")
		else
			self:showSceneView()
		end
	end
end

--[[
	当最后一轮结束
]]
function GuildGameControler:onLastRoundEnd()
	local callBack = function()
		echo("最后一轮结束回调")
		-- 更新相关数据
		GuildActMainModel:requestGVEData()
		GuildActMainModel:addTeamRewardToPlayer(self.totalReward)
		if GuildActMainModel:getChallengeTimes() <= GuildActMainModel:getMaxChallengeTimes() then
			WindowControler:showWindow("GuildActivityKillMonsterRewardView",self.totalReward)
		else 
			WindowControler:showTips( GameConfig.getLanguage("#tid_guild_056"));
		end
		GuildActMainModel:resetTeamReward()
		self.ui:delayCall(c_func(self.ui.onClose,self.ui),0.5) 
	end

	echo("onLastRoundEnd 最后一轮结束")

	self.ui:playEndAnim(c_func(callBack))
end

-- 更新队内食材和积分
function GuildGameControler:updateScoreAndIngredients( _monsterId,_count )
	local monsterType = FuncGuildActivity.getMonsterTypeByMonsterId( _monsterId )
	if monsterType == FuncGuildActivity.monsterType.red then
		return
	end
	local rewardMaterials,score = FuncGuildActivity.getComboScore( _monsterId,_count )
	-- dump(rewardMaterials, "碰撞获得的食材数组")
	-- echo("_________ 碰撞获得的积分 _____",score)
	if rewardMaterials then
		for k,v in pairs(rewardMaterials) do
			-- dump(v,"碰撞消除获得的食材")
		 	GuildActMainModel:addChallengesIngredients(v.id,v.num)
			self.ui:updateTeamMaterials(v.id)  
			-- WindowControler:showTips( GameConfig.getLanguage("#tid_guild_086")..v.num.."!!!" )
			-- WindowControler:showTips(v.num,1,0,true)
		end 
	end
	-- 更新队内积分
	GuildActMainModel:addChallengesScore(score)
	-- 注意 正常情况下应该将碰撞中的积分加到碰撞前的变量里 碰撞完成后做校验  
	-- 新手引导时与服务器没有交互 所以没有积分和食材校验 
	-- 将积分直接加入正式变量里 展示出来
	if GuildActMainModel:isInNewGuide() then
		GuildActMainModel._myTeamScore = GuildActMainModel._myTeamScore + score
	end
	self.ui:updateTeamScore()
	WindowControler:showTips(score,1,0,true)
	-- WindowControler:showTips( GameConfig.getLanguage("#tid_guild_087")..score.."!!!")
end

function GuildGameControler:getGridPosition( _index )
	-- if tonumber(_index) > 20 then
	-- 	xpos = -1050 - tonumber(_index)*20
	-- 	ypos = -500
	-- end
	-- _index = tonumber(20 - _index + 1)
	-- -- local perDisX = 90
	-- local perDisY = 80
	-- if _index <= 5 then
	-- 	local offset = (_index<4 and _index or (6-_index)) - 1
	-- 	xpos = _index * perDisX - offset*40
	-- 	ypos = _index * perDisY + offset*20
	-- elseif _index <= 10 then
	-- 	local offset = (_index<9 and (_index-5) or (11-_index)) - 1
	-- 	xpos = _index * perDisX + 40 + offset*40
	-- 	ypos = (11-_index) * perDisY + offset*20
	-- elseif _index <= 15 then
	-- 	local offset = (_index<14 and (_index-10) or (16-_index)) - 1
	-- 	xpos = _index * perDisX + 80 - offset*40
	-- 	ypos = (_index -10) * perDisY + offset*20
	-- elseif _index <= 20 then
	-- 	local offset = (_index<19 and (_index-15) or (21-_index)) - 1
	-- 	xpos = _index * perDisX + 120 + offset*40
	-- 	ypos = (21-_index) * perDisY + offset*20
	-- end
	-- -- return xpos,ypos
	-- return xpos-850,ypos-550
	local xpos,ypos = self.map:getGridPoint( _index)
	if FuncGuildActivity.isDebug then
		echo("__________index,xpos,ypos______________",_index,xpos,ypos)
	end
	return xpos,ypos
end

--=====================================================================
-- 选怪
--=====================================================================
function GuildGameControler:setOneMonsterSelected( _index )
	for k,v in pairs(self.monsterModelArr) do
		-- echo("_________ k,_index _______ ", k,_index )
		if k ~= _index then
			v:updateClickFlag(false)	
		end
	end
end


-- 获取引导步骤对应坐标
function GuildGameControler:getGuidingPos(step)
	if not step then
		return cc.p(0,0)
	end
	local index = tonumber(step)
	-- 1,2,3,4步分别点第4个怪,第4个怪的开打面板,7,7类似
	local step2monsterIndexMap = {"4","4","7","7"}
	local targetMonster = self.monsterModelArr[step2monsterIndexMap[index]]
	local targetView = nil
	if index % 2 == 0 then
		targetView = targetMonster.flagmcView:getCurFrameView().panel_1.btn_1
	else
		targetView = targetMonster.myView
	end
    local box = targetView:getContainerBox()
    local cx = box.x + box.width/2
    local cy = box.y + box.height/2
    local turnPos = targetView:convertToWorldSpaceAR(cc.p(cx,cy))
    return turnPos
end

function GuildGameControler:saveCharPos(pos)
	GuildActMainModel:saveCharPos(pos)
end

return GuildGameControler