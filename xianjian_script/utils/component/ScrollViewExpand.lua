-- User: cwb
-- Date: 2015/5/11
-- ScrollView 组件


local ScrollViewExpand = class("ScrollViewExpand", cc.ui.UIScrollView)

--ITEM 的出现方式 0 表示没有
ScrollViewExpand.ITEMAPPEARTYPEMAP = {
    NONE = 0,
    --反弹式的运动过去
    BOUCEMOVE = 1,

}


ScrollViewExpand.EVENT_BEGAN = "began"                  --滑动开始
ScrollViewExpand.EVENT_MOVED = "moved"                  --滑动中
ScrollViewExpand.EVENT_ENDED = "ended"                  --滑动结束 不会和 点击同时触发
ScrollViewExpand.EVENT_CLICKED = "clicked"              --滑动点击
ScrollViewExpand.EVENT_SCROLLEND = "scrollEnd"          --缓动结束 -- 彻底静止
ScrollViewExpand.EVENT_SCROLLHEAD = "scrollHead"        --滑到头部
ScrollViewExpand.EVENT_SCROLLDOWN = "scrollTail"        --滑到尾部

ScrollViewExpand.SECTOR_CENTER_BOTTOM = 0        -- 圆心在下侧
ScrollViewExpand.SECTOR_CENTER_TOP = 1        -- 圆心在上侧
ScrollViewExpand.SECTOR_CENTER_LEFT = 0        -- 圆心在左侧
ScrollViewExpand.SECTOR_CENTER_RIGHT = 1        -- 圆心在右侧
--------------------------------
-- ScrollViewExpand
-- @function [parent=#ScrollViewExpand] new
-- @param table params 参数表

--[[

    ScrollViewExpand构建函数

    可用参数有：

    direction 列表控件的滚动方向，默认为垂直方向
    alignment listViewItem中content的对齐方式，默认为垂直居中
    viewRect 列表控件的显示区域
    scrollbarImgH 水平方向的滚动条
    scrollbarImgV 垂直方向的滚动条
    bgColor 背景色,nil表示无背景色
    bgStartColor 渐变背景开始色,nil表示无背景色
    bgEndColor 渐变背景结束色,nil表示无背景色
    bg 背景图
    bgScale9 背景图是否可缩放
    capInsets 缩放区域

]]
-- end --


ScrollViewExpand._allItemData = nil
--视图缓存 结构 { {data,view},{..},...    }
ScrollViewExpand._viewCache = nil

--当前的view视图数组  结构 { {data,view},{..},...    }
ScrollViewExpand._viewArr= nil


--所有的 cellview数组 
ScrollViewExpand._allCellViewArr = nil

--当前的bg数组  结构 { {groupIndex,posIndex, view},{..},...    }
ScrollViewExpand._bgViewArr = nil
ScrollViewExpand._bgViewCacheArr = nil

--存储的是groupView 格式 {group1:{view1,view2,view3} }
ScrollViewExpand._groupViewArr = nil 

--视图组容器的缓存
ScrollViewExpand._groupCtnCache = nil
ScrollViewExpand._itemAppearType = 0 --item 出现方式
ScrollViewExpand._appearComplete = true --是否出现完成 在未出现完成的时候 是不能进行点击的

--[[
    设置所有srcoll是否可以拖动
    新手引导时候不能让玩家拖动scroll
]]
ScrollViewExpand._isEnableScroll = true;

--是否已经打开 这个scroll  ,需要根据这个判断是否添加item 初始表现
ScrollViewExpand._hasOpened = false

-- 扇形滚动参数
ScrollViewExpand.__sectorP = nil

function ScrollViewExpand.setEnableScroll(isEnable)
    ScrollViewExpand._isEnableScroll = isEnable
    ScrollViewExpand.super._isEnableScroll = isEnable
end


function ScrollViewExpand:ctor(params)
    self._itemAppearType = self.ITEMAPPEARTYPEMAP.NONE
    self._fillEaseTime = 0
    self._canScroll = true
    self._canAutoScroll = true
    self._appearComplete =true
    params.bgScale9 = true
    ScrollViewExpand.super.ctor(self, params)

    self.currentIndex_ = 0
    self.currentItem_ = nil
    self._viewCache = {}
    self._viewArr = {}
    self._allCellViewArr = {}
    --存放背景的数组
    self._bgViewArr = {}
    self._bgViewCacheArr ={}
    self._lastPageIndex = 1
    self.innerContainer =  display.newNode()
    self:addScrollNode(self.innerContainer)
    self._itemAppearCount = 1
    self._groupViewArr = {}
    self.hasInit = false;

    self._groupDataExpand = {}
    --初始化 判定创建完成为true
    self._createComplete = true
    self:setCascadeOpacityEnabled(true)

    self._isCellView =false
    self._pageStyle = 0
    self._onPageFrame  = 0

    -- 设置默认是否显示滚动滑块
    self._showBDrag = false

    self.__sectorP = nil
end

--内部调用

function ScrollViewExpand:onTouch_(event)
    --
    if not self:checkCanClickOnGuide() then
        if  LoginControler:isStartPlay() == true and
             TutorialManager.getInstance():isAllFinish() == false and 
              TutorialManager.getInstance():isTutoring() == true and
               TutorialManager.getInstance():isInBtnClickArea(event.x, event.y) == true then
        elseif not self._canScroll or ScrollViewExpand._isEnableScroll == false then
            return false
        end
    end
   
    return ScrollViewExpand.super.onTouch_(self,event)
end

-- 添加滑动容器
function ScrollViewExpand:addScrollContainer(container)
    if self.innerContainer then
        self.innerContainer:removeSelf()
        self.innerContainer = nil
    end
    self.innerContainer = container
    self:addScrollNode(self.innerContainer)
end

-- 获得scrollView的大小
function ScrollViewExpand:getScrollViewSize()
    return self.viewRect_
end




function ScrollViewExpand:callListener_(event)


    if event.name == self.EVENT_MOVED then
        self.touchState = event.name
    elseif event.name == self.EVENT_BEGAN  then
        self.touchState = event.name
    elseif event.name == self.EVENT_CLICKED then
        self.touchState = self.EVENT_CLICKED
        if self._pageType then
            self:onPageClick(event.x,event.y)
        end
    elseif event.name == self.EVENT_SCROLLEND then
        --延迟一帧让设置成让自己非运动
        self:delayCall(c_func(self.setTouchState, self,self.EVENT_SCROLLEND), 0.04)
    end
    ScrollViewExpand.super.callListener_(self,event)
    
end


function ScrollViewExpand:setTouchState( state )
    self.touchState = state
    if state == self.EVENT_SCROLLEND then
        self:refreshCellView(0)
        -- 将位置刷新为扇形滚动
        self:updateSector(0)
    end
end



-- 点击事件caollback
function ScrollViewExpand:onTouchCallback(event)
    self.touchState = event.name
end





--创建完毕
function ScrollViewExpand:onCreateComplete()

    self._hasOpened = true
    --如果是清除缓存的
    if self._isCellView then
        --那么刷新cellview
        self:refreshCellView(0)
    end

    --如果有加载完成的回调
    if self.onCreateCompFunc  then
        self.onCreateCompFunc()
    end

    if self._showBDrag then
        self:enableScrollBar()
        self.bDrag_ = true
    end

    -- 将位置刷新为扇形滚动
    self:updateSector(0)
end

--按照pageType 方式运动
function ScrollViewExpand:scrollByPageType(  )
    if not self._pageType then
        return
    end



    local oldGroup,oldIndex = self:getGroupPos(self._pageType ,true  )
    -- echo("111111111aaa",oldIndex,self.speed.x,self.speed.y)
    if self:isSideShow() then
        self:_pageEaseMoveTo(oldIndex,oldGroup,0.3)
        -- echo("22222222222aaa",oldGroup,oldIndex)
        return 
    end

    local  group,index
    --当前的x,和当前的y
    local curx,cury = self.position_.x,self.position_.y
    local dis 
    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        dis = self.speed.x * 10
        group,index = self:getGroupPos(self._pageType ,true,curx + dis,cury  )

    else
        dis = self.speed.y * 10
        group,index = self:getGroupPos(self._pageType ,true,curx,cury +dis  )
    end


    -- echo("33333333333aaa",index)
    local groupData = self._allItemData[group]

    local itemRect = groupData.itemRect

    local nums = math.abs(index - self._lastPageIndex) -1

    local perTime = 0.2

    local time = math.pow(1.3,nums) * perTime
    time = time > 1 and 1  or time
    time = time < perTime and perTime or time

      --如果发现已经换页了 那么直接滚动过去
    if group ~=oldGroup or index ~= oldIndex  then
        self:_pageEaseMoveTo(index,group,time)
        return
    end

    
    if math.abs(dis) > itemRect.width and self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        self:_pageEaseMoveTo(index,group,time)
        return 
    elseif math.abs(dis) > itemRect.height then
        self:_pageEaseMoveTo(index,group,time)
         -- echo("444444444444aaa",index ,posy,cury)
        return 
    end
    

    local posx,posy = self:getTargetPosByWay(index,group,self._pageType)
     -- echo("5555555555aaa",index,posy-cury)
    --这里判断下 修正的位置 

    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        scrollDis = self._pageScrollDis or itemRect.width/2
         -- echo(posx,curx,self._pageScrollDis,"__scrolldis",index,  posx - curx ,self._lastPageIndex)
        if math.abs( posx - curx ) > scrollDis and self._lastPageIndex  == index then
            if posx > curx then
                index = index +1
            else
                index = index -1
            end 

            if index > #groupData.data then
                index = #groupData.data
            end
            if index < 1 then
                index = 1
            end

            posx,posy = self:getTargetPosByWay(index,group,self._pageType)
        end


    elseif self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
       scrollDis = self._pageScrollDis or itemRect.height/2
        if math.abs( posy - cury ) > scrollDis then
            if posy > cury then
                index = index -1
            else
                index = index +1
            end
             
            if index > #groupData.data then
                index = #groupData.data
            end
            if index < 1 then
                index = 1
            end
            -- echo("66666666aaa",index)
            posx,posy = self:getTargetPosByWay(index,group,self._pageType)

        end
    end
    self._lastPageIndex = index
    --然后 进行坐标修正
    self:easeMoveto(posx, posy, 0.3) 
    if self._onPageEnd then
        self._onPageEnd(index,group)
    end

end

--click onpage
function ScrollViewExpand:onPageClick( localx,localy )
    --判断点击的是否是当前的item
    --把他进行下坐标转换
    -- echo(self._onPageFrame,"__self.pageframe")
    -- echo("------------------------滑动点击 ----aann aaa=====")
    -- echo("self._disabledPageClick===", self._disabledPageClick)
    if self._disabledPageClick then
        return
    end

    if self._onPageFrame > 0 then
        -- self:scrollByPageType( )
        return
    end
    local posx,posy = self:getCurrentPos()
    -- posx = posx > 0 and 0 or posx
    -- posy = posy < 0 and 0 or posy
    posx = posx - localx
    posy = posy - localy
    local group,index = self:getGroupPos(0, true, posx, posy)
    --如果不是同一个pageindex
    if index ~= self._lastPageIndex then
        -- if index - self._lastPageIndex > 1 then
        --     index = self._lastPageIndex + 1
        -- elseif index  - self._lastPageIndex < -1 then
        --     index = self._lastPageIndex - 1
        -- end

        self:_pageEaseMoveTo(index,group,0.3)
    end

    --间隔10帧点一次
    self._onPageFrame = 10
end

--内部按页滚动到第几组第几个
function ScrollViewExpand:_pageEaseMoveTo(  index,group,time )
    if index < 1 then index = 1 end
    self._lastPageIndex = index
    if self._onPageEnd then
        self._onPageEnd(index,group)
    end
    self:gotoTargetPos(index, group, self._pageType, time)
end

--按页缓动到第几组第几个
function ScrollViewExpand:pageEaseMoveTo( index,group,time )
    if index < 1 then index = 1 end
    self._lastPageIndex = index
    self:gotoTargetPos(index, group, self._pageType, time)
end


--重新计算宽高 如果传递 groupIndex 表示只需要获取到某一组的矩形区域 否则获取整个矩形区域
function ScrollViewExpand:countGroupRect(groupIndex ,oneGroup )

    local length
    local perNums
    local offsetX
    local offsetY
    local itemRect
    local widthGap 
    local heightGap

    local width =0
    local height =0

    local lines =0      --需要多少行

    groupIndex = groupIndex or #self._allItemData


    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL or self.direction == cc.ui.UIScrollView.DIRECTION_BOTH then
        width = self.viewRect_.width
    elseif self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        height = self.viewRect_.height
    end

    if groupIndex ==0 then
        return cc.rect(0,0,0,0 )
    end

    local v = nil
    for i=1,groupIndex do
        v = self._allItemData[i]

        length = #v.data
        perNums = v.perNums or 1
        offsetX = v.offsetX or 0
        offsetY = v.offsetY or 0
        widthGap = v.widthGap or 10
        heightGap = v.heightGap or 10
        itemRect = v.itemRect

        lines =  math.ceil( length/perNums )

        --计算坐标
        --如果是垂直方向的滚动条 
        if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL or self.direction == cc.ui.UIScrollView.DIRECTION_BOTH then
            height = height + itemRect.height * lines + (lines-1) * heightGap + offsetY

        else
            width = width + itemRect.width * lines + (lines-1) * widthGap + offsetX
        end
    end
    local resultRect = cc.rect(0,-height,width,height )
    if oneGroup then
        local lastRect = self:countGroupRect(groupIndex-1 )

        if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL  then
            resultRect.height = resultRect.height - lastRect.height
            resultRect.y = -lastRect.height
        else
            resultRect.width = resultRect.width - lastRect.width
            resultRect.x = lastRect.width
        end
    end

    return resultRect

end

-- 获取滑动区域长度（同countGroupRect意义相同，不考虑多组）
function ScrollViewExpand:countSectorGroupRect()
    local groupIndex = 1
    local itemNums = #(self._allItemData[groupIndex]).data
    -- 所有item总夹角
    local itemTotalAngle = (itemNums - 1) * self.__sectorP.SPACE_ANGLE
    local totalAngle = itemTotalAngle + self.__sectorP.END_ANGLE
    -- 可移动的差值角度
    local deltaAngle = totalAngle - (self.__sectorP.START_ANGLE - 90 + self:getSectorViewAngle()/2)
    if deltaAngle < 0 then deltaAngle = 0 end
    -- 映射可拖动距离
    local dis = deltaAngle / self.__sectorP.DISTOANGLE

    local width,height = self.viewRect_.width,self.viewRect_.height
    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        width = width + dis 
    elseif self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
        height = height + dis
    end

    -- echoError("width",itemNums,itemTotalAngle,totalAngle,deltaAngle,self.viewRect_.width)
    return cc.rect(0,-height,width,height)
end

-- 获取滑动区域长度
function ScrollViewExpand:getScrollRect()
    -- 普通模式
    if not self:isSectorMode() then
        return self:countGroupRect()
    else
        return self:countSectorGroupRect()
    end
end

--计算某个view应该在本组相对的什么位置
function ScrollViewExpand:getViewPos( createNums,groupIndex,itemRect,perNums,offsetX,offsetY,widthGap,heightGap )
    local xpos = 0
    local ypos = 0

    local xIndex =0      --x位置
    local yIndex = 0      --y位置

    --如果是垂直方向或者双向的
    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL or self.direction == cc.ui.UIScrollView.DIRECTION_BOTH then
        xIndex = createNums % perNums
        if xIndex == 0 then
            xIndex = perNums
        end
        yIndex = math.ceil( createNums /perNums )
    else
        xIndex = math.ceil( createNums /perNums )  
        yIndex = createNums % perNums
        if yIndex == 0 then
            yIndex = perNums
        end
    end

    xpos = (xIndex-1) * (itemRect.width + widthGap) + offsetX - itemRect.x
    ypos = (yIndex - 1) * (itemRect.height + heightGap) + offsetY + itemRect.y + itemRect.height
    local groupData = self._allItemData[groupIndex]
    return xpos + groupData.__groupx,-ypos + groupData.__groupy
end

--根据坐标获取应该是在第几个view
function ScrollViewExpand:getViewIndex( xpos,ypos,itemRect,perNums,offsetX,offsetY,widthGap,heightGap,nearest )
    local xIndex =0      --x位置
    local yIndex = 0      --y位置

    xIndex = math.floor( (xpos - offsetX ) / (itemRect.width + widthGap) ) + 1
    yIndex = math.floor( (ypos - offsetY) /  (itemRect.height + heightGap)  ) + 1

    xIndex = xIndex < 1 and 1 or xIndex
    yIndex = yIndex < 1 and 1 or yIndex


    local resultIndex=0
    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL or self.direction == cc.ui.UIScrollView.DIRECTION_BOTH then
        xIndex = perNums
        resultIndex = (yIndex-1) * perNums + xIndex
    else
        yIndex = perNums
        resultIndex = (xIndex - 1 ) * perNums + yIndex
    end

    -- echo(xpos,ypos,"_____________",perNums,"xIndex",xIndex,"yIndex",yIndex,resultIndex)
    return resultIndex
end



--获取某组的容器
function ScrollViewExpand:getGroupCtn( groupIndex )
    if not self._groupCtnCache then
        self._groupCtnCache = {}
    end
    if not self._groupCtnCache[groupIndex] then
        self._groupCtnCache[groupIndex] = display.newNode():addto(self.innerContainer)
    end
    return self._groupCtnCache[groupIndex]

end

--根据数据获取view 返回view  以及 是否是缓存的,true 是缓存 false是创建
function ScrollViewExpand:createViewByData( data,cellIndex,createFunc ,x,y,groupCtn,updateFunc)
    
    local view,isCache,v
    for i=#self._viewCache,1,-1 do
        v= self._viewCache[i]

        --如果匹配到了对应的视图 那么直接返回这个视图
        if v[1] == data then
            view = v[2]
            if view.setScrollView then
                view:setScrollView(self)
            end
            --显示这个view
            view:visible(true)
            isCache =true

            table.remove(self._viewCache,i)
            --同时放到 当前视图数组里面去 这样是为了 提高后面的创建和获取速度
            table.insert(self._viewArr,v)
            if updateFunc then
                updateFunc(data,view,i)
            end
            break
        end
    end

    if not view then
        --否则创建一个视图
        view = createFunc(data,cellIndex)
        if not self._hasOpened then
            view:setOpacity(0)
            view:fadeTo(0.1,255)
        end
        

        if not view then
            echoError("创建view的函数返回空了")
        end
        table.insert(self._viewArr,{data,view} )
    end
    --设置父容器
    if isCache then
        view:parent(self.innerContainer,cellIndex)
        view:stopAllActions()
        if self._fillEaseTime> 0 then

            view:moveTo(self._fillEaseTime,x,y)
        else
            view:pos(x,y)
        end
    else
        view:pos(x,y):parent(self.innerContainer,cellIndex)
    end
    
    --如果view有这个 设置scroll的方法 那么 就调用
    if view.setScrollView then
        view:setScrollView(self)
    end
    view.scrollView = self

    -- 记录一下view的cellIndex用于更新位置
    view.__TTcellIndex = cellIndex
    return view ,isCache

end


--创建bg视图
function ScrollViewExpand:createBgView( groupIndex,createBgFunc,groupData )
    local view,isCache
    local v
    for i=#self._bgViewCacheArr,1,-1 do
        v= self._bgViewCacheArr[i]

        --如果匹配到了对应的视图 那么直接返回这个视图
        if v[1] == groupIndex  then
            view = v[2]
            --显示这个view
            view:visible(true)
            isCache =true

            table.remove(self._bgViewCacheArr,i)
            --同时放到 当前视图数组里面去 这样是为了 提高后面的创建和获取速度
            table.insert(self._bgViewArr,v)
        end
    end

    if not view then
        local rect = self:countGroupRect(groupIndex, true)
        view = createBgFunc(groupIndex,rect.width,rect.height)
        table.insert(self._bgViewArr,{groupIndex,view} )
    end
    local oldx,oldy = view:getPosition()
    view:pos(oldx +groupData.__groupx,oldy + groupData.__groupy)
    view:parent(self.innerContainer,-1)
    return view,isCache

end




--分帧创建视图 这里要判断 如果是缓存的 那么就不不要算分帧
function ScrollViewExpand:delayCreateView(groupIndex,createNums  )
    if groupIndex == #self._allItemData then 
        --如果是循环复用的 那么当创建玩需要的视图后 就足够了
        if self._isCellView then
            if createNums >= self._groupDataExpand[groupIndex].viewNums then
                self._createComplete = true
                
                self:onCreateComplete()
            end
        else
            if createNums >=#self._allItemData[groupIndex].data then
                --创建完成
                self._createComplete = true
                self:onCreateComplete()
                return
            end
        end
        
    end

    local groupData = self._allItemData[groupIndex]
    local groupExpandData = self._groupDataExpand[groupIndex]

    local groupCtn = self:getGroupCtn(groupIndex)

    local length = #groupData.data
    if self._isCellView then
        length = groupExpandData.viewNums
    end

    local perNums = groupData.perNums or 1
    local offsetX = groupData.offsetX or 0
    local offsetY = groupData.offsetY or 0
    local widthGap = groupData.widthGap or 0
    local heightGap = groupData.heightGap or 0
    local itemRect = groupData.itemRect


    local perFrame = groupData.perFrame or 0

    --如果是循环利用的, 那么直接跳到下一组去
    -- if groupData.updateCellFunc then
    --     createNums = #groupData.data
    -- end

    local startIndex = createNums + 1
    local endIndex = startIndex + perFrame

    local nums = 0

    --如果有创建bg的函数, 这里  创建bg 只传递x,y
    if groupData.createBgFunc and createNums == 0 then
        self:createBgView(groupIndex,groupData.createBgFunc,groupData)
    end
    local view
    local groupx,groupy = groupData.__groupx,groupData.__groupy
    local isLast =false



    if self._isCellView then
        for i=startIndex,length do
            --如果是最后一个
            if i == length and groupIndex == #self._allItemData   then
                isLast = true
            end
            local x,y = self:getViewPos(i,groupIndex, itemRect, perNums, offsetX, offsetY, widthGap, heightGap)
            local view = groupData.createFunc(groupData.data[i],i):parent(self.innerContainer)

            -- 记录一下view的cellIndex用于更新位置
            view.__TTcellIndex = i
            view.__cellData = groupData.data[i]
            view.__tempRect = itemRect
            if not self._hasOpened then
                view:setOpacity(0)
                view:fadeTo(0.1,255)
            end
            table.insert( groupExpandData.viewArr,view )
            --存放到所有的cellview数组里面去
            table.insert(self._allCellViewArr, view)
            self:doEnterScroll( view,x,y , isLast )

            self:calSectorPos(i, view)

            nums  = nums +1
            createNums = i
            if nums == perFrame and perFrame > 0 then
                break
            end
        end

    else
        local index1,index2 = nil,nil
        -- 扇形模式需要控制显隐
        if self:isSectorMode() then
            local _
            _,index1 = self:getGroupAndIndex(0)
            _,index2 = self:getGroupAndIndex(2)
        end
        for i=startIndex,length do
            if i == length and groupIndex == #self._allItemData   then
                isLast = true
            end
            local x,y = self:getViewPos(i,groupIndex, itemRect, perNums, offsetX, offsetY, widthGap, heightGap)
            local view,isCache = self:createViewByData(groupData.data[i],i ,groupData.createFunc ,x,y,self.innerContainer )
            view.__tempRect = itemRect
            if not isCache then
                self:doEnterScroll( view,x,y , isLast )
            end
            
            --记录他在这个组的位置
            view.__cellIndex = i
            if not isCache then
                nums  = nums +1
            else
                --如果是缓存的 而且有更新函数 那么调用更新函数
                if groupData.updateFunc then
                    groupData.updateFunc(groupData.data[i],view,i)
                end
            end

            self:calSectorPos(i, view)
            if index1 and index2 then
                view:visible(i >= index1 and i <= index2)
            end

            createNums = i
            --如果当前帧创建的数量足够了 那么break掉
            if nums == perFrame and perFrame > 0 then
                break
            end
        end
    end

    if perFrame ==0 then
        createNums = length
    end

    --如果当前组创建完毕了 那么从下一组 开始从新创建
    if createNums >= length then
        groupIndex = groupIndex +1
        createNums = 0
        if groupIndex > #self._allItemData  then
            self._createComplete = true
            --echo("创建完成--------------")
            self:onCreateComplete()
            return 
        end

        local perFrame = self._allItemData[groupIndex].perFrame or 0
        --判断下一组 是否是分帧创建
        if  perFrame > 0 then
            self:delayCall(c_func(self.delayCreateView, self,groupIndex,createNums))
        else
            
            self:delayCreateView( groupIndex,createNums )
        end

    else
        self:delayCall(c_func(self.delayCreateView, self,groupIndex,createNums))
    end

end


--让view做出场行为
function ScrollViewExpand:doEnterScroll( view,x,y , isLast )

    -- echo(self._itemAppearCount,"____________itemAppearCount_____",self._appearComplete)
    --如果item出现次数小于0了 那么直接设置坐标
    if self._itemAppearCount < 0 then
        view:setPosition(x,y)
        return
    end

    if self._itemAppearType == self.ITEMAPPEARTYPEMAP.NONE then
        view:setPosition(x,y)

    --如果是回弹的
    elseif self._itemAppearType == self.ITEMAPPEARTYPEMAP.BOUCEMOVE then
        view:stopAllActions()
        --如果是竖直方向的滚动条 那么是从下往上
        local rect = self:getViewRect()
        local time = 0.5
        local isInRect =rectEx.contain(rect, x, y )
        --如果超出屏幕了 那么直接 time之间后 设置缓动完成
        if isInRect  then
            local fromx,fromy 
            if self.direction == self.DIRECTION_VERTICAL then
                fromx = x
                --一定是出rect区域外的
                fromy = y - rect.height
            elseif self.direction == self.DIRECTION_HORIZONTAL then
                fromx = x + rect.width
                fromy = y
            end
            -- echo(fromx,fromy,"____doenterAction",x,y)
            view:setPosition(fromx,fromy)
            
            local moveTo  = cc.MoveTo:create(time, cc.p(x, y))
            local action = act.easebackout(moveTo)
            view:runAction(action)
        else
            --直接设置坐标过去
            view:setPosition(x,y)
        end

        local tempFunc =function (  )
            self._appearComplete = true
        end

        --如果不在滚动区域内 或者是最后一个 那么设置0.5秒后恢复滚动状态
        if (not isInRect) or isLast then
            if not self._hasCheckLast   then
                self._hasCheckLast =true
                self:delayCall(tempFunc, time)
            end
        end
    end
end

-- 重写加速滑动的方法，滑动后也需要更新
function ScrollViewExpand:deaccelerateScrolling(...)
    ScrollViewExpand.super.deaccelerateScrolling(self, ...)

    self:updateSector()
end

--重写刷新函数
function ScrollViewExpand:update_(  )
    ScrollViewExpand.super.update_(self)
    if self._isCellView then
        self:refreshCellView()
    end

    --判断page 页码的运动方式
    --如果pageStyle 是按照 火影的方式 scale 朝中心入场
    if self._pageStyle == 1 then
        if self._onPageFrame > 0 then
            self._onPageFrame = self._onPageFrame -1
        end
        
       self:updatePageStyle()
    end

    -- 将位置刷新为扇形滚动
    self:updateSector()
end

function ScrollViewExpand:disabledPageClick(boolean)
    self._disabledPageClick = boolean
end
--
function ScrollViewExpand:updatePageStyle(  )
    --先转化下centerpos
    local posx,posy = self:getCurrentPos()
    --如果是垂直方向的
    if self.direction == self.DIRECTION_VERTICAL then
        posx = self.viewRect_.width/2
        posy = -posy - self.viewRect_.height/2 * self._pageType
    else
        posx = - posx + self.viewRect_.width/2 *self._pageType
        posy = -self.viewRect_.height/2
    end

    -- echo(posx,posy,"___________pagetype")

    local view
    if self._isCellView then
        for i,v in ipairs(self._allCellViewArr) do
            self:pageStyleToView_(v,posx,posy)
        end
    else
        for i,v in ipairs(self._viewArr) do
            self:pageStyleToView_(v[2],posx,posy)
        end
    end

end

--让一个view进行style变化
function ScrollViewExpand:pageStyleToView_( view,posx,posy )
    local viewx,viewy = view:getPosition()
    local itemRect = view.__tempRect
    local scale
    local minscale = self._pageParams.scale
    local wave = self._pageParams.wave
    if self.direction == self.DIRECTION_VERTICAL then
        viewy = viewy - itemRect.height/2 * self._pageType
        scale = 1-math.abs(posy-viewy)/ self.viewRect_.height * wave *2
    else
        viewx = viewx + itemRect.width/2 * self._pageType + itemRect.x
        scale = 1- math.abs( posx-viewx ) / self.viewRect_.width * wave *2
    end
    -- echo(itemRect.width,viewx,posx,"_____________",scale)
    scale = math.max(minscale,scale)
    view:scale(scale)
    view:opacity(scale*255)

end



--移除view
function ScrollViewExpand:doRemoveView(view)
    if view.deleteMe then
        view.deleteMe(view)
    else
        if not tolua.isnull(view) then
            view:removeFromParent(true)
        end
    end
end

--参数转换
function ScrollViewExpand:turnParams( params )
    local uiCfgs = self.__uiCfg.co
    if not uiCfgs then
        return
    end

    for i,v in ipairs(params) do
        
        if not v.offsetX  then
            v.offsetX = uiCfgs.ox or 0
        end

        if not v.offsetY  then
            v.offsetY = uiCfgs.oy or 0
        end

        if not v.perNums  then
            v.perNums = uiCfgs.num or 1
            v.perNums = v.perNums ==0 and 1 or v.perNums
        end

        if not v.widthGap  then
            v.widthGap = uiCfgs.dx or 10
            if v.widthGap == 0 then
                v.widthGap = 10
            end
        end

        if not v.heightGap  then
            v.heightGap = uiCfgs.dy or 10
            if v.heightGap == 0 then
                v.heightGap = 10
            end
        end

        if not v.itemRect then
            if not uiCfgs.wid then
                echoError("这个scroll没有配置itemRect,flash里面也没有配")
            end
            v.itemRect = {x=0,y=- uiCfgs.hei or 0,width = uiCfgs.wid or 0,height = uiCfgs.hei or 0 }
        else
            if v.itemRect.y ==0 then
                echoWarn("这个scroll没有配置itemRect的y坐标不应该配为0")
                v.itemRect.y = -v.itemRect.height
            end
        end



    end

end



--循环复用相关-----------------------------------------------------
--循环复用相关-----------------------------------------------------
--循环复用相关-----------------------------------------------------
--刷新视图,如果只是数据发生变化 那么 调用这个刷新视图即可
function ScrollViewExpand:refreshScroll(  )
    self._createComplete =false

    --先把所有的视图放到 缓存里面去
    for i=#self._viewArr,1,-1 do
        v= self._viewArr[i]
        v[2]:visible(false)
        table.insert(self._viewCache, v)
        --从viewArr里面移除
        table.remove(self._viewArr,i)
    end

    for i=#self._bgViewArr,1,-1 do
        v= self._bgViewArr[i]
        v[2]:visible(false)
        table.insert(self._bgViewCacheArr, v)
        --从viewArr里面移除
        table.remove(self._bgViewArr,i)
    end
    
    --判断有没有是重复创建的
    for i,v in pairs(self._groupDataExpand) do
        for ii,vv in pairs(v.viewArr) do
            --把所有的view隐藏
            vv:visible(false)
        end
    end


    local viewRect
    viewRect = self:getScrollRect()

    --创建scroll的矩形区域
    self:setScrollNodeRect(viewRect)
    --开始分帧创建
    self:delayCreateView(1,0)

end


--初始化循环创建的组
function ScrollViewExpand:initCellGroupProp( groupData,groupIndex )
    if not groupData.data then
        echoError("没有传入数据")
        groupData.data = {}
    end
    local length = #groupData.data
    local perNums = groupData.perNums 
    local offsetX = groupData.offsetX 
    local offsetY = groupData.offsetY 
    local widthGap = groupData.widthGap 
    local heightGap = groupData.heightGap 
    local itemRect = groupData.itemRect
    local perFrame = groupData.perFrame 
    if not self._groupDataExpand[groupIndex] then
        self._groupDataExpand[groupIndex] = {}
    end
    self._groupDataExpand[groupIndex].cellWithGroup = groupData.cellWithGroup
    --数据结构
    --[[
    _groupDataExpand = {
        groupIndex = {
            dataNums ,  --数据数量
            viewArr,    --存储的view数组  长度<= dataNums
            cacheNumsArr = {
                length,
                viewNums,
                group,
            },
            --坐标信息
            dataInfo = {
                {
                    x,
                    y,
                    index
                }

            }
        }
    

    }

    ]]


    local tempObj = self._groupDataExpand[groupIndex]

    local cellGroupObj
    local startIndex = 0

    local viewNums

    --判断需要创建的view数量
    --水平的
    local wid = self.viewRect_.width
    local hei = self.viewRect_.height
    if self:isSectorMode() then
        local degree = self:getSectorViewAngle()
        viewNums = math.ceil(degree / self.__sectorP.SPACE_ANGLE) + 1 -- +1 是多创建一个，防止跳图
    else
        if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL  then
            viewNums = math.ceil(wid/(itemRect.width +widthGap )) + 1
        --垂直的
        elseif self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
            viewNums = math.ceil(hei/ (itemRect.height + heightGap)) + 1
        end
    end
    

    --然后乘以每行创建的数量,这样就是这一组应该创建多少个view ,每个view有一个唯一编号
    viewNums = viewNums * perNums

    --记录最多创建的viewNums
    local maxViewNums = viewNums

    
    local needCreatenums = 0
    local totalViewLength =0
    --如果是采用相同的cell ,而且 而且 groupIndex > 0
    if groupData.cellWithGroup and groupIndex ~= groupData.cellWithGroup then
        cellGroupObj = self._groupDataExpand[groupData.cellWithGroup]
        -- if not cellGroupObj.cacheNumsArr then
        --     cellGroupObj.cacheNumsArr = { {length =cellGroupObj.dataNums,viewNums = cellGroupObj.viewNums, group = groupData.cellWithGroup   }  }
        -- end
        
        --计算已经创建的viewNums
        for i,v in ipairs(cellGroupObj.cacheNumsArr) do
            needCreatenums = needCreatenums + v.viewNums
        end

        
     
        --记录开始的index
        startIndex = cellGroupObj.dataNums
        
        cellGroupObj.dataNums = cellGroupObj.dataNums + length

        --共享同一个viewArr
        if not tempObj.viewArr then
            tempObj.viewArr = cellGroupObj.viewArr
        end
        
        --计算下 我这一组需要创建的viewNums
        viewNums = math.min(cellGroupObj.dataNums,maxViewNums) - needCreatenums

        viewNums = math.max(0,viewNums)
        tempObj.viewNums = viewNums
        table.insert(cellGroupObj.cacheNumsArr, {length= length,viewNums = viewNums, group = groupIndex } )
        totalViewLength = math.min(cellGroupObj.dataNums,maxViewNums)
    else
        if viewNums > length then
            viewNums = length
        end
        totalViewLength = viewNums
        --view数组 ,{从这里面拿view}
        if not tempObj.viewArr then
            tempObj.viewArr = {}
        end
        tempObj.cacheNumsArr = { {length =0,viewNums = viewNums, group = groupIndex   } }

        viewNums = math.max(viewNums - #tempObj.viewArr,0 )
        tempObj.viewNums = viewNums
    end

    --数据信息 {1 = {x,y,index} }
    tempObj.dataInfo = {}
    

    local groupCtn = self:getGroupCtn(groupIndex)
    tempObj.dataNums = #groupData.data
    for i,v in ipairs(groupData.data) do
        local x,y = self:getViewPos(i, groupIndex,itemRect, perNums, offsetX, offsetY, widthGap, heightGap)
        local index = (i+startIndex) % totalViewLength
        if index ==0 then
            index = totalViewLength
        end
        -- echo(index,"__________",totalViewLength,groupIndex,x,y,i)
        --拿的是哪个view
        table.insert(tempObj.dataInfo, {x= x,y=y,index = index } )
        
    end

end


--外部接口----------------------------------------------------
--外部接口----------------------------------------------------
--外部接口----------------------------------------------------
--判断是否创建完成
function ScrollViewExpand:isCreateComplete(  )
    return self._createComplete
end

--重写获取containerBox函数 
function ScrollViewExpand:getContainerBox( )
    return table.copy(self.viewRect_)
end





--设置缓动填充时间
function ScrollViewExpand:setFillEaseTime( easeTime )
    self._fillEaseTime = easeTime or 0
end



--[[
    {
        {
            data = {itemData1,itemData2,... },              --每个item数据 ,必须是table
            createFunc                       --创建函数 必须返回一个 node对象 必须有
            createBgFunc                      创建背景函数,参数( groupIndex,width,height )每组创建一个bg函数 会跟随拖动
            grouBg = 1
            updateFunc                       --刷新item的函数 updateFunc(data,view,index),如果有这个刷新函数,每当从缓存里面拿到的view都会做一次刷新,
            perNums = 1,                     --每行或者每列多少个 默认1 (如果nil表示读取配表值)
            offsetX = 0,                        --
            offsetY = 0,                                    --初始的偏移x ,y 默认是0   (如果nil表示读取配表值)                                 
            widthGap = 10,                                   --  x间隔        默认10    (如果nil表示读取配表值)
            heightGap = 10,                                   --y间隔       默认10      (如果nil表示读取配表值)
            itemRect  = {x=0,y=0,width =100,height = 100},  --    (如果nil表示读取配表值)
            perFrame = 0                                       --分帧加载 默认是0 表示一瞬间加载完成,perFrame是多少每帧加载多少个
        
            updateCellFunc            --更新cell的方法,如果有这个方法,表示是item重复使用的, u
                                      --pdateCellFunc(data,view,index),表示给与这个view重新赋值数据
            cellWithGroup             --当是cellview的时候 表示他和第几组复用同样的item,
                                      --主要是对于有多组填充(比如背包)等这样的list排版
        
        },
        {
            ...
        },
    },

    备注:
    滚动条原则上需要使用循环复用.增加效率.updateCellFunc.
    当数据发生变化的时候 能做少量刷新就少量刷新,注意刷新效率

  ]]

--样式填充
function ScrollViewExpand:styleFill( params )
    
    if self._cancleCache then
        for i=#self._viewCache,1,-1 do
            --这里判断是否是ui
            self:doRemoveView(self._viewCache[i][2])
            table.remove(self._viewCache,i)
        end
        for i=#self._viewArr,1,-1 do
            local view = self._viewArr[i][2]
            self:doRemoveView( self._viewArr[i][2])
            table.remove(self._viewArr,i)
        end
        for k,v in pairs(self._groupDataExpand) do
            if v.viewArr then
                for kk,vv in pairs(v.viewArr) do
                    self:doRemoveView( vv)
                end
                for i=#v.viewArr,1,-1 do
                    table.remove(v.viewArr,i)
                end
            end
        end
        self._groupDataExpand = {}
        self._allCellViewArr ={}
    else
        for k,v in pairs(self._groupDataExpand) do
            if v.viewArr then
                for kk,vv in pairs(v.viewArr) do
                    vv.__cellData = nil
                    vv.__isUsed = false
                end
            end
        end
    end
    
    --先转化下格式
    self:turnParams(params)
    --self.__tempParams =nil
    --self:scrollTo(0, 0)
    self:stopAllActions()
    --初始化停住所有的action
    self.scrollNode:stopAllActions()
    self._allItemData = params
    self._itemAppearCount = self._itemAppearCount -1
    if self._itemAppearCount < 0 then
        self._appearComplete = true
    end
    self._hasCheckLast=nil
    --如果有循环利用的组 那么就 做一下初始化
    local  viewRect
    for k,v in pairs(params) do

        viewRect = self:countGroupRect(k-1)
        --初始化创建组容器

        if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL  then
            v.__groupx = viewRect.width
            v.__groupy = 0
        elseif self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
            --组容器的坐标也需要初始化
            v.__groupx = 0
            v.__groupy = - viewRect.height 
        else
            v.__groupx = 0
            v.__groupy = -viewRect.height
        end
        if v.updateCellFunc then
            --标记是重复利用view
            self._isCellView = true
            self:initCellGroupProp(v, k)

        end
    end
    --直接做刷新功能
    self:refreshScroll()
     --如果是按page页滚动的,那么需要自动设置border
    if self._pageType then
        local itemRect = params[1].itemRect
        if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
            self:setScrollBorder( -self.viewRect_.height/2 * self._pageType + itemRect.height/2 * self._pageType )
        else
            self:setScrollBorder( -self.viewRect_.width/2 * self._pageType + itemRect.width/2 * self._pageType )
        end
        
        -- echo(-self.viewRect_.width/2 * self._pageType + itemRect.width/2,"______scrollBorder" )
    end

    local posx,posy = self:getCurrentPos()
    posx,posy = self:checkBorderPos(posx, posy)
    self:scrollTo(posx,posy)

end

--获取传递进来的scroll参数
function ScrollViewExpand:getScrollParams()
    return self._allItemData;
end

--获取目标节点的坐标
function ScrollViewExpand:getTargetPosByWay(posIndex, groupIndex ,way )
    groupIndex = groupIndex or 1
    if not posIndex then
        echoError("传入空的posIndex了,临时使用1")
        posIndex = 1
    end

    local groupCtn = self:getGroupCtn(groupIndex)

    local groupData = self._allItemData[groupIndex]

    local posx,posy = self:getViewPos(posIndex,groupIndex, groupData.itemRect, groupData.perNums or 1, 
            groupData.offsetX or 0, groupData.offsetY or 0, groupData.widthGap or 10 , groupData.heightGap or 10)

    way = way or 0

    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL  then
        -- echo(way * (self.viewRect_.width - groupData.itemRect.width  ) /2,"______way",posx)
        posx =  -posx -groupData.itemRect.x    + way * (self.viewRect_.width - groupData.itemRect.width  ) /2 

        posy =0

    else 
        posy = -posy -  groupData.itemRect.height - groupData.itemRect.y  -  way * (self.viewRect_.height - groupData.itemRect.height  ) /2  
        posx = 0
    end
    posx,posy = self:checkBorderPos(posx, posy)
    return posx,posy
end

--goto  添加设置偏移的方法
function ScrollViewExpand:gotoTargetPosForOffset(posIndex, groupIndex ,way, easeTime,offset)
    local posx,posy = self:getTargetPosByWay(posIndex, groupIndex ,way)
    --需要加上 offsetX,offsetY
    local groupData = self._allItemData[groupIndex]
    if posIndex == 1 and groupIndex == 1 then
        offset = 0
    end
    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        posx = posx + groupData.offsetX + offset
    else
        posy = posy - groupData.offsetY - offset
    end

    local time
    if easeTime then
        local dx = posx -  self.position_.x
        local dy = posy - self.position_.y

        local spdx = dx/ 10
        local spdy = dy/ 10
        time = math.sqrt( dx*dx + dy*dy ) / 600
        if(easeTime ~= true) then 
            time = easeTime
        else
            if time < 0.1 then
                time = 0.1
            end
            if time > 0.8 then
                time = 0.8
            end

        end
        
    else

        time =0
    end
    self:easeMoveto(posx,posy,time)
end

--goto  groupIndex 第几组 posIndex 第几个       way 跳转到的地方 0 上(左) 1 中(中)  2下(右)     isEase 是否缓动 
function ScrollViewExpand:gotoTargetPos(posIndex, groupIndex ,way, easeTime)
    local posx,posy = self:getTargetPosByWay(posIndex, groupIndex ,way)
    --需要加上 offsetX,offsetY
    local groupData = self._allItemData[groupIndex]
    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        posx = posx + groupData.offsetX 
    else
        posy = posy - groupData.offsetY 
    end

    local time
    if easeTime then
        local curx,cury = self:getCurrentPos()
        local dx = posx -  curx
        local dy = posy - cury

        local spdx = dx/ 10
        local spdy = dy/ 10
        time = math.sqrt( dx*dx + dy*dy ) / 600
        if(easeTime ~= true) then 
            time = easeTime
        else
            if time < 0.1 then
                time = 0.1
            end
            if time > 0.8 then
                time = 0.8
            end

        end

        
    else

        time =0
    end
    self:easeMoveto(posx,posy,time)
end


--获取当前滑到第几组第几个 全部是 当前显示的靠右下的部分
--way 0表示显示考上  1表示显示靠中 2表示显示靠下
--nearest 是否找最近的 ,也许会超出
function ScrollViewExpand:getGroupPos(way ,nearest,posx,posy )
    if not way then
        way = 2
    end
    --如果没传坐标 就获取 获取当前坐标
    if not posx then
        posx ,posy= self:getCurrentPos()
    end

    --坐标进行一下转化
    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        posx = posx - self.viewRect_.width * way/2 
        posy = 0
    else
        posx = 0
        posy = posy +(self.viewRect_.height * way/2  )
    end

    -- posx,posy = self:checkBorderPos(posx,posy)

    -- posx = posx > 0 and 0 or posx
    -- posx = posx < -self.__scrollNodeRect.width and -self.__scrollNodeRect.width or posx
    -- posy = posy > self.__scrollNodeRect.height and self.__scrollNodeRect.height or posy

    -- posy = posy < 0 and 0 or posy

    local turnx = 0
    local turny = 0

    local groupIndex=0
    local posIndex =0 

    --判断落在第几组
    for i,v in ipairs(self._allItemData) do
        local groupRect = self:countGroupRect(i)
        local perNums = v.perNums or 1
        local offsetX = v.offsetX or 0
        local offsetY = v.offsetY or 0
        local widthGap = v.widthGap or 10
        local heightGap = v.heightGap or 10
        local itemRect = v.itemRect

        --坐标进行一下转化
        if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
            turnx = -posx  
            -- turnx = -posx  + self.viewRect_.width * way/2 
            turny = 0
        else
            turnx = 0
            turny = -posy 
            -- turny = -posy  - (self.viewRect_.height * way/2  )
        end

        --如果包含这个点
        if  rectEx.contain(groupRect,turnx,turny) then
            groupIndex = i

            --在找是当前组的第几个
            local ctnx,ctny = v.__groupx,v.__groupy
            turnx = turnx - ctnx
            turny = turny - ctny
            posIndex = self:getViewIndex(turnx,-turny,itemRect,perNums,offsetX,offsetY,widthGap,heightGap ,nearest )
                
           
            --如果是最近的
            if nearest then
                local tempx,tempy =self:getTargetPosByWay(posIndex,groupIndex,0)
                if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
                    tempx = tempx -itemRect.width/2 
                    if math.abs( tempx - posx ) >itemRect.width/2 then
                        if tempx > posx then
                            posIndex = posIndex 
                        else
                            posIndex = posIndex - perNums
                        end
                    end
                else
                    tempy = tempy  + itemRect.height/2 
                    if math.abs(tempy - posy)> itemRect.height/2 then
                        if tempy > posy then
                            posIndex = posIndex - perNums
                        else 
                            posIndex = posIndex 
                        end
                    end
                end
            end

            if posIndex > #v.data then
                posIndex = #v.data
            end
            return groupIndex,posIndex
        end
    end
    -- echo(posy,"_________posy")
    if posx > 0 or posy < 0 then
        local dataNum = #self._allItemData[1].data
        return 1,math.min(self._allItemData[1].perNums,dataNum )
    end

    return #self._allItemData,#(self._allItemData[#self._allItemData].data)

end

-- 扇形模式数量计算，参数和返回值暂时和getGroupPos一致
function ScrollViewExpand:getSectorGroupPos(way)
    if not way then
        way = 2
    end

    local SPACE_ANGLE = self.__sectorP.SPACE_ANGLE
    local START_ANGLE = self.__sectorP.START_ANGLE

    local deltaAngle = self:getSectorDeltaAngle()

    local nowAngle = (self:getSectorViewAngle() / 2) * (1 - way) + 90
    local cellIndex = 1  - (nowAngle - deltaAngle - START_ANGLE) / SPACE_ANGLE
    -- 取最左的时 给出一个item的余量
    if way == 0 then
        cellIndex = cellIndex - 1
    end
    if cellIndex < 1 then cellIndex = 1 end

    cellIndex = math.floor(cellIndex)
    -- echo("self:getSectorViewAngle()",self:getSectorViewAngle())
    -- groupIndex暂时写死1 
    return 1,cellIndex
end

-- 封装方法
function ScrollViewExpand:getGroupAndIndex(...)
    -- 普通模式
    if not self:isSectorMode() then
        return self:getGroupPos(...)
    else
        return self:getSectorGroupPos(...)
    end
end

--获取当前列表所有的view
function ScrollViewExpand:getAllView(  )
    local resultArr = {}
    
    --这里 还需要判断 是否是cellView
    if self._isCellView then
        resultArr = self._allCellViewArr
    else
        for k,v in pairs(self._viewArr) do
            table.insert(resultArr, v[2])
        end
    end

    return resultArr
end


--根据data 获取view  有时 当某个数据发生变化的时候 需要拿到对应数据的视图进行视图更新
function ScrollViewExpand:getViewByData( data )
    for i,v in ipairs(self._viewArr) do
        if v[1] == data then
            return v[2]
        end
    end
    --如果是循环使用的
    if self._isCellView then
        for k,v in pairs(self._groupDataExpand) do
            for kk,vv in pairs(v.viewArr) do
                if vv.__cellData == data then
                    return vv
                end
            end
        end
    end

    return nil
end


--设置scroll坐标  easeTime 默认为0 表示不缓动
function ScrollViewExpand:easeMoveto( xpos,ypos,easeTime )
    easeTime = easeTime or 0
    --边界判断
    self.scrollNode:stopAllActions()
    xpos,ypos = self:checkBorderPos(xpos,ypos) 
    if easeTime > 0 then
        -- self.scrollNode:pos(self.position_.x,self.position_.y)
        self.position_.x = xpos
        self.position_.y = ypos

        --让自身状态是move
        self.touchState = "moved"
        self.scrollNode:runAction(
            act.sequence(
                act.moveto(easeTime,xpos,ypos) ,
                act.callfunc(c_func(self.callListener_, self,{name=self.EVENT_SCROLLEND}))
            )
        )   

        -- self.scrollNode:moveTo(easeTime,xpos,ypos)
    else
       
        self:scrollTo(xpos, ypos)
        self:refreshCellView(0)
    end

end

--设置能否滚动
function ScrollViewExpand:setCanScroll( value )
    self._canScroll = value
end


--取消缓存
function ScrollViewExpand:cancleCacheView( )
    self._cancleCache = true
end

--隐藏滚动条
function ScrollViewExpand:hideDragBar(  )
    self._drawScrollBar = false
    if self.sbV then
        self.sbV:visible(false)
    end

    if self.sbH then
        self.sbH:visible(false)
    end
end

--保持滚动条永不消失，停止滑动后也不消失
function ScrollViewExpand:keepDragBar(  )
    self._keepScrollBar = true
end

--默认是否显示滑动条(即一次也没有点击滚动条，是否显示出滑动条)
function ScrollViewExpand:initDragBarVisible(visible)
    self._showBDrag = visible
end

--更新view滑动区域
function ScrollViewExpand:updateViewRect( rect )
    self:setViewRect(rect)
	if rect.y ~= -rect.height then
		echoError("ScrollViewExpand height not right", rect.y, rect.height)
	end
    self.touchNode_:setContentSize(cc.size(rect.width,rect.height))

end


--按照pageview的方式 滑动  pageType  0上(左) 1中 2下(右)
--scrollDis 指定滑动多少就跳转到下一页, 如果不传 那么就是按照 viewRect.width/2判断
--pageStyle  0表示不需要样式 1 表示采用缩进到中心的方式
--onPageEnd 当鼠标放开时 传递当前滚动到第几组 第几个  onPageEnd(itemIndex,groupIndex)
--pageParams 按页滚动参数 如果是模仿火影的 
--[[
    那么pageParams ={ scale = 0.7, wave = 0.3  } scale 表示最小的缩小值,默认0.7 ,
    wave表示 变化的波动  0.5适中 默认0.3 ,0-1之间的数,越大表示很快就会缩放完毕 0表示几乎不缩小
]]

function ScrollViewExpand:setScrollPage( pageType ,scrollDis,pageStyle,pageParams, onPageEnd)
    pageStyle = pageStyle or 0
    if self._allItemData and not self._pageType then
        echoError("设置page滚动必须要在 styleFill之前")
        return 
    end
    self._pageType = pageType
    self._pageScrollDis = scrollDis
    self._pageStyle = pageStyle
    
    self._pageParams = pageParams
    if pageStyle == 1 then
        if not pageParams then
            self._pageParams= {scale = 0.7,wave = 0.3}
        end
    end

    self._onPageEnd = onPageEnd
end





--获取当前scroll坐标 ,返回 x,y
function ScrollViewExpand:getCurrentPos(  )
    return self.scrollNode:getPosition()
end

--设置超出后的回弹距离
function ScrollViewExpand:setBounceDistance( dis )
    self._bounceDis = dis
end

--设置能否自动滚动
function ScrollViewExpand:setCanAutoScroll(canAutoScroll)
	self._canAutoScroll = canAutoScroll
end

--手动删除某个view,根据数据清理某个view,这样是为了防止内存过大
function ScrollViewExpand:clearOneView( data )
    local length = #self._viewCache
    for i=length,1,-1 do
        local info = self._viewCache[i]
        if info[1] == data then
            local view = info[2]
			self:doRemoveView(view)
        end
    end

end


--清除所有的缓存的view
function ScrollViewExpand:clearCacheView(  )

    local isUseData = function ( data )
        for i,v in ipairs(self._allItemData) do
            if table.indexof(v.data, data) then
                return true;
            end
        end
        return false
    end

    for i=#self._viewCache,1,-1 do
        local v = self._viewCache[i]
        local view = v[2]
        local data = v[1]
        --判断这个view是否在 item里面
        if not isUseData(data) then
            self:doRemoveView(view)
            table.remove(self._viewCache,i)
        end
        
    end

end




-- 获取scrollview 所处的状态
function ScrollViewExpand:isMoving()
    if self.touchState == "moved" then
        return true
    end
    --如果没有出现完成也返回false
    if not self._appearComplete then
        return false
    end

    return false
end

--根据数据判断这个data对应的view是否在显示列表 
--当这个scroll 是循环复用的时候 才有这个接口的需求
function ScrollViewExpand:checkDataToViewShow( data ,groupIndex )

    --如果不是反复利用的
    if not self._isCellView then
        return true
    end
    groupIndex = groupIndex or 1
    local viewArr = self._groupDataExpand[groupIndex].viewArr
    local isShow =false
    for k,v in pairs(viewArr) do
        if v.__cellData == data then
            return true
        end
    end
    return false

end

--强刷某个 data 对应的view,会判断这个view是否在显示队列里面,只针对cellView
--一般 是在当数据发生变化的时候 就单独刷新下,这样会提高效率
function ScrollViewExpand:refreshOneCellData( data,groupIndex )
    if not self._isCellView then
        return
    end
    groupIndex = groupIndex or 1
    local viewArr = self._groupDataExpand[groupIndex].viewArr
    local groupData = self._allItemData[groupIndex]
    local isShow =false
    for k,v in pairs(viewArr) do
        if v.__cellData == data then
            v:visible(true)
            if groupData.updateCellFunc then
                groupData.updateCellFunc(data,v)
            end
        end
    end
    return false
end





--重刷view
--isInit  0表示初始化刷新cellview ,1表示 强制让所有的 view全部更新
function ScrollViewExpand:refreshCellView( isInit )

    if not self._isCellView then
        return
    end

    if not self._appearComplete then
        return
    end

    if (not self:isMoving()) and (not  isInit)  then
        return
    end

    local group1,index1 = self:getGroupAndIndex(0, false)
    -- self:getGroupPos(0, false)
    local group2,index2 = self:getGroupAndIndex(2, false)
    -- self:getGroupPos(2, false)
    -- echo(group1,index1,group2,index2,"_____________________________")

    local groupData1 = self._allItemData[group1]
    local groupData2 = self._allItemData[group2]

    index1 = index1 - groupData1.perNums +1

    local groupStart,indexstart1,indexend1
    local groupMiddle1
    local groupMiddle2

    local groupend,indexstart2,indexend2
    groupStart = group1
    indexstart1 = index1

    for k,v in pairs(self._groupDataExpand) do
        if not v.cellWithGroup or  ( v.cellWithGroup and v.cellWithGroup == k  )then
            --必须得有这组数据
            if self._allItemData[k] then
                local tempViewArr = v.viewArr
                for i,v in ipairs(tempViewArr) do
                    v.__isUsed = false
                end
            end
        end
    end

    --如果是强制重刷的
    if isInit == 1 then
        for k,v in pairs(self._groupDataExpand) do
            if v.viewArr then
                for kk,vv in pairs(v.viewArr) do
                    vv.__cellData = nil
                    vv.__isUsed = false
                end
            end
        end
    end


    local updateGroup = function ( groupIndex,startIndex,endIndex )
        local groupData = self._allItemData[groupIndex]
        -- echo(startIndex,endIndex,groupIndex,"________________",index1,index2,#groupData.data,self:getCurrentPos(  ))
        --如果不是循环利用的
        if not groupData.updateCellFunc then
            return
        end

        if endIndex == -1 then
            endIndex = #groupData.data
        end
        local expandData = self._groupDataExpand[groupIndex]
        if not expandData then
            return
        end
        local viewArr = expandData.viewArr
        local dataInfo= expandData.dataInfo
       
            
        local useArr = {}
        --先选择需要用到的view,编号
        for i=startIndex,endIndex do
            local info = dataInfo[i]
            if info then
                local viewIndex = info.index
                local view = viewArr[viewIndex]
                if view then
                    --如果已经是相同的 那么不需要在刷新了
                    local cellData = groupData.data[i]
                    if view.__cellData ~= cellData or (isInit == 1) then
                        view.__cellData = cellData
                        groupData.updateCellFunc(cellData,view,i)
                        -- echo("_______is change",i,startIndex,endIndex,info.x,info.y)
                    else
                        -- echo("_______is same",i)
                    end
                    --那么调整view的位置 
                    view:pos(info.x,info.y)
                    -- self:calSectorPos(i, view)
                    view.__isUsed = true
                    view.__TTcellIndex = i
                    if not view._isHide then
                        view:visible(true)
                    end
                end
            end
        end
    end

    if group1 ==group2 then
        indexend1 = index2
    --如果横跨2组
    elseif group2 - group1 == 1 then
        indexend1 = #groupData1.data
        groupend = group2
        indexstart2 = 1
        indexend2 = index2
    else
        groupMiddle1 = group1 +1
        groupMiddle2 = group2 -1
        indexend1 = #groupData1.data
        groupend = group2
        indexstart2 = 1
        indexend2 = index2
    end
    updateGroup(groupStart,indexstart1,indexend1)
    if groupMiddle1 then
        for i=groupMiddle1,groupMiddle2 do
            updateGroup(i,1,-1)
        end
    end
    if groupend then
        updateGroup(groupend,indexstart2,indexend2)
    end

    for k,v in pairs(self._groupDataExpand) do
        if not v.cellWithGroup or  ( v.cellWithGroup and v.cellWithGroup == k  )then
            --必须得有这组数据
            if self._allItemData[k] then
                local tempViewArr = v.viewArr
                local hideNums = 0
                for i,v in ipairs(tempViewArr) do
                    if not v.__isUsed then
                        v:visible(false)
                        hideNums = hideNums +1
                    end
                end
            end
        end
    end

end


--显示 滚动条的位置
-- way   -1  对应水平滚动条上(竖直滚动条左)  1对应水平滚动条右(数值滚动条下) 
--默认是1
function ScrollViewExpand:setBarBgWay( way )
    self._barBgWay = way
end

--给item设置出现方式
--这个必须要在stylefill填充之前调用 ,
--isOnlyOnce 对item的出现行为是否只出现一次,如果传false,那么每次stylefill的时候 都会执行 item的入场效果,
--如果是true, 那么只有第一次stylefill的时候才会执行item的出场效果
-- 0表示没有出现方式 1表示缓动过去
function ScrollViewExpand:setItemAppearType( appearType,isOnlyOnce )
    self._itemAppearType = appearType
    if isOnlyOnce then
        self._itemAppearCount=-1;
        self._appearComplete=true
    else
        self._itemAppearCount =   999999
    end
    
    -- if appearType~= self.ITEMAPPEARTYPEMAP.NONE then
    --     self._appearComplete =false
    -- else
    --     self._appearComplete = true
    -- end
    if self._itemAppearCount > 0 then
        self._appearComplete =false
    end
end


--设置scroll 拖拽边界border,有时希望边界的某些范围是不能滚动的 可正可负数
-- 必须在stylefill之后调用
function ScrollViewExpand:setScrollBorder( border )
    self._scrollBorder = border
    if not self._min then
        echoWarn("必须在stylefill之后调用setScrollBorder")
        return 
    end
    self:_calMaxXY()
    local xpos,ypos = self:getCurrentPos(  )
    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        xpos = self._max
    else
        ypos = self._min
    end
    xpos,ypos = self:checkBorderPos(xpos,ypos) 
    self:scrollTo(xpos, ypos)
end

--当滚动条创建完毕时的回调 这个时候一般需要禁止对应ui的电击事件  防止 异常错误
function ScrollViewExpand:setOnCreateCompFunc( func )
    self.onCreateCompFunc = func
end

--[[开启边缘模糊]]
function ScrollViewExpand:enableMarginBluring(_percent)
    self:setClippingMarginType(self.direction-1,_percent or 0.1);
end

-- 更新方法
function ScrollViewExpand:updateSector( isInit )
    if not self:isSectorMode() then return end
    if (not self:isMoving()) and (not  isInit)  then
        return
    end

    -- echo("更新所有view的方法",#self:getAllView())
    local group1,index1 = self:getGroupAndIndex(0, false)
    -- self:getGroupPos(0, false)
    local group2,index2 = self:getGroupAndIndex(2, false)

    -- 更新所有view的位置
    for _,view in ipairs(self:getAllView() or {}) do
        self:calSectorPos(view.__TTcellIndex, view)
        -- 此模式zorder重要
        view:zorder(view.__TTcellIndex)
        -- 显隐性
        view:visible(view.__TTcellIndex >= index1 and view.__TTcellIndex <= index2)
    end
end

-- 计算差值角度
function ScrollViewExpand:getSectorDeltaAngle()
    -- 计算差值角度
    local deltaX, deltaY = self:getCurrentPos()

    local deltaDis

    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        deltaDis = -deltaX
    elseif self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
        deltaDis = deltaY
    end

    local deltaAngle = deltaDis * self.__sectorP.DISTOANGLE

    return deltaAngle
end

local PI = 3.1415926
local PI_2 = PI * 2 

-- 计算item在弧形上的位置和角度（正方向和圆心位置有关）
function ScrollViewExpand:calSectorPos(cellIndex, view)
    if not self:isSectorMode() then return end
    local SPACE_ANGLE = self.__sectorP.SPACE_ANGLE
    local START_ANGLE = self.__sectorP.START_ANGLE

    local cx,cy
    local R
    -- 自身角度
    local selfAngle = -(cellIndex - 1) * SPACE_ANGLE + START_ANGLE
    -- 计算差值角度
    local deltaAngle = self:getSectorDeltaAngle()
    -- 计算位置
    local nowAngle = selfAngle + deltaAngle
    local nowRad = math.rad(nowAngle)
    -- view的大小
    local itemRect = view.__tempRect
    -- 位置
    local x,y = nil,nil
    -- 旋转角度
    local rotation = nil
    -- cx + R * math.cos(nowRad)
    -- local y = cy + R * math.sin(nowRad)
    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        if self.__sectorP.STYPE == ScrollViewExpand.SECTOR_CENTER_BOTTOM then
            cx,cy = self.viewRect_.width / 2,-self.__sectorP.R
            R = self.__sectorP.R
            x = cx + R * math.cos(nowRad)
            y = cy + R * math.sin(nowRad)
            rotation = 90 - nowAngle
        else
            cx,cy = self.viewRect_.width / 2, self.__sectorP.R - self.viewRect_.height
            R = self.__sectorP.R - itemRect.height
            x = cx + R * math.cos(nowRad)
            y = cy + R * math.sin(PI_2 - nowRad)
            rotation = nowAngle - 90
        end
    elseif self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
        if self.__sectorP.STYPE == ScrollViewExpand.SECTOR_CENTER_LEFT then
            cx,cy = -(self.__sectorP.R - self.viewRect_.width),-self.viewRect_.height / 2
            R = self.__sectorP.R - itemRect.width
            x = cx + R * math.sin(nowRad)
            y = cy + R * math.cos(PI - nowRad)
            rotation = 90 - nowAngle
        else
            cx,cy = self.__sectorP.R,-self.viewRect_.height / 2
            R = self.__sectorP.R
            x = cx + R * math.sin(PI_2 - nowRad)
            y = cy + R * math.cos(PI - nowRad)
            rotation = nowAngle - 90
        end
    end

    local tpos = self:convertLocalToNodeLocalPos(self.scrollNode,cc.p(x,y))
    if view then
        -- item倾斜角度
        -- view:stopAllActions() -- 临时
        view:setRotation(rotation)
        view:pos(tpos.x, tpos.y)
    end

    return tpos.x,tpos.y
end

--[[
    要先于styleFill调用
    标准x轴正方向重合时为0°，逆时针为旋转方向，默认所有的item锚点都在cc.p(0,1)
    params = {
        stype = -- 圆心位置（枚举值）ScrollViewExpand.SECTOR_CENTER_BOTTOM
        start = -- 第一个item的起始角度(转向滑动方向的角，右侧总为正方向)
        endangle = -- 最后一个item相对于0°可滑动到的最大位置
        space -- 间隔角度
        r = -- 半径
        speed = -- 每像素对应的角度
    }

    scroll:setSectorScroll({
        stype = ScrollViewExpand.SECTOR_CENTER_BOTTOM,
        -- start = 180,
        endangle = 26,
        space = 10,
        r = 1000,
        speed = 0.1,
    })
]]
-- 设置扇形滚动参数
function ScrollViewExpand:setSectorScroll(params)
    -- 扇形滚动参数
    self.__sectorP = {
        STYPE = params.stype or ScrollViewExpand.SECTOR_CENTER_BOTTOM,
        START_ANGLE = params.start,
        END_ANGLE = params.endangle or 10,
        SPACE_ANGLE = params.space or 30,
        DISTOANGLE = params.speed or 1,
        R = params.r or 0,
    }

    -- 限制半径
    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        if self.__sectorP.R < self.viewRect_.height then
            self.__sectorP.R = self.viewRect_.height
        end
        if not params.start then
            self.__sectorP.START_ANGLE = 90 + math.deg(math.asin(self.viewRect_.width / 2 / self.__sectorP.R))
        end
    elseif self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
        if self.__sectorP.R < self.viewRect_.width then
            self.__sectorP.R = self.viewRect_.width
        end
        if not params.start then
            self.__sectorP.START_ANGLE = 90 + math.deg(math.asin(self.viewRect_.height / 2 / self.__sectorP.R))
        end
    end
end

-- 计算可视角度
function ScrollViewExpand:getSectorViewAngle()
    -- 正切的底边，和竖直边
    local horizontal,vertical

    if self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
        horizontal,vertical = self.viewRect_.height,self.viewRect_.width
    elseif self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
        horizontal,vertical = self.viewRect_.width,self.viewRect_.height
    end

    local templ = self.__sectorP.R - horizontal 
    if templ <= 0 then templ = 1 end
    local degree = math.deg(math.atan(vertical / 2 / templ) * 2)

    return degree
end

-- 是否是扇形模式
function ScrollViewExpand:isSectorMode()
    return self.__sectorP ~= nil
end

return ScrollViewExpand