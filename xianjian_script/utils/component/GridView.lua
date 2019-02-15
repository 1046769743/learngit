--[[guan 2015.10.8]]

local UIScrollViewExpand = import(".ScrollViewExpand");

local GridView = class("GridView", UIScrollViewExpand);

------------------------------------public------------------------------
--滚动到那个地方 0-100, time(秒)不为nil则用time时间缓动过去
function GridView:scrollToPosByPercent(percent, time)
    local allDis = self._max - self._min;

    if percent < 0 or percent > 100 then 
        echo("scrollToPosByPercent percent should be 0-100")
        return;
    end 

    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        self.position_ = cc.p(self.scrollNode:getPositionX(), 
            0 + allDis * percent / 100);
    else 
        self.position_ = cc.p(-allDis * percent / 100, 
            self.scrollNode:getPositionY());
    end 

    local needCellIndexs = self:_needCellIndexs(self.position_);
    self:updateContainerCells(needCellIndexs);

    if time == nil then
        self.scrollNode:setPosition(self.position_);
    else 
        local act = cc.MoveTo:create(time, self.position_);
        self.scrollNode:runAction(act);
    end 
end

--返回当前滚动位置百分比
function GridView:getCurScrollPosByPercent()
    local allDis = self._max - self._min; 

    if allDis == 0 then 
        return 0;
    end 

    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        return self.scrollNode:getPositionY() / allDis; 
    else 
        return self.scrollNode:getPositionX() / allDis; 
    end  
end

--删除节点
function GridView:delItemByIndex(index)
    self._dataAdapter:delItemByIndex(index);
end

--增加节点
function GridView:addItemByIndex(itemData, index)
    self._dataAdapter:addItemByIndex(itemData, index);
end

function GridView:setAdapter(adapter)
    self._dataAdapter = adapter;
    self._dataAdapter:setGridView(self);
end

function GridView:updateSingleItem(index)
    for indexUse, _ in pairs(self._cellsInContainerIndexs) do
        if indexUse == indexUse then 
            local child = self._cellsUsed[index];
            child = child:updateUI(index, self._dataAdapter);
            return;
        end 
    end
end

--执行这个后界面显示
function GridView:gridViewInit()
    --计算innterContainerSize 
    self._innterContainerSize = self:_calInnterContainerSize();

    self._innerContainer = self:_createInnerContainer();

    if self._isNodeAdd == nil or self._isNodeAdd == false then  
        self:addScrollNode(self._innerContainer);
    end 
    self._isNodeAdd = true;

    self:setScrollNodeRect(cc.rect(0, -self._innterContainerSize.height, 
      self._innterContainerSize.width, self._innterContainerSize.height));

    self._cellsInContainerIndexs = self:_needCellIndexs();

    for index, _ in pairs(self._cellsInContainerIndexs) do
        local itemPos = self._allItemPos[index].pos;
        local child = nil;

        if table.length(self._cellsFreeBuffer) ~= 0 then 
            child = table.remove(self._cellsFreeBuffer);
        else
            child = self:_cellCreate();
        end 

        -- child = self._dataAdapter:itemCreateCallBack(child, index);
        child = child:updateUI(index, self._dataAdapter);
        child:setPosition(itemPos);
        child:setVisible(true);

        self._cellsUsed[index] = child;
    end

    self:_calMaxXY();
end

function GridView:recreateUI(adapter, isCellReuse)
    self:stopScrolling();
    if isCellReuse == false or isCellReuse == nil then 
        self:_collectAllCellToBuffer();
    else 
        self._cellsUsed = {}
        self._cellsFreeBuffer = {};
        --一共创建了多少个cell
        self._cellCreateNum = 0;
    end 
    
    self._allItemPos = {};
    self._cellsInContainerIndexs = {};

    self:setAdapter(adapter);
    self:gridViewInit();
end

--得到此GridView的配置信息，间距等
function GridView:getParams()
    local itemWidth = self._itemPrototype:getContainerBox().width;
    local itemHeight = self._itemPrototype:getContainerBox().height;

    local ct = table.deepCopy(self._params);

    ct.itemWidth = itemWidth;
    ct.itemHeight = itemHeight;

    return ct;
end

------------------------------------private------------------------------
--[[
  可用参数有：
  ScrollViewExpand中有的
  -   direction 列表控件的滚动方向，默认为垂直方向
  -   alignment listViewItem中content的对齐方式，默认为垂直居中
  -   scrollbarImgH 水平方向的滚动条
  -   scrollbarImgV 垂直方向的滚动条
  -   bgColor 背景色,nil表示无背景色
  -   bgStartColor 渐变背景开始色,nil表示无背景色
  -   bgEndColor 渐变背景结束色,nil表示无背景色
  -   bg 背景图
  -   bgScale9 背景图是否可缩放
  -   capInsets 缩放区域
  
  从flash里取到的数据

  -   numColumns 一行或一列放多少item
  -   lineGap 每行或每列之间的间隔
  -   GridViewWidth GridView的宽度
  -   GridViewHeight GridView的高度
  -   itemClass item类名

  -   xlineGap x方向间隔
  -   ylineGap y方向间隔

  -   xOffset x偏移
  -   yOffset y偏移
]]
function GridView:ctor(params)
    --所有gridView 中 的 item 的 位置
    --[[
        index = {pos = cc.p(), index = },
        index = {pos = cc.p(), index = },
        index = {pos = cc.p(), index = },
        index = {pos = cc.p(), index = },
    ]]
    self._allItemPos = {};
    --[[
      {
        3 = true,
        4 = true,
        5 = true,
        6 = true,
      }
    ]]
    self._cellsInContainerIndexs = {};
    self.viewRect_ = cc.rect(0, -params.GridViewHeight,
      params.GridViewWidth, params.GridViewHeight);
    params.viewRect = self.viewRect_;

    self._innterContainerSize = {height = 0, width = 0};
    
    GridView.super.ctor(self, params)

    self._itemPrototype = UIBaseDef:createUIByName(params.itemClass);

    self._itemPrototype:setVisible(false);
    self:addChild(self._itemPrototype);

    self._numColumns = params.numColumns;
    self._itemClass = params.itemClass;

    self._xlineGap = params.xlineGap or 0;
    self._ylineGap = params.ylineGap or 0;

    self._xOffset = params.xOffset or 0;
    self._yOffset  = params.yOffset or 0;

    self._cellsUsed = {}
    self._cellsFreeBuffer = {};
    --一共创建了多少个cell
    self._cellCreateNum = 0;
    self._params = params;
end


function GridView:setItemPrototype(prototype)
    self._itemPrototype = prototype;
end

function GridView:_calMaxXY()
    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        self._max = self._innterContainerSize.height - self.viewRect_.height;
        self._min = 0;
    else 
        self._max = 0;
        self._min = -(self._innterContainerSize.width - self.viewRect_.width);
    end  
end

function GridView:_calInnterContainerSize()
    local length = self:_calGridLength();

    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
        return cc.size(self.viewRect_.width, length);
    else 
        return cc.size(length, self.viewRect_.height);
    end
end

function GridView:_calGridLength()
  local totalLine = math.ceil(self._dataAdapter:getItemNum() / self._numColumns);
  local retLength = 0;

  if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
    retLength = totalLine * self._itemPrototype:getContainerBox().height + 
      (totalLine - 1) * self._ylineGap + 2 * self._yOffset;
  else 
    retLength = totalLine * self._itemPrototype:getContainerBox().width + 
      (totalLine - 1) * self._xlineGap + 2 * self._xOffset;
  end 

  return retLength;
end

function GridView:_calGap()
  local gap = 0;

  if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
    gap = self._xlineGap;
  else 
    gap = self._ylineGap;
  end 

  return gap;
end

function GridView:_createInnerContainer()
    if  self._innerContainer == nil then
       self._innerContainer = display.newNode();
    end 
    self._innerContainer:setPosition(cc.p(0, 0))

    self._innerContainer:setContentSize(self._innterContainerSize);

    local gap = self:_calGap();
    
    local totalLine = math.ceil(self._dataAdapter:getItemNum() / self._numColumns);

    for i = 1, totalLine do
      local posX = nil;
      local posY = nil;

      if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        posX = self._xOffset;
        posY = self._innterContainerSize.height - (i - 1) * 
          (self._ylineGap + self._itemPrototype:getContainerBox().height) - self._yOffset;
      else 
        posX = (i - 1) * 
          (self._itemPrototype:getContainerBox().width + self._xlineGap) + self._xOffset;
        posY = self._innterContainerSize.height - self._yOffset;
      end 

      for j = 1, self._numColumns do
        if ((i - 1) * self._numColumns + j) > self._dataAdapter:getItemNum() then 
          break;
        end 

        local itemPos = {}

        itemPos.index = (i - 1) * self._numColumns + j;
        itemPos.pos = cc.p(posX, posY);

        table.insert(self._allItemPos, itemPos);

        if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
          posX = posX + gap + self._itemPrototype:getContainerBox().width;
        else 
          posY = posY - self._itemPrototype:getContainerBox().height - gap;
        end 
      end
      if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        posY = posY - self._itemPrototype:getContainerBox().height - self._ylineGap;
      else 
        posX = posX + self._xlineGap;
      end 
    end

    self._innerContainer:setAnchorPoint(cc.p(0, 1));
    self._totalLine = totalLine;
    return self._innerContainer;
end

function GridView:_delItemByIndexUseByAdapter(index)
    local itemToDel = self._allItemPos[index];
    if itemToDel == nil then 
        return;
    end 

    table.remove(self._allItemPos, index);

    self._innterContainerSize = self:_calInnterContainerSize();

    self._innerContainer:setContentSize(self._innterContainerSize);

    self:setScrollNodeRect(cc.rect(0, -self._innterContainerSize.height, 
        self._innterContainerSize.width, self._innterContainerSize.height));
    
    
    self:resetItemPos();
    self:_calMaxXY();

    self:_updateUI();
end

function GridView:_updateUI()
    self:_collectAllCellToBuffer();

    local needCellIndexs = self:_needCellIndexs(self.position_);

    self:updateContainerCells(needCellIndexs);
end

function GridView:_collectAllCellToBuffer()
    for index, cell in pairs(self._cellsUsed) do
        table.insert(self._cellsFreeBuffer, cell);
        cell:setVisible(false);
    end
    self._cellsUsed = {};
    self._cellsInContainerIndexs = {};
end

--更新container里面的cell
function GridView:updateContainerCells(needCellIndexs)
    --已经不用了，放到 self._cellsFreeBuffer 里
    for index, _ in pairs(self._cellsInContainerIndexs) do
        if needCellIndexs[index] ~= true then 
            local cell = self._cellsUsed[index];
            table.insert(self._cellsFreeBuffer, cell);
            cell:setVisible(false);
            self._cellsUsed[index] = nil;
        end 
    end

    --不在container里就创建出来，放进去
    for index, _ in pairs(needCellIndexs) do
        if self._cellsInContainerIndexs[index] ~= true then 
            local cell = nil;
            if table.length(self._cellsFreeBuffer) ~= 0 then 
                cell = table.remove(self._cellsFreeBuffer);
            else 
                --创建cell
                cell = self:_cellCreate();
            end
            
            cell = cell:updateUI(index, self._dataAdapter);

            local pos = self._allItemPos[index].pos;
            cell:setPosition(pos);

            self._cellsUsed[index] = cell;
            cell:setVisible(true);
        end 
    end

    self._cellsInContainerIndexs = needCellIndexs;
end

function GridView:_addItemByIndexUseByAdapter(itemData, index)
    table.insert(self._allItemPos, index, {});

    self._innterContainerSize = self:_calInnterContainerSize();
  
    self._innerContainer:setContentSize(self._innterContainerSize);

    self:setScrollNodeRect(cc.rect(0, -self._innterContainerSize.height, 
      self._innterContainerSize.width, self._innterContainerSize.height));

    self:resetItemPos();
    self:_calMaxXY();

    self:_updateUI();
end

function GridView:resetItemPos()
    local gap = self:_calGap();
    
    local totalLine = math.ceil(self._dataAdapter:getItemNum() / self._numColumns);

    for i = 1, totalLine do
      local posX = nil;
      local posY = nil;
      if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        posX = self._xOffset;
        posY = self._innterContainerSize.height - (i - 1) * 
          (self._ylineGap + self._itemPrototype:getContainerBox().height) - self._yOffset;
      else 
        posX = (i - 1) * 
          (self._itemPrototype:getContainerBox().width + self._xlineGap) + self._xOffset;
        posY = self._innterContainerSize.height - self._yOffset;
      end 

      for j = 1, self._numColumns do
        if ((i - 1) * self._numColumns + j) > self._dataAdapter:getItemNum() then 
          break;
        end 

        local itemPos = self._allItemPos[(i - 1) * self._numColumns + j];
        itemPos.index = (i - 1) * self._numColumns + j;
        itemPos.pos = cc.p(posX, posY);

        if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
          posX = posX + gap + self._itemPrototype:getContainerBox().width;
        else 
          posY = posY - self._itemPrototype:getContainerBox().height - gap;
        end 
      end
      if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        posY = posY - self._itemPrototype:getContainerBox().height - self._ylineGap;
      else 
        posX = posX + self._xlineGap + self._itemPrototype:getContainerBox().width;
      end 
    end

    self._totalLine = totalLine;
end

function GridView:addScrollContainer(container)
    --不应该调用这个方法
    assert(false, "GirdView can't call addScrollContainer. Container is calculated automatically！");
end

function GridView:_addItemFunc(itemNode)
    itemNode.checkCanClick = function (itemNode)
        if itemNode.scrollView then
            if itemNode.scrollView:isScrolling() ~= true then 
                -- print("isScrolling is false")
                return not itemNode.scrollView:isMoving();
            else 
                return false;
            end 
        end
        return true
    end

    itemNode.setScrollView = function (itemNode, scroll)
        itemNode.scrollView = scroll;
    end   
end

function GridView:isScrolling()
    return self._isScrolling == true and true or false;
end

--container位于 containerPos 需要的的cell序号集合
function GridView:_needCellIndexs(containerPos)
    --[[
        {
            2 = true,
            3 = true,
            4 = true,
        }
    ]]
    local indexs = {};

    containerPos = containerPos or 
        cc.p(self._innerContainer:getPositionX(), self._innerContainer:getPositionY());

    local beginLine, endLine = self:_getShowBeginAndEndLineIndex(containerPos);
    local itemsNum = self._dataAdapter:getItemNum();

    for i = beginLine, endLine do
       for j = 1, self._numColumns do
          local index = (i - 1) * self._numColumns + j;
          if index > itemsNum then 
              break;
          end 
          indexs[index] = true;
       end
    end

    return indexs;
end

function GridView:_itemLinePerView()
    local num = 0;
    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        local itemHeight = self._itemPrototype:getContainerBox().height;

        local y = -self._yOffset;
        local downY = -self.viewRect_.height;

        while y > downY do
            y = y - itemHeight - self._ylineGap;
            num = num + 1;
        end
    else 
        local itemWidth = self._itemPrototype:getContainerBox().width;

        local x = self._xOffset;
        local rightX = self.viewRect_.width;

        while x < rightX do
            x = x + itemWidth + self._xlineGap;
            num = num + 1;
        end
    end 
    return num;
end

function GridView:_getShowBeginAndEndLineIndex(containerPos)
    local beginLine = 0;
    local endLine = 0;

    local min = self:_itemLinePerView();

    if min < self._totalLine then 
        if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
            local itemHeight = self._itemPrototype:getContainerBox().height;

            local y = containerPos.y - self._yOffset - itemHeight;
            local downY = -self.viewRect_.height;

            for i = 1, self._totalLine do 
                if beginLine ~= 0 and endLine ~= 0 then 
                    break;
                end 
                if beginLine == 0 and y < 0 then 
                    beginLine = i;
                end 

                if endLine == 0 and (y + itemHeight) < downY then 
                    endLine = i - 1;
                end 

                y = y - itemHeight - self._ylineGap;
            end

            if endLine == 0 then 
                endLine = self._totalLine;
            end 

            if beginLine == 0 then 
                beginLine = 1;
            end 
        else 
            local itemWidth = self._itemPrototype:getContainerBox().width;

            local x = containerPos.x + self._xOffset + itemWidth;
            local rightX = self.viewRect_.width;

            for i = 1, self._totalLine do
                if beginLine ~= 0 and endLine ~= 0 then 
                    break;
                end 

                if beginLine == 0 and x > 0 then 
                    beginLine = i;
                end 

                if endLine == 0 and (x - itemWidth) > rightX then 
                    endLine = i - 1;
                end 

                x = x + itemWidth + self._xlineGap;
            end

            if endLine == 0 then 
                endLine = self._totalLine;
            end 
        end 

        if beginLine == 1 and endLine < self._totalLine and endLine < (beginLine + min) then 
            endLine = min;
        elseif endLine == self._totalLine and endLine > min then
            beginLine = endLine - min;
        end 
    else 
        beginLine = 1;
        endLine = self._totalLine;
    end 

    return beginLine, endLine;
end

--touch move中执行的
function GridView:scrollBy(x, y)
    self.position_.x, self.position_.y = 
        self:moveXY(self.position_.x, self.position_.y, x, y);

    local needCellIndexs = self:_needCellIndexs(self.position_);

    self:updateContainerCells(needCellIndexs);

    self.scrollNode:setPosition(self.position_);

    if self.actualRect_ then
        self.actualRect_.x = self.actualRect_.x + x
        self.actualRect_.y = self.actualRect_.y + y
    end
end

function GridView:_cellCreate()
    self._cellCreateNum = self._cellCreateNum + 1;
    --echo("cell create，total cell num is " .. tostring(self._cellCreateNum));
    local cell = UIBaseDef:createUIByName(self._itemClass);

    cell:setAnchorPoint(cc.p(0, 1));

    self:_addItemFunc(cell);
    cell:setScrollView(self);

    self._innerContainer:addChild(cell);
    return cell;
end

function GridView:deaccelerateScrolling()
    local curDis = nil;

    if UIScrollViewExpand.MAXMOVE < math.abs(self._scrollDistance) then 
        if self._scrollDistance > 0 then 
            curDis = UIScrollViewExpand.MAXMOVE;
        else 
            curDis = -UIScrollViewExpand.MAXMOVE;
        end 
    else 
        curDis = self._scrollDistance;
    end 
    
    local newPosXorY = nil;

    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        newPosXorY = self.position_.y + curDis;
    else 
        newPosXorY = self.position_.x + curDis;
    end 

    if (newPosXorY > self._max) or (newPosXorY < self._min) or (math.abs(curDis) < 1) then 
        if newPosXorY > self._max then 
            if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
                self.position_.y = self._max;
            else 
                self.position_.x = self._max;
            end 
        end 

        if newPosXorY < self._min then 
            if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
                self.position_.y = self._min;
            else 
                self.position_.x = self._min;
            end 
        end 

        local needCellIndexs = self:_needCellIndexs(self.position_);
        self:updateContainerCells(needCellIndexs);
        self.scrollNode:setPosition(self.position_);

        self:stopScrolling();

        return;
    end 

    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        self.position_.y = newPosXorY;  
    else 
        self.position_.x = newPosXorY;  
    end 
    
    local needCellIndexs = self:_needCellIndexs(self.position_);
    self:updateContainerCells(needCellIndexs);

    self.scrollNode:setPosition(self.position_);

    self._scrollDistance = self._scrollDistance * 0.8;
end


return GridView;


















