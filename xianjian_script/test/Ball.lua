
--边界rect
local borderRect = {
    {x=68,y=436},      --点A
    {x=622,y=450},      --点B 
    {x=800,y=30},      --点C
    {x=100,y=100},      --点D
}

--计算4条线段.因为判断相交 是根据线段判断的
local lineAB = Equation.creat_1_1_b(borderRect[1],borderRect[2],true)
local lineBC = Equation.creat_1_1_b(borderRect[2],borderRect[3],true)
local lineCD = Equation.creat_1_1_b(borderRect[3],borderRect[4],true)
local lineDA = Equation.creat_1_1_b(borderRect[4],borderRect[1],true)

local lineGroup = {lineAB,lineBC,lineCD,lineDA}

local Ball = class("ball")
function Ball:ctor(scene  )
    self.speed = {x=20,y=13}
    --摩擦系数
    self.addSpeed = 1
    --定义初始坐标
    self.pos = {x=192,y= 266}
    --标记是否停止
    self.isStop = false
    self.myView = display.newSprite("test/friend_img_haogan.png"):addto(scene)


    local newPoints = {}
    for k,v in pairs(borderRect) do
        table.insert(newPoints, {v.x,v.y})
    end

    local sp = display.newPolygon(newPoints,{}):addto(scene)

    
    self.myView:scheduleUpdateWithPriorityLua(c_func(self.updateframe,self),0)

end

--每帧刷新函数
function Ball:updateframe(  )
    self:updateSpeed()
    self:chekHitTest()
    self:realPos()
end

function Ball:updateSpeed(  )
    self.speed.x = self.speed.x * self.addSpeed
    self.speed.y = self.speed.y * self.addSpeed
    if math.abs(self.speed.x) < 0.1 then
        self.speed.x = 0
    end
    if math.abs(self.speed.y) < 0.1 then
        self.speed.y = 0
    end
    if self.speed.x == 0 or self.speed.y ==0 then
        self._isStop = true
    end
end

--碰撞检测判断
function Ball:chekHitTest(  )
    if self.isStop then
        return
    end
    local nextPos = {}
    nextPos.x = self.pos.x + self.speed.x
    nextPos.y = self.pos.y + self.speed.y
    --计算球下一帧是否要和边界碰撞了. 取球当前的坐标和下一个点的坐标的线段 与边界判断是否相交
    local ballLine = Equation.creat_1_1_b(nextPos,self.pos,true)

    self.isBlock = false
    --遍历4个边界,判断和哪一条边相交,如果相交 就反弹
    for k,v in pairs(lineGroup) do
        local pointof = Equation.pointOf(v,ballLine)
        --如果有焦点
        if pointof then
            self.isBlock = true
            self:hitOneBorder(v,pointof)
            --这里需要加一个参数 如果被阻挡了  那么 本帧就不能让我的坐标位移了. 因为可能出现拐点 让我移出去了
            
            break
        end

    end

end

--碰到了某条边了 速度需要修正.
function Ball:hitOneBorder( targetLine,pointof )
    --计算垂线
    local plumbLine =  Equation.plumbLine(pointof,targetLine)
    --找到模拟的对称点
    local symmetryPoint = Equation.getSymmetryPoint(self.pos,plumbLine )
    --计算新的速度方向
    local ang = math.atan2(symmetryPoint.y-pointof.y,symmetryPoint.x-pointof.x)
    local spdAbs = math.sqrt(self.speed.x*self.speed.x + self.speed.y *self.speed.y)
    --确定新的速度
    local newSpeed = {x =spdAbs*math.cos(ang),y = spdAbs * math.sin(ang) }
    self.speed = newSpeed
    -- self.pos = pointof
end


--显示坐标
function Ball:realPos(  )
    if self.isStop then
        return
    end
    if self.isBlock then
        return
    end
    self.pos.x = self.pos.x + self.speed.x
    self.pos.y = self.pos.y + self.speed.y
    self.myView:setPosition(self.pos)
end


return Ball