--
-- Author: xd
-- Date: 2016-02-26 11:09:14
-- 一些信息tip 基类
local InfoTipsBase = class("InfoTipsBase", UIBase)



function InfoTipsBase:startShow(followView)
    self._isShow =true
    -- self:visible(false)
    self:opacity(0)
    self._initPos = {x=0,y=0}
    --记录下 全局坐标
    self._globalPos = followView:convertToWorldSpace(cc.p(0,0))

    self:delayCall(c_func(self.delayShow,self,followView), 0.2)

end

InfoTipsBase.DIRECTION = {
    ["DOWN"] = 1,
    ["UP"] = 2,
}

--延迟后显示
function InfoTipsBase:delayShow(followView)
    local direction = InfoTipsBase.DIRECTION.DOWN;

    if  tolua.isnull( followView ) then
        return
    end

    local globalPos = followView:convertToWorldSpace(cc.p(0,0))
    --如果在这个期间 这个显示对象被移动了 那么 不执行
    if math.abs(globalPos.x-self._globalPos.x) > 5 or  math.abs(globalPos.y-self._globalPos.y) > 5  then
        return
    end

    -- self:visible(true)
    self:opacity(255)
    local box = followView:getContainerBox()

    --把这个box转化成全局box
    local turnPos = followView:convertToWorldSpace(cc.p(box.x+box.width/2,box.y + box.height/2))
    
    --在把这个坐标转化成  scene坐标
    turnPos = self:convertToNodeSpace(turnPos)

    local resultPos = {x=0,y=0}


    local selfBox = self._root:getContainerBox()
    local initPos = {x= 0,y = 0}
    local border = 30

    local jianjiaoPos = 0

    --判断方位 默认在正上方 如果 正上方的位置小于 300了 就向下方显示
    if turnPos.y > -300  then
        direction = InfoTipsBase.DIRECTION.UP;
        resultPos.y =  turnPos.y - box.height/2  - selfBox.height - selfBox.y  
        initPos.y = selfBox.height/2 
    else
        direction = InfoTipsBase.DIRECTION.DOWN;
        resultPos.y =  turnPos.y +  ( box.height/2  - selfBox.y   )
        initPos.y =  - selfBox.height/2 
    end

    resultPos.x = turnPos.x -selfBox.x - selfBox.width/2
    
    --然后在判断 自身的坐标
    local minX = -selfBox.x +  border
    --右边界
    local maxX = GameVars.width - selfBox.x - selfBox.width - border

    -- local minY = -selfBox.y + border
    -- local maxY = GameVars.height  - selfBox.y - selfBox.height + border

    if resultPos.x < minX then
        resultPos.x = minX
    elseif resultPos.x > maxX then
        resultPos.x = maxX
    end

    local initScale = 0.1

    --这个需要记录 从哪个点出来的scale
    initPos.x = turnPos.x  - resultPos.x 
    
    initPos.x = initPos.x- initPos.x*initScale + resultPos.x
    initPos.y = initPos.y - initPos.y*initScale + resultPos.y

    -- initPos.y = initPos.y +dy 
    self._root:pos(initPos.x,initPos.y)

    self._root:scale(initScale)

    self._initPos = initPos

    local  moveTime = 0.1

    self._root:scale(1);

    local x = (GameVars.width - GameVars.gameResWidth)/2
    local y = (GameVars.height - GameVars.gameResHeight)/2


    --暂时不缓动
    self._root:pos(resultPos.x - x, resultPos.y)
    -- self._root:runAction( 

    --     act.spawn(
    --         act.bouncein( act.scaleto(moveTime,1) ), 
    --         act.bouncein( act.moveto(moveTime,resultPos.x,resultPos.y) )
    --     )
    -- )
    if self.panel_left then
        self.panel_left:setVisible(false);
    end
    if self.panel_right then
        self.panel_right:setVisible(false);
    end
    if self.panel_up then
        self.panel_up:setVisible(false);
    end
    if self.panel_down then
        self.panel_down:setVisible(false);
    end
    

    --位置计算
    local diffX = turnPos.x - resultPos.x +  x  + 15;
    local maxoff = 130
    local minoff = -160

    if direction == InfoTipsBase.DIRECTION.UP then 
        if self.panel_up then
            self.panel_up:setVisible(true);
            if self.windowName ~= "PartnerStarTips" then
                if diffX >= maxoff then
                    diffX = maxoff
                elseif diffX <= minoff then
                    diffX = minoff
                end
                self.panel_up:setPositionX(diffX);
            end
        end
    else
        if self.panel_down then
            self.panel_down:setVisible(true);
            if self.windowName ~= "PartnerStarTips" then
                if diffX <= minoff  then
                    diffX = minoff
                elseif diffX >= maxoff then
                    diffX = maxoff
                end
                self.panel_down:setPositionX(diffX);
            end
        end
        
    end 
end

--开始隐藏 目前简单暴力  直接删除 缓动稍后在做 startHide不让执行多次
function InfoTipsBase:startHide(  )
    if not self._isShow  then
        return
    end
    if self.died then
        echo("__已经hide过了 还咋ihide")
        return
    end
    self._isShow = false
    --self:deleteMe()
    self._root:stopAllActions()
    local tempFunc = function (  )
        self:deleteMe()
    end
    local  moveTime = 0.1
    --目前暂定用这种方式
    self._root:runAction( 
        act.sequence(

            act.spawn(
                -- act.scaleto(moveTime,1),
                -- act.moveto(moveTime,resultPos.x,resultPos.y)
                act.bouncein( act.scaleto(moveTime,0.0) ), 
                act.bouncein( act.moveto(moveTime,self._initPos.x,self._initPos.y) )
            ),
            act.callfunc(tempFunc ) 
        )
    )

end


return InfoTipsBase