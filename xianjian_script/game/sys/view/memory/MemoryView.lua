
--剧情宝箱需要
local MemoryView = class("MemoryView", UIBase);


function MemoryView:ctor(winName, cardId, closeCallFunc)
    MemoryView.super.ctor(self, winName);
    self.cardId = tostring(cardId)
    self.closeCallFunc = closeCallFunc -- 关闭界面时调用的方法
end

function MemoryView:registerEvent()
    MemoryView.super.registerEvent(self);
    -- self:registClickClose(-1, c_func( function()
    --     self:close()
    -- end , self))
end

function MemoryView:loadUIComplete()
    self:registerEvent();
    -- self:disabledUIClick()
    self.mc_img:showFrame(1)

    -- --初始化更新ui
    -- self.panel_baoxxx:setVisible(false)
    self.showAni = self:createUIArmature("UI_qingjingka","UI_qingjingka_juanzhoudakai", self.ctn_anim, false,GameVars.emptyFunc)

    FuncArmature.changeBoneDisplay(self.showAni, "node1", self.mc_img.currentView.panel_1["panel_1"])
    FuncArmature.changeBoneDisplay(self.showAni, "node2", self.mc_img.currentView.panel_1["panel_2"])
    FuncArmature.changeBoneDisplay(self.showAni, "node3", self.mc_img.currentView.panel_1["panel_3"])
    FuncArmature.changeBoneDisplay(self.showAni, "node4", self.mc_img.currentView.panel_1["panel_4"])
    FuncArmature.changeBoneDisplay(self.showAni, "node5", self.mc_img.currentView.panel_1["panel_5"])
    FuncArmature.changeBoneDisplay(self.showAni, "node6", self.mc_img.currentView.panel_1["panel_6"])
    FuncArmature.changeBoneDisplay(self.showAni, "node01", self.ctn_card)

    self.showAni:playWithIndex(0,false)
    -- self.showAni:startPlay(false, true)
    
    self:delayCall(function ()
        self:removeChild(self.node)
        self.node = display.newNode()
        self.node:setContentSize(cc.size(1400,768))
        self.node:pos(-130,-700)
        self.node:anchor(0,0)
        self.node:addto(self,1)
        self.node:setTouchEnabled(true)
        self.node:setTouchedFunc(c_func(self.close,self))
        self:updateCtnEff()
    end,1.5)
    self:updateUI()
end 


function MemoryView:updateUI()

    local ctn_card = self.ctn_card
    ctn_card:removeAllChildren()

    -- self.mc_img:showFrame(1)
    -- self.mc_img.currentView.panel_1:setTouchedFunc(c_func(self.onTouch_,self))

    -- 配的假的数据 为了在1-1章节弹出一个全部遮住的弹窗 特殊处理
    if self.cardId == "1000" then
        echo("============== 1000   特殊处理 ==============")
        for i = 1,6 do
            local name = "node"..i
            local anim = self.showAni:getBone("node"..i)
            anim:setVisible(true)
            -- local ctnEff = self.mc_img.currentView.panel_1["ctn_"..i]
            -- local effectName,nodeName = self:getEffectName( i )
            -- local effAnim = self:createUIArmature("UI_qingjingka",effectName, nil, true, GameVars.emptyFunc)  
            -- effAnim:getBoneDisplay(nodeName):visible(false)
            -- ctnEff:addChild(effAnim)
        end
    else
        local cardData = FuncMemoryCard.getMemoryCardDataById(self.cardId)
        local cardIconPath = FuncRes.memoryCardIcon( cardData.source )
        local cardIconSp = display.newSprite(cardIconPath)
        cardIconSp:setScaleX(0.6)
        cardIconSp:setScaleY(0.6)
        ctn_card:addChild(cardIconSp)
        -- 遮罩
        local items = cardData.pieceId
        echo("============== 正常逻辑 ==============")
        for i = 1,6 do
            local chipId = items[i]
            local isLight = MemoryCardModel:checkChipLightById(chipId,self.cardId)
            -- local _panel = self.mc_img.currentView.panel_1["panel_"..i]
            -- local ctnEff = self.mc_img.currentView.panel_1["ctn_"..i]
            -- ctnEff:removeAllChildren()
            if not isLight then
                -- _panel:visible(false)
                local isHas = MemoryCardModel:checkHasChipById( chipId )
                if isHas then
                    echo("-------------隐藏板子-------------")
                    -- 可点亮的提示
                    -- _panel:visible(false)
                    -- self.showAni:getBone("node"..i):visible(false)
                    local name = "node"..i
                    local anim = self.showAni:getBone("node"..i)
                    -- echo("anim===",anim,tolua.type(anim))
                    anim:setVisible(false)
                    -- anim:pause()

                    -- anim:setVisible(false)
                    -- echo("anim=",anim,type(anim))
                    -- self.showAni:visibleBone(name)
                    -- self.showAni:setVisible(false)
                    -- local effectName,nodeName = self:getEffectName( i )
                    -- local effAnim = self:createUIArmature("UI_qingjingka",effectName, nil, true, GameVars.emptyFunc)  
                    -- effAnim:getBoneDisplay(nodeName):visible(false)
                    -- ctnEff:addChild(effAnim)
                end
            -- else
            --     _panel:visible(false)
            end
        end
    end
end

function MemoryView:updateCtnEff()
    -- 配的假的数据 为了在1-1章节弹出一个全部遮住的弹窗 特殊处理
    if self.cardId == "1000" then
        for i = 1,6 do
            -- local _panel = self.mc_img.currentView.panel_1["panel_"..i]
            -- _panel:visible(true)
            local ctnEff = self.mc_img.currentView.panel_1["ctn_"..i]
            local effectName,nodeName = self:getEffectName( i )
            local effAnim = self:createUIArmature("UI_qingjingka",effectName, nil, true, GameVars.emptyFunc)  
            effAnim:getBoneDisplay(nodeName):visible(false)
            ctnEff:addChild(effAnim)
        end
    else
        local cardData = FuncMemoryCard.getMemoryCardDataById(self.cardId)
        -- 遮罩
        local items = cardData.pieceId
        for i = 1,6 do
            local chipId = items[i]
            local isLight = MemoryCardModel:checkChipLightById(chipId,self.cardId)
            -- local _panel = self.mc_img.currentView.panel_1["panel_"..i]
            local ctnEff = self.mc_img.currentView.panel_1["ctn_"..i]
            ctnEff:removeAllChildren()
            if not isLight then
                -- _panel:visible(true)
                local isHas = MemoryCardModel:checkHasChipById( chipId )

                if isHas then
                    -- 可点亮的提示
                    -- _panel:visible(false)
                    local effectName,nodeName = self:getEffectName( i )
                    local effAnim = self:createUIArmature("UI_qingjingka",effectName, nil, true, GameVars.emptyFunc)  
                    effAnim:getBoneDisplay(nodeName):visible(false)
                    ctnEff:addChild(effAnim)
                end
            -- else
            --     _panel:visible(false)
            end
        end
    end
end

function MemoryView:getEffectName( index )
    local effectName = ""
    local nodeName = "node1"
    if index == 1 then
        effectName = "UI_qingjingka_ka2"
    elseif index == 2 then
        effectName = "UI_qingjingka_ka3"
    elseif index == 3 then
        effectName = "UI_qingjingka_ka1"
    elseif index == 4 then
        effectName = "UI_qingjingka_ka6"
    elseif index == 5 then
        effectName = "UI_qingjingka_ka4"
    elseif index == 6 then
        effectName = "UI_qingjingka_ka5"
    end

    return effectName,nodeName
end


function MemoryView:close()
    for i = 1,6 do
        self.mc_img.currentView.panel_1["ctn_"..i]:removeAllChildren()
    end
    self.showAni:playWithIndex(2)
    self:removeChild(self.node)
    self:delayCall(function ()
        if self.closeCallFunc then
            self.closeCallFunc()
        end
        self:startHide()
    end,1.7)
end


return MemoryView;