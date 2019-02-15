--
-- Author: XD
-- Date: 2014-07-11 11:28:31
--

local k = 59
local keyDatas = 
{
	["A"]= 65+k, ["B"]= 66+k, ["C"]= 67+k, ["D"]= 68+k, 
	["E"]= 69+k, ["F"]= 70+k, ["G"]= 71+k, ["H"]= 72+k,
	["I"]= 73+k, ["J"]= 74+k, ["K"]= 75+k, ["L"]= 76+k, 
	["M"]= 77+k, ["N"]= 78+k, ["O"]= 79+k, ["P"]= 80+k, 
	["Q"]= 81+k, ["R"]= 82+k, ["S"]= 83+k, ["T"]= 84+k, 
	["U"]= 85+k, ["V"]= 86+k, ["W"]= 87+k, ["X"]= 88+k, 
	["Y"]= 89+k, ["Z"]= 90+k, ["0"]= 48+k, ["1"]= 77, 
	["2"]= 78, 	 ["3"]= 79,   ["4"]= 80,   ["5"]= 81, 
	["6"]= 82,   ["7"]= 83,   ["8"]= 84,   ["9"]= 85, 
	
	["a"]= 65+k, ["b"]= 66+k, ["c"]= 67+k, ["d"]= 68+k, 
	["e"]= 69+k, ["f"]= 70+k, ["g"]= 71+k, ["h"]= 72+k,
	["i"]= 73+k, ["j"]= 74+k, ["k"]= 75+k, ["l"]= 76+k, 
	["m"]= 77+k, ["n"]= 78+k, ["o"]= 79+k, ["p"]= 80+k, 
	["q"]= 81+k, ["r"]= 82+k, ["s"]= 83+k, ["t"]= 84+k, 
	["u"]= 85+k, ["v"]= 86+k, ["w"]= 87+k, ["x"]= 88+k, 
	["y"]= 89+k, ["z"]= 90+k,
	
}










KeyControler= {}
KeyControler.node =nil
--							x,y,	r  按键区域的坐标和半径
KeyControler.circle_1 = {x=142,y=473,r=100}
--							第二个限制区域的 坐标和半径
KeyControler.circle_2 = {x=GameVars.width-142,y=473,r=100}


KeyControler.angle1 = nil 		--区域1的按键角度  给外部调用的
KeyControler.angle2 = nil 		--区域2的按键角度  给外部调用的 nil 表示没有按下

KeyControler.outRectArr =nil
KeyControler.touchIdObj  =nil
KeyControler.touchNums = 2 		-- 设置触摸的点数量 暂定为一个








function KeyControler:pressKeyClick(id,eventName,x,y  )
	
	if self["angle"..id] == 1 then
		if eventName ~= "moved" then
			self:pressKeyDown(self.touchTypeObj[id].keyCode)
		end
		self["view"..id]:gotoAndStop(2)
	else
		self["view"..id]:gotoAndStop(1)
		if eventName ~= "moved" then
			self:pressKeyUp(self.touchTypeObj[id].keyCode)
		end
	end

end



KeyControler.touchTypeObj = {
	--type 		区域  如果是运动的  那么就是一个大圆加小圆
	{type="move",area = {x=140,y=140,r=100},moveR= 60 		},
	{type="click",keyCode = keyDatas.j,  area ={x=GameVars.width-300,y= 100,r =100 },images = {"ui/keyBtn_00.png","ui/keyBtn_01.png"} ,funcs = { c_func(KeyControler.pressKeyClick,KeyControler,2 ),c_func(KeyControler.pressKeyClick,KeyControler,2 ),c_func(KeyControler.pressKeyClick,KeyControler,2 )	 } 				},
	{type="click",keyCode = keyDatas.k,area ={x=GameVars.width-200,y= 200,r =100 },images = {"ui/keyBtn_02.png","ui/keyBtn_03.png"}	,funcs = { c_func(KeyControler.pressKeyClick,KeyControler,3 ),c_func(KeyControler.pressKeyClick,KeyControler,3 ),c_func(KeyControler.pressKeyClick,KeyControler,3 )	 } 			},
	{type="click",keyCode = keyDatas.l,area ={x=GameVars.width-100,y= 300,r =100 },images = {"ui/keyBtn_04.png","ui/keyBtn_05.png"}	,funcs = { c_func(KeyControler.pressKeyClick,KeyControler,4 ),c_func(KeyControler.pressKeyClick,KeyControler,4 ),c_func(KeyControler.pressKeyClick,KeyControler,4 )	 } 			},
	--{type="move",area = {x=display.w-142,y=200,r=100},moveR= 60 		},
}





local ratio = 0.7

local function creatCircleView( circle ,moveR,ctn)
	local node =display.newNode():addto(ctn):pos(circle.x,circle.y)
	local cir1 = display.newCircle(circle.r, {fillColor = cc.c4f(0.5, 0, 0,0.5)}):addto(node)
	
	local cir2 = display.newCircle(moveR, {fillColor = cc.c4f(0, 0.5, 0,0.5)}):addto(node)
	node.view = cir2
	return node
end




local function creatClickView( area ,ctn,images)
	local mc = MovieClip.creatOneMovieClip(images)
	mc:addto(ctn)
	if area.r then
		mc:pos(area.x - area.r/2,area.y + area.r/2)
	elseif area.w then
		mc:pos(area.x - area.w/2,area.y + area.r/2)
	end
	--local mc = display.newNode():addto(ctn)
	return mc
end




function KeyControler:init(node)
	self.circle_1 = {x=142,y=473,r=100}
	self.circle_2 = {x=GameVars.width-142,y=473,r=100}

	
	--记录当前记录的touchid 是否按下
	self.touchIdObj = {}

	self.outRectArr= {}
	self.outRectArr[1] = {x=0, y=0, w=300, h=70};
	self.outRectArr[2] = {x=0, y=618,w=333,h=101};
	self.outRectArr[3] = {x=1032,y=618,w=239,h=101};


	self.node = display.newLayer():addto(node)

	
	

	self:registerKeyEvent()
	return self
end


function KeyControler:creatBtns(  )

	--遍历所有的点击事件
	for i,v in ipairs(self.touchTypeObj) do
		if v.type =="click" then
			local mc = MovieClip.creatOneMovieClip(v.images )


		end
	end

	-- BtnImg.new("ui/keyBtn_00.png","ui/keyBtn_01.png"):addto(self.node):pos(GameVars.width-300,100):setBegan(c_func(self.pressKeyDown,self,keyDatas["j"])):setEnded(c_func(self.pressKeyUp,self,keyDatas["j"])):setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
	-- BtnImg.new("ui/keyBtn_02.png","ui/keyBtn_03.png"):addto(self.node):pos(GameVars.width-200,200):setBegan(c_func(self.pressKeyDown,self,keyDatas["k"])):setEnded(c_func(self.pressKeyUp,self,keyDatas["k"])):setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
	-- BtnImg.new("ui/keyBtn_04.png","ui/keyBtn_05.png"):addto(self.node):pos(GameVars.width-100,300):setBegan(c_func(self.pressKeyDown,self,keyDatas["l"])):setEnded(c_func(self.pressKeyUp,self,keyDatas["l"])):setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)

end



function KeyControler:pressTouchDown( event )
	local result

	for i,v in ipairs(self.touchTypeObj) do
		for k,s in pairs(event.points) do
			if v.type =="move" then
				if  circleEx.contain(v.area, s.x, s.y) then
					result = true
					self.touchIdObj[k] = i
					if v.funcs then
						v.funcs[1]("began",s.x,s.y)
					end
				end
			elseif v.type =="click" then
				if circleEx.contain(v.area, s.x, s.y) then 
					result = true
					self.touchIdObj[k] = i
					if v.funcs then
						v.funcs[1]("began",s.x,s.y)
					end
				end
			end
			
		end

	end

	if not result then
		return false
	end
	--按下后做一次move
	self:pressTouchMove(event)
	

	return true
end

function KeyControler:pressTouchMove( event )
	local cir,ang,dx,dy
	local index 

	for k,s in pairs(event.points) do
		index = self.touchIdObj[k]
		if index then
			local info = self.touchTypeObj[index]

			if info.type =="move" then
				cir = info.area
				--计算对应的角度
				dx = s.x - cir.x
				dy = s.y - cir.y
				--那么计算角度

				--这里是 cocos的角度  要转换成 flash角度 以后所有的角度 按照flash角度算 配合引擎需要
				local ang =  math.atan2(dy,dx)
				if ang < 0 then
					ang = ang + math.pi *2
				end
				self["angle"..index] = math.pi *2 - ang
				self:updateViewPos(index)
			elseif info.type =="click" then
				--如果是区域操作  那么move的时候 必须在这个区域内 才执行回调函数
				if not circleEx.contain(info.area, s.x, s.y) then
					self["angle"..index] = nil
				else
					self["angle"..index]  =1
				end

			end
			if info.funcs then
				info.funcs[2](event.name,s.x,s.y)
			end
			
		end
	end

	return true
end

function KeyControler:pressTouchEnd( event )
	local index 
	for k,s in pairs(event.points) do
		index = self.touchIdObj[k]
		self.touchIdObj[k] = nil
		if index then
			local info =  self.touchTypeObj[index]
			
			--恢复坐标
			self:updateViewPos(index,true)
			self["angle"..index] = nil
			if info.funcs then
				info.funcs[3]("ended",s.x,s.y)
			end
		end
	end

	

	return true
end


function KeyControler:updateViewPos( index ,resumeCheck)
	local info = self.touchTypeObj[index]

	if info.type =="move" then
		local view = self["view"..index]
		if resumeCheck then
			view.view:pos(0,0)
		else
			--这里要把flash角度转化城cocos角度 在去计算
			local ang =  math.pi *2 - self["angle"..index]
			local circle = info.area
			local r = info.area.r- info.moveR
			view.view:pos(r*math.cos(ang),r*math.sin(ang))
		end
	end

	
end






--按键信息

KeyControler.w=false
KeyControler.s=false
KeyControler.a=false
KeyControler.d=false

KeyControler.j=false
KeyControler.k=false
KeyControler.l=false
KeyControler.i=false


KeyControler.jover =false
KeyControler.kover =false
KeyControler.lover =false
KeyControler.iover =false


local useKeyArr = {"w","s","a","d","j","k","l","i"}




function KeyControler:registerKeyEvent()
    
    --必须是windows平台
	if device.platform ~= "windows" then
		return
	end

	local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(c_func(self.pressKeyDown,self), cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(c_func(self.pressKeyUp,self), cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
    
    self.keyListener = listener

end

function KeyControler:pressKeyDown(keyCode)


	--计算角度

	for i,v in ipairs(useKeyArr) do
		if keyCode == keyDatas[v] then
			self[v] = true
			FightEvent:dispatchEvent(KeyControler.Event_KEYUP,keyCode)
			self:countKeyAngle()
			return
		end
	end
end


--计算角度
function KeyControler:countKeyAngle( )
	if self.a then
		--如果是左上
		if self.w then
			self.angle1= math.pi/4*5
		elseif self.s then
			--左下
			self.angle1= math.pi/4*3
		else
			self.angle1 = math.pi
		end
	elseif self.d then
		--如果是右上
		if self.w then
			self.angle1= math.pi/4*7
		elseif self.s then
			--右下
			self.angle1= math.pi/4*1
		else
			self.angle1 = 0
		end
	elseif self.w then
		self.angle1 = math.pi /4*6
	elseif self.s then
		self.angle1 = math.pi /4*2
	else
		--全部放下了 那么角度为nil
		self.angle1 = nil
	end
end


function KeyControler:pressKeyUp(keyCode )

	--
	self:keyDebug(keyCode)

	for i,v in ipairs(useKeyArr) do
		if keyCode == keyDatas[v] then
			self[v] = false
			if self[v.."over"] then
				self[v.."over"] =false
			end

			self:countKeyAngle()
			FightEvent:dispatchEvent(KeyControler.Event_KEYUP,keyCode)
			return
		end
	end
	self.angle1 = nil
end


function KeyControler:keyDebug( keyCode )
	-- 26 27 28 29对用 ←→ ↑ ↓ 
	--帧频调试
	if keyCode == 23 then
		self:changeFrameRate(-1)
	elseif keyCode == 24 then
		self:changeFrameRate(1)
	elseif keyCode == 25 then
		self:changeFrameRate(5)
	elseif keyCode == 26 then
		self:changeFrameRate(-5)
	end

	echo(keyCode,"________________")

	--如果是暂停事件
	if keyCode == 136 then
		--发送一个暂停侦听
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE)
		echo("___dispatchGamePauseEvent")
	end


end


function KeyControler:changeFrameRate( value )
	GameVars.GAMEFRAMERATE = GameVars.GAMEFRAMERATE +value
	if GameVars.GAMEFRAMERATE < 3 then
		GameVars.GAMEFRAMERATE = 3
	elseif GameVars.GAMEFRAMERATE > 60 then
		GameVars.GAMEFRAMERATE = 60
	end
	 -- cc.Director:getInstance():setAnimationInterval(1.0/GameVars.GAMEFRAMERATE )

end



function KeyControler:deleteMe(  )
	 cc.Director:getInstance():getEventDispatcher():removeEventListener(self.keyListener)
	 self.node:clear()
end



return KeyControler