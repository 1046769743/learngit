--
-- Author:wk
-- Date: 2017-09-11
-- 一些信息气泡 基类
local InfoBubbleBase = class("InfoBubbleBase", UIBase)



function InfoBubbleBase:startShow(followView)
    self._isShow =true
    self._initPos = {x=0,y=0}
    --记录下 全局坐标
    self._globalPos = followView:convertToWorldSpace(cc.p(0,0))
    -- self:delayCall(c_func(self.delayShow,self,followView), 0.2)

    self:delayShow(followView)

end


--延迟后显示
function InfoBubbleBase:delayShow(followView)
    -- local direction = InfoBubbleBase.DIRECTION.DOWN;

    if  tolua.isnull( followView ) then
        return
    end

    local globalPos = followView:convertToWorldSpace(cc.p(0,0))

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
        -- direction = InfoBubbleBase.DIRECTION.UP;
        resultPos.y =  turnPos.y - box.height/2  - selfBox.height - selfBox.y  
        initPos.y = selfBox.height/2 
    else
        -- direction = InfoBubbleBase.DIRECTION.DOWN;
        resultPos.y =  turnPos.y +  ( box.height/2  - selfBox.y   )
        initPos.y =  - selfBox.height/2 
    end

    resultPos.x = turnPos.x -selfBox.x - selfBox.width/2
    
    --然后在判断 自身的坐标
    local minX = -selfBox.x +  border
    --右边界
    local maxX = GameVars.width - selfBox.x - selfBox.width - border


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

    -- echo("\n========initPos========",initPos.x,initPos.y)   --场景界面
    -- echo("\n========resultPos========",resultPos.x,resultPos.y)

    return initPos.x,initPos.y

end



return InfoBubbleBase