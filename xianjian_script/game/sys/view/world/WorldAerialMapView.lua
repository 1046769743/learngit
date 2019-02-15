-- Author: ZhangYanguang
-- Date: 2017-04-17
-- 六界新版缩略图界面

local WorldAerialMapView = class("WorldAerialMapView", UIBase);

function WorldAerialMapView:ctor(winName)
    WorldAerialMapView.super.ctor(self, winName);
end

function WorldAerialMapView:loadUIComplete()
	self:initData()
	self:initView()
	self:registerEvent()
	self:registerGestureEvent()
	self:updateUI()
end 

function WorldAerialMapView:initData()
	-- 开启摩擦系数
    self.openCharMoveF = false

	self.mapConfig = require("world.mapTextureConfig.lua")

	self.mainMapWidth = self.mapConfig.rect.width
	self.mainMapHeight = self.mapConfig.rect.height

	-- 创建地图
	self.mapBg = display.newSprite(FuncRes.iconPVE("world_map_aeria"))
	-- 缩略图尺寸
	self.aerialBgWidth = self.mapBg:getContentSize().width
	self.aerialBgHeight = self.mapBg:getContentSize().height

	self.bgXScale = GameVars.width / self.aerialBgWidth
	self.bgYScale = GameVars.height / self.aerialBgHeight

	-- echo("self.bgXScale,self.bgYScale=",self.bgXScale,self.bgYScale)

	-- 4800 3240 大地图尺寸
	self.mapXScale = (self.aerialBgWidth / self.mainMapWidth) * self.bgXScale
	self.mapYScale = (self.aerialBgHeight / self.mainMapHeight ) * self.bgYScale

	-- 主角缩放比例
	self.charScale = 0.5

	-- 主角普通飞行速度
    self.charMoveSpeed = 8

    -- 主角尺寸
    self.charSize = {width = self.charScale * 180,height = self.charScale  * 180}
    self.locationView_map = {}
end

function WorldAerialMapView:initView()
	-- 去大地图
	self.btnGoBigMap = self.btn_large
	
	self:initMap()
	self:initViewAlign()
	self.UI_world_zuobiao:setVisible(false)
end

-- UI适配
function WorldAerialMapView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name,UIAlignTypes.LeftTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)
	
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_large,UIAlignTypes.LeftBottom)

	-- 地图适配
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mapNode,UIAlignTypes.LeftTop)
end

function WorldAerialMapView:initMap()
	self.mapNode = display.newNode()
	-- self.mapNode:pos(-GameVars.UIOffsetX, GameVars.UIOffsetY)
	self:addChild(self.mapNode,-1)

	self.touchNode = display.newNode():addTo(self,-1)
	self.touchNode:pos(0,-GameVars.height)
    self.touchNode:setContentSize(cc.size(GameVars.width,GameVars.height))

	-- 创建地图
	local mapBg = self.mapBg
	mapBg:anchor(0,1)
	mapBg:setScaleX(self.bgXScale)
	mapBg:setScaleY(self.bgYScale)

	self.mapNode:addChild(mapBg)

	self.touchNode:setTouchedFunc(c_func(self.onTouchMapEnd,self), nil, false, c_func(self.onTouchMapBegin,self), c_func(self.onTouchMapMove,self))
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
end

function WorldAerialMapView:registerEvent()
	self.btnGoBigMap:setTap(c_func(self.onClickGoMainMap,self))
	self.btn_back:setTap(c_func(self.onClickBack,self))


	EventControler:addEventListener(WorldEvent.WORLDEVENT_UPDATE_AERIA_MAP,self.updateMapInfo,self)
end
function WorldAerialMapView:addChatUI()
	FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.CHAT)
end
function WorldAerialMapView:registerGestureEvent()
	local lastDis = nil
	local curDis = nil

	local function onTouchesBegan(touches, event)
		if #touches >=2 then
			self.isSwitch = false
			local point1 = touches[1]:getLocationInView()
			local point2 = touches[2]:getLocationInView()

			lastDis = math.sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
			return true
		end
	end

	local function onTouchesMoved(touches, event)
		if #touches >= 2 then
			local point1 = touches[1]:getLocationInView()
			local point2 = touches[2]:getLocationInView()

			curDis = math.sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
			if lastDis == nil then
				lastDis = curDis
			end

			if lastDis and curDis then
				if curDis > lastDis and curDis - lastDis > 30 then
					echo("Aeria手势放大")
					if not self.isSwitch then
						self.isSwitch = true
						self:onClickGoMainMap()
					end
				elseif lastDis > curDis and lastDis - curDis > 30 then
					-- echo("手势缩小")
				end
			end
			return true
		end
	end

	local  function onTouchesEnded(touches, event)
		if #touches >=2 then
			lastDis = nil
			curDis = nil
			return true
		end
	end

	local listener = cc.EventListenerTouchAllAtOnce:create()    
	self.touchListener = listener

    listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED )

    local eventDispatcher = self.mapNode:getEventDispatcher()
    self.eventDispatcher = eventDispatcher

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.mapNode)
end

-- 更新按钮状态
function WorldAerialMapView:updateBtnStatus()
	local openBtnArr = {}

	-- 找到所有的已开启功能按钮
	for i=1,#self.btnMap do
		local btnInfo = self.btnMap[i]
		local openFunc = btnInfo.openFunc
		local sys = btnInfo.sys
		local btn = btnInfo.btn

		if openFunc and openFunc() then
			btn:setVisible(true)
			local index = #openBtnArr+1
			openBtnArr[index] = {sys=sys,pos=self.btnPosArr[index],btn=btn}
		else
			btn:setVisible(false)
		end
	end

	-- 设置已开启按钮的位置
	for i=1,#openBtnArr do
		local btn = openBtnArr[i].btn
		local pos = openBtnArr[i].pos
		local sys = openBtnArr[i].sys
		btn:pos(pos.x,pos.y)

		FuncCommUI.clearAdapterView(btn)
		FuncCommUI.setViewAlign(self.widthScreenOffset,btn,UIAlignTypes.RightBottom)
	end
end 

function WorldAerialMapView:updateUI()
	-- self:updateBtnStatus()
	-- self:updateRedPointStatus()
end

function WorldAerialMapView:updateRedPointStatus()
	self.btnGoPVEListView:getUpPanel().panel_red:setVisible(WorldModel:showMainRedPoint())
	-- -- 精英副本红点 zgy
	self.btnGoEliteView:getUpPanel().panel_red:setVisible(WorldModel:showEliteRedPoint())
	-- 挂机红点
	if DelegateModel:isOpen() then
		self.btn_wt:visible(true)
	end
	
	self.btn_wt:getUpPanel().panel_red:visible(DelegateModel:isShowRedPoint())
	-- 轶事红点
	self.btnMissionView:getUpPanel().panel_red:setVisible(MissionModel:isShowRed())
	-- 情景卡红点
	self.btnMemoryView:getUpPanel().panel_red:setVisible(MemoryCardModel:checkRedPointShow())
end

function WorldAerialMapView:onTouchMapBegin(event)
	echo("点击坐标===",event.x,event.y)
end

function WorldAerialMapView:onTouchMapMove(event)
	
end

function WorldAerialMapView:onTouchMapEnd(event)
	local charTargetPos = self.mapNode:convertToNodeSpaceAR(event)

	charTargetPos.speed = self.charMoveSpeed
	if self.openCharMoveF then
		charTargetPos.speed = 10
		charTargetPos.minSpeed = 5
    	charTargetPos.f = 0.97
	end
    
	self.charModel:moveToPoint(charTargetPos)
	self.charTargetPos = charTargetPos

	if not self.isDragingWorld then
    	self:playGuildAnim(charTargetPos)
    end
end

function WorldAerialMapView:updateGuildAnim()
	if self.guildAnim and self.charTargetPos then
		local x = self.charModel.pos.x
		local y = self.charModel.pos.y

		if x == self.charTargetPos.x and y == self.charTargetPos.y then
			self.guildAnim:setVisible(false)
		end
	end
end

function WorldAerialMapView:updateFrame()
	if self.charModel then
		self.charModel:updateFrame()
	end

	self:updateGuildAnim()
end

-- 播放指引动画
function WorldAerialMapView:playGuildAnim(targetPos)
	if not self.charTargetPos then
		self.charTargetPos = targetPos
	end

	local x = targetPos.x
	local y = targetPos.y

    local callBack = function()
        self.guildAnim:setVisible(false)
    end

    if not self.guildAnim then
        self.guildAnim = self:createUIArmature("UI_shijieditu","UI_shijieditu_zhishi",nil, false, GameVars.emptyFunc)
        self.mapNode:addChild(self.guildAnim,2)
        self.guildAnim:setScale(0.5)
    end

    self.guildAnim:pos(x,y)
    self.guildAnim:setVisible(true)
    -- self.guildAnim:registerFrameEventCallFunc(self.guildAnim.totalFrame,1,callBack)
    self.guildAnim:startPlay(true)
end

function WorldAerialMapView:updateMapInfo(data)
	if not self.charModel then
		self.charModel = self:createChar()
		self.charModel:setCharViewScale(self.charScale)
	end

	local mapInfo = data.params.mapInfo
	local charFace = mapInfo.charFace
	local charPos = mapInfo.charPos
	local charScaleX = mapInfo.charScaleX
	local charTargetPos = mapInfo.charTargetPos

	self.charModel:setCharScaleX(charScaleX)
	self.charModel:setCharFace(charFace)

	local charPosX = charPos.x * self.mapXScale
	local charPosY = charPos.y * self.mapYScale
	self.charModel:setPos(charPosX,charPosY)

	charTargetPos.x =  charTargetPos.x * self.mapXScale
	charTargetPos.y =  charTargetPos.y * self.mapYScale

	self.charTargetPos = charTargetPos

	-- echo("缩略图主角移动。。。。。。。。。")
	-- echo("charPosX,charPosY==",charPosX,charPosY)
	-- dump(charTargetPos)

	-- todo moveToPoint导致朝向不对
	if charTargetPos.speed > 0 then
		self.charModel:moveToPoint(charTargetPos)
		self:playGuildAnim(charTargetPos)
	end
end

function WorldAerialMapView:getMapInfo()
	local x = self.charModel.pos.x
	local y = self.charModel.pos.y

	local mapInfo = {}
	mapInfo.charFace = self.charModel:getCharFace()
	mapInfo.charPos = {x = x / self.mapXScale,y = y / self.mapYScale}
	mapInfo.charScaleX = self.charModel:getCharScaleX()
	mapInfo.charTargetPos = self:convertPointToMainMap(self.charTargetPos)
	mapInfo.charTargetPos.speed = self.charModel:getAbsSpeed()

	return mapInfo
end

function WorldAerialMapView:convertPointToMainMap(point)
	local newPoint = {}
	newPoint.x = point.x / self.mapXScale
	newPoint.y = point.y / self.mapYScale

	return newPoint
end

-- 创建主角
function WorldAerialMapView:createChar()
	local charInitPos = {x=0,y=0}
	local charModel = require("game.sys.view.world.model.WorldCharModel").new()

	local charSex = nil
	if PrologueUtils:showPrologue() then
		charSex = FuncChar.getCharSex(LoginControler:getLocalRoleId())
	else
		charSex = UserModel:sex()
	end

	local playerSpine = self:getCharSpine(charSex)

    -- playerSpine:zorder(2)
    charModel:initView(self.mapNode,playerSpine,charInitPos.x,charInitPos.y,0,self.charSize)
    local shadow = display.newSprite(FuncRes.iconPVE("world_char_shadow"))
	-- playerSpine:addChild(shadow)
	charModel:setShadowView(self.mapNode,shadow)
	charModel:setZOrder(1)
    return charModel
end

function WorldAerialMapView:getCharSpine(sex)
	local spineName = ""
	if sex == FuncChar.SEX_MAP.MAN then
		spineName = "world_treasure_a1"
	elseif sex == FuncChar.SEX_MAP.FEMALE then
		spineName = "world_treasure_b1"
	end

	if LoginControler:isLogin() and GarmentModel:isOwnOtherGarmentId() then
		local garmentId = GarmentModel:isOwnOtherGarmentId()
		spineName = FuncGarment.getWorldSpineById(sex, garmentId)
	end

	return ViewSpine.new(spineName)
end

function WorldAerialMapView:onClickGoMainMap()
	local mapInfo = self:getMapInfo()
	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_SHOW_MAIN_MAP,{mapInfo=mapInfo})
end

function WorldAerialMapView:startHide()
	WorldAerialMapView.super.startHide(self)
	if self.charModel then
		self.charModel:deleteMe()
	end
	self:unscheduleUpdate()
	self.mapNode:getEventDispatcher():removeEventListener(self.touchListener);
end

function WorldAerialMapView:onClickBack()
	-- self:startHide()
	-- WorldModel:clearCharMapPos()
	-- WindowControler:closeWindow("WorldMainView")
	self:onClickGoMainMap()
end

return WorldAerialMapView
