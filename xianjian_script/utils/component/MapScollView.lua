--[[
    滚动地图控件
]]
local ScrollViewExpand = import(".ScrollViewExpand");

local MapScollView = class("MapScollView", ScrollViewExpand);

local STATE = {
    ["DISAPEAR"] = 1,
    ["APPEARCHANGE"] = 2,
    ["APPEAR"] = 3,
}

local DIR = {
    ["LEFT"] = 1,
    ["RIGHT"] = 2,
}

local MAXMOVE = 200;

local SPEED = 3;

function MapScollView:ctor(params)
    MapScollView.super.ctor(self, params);
    self._middleChapter = 1;
    self._dir = nil;
    self._middleChapterState = nil;
    self._preMiddleChapterState = nil;
end

function MapScollView:_calMaxXAndMinX()
    self._maxX = 0;
    self._minX = -(#self._chapters * 
        self._chapterSize.width - self.viewRect_.width);
    echo("self._maxX:" .. tostring(self._maxX) .. 
        " self._minX" .. tostring(self._minX));
end

--[[
    只有一个真的 ChapterTrue 放在第四章
]]
function MapScollView:createChapter(index)
    local sprite;
    if index == 4 then 
        sprite = WindowControler:createWindowNode("ChapterTrue");
        sprite:setAnchorPoint(cc.p(0, 1));
        sprite:setPosition(cc.p(0, 0));

    else 
        sprite = cc.Sprite:create(self._chapters[index]);
        sprite:setAnchorPoint(cc.p(0, 1));
        sprite:setPosition(cc.p(0, 0));

        for i = 1,300 do
            local c = display.newSprite("#txt_dujie.png");
            c:setPosition(cc.p((i + 1) * 2, 200));
            sprite:addChild(c);
        end

        for i = 1,300 do
            local c = display.newSprite("#txt_dujie.png");
            c:setPosition(cc.p((i + 1) * 2, 400));
            sprite:addChild(c);
        end
    end 

    return sprite;
end

function MapScollView:getContainer(chapters, chapterSize)
    local innerContainer = cc.Node:create();

    self._chapters = chapters;
    self._chapterSize = chapterSize;
    self._chapterPosMap = {};

    for i = 1, #chapters do    
        local node = cc.Node:create();
        node:setAnchorPoint(cc.p(0, 0));
        node:setPosition(cc.p((i - 1) * chapterSize.width, 0));
        node:setContentSize(chapterSize);

        innerContainer:addChild(node, 1, i);

        --计算 self._chapterPosMap
        local elementPos = {["left"] = (i - 1) * chapterSize.width, 
            ["right"] = i * chapterSize.width};
        table.insert(self._chapterPosMap, elementPos);
    end

    for i = 1, 3 do
        local sprite = self:createChapter(i);
        local node = innerContainer:getChildByTag(i);
        node:addChild(sprite);
    end

    self:_calMaxXAndMinX();

    --todo change 0
    self:_calMiddleChapterState(0);

    self._preMiddleChapterState = self._middleChapterState;
    return innerContainer;
end

function MapScollView:_calMiddleChapterState(x)
    self._preMiddleChapterState = self._middleChapterState;

    local elementPos = self._chapterPosMap[self._middleChapter];
    -- dump(elementPos);
    if ((x + elementPos.left) > self.viewRect_.width) or 
        ((x + elementPos.right) < 0) then 
         self._middleChapterState = STATE.DISAPEAR;
    elseif ((x + elementPos.left) <= 0) and 
        ((x + elementPos.right) >= self.viewRect_.width) then 
        self._middleChapterState = STATE.APPEAR;
    else 
        self._middleChapterState = STATE.APPEARCHANGE;
    end 
end

function MapScollView:onTouch_(event)
    if "began" == event.name and not self:isTouchInViewRect(event) then
        printInfo("UIScrollViewExpand - touch didn't in viewRect")
        return false
    end

    local localPos = self:convertToNodeSpace(cc.p(event.x, event.y)) 

    if "began" == event.name and self.touchOnContent then
        local cascadeBound = self:getScrollNodeToParentRect()
        if not cc.rectContainsPoint(cascadeBound, localPos) then
            return false
        end
    end

    if "began" == event.name then
        self:unscheduleUpdate();

        self.prevX_ = localPos.x
        self.prevY_ = localPos.y
        self.bDrag_ = false
        local x,y = self.scrollNode:getPosition()
        self.position_ = {x = x, y = y}

        transition.stopTarget(self.scrollNode)
        self:callListener_{name = "began", x = localPos.x, y = localPos.y}

        self:enableScrollBar()

        self.scaleToWorldSpace_ = self:scaleToParent_()

        return true
    elseif "moved" == event.name then
        if self:isShake(event) then
            return
        end

        self.bDrag_ = true

        local prevPos = self:convertToNodeSpace(cc.p(event.prevX, event.prevY))

        self.speed.x = localPos.x - prevPos.x
        self.speed.y = localPos.y - prevPos.y

        if (self.speed.x < 0) then 
            self._dir = DIR.RIGHT;
        else 
            self._dir = DIR.LEFT;
        end 

        if self.direction == 1 then
            self.speed.x = 0
        elseif self.direction == 2 then
            self.speed.y = 0
        else
            -- do nothing
        end

        self:scrollBy(self.speed.x, self.speed.y)

        self:callListener_{name = "moved", x = event.x, y = event.y}
    
    elseif "ended" == event.name then
        if self.bDrag_ then
            self.bDrag_ = false

            self:scrollAuto()
            
            self:callListener_{name = "ended", x = localPos.x, y = localPos.y}

            self:disableScrollBar()
        else
            self:callListener_{name = "clicked", x = localPos.x, y = localPos.y}
        end
    end
end

function MapScollView:scrollAuto()
    --注掉，不知是干什么的
    -- if self:isSideShow() then
    --     return false
    -- end
    
    if math.abs(self.speed.x) < 10 and math.abs(self.speed.y) < 10 then
        return false
    end

    local disX, disY = self:moveXY(0, 0, self.speed.x * SPEED, self.speed.y * SPEED);
    self._scrollDistanceX = disX;
    
    echo("scrollAuto self._scrollDistanceX:" .. tostring(self._scrollDistanceX));

    self:scheduleUpdateWithPriorityLua(handler(self, self.deaccelerateScrolling), 0);
end

function MapScollView:deaccelerateScrolling()
    local curDis = nil;

    if MAXMOVE < math.abs(self._scrollDistanceX) then 
        if self._scrollDistanceX > 0 then 
            curDis = MAXMOVE;
        else 
            curDis = -MAXMOVE;
        end 
    else 
        curDis = self._scrollDistanceX;
    end 

    local newx = self.position_.x + curDis;
    -- print("deaccelerateScrolling:" .. tostring(newx));
    if (newx > self._maxX) or (newx < self._minX) or (math.abs(curDis) < 1) then 
        if newx > self._maxX then --地图在第一张
            self.position_.x = self._maxX;
            self:_loadChapter(1);
            self._middleChapter = 1;
            self.scrollNode:setPosition(self.position_);
            echo("curDis:" .. tostring(curDis));
            echo("max");
            echo("newx:"..tostring(newx));
        end 

        if newx < self._minX then 
            self.position_.x = self._minX;
            self:_loadChapter(#self._chapters);
            self._middleChapter = #self._chapters;
            self.scrollNode:setPosition(self.position_);
            echo("curDis:" .. tostring(curDis));
            echo("min");
        end 

        self:unscheduleUpdate();
        return;
    end 

    -- self:_calMiddleChapterState(newx);
    -- self:_loadCheck();
    -- 有可能一下子跳到下下个章节，所以不能用上面注释中的方法
    local needChapter = self:currentNeedChapter(newx);

    function getMinAndMax(t)
        local min = 10000;
        local max = -1;
        for index, v in pairs(t) do
            if index > max then 
                max = index;
            end 

            if index < min then 
                min = index;
            end 
        end
        return min, max;
    end

    local leftChapter, rightChapter = getMinAndMax(needChapter);

    for index, v in pairs(needChapter) do
        self:_loadChapter(index);
    end

    if table.length(needChapter) == 1 then 
        self._middleChapter = leftChapter;
    else
        if self._dir == DIR.RIGHT then 
            self._middleChapter = leftChapter;
        else 
            self._middleChapter = rightChapter;
        end 
    end 
    -- print("middleChapter:" .. tostring(self._middleChapter));

    self:_calMiddleChapterState(newx);

    self._scrollDistanceX = self._scrollDistanceX * 0.8;
    self.position_.x = newx;

    self.scrollNode:setPosition(self.position_);

    self:_deleteOtherChapter();
end

--[[某个位置占用哪几个章节 最多2个
    return chapters = {
        [1] = true, -- 用到的章节index
        [2] = true, -- 用到的章节index
    }
]]
function MapScollView:currentNeedChapter(x)
    local chapters = {};
    local left = 0;
    local right = self.viewRect_.width;

    for i = 1, #self._chapters do
        local chapterLeft = x + self._chapterPosMap[i].left;
        local chapterRight = x + self._chapterPosMap[i].right;

        if ((chapterLeft <= left) and (chapterRight >= left)) or
            ((chapterLeft <= right) and (chapterRight >= right)) then 
            chapters[i] = true;
        end 

        if table.length(chapters) >= 2 then 
            return chapters;
        end 
    end

    return chapters;
end 

function MapScollView:scrollBy(x, y)
    local newx;
    local newy;
    newx, newy  = self:moveXY(self.position_.x, self.position_.y, x, y);

    if (newx > self._maxX) or (newx < self._minX) then 
        return;
    end 

    self:_calMiddleChapterState(newx);
    self:_loadCheck();

    -- dump(self:currentNeedChapter(newx));

    self.position_.x, self.position_.y = 
        self:moveXY(self.position_.x, self.position_.y, x, y);

    self.scrollNode:setPosition(self.position_)

    if self.actualRect_ then
        self.actualRect_.x = self.actualRect_.x + x
        self.actualRect_.y = self.actualRect_.y + y
    end
end

function MapScollView:_loadChapter(index)
    local node = self.innerContainer:getChildByTag(index);
    if node:getChildrenCount() == 0 then 
        --创建 章节

        local sprite = self:createChapter(index);
        
        echo("创建章节：" .. tostring(index));
        node:addChild(sprite);
    end  
end 

function MapScollView:testLogShowMiddleChapter()
    echo("当前中心章节是:" .. tostring(self._middleChapter));
end

function MapScollView:_loadCheck()
    if self._dir == DIR.RIGHT then 
        if self._middleChapterState ~= self._preMiddleChapterState then 
            if self._middleChapterState == STATE.APPEARCHANGE then 
                echo("向 右 出现新章节");
                self:_loadChapter(self._middleChapter + 1);
                self:testLogShowMiddleChapter();
            elseif self._middleChapterState == STATE.DISAPEAR then 
                echo("向 右 章节消失");
                self._middleChapter = self._middleChapter + 1;
                self:_deleteOtherChapter();
                self:testLogShowMiddleChapter();

            end 
        end 
    else 
        if self._middleChapterState ~= self._preMiddleChapterState then 
            if self._middleChapterState == STATE.APPEARCHANGE then 
                echo("向 左 出现新章节");
                self:_loadChapter(self._middleChapter - 1);
                self:testLogShowMiddleChapter();

            elseif self._middleChapterState == STATE.DISAPEAR then 
                echo("向 左 章节消失");
                self._middleChapter = self._middleChapter - 1;
                self:_deleteOtherChapter();
                self:testLogShowMiddleChapter();
            end 
        end 
    end 
end 

function MapScollView:_deleteOtherChapter()
    local inIndexs = {};
    inIndexs[self._middleChapter] = true;
    if self._middleChapter == 1 then 
        inIndexs[self._middleChapter + 1] = true;
        inIndexs[self._middleChapter + 2] = true;
    elseif self._middleChapter == #self._chapters then 
        inIndexs[self._middleChapter - 1] = true;
        inIndexs[self._middleChapter - 2] = true;
    else 
        inIndexs[self._middleChapter + 1] = true;
        inIndexs[self._middleChapter - 1] = true;
    end 

    local childs = self.innerContainer:getChildren();

    for i = 1, #self._chapters do
        local node = self.innerContainer:getChildByTag(i);
        if inIndexs[i] ~= true and node:getChildrenCount() ~= 0 then 
            node:removeAllChildren();
            echo("删除章节:" .. tostring(i));
            cc.Director:getInstance():getTextureCache():removeTextureForKey(self._chapters[i]);
            cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(self._chapters[i]);
        end 
    end
end

function MapScollView:deleteAllCache()
    for i = 1, #self._chapters do
        cc.Director:getInstance():getTextureCache():removeTextureForKey(self._chapters[i]);
        cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(self._chapters[i]);
    end 
end

return MapScollView;











