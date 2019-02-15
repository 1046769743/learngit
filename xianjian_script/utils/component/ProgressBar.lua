
-- User: cwb
-- Date: 2015/5/4
-- 进度条组件


--------------------------------
-- @module ProgressBar

--[[--

	进度条

	每次创建时应该首先配置方向,设置初始化百分比.

]]


local resUrl = "uipng/"
local globalPngsUrl = "globalPngs/"

local globalPngCfg = require("viewConfig.globalPngCfg");

local ProgressBar = class("ProgressBar", function()
    return display.newNode()
end)

ProgressBar.l_r = 0         --左到右
ProgressBar.r_l = 1         --右到左
ProgressBar.d_u = 2         --下到上
ProgressBar.u_d = 3         --上到下

ProgressBar.ld_ru = 4         --左下到右上
ProgressBar.lu_rd = 5         --左上到右下
ProgressBar.rd_lu = 6         --右下到左上
ProgressBar.ru_ld = 7         --右上到左下

ProgressBar.c_o = 11             --从中心到 外边扩展
ProgressBar.o_c = 12             --从外边到中心 

-- 遮罩方式
ProgressBar.STYLE = {
    POS = 0,
    SCALE = 1,
}

function ProgressBar:ctor(cfgs,image)

	self.cfgs = cfgs
    self._style = ProgressBar.STYLE.POS
	-- 当前进度
	self.curPercent = 0
    if CONFIG_USEDISPERSED then
        self._image =resUrl.. cfgs[UIBaseDef.prop_image]
    else
        if globalPngCfg.globalPngMap[cfgs[UIBaseDef.prop_image]] == 1 then 
            self._image = globalPngsUrl .. cfgs[UIBaseDef.prop_image];
        else 
            self._image ="#".. cfgs[UIBaseDef.prop_image]
        end 
    end
    
    --默认从坐到右
    self.direction = self.l_r 

    self:setStyle( {_style = ProgressBar.STYLE.POS ,_image = self._image} )


    -- 这个可能进度条有渐变色时候就不行了
    --self.size  = self.bar:getContentSize()
    --self.size.width = 100
    --dump(self.size)
    --self.bar:setContentSize(self.size)

end


--------------------------------
-- 设置进度的方向
-- @function
-- @param dir 

function ProgressBar:setDirection(dir)
    self.direction = dir and dir or 0
    self:resetBarSpriteAnchor()
end
function ProgressBar:getDirection()
    return self.direction
end
--------------------------------
-- 设置遮罩方式
--param = {
--    _style =  ProgressBar.STYLE.POS or  ProgressBar.STYLE.SCALE --进度条实现方式
--    _image    --资源路径 如果为空 就是 自身的_image
--    _size     --九宫图contantsize 
--    _capInsets     --九宫图capInsets 注意：依据原图得出  
--}
function ProgressBar:setStyle(param)
    local image = param._image or self._image
    local size = param._size or self.barSize
    self._style = param._style and param._style or ProgressBar.STYLE.POS
    if self._style == ProgressBar.STYLE.SCALE then

        if self.bar then
            self.bar:removeFromParent()
        end
        if self.maskCtn then
            self.maskCtn:removeFromParent()
        end
        local capInsets = param._capInsets --or {x=size.width/3,y = size.height/3,width = size.width/3*2,height = size.height/3*2}
        self.is9Sprite = false  
        if  param._capInsets then -- 此时是九宫图
            self.bar = display.newScale9Sprite(image,nil,nil,size,capInsets):anchor(0,1)
            self.is9Sprite = true
            
        else  -- 使用图片创建
            self.bar = display.newSprite(self._image):anchor(0,1)
            self.sprScale = {x=self.bar:getScaleX(),y = self.bar:getScaleY() }   
                     
        end 
        
        local barSize = self.bar:getContentSize()
        self.centerPos = self.bar:getCenterPos()
        self.barSize = barSize
        self.bar:addTo(self)
    else
        self:setBarSprite( image )
    end
    self:resetBarSpriteAnchor()
end
-- 重新设置bar的锚点
function ProgressBar:resetBarSpriteAnchor()
    if self._style == ProgressBar.STYLE.SCALE then
        local barSize = self.barSize
        if (self.direction == ProgressBar.c_o or self.direction == ProgressBar.o_c) then
            self.bar:anchor(0.5,0.5)
            self.bar:pos(barSize.width/2,barSize.height/2)
        elseif self.direction == ProgressBar.r_l then
            self.bar:anchor(1,0)
            self.bar:pos(barSize.width,-barSize.height)
        elseif self.direction == ProgressBar.d_u then
            self.bar:anchor(0,0)
            self.bar:pos(0,-barSize.height)
        elseif self.direction == ProgressBar.u_d then
            self.bar:anchor(0,1)
            self.bar:pos(0,0)
        elseif self.direction == ProgressBar.ld_ru then
            self.bar:anchor(0,0)
            self.bar:pos(0,-barSize.height)
        elseif self.direction == ProgressBar.lu_rd then
            self.bar:anchor(0,1) 
            self.bar:pos(0,0)
        elseif self.direction == ProgressBar.rd_lu then
            self.bar:anchor(1,0) 
            self.bar:pos(barSize.width,-barSize.height)
        elseif self.direction == ProgressBar.ru_ld then
            self.bar:anchor(1,1) 
            self.bar:pos(barSize.width,0)
        end
        
    end
end

-- 设置进度条初始化百分比 per= 0 ~ 100
function ProgressBar:initPercent(per)
    self:setPercent(per)
end


function ProgressBar:setBarColor( color )
    if self.bar then
        echo("设置了颜色-----")
        self.bar:setColor(color)
    end
end

--[[
重新设置Bar的图层 
]]
function ProgressBar:setBarSprite( image )

    if self.bar then
        self.bar:removeFromParent()
    end
    
    if self.maskCtn then
        self.maskCtn:removeFromParent()
    end

    if image then
        if type(image) =="string"  then
            self.bar = display.newSprite(image):anchor(0,1)
        else
            self.bar = image
        end
    else
        self.bar = display.newSprite(self._image):pos(0,0)
    end

    local barSize = self.bar:getContentSize()

    self.maskSprite = FuncRes.a_black(barSize.width,barSize.height)
    --获取中心点坐标  
    self.centerPos = self.bar:getCenterPos()
    --记录初始遮罩的scaleX ,scaleY
    self.maskScale = {x=self.maskSprite:getScaleX(),y = self.maskSprite:getScaleY() }


    self.maskCtn = FuncCommUI.getMaskCan(self.maskSprite, self.bar):addTo(self)

    self.barSize = barSize

    self.maskCtn:anchor(0,1)
    if image then
        self.maskSprite:setAnchorPoint(self.bar:getAnchorPoint() )
    else
        local anchor =  self.cfgs[self.prop_anchor] 
        if anchor then
            self.bar:anchor(anchor.x,anchor.y)
            self.maskSprite:anchor(anchor.x,anchor.y)
        else
            self.bar:anchor(0,1)
            self.maskSprite:anchor(0,1)
        end
    end

end


-- 设置进度条百分比 per= 0 ~ 100
function ProgressBar:setPercent(per)
    per = per and per or 0 
    per = per > 100 and 100 or per
    
    local width = self.barSize.width
    local height = self.barSize.height


    local xpos = 0
    local ypos = 0

    local xscale = 1
    local yscale = 1

    local scale = 1

    if self._style == ProgressBar.STYLE.POS then
        --如果是从左到右  那么 遮罩运动方向 是从  -width运动到0
        if self.direction == self.l_r then
            xpos = - width + width*per/100 
            --width = math.round(width*per/100)
        elseif self.direction == self.r_l then
            --如果是从右到左  那么 遮罩运动方向 是从  width运动到0
            xpos = width - width*per/100 

        elseif self.direction == self.d_u then
            --如果是从下到上  那么 遮罩运动方向 是从  -height运动到0
            ypos = -height + height * per/100
        elseif self.direction == self.u_d then

            --如果是从上到下  那么 遮罩运动方向 是从  height运动到0
            ypos = height - height * per/100

         elseif self.direction == self.ld_ru then

            --如果是从左下到右上  那么 遮罩运动方向 是从 -width, -height 运动到0
            xpos = - width + width*per/100 
            ypos = -height + height * per/100


        elseif self.direction == self.lu_rd then

            --如果是从左上到右下  那么 遮罩运动方向 是从 -width, height 运动到0
            xpos = - width + width*per/100 
            ypos = height - height * per/100
    
        elseif self.direction == self.rd_lu then

            --如果是从右下到左上  那么 遮罩运动方向 是从 width, -height 运动到0
            xpos =  width - width*per/100 
            ypos = -height + height * per/100

        elseif self.direction == self.ru_ld then

            --如果是从右上到左下  那么 遮罩运动方向 是从 width, height 运动到0
            xpos =  width - width*per/100 
            ypos = height - height * per/100
 
        elseif self.direction == self.c_o then
            --从中心到 out   那么是  从 scale0 到 scale1
            scale = per/100 
            self.maskSprite:setScaleX(self.maskScale.x * scale)
            self.maskSprite:setScaleY(self.maskScale.y * scale)

            xpos = math.round( self.centerPos.x - self.centerPos.x *scale )
            ypos = math.round( self.centerPos.y - self.centerPos.y *scale )

        elseif self.direction == self.o_c then
            --从 out  到 中心  那么是  从 scale1 到 scale0
            scale = 1- per/100
            self.maskSprite:setScaleX(self.maskScale.x * scale)
            self.maskSprite:setScaleY(self.maskScale.y * scale)
            xpos = math.round( self.centerPos.x - self.centerPos.x * scale )
            ypos = math.round( self.centerPos.y - self.centerPos.y * scale )

        else
            echo("wrong direction type",self.direction)
        end

        self.maskSprite:pos(xpos,ypos)
    elseif self._style == ProgressBar.STYLE.SCALE then
        --如果是从左到右 
        if self.direction == self.l_r then
            xscale = per/100 
            --width = math.round(width*per/100)
        elseif self.direction == self.r_l then
            --如果是从右到左  
            xscale = per/100 

        elseif self.direction == self.d_u then
            --如果是从下到上  
            yscale = per/100
        elseif self.direction == self.u_d then
            --如果是从上到下  
            yscale = per/100

         elseif self.direction == self.ld_ru then

            --如果是从左下到右上  
            xscale = per/100 
            yscale = per/100
        elseif self.direction == self.lu_rd then
            --如果是从左上到右下  
            xscale = per/100 
            yscale = per/100
        elseif self.direction == self.rd_lu then
            --如果是从右下到左上  
            xscale =  per/100 
            yscale =  per/100
        elseif self.direction == self.ru_ld then
            --如果是从右上到左下  
            xscale =  per/100 
            yscale =  per/100
        elseif self.direction == self.c_o then
            --从中心到 out   那么是  从 scale0 到 scale1
            scale = per/100 
            xscale = scale
            yscale = scale

        elseif self.direction == self.o_c then
            --从 out  到 中心  那么是  从 scale1 到 scale0
            scale = per/100
            xscale = scale
            yscale = scale
        else
            echo("wrong direction type",self.direction)
        end
        
        if self.is9Sprite then 
            width = width * xscale
            height = height *  yscale
            self.bar:setContentSize(cc.size(width,height))
        else
            self.bar:setScaleX(xscale)
            self.bar:setScaleY(yscale)
        end


    end
    self.curPercent= per
end



--获取当前的percent
function ProgressBar:getPercent(  )
    return self.curPercent
end




--刷新函数
function ProgressBar:updateFrame(  )

    --现在全部走缓动
    -- local toPercent = self.curPercent  + self._perValue
    self._currentFrame = self._currentFrame + 1
    

    if self._currentFrame > self._tweenFrame then
        self:setPercent(self._targetPercent)
        --取消刷新
        self:unscheduleUpdate()
        if self._callBack then
            local func = self._callBack
            self._callBack = nil
            func()
        end
    else
        local toPercent = self._startPercent + self._tweenv * self._currentFrame + 0.5*self._tweena * self._currentFrame* self._currentFrame
        self:setPercent(toPercent)
    end
end



--缓动bar 
-- easeType 是带加速度缓动 1是 匀速缓动
function ProgressBar:tweenToPercent(targetPercent,frame,callBack,easeType )
    frame = frame or 20
    targetPercent = targetPercent < 0 and 0 or targetPercent
    targetPercent = targetPercent > 100 and 100 or targetPercent

    easeType = easeType or 0


    --先取消刷新
    self:unscheduleUpdate()
    --如果差距太小就不缓动了
    if math.abs( targetPercent - self.curPercent ) < 1 then
        self:setPercent(targetPercent)
        if callBack then
            callBack()
        end
        return
    end

    --这里要求有缓动加速度 当百分比越高的时候 速度越大 百分比越小的时候 速度越小
    
    --计算起始速度 固定加速度
     --* math.abs( targetPercent - self.curPercent )/( targetPercent - self.curPercent )

    self._perValue = ( targetPercent - self.curPercent ) /frame

    if easeType == 0 then
        self._tweena = self._perValue/frame *2
        self._tweena = math.abs(self._tweena)
    elseif easeType ==1 then
        self._tweena = 0
    end

    
    --公式原理 vt + 0.5 * a*t = dx
    self._startPercent = self.curPercent
    --缓动起始速度
    self._tweenv = self._perValue-0.5*self._tweena * frame

    self._targetPercent = targetPercent
    self._tweenFrame = frame 
    self._currentFrame =0;
    self._callBack = callBack
    
    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self), 0) 
end


--停止缓动
function ProgressBar:stopTween(  )
    self:unscheduleUpdate()

end


return ProgressBar