-- UI通用方法，补充FuncCommUI

FuncUITool = FuncUITool or {}

--[[
    做移动特效
    delay 延迟时间
    movePos 需要移动的距离
    moveTime 移动时间
    bouncePos 回弹距离
    bounceTime 回弹时间
]]
function FuncUITool.doMoveAndBounce(view, delay, movePos, moveTime, bouncePos, bounceTime)
    -- 原位置
    local oX,oY = view:getPosition()
    view:setPosition(oX + movePos.x, oY + movePos.y)

    local delay = delay or 0
    local bouncePos = bouncePos or cc.p(0,0)
    local bounceTime = bounceTime or 0

    -- 出现
    local show = cc.EaseOut:create(cc.MoveBy:create(moveTime,cc.p(-(movePos.x + bouncePos.x),-(movePos.y + bouncePos.y))),3)
    -- 回弹
    local back = cc.EaseOut:create(cc.MoveBy:create(bounceTime,cc.p(bouncePos.x, bouncePos.y)),1)

    view:runAction(cc.Sequence:create({
        cc.DelayTime:create(delay),
        show,
        back,
    }))
end

--[[
    做弹出效果
]]
function FuncUITool.doScaleAndBounce(view, delay, scale, showTime, bounceTime)
    -- 原大小
    local oSX,oYX = view:getScaleX(),view:getScaleY()
    view:scaleByPos(0,0,0,true)

    local delay = delay or 0
    local showTime = showTime or 0
    local bounceTime = bounceTime or 0

    view:runAction(cc.Sequence:create({
        cc.DelayTime:create(delay),
        view:getScaleAnimByPos(showTime, scale, scale, false),
        view:getScaleAnimByPos(bounceTime, oSX, oYX, false)
    }))
end

--[[
    做渐入效果
]]
function FuncUITool.doFadeIn(view, delay, time)
    local delay = delay or 0
    local time = time or 0
    view:setOpacity(0)

    view:runAction(cc.Sequence:create({
        cc.DelayTime:create(delay),
        cc.FadeIn:create(time),
    }))
end