--
-- Author: xd
-- Date: 2016-02-26 11:09:14
-- 一些信息tip 基类
local InfoTips1Base = class("InfoTips1Base", UIBase)



function InfoTips1Base:startShow(followView)
    self._isShow =true
--    self:visible(false)
    self:opacity(0)
    self._initPos = {x=0,y=0}
    --记录下 全局坐标
    self._globalPos = followView:convertToWorldSpace(cc.p(0,0))

    self:delayCall(c_func(self.delayShow,self,followView), 0.2)

end

InfoTips1Base.DIRECTION = {
    ["LEFT"] = 1,
    ["RIGHT"] = 2,
}

--延迟后显示
function InfoTips1Base:delayShow(followView)

    if  tolua.isnull( followView ) then
        return
    end

    local globalPos = followView:convertToWorldSpace(cc.p(0,0))
    --如果在这个期间 这个显示对象被移动了 那么 不执行
    if math.abs(globalPos.x-self._globalPos.x) > 5 or  math.abs(globalPos.y-self._globalPos.y) > 5  then
        return
    end

--    self:visible(true)
    self:opacity(255)
    local box = followView:getContainerBox()

    --把这个box转化成全局box
    local turnPos = followView:convertToWorldSpace(cc.p(box.x+box.width/2,box.y + box.height/2))
    --在把这个坐标转化成  scene坐标
    turnPos = self:convertToNodeSpace(turnPos)

    local resultPos = {x=0,y=0}


    local selfBox = self._root:getContainerBox()
    local border = 30

    local jianjiaoPos = 0

    --判断左右
    if turnPos.x > 480  then
        direction = InfoTips1Base.DIRECTION.LEFT;
        resultPos.x =  turnPos.x - box.width/2  - selfBox.width - selfBox.x 
    else
        direction = InfoTips1Base.DIRECTION.RIGHT;
        resultPos.x =  turnPos.x +  ( box.width/2  - selfBox.x   )
    end


    -- 判断上下
    local height = GameVars.height
    if turnPos.y >= (-height+selfBox.height/2) and turnPos.y <= -selfBox.height/2  then
        resultPos.y = turnPos.y -selfBox.y - selfBox.height/2
    elseif  turnPos.y < (-height+selfBox.height/2) then 
        resultPos.y = turnPos.y -selfBox.y - selfBox.height/2 - (turnPos.y - (-height+selfBox.height/2))
    else
        resultPos.y = turnPos.y -selfBox.y - selfBox.height/2 - (turnPos.y - (-selfBox.height/2))
    end
    


    --暂时不缓动
    self._root:pos(resultPos.x, resultPos.y)
end

--开始隐藏 目前简单暴力  直接删除 缓动稍后在做 startHide不让执行多次
function InfoTips1Base:startHide(  )
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


return InfoTips1Base