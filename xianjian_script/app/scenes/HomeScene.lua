--2015.07.31
--guanfeng 作废

local HomeScene = class("HomeScene", SceneBase);

function HomeScene:ctor()
    --初始化所有的model
    FuncServerData.initModel()

    HomeScene.super.ctor(self);
    --加载btns层
    self:loadHomeBtnsLayer()
    --加载主界面 大树什么的

end

function HomeScene:loadHomeBtnsLayer()
    local cfg = WindowsTools:getUiCfg("HomeBtnsLayer");
    local newPos = {x=cfg.pos.x + GameVars.UIOffsetX,
        y=cfg.pos.y - GameVars.UIOffsetY};
    local homeBtnsLayer = WindowsTools:createWindow("HomeBtnsLayer");
    homeBtnsLayer:setPosition(newPos);

    homeBtnsLayer:startShow();
    self._root:addChild(homeBtnsLayer, 0);
end

function HomeScene:loadTestBtns()

end

function HomeScene:onEnter()
    echo("HomeScene:onEnter call");
end

function HomeScene:onExit()
    echo("HomeScene:onExit call");
end

return HomeScene;


