--guan 2016.10.24

local LayerColorExpand = class("LayerColorExpand", function ( )
    return display.newNode();
end)

function LayerColorExpand:ctor(color)
    echo("---LayerColorExpand---");
    self._color = color;
    self._whiteNode = display.newSprite("a/a1_4.png")
    -- self._whiteNode:setContentSize(cc.size(1, 1));

    self._nativeSize = self._whiteNode:getContentSize();

    -- dump(self._nativeSize, "---self._nativeSize---");

    self._whiteNode:setColor(color);
    self._whiteNode:setAnchorPoint(cc.p(0, 0));
    self._whiteNode:setOpacity(color.a);

    self:addChild(self._whiteNode);

    self:setTouchSwallowEnabled(true);
end

function LayerColorExpand:setContentSize(size)
    -- dump(size, "====LayerColorExpand:setContentSize====");

    -- self._whiteNode:setScaleX(size.width / self._nativeSize.width);
    -- self._whiteNode:setScaleY(size.height / self._nativeSize.height);
    self._whiteNode:size(size);
    self._size = size;
end

function LayerColorExpand:getContentSize()
    if self._size == nil then 
        return cc.size(1, 1);
    else 
        return self._size;
    end 
end

function LayerColorExpand:anchor(x, y)
    self._whiteNode:setAnchorPoint( cc.p(x, y) );
    self:setAnchorPoint( cc.p(x, y) );
end

-- 不好用……
-- function LayerColorExpand:setAnchorPoint(point)
    -- self._whiteNode:setAnchorPoint(point);
    -----要加个  self:setAnchorPoint(point); 可是这样就递归了
-- end


------------======= start =========---------------
--下层有LayerColor，释放spine 报错，改下cc.LayerColor.create
--把下面的注释掉，就用原生的 cc.LayerColor 了

-- cc.LayerColor.nativeCreate = cc.LayerColor.create;

-- cc.LayerColor.create = function (self, color)
--     return LayerColorExpand.new(color);
-- end

------------======= end =========---------------


return LayerColorExpand;
