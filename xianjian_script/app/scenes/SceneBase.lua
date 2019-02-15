--
-- User: zhangyanguang
-- Date: 2015/6/10
-- scene基类，实现处理偏移、黑边填充等基本功能

local SceneBase = class("SceneBase", function()
		return display.newScene("SceneBase")
	end 
 )

function SceneBase:ctor()
	self.__sceneBgRoot = display.newNode():addto(self)--:scale(GameVars.rootScale)

	self._root = display.newNode();
	self:anchor(0,0)

	--这里创建一个doc的原因是因为  scene 是不能缩放的 缩放scene会出bug 这个是cocos底层的 原造成的
	self.__doc = display.newNode():addto(self)--:scale(GameVars.rootScale)

	--self:scale(GameVars.rootScale);


	self.__doc:addChild(self._root)

	--根容器偏移
	self.__doc:setPositionX(GameVars.sceneOffsetX)
	self.__doc:setPositionY(GameVars.sceneOffsetY)
	
	ScreenAdapterTools.initDatas()
	--填充黑边
	self:fillBlackBorder();
	
end

function SceneBase:isSceneBgRoot(node)
	return node == self.__sceneBgRoot
end

--设置隐藏 
function SceneBase:setBgRootVisible( value )
	if self.__sceneBgRoot then
		self.__sceneBgRoot:setVisible(value)
	end
end

function SceneBase:registEvent()
	EventControler:addEventListener(PCSdkHelper.EVENT_SCREEN_ORIENTATION,self.onScreenOrientationChange, self)
end

local borderColor =cc.c4b(0,0,0,255)

--填充黑边
function SceneBase:fillBlackBorder()
    local screenOffsetX = GameVars.sceneOffsetX;
    if screenOffsetX > 0 then
    	local leftBorderBg = cc.LayerColor:create(borderColor)
	    -- :size(screenOffsetX, display.height)
	    :size(screenOffsetX, GameVars.scaleHeight)
	    :pos(0, 0);
	    self:addChild(leftBorderBg);

	    local rightBorderBg = cc.LayerColor:create(borderColor)
	    :size(screenOffsetX, GameVars.scaleHeight)
	    :pos(GameVars.scaleWidth-screenOffsetX, 0);
	    self:addChild(rightBorderBg);
    end

    local screenOffsetY = GameVars.sceneOffsetY;
    if screenOffsetY > 0 then

    	local spTop = display.newSprite(FuncRes.iconBg("global_bg_heibian") )
  		spTop:setScaleX(GameVars.scaleWidth/GameVars.gameResWidth)
    	spTop:anchor(0.5,0)
    	spTop:pos(GameVars.scaleWidth/2,GameVars.scaleHeight-screenOffsetY)
    	self:addChild(spTop,2);

    	local spButtom =  display.newSprite (FuncRes.iconBg("global_bg_heibian") )
    	spButtom:anchor(0.5,0):setScaleY(-1)
    	spButtom:setScaleX(GameVars.scaleWidth/GameVars.gameResWidth)
    	spButtom:pos(GameVars.scaleWidth/2,screenOffsetY)
    	self:addChild(spButtom,2);

    end
end

function SceneBase:updateBarPos(  )
	--ios 和android 显示这个bar
	if device.platform == "ios" or device.platform == "android" then 
		return
	end

	--添加刘海 0 表示没有刘海 必须宽度大于1280
    if GameVars.toolBarWay ~= 0 and GameVars.width >= 1280  then
    -- if AppInformation:isIphoneX() then
    	if not self._barSp then
    		self._barSp = display.newSprite("icon/other/other_liuhai.png", 0):addto(self)

    		local touhedFunc = function (  )
    			echo("模拟屏幕翻转")
    			local way = ScreenAdapterTools.getCurrentWay(  )
			    self:onScreenChange({way = way*(-1)})
    		end

    		self._barSp:setTouchedFunc(touhedFunc, nil, true)


    		-- --创建4个遮挡框
    		-- local posArr = {
    		-- 	{0,GameVars.height,0},
    		-- 	{GameVars.width ,GameVars.height,90},
    		-- 	{GameVars.width ,0,180},
    		-- 	{0 ,0,270},

    		-- }
    		-- for i=1,4 do
    		-- 	local info = posArr[i]
    		-- 	local sp = display.newSprite("icon/other/border_grid.png", info[1], info[2])
    		-- 	sp:setRotation(info[3])
    		-- 	sp:anchor(0,1)
    		-- 	sp:addto(self)
    		-- end

    	end
    	sp = self._barSp
    	local spWid = sp:getContentSize().width
    	if ScreenAdapterTools.getCurrentWay(  ) == 1 then
    		sp:setScaleX(-1)
    		sp:pos(GameVars.fullWidth-spWid/2,GameVars.height /2)
    	else
    		sp:setScaleX(1)
    		sp:pos(spWid/2,GameVars.height /2)
    	end
    end
end

-- 屏幕方向发生旋转
function SceneBase:onScreenOrientationChange(event)
	-- TODO  屏蔽iPhoneX屏幕旋转
	if true then
		return
	end

	if not AppInformation:isIphoneX() then
		return
	end

	-- Home键方向
	local homeOrien = nil
	if event and event.params then
		homeOrien = event.params.orientation
	end
	echo("mostsdk-onScreenOrientationChange=",homeOrien)

	local toolBarWay = - homeOrien
	-- ScreenAdapterTools.onScreenChange( toolBarWay )
	self:updateBarPos()
end

function SceneBase:onScreenChange( event )
	local way = event.way 
	echo("改变屏幕方向-----",way)
	ScreenAdapterTools.onScreenChange( way )
	self:updateBarPos()
end


function SceneBase:onEnter()
	
end

function SceneBase:onExit()
	--清理所有ui
	WindowControler:clearAllWindow()

	--清理掉所有的子ui 以及没有清理完毕的
	UIBase.deleteAllChild(self )
end

--开始清除场景 --子类扩展
function SceneBase:startClear(  )
	
end



return SceneBase