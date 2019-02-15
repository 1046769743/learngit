--
-- autor: pangkangning
-- Date: 2017.11.23
-- 战斗中换灵界面

local BattleHuanLingView = class("BattleHuanLingView", UIBase)

function BattleHuanLingView:loadUIComplete()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self,UIAlignTypes.RightTop)

    self._elementBtn = {} --换灵对应的五属性
    self._elementG = {} --拖拽的换灵图标
    self:visible(false)
    if not self.huanlingAnim then
        self.huanlingAnim = self:createUIArmature("UI_zhandoud", "UI_zhandoud_huanling",self.panel_lafu.btn_huanling,true,GameVars.emptyFunc)
    end
    self.huanlingAnim:visible(false)
    self._clickType = false
end
function BattleHuanLingView:initControler(battleView,controler )
    self._battleView = battleView
    self.controler = controler
    for i=1,5 do
        local btn = UIBaseDef:cloneOneView(self.panel_lafu.panel_1["btn_"..i])
        btn:pos(0,0)
        FuncArmature.changeBoneDisplay(self.huanlingAnim,"node"..i, btn)
        self._elementBtn[i] = btn
        self:getDragFunc(btn:getUpPanel().panel_1,i)--:getUpPanel()
    end
    self.panel_lafu.btn_huanling:setTap(c_func(self.clickHuanLing,self),nil,true)
end
-- 点击换灵按钮
function BattleHuanLingView:clickHuanLing( )
    self.huanlingAnim:visible(true)
    if not self._clickType then
        self._clickType = true
        self.huanlingAnim:playWithIndex(0,0)
    else
        self._clickType = false
        self.huanlingAnim:playWithIndex(2,0)
    end
end

-- 换灵取消的方法
function BattleHuanLingView:cancelChangeElement()
    for _,element in pairs(self._elementG) do
        if element then
            element:moveBack()
        end
    end
end

function BattleHuanLingView:setChangeElementVisible(value)
    self:visible(value)
    self.panel_lafu.panel_1:visible(false)
    -- if not value then
    --     self.huanlingAnim:visible(false)
    -- end
    for i,btn in ipairs(self._elementBtn) do
        btn:visible(value)
    end
end

-- 换灵拖动的方法
function BattleHuanLingView:getDragFunc(parent,element)
    local nd = nil
    local clickOffset = nil
    local limitY = nil
    local function pressClickViewDown(event)

        local targetX = event.x
        local targetY = event.y
        -- 转换坐标
        local pNode = self.controler.layer:getGameCtn(2)
        local ttPos = cc.p(targetX,targetY)
        -- parent:convertLocalToNodeLocalPos(pNode,cc.p(targetX,targetY))
        local initpos = parent:getParent():convertLocalToNodeLocalPos(pNode,cc.p(parent:getPosition()))

        local dx = targetX *Fight.cameraWay - initpos.x 
        local dy = initpos.y-targetY

        clickOffset = cc.p(dx,dy)

        limitY = {initpos.y,570}
        
        local dropView = UIBaseDef:cloneOneView(self.panel_lafu.panel_1["btn_"..element]:getUpPanel().panel_1)
        -- 创建一个实例
        nd = ModelElement.new(self.controler, 1, initpos,dropView)
        table.insert(self._elementG, nd)

        -- 置灰其他按钮
        for idx,btn in ipairs(self._elementBtn) do
            if idx ~= element then
                FilterTools.setGrayFilter(btn)
            else
                FilterTools.clearFilter(btn)
            end
        end
    end

    local function pressClickViewMove(event)
        if not nd or not clickOffset then return end
        if not nd:canMove() then return end
        local targetX = event.x*Fight.cameraWay - clickOffset.x
        local targetY = event.y + clickOffset.y
        -- nd:setPos(targetX,targetY)

        local x,y = targetX,-targetY


        local camp = BattleControler:getTeamCamp()
        if camp == Fight.camp_1 then
            x = math.max(self.controler.middlePos  - GameVars.width/2 + 10,x)
            x = math.min(self.controler.middlePos,x)
        else
            x = math.max(self.controler.middlePos  - 10 ,x)
            x = math.min(self.controler.middlePos  + GameVars.width/2,x)
        end
        y = math.max(limitY[1],y)
        y = math.min(Fight.buzhen_max,y)

        nd:setPos(x,y,0)
    end

    local function pressClickViewUp(event)
        if not nd or not clickOffset then return end
        if not nd:canMove() then return end
        -- 判断位置使用或者飞回
        -- 判断落在哪个区域

        local camp = BattleControler:getTeamCamp()
        local heroObj,posIndex = self.controler:getAreaTargetByPos(camp,nd.pos.x,nd.pos.y)
        if posIndex ~= 0 then
            self.controler.server:sendChangeElementHandle({
                element = element,
                round = self.controler.logical.roundCount,
                pos = posIndex,
                camp = camp,
            })
            nd:deleteMe()
        else
            nd:moveBack()
        end

        -- 恢复所有置灰
        for idx,btn in ipairs(self._elementBtn) do
            FilterTools.clearFilter(btn)
        end

        nd = nil
        clickOffset = nil
    end

    parent:setTouchedFunc(GameVars.emptyFunc,nil,true,
        pressClickViewDown,pressClickViewMove,false,pressClickViewUp)
end


return BattleHuanLingView