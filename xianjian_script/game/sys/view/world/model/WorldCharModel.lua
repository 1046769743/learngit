--[[
	Author: ZhangYanguang
	Date: 2017-05-02
	六界主角model
]]

local WorldBaseCharModel = require("game.sys.view.world.model.WorldBaseCharModel")
WorldCharModel = class("WorldCharModel",WorldBaseCharModel)

function WorldCharModel:ctor(controler,sex)
	WorldCharModel.super.ctor(self,controler)

	self.flySpeed = 0
	if controler then
		self.baseScale = controler.charScale
		self.flySpeed = controler.charFlySpeed
		self.worldBorderInfo = controler:getWorldBorderInfo()
	end
	
	self.charSex = sex
	self.nameOffsetX = 20
	if self.charSex == 1 then
		self.nameOffsetY = 280
	else
		self.nameOffsetY = 300
	end

    -- 飞行头部特效
    self.flyHeadEffCfg = {
    	{pos={x=80,y=150},rotation=0},
    	{pos={x=10,y=200},rotation=-90},
    	{pos={x=-30,y=180},rotation=-180},

    	{pos={x=-30,y=140},rotation=110},
    	{pos={x=-10,y=120},rotation=90},

    	{pos={x=0,y=160},rotation=70},
	}

	self.charMoveStatus =  {
		STAND = 0,  --静止不动
		WALK = 1,   --普通走动
		FLY = 2,    --极速
	}

	self.flyEffNameCfg = {
		-- 男
		"eff_world_treasure_a1_jixing",
		-- 女
		"eff_world_treasure_b1_jixing"
	}

	self.flyEffName = self.flyEffNameCfg[self.charSex]

    self.mySize = {width = 180,height = 180}
    self._isLock = false

    -- 伙伴相对主角位置的偏移值
    self.partnersOffsetX = 220
    self.partnersOffsetY = 45

    -- 是否开启极速飞行特效
    self.openFlyEff = true
    self.isInit = true
end

function WorldCharModel:registerEvent()
	WorldCharModel.super.registerEvent(self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_MAP_TOUCH,self.onTouchMap,self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_CLICK_ONE_NPC,self.onTouchMap,self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_CLICK_ONE_SPACE,self.onTouchMap,self)
	 -- 阵容变化
    EventControler:addEventListener(TeamFormationEvent.TEAMFORMATIONEVENT_CHANGE_TEAMFORMATION,self.updateFuncMenuRedPoint,self)

    EventControler:addEventListener(UserEvent.USEREVENT_NAME_CHANGE_OK, 
        self.setTitleNameData, self)

    EventControler:addEventListener(UserEvent.USEREVENT_SET_NAME_OK, 
        self.setTitleNameData, self)

    ---穿戴，卸下
    EventControler:addEventListener(TitleEvent.TitleEvent_C_X_CALLBACK,
        self.setTitleNameData, self)
    --限时已到
    EventControler:addEventListener(TitleEvent.TitleEvent_ONTIME_CALLBACK,
        self.setTitleNameData, self)
    --购买头衔
    EventControler:addEventListener("BUY_TOUXIAN_EVENT", 
        self.setTitleNameData, self) 
end

function WorldCharModel:initView(...)
	WorldCharModel.super.initView(self,...)
	self:setCharMoveStatus(self.charMoveStatus.STAND)
	
	if self.isInit then
		self:mapViewAction(0)
		self.isInit = false
	end
	
	self:setClickFunc()
	self:upateWorldBorderInfo()
end

--刷新函数
function WorldCharModel:updateFrame( )
	WorldCharModel.super.updateFrame(self)

	if self.partnerView then
		self:updatePartners()
	end
end

function WorldCharModel:updatePartners()
	if self.partnerView then
		self.partnerView:pos(self.pos.x+self.partnersOffsetX,self.pos.y+self.partnersOffsetY)
	end
end

function WorldCharModel:setNameView(viewCtn,nameView)
	if not nameView then
		return
	end

	if self.myView then
		self.nameView = nameView
		nameView:setVisible(true)
		self.myView:addChild(nameView)
		self.nameView:pos(self.nameOffsetX,self.nameOffsetY)
		self:setTitleNameData()
	end
end

--[[
	设置伙伴
]]
function WorldCharModel:setPartners(partnerView)
	if not partnerView then
		return 
	end

	if self.myView then
		partnerView:setVisible(true)
		self.viewCtn:addChild(partnerView)
		self.partnerView = partnerView

		self.controler:setViewRotation3DBack(partnerView)
	end
end

function WorldCharModel:getPartnersView()
	return self.partnerView
end

function WorldCharModel:setTitleNameData()
	local data = {
		titleId = TitleModel:gettitleids(),
		name = UserModel:name(),
		crown = UserModel:crown() ,
	}

	if self.nameView then
		self.nameView:update(data)
	end
end

function WorldCharModel:upateWorldBorderInfo()
	if self.worldBorderInfo then
		self.worldBorderInfo.minX = self.worldBorderInfo.minX + self.mySize.width /2
		self.worldBorderInfo.maxX = self.worldBorderInfo.maxX - self.mySize.width /2

		self.worldBorderInfo.minY = self.worldBorderInfo.minY + self.mySize.height /2
		self.worldBorderInfo.maxY = self.worldBorderInfo.maxY - self.mySize.height /2
	end
end

function WorldCharModel:setViewRotation3D()
	WorldCharModel.super.setViewRotation3D(self)
end

function WorldCharModel:setShadowView(viewCtn,shadowView)
	viewCtn:addChild(shadowView)
	self.shadowView = shadowView

	if self.shadowView then
		if self.controler then
			self.controler:setViewRotation3DBack(self.shadowView)
		end
	end
end

function WorldCharModel:setCharViewScale(scale)
	self:setViewScale(scale)
	if self.shadowView then
		self.shadowView:setScale(scale)
	end
end

-- 播放极速特效
function WorldCharModel:playFlyEff()
	if not self.openFlyEff then
		return
	end

	if not self.flyEffName then
		return
	end

	if self.moveStatus == self.charMoveStatus.FLY then
		if not self.flyHeadEff then
			self.flyHeadEff = ViewSpine.new(self.flyEffName)
    		self.viewCtn:addChild(self.flyHeadEff,1)

    		self.flyHeadEff:playLabel(self.flyEffName)
    		self.flyHeadEff:setScale(1.0)

    		self.controler:setViewRotation3DBack(self.flyHeadEff)
		end

		self.flyHeadEff:setVisible(true)
		self.flyHeadEff:pos(self.pos.x,self.pos.y + self.mySize.height)
		self.flyHeadEff:setRotation(-self.rotation)
	else
		if self.flyHeadEff then
			self.flyHeadEff:setVisible(false)
		end
	end
end

function WorldCharModel:setCharMoveStatus(status)
	self.moveStatus = status
end

function WorldCharModel:setIsLock(isLock)
	self._isLock = isLock
end

function WorldCharModel:isLock()
	return self._isLock
end

function WorldCharModel:moveToPoint(targetPoint, speed,moveType )
	self:ajustTargetPoint(targetPoint)
	WorldCharModel.super.moveToPoint(self,targetPoint, speed,moveType)
	--映射view的视图
	self:mapViewAction(self.ang * 180/math.pi)
end

function WorldCharModel:ajustTargetPoint(targetPoint)
	local point = self:getAjustedPos(targetPoint)
	targetPoint.x = point.x
	targetPoint.y = point.y
end

function WorldCharModel:setCharPos(point)
	local pos = self:getAjustedPos(point)
	self:setPos(pos.x,pos.y,0)
end

function WorldCharModel:getAjustedPos(targetPoint)
	if not self.worldBorderInfo then
		return targetPoint
	end

	local minX = self.worldBorderInfo.minX
	local maxX = self.worldBorderInfo.maxX

	local minY = self.worldBorderInfo.minY
	local maxY = self.worldBorderInfo.maxY

	local pos = {x=targetPoint.x,y=targetPoint.y}
	if targetPoint.x <= minX then
		pos.x = minX
	end

	if targetPoint.x >= maxX then
		pos.x = maxX
	end

	if targetPoint.y <= minY then
		pos.y = minY
	end

	if targetPoint.y >= maxY then
		pos.y = maxY
	end

	return pos
end

function WorldCharModel:getAbsSpeed()
	local speed = math.sqrt(self.speed.x*self.speed.x+self.speed.y*self.speed.y)
	return speed
end

-- isEnd 运动是否结束
function WorldCharModel:onMoveToPointCallBack(isEnd)
	echo("\nWorldCharModel onMoveEndCallBack pos=",self.pos.x,self.pos.y)
	if isEnd then
		if self.controler then
			self.controler:onCharArriveTargetPostion()
		end
	end
end

function WorldCharModel:setCharFace(charFace)
	self.charFace = charFace
	if self.myView then
		self.myView:playLabel(self.charFace)
	end
end

function WorldCharModel:getCharFace()
	return self.charFace
end

function WorldCharModel:setCharScaleX(charScaleX)
	self.charScaleX = charScaleX
	-- if self.myView then
	-- 	self.myView.currentAni:setScaleX(self.charScaleX * self.viewScale)
	-- end
	self:setWay(self.charScaleX)
end

function WorldCharModel:getCharScaleX()
	return self.charScaleX
end

function WorldCharModel:getCharFaceActionIndex()
	-- echo("self.charFace==",self.charFace)
	-- echo("self.charScaleX==",self.charScaleX)
	for i=1,#self.charFaceAction do
		local curAction =  self.charFaceAction[i]
		if self.charFace == curAction[1] and self.charScaleX == curAction[2] then
			return i
		end
	end
end

function WorldCharModel:setZOrder( zorder )
	WorldCharModel.super.setZOrder(self,zorder)
	if self.funcItem then
		self.funcItem:zorder(zorder)
	end
end

function WorldCharModel:getSortPos()
	self._sortPos.x = self.pos.x - self.mySize.width / 2
	self._sortPos.y = self.pos.y
	return self._sortPos
end

function WorldCharModel:dummyFrame()
	self:checkMoveStatus()
	self:playFlyEff()
	self:updateShadow()
	self:updateFuncItem()

	self:ajustCharPos()
end

function WorldCharModel:ajustCharPos()
	if not self.worldBorderInfo then
		return
	end

	local pos = self:getAjustedPos(self.pos)
	self:setPos(pos.x,pos.y,0)

	--[[
	if not self.count then
		self.count = 1
	end

	if self.count % 10 == 0 then
		echo("self.pos=---------",self.pos.x,self.pos.y)
		dump(self.speed)
	end

	self.count = self.count + 1
	]]
end

function WorldCharModel:updateFuncItem()
	if self.funcItem then
		local charWorldPos = self:getWorldPos()

		local dx = charWorldPos.x + self.mySize.width / 2
		local x = 0
		
		if dx > GameVars.width then
			x = self.pos.x - self.mySize.width + 30
		else
			x = self.pos.x + self.mySize.width / 2 - 30
		end

		local y = self.pos.y + self.mySize.height
		self.funcItem:pos(x,y)
	end
end

function WorldCharModel:updateShadow()
	if self.shadowView then
		self.shadowView:pos(self.pos.x,self.pos.y)
	end
end

-- 检查运动状态
function WorldCharModel:checkMoveStatus()
	local speed = math.max(math.abs(self.speed.x),math.abs(self.speed.y))
	-- echo("speed---------",speed,self.flySpeed)
	if speed == 0 then
		self:setCharMoveStatus(self.charMoveStatus.STAND)
	elseif speed < self.flySpeed then
		self:setCharMoveStatus(self.charMoveStatus.WALK)
	else
		self:setCharMoveStatus(self.charMoveStatus.FLY)
	end
end

-- 主角与npc碰撞检测
function WorldCharModel:checkHit()
	-- echo("self.controler.npcModel.isClickNpc==",self.controler.npcModel.isClickNpc)
	if not self.controler or not self.controler.npcModel then
		return
	end

	local npcX = self.controler.npcModel.pos.x
	local npcY = self.controler.npcModel.pos.y

	-- echo("self.controler.npcModel:isClickNpc()=============",self.controler.npcModel:isClickNpc())
	if not self.controler.npcModel:isClickNpc() then
		return
	end

	local charX = self.pos.x
	local charY = self.pos.y + self.mySize.height / 2
	
	if math.abs(charX - npcX) <= self.controler.npcMeetDis and math.abs(charY - npcY) <= self.controler.npcMeetDis then
		-- echo("相遇....self.isClickNpc=")
		if not self._isMeetNpc then
			-- echo("\n===========onCharMeetNpc=============",self.controler.npcModel:isClickNpc())
			self:onCharMeetNpc()
		end
		self._isMeetNpc = true
	else
		-- echo("没相遇math.abs(charX - npcX)=",math.abs(charX - npcX))
		-- echo("math.abs(charY - npcY)=",math.abs(charY - npcY))
		self._isMeetNpc = false
	end
end

--[[
	当主角与npc相遇
]]
function WorldCharModel:onCharMeetNpc( )
	self.controler:onCharMeetNpc()
	self.controler.npcModel:setIsClickNpc(false)
	-- 强制设置主角朝向(不再根据主角与npc间角度使用实际朝向)
	local npcModel = self.controler.npcModel
	-- npc在右
	if npcModel.pos.x > self.pos.x then
		self:setRightAction()
	else
		self:setLeftAction()
	end
end

function WorldCharModel:isMeetNpc( )
	return self._isMeetNpc
end

--给场上英雄注册点击事件 点击后显示 明按
function WorldCharModel:setClickFunc( )
	-- TODO屏蔽主角点击事件
	if true then
		return
	end

	local nd = display.newNode()
	
	--[[
	-- 测试代码
	local color = color or cc.c4b(255,0,0,120)
  	local layer = cc.LayerColor:create(color)
    nd:addChild(layer)
    nd:setTouchEnabled(true)
    nd:setTouchSwallowEnabled(true)
    layer:setContentSize(cc.size(self.charWidth,self.charHeight) )
	]]
    nd:setContentSize(self.mySize)
    nd:pos(-self.mySize.width / 2,self.mySize.height / 2)
	
	-- nd:setContentSize(cc.size(figure,figure) )
	nd:addto(self.myView,1)
	nd:setTouchedFunc(c_func(self.onClickChar,self),nil,true)
end

function WorldCharModel:onTouchMap()
	-- TODO 屏蔽主角菜单
	--[[
	if self.isShowMenu then
		self:playFuncAnim()
	end
	]]
end

function WorldCharModel:onClickChar(  )
	-- TODO 屏蔽主角菜单
	-- self:createFuncMenu()
	-- self:playFuncAnim()
end

-- 创建功能菜单动画
function WorldCharModel:createFuncMenu()
	if not self.funcItem then
		self.funcItem = self.controler.mapUI:createUIArmature("UI_shijieditu","UI_shijieditu_gongnenganniu",self.viewCtn, false, GameVars.emptyFunc)
		self.isShowMenu = false
		self:funcItemCallBack()
	end
	self:updateFuncMenuRedPoint()
end

-- 更新功能菜单红点状态
function WorldCharModel:updateFuncMenuRedPoint()
	if self.funcItem then
		local garmentRedPoint = self.funcItem:getBone("hongdian1")
		garmentRedPoint:setVisible(false)

		local formationRedPoint = self.funcItem:getBone("hongdian2")
		local isOpen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.ARRAY)
		if isOpen then
			local hasIdlePosition = TeamFormationModel:hasIdlePosition()
			formationRedPoint:setVisible(hasIdlePosition)
		end
	end
end

-- 播放主角点击功能菜单
function WorldCharModel:playFuncAnim()
	if not self.funcItem then
		return
	end

	self.isShowMenu = not self.isShowMenu

	if self.isShowMenu then
		self.funcItem:setVisible(true)
		self.funcItem:startPlay(false)
	else
		if self.funcItem.playWithIndex then
			self.funcItem:playWithIndex(2,false,true)
		else
			echoWarn("WorldCharModel:playFuncAnim playWithIndex is nil")
		end
	end
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              

-- 设置菜单项点击事件
function WorldCharModel:funcItemCallBack()
	local showGarmentView = function()
		self:playFuncAnim()
		self.controler:goCharGarmentView()
	end

	local showFormationView = function()
		self:playFuncAnim()
		self.controler:goFormationView()
	end

	local garmentItem = self.funcItem:getBoneDisplay("layer1")
	garmentItem:addTo(self.funcItem:getBone("layer1"))

	local formationItem = self.funcItem:getBoneDisplay("layer4")
	formationItem:addto(self.funcItem:getBone("layer4"))

	garmentItem:setTouchedFunc(c_func(showGarmentView),nil,true)
	formationItem:setTouchedFunc(c_func(showFormationView),nil,true)
end

-- TODO 临时解决3d坐标转到导致的判断屏幕内不准确的问题
-- 获取view边界信息
function WorldCharModel:getBorderInfo()
	local offsetX1 = GameVars.width * 0.22
	local offsetX2 = GameVars.width * 0.23

	local offsetY1 = GameVars.height * 0.19
	local offsetY2 = GameVars.height * 0.17

	local info = {}
	local minX = -self.mySize.width / 2 - GameVars.UIOffsetX + offsetX1
	local maxX = GameVars.width + self.mySize.width / 2 + GameVars.UIOffsetX - offsetX2

	local minY = -self.mySize.height - GameVars.UIOffsetY + offsetY1
	local maxY = GameVars.height + GameVars.UIOffsetY - offsetY2
 
	info.minX = minX
	info.maxX = maxX
	info.minY = minY
	info.maxY = maxY

	return info
end

--[[
	主角为序章衔接特效写死动作
]]
function WorldCharModel:playActionForPrologue()
	self.myView.currentAni:setScaleX(-1)
    self.myView:playLabel("crossrange")

    self.partnerView:playLabel("stand")
end

function WorldCharModel:setVisible(visible)
	if self.shadowView then
		self.shadowView:visible(visible)
	end

	if self.flyHeadEff then
		self.flyHeadEff:visible(visible)
	end

	if self.partnerView then
		self.partnerView:visible(visible)
	end
	WorldCharModel.super.setVisible(self,visible)
end

function WorldCharModel:deleteMyView()
	WorldCharModel.super.deleteMyView(self)
	if self.shadowView then
		self.shadowView:removeFromParent()
		self.shadowView = nil
	end

	if self.flyHeadEff then
		self.flyHeadEff:removeFromParent()
		self.flyHeadEff = nil
	end

	if self.partnerView then
		self.partnerView:removeFromParent()
		self.partnerView = nil
	end
end

function WorldCharModel:deleteMe()
	WorldCharModel.super.deleteMe(self)
end

return WorldCharModel
