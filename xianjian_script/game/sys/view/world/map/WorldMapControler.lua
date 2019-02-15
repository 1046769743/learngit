--[[
	Author: 张燕广
	Date:2017-05-02
	Description: 六界大地图控制器
]]

WorldMapControler = class("WorldMapControler")

local WorldMapClazz = require("game.sys.view.world.map.WorldMap")
local WorldMapCreatorClazz = require("game.sys.view.world.map.WorldMapCreator")

WorldMapControler.lockPlayerModel = nil  --锁定的model，主角或其他玩家，默认是主角
WorldMapControler.charModel = nil  --主角model
WorldMapControler.npcModel = nil   --npcmodel
WorldMapControler.playerArr = nil  --其他玩家对象数组
WorldMapControler.spaceArr = nil   --地标对象数组
WorldMapControler._canClickNpc = true

function WorldMapControler:ctor(mapUI,mapConfig)
	WorldControler:setWorldMapControler(self)
	self.updateCount = 0
	self.mapConfig = mapConfig
	self.mapUI = mapUI

	self:registerEvent()
	self:initData()
	
	self._canClickNpc = true

	self:initMap()
	-- 初始化提示
	-- self.mapCreator:initTips()

	-- 主城六界合并，屏蔽云动画 ZhangYanguang
	-- self.mapCreator:playCloudAnim()
	self:createNpc()
	self:createChar()
	self:createCloud()

	-- 创建地图山体和地标
	self.mapCreator:initMapSpaceModels()
	if self.is3DMode then
		-- 创建神界
		if not self.isCloseGod then
			self.mapCreator:initGodWorld()
		end
	end
	
	-- 创建场景特效
	self.mapCreator:initMapEffModels()

	if not PrologueUtils:showPrologueJoinAnim() then
		-- 创建第三方玩家
		self.mapCreator:createPlayers()
	end
	
	-- 执行强制引导逻辑
	self:doForceGuideLogic()
end

function WorldMapControler:initMapCreator()
	self.mapCreator = WorldMapCreatorClazz.new(self)
end

function WorldMapControler:initData()
	-- 初始化强制引导相关数据
	self:initForceGuideData()

	self:setWorldTouchEnable(true)
	self:setMapTouchEnable(true)

	self.mapRect = self.mapConfig.rect

	self.initFinishUI = {
		homeBut = false,
		worldUI = false,
	}

	-- 所有玩家包括主角、npc、第三方玩家
	self.playerArr = {}
	-- 大地图地标
	self.spaceArr = {}
	-- 地标名称数组
	self.spaceNameArr = {}
	-- 场景特效数组
	self.mapEffArr = {}

	-- 地图缩放比例
	self.mapScale = 0.8
	-- 主角相关变量
	self.charScale = 0.8
	self.charOffsetX = 50
    self.charOffsetY = 300
    self.charSize = {width=180,height=180}
    self.charInitPos = {0,0}
    self.charCenterOffsetY = 200

    -- 主角普通飞行速度
    self.charMoveSpeed = 11
    -- 主角极行速度
    self.charFlySpeed = 20

     -- 主角与npc相遇距离
    self.npcMeetDis = 150
    -- 主角与地标相遇距离
    self.spaceMeetDis = 60
    -- 主角极速状态边界偏移值
    -- 当主角与屏幕距离超过该值时，设置到改点后再切换为极速飞行状态
    self.charFlyOffsetDis = 128
    -- 主角移动状态边界值
	-- 当主角与目标点距离为该值时，切换为移动状态
    self.charWalkOffsetDis = 256
    -- 主角初始地标
    self.initCharTargetSpace = "suzhoucheng"
    -- 序章结束特效入口地标
    self.initPrologueJoinSpace = "yuhangzhen"
    -- 序章结束衔接目标地标
    self.initPrologueTargetSpace = "shenmozhijing"

    -- 主角初始化位置
    self.initCharPos = nil

    -- 开启摩擦系数
    self.openCharMoveF = false

    -- npc相关变量
    self.npcHeightOffset = 30
     -- npc运动范围
    self.npcWalkDis = 100

    -- 地图相关变量
    -- 预加载瓦块的数量
    self.preLoadTilesNum = 1
	-- 3D旋转相关常量			
	self.rotation3DX = -15
	-- 是否开启3D透视效果
	self.openRotation3D = true
	-- 是否是3d模式的资源
	self.is3DMode = true
	-- 地图锚点是否设置在左下角
	self.isMapLeftDown = false
	-- 关闭天界
	self.isCloseGod = true
	-- 主角特写功能是否开启
	self.isOpenCharFeature = false
	-- 更新关卡数据
    self:updateRaidData()
end

--[[
	初始化序章衔接
]]
function WorldMapControler:initPrologueJoinAnim()
	if PrologueUtils:showPrologueJoinAnim() then
		-- 设置不可触摸
		self:setWorldTouchEnable(false)
		-- 隐藏所有UI(不用手动打开UI，因为战斗后会重建主城，那是序章衔接逻辑不再执行)
		EventControler:dispatchEvent(HomeEvent.SHOW_BUTTON_UI_VIEW,{isShow  = false});

		-- 衔接进度
		local joinStage = PrologueUtils:getPrologueJoinStage()

		if joinStage == 0 then
			local anim = self.mapCreator:createPrologueDoorAnim(self.initPrologueJoinSpace)
			self.charModel:setVisible(false)
			self._canClickNpc = false
			local callBack = function()
				self:forceCharToNpcForPrologue()
				-- echoError ("1.........")
			end

			-- 播放主角出现动画
			local playCharAppearAnim = function()
				local actCallBack = act.callfunc(callBack)

				self.charModel:setVisible(true)
				local charView = self.charModel:getPlayerView()
				charView:opacity(0)

				local charPartnersView = self.charModel:getPartnersView()
				charPartnersView:setVisible(true)
				charPartnersView:opacity(0)

				local action = cc.Spawn:create(
					-- act.scaleto(0.5,self.charScale,self.charScale),
					act.fadein(0.5),
					actCallBack
				)

				charView:stopAllActions()
				charView:runAction(action)

				local action2 = cc.Spawn:create(
					-- act.scaleto(0.5,self.charScale,self.charScale),
					act.fadein(0.5)
				)

				charPartnersView:stopAllActions()
				charPartnersView:runAction(action2)
			end

			anim:registerFrameEventCallFunc(90,1,c_func(playCharAppearAnim))
		elseif joinStage == 1 then
			local targetPoint = self:getCharTargetPosForPrologue()
			self.charModel:setCharPos(targetPoint)
			self.mapUI:delayCall(c_func(self.onCharArriveTargetPostion,self),1/GameVars.GAMEFRAMERATE)
		end
	end
end

-- 初始化强制引导相关写死数据
function WorldMapControler:initForceGuideData()
	self.forceRaidDataMap = {}

	--[[
		关卡与npc所在地标的对应关系
		initSpace:主角初始地标
		offsetPos:相对目标npc的偏移值，暂未用到
	]]
	self.forceRaidDataMap["10002"] = {
		-- initSpace = "xianlingdao",offsetPos={x=450,y=-240}
		initSpace = "suzhoucheng",offsetPos={x=-500,y=200}
	}

	-- 强制初始信息
	-- self.forceRaidDataMap["10003"] = {
	-- 	initSpace = "suzhoucheng",offsetPos={x=-500,y=200}
	-- }

	self.forceRaidDataMap["10101"] = {
		initSpace = "suzhoucheng",offsetPos={x=450,y=-240}
	}

	self.forceRaidDataMap["10201"] = {
		initSpace = "suzhoucheng",offsetPos={x=420,y=-270}
	}

	-- 新手引导中通过获取途径跳转的关卡ID
	self.jumpGetWayRaidId = "10204"

	-- 主角相对npc的位置
	self.charNpcRelativePos = cc.p(180,-200)
end

-- 更新强制引导相关数据
function WorldMapControler:updateForceGuideData(raidId)
	echo("updateForceGuideData------------",raidId)
	if PrologueUtils:showPrologue() or TutorialManager.getInstance():isNpcInWorldHalt() then
		local curNpcPos = self:getCurNpcCenterPostion()

		local forceRaidData = self.forceRaidDataMap[raidId]
		if forceRaidData and forceRaidData.initSpace then
			self.initCharTargetSpace = forceRaidData.initSpace
		end

		local npcPosx = curNpcPos.x
		local npcPosy = curNpcPos.y

		-- 判断主角与npc间的距离
		local charPos = self:getCharPos()
		if math.abs(charPos.x - npcPosx) > GameVars.width/2 or 
			math.abs(charPos.y - npcPosy) > GameVars.height/2 then

			local offseX = self.charNpcRelativePos.x
			local offsetY = self.charNpcRelativePos.y
			if charPos.x > npcPosx then
				offseX = self.charNpcRelativePos.x
			else
				offseX = -self.charNpcRelativePos.x
			end

			-- 强制主角移到的目标位置
			self.forceCharTargetPos = cc.p(npcPosx+offseX,npcPosy+offsetY)
		end
	end
end

function WorldMapControler:getCurNpcCenterPostion()
	local npcPos = self.curRaidData.enterLocation
	
	local npcId = self.curRaidData.storyNpc
	local npcSourceData = FuncTreasure.getSourceDataById(npcId)
	local npcHeight = npcSourceData.viewSize[2] + self.npcHeightOffset

	local pos = cc.p(tonumber(npcPos[1]),-npcPos[2] + npcHeight/2)
	return pos
end

function WorldMapControler:registerEvent()
	EventControler:addEventListener(WorldEvent.WORLDEVENT_UPDATE_MAIN_MAP,self.updateMapInfo,self)

	-- 领取宝箱后更新npc
	EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES, self.updateNpc, self)
	-- 新手引导后，六界被设置为顶层View
	EventControler:addEventListener(WorldEvent.WORLDEVENT_UPDATE_NPC_WHEN_TOP_VIEW, self.updateNpc, self)
	-- 点击了地图UI
	EventControler:addEventListener(WorldEvent.WORLDEVENT_MAP_UI_TOUCH, self.onClickMapUI,self)
	-- 移动主角进入地标
	EventControler:addEventListener(WorldEvent.WORLDEVENT_ENTER_ONE_SPACE,self.moveCharEnterSpace,self)
	-- 恢复六界角色
	EventControler:addEventListener(WorldEvent.WORLDEVENT_WORLD_MAIN_ON_TOPVIEW, self.onBecomeTopView,self)
	-- 停止六界角色
	EventControler:addEventListener(WorldEvent.WORLDEVENT_WORLD_MAIN_ON_NOT_TOPVIEW, self.onStopAllModels,self)
	-- 强制主角靠近npc
	EventControler:addEventListener(WorldEvent.WORLDEVENT_FORCE_CHAR_TO_NPC, self.setNpcInCenter,self)

	-- 引导消息
	-- EventControler:addEventListener(TutorialEvent.TUTORIAL_FINISH_ONE_GROUP,self.updateGuideStatus,self)
	--六界气泡方向发生变化
	-- EventControler:addEventListener(WorldEvent.BUBBLE_NEED_CHANGED, self.changeWorldBubble, self)

	--六界加载完成
	EventControler:addEventListener(WorldEvent.WORLD_UI_AND_BTN_FINISH, self.initFinishEvent, self)
	-- 新手引导小手出现与消失消息，更新npc小手动画
	EventControler:addEventListener(TutorialEvent.TUTORIAL_UI_SHOWORHIDE,self.updateNpcHandAnim,self)
	-- 主角皮肤发生变化
	EventControler:addEventListener(GarmentEvent.GARMENT_CHANGE_ONE, self.updateCharSkin, self)

	EventControler:addEventListener(WorldEvent.TOUCHTRIAK_ICON_PLOT, self.doAutoClickNpc, self)

end

-- 更新关卡数据
function WorldMapControler:updateRaidData()
	self.curRaidId = WorldModel:getNextMainRaidId()
	self.curRaidData = FuncChapter.getRaidDataByRaidId(self.curRaidId)

	-- 更新强制引导数据
	self:updateForceGuideData(self.curRaidId)
end

--[[
	废弃方法，暂时屏蔽                                                                                                            
]]
function WorldMapControler:updateGuideStatus()
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		self:setWorldTouchEnable(false)
	else
		self:setWorldTouchEnable(true)
		self:setMapTouchEnable(true)
	end
end

--[[
	当WorldMainView成为TopView时
]]
function WorldMapControler:onBecomeTopView()
	echo("onBecomeTopView========",PrologueUtils:getPrologueJoinStage(),PrologueUtils:showPrologueJoinAnim())
	if PrologueUtils:showPrologueJoinAnim() then
		-- if PrologueUtils:getPrologueJoinStage() > 0 then
		echo("发送引导消息")
		EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE
		, {tutorailParam = TutorialEvent.CustomParam.worldComeToTop})
		-- end
	end

	-- 恢复世界可以点击
	self:setWorldTouchEnable(true)
	
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		self:setMapTouchEnable(false)
	else
		self:setMapTouchEnable(true)
	end

	self:onResumeAllModels()
end

-- 执行强制引导逻辑
function WorldMapControler:doForceGuideLogic()
	echo("doForceGuideLogic 强制引导逻辑")
	if PrologueUtils:showPrologueJoinAnim() then
		-- 创建序章衔接特效
		self:initPrologueJoinAnim()
		return
	end
	
	if PrologueUtils:showPrologue() or TutorialManager.getInstance():isNpcInWorldHalt() then
		if self.curRaidId == self.jumpGetWayRaidId then
			return
		end
	end

	if PrologueUtils:showPrologue() or TutorialManager.getInstance():isNpcInWorldHalt() then
		--[[

		if self.forceCharTargetPos then
			-- 首先设置世界不可点击，主角运动后目标位置后再设置地图不可点击(引导层也会屏蔽引导之下的事件)
			self:setWorldTouchEnable(false)
			local moveFunc = function()
				-- TODO 相对于npc坐标方案
				self:forceMoveCharToTargetPos(self.forceCharTargetPos)
				self.forceCharTargetPos = nil
			end

			self.mapUI:delayCall(c_func(moveFunc),1 / GameVars.ARMATURERATE)
		end
		]]
		-- 因等级控制主角位置，所以引导中直接设置主角到达目的地
		self:setWorldTouchEnable(false)
		-- 主角不需要移动到npc附近
		self.mapUI:delayCall(c_func(self.onCharArriveTargetPostion,self),1 / GameVars.ARMATURERATE)
	else
		-- 主角不需要移动到npc附近
		self:onCharArriveTargetPostion()
	end
end

-- 初始化地图世界
function WorldMapControler:initMap()
	if not self.is3DMode then
		-- TODO 3D分支打开后需要修改该代码
		self.mapConfig.mapSpace = self.mapConfig.space
	end

	self.spaceList = self.mapConfig.mapSpace
	self.mapMontainList = self.mapConfig.mapMountain

	self.godMap = self.mapConfig.godMap
	self.godSpace = self.mapConfig.godSpace
	self.godMontainList = self.mapConfig.godMountain

	self.mainMap = WorldMapClazz.new(self.mapConfig,self)
	self.mainMap:setPreLoadTilesNum(self.preLoadTilesNum)
	
	-- 初始化创建器
	self:initMapCreator()
	self.mainMap:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
end

function WorldMapControler:getMap()
	return self.mainMap
end

-- 地图是否移动中
function WorldMapControler:isWorldMoving()
	return self.mainMap:isWorldMoving()
end

-- 获取地图移动速度
function WorldMapControler:getWorldMoveSpeed()
	return self.mainMap:getWorldMoveSpeed()
end

--[[
	设置整个世界(地图+UI)是否可以触摸
	true:可见的所有UI可以点击/地图可以点击拖动
]]
function WorldMapControler:setWorldTouchEnable(enable)
	self.canTouchWorld = enable
	self.mapUI:setTouchEnable(enable)
	self:setMapTouchEnable(enabled)
end

--[[
	设置地图是否可以触摸，前提是setWorldTouchEnable(true)
]]
function WorldMapControler:setMapTouchEnable(enable)
	-- 如果设置为可触摸，需要先设置世界触摸状态
	if enable then
		self:setWorldTouchEnable(true)
	end

	self.canTouchMap = enable
end

function WorldMapControler:isWorldTouchEnable()
	return self.canTouchWorld
end

function WorldMapControler:isMapTouchEnable()
	return self.canTouchMap
end

--[[
	获取主角位置
]]
function WorldMapControler:getCharPos()
	local charInitPos = {}
	self.targetSpacePos = {}

	-- 如果播放序章衔接动画
	if PrologueUtils:showPrologueJoinAnim() then
		self.targetSpacePos = self.mapConfig.mapSpace[self.initPrologueJoinSpace]
		charInitPos.x = self.targetSpacePos.x - 400
		charInitPos.y = self.targetSpacePos.y - 320

		return charInitPos
	else
		if self.initCharPos then
			self.targetSpacePos = self.initCharPos
		else
			self.targetSpacePos = self.mapConfig.mapSpace[self.initCharTargetSpace]
		end

		charInitPos.x = self.targetSpacePos.x + self.charOffsetX
		charInitPos.y = self.targetSpacePos.y - self.charOffsetY
	end

	-- 判断主角是否被限定在指定位置
	if not WorldModel:isRaidLock(self.curRaidId) 
		and WorldModel:checkCharInTargetPositionLimit(self.curRaidId) then
		local charTargetPos = WorldModel:getCharTargetPosition(self.curRaidId)
		if charTargetPos then
			charInitPos.x = charTargetPos.x
			charInitPos.y = charTargetPos.y
		end
	-- 判断主角是否被限定在npc附近
	elseif not WorldModel:isRaidLock(self.curRaidId) 
		and WorldModel:checkCharInPositionLimit() then
		local npcx,npcy = self:getCurNpcPos()
		-- 主角站在npc右侧大概一个身位
		charInitPos.x = npcx + self.charSize.width
		charInitPos.y = npcy
	else
		-- 取出主角缓存的坐标
		local charCacheInfo = WorldModel:getCharMapInfo()
		if charCacheInfo then
			charInitPos.x = charCacheInfo.x
			charInitPos.y = charCacheInfo.y
		end
	end

	return charInitPos
end

--[[
	获取当前npc坐标
]]
function WorldMapControler:getCurNpcPos()
	local npcPos = self.curRaidData.enterLocation
	return tonumber(npcPos[1]),tonumber(-npcPos[2])
end

--[[
	获取当前npc世界坐标
]]
function WorldMapControler:getCurNpcWorldPos()
	local npcWorldPos = self.npcModel:getCenterWorldPos()
	local targetPos = cc.p(npcWorldPos.x,npcWorldPos.y)
	return targetPos
end

-- ======================================================创建类方法======================================================
-- 创建主角
-- 默认锁定主角
-- 1.主角锁定：主角不动，地图上被点击位置移动到主角
-- 2.主角自由：a.主角移动到地图上被点击位置，地图被锁定不动。b.拖拽时，主角和地图一起移动
function WorldMapControler:createChar()
	local charInitPos = self:getCharPos()

    self.charModel = self.mapCreator:createCharModel(charInitPos,self.charSize,self.charScale)
    self.playerArr[#self.playerArr+1] = self.charModel

    if not WorldModel:isRaidLock(self.curRaidId) 
			and WorldModel:checkCharInPositionLimit() then
			local charScaleX = -1
			self.charModel:setCharScaleX(charScaleX)
	else
		local charCacheInfo = WorldModel:getCharMapInfo()

	    if charCacheInfo then
	    	local charFace = charCacheInfo.charFace
	    	local charScaleX = charCacheInfo.charScaleX
	    	
	    	if charScaleX then
	    		self.charModel:setCharScaleX(charScaleX)
	    	end

	    	if charFace then
	    		self.charModel:setCharFace(charFace)
	    	end
	    end
	end

    -- 默认锁定主角
    self:setLockPlayerModel(self.charModel)
end

--[[
	更新主角皮肤
]]
function WorldMapControler:updateCharSkin()
	if self.charModel then
		self.mapCreator:updateCharModelView(self.charModel)
	end
end

-- 创建游云model
function WorldMapControler:createCloud()
	if not self.cloudModel then
		self.cloudModel = self.mapCreator:createCloudModel()
	end
end

-- 设置锁定player(主角或第三方玩家)
function WorldMapControler:setLockPlayerModel(lockPlayerModel)
	if self.lockPlayerModel then
		self.lockPlayerModel:setIsLock(false)
	end

	if lockPlayerModel.setIsLock then
		lockPlayerModel:setIsLock(true)
	end

	self.lockPlayerModel = lockPlayerModel
end

-- 创建npc
function WorldMapControler:createNpc()
	self.npcModel = self.mapCreator:createNpcModel(self.curRaidData,self.npcHeightOffset)
	self.npcModel:setNpcWalkDis(self.npcWalkDis)
	self.playerArr[#self.playerArr+1] = self.npcModel

	self.mapCreator:updateNpcTipHead(self.curRaidData)

	-- 指定的关卡需要显示npc手指动画
	if not WorldModel:isRaidLock(self.curRaidId)
		and  WorldModel:checkShowHandAnim(self.curRaidId) then
	-- if true then
		self.npcModel:createHandAnimView()
		-- echo("创建npc小手---",TutorialManager.getInstance():isNpcInWorldHalt())
		if TutorialManager.getInstance():isHomeExistGuide() then
			self.npcModel:setHandAnimVisible(false)
		end
	end
end

function WorldMapControler:getNpcHandAnim()
	local handAnim = self.mapUI:createUIArmature("UI_main_img_shou", "UI_main_img_shou_sz", nil, true, GameVars.emptyFunc)
	handAnim:setRotation(120)
	return handAnim
end

--[[
	更新Ncp小手动画
	1.新手引导小手出现时，隐藏npc小手
	2.新手引导小手消失时，显示npc小手
]]
function WorldMapControler:updateNpcHandAnim(event)
	local isShow = event.params.isShow
	-- echo("引导小手是否显示中 isShow===",isShow)
	if self.npcModel then
		self.npcModel:setHandAnimVisible(not isShow)
	end
end

-- 更新npc
function WorldMapControler:updateNpc()
	if PrologueUtils:showPrologueJoinAnim() then
		return
	end

	if self.npcModel then
		self.npcModel:deleteMe()
		table.removebyvalue(self.playerArr,self.npcModel,true)
	end
	self:updateRaidData()
	self:createNpc()
end

-- 获取玩家数据
function WorldMapControler:getPlayerInfo(playerId)
	return self.mapCreator:getPlayerInfo(playerId)
end

-- ======================================================事件交互类方法======================================================
-- 当主角运动到目标位置
function WorldMapControler:onCharArriveTargetPostion()
	-- 如果是序章衔接特效期间
	if PrologueUtils:showPrologueJoinAnim() then
		
		self.charModel:playActionForPrologue()
		self.npcModel:setScaleX(-1)
		EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, {tutorailParam = TutorialEvent.CustomParam.worldComeToTop})
		-- echoError ('1.....发送引导消息...')
		
		self.mapUI:delayCall(function ( )
			self._canClickNpc = true
		end, 0.08)

		return
	end

	-- 六界初始化完成（主角移动完成）的消息
	EventControler:dispatchEvent(WorldEvent.WORLD_UI_AND_BTN_FINISH, {_type = "world"})

	WorldModel:saveCharMapInfo(self.charModel.pos,self.charModel:getCharScaleX(),self.charModel:getCharFace())

	-- 如果引导中
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		local npcWorldPos = self.npcModel:getCenterWorldPos()
		local targetPos = cc.p(npcWorldPos.x,npcWorldPos.y)

		local setTouchStatus = function()
			self:setWorldTouchEnable(true)
			self:setMapTouchEnable(false)
		end

		self.mapUI:delayCall(c_func(setTouchStatus), 1/GameVars.GAMEFRAMERATE)
	end
end

--六界的按钮和界面加载完成
function WorldMapControler:initFinishEvent(event)
	-- 如果是序章衔接逻辑，不发送该消息(序章衔接逻辑中会触发)
	if PrologueUtils:showPrologueJoinAnim() then
		return
	end

	local eventName = event.params._type

	if eventName == "world" then
		self.initFinishUI.worldUI = true
	else
		self.initFinishUI.homeBut = true
	end

	for k,v in pairs(self.initFinishUI) do
		if not v then
			return
		end
	end

	self.initFinishUI = {
		homeBut = false,
		worldUI = false,
	}

	EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, {tutorailParam = TutorialEvent.CustomParam.worldComeToTop})
end

-- 当主角与npc相遇-处理逻辑
function WorldMapControler:onCharMeetNpc()
	if self.isOpenCharFeature  then
		self:doCharFeature()
	end

	-- 设置UI可点击
	self:setWorldTouchEnable(true)

	-- 如果没有开启，tips
	if WorldModel:isRaidLock(self.curRaidId) then
		-- WindowControler:showTips(GameConfig.getLanguage("tid_story_10020"))
		return
	end

	if self.isPlayStory then
		return
	end

	self:playStoryPlot()
end

--[[
	主角特写动画
]]
function WorldMapControler:doCharFeature()
	local charPoint = self.charModel.myView:convertToWorldSpaceAR(cc.p(0,0));
	local npcPoint = self.npcModel.myView:convertToWorldSpaceAR(cc.p(0,0));

	local centerX = 0

	-- 主角在npc右边
	if self.charModel.pos.x > self.npcModel.pos.x then
		centerX = npcPoint.x + self.npcModel.mySize.width / 2
	else
		centerX = npcPoint.x - self.npcModel.mySize.width / 2
	end
	
	local moveX = GameVars.width / 2 - centerX
	local moveY = GameVars.height / 2 - self.charCenterOffsetY - charPoint.y + 50

	-- dump(charPoint,"charPoint------------")
	-- 因透视做一个偏差计算
	local offset = 100 * (GameVars.width / 1136)
	local offsetX = (GameVars.width/2 - charPoint.x) / (GameVars.width/2)*offset

	-- 主角在npc左边
	if self.charModel.pos.x < self.npcModel.pos.x then
		offsetX = - offsetX
	end

	moveX = moveX + offsetX
	-- echo("--------- test ------------")
	-- echo("offsetX=",offsetX)
	-- echo("moveX =========",moveX)
	
	local fromScale = 1
	local toScale = 1.01
	local timeSec = 0.5
	self.mainMap:playWorldMapScaleAnim(moveX,moveY,fromScale,toScale,timeSec)
end

--[[
	主角特写之后恢复数据
]]
function WorldMapControler:resetAfterCharFeature()
	self.mainMap:restWorldMap()
end

-- 播放剧情
function WorldMapControler:playStoryPlot()
	-- 如果npc有手指动画，先隐藏掉
	self.npcModel:setHandAnimVisible(false)

	local storyPlotId = self.curRaidData.storyPlot
	if not storyPlotId then
		if self.curRaidId then
			BattleControler:startBattleFormWorld(self.curRaidId)
		end
		return
	end

	-- 剧情展示完毕回调
	local plotCallBack = function(ud)
		if ud.step == -1 and ud.index == -1 then
			-- 剧情播放完毕，进入战斗
			echo("剧情播放完毕，进入战斗self.curRaidId====",self.curRaidId)
			if self.isOpenCharFeature then
				self:resetAfterCharFeature()
			end
			
			self.isPlayStory = false
			if self.curRaidId then
				BattleControler:startBattleFormWorld(self.curRaidId)
			end
		end
	end

	self.isPlayStory = true
	PlotDialogControl:showPlotDialog(storyPlotId, c_func(plotCallBack))
    PlotDialogControl:setSkipButtonVisbale(true);
end

-- 当主角退出地标
function WorldMapControler:onExitSpace(_spaceName)
	if self.curSpaceModel then
		self.curSpaceModel:setIsClicked(false)
	end
	
	self.hasEnterSpace = false
end

-- 当主角进入地标
function WorldMapControler:onEnterSpace(spaceName)
	echo("\n onEnterSpace spaceName=",spaceName,self.isPlayStory)

	if self.isPlayStory then
		return
	end

	--[[
	-- 退出地标回调
	local exitSpaceCallBack = function(_spaceName)
		self.isPlayStory = false
		self.mapCreator:playPlayerExitSpaceAnim(self.charModel,c_func(self.onExitSpace,self,_spaceName))
		self:setMapTouchEnable(true)
		self.curSpaceName = nil
	end
	]]

	-- 进入地标
	local enterSpace = function()
		self:setWorldTouchEnable(true)

		local spaceData = FuncChapter.getSpaceDataByName(spaceName)
		local mapId = spaceData.map
		self.isPlayStory = true
		AnimDialogControl:setSpaceName(spaceName)
		AnimDialogControl:showPlotDialogFormMap(mapId,c_func(self.exitSpaceCallBack,self))

		self.curSpaceName = spaceName
	end
	
	self:setWorldTouchEnable(false)
	self.mapCreator:playPlayerEnterSpaceAnim(self.charModel,c_func(enterSpace))
end

function WorldMapControler:exitSpaceCallBack(_spaceName)
	self.isPlayStory = false
	self.mapCreator:playPlayerExitSpaceAnim(self.charModel,c_func(self.onExitSpace,self,_spaceName))
	self:setMapTouchEnable(true)
	self.curSpaceName = nil
end

-- 点击了地标
function WorldMapControler:onClickSpace(spaceModel)
	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CLICK_ONE_SPACE)

	-- 隐藏主角指示动画
	self.mainMap:showGuildAnim(false)

	self.curSpaceModel = spaceModel
	local spaceEnterPoint = self.curSpaceModel:getEnterPoint()
	local spaceX = spaceEnterPoint.x
	local spaceY = spaceEnterPoint.y

	local charTargetPos = cc.p(spaceX,spaceY)
	self:moveChar(charTargetPos)
end

-- 点击了地图UI
function WorldMapControler:onClickMapUI()
	-- echo("点击了地图UI..........")
	if not TutorialManager.getInstance():isNpcInWorldHalt() then
		-- 去掉npc点击事件
		self.npcModel:setIsClickNpc(false)
	end
end

function WorldMapControler:autoClickCurNpc()
	if self.npcModel then
		self:setCharInCenter()
		self.npcModel:onClickNpc()
	end
end

-- 点击了npc
-- 1.如果任务可接，主角移动过去
-- 2.如果任务不可接，弹出tips，主角不移动过去
function WorldMapControler:onClickNpc(npcObj)
	-- echo("self:isWorldTouchEnable()---------",self:isWorldTouchEnable())
	-- TODO 
	-- if not self:isWorldTouchEnable() then
	-- 	return
	-- end
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		self:setWorldTouchEnable(false)
	end

	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CLICK_ONE_NPC)
	-- 隐藏主角指示动画
	self.mainMap:showGuildAnim(false)

	if WorldModel:isRaidLock(self.curRaidId) then
		-- local levelLimit = WorldModel:getRaidLevelLimit(self.curRaidId)
		-- WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_story_10020",levelLimit))
		local condition = self.curRaidData.condition
		local lockTip = UserModel:getConditionTip(condition)
		WindowControler:showTips(lockTip)

		WindowControler:showWindow("CompLevelUpTipsView", true)
		return
	end 

	local npcX = npcObj.pos.x
	local npcY = npcObj.pos.y

	local charTargetPos = {x=npcX,y=npcY}

	local dis = self.npcMeetDis - 10
	-- 调整charTargetPos,控制主角移动到npc的什么位置
	if self.charModel.pos.x <= npcX then
		charTargetPos.x = charTargetPos.x - dis
	else
		charTargetPos.x = charTargetPos.x + dis
	end

	-- if self.charModel.pos.y <= npcY then
	-- 	charTargetPos.y = charTargetPos.y - 120
	-- else
	-- 	charTargetPos.y = charTargetPos.y - 120
	-- end
	charTargetPos.y = npcY - 120

	self:moveChar(charTargetPos)
end

-- 点击了第三方玩家
function WorldMapControler:onClickPlayer(playerObj)
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		return
	end

	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CLICK_ONE_PLAYER,{player=playerObj})
	self:setLockPlayerModel(playerObj)
end

-- 一个玩家进入地标
-- 播放动画等逻辑操作
function WorldMapControler:onPlayerEnterSpace(playerModel)
	self.mapCreator:onPlayerEnterSpace(playerModel)
end

-- ======================================================更新类方法======================================================
-- 获取世界边界信息
function WorldMapControler:getWorldBorderInfo()
	return self.mainMap.mapInnterRect
end

function WorldMapControler:getCharTargetPoint()
	if self.charTargetPos == nil then
		self.charTargetPos = self.charModel.pos
	end

	return self.charTargetPos
end

-- 更新地图相关信息
-- 缩略图切换过来会调用该方法
function WorldMapControler:updateMapInfo(data)
	-- self.charModel:setIsLock(true)
	-- self.lockPlayerModel = self.charModel
	self:setLockPlayerModel(self.charModel)

	local mapInfo = data.params.mapInfo
	local charFace = mapInfo.charFace
	local charPos = mapInfo.charPos
	local charScaleX = mapInfo.charScaleX
	local charTargetPos = mapInfo.charTargetPos

	-- echo("WorldMap 缩略图传给大地图 mapInfo=")
	-- dump(mapInfo)
	-- echo("self.mapRect.x,y===",self.mapRect.x,self.mapRect.y)

	local charX = charPos.x - math.abs(self.mapRect.x)
	local charY = charPos.y + math.abs(self.mapRect.y)

	charTargetPos.x = charTargetPos.x - math.abs(self.mapRect.x)
	charTargetPos.y = charTargetPos.y + math.abs(self.mapRect.y)

	self.charModel:setCharFace(charFace)
	self.charModel:setCharScaleX(charScaleX)

	-- echo("self.charModel:isLock===",self.charModel:isLock())
	-- todo moveToPoint导致朝向不对
	if charTargetPos.speed == 0 then
		self.charModel:setCharPos(cc.p(charX, charY))
	end

	if charTargetPos.speed > 0 then
		self.charTargetPos = charTargetPos
		self.charModel:moveToPoint(charTargetPos)
		self.mainMap:playGuildAnim(charTargetPos)
	end
	self:setCharInCenter()
end

-- 获取地图相关信息
function WorldMapControler:getMapInfo()
	local charX = self.charModel.pos.x
	local charY = self.charModel.pos.y

	local mapInfo = {}
	mapInfo.charFace = self.charModel.charFace
	mapInfo.charScaleX = self.charModel.charScaleX
	mapInfo.charPos = self:convertPointToAerialMap(cc.p(charX,charY))
	mapInfo.charTargetPos = self:convertPointToAerialMap(self:getCharTargetPoint())
	mapInfo.charTargetPos.speed = self.charModel:getAbsSpeed()
	-- echo("WorldMap 大地图传给缩略图 mapInfo=")
	-- dump(mapInfo)
	return mapInfo
end

function WorldMapControler:convertPointToAerialMap(point)
	local newPoint = {}
	newPoint.x = point.x + math.abs(self.mapRect.x)
	newPoint.y = point.y - math.abs(self.mapRect.y)

	return newPoint
end

function WorldMapControler:updateFrame(dt)
	self.updateCount = self.updateCount +1
	-- echo("WorldMapControler updateFrame dt=",dt)
	if self.mainMap then
		self.mainMap:updateFrame(dt)
	end

	if self.cloudModel  then
		self.cloudModel:updateFrame()
	end

	--暂定 50秒做一次垃圾回收.
	if self.updateCount % 1500 == 0 then
		collectgarbage("collect")
	end

	-- 更新所有玩家
	self:updatePlayer()
	-- 更新所有地标
	self:updateSpace()
	self:updateMapEff()
	self:updateMapMontain()
	self:sortMapMontain()
	-- 更新UI逻辑
	-- self:updateUILogic()
	self:updateNpcTipLogic()
	
	self.mapCreator:updateFrame()

	--每十分钟请求一次幻境协战数据  检查是否需要显示主城的提示板
	if self.updateCount % (30 * 60 * 10) == 0 then
		ShareBossModel:isShowHomeViewTips()
	end
end

-- @deprecated @Test 测试方法
function WorldMapControler:checkDuplicateName()
	local nameMap = {}
	for k,v in pairs(self.playerArr) do
		if v.getName then
			local name = v:getName()
			nameMap[name] = (nameMap[name] or 0) + 1
		end
	end

	for k,v in pairs(nameMap) do
		if tonumber(v) >=2 then
			echo("重复的名字:",k,v)
		end
	end
end

-- 更新所有玩家
function WorldMapControler:updatePlayer(dt)
	--1秒排序一次
	if self.updateCount % 30 == 0 then
		self:sortPlayer()
	end
	

	for k,v in pairs(self.playerArr) do
		if v then
			v:updateFrame(dt)
		end
	end
end


local sortMapFunc = function(m1,m2)
	local m1Y = m1.pos.y
	local m2Y = m2.pos.y

	if m1Y > m2Y then
		return true
	else
		return false
	end
end

-- 地图山体排序
function WorldMapControler:sortMapMontain()
	if self.updateCount % 30 ~= 10 then
		return
	end

	table.sort(self.mapMontainArr,sortMapFunc)

	for i,v in pairs(self.mapMontainArr) do
		v:setViewZOrder(i)
	end
end


local sortPlayerFunc = function(m1,m2)
	local m1X = m1:getSortPos().x
	local m1Y = m1:getSortPos().y

	local m2X = m2:getSortPos().x
	local m2Y = m2:getSortPos().y

	-- echo("m1X,m2X=",m1X,m2X)
	if m1Y > m2Y then
		return true
	elseif m1Y == m2Y then
		if m1X < m2X then
			return true
		else
			return false
		end
	else
		return false
	end
end
-- 玩家排序,x小的在下面，y大的在下面(坐标系原点是左上角)
function WorldMapControler:sortPlayer()
	
	-- local tempPlayerArr = table.copy(self.playerArr)
	table.sort(self.playerArr,sortPlayerFunc)

	for i,v in pairs(self.playerArr) do
		v:setZOrder(i)
	end

	if self.cloudModel then
		self.cloudModel:setZOrder(#self.playerArr+1)
	end

	self.charModel:setZOrder(self.charModel:getZOrder() + #self.playerArr + 1)
	self.npcModel:setZOrder(self.npcModel:getZOrder() + #self.playerArr + 1)
end

-- 更新所有地图山体
function WorldMapControler:updateMapMontain(dt)
	for k,v in pairs(self.mapMontainArr) do
		v:updateFrame(dt)
	end
end

-- 更新所有场景特效
function WorldMapControler:updateMapEff(dt)
	for k,v in pairs(self.mapEffArr) do
		v:updateFrame(dt)
	end
end

-- 更新所有地标
function WorldMapControler:updateSpace(dt)
	for k,v in pairs(self.spaceArr) do
		v:updateFrame(dt)
	end
end

-- 更新npc任务指引
function WorldMapControler:updateNpcTipLogic()
	-- if self.updateCount % 60 ~= 30 then
	-- 	return
	-- end
	if PrologueUtils:showPrologue() then
		self.npcLockTip:setVisible(false)
		self.npcUnLockTip:setVisible(true)
		return
	end

	if WorldModel:isRaidLock(self.curRaidId) then
		self.npcLockTip:setVisible(true)
		self.npcUnLockTip:setVisible(false)
	else
		self.npcLockTip:setVisible(false)
		self.npcUnLockTip:setVisible(true)
	end
end

function WorldMapControler:updateTaskTipStatus()
	if self.updateCount % 60 ~= 45 then
 		return
	end


	local tipHead = self.taskTip:getChildByName("head")
	if WorldModel:isRaidLock(self.curRaidId) then
		self.taskTip:setVisible(true)
		-- if tipHead and (not  tipHead._isFilter) then
		-- 	FilterTools.setGrayFilter(tipHead)
		-- 	tipHead._isFilter = true
		-- end
		if self.taskTip.tipsAnim then
			self.taskTip.tipsAnim:setVisible(false)
		end
	else
		self.taskTip:setVisible(true)
		-- if tipHead and tipHead._isFilter  then
		-- 	FilterTools.clearFilter(tipHead)
		-- 	tipHead._isFilter = nil
		-- end
		if not self.taskTip.tipsAnim then
			local tipsAnim = self.mapUI:createUIArmature("UI_liujie", "UI_liujie_touxiangtishi_zong_copy", self.taskTip, true, GameVars.emptyFunc)
			tipsAnim:setName("tipsAnim")
			tipsAnim:setScale(0.80)
			tipsAnim:pos(-8.5, 5.2)
			tipsAnim:zorder(2)
			self.taskTip.tipsAnim = tipsAnim
		end
		self.taskTip.tipsAnim:setVisible(true)
	end
end

-- 更新UI显示相关逻辑
function WorldMapControler:updateUILogic()
	self:updateTipsLogic()
end

function WorldMapControler:updateTipsLogic()
	-- 是否是序章
	if PrologueUtils:showPrologue() then
		self.taskTip:setVisible(false)
		-- self.charTip:setVisible(false)
		self:updateNpcTipLogic()
		return
	end
	
	if  TutorialManager.getInstance():isInTutorial() then
		self.taskTip:setVisible(false)
		self:updateNpcTipLogic()
		return
	end

	self:updateTaskTipStatus()
	-- 2017.11.23 锁定的npc也要显示任务tip   2018.6  锁定的npc不再显示tips
	self:updateTip(self.taskTip,self.npcModel)
	-- self:updateWorldBubble()	
	self:updateNpcTipLogic()
	self:updateTipText()
	if PrologueUtils:showPrologueJoinAnim() then
		self.taskTip:setVisible(false)
		self.npcLockTip:setVisible(false)
	end
end

function WorldMapControler:updateTipText()
	local raidData = FuncChapter.getRaidDataByRaidId(self.curRaidId)
	local chat = raidData.chat
	local desStr = ""
	local isHideText = false
	if not WorldModel:isRaidLock(self.curRaidId) then
		isHideText = true
		if chat and chat[1] then
			-- local raidName = GameConfig.getLanguage(raidData.name) 
			desStr = FuncTranslate._getLanguageWithSwap(chat[1], UserModel:name())
		end			
	else
		if chat and chat[2] then			
			local openLevel = raidData.condition[2].v 
			desStr = FuncTranslate._getLanguageWithSwap(chat[2], openLevel)
		end	
	end

	if self.taskTip.textLabel then
		self.taskTip.textLabel:setString(desStr)
	end

	if self.taskTip.textDi then
		if isHideText then
			self.taskTip.textDi:setVisible(false)
		else
			self.taskTip.textDi:setVisible(true)
		end
	end	
end

function WorldMapControler:updateWorldBubble()
	if not self.tipsBubble then
		local cx = self.taskTip:getPositionX()
		local cy = self.taskTip:getPositionY()
		local raidData = FuncChapter.getRaidDataByRaidId(self.curRaidId)
		local chat = raidData.chat
		local desStr = ""
		if not WorldModel:isRaidLock(self.curRaidId) then
			if chat and chat[1] then
				-- local raidName = GameConfig.getLanguage(raidData.name) 
				desStr = FuncTranslate._getLanguageWithSwap(chat[1], UserModel:name())
			end			
		else
			if chat and chat[2] then			
				local openLevel = raidData.condition[2].v 
				desStr = FuncTranslate._getLanguageWithSwap(chat[2], openLevel)
			end	
		end
		
		self.bubble_params = {
			pos = {x = cx, y = cy},
			chat = desStr,
			appear = 10,
			display = 60,
			interval = 240,
		}
		self.tipsBubble = FuncCommUI.regesitWorldBubbleView(self.bubble_params, self.taskTip)
	end
end

function WorldMapControler:changeWorldBubble(params)
	local frame = params.params.frame
	self.tipsBubble:setViewByFrame(frame)
	local offset_x, offset_y = self.tipsBubble:getOffset()
    self.tipsBubble:setPosition(cc.p(offset_x, offset_y + 22))	
end

function WorldMapControler:updateTip(tipView,targetModel)
	local targetPoint = targetModel:getWorldPos()
	-- TODO临时解决3d透视导致的坐标偏差
	local offsetX = 80
	local offsetY = 80

	-- if not targetModel:isInScreen() then
		tipView:setVisible(true)
		-- local tipSize = tipView.tipSize
		-- local tipViewBg = tipView.tipViewBg
		-- local newX = targetPoint.x
		-- local newY = targetPoint.y

		-- local minX = tipSize.width - GameVars.UIOffsetX
		-- local maxX = GameVars.width - tipSize.width - GameVars.UIOffsetX

		-- local minY = tipSize.height
		-- local maxY = GameVars.height - tipSize.height + GameVars.UIOffsetY

		-- if targetPoint.x < (0 + offsetX) then
		-- 	newX = minX
		-- elseif targetPoint.x >= (GameVars.width - offsetX) then
		-- 	newX = maxX
		-- end

		-- if targetPoint.y < (0 + offsetY) then
		-- 	newY = minY
		-- elseif targetPoint.y >= (GameVars.height - offsetY) then
		-- 	newY = maxY
		-- end
		
		-- if newX <= minX then
		-- 	newX = minX
		-- elseif newX >= maxX then
		-- 	newX = maxX
		-- end

		-- -- 不要与下边的按钮重叠
		-- if newY <= 220 then
		-- 	newY = 220
		-- end

		-- if newY >= maxY then
		-- 	newY = maxY
		-- end

		-- 设置旋转角度
		-- local tipPoint = self.charTip:convertToWorldSpace(GameVars.emptyPoint);
		-- local newTargetPoint = cc.p(targetPoint.x,targetPoint.y + targetModel:getContentSize().height / 2)
		-- local ang = self:calculateTanAngle(tipPoint,newTargetPoint)
		-- local tipsAnim = tipView.tipsAnim
		-- tipView:setPositionX(newX)
		-- tipView:setPositionY(-(GameVars.height-newY))
		-- tipViewBg:setRotation(ang)
		-- if tipsAnim then
		-- 	tipsAnim:setRotation(ang)
		-- end

		-- 更新指示的朝向
		-- local tipPos = tipView:convertToWorldSpaceAR(GameVars.emptyPoint)
		-- local tipHead = tipView:getChildByName("head")
		-- if targetPoint.x > GameVars.width/2 then
		-- 	if tipHead then
		-- 		tipHead:setRotationSkewY(180)
		-- 	end
		-- else
		-- 	if tipHead then
		-- 		tipHead:setRotationSkewY(0)
		-- 	end
		-- end

		-- if self.tipsBubble then
		-- 	local _posX = self.taskTip:getPositionX()
		-- 	local _posY = self.taskTip:getPositionY()
		-- 	self.tipsBubble:updateBubbleStatus(_posX, _posY)
		-- end		
	-- else
	-- 	tipView:setVisible(false)
	-- end
end

-- ======================================================跳转类方法======================================================
function WorldMapControler:goCharGarmentView()
	local isOpen,_,_,locKTip = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.GARMENT)
	if isOpen then
		WindowControler:showWindow("CharMainView",CharModel.CHAR_SYS.SYS_GARMENT)
	else
		WindowControler:showTips(locKTip)
	end
end

function WorldMapControler:goFormationView()
	local isOpen,_,_,locKTip = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.ARRAY)
	if isOpen then
		WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve,{})
	else
		WindowControler:showTips(locKTip)
	end
end

-- @deprecated 废弃方法查看玩家阵容
function WorldMapControler:goPlayerLineUpView(playerId)
	local playerInfo = self.mapCreator:getPlayerInfo(playerId)
	if not playerInfo then
		echoWarn("查看玩家阵容playerInfo=")
		dump(playerInfo)
		return
	end

	playerInfo.rid = playerInfo._id
	-- echo("\n====== playerInfo.isRobot==",playerInfo.isRobot)
	-- echo("playerInfo.sec====")
	-- echo(playerInfo.sec)

	if playerInfo then
		local isOpen, lv = LineUpModel:isLineUpOpen(playerInfo.level)
		if isOpen then
			if playerInfo.isRobot then
				WorldModel:repairFakePlayerInfo(playerInfo)
	            LineUpViewControler:showMainWindow(playerInfo)
	        else
	        	-- TODO 该方案存在安全隐患，合服方案确定后需要修改 by ZhangYanguang
	        	playerInfo.sec = LoginControler:getServerId()

	            LineUpViewControler:showMainWindow({
	                trid = playerInfo.rid,
	                tsec = playerInfo.sec or LoginControler:getServerId(),
	                formationId = FuncTeamFormation.formation.pve,
	            })
	        end
	    else
	    	local tipMsg = GameConfig.getLanguage(FuncCommon.getSysOpenxtname(FuncCommon.SYSTEM_NAME.LINEUP))
        	WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_teaminfo_1001", lv, tipMsg))
		end
	end
end

-- 跳转到缩略图
function WorldMapControler:showAerialMap()
	-- 2018.06.14 四测屏蔽缩略图
	if true then
		return
	end

	local mapInfo = self:getMapInfo()
	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_SHOW_AERIAL_MAP,{mapInfo=mapInfo})
end

-- ======================================================功能类方法======================================================
-- 设置3d旋转
function WorldMapControler:setViewRotation3D(view)
	if not self.openRotation3D then
		return
	end

	if view then
		view:setRotation3D({x=self.rotation3DX,y=0,z=0})
	end
end

-- 设置3d反旋转
function WorldMapControler:setViewRotation3DBack(view)
	if not self.openRotation3D then
		return
	end

	if view then
		view:setRotation3D({x=-self.rotation3DX,y=0,z=0})
	end
end

-- 移动第三方玩家
function WorldMapControler:movePlayer(playerModel,targetSpace)
	-- echo("targetSpace--------",targetSpace)
	local spacePos = self.spaceList[targetSpace]
	local targetPos = {x= spacePos.x,y = spacePos.y,speed = 3}
	targetPos.y = targetPos.y - 80
	playerModel:setTargetSpace(targetSpace)
    playerModel:setTargetPos(targetPos)
end

-- 移动主角并进入目标地标
function WorldMapControler:moveCharEnterSpace(event)
	if event and event.params then
		local spaceName = event.params.spaceName
		for k,v in pairs(self.spaceArr) do
			if v and v:getSpaceName() == spaceName then
				self:charOneStepSpace(spaceName)
				v:enterSpace()
				return
			end
		end
	end
end

-- 主角瞬时移到地标附近
function WorldMapControler:charOneStepSpace(spaceName)
	local targetSpacePos = self.mapConfig.mapSpace[spaceName]
	if targetSpacePos then
		local charInitPos = {}
		charInitPos.x = targetSpacePos.x + self.charOffsetX
		charInitPos.y = targetSpacePos.y - self.charOffsetY
		self.charModel:setPos(charInitPos.x,charInitPos.y,self.charModel.pos.z)
		self:setLockPlayerModel(self.charModel)
		self.mainMap:setOneStepMove()
	end
end

-- 移动主角到目标位置
function WorldMapControler:forceMoveCharToTargetPos(targetPos)
	local speed = self.charFlySpeed - 1
	self:moveChar(targetPos,speed)
end

--[[
    移动主角靠近地标附近，不进入
]]
function WorldMapControler:moveCharNearSpace(spaceName)
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		self:setWorldTouchEnable(false)
	end

	self:setCharInCenter()

	local targetPos = {}
	local spaceInfo = self.mapConfig.mapSpace[spaceName]
	targetPos.x = spaceInfo.x
	targetPos.y = spaceInfo.y

	local spaceWidth = spaceInfo.width
	local spaceHeight = spaceInfo.height

	local charPos = self.charModel.pos
	local offsetX = 100
	local offsetY = 150
	-- 主角在地标右边
	if charPos.x > targetPos.x then
		targetPos.x = targetPos.x + spaceWidth/2 + offsetX
	else
		targetPos.x = targetPos.x - spaceWidth/2 - offsetX
	end

	-- 主角在地标上边(无论主角在地标上下，都移动到左下角或右下角)
	if charPos.y > targetPos.y then
		targetPos.y = targetPos.y - offsetY
	else
		targetPos.y = targetPos.y - offsetY
	end

	local speed = self.charFlySpeed - 2
	self:moveChar(targetPos,speed)
end

--[[
	移动主角到npc附近
	序章衔接需求专用
]]
function WorldMapControler:forceCharToNpcForPrologue()
	local charPos = self.charModel.pos

	local targetPoint = self:getCharTargetPosForPrologue()
	self:moveChar(targetPoint,12)
end

--[[
	获取主角目标位置
	序章衔接需求专用
]]
function WorldMapControler:getCharTargetPosForPrologue()
	local npcPos = self.npcModel.pos
	local targetPoint = {}
	targetPoint.x = npcPos.x + 200
	targetPoint.y = npcPos.y - 40
	return targetPoint
end

-- 移动主角到npc附近，不触发npc点击操作
function WorldMapControler:forceCharToNpc()
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		self:setWorldTouchEnable(false)
	end
	
	local charPos = self.charModel.pos
	local npcPos = self.npcModel.pos

	local dis = self.npcMeetDis + 150
	local targetPoint = nil
	if math.abs(charPos.x - npcPos.x) > dis or math.abs(charPos.y - npcPos.y) > dis then
		targetPoint = {}
		-- 在npc的左边
		if charPos.x < npcPos.x then
			targetPoint.x = npcPos.x - dis
		else
			-- 在主角的右边
			targetPoint.x = npcPos.x + dis
		end

		targetPoint.y = npcPos.y - dis
	end

	if targetPoint then
		self:moveChar(targetPoint)
	end
end

-- 移动主角
function WorldMapControler:moveChar(targetPos,speed)
	local isLock = self.charModel:isLock()

	self.charTargetPos = targetPos
	if isLock or self.charModel:isInScreen() then
		self.charTargetPos = targetPos
		-- TODO 动态计算速度
		targetPos.speed = speed or self.charMoveSpeed
		if self.openCharMoveF then
			targetPos.speed = 10
			targetPos.minSpeed = 5
	   		targetPos.f = 0.97
		end

	    targetPos.y = targetPos.y
	    self.charModel:moveToPoint(targetPos)
	else
		self:moveCharByPointArr(targetPos)
	end
end

-- 指定多个点移动主角
function WorldMapControler:moveCharByPointArr(targetPos)
	self.charTargetPos = targetPos

	local isLock = self.charModel:isLock()

	-- echo("isLock===",isLock)
	-- echo("char pos====")
	-- dump(self.charModel.pos)

	-- echo("char target pos===")
	-- dump(targetPos)

	-- echo("world vis rect")
	-- self.mainMap:getCharLayerVisRect()

	local charFlyWorldPoint,charWalkWorldPoint = self:getIntersectPoint(targetPos)

	local charFlyPoint = nil
	local charWalkPoint = nil

	if charFlyWorldPoint then
		charFlyPoint = self.charModel:convertToLocalPos(charFlyWorldPoint)
	end

	if charWalkWorldPoint then
		charWalkPoint = self.charModel:convertToLocalPos(charWalkWorldPoint)
	end

	if charFlyPoint then
		self.charModel:setPos(charFlyPoint.x,charFlyPoint.y,0)
	end

	local pointArr = {}
	if charWalkPoint then
		charWalkPoint.y = charWalkPoint.y
		charWalkPoint.speed = self.charFlySpeed

		pointArr[#pointArr+1] = charWalkPoint
	end

	targetPos.speed = self.charMoveSpeed
	if self.openCharMoveF then
		targetPos.speed = 10
		targetPos.minSpeed = 5
   		targetPos.f = 0.97
	end

	targetPos.y = targetPos.y
	pointArr[#pointArr+1] = targetPos

	self.charModel:moveByPointArr(pointArr)
end

-- 计算主角出界后与屏幕边缘及指定距离相交点
function WorldMapControler:getIntersectPoint(targetPoint)
	local charWorldPos = self.charModel:getWorldPos()

	local targetWorldPos = self.charModel:getWorldPosByPoint(targetPoint)
	local charX = charWorldPos.x
	local charY = charWorldPos.y

	local dx = targetWorldPos.x - charX
	local dy = targetWorldPos.y - charY
	local ang = math.atan2(dy, dx)

	-- 主角与目标点间距离
	local targetDis = math.sqrt(dx*dx+dy*dy)
	-- 主角与屏幕相交点距离
	local screenDis = 0

	-- 主角x方向出界
	if charX <= 0 or charX >= GameVars.width then
		local screenDx = 0
		if charX <= 0 then
			screenDx = 0 - charX
		else
			screenDx = charX - GameVars.width
		end
		screenDis = math.abs(screenDx / math.cos(ang))

	-- 主角y方向出界
	elseif charY <= 0 or charY >= GameVars.height then
		local screenDy = 0
		if charY <= 0 then
			screenDy = 0 - charY
		else
			screenDy = charY - GameVars.height
		end

		screenDis = math.abs(screenDy / math.sin(ang))
	end

	local screenPoint = nil
	local walkPoint = nil
	if targetDis > 0 then
		screenPoint = {x=0,y=0}
		screenPoint.x = targetWorldPos.x - math.cos(ang) * (targetDis - screenDis)
		screenPoint.y = targetWorldPos.y - math.sin(ang) * (targetDis - screenDis)

		if targetDis >= self.charWalkOffsetDis then
			walkPoint = {x=0,y=0}
			walkPoint.x = targetWorldPos.x - math.cos(ang) * self.charWalkOffsetDis
			walkPoint.y = targetWorldPos.y - math.sin(ang) * self.charWalkOffsetDis
		end
	end

	-- 主角与屏幕相交点/主角与walk相交点
	return screenPoint,walkPoint
end

-- @deprecated 需求原因暂时废弃
function WorldMapControler:getCharWalkBorderIntersectPoint(targetPoint)
	local charX = self.charModel.pos.x
	local charY = self.charModel.pos.y

	local dx = targetPoint.x - charX
	local dy = targetPoint.y - charY
	local ang = math.atan2(dy, dx)

	local dis = math.sqrt(dx*dx+dy*dy)
	local xdis = math.cos(ang) * dis
	local ydis = math.sin(ang) * dis
	
	local point = {x=0,y=0}
	point.x = targetPoint.x - math.cos(ang) * self.charWalkOffsetDis
	point.y = targetPoint.y - math.sin(ang) * self.charWalkOffsetDis
	-- echo("=========== 256相交点。。。")
	-- dump(point)
	return point
end

-- 将主角移动到镜头中心
function WorldMapControler:setCharInCenter()
	-- self.charModel:setIsLock(true)
	-- self.lockPlayerModel = self.charModel
	self:setLockPlayerModel(self.charModel)
	
	local charPoint = self.charModel.myView:convertToWorldSpaceAR(cc.p(0,0));
	local moveX = GameVars.width/2 - charPoint.x
	local moveY = GameVars.height/2 - self.charCenterOffsetY - charPoint.y

	self.mainMap:moveWorld(moveX, moveY)
end

-- 将npc移动到镜头中心
function WorldMapControler:setNpcInCenter()
	-- 锁定主角时，世界的位置会依赖主角的位置，必须解锁主角
	self.charModel:setIsLock(false)
	self:setLockPlayerModel(self.npcModel)

	local npcPoint = self.npcModel.myView:convertToWorldSpaceAR(cc.p(0,0));

	local moveX = GameVars.width/2 - npcPoint.x
	local moveY = GameVars.height/2 - npcPoint.y
	local callBack = c_func(self.forceCharToNpc,self)

	self.mainMap:moveWorld(moveX, moveY,callBack)
end

--[[
	自动触发npc点击事件
	1.点击npc任务指引自动触发
	2.触发点击前先将npc设置为屏幕中心
]]
function WorldMapControler:doAutoClickNpc()
	-- echoError ("self.curSpaceName===",self.curSpaceName)
	if self.curSpaceName then
		AnimDialogControl:destoryView()
		self:exitSpaceCallBack(self.curSpaceName)
	end

	-- 锁定主角时，世界的位置会依赖主角的位置，必须解锁主角
	self.charModel:setIsLock(false)
	self:setLockPlayerModel(self.npcModel)

	local npcPoint = self.npcModel.myView:convertToWorldSpaceAR(cc.p(0,0));

	local moveX = GameVars.width/2 - npcPoint.x
	local moveY = GameVars.height/2 - npcPoint.y

	local autoClickNpc = function()
		self.npcModel:setIsClickNpc(true)
		self:onClickNpc(self.npcModel)
	end

	self.mainMap:moveWorld(moveX, moveY,c_func(autoClickNpc,self))
end

function WorldMapControler:calculateTanAngle(point1,point2)
	local dx = point2.x - point1.x
    local dy = point2.y - point1.y
    local ang = math.atan2(-dy, dx) *  180 / math.pi
    return ang
end

-- 停止六界所有models
function WorldMapControler:onStopAllModels()
	-- echo("\n停止所有models")
	for i=1,#self.playerArr do
		local player = self.playerArr[i]
		player:pauseMe()
	end

	local visible = self.mapUI:checkIsVisible()
end

function WorldMapControler:deleteMe()
	echo("\n\n WorldMapControler deleteMe")
	WorldModel:saveCharMapInfo(self.charModel.pos,self.charModel:getCharScaleX(),self.charModel:getCharFace())

	for k,v in pairs(self.playerArr) do
		if v then
			v:deleteMe()
		end
	end

	-- 删除地标
	for k,v in pairs(self.spaceArr) do
		if v then
			v:deleteMe()
		end
	end

	-- 删除场景特效
	for k,v in pairs(self.mapEffArr) do
		if v then
			v:deleteMe()
		end
	end

	self.mainMap:deleteMe()
	self.mapCreator:deleteMe()

	EventControler:clearOneObjEvent(self)
end

-- 停止六界所有models
function WorldMapControler:onStopAllModels()
	-- echo("\n停止所有models")
	for i=1,#self.playerArr do
		local player = self.playerArr[i]
		player:pauseMe()
	end

	for i=1,#self.spaceArr do
		local space = self.spaceArr[i]
		space:pauseMe()
	end
end

-- 恢复六界所有models
function WorldMapControler:onResumeAllModels()
	-- echo("\n恢复所有models")
	for i=1,#self.playerArr do
		local player = self.playerArr[i]
		player:resumeMe()
	end

	for i=1,#self.spaceArr do
		local space = self.spaceArr[i]
		space:resumeMe()
	end
end

return WorldMapControler
