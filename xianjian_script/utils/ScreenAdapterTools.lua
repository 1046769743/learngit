--
-- Author: xd
-- Date: 2017-11-13 17:10:23
-- 屏幕适配工具
--原则上 不允许对一个 view 适配后 手动修改坐标 否则进行动态适配的时候就会出问题
-- 九宫格 和滚动条进行区域动态缩放适配的时候 一定要注意对应缩放的方向适配必须是居中的,否则会出现适配bug


ScreenAdapterTools = {}

--已经适配过的view数组 
--[[

	[type] = {view1,view2,...}

]]
UIAlignTypes= {
    Left = 1,              --左对齐
    LeftTop = 2,           --左上对齐
    MiddleTop = 3,         --居中顶对齐
    RightTop = 4,          --右上对齐

    Right = 5,             --右对齐
    RightBottom = 6,       --右底对齐
    MiddleBottom = 7;      --居中底对齐
    LeftBottom = 8,        --左底对齐
    Middle=9,--保持居中,一般只用在Scale9Sprite的缩放上

    ScaleWidth = 10,			--九宫格或者滚动条的左右缩放适配
}

--合法的适配映射 比如九宫格 不能是 LeftTop,RightTop,RightBottom,LeftBottom 四种适配方案
local safeScaleAlign = {
	[UIAlignTypes.LeftTop] =  UIAlignTypes.MiddleTop,
	[UIAlignTypes.RightTop] =  UIAlignTypes.MiddleTop,
	[UIAlignTypes.RightBottom] =  UIAlignTypes.MiddleBottom,
	[UIAlignTypes.LeftBottom] =  UIAlignTypes.MiddleBottom,
} 


local hasAdapterMap = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
	[9] = {},
	[10] = {},		

}

--需要缩放适配的数组
local scaleAdapterMap = {}

local currentWay = 1

--靠左适配的方位数组
local leftGroups = {UIAlignTypes.Left,UIAlignTypes.LeftTop,UIAlignTypes.LeftBottom}
--靠右适配的方位数组
local rightGroups = {UIAlignTypes.RightTop,UIAlignTypes.Right,UIAlignTypes.RightBottom}
--滚动条或者九宫格带缩放的适配数组
local scaleGroups = {UIAlignTypes.ScaleWidth}
local toolBarWidth = 40


function ScreenAdapterTools.getCurrentWay(  )
	return currentWay
end


function ScreenAdapterTools.initDatas(  )
	currentWay = GameVars.toolBarWay 
	if GameVars.toolBarWay == 0 then
		toolBarWidth = 0
	else
		toolBarWidth = GameVars.toolBarWidth 
	end
	
end

function ScreenAdapterTools.turnScaleAlign(align)
	local targetAlign = safeScaleAlign[align]
	if targetAlign then
		echoError("九宫格或者滚动条错误的适配:",align)
	end
end


--判断是否已经适配过就不执行了
function ScreenAdapterTools.checkHasAdapter( view,alignType )
	if not view then
		return false
	end
    
	local arr = hasAdapterMap[(alignType)]
    if not arr then
        echoError("错误的对其方式:%s",tostring(alignType) )
        return true
    end
	if table.indexof(arr, view) then
		return true
	end
	table.insert(arr, view)
	if view._scaleAlignNums  then
		table.insert(hasAdapterMap[UIAlignTypes.ScaleWidth], view)
	end
	ScreenAdapterTools.adustViewWay(view,alignType)
	return 
end

--清除一个对象做过的适配
function ScreenAdapterTools.clearAdapterView( view )
    --遍历所有的显示对象
    for i,v in ipairs(hasAdapterMap) do
        local length = #v
        for ii=length,1,-1 do
            local targetView = v[ii]
            if tolua.isnull(targetView) then 
                table.remove(v,ii)
            else
                if v[ii] == view then
                    table.remove(v,ii)
                    return
                end
            end
        end
    end
end

--判断某个对象的父容器是否适配过 暂时用不到
function ScreenAdapterTools.checkParentHasAdapter(baseView, view,depth )
	if tolua.isnull(view) then 
		return false
	end
	local parent = view:getParent()
	depth = depth  or 1
	if not parent then
		return false
	end
	if depth > 2 then
		return false
	else
		--遍历所有的显示对象
		for i,v in ipairs(hasAdapterMap) do
			local length = #v
			for ii=length,1,-1 do
				local targetView = v[ii]
				if tolua.isnull(targetView) then 
					table.remove(v,ii)
				else
					if v[ii] == view then
						echoError("这个对象的parent和自身适配重复了,请检查,window:%s,view:%s" , view.__parentWindowName,view.name )
						return true
					end
				end
			end
		end
		return ScreenAdapterTools.checkParentHasAdapter( parent,depth+1 )

	end
end

-- 获取某UI的适配方式（假定UI适配是与父类一致的）
-- ***注意*** 新手引导工具接口使用，效率低，不要用作功能接口
function ScreenAdapterTools.getUIAdaptMethod(tview)
    -- 返回视图的适配方式
    local function _getUIAdaptMethod(tview)
        if not tview or tolua.isnull(tview) then return nil end

        for adapt,views in ipairs(hasAdapterMap) do
            for _,view in ipairs(views) do
                if view == tview then
                    -- echo("有相等的吗")
                    return adapt
                end
            end
        end
        -- 检查父类
        return _getUIAdaptMethod(tview:getParent())
    end
    -- 水平方向
    local horizon = {
        [UIAlignTypes.Left] = 2,
        [UIAlignTypes.LeftTop] = 2,
        [UIAlignTypes.LeftBottom] = 2,
        [UIAlignTypes.Right] = 1,
        [UIAlignTypes.RightTop] = 1,
        [UIAlignTypes.RightBottom] = 1,
    }
    -- 竖直方向
    local vert = {
        [UIAlignTypes.LeftTop] = 2,
        [UIAlignTypes.MiddleTop] = 2,
        [UIAlignTypes.RightTop] = 2,
        [UIAlignTypes.RightBottom] = 1,
        [UIAlignTypes.MiddleBottom] = 1,
        [UIAlignTypes.LeftBottom] = 1,
    }

    local adapt = _getUIAdaptMethod(tview) or UIAlignTypes.Middle

    return {horizon[adapt] or 0, vert[adapt] or 0}
end

--判断正常是左边适配的还是右边适配的 -1 是左 0 是居中  1是右
function ScreenAdapterTools.checkAdapeterWay( alignType )
	if table.indexof(leftGroups,alignType) then
		return -1
	elseif table.indexof(rightGroups,alignType) then
		return 1
	end
	return 0
end

--当屏幕发生旋转  way 1是右边 -1是左边
function ScreenAdapterTools.onScreenChange( way )
    
	--如果way相同 那么不用转换
	if currentWay == way then
		return
	end
	currentWay = way
	if true then
        return
    end
	--左边适配的人需要 靠右移动 右边适配的人左移
	local offsetFunc = function ( groupArr,way )
		for i,v in ipairs(groupArr) do
			local alignArr = hasAdapterMap[v]
			local length =#alignArr
			for ii=length,1,-1 do
				local view = alignArr[ii]

				if tolua.isnull(view) then
					table.remove(alignArr,ii)
				else
					view:offsetPos(way*toolBarWidth, 0)
				end
			end
		end
	end

	if way == 1 then
		offsetFunc(rightGroups,-1)
		offsetFunc(leftGroups,-1)
		offsetFunc(scaleGroups,-1)
	else
		offsetFunc(rightGroups,1)
		offsetFunc(leftGroups,1)
		offsetFunc(scaleGroups,1)
	end


end

--修正ui的视图
function ScreenAdapterTools.adustViewWay( view,alignType )
	--判断是否
	local way = ScreenAdapterTools.checkAdapeterWay(alignType)
	if way == 0 then
		if view._scaleAlignNums and view._scaleAlignNums > 0 then
			way =  0
		else
			return
		end
        return
	end
	
	local x,y = view:getPosition()
	
    view:pos(x - toolBarWidth * way,y)

end


function ScreenAdapterTools.setScale9Scale(view,withScaleX,withScaleY)
    local spSize = view:getContentSize()
    local offsetX = 0
    local offsetY = 0
    withScaleX = withScaleX or 1
    withScaleY = withScaleY or 1

    if withScaleX then
        spSize.width = spSize.width *  withScaleX
    end

    if withScaleY then
        spSize.height = spSize.height * withScaleY
    end

    view:setContentSize(spSize)
end

--scale9缩放规则,alignType 对齐方式,withScaleX x方向缩放拉长系数,会在左右2边均匀加长
--withScaleX x方向缩放拉长系数,会在上下均匀加长 
--withScaleX 是一个比例值 
--如果传空或者0表示不缩放 传其他表示按照 withScaleX*( GameVars.width  - GameVars.gameResWidth )宽度缩放
--withScaleY也是同理  
--moveScale 表示移动的系数 默认是1 ,也就是说 1136机器 靠左对其 只移动 (1136-960)/2 * moveScale这个多像素
--[[
    示例 机型是 1136*768
    ScreenAdapterTools.setScale9Align(widthScreenOffset, scale9Sprite,UIAlignTypes.MiddleTop,1,0 )
    表示让 scale9Sprite 居中朝上对其,x方向 会让这个scale9左右各自加长 (1136-960) *withscaleX /2的宽度 
    scroll的适配同样如此
]]
function ScreenAdapterTools.setScale9Align( widthScreenOffset,view,alignType,withScaleX,withScaleY ,moveScale)
	
    local spSize = view:getContentSize()
    local offsetX =0
    local offsetY =0
    widthScreenOffset = widthScreenOffset or 0

    local adapterOffset = toolBarWidth

    if withScaleX and withScaleX > 0 then
    	offsetX =  - (GameVars.width - GameVars.gameResWidth  )*withScaleX /2 

        if ScreenAdapterTools.checkViewNotch(view,spSize.width,withScaleX) then
            adapterOffset = 0
        end

        spSize.width = spSize.width +  (GameVars.width  - GameVars.gameResWidth   )*withScaleX - adapterOffset *2
  
        view:offsetPos(adapterOffset  , 0)
        view._scaleAlignNums = 1



    end

    if withScaleY then
        spSize.height = spSize.height +( GameVars.height  - GameVars.gameResHeight  ) * withScaleY
        offsetY = ( GameVars.height  - GameVars.gameResHeight  ) * withScaleY/2
    end
    moveScale = moveScale or 1
    view:setContentSize(spSize)
    view:offsetPos(offsetX * moveScale  , offsetY *moveScale)
    ScreenAdapterTools.setViewAlign(widthScreenOffset,view,alignType)

end

--参数格式 和 setScale9Align 一样
--fillNotouch 是否填充刘海区域,默认不填充
function ScreenAdapterTools.setScrollAlign(widthScreenOffset, view,alignType,withScaleX,withScaleY ,moveScale,fillNotouch)
    
    local offsetX =0
    local offsetY =0

    local rect = view:getViewRect()
    moveScale = moveScale or 1
    local adapterOffset = 0
    if withScaleX and withScaleX > 0  then
    	offsetX =  - (GameVars.width - GameVars.gameResWidth  )*withScaleX /2 
    	
        adapterOffset = toolBarWidth 

        --滚动条设计到新手引导适配的问题 暂时不做全屏滚动适配
        if  fillNotouch and ScreenAdapterTools.checkViewNotch( view ,rect.width,withScaleX) then
            adapterOffset =0
        end

        rect.width = rect.width +  (GameVars.width  - GameVars.gameResWidth   )*withScaleX - adapterOffset *2
        view:offsetPos(adapterOffset  , 0)
        view._scaleAlignNums = 1
        
    end

    if withScaleY then
        offsetY = ( GameVars.height  - GameVars.gameResHeight  ) * withScaleY/2
        rect.height = rect.height + ( GameVars.height  - GameVars.gameResHeight  ) * withScaleY
    end
    rect.y = -rect.height 
    view:updateViewRect(rect)
    view:offsetPos(offsetX*moveScale , offsetY*moveScale)
    
    ScreenAdapterTools.setViewAlign(widthScreenOffset,view,alignType)
end





--设置view对其
--moveScale 表示移动的系数 默认是1 ,也就是说 1136机器 靠左对其 只移动 (1136-960)/2 * moveScale这个多像素
-- widthScreenOffset  每个系统调用这个方法时 必须传递 对应ui的 widthScreenOffset 参数
--  withNotch 0表示不偏移刘海区域, 默认为0,  1表示向右深入刘海区域, -1表示向左深入刘海区 ,这个针对新手引导适配场景的点击区域, 特殊组件也可以使用

function ScreenAdapterTools.setViewAlign(widthScreenOffset,view,alignType,moveScaleX , moveScaleY,withNotch)
	if ScreenAdapterTools.checkHasAdapter(view,alignType) then
		return
	end
    -- print("\n\n setViewAlign=============================== \n\n");
    if view == nil then
        echoError("ScreenAdapterTools.setViewAlign view is nil")
        return ;
    end
    withNotch = tonumber(withNotch) or 0
    withNotch = withNotch or 0
    moveScaleX = moveScaleX or 1
    moveScaleY = moveScaleY or 1
    local offsetX = 0
    local offsetY = 0
    if alignType == UIAlignTypes.Left then
        offsetX = - GameVars.UIOffsetX - widthScreenOffset/2
    elseif alignType == UIAlignTypes.LeftTop then
        offsetX = - GameVars.UIOffsetX - widthScreenOffset/2
        offsetY =   GameVars.UIOffsetY

    elseif alignType == UIAlignTypes.MiddleTop then
        offsetY =   GameVars.UIOffsetY

    elseif alignType == UIAlignTypes.RightTop then
        offsetX =   GameVars.UIOffsetX + widthScreenOffset/2
        offsetY =   GameVars.UIOffsetY
    elseif alignType == UIAlignTypes.Right then
        offsetX =   GameVars.UIOffsetX + widthScreenOffset/2
    elseif alignType == UIAlignTypes.RightBottom then
        offsetX =   GameVars.UIOffsetX + widthScreenOffset/2
        offsetY = - GameVars.UIOffsetY
    elseif alignType == UIAlignTypes.MiddleBottom then
        offsetY = - GameVars.UIOffsetY

    elseif alignType == UIAlignTypes.LeftBottom then
        offsetX = - GameVars.UIOffsetX - widthScreenOffset/2
        offsetY = - GameVars.UIOffsetY
    end
    view:offsetPos(offsetX*moveScaleX +withNotch*GameVars.toolBarWay  , offsetY*moveScaleY)
    -- print("后(x,y)",view:getPositionX(),view:getPositionY());
end

--适配一个背景sprite scaleType 0或者空 表示等比缩放适配 1表示只缩放x 2表示只缩放y 3表示不缩放
--注意 bg 一定要放在ui里面才有效
function ScreenAdapterTools.setBgScaleAlign( bgSprite,scaleType )
    scaleType = scaleType or 0
    local xpos = -GameVars.UIOffsetX-GameVars.toolBarWidth
    local ypos = GameVars.UIbgOffsetY
    local contentSize = bgSprite:getContentSize()


    local scaleX = GameVars.fullWidth /contentSize.width  --GameVars.bgSpriteScale
    if scaleX < 1 then
        scaleX = 1
    end
    local scaleY = scaleX

    --等比缩放
    if scaleType == 0 then
        -- uiView.__bgView:setScale(GameVars.bgSpriteScale)
    --只缩放x
    elseif scaleType == 1 then
        scaleY =1
    --只缩放y
    elseif scaleType == 2 then
        scaleX =1
    --都不缩放
    elseif scaleType == 3 then
        scaleX =1
        scaleY =1
    end
    local middleX = contentSize.width * scaleX/2
    xpos = -middleX + GameVars.gameResWidth /2
    bgSprite:anchor(0,1)
    bgSprite:setScaleX(scaleX)
    bgSprite:setScaleY(scaleY)
    bgSprite:pos(xpos,ypos)
end

local ENUM_LAYOUT_POLICY = {
    ["CENTER"] = 0,
    ["LEFT"] = 2,
    ["RIGHT"] = 1,
    ["UP"] = 2,
    ["DOWN"] = 1,
};
function ScreenAdapterTools.turnGuidePos( pos, horizontalLayout, verticalLayout, scaleX, scaleY,withNotch )
    local widthDistance = 0 ;
    local difX = GameVars.width - GameVars.gameResWidth;
    local difY = GameVars.height - GameVars.gameResHeight ;
    withNotch = tonumber(withNotch) or 0
    withNotch = withNotch or 0
    withNotch = withNotch*GameVars.toolBarWidth 

    if horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.CENTER then
        if scaleX ~= 1 then 
           return {x = pos.x + (scaleX / 2) * difX / 2 +GameVars.toolBarWidth+withNotch, y = pos.y + difY / 2};
        else 
           return {x = pos.x+GameVars.toolBarWidth+withNotch, y = pos.y + difY / 2};
        end
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.UP then
        --左上 done

        if scaleX ~= 1 then 
           return {x = pos.x + (scaleX / 2) * difX / 2+GameVars.toolBarWidth+withNotch, y = pos.y + difY};
        else 
            return {x = pos.x +GameVars.toolBarWidth+withNotch, y = pos.y + difY};
        end


    elseif horizontalLayout == ENUM_LAYOUT_POLICY.LEFT and verticalLayout == ENUM_LAYOUT_POLICY.DOWN then 
        --左下 done
        return { x = pos.x + GameVars.toolBarWidth+withNotch, y = pos.y};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.CENTER and verticalLayout == ENUM_LAYOUT_POLICY.UP then
        --上对齐 done
        return { x = pos.x + difX / 2 + widthDistance / 2+withNotch, y = pos.y + difY};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.CENTER and verticalLayout == ENUM_LAYOUT_POLICY.DOWN then
        --下对齐 done
        return {x = pos.x + difX / 2 + widthDistance / 2+withNotch, y = pos.y};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.RIGHT and verticalLayout == ENUM_LAYOUT_POLICY.CENTER then
        --右对齐 done
        return {x = pos.x + difX + widthDistance -GameVars.toolBarWidth+withNotch , y = pos.y + difY / 2};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.RIGHT and verticalLayout == ENUM_LAYOUT_POLICY.UP then
        --右上对齐 done
        return {x = pos.x + difX + widthDistance -GameVars.toolBarWidth+withNotch, y = pos.y + difY};
    elseif horizontalLayout == ENUM_LAYOUT_POLICY.RIGHT and verticalLayout == ENUM_LAYOUT_POLICY.DOWN then
        --右下 done
        -- echo(horizontalLayout, horizontalLayout);
        return {x = pos.x + difX + widthDistance -GameVars.toolBarWidth+withNotch, y = pos.y};
    else 
        --CENTER CENTER
        return {x = pos.x + difX / 2 + widthDistance / 2+withNotch, y = pos.y + difY / 2};
    end 
end



--判断滚动条或者九宫格 是否刘海适配
function ScreenAdapterTools.checkViewNotch( view ,targetWid,withScaleX)
    --必须是原始宽度大于1036才执行
    if targetWid < GameVars.gameResWidth  - 100 then
        return
    end
    --必须是左右适配的
    if (not  withScaleX) or withScaleX == 0 then
        return 
    end

    return true
end

return ScreenAdapterTools