-- Author: ZhangYanguang
-- Date: 2017-04-17
-- 六界新版大地图界面

local WorldMainMapView = class("WorldMainMapView", UIBase);

function WorldMainMapView:ctor(winName)
    WorldMainMapView.super.ctor(self, winName);
end

function WorldMainMapView:loadUIComplete()
	self:initView()
	self:initMap()
	self:registerEvent()
	self:initViewAlign()
	-- 如果是序章，更新部分UI显示
	if PrologueUtils:showPrologue() then
		-- self:hideUI()
		-- 序章引导选角成功打点
		ClientActionControler:sendNewDeviceActionToWebCenter(
			ActionConfig.guide_enter_world);
	end
end

function WorldMainMapView:initView()
	-- 玩家名字，地图上第三方玩家显示用
	self.UI_name_title:setVisible(false)
end

function WorldMainMapView:initMap()
	self:initUITouchLayer()

	if IS_CLEAR_PACKAGE_AFTER_HIDE then
		package.loaded["game.sys.view.world.map.WorldMapControler"] = nil
		package.loaded["game.sys.view.world.map.WorldMap"] = nil
	end

	local mapControlerClazz = require("game.sys.view.world.map.WorldMapControler")
	local mapConfig = require("world.mapTextureConfig.lua")
	self.mapControler = mapControlerClazz.new(self,mapConfig)
	self.mainMap = self.mapControler:getMap()

	self:addChild(self.mainMap,-2)

	if self.mapControler.isMapLeftDown then
		self.mainMap:pos(0,-GameVars.height)
	end
end

-- 在地图上之上创建UI触摸层
function WorldMainMapView:initUITouchLayer()
	local onTouchMapBegin = function()
		-- echo("点击UI WorldMainMapView self.isTouchSwallow=",self.isTouchSwallow)
		EventControler:dispatchEvent(WorldEvent.WORLDEVENT_MAP_UI_TOUCH)
		if not self.isTouchSwallow then
			return true
		end
	end

	local onTouchMapMove = function()
		if not self.isTouchSwallow then
			return true
		end
	end

	local onTouchMapEnd = function()
		if not self.isTouchSwallow then
			return true
		end
	end

	self.uiTouchNode = display.newNode():addTo(self,1)

	self.uiTouchNode:pos(-GameVars.UIOffsetX,-GameVars.height+GameVars.UIOffsetY)
	self.uiTouchNode:setContentSize(cc.size(GameVars.width,GameVars.height))
	self.uiTouchNode:setTouchedFunc(c_func(onTouchMapEnd), nil, true, c_func(onTouchMapBegin), c_func(onTouchMapMove))
    self.uiTouchNode:setTouchSwallowEnabled(false)
end

-- enable:UI是否可以点击
function WorldMainMapView:setTouchEnable(enable)
	self.isTouchSwallow = not enable
	self.uiTouchNode:setTouchSwallowEnabled(self.isTouchSwallow)
end

function WorldMainMapView:registerEvent()
	-- TODO PC上测试进入缩略图
	EventControler:addEventListener("WORLD_TEST_ENTER_AERIA", self.onClickGoAeriaMap, self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_CLOSE_WORLD, self.deleteMe, self)
end

-- UI适配
function WorldMainMapView:initViewAlign()
	-- 地图适配
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mainMap,UIAlignTypes.LeftTop)
end

-- 更新按钮状态
function WorldMainMapView:updateBtnStatus()
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
		btn:pos(pos.x,pos.y)
		
		FuncCommUI.clearAdapterView(btn)
		FuncCommUI.setViewAlign(self.widthScreenOffset,btn,UIAlignTypes.RightBottom)
	end

	WorldControler:setWorldMapBtnInfo(openBtnArr)
end

-- 注册气泡
function WorldMainMapView:registerBubleView(view,sysName,offset,issubtypes)
	 local conditions = {
        systemname = sysName,
        npc = false,
        offset = offset or {
          x = -60,
          y = 120,
        },
        issubtypes = issubtypes,
      }
      FuncCommUI.regesitShowBubbleView(conditions,view)
end

function WorldMainMapView:onClickGoMissionView()
	if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MISSION) then
		WindowControler:showWindow("MissionMainView");
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_worldAerial_003"))
	end
end

--点击显示聊天
function WorldMainMapView:onClickChatView()
	FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.CHAT)
end

function WorldMainMapView:onClickGoMemoryView()
	MemoryCardModel:showMemoryCardView( )
end

function WorldMainMapView:onClickGoAeriaMap()
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		return
	end

	local mapInfo = self.mapControler:getMapInfo()
	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_SHOW_AERIAL_MAP, {mapInfo = mapInfo})
end

function WorldMainMapView:onClickGoPVEListView()
	if WorldModel:isOpenPVEMemory() then
		WindowControler:showWindow("WorldPVEListView")
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_worldAerial_001"))
	end
end 

function WorldMainMapView:onClickGoEliteView()
	if WorldModel:isOpenElite() then
		WindowControler:showWindow("EliteMainView")
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_worldAerial_002"))
	end
end

-- 去共享副本 by LXH
function WorldMainMapView:onClickGoShareBoss()
	if WorldModel:isOpenShareBoss() then
		ShareBossControler:enterShareBossMainView()		
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_worldAerial_004"))
	end
end

function WorldMainMapView:deleteMe()
	if self.mapControler then
		self.mapControler:deleteMe()
	end
	WorldMainMapView.super.deleteMe(self)
end

function WorldMainMapView:onClickBack()
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		return
	end
	self:startHide()
	WorldModel:clearCharMapPos()
	WindowControler:closeWindow("WorldMainView")
end
function WorldMainMapView:startHide( ... )
	WorldMainMapView.super.startHide(self)
end

function WorldMainMapView:checkIsVisible( )
	local mainView = WindowControler:getWindow("WorldMainView")
	return mainView:isVisible()
end

return WorldMainMapView
