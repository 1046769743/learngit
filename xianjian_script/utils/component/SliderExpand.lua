--
-- Author: xd
-- Date: 2015-12-04 16:24:55
--
local SliderExpand = class("SliderExpand", function (  )
	return display.newNode()
end)


--self.panel_s  --滑块 必须有
--self.progress_s --进度条 必须有
--self.panel_min --最小值 可有可无
--self.panel_max --最大值 可有可无

SliderExpand.startPos = nil 		--起始坐标
SliderExpand.endPos = nil 			--结束坐标
SliderExpand.sliderType = 0 		--滑动方式  1水平     -1 垂直
SliderExpand.way = 1 				--滑块运动方向  1 是从左到右 或者从上到下  -1是从上到下

function SliderExpand:ctor( cfgs )
	self:initData()
end

function SliderExpand:initData()
	self.minPercent = 0
	self.maxPercent = 100
	self._min = 0
	self._max = 100
end

function SliderExpand:setMinMax( min,max )
	self._min = min
	self._max = max
	self:_setPercent(0,true)
end

--初始化完毕
function SliderExpand:initComplete( )
	self:setWay(1)
	if self.btn_max then
		self.btn_max:setTouchedFunc( c_func(self.pressMaxBtn, self ) )
	end


	if self.btn_min then
		self.btn_min:setTouchedFunc( c_func(self.pressMinBtn, self ) )
	end


	self:setTouchedFunc(c_func(self.pressSliderEnd, self), nil, nil, c_func(self.pressSliderStart, self),c_func(self.pressSliderMove, self) ,nil,c_func(self.touchSliderEnd, self) )

	self.panel_s:setTouchedFunc(c_func(self.pressSliderEnd, self), nil, true, c_func(self.pressSliderStart, self),c_func(self.pressSliderMove, self),nil,c_func(self.touchSliderEnd, self) )
	self:_setPercent(0,true)
end

--设置最大
function SliderExpand:pressMaxBtn( )
	self:_setPercent(self.maxPercent)
end

--设置最小
function SliderExpand:pressMinBtn(  )
	self:_setPercent(self.minPercent)
end


--滑块开始
function SliderExpand:pressSliderStart( event )
	if self.sliderDisable then
		return
	end
	--获取鼠标坐标
	self.mouseDown = self:convertToNodeSpace(cc.p(event.x,event.y))
	self:pressSliderMove(event)
end


--滑块运动
function SliderExpand:pressSliderMove( event )
	if self.sliderDisable then
		return
	end
	--根据运动方向 确定 滑块的坐标
	local sliderPos = self:convertToNodeSpace(cc.p(event.x,event.y))

	--边界判断
	local dis =0 --距离

	local percent = 0 --百分比
	--如果是左右运动的
	if self.sliderType ==1 then
		--y坐标初始化
		sliderPos.y = self.startPos.y

		if sliderPos.x < self.startPos.x then
			sliderPos.x = self.startPos.x
		elseif sliderPos.x > self.endPos.x then
			sliderPos.x = self.endPos.x
		end

		--从左往右
		if self.way == 1 then
			dis = sliderPos.x - self.startPos.x

		else
			dis = self.endPos.x - sliderPos.x
		end

	else
		--x坐标初始化
		sliderPos.x = self.startPos.x

		if sliderPos.y > self.startPos.y then
			sliderPos.y = self.startPos.y
		elseif sliderPos.y < self.endPos.y then
			sliderPos.y = self.endPos.y
		end

		if self.way == 1 then
			dis = self.startPos.y - sliderPos.y
		else
			dis = sliderPos.y - self.endPos.y
		end
	end

	--计算百分比
	percent = ( dis / self.sliderLenth * 100 )
	if percent <= self.minPercent then
		percent = self.minPercent
	end

	if self.sliderMax and percent > self.sliderMax then
		percent = self.sliderMax
	end

	self:_setPercent(percent)
end

--设置百分比
function  SliderExpand:_setPercent(per, isInit, isRunCallback)
	if self.percent == per and not isInit then
		return
	end

	local sliderPos = {}

	--边界判断

	local dis =0 --距离

	local percent = 0 --百分比
	--如果是左右运动的
	if self.sliderType ==1 then
		--y坐标初始化
		sliderPos.y = self.startPos.y

		--从左往右
		if self.way == 1 then
			sliderPos.x = math.round( self.startPos.x + self.sliderLenth * per/100 )
		else
			sliderPos.x = math.round( self.endPos.x - self.sliderLenth * per/100 )
		end
		sliderPos.x = sliderPos.x+  self.adjustPos.x

	else
		--x坐标初始化
		sliderPos.x = self.startPos.x

		--从上到下
		if self.way == 1 then
			sliderPos.y = math.round( self.endPos.y - self.sliderLenth * per/100    )

		else
			sliderPos.y = math.round( self.startPos.y + self.sliderLenth * per/100    )
		end
		sliderPos.y = sliderPos.y+  self.adjustPos.y
	end


	self.panel_s:pos(sliderPos.x  ,sliderPos.y)

	self.progress_s:setPercent(per)

	self.percent = per

	--当slider改变的时候 
	if self.__onSliderChange and isRunCallback == nil then
		self.__onSliderChange(per)
		
	end

	if self.txt_percent then
		local p = per

		p = p/100 * (self._max-self._min) + self._min
		p = math.round(p)

		if self._txtDiv ~= nil then 
			p = p / self._txtDiv;
		end 

		self.txt_percent:setString( p )
	end

end

function SliderExpand:getTxtPercent()
	return self.txt_percent.childLabels[1]:getString();
end

function SliderExpand:setTxtDiv(num)
	self._txtDiv = num;
end

--滑块运动结束
function SliderExpand:pressSliderEnd(event )
end
function SliderExpand:touchSliderEnd(event )
	if self.__onSliderEnd then
		self.__onSliderEnd(self.percent)
	end
end

function SliderExpand:onSliderEnd( func )
	self.__onSliderEnd = func
end


--设置方向 1 表示从左到右  从上到下  2表示 从右到左或者从下到上 默认是1
function  SliderExpand:setWay( way )
	self.way = way


	--初始化 起点 终点 方向

	--这里 rect 是获取相对于父容器的坐标
	local rect = self.progress_s:getContainerBoxToParent()

	local sliderx,slidery = self.panel_s:getPosition()


	

	-- dump(self:getContainerBox(),"__rect")

	local prox,proy = self.progress_s:getPosition()

	
	
	local x,y = self.panel_s:getPosition()

	self.adjustPos = {x=x - rect.x,y = y - rect.y }

	--判断方向 如果宽大于高
	if(rect.width > rect.height) then
		self.sliderType = 1

		self.startPos  ={x = rect.x,y = y    }
		self.endPos = {x = rect.x + rect.width,y= y}

		--滑动区域长度
		self.sliderLenth = rect.width

		if way ==1 then
			
			self.progress_s:setDirection(ProgressBar.l_r)
		else
			self.progress_s:setDirection(ProgressBar.r_l)
		end

	else
		self.sliderType = -1

		self.startPos = {x = x, y = rect.y + rect.height }
		self.endPos  =  {x= x, y = rect.y} 
		
		--滑动区域长度
		self.sliderLenth = rect.height

		if way == 1 then
			self.progress_s:setDirection(ProgressBar.u_d)
		else
			self.progress_s:setDirection(ProgressBar.d_u)

		end

	end

	--self.progress_s:_setPercent(0)
end

-----------------------外部需要调用的接口------------
--设置初始化最小百分比
function SliderExpand:setInitPercent(percent)
	if tonumber(percent) ~= nil then
		self.minPercent = tonumber(percent)
		if self.minPercent >= self.maxPercent then
			self.minPercent = self.maxPercent
		end
		self:_setPercent(self.minPercent)
	end
end

--设置百分比
function SliderExpand:setPercent(percent, isInit, isRunCallback)
	self:_setPercent(percent, isInit, isRunCallback)
end

--获取百分比
function SliderExpand:getPercent()
	return self.percent
end

--一般会传递一个回调 就是当 滑块发生变化的时候 注册的回调    同时 回传了一个当前的百分比 0-100之间的数
--func(percent)
function SliderExpand:onSliderChange( func )
	self.__onSliderChange = func
end

--滑块滑动是 最大的界限设置
function SliderExpand:onSliderMax(max)
	self.sliderMax = max
end

--设置是否禁止滑动 true 是禁止滑动
function SliderExpand:setSliderDisable( value )
	self.sliderDisable = value
end

return SliderExpand