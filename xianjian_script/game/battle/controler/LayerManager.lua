--
-- Author: xd
-- Date: 2014-01-02 10:21:52
--


LayerManager= class("LayerManager")


--[[

	Layer = {
		a1=游戏层{
			
			a1c 


		}



	}




]]


local yuandian = {x=0,y=0}

local shakePosGroup  = {
	{0,0},
	{6,10},
	{0,0},
	{-5,-8},
	{-9,-2},
	{6,2},
}


LayerManager.flashImg = nil

LayerManager.blackImage = nil

function LayerManager:ctor( controler)
		
	self.controler = controler

	-- 主场景朝下对其  所以需要偏移方式不同 
	local gameLayers = display.newNode():pos(GameVars.UIOffsetX,GameVars.height - GameVars.UIOffsetY*2 )
	--gameLayers:setAnchorPoint(cc.p(0,1))
	--ui.cover(gameLayers)
	local turnGameScale = 1
	local widOff = 0
	local heiOff = 0
	--目前战场宽度是按照1024 最低宽度适配的,如果 宽度小于这个值 那么需要把整体容器缩放一下
	-- if GameVars.width < 1024 then
	-- 	turnGameScale = GameVars.width / 1024
	-- 	widOff = math.round(1024 - GameVars.width) /2
	-- 	heiOff = math.round(GameVars.height* (1-turnGameScale))
	-- end

	--针对960的机器 会把gameLayer整体进行缩小,这样保证战场宽度会宽一些

	--把gameLayers 绕中心对称 
	if Fight.cameraWay == -1 then
		gameLayers:setScaleX(-turnGameScale)

		gameLayers:pos(GameVars.UIOffsetX + GameVars.gameResWidth * turnGameScale  +  widOff ,GameVars.height - GameVars.UIOffsetY*2 - heiOff)
	else
		gameLayers:setScaleX(turnGameScale)
		gameLayers:pos(GameVars.UIOffsetX  +  widOff ,GameVars.height - GameVars.UIOffsetY*2 - heiOff)
	end
	gameLayers:setScaleY(turnGameScale)
	

	local node = display.newNode():addto(gameLayers)
	node:anchor(0.5,0.5):setContentSize(cc.size(GameVars.width*3,GameVars.height * 3))
	node:setTouchSwallowEnabled(true)
	node:setTouchedFunc(GameVars.emptyFunc,nil,true,nil,nil,false)
	self.a = gameLayers
	gameLayers:setAnchorPoint(yuandian)


	local layer,i
	for i=1,4 do
		layer = display.newNode()
		--layer:setAnchorPoint(yuandian)
		gameLayers:addChild(layer)
		self["a"..i] = layer
	end
	

	--目前添加一层camera 层 这个需要 被a1嵌套  因为 执行shake的时候 可能 会和camera的坐标计算 冲突
	self.a2c = display.newNode():addto(self.a2)


	-- a12c 表示 a12c放在a12的第一层  a12b表示 a12 放在a12b的第一层  角标 c b 的作用就是多一层父载体,,用于镜头缩放等操作会方便很多
	for i=1,4 do
		layer = display.newNode()
		--layer:setAnchorPoint(yuandian)
		
		self["a1"..i] = layer
		if i==2 then
			self.a12 = display.newNode():addto(self.a1)
			self.a12b =  display.newNode():addto(self.a12)
		else
			self.a1:addChild(layer)
		end

		--第二层游戏空间 目前暂时没有用到
		layer = display.newNode():addto(self.a2c)
		--异次元容器层 是a2  
		self["a2"..i] = layer

	end

	-- self.a11:pos(-GameVars.UIOffsetX ,0)
	-- self.a13:pos(-GameVars.UIOffsetX,0)
	self.ctnOffsetX = -GameVars.UIOffsetX - turnGameScale * widOff
	-- self.a1:pos(ctnOffsetX,0)
	self.a11:pos(self.ctnOffsetX,0)
	self.a12:pos(self.ctnOffsetX,0)
	self.a13:pos(self.ctnOffsetX,0)
	
	self.flashImg = display.newSprite("a/a1_4.png"):size(GameVars.width,GameVars.height):addto(self.a1):anchor(0,1)
	--self.flashImg:hide()
	self.flashImg:setCascadeOpacityEnabled(true)
	self.flashImg:visible(false)
	for i=1,4 do

		--这里 对后面场景也分4层 地面  远景1 远景2  远景3 远景4 

		layer = display.newNode()
		self.a12b:addChild(layer)
		self["a12"..i] = layer


		layer = display.newNode()
		self.a22:addChild(layer)
		self["a22"..i] = layer

	end


	--self.chaseBgAni = ViewArmature.new("zhuidatexiao_beijing"):addto(self.a122):visible(false)
	-- self.chaseBgAni = FuncArmature.createArmature("zhuidatexiao_beijing", self.a124, false,GameVars.emptyFunc)
	-- self.chaseBgAni:visible(false)
	-- self.chaseBgAni:gotoAndPause(0)
	-- self.chaseBgAni:zorder(Fight.chaseZOrder)
	-- self.chaseBgAni:setScale(1.3)


	self.blackImage = display.newSprite("a/a2_4.png"):addto(self.a122):visible(false)
	self.blackImage:opacity(255 * 0.4)
	--黑屏的zorder 写死为999 要挡住所有的中景元素的 所以要大些
	self.blackImage:zorder(Fight.zorder_blackScreen)
	--考虑到最大缩放系数所以黑屏的区域尽量大点
	self.blackImage:size(GameVars.width *3,GameVars.height *2)
	return self
end

-- 显示追打屏幕
function LayerManager:showChaseBg(x,y)
	x = x or GameVars.width/2
	y = y or -GameVars.height/2
	self.chaseBgAni:pos(x,y)
	self.chaseBgAni:visible(true)
	self.chaseBgAni:startPlay(false)
end

function LayerManager:hideChaseBg()
	self.chaseBgAni:getAnimation():playWithIndex(2)
end

--显示黑屏
function LayerManager:showBlackImage(x,y )
	x = x or GameVars.width/2
	y = y or -GameVars.height/2
	self.blackImage:pos(x,y)
	--self.blackImage:opacity(180)
	self.blackImage:visible(true)
	self.blackImage:opacity(0)
	self.blackImage:stopAllActions()
	transition.fadeTo(self.blackImage,{time = 0.2,opacity = 255* 0.7})
end

--关闭黑屏
function LayerManager:hideBlackImage(  )
	-- self.blackImage:visible(false)
	-- self.blackImage:opacity(0)
	self.blackImage:stopAllActions()
	self.blackImage:fadeTo(0.4, 0)
	local onComplete = function (  )
		self.blackImage:visible(false)
	end
	transition.fadeTo(self.blackImage,{time = 0.5,opacity = 0,onComplete = onComplete})
end


--屏幕闪红光
function LayerManager:flashLayer_red( )
	self.flashImg:visible(true)
	self.flashImg:setColor(cc.c3b(40,0, 0))
	self.flashImg:opacity(128)
	FilterTools.flash_alpha_degress(self.flashImg,10, 2, 50, self.showOrHideFlashImg,{self,false}  )
end


--隐藏 闪光图
function LayerManager:showOrHideFlashImg( value )
	self.flashImg:visible(value)
end

 

--震屏 						持续帧  力度    震屏方式 1,x 2,y 3 xy 方向震动
function LayerManager:shake( frame,range,shakeType )
	--如果是游戏加速的 不创建特效
	if self.controler:isQuickRunGame() then
		return
	end
	range = range and tonumber(range) or 2
	frame = frame and tonumber(frame) or 6
	shakeType = shakeType and shakeType or "xy"
	self.shakeInfo = {
		frame = frame,
		shakeType = shakeType 
	}
	if shakeType == "x" then
		self.shakeInfo.range = {range,0}
	elseif shakeType == "y" then
		self.shakeInfo.range = {0,range}
	else
		self.shakeInfo.range = {range,range}
	end
	self.shakeInfo.range = {range,range}
	local shakeLayer = self.a1

	if self.oldPos then
		shakeLayer:pos(self.oldPos[1],self.oldPos[1])
	else
		self.oldPos = {shakeLayer:getPosition() }
	end
end


function LayerManager:updateFrame( )
	if not self.shakeInfo then
		return
	end
	
	local shakeLayer = self.a1

	self.shakeInfo.frame = self.shakeInfo.frame-1
	
	local oldXpos =  self.oldPos[1] or 0
	local oldYpos = self.oldPos[2]  or 0

	local posIndex = self.shakeInfo.frame % #shakePosGroup
	posIndex = #shakePosGroup - posIndex


	local posArr = shakePosGroup[posIndex]
	shakeLayer:pos(posArr[1] *self.shakeInfo.range[1], posArr[2] *self.shakeInfo.range[2] )
	-- local pianyi =   (self.shakeInfo.frame %2 *2 -1 ) 

	-- shakeLayer:pos(oldXpos + pianyi*self.shakeInfo.range[1],oldYpos + pianyi * self.shakeInfo.range[2] )

	if self.shakeInfo.frame ==0 then
		self.shakeInfo = nil
		shakeLayer:pos(oldXpos,oldYpos)
		self.oldPos = nil
	end

end


function LayerManager:getGameCtn(id  )
	return self["a12"..id]
end

--设置整个游戏 visible
function LayerManager:setGameVisible( value )
	self.a:setVisible(value)
end

--设置地图visible
function LayerManager:setMapVisible( value )
	self.a11:setVisible(value)
	self.a13:setVisible(value)
end



-- mainlayer层
function LayerManager:deleteMe(  )
	self.a:clear()
	self.a = nil
end


