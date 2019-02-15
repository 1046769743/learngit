--
-- Author: ZhangYanguang
-- Date: 2015-12-18
-- 不规则item滚动条
-- 目前仅支持单列或单行
--[[
    setByFrame:设置是否分帧加载，默认分帧加载
    setItemNumByFrame:设置每帧创建item数量，默认每帧创建总数量的1/5个，即分5帧显示完毕
]]

local MultiScrollBaseView = class("MultiScrollBaseView", UIBase);

function MultiScrollBaseView:ctor(winName)
    MultiScrollBaseView.super.ctor(self, winName);
    self:_initData()
end

-- =====================  对外接口 =========================
-- 初始化滚动
function MultiScrollBaseView:createScroller(scrollerView,scrollerCfg)
    self:initScroller(scrollerView)
    self.scrollerCfg = scrollerCfg
    self:layoutScroller()

    scrollerView:onScroll(handler(self, self.onTouchCallback))
end

-- 设置是否分帧加载
function MultiScrollBaseView:setByFrame(byFrame)
    self.isByFrame = byFrame
end

-- 设置每帧创建item数量
function MultiScrollBaseView:setItemNumByFrame(itemNum)
    self.createNumPerFrame = itemNum
end

-- 刷新滚动列表
function MultiScrollBaseView:reload()
    if self.container then
        self.container:removeAllChildren()
        self:layoutScroller()
    end
end

-- 滚动条是否在滚动中
function MultiScrollBaseView:isScrolling(itemNum)
    if self.scroller._isScrolling then
        return true
    end

    if self.scroller:isMoving() then
        return true
    end

    return false
end

function MultiScrollBaseView:setScrollEndCallBack(callBack)
    self.scrollEndFunc = callBack
end

-- =====================  内部方法 =========================
function MultiScrollBaseView:onTouchCallback(event)
    if event.name == "scrollEnd" then
        if self.scrollEndFunc ~= nil then
            self.scrollEndFunc()
        end
    end
end

function MultiScrollBaseView:_initData()
    -- 所有item数据配置列表
    self.itemCfgList = {}
    -- item创建计数器
    self.createCounter = 0
    -- 每帧创建item个数
    self.createNumPerFrame = 0
    -- 是否分帧创建
    self.isByFrame = true

    -- 分帧加载时，总共用多少帧加载完成
    self.totalFrames = 5
end

--初始化滚动
function MultiScrollBaseView:initScroller(scrollerView)
    self.scroller = scrollerView
    --目前暂定每次初始化 重新创建container
    self.container = display.newNode()
    self.scroller:addScrollContainer(self.container)
    
    self.scrollerViewRect = self.scroller.viewRect_
end

-- 布局滚动区
function MultiScrollBaseView:layoutScroller()
    -- 初始化滚动区内容总高度 self.totalSize
    self.totalSize = 0
    local firstViewCfg = self.scrollerCfg[1]

    if self.scroller.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
        self.totalSize = firstViewCfg.offsetY
    else
        self.totalSize = firstViewCfg.offsetX
    end

    -- 解析item配置数据
    self:parseItemCfg()

    -- 如果是分帧创建
    if self.isByFrame then
        self:createAllItemsByFrame()
    else
        self:createAllItems()
    end
end

-- 分帧创建所有items
function MultiScrollBaseView:createAllItemsByFrame()
    if self.createCounter > #self.itemCfgList then
        self:updateScrollRect()
        return
    else
        if self.createCounter <= 0 then
            self.createCounter = 1
        end

        for i=1,self.createNumPerFrame do
            if self.createCounter > #self.itemCfgList then
                self:updateScrollRect()
                return
            end

            local itemCfg = self.itemCfgList[self.createCounter]
            local dataIndex = itemCfg.index
            local viewCfg = itemCfg.viewCfg
            self:createOneItem(dataIndex,viewCfg)

            self.createCounter = self.createCounter + 1
        end
    end

    self:delayCall(handler(self,self.createAllItemsByFrame), 1/GameVars.GAMEFRAMERATE)
end

-- 一帧内创建所有items
function MultiScrollBaseView:createAllItems()
    -- 遍历配置，布局滚动区
    -- for i=1,#self.scrollerCfg do
    --     local viewCfg = self.scrollerCfg[i]
    --     self:createItems(viewCfg)
    -- end

    for i=1,#self.itemCfgList do
        local itemCfg = self.itemCfgList[i]
        local dataIndex = itemCfg.index
        local viewCfg = itemCfg.viewCfg
        self:createOneItem(dataIndex,viewCfg)
    end

    self:updateScrollRect()
end

-- 追加items
function MultiScrollBaseView:appendItems(type,datas)
    type = type or 1
    local itemCfg = self.itemCfgList[type]
    if datas == nil or #datas ==  0 or itemCfg == nil then
        return
    end

    local viewCfg = itemCfg.viewCfg
    local originNum = #viewCfg.data

    -- 将datas加入追加到原数据中
    for i=1,#datas do
        viewCfg.data[#viewCfg.data+1] = datas[i]
    end

    -- 是否分帧
    if self.isByFrame then
        self.originNum = originNum
        self.appendDatas = datas
        self.appendType = type
        self.appendCounter = 0

        self:appendItemsByFrame()
    else
        for i=1,#datas do
            local dataIndex = i + originNum
            self:createOneItem(dataIndex,viewCfg)
        end

        self:updateScrollRect()
    end
end

-- 分帧追加items
function MultiScrollBaseView:appendItemsByFrame()
    if self.appendCounter > #self.appendDatas then
        self:updateScrollRect()
        return 
    else
         if self.appendCounter <= 0 then
            self.appendCounter = 1
        end

        for i=1,self.createNumPerFrame do
            if self.appendCounter > #self.appendDatas then
                self:updateScrollRect()
                return
            end

            local itemCfg = self.itemCfgList[self.appendType]
            local viewCfg = itemCfg.viewCfg

            local dataIndex = self.appendCounter + self.originNum
            self:createOneItem(dataIndex,viewCfg)

            self.appendCounter = self.appendCounter + 1
        end
    end

    self:delayCall(handler(self,self.appendItemsByFrame), 1/GameVars.GAMEFRAMERATE)
end

-- 解析item配置
function MultiScrollBaseView:parseItemCfg()
    for i=1,#self.scrollerCfg do
        local viewCfg = self.scrollerCfg[i]
        local item = viewCfg.item
        -- 隐藏原item
        item:setVisible(false)
        
        local datas = viewCfg.data
        if datas ~= nil and #datas > 0 then
            for i=1,#datas do
                self.itemCfgList[#self.itemCfgList+1] = {index = i,viewCfg = viewCfg}
            end
        end
    end

    -- 设置默认每帧创建item数量
    -- 判断self.createNumPerFrame等于0，是避免覆盖外部接口设置的值
    if self.isByFrame and self.createNumPerFrame == 0 then
        self:setDefaultItemNumByFrame()
    end
end

-- 设置默认每帧创建item的数量
function MultiScrollBaseView:setDefaultItemNumByFrame()
    if #self.itemCfgList > 0 then
        local itemNum = math.floor(#self.itemCfgList / self.totalFrames )
        if itemNum < 1 then
            itemNum = 1
        end
        self.createNumPerFrame = itemNum
    end

    echo("self.createNumPerFrame==",self.createNumPerFrame)
end

-- 创建所有items
function MultiScrollBaseView:createItems(viewCfg)
    local item = viewCfg.item
    -- 隐藏原item
    item:setVisible(false)

    local datas = viewCfg.data
    if datas ~= nil and #datas > 0 then
        for i=1,#datas do
            self:createOneItem(i,viewCfg)
        end
    -- ZhangYanguang 数据为nil，不创建item
    -- else
    --     self:createOneItem(1,viewCfg)
    end
    
    self:updateScrollRect()
end

-- 创建一个item
function MultiScrollBaseView:createOneItem(index,viewCfg)
    local itemView = UIBaseDef:cloneOneView(viewCfg.item)
    itemView:setVisible(true)
    itemView:addTo(self.container)

    local itemUIBox = itemView:getContainerBox()

    -- itemView的大小
    local itemViewSize = 0
    if self.scroller.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
        itemViewSize = itemUIBox.height
        -- 设置位置
        local posX = viewCfg.offsetX or 0
        local posY = - self.totalSize
        itemView:pos(posX,posY)
    else
        itemViewSize = itemUIBox.width
        -- 设置位置
        local posX = self.totalSize
        local posY = viewCfg.offsetY or 0
        itemView:pos(posX,posY)
    end

    local padding = viewCfg.padding or 0
    -- 重新计算totalHeight
    self.totalSize = self.totalSize + itemViewSize + padding

    -- 调用item的更新方法
    local updateFunc = viewCfg.updateFunc
    if updateFunc ~= nil then
        local data = nil
        if viewCfg.data ~= nil and #viewCfg.data > 0 then
            data = viewCfg.data[index]
        end
        updateFunc(itemView,data)
    end
end

-- 更新滚动区域
function MultiScrollBaseView:updateScrollRect()
    local scrollRect = cc.rect(0,0,0,0)
    
    -- 垂直布局
    if self.scroller.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
        if self.totalSize > self.scrollerViewRect.height then
            scrollRect.y = - self.totalSize
            scrollRect.height = self.totalSize
            scrollRect.width = self.scrollerViewRect.width
        else
            scrollRect.y = - self.scrollerViewRect.height
            scrollRect.height = self.scrollerViewRect.height
            scrollRect.width = self.scrollerViewRect.width
        end

        self.scroller:setScrollNodeRect(scrollRect)
    else
        if self.totalSize > self.scrollerViewRect.width then
            scrollRect.x = - self.totalSize
            scrollRect.width = self.totalSize
            scrollRect.height = self.scrollerViewRect.height
        else
            scrollRect.x = - self.scrollerViewRect.width
            scrollRect.width = self.scrollerViewRect.width
            scrollRect.height = self.scrollerViewRect.height
        end

        -- ZhangYanguang 横版滚动设置ScrollNodeRect有bug
        -- self.scroller:setScrollNodeRect(scrollRect)
    end
end

return MultiScrollBaseView;
