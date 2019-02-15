--zhangqiang
--2018.4.8

local MemoryCardInfoThrView = class("MemoryCardInfoThrView", UIBase);


function MemoryCardInfoThrView:ctor(winName)
    MemoryCardInfoThrView.super.ctor(self, winName);
end

--分辨率适配
function MemoryCardInfoThrView:uiAdjust()
end
function MemoryCardInfoThrView:registerEvent()
    MemoryCardInfoThrView.super.registerEvent();
end


function MemoryCardInfoThrView:loadUIComplete()
    self:registerEvent();
    self:uiAdjust()
end 



function MemoryCardInfoThrView:updateUI( cardId,index )

    if not MemoryCardModel:checkCardCanShow(cardId) then
        self.mc_1:showFrame(1)
        return
    end

    self.mc_1:showFrame(2)
    
    local cardData = FuncMemoryCard.getMemoryCardDataById(cardId)

    local cardPanel = self.mc_1.currentView.panel_1

    -- self:setRotation3D({x= -15,y =0,z=0})
    -- if index == 1 then
    --     self:setRotation(2)
    -- elseif index == 2 then
    --     self:setRotation(-2)
    -- elseif index == 3 then
    --     self:setRotation(-3)
    -- end
    
    local viewTransform = cardData.view
    if viewTransform then
        self:scale(viewTransform[1]/100)
        self:setRotation3D({x=viewTransform[2],y=viewTransform[3],z=viewTransform[4]})

        self:setRotation(viewTransform[5])
        self:pos(viewTransform[6],viewTransform[7])
    else
        

    end



    local cardZZ = self.mc_1.currentView.panel_1.mc_img
    local ctn_card = cardPanel.ctn_card
    local attrTxt = self.mc_1.currentView.txt_1
    local typeMc = self.mc_1.currentView.mc_1

    

    local cardIconPath = FuncRes.memoryCardIcon( cardData.source )
    local cardIconSp = display.newSprite(cardIconPath)
    cardIconSp:setScaleX(0.6)
    cardIconSp:setScaleY(0.6)

    ctn_card:removeAllChildren()
    ctn_card:addChild(cardIconSp)

    -- 遮罩
    cardZZ:showFrame(1)
    local items = cardData.pieceId
    for i = 1,6 do
        local chipId = items[i]
        local isLight = MemoryCardModel:checkChipLightById(chipId,cardId)
        local _panel = cardZZ.currentView.panel_1["panel_"..i]

        local ctnEff = cardZZ.currentView.panel_1["ctn_"..i]
        ctnEff:removeAllChildren()
        if not isLight then
            _panel:visible(true)
            local isHas = MemoryCardModel:checkHasChipById( chipId )
            
            if isHas then
                -- 可点亮的提示
                _panel:visible(false)
                local effectName,nodeName = self:getEffectName( i )
                local effAnim = self:createUIArmature("UI_qingjingka",effectName, nil, true, GameVars.emptyFunc)
                
                effAnim:getBoneDisplay(nodeName):visible(false)
                ctnEff:addChild(effAnim)
            end
        -- else
        --     _panel:visible(false)
        end
    end

    -- -- 属性
    local attrT = FuncMemoryCard.getCardAttrById(cardId)
    local attrStr = ""
    for i,v in pairs(attrT) do
        local value = v.value
        if v.mode == 2 then
            value = (v.value/100).."%"
        end
        attrStr = attrStr .. v.name .. "+" .. value .. "  "
    end
    local _typeFrame = tonumber(cardData.target[1]) + 1
    typeMc:showFrame(_typeFrame)
    attrTxt:setString(attrStr)

    local isJiHuo = MemoryCardModel:checkCardFinishJiHuo(cardId)
    if isJiHuo then
        for i = 1,6 do
            cardZZ.currentView.panel_1["ctn_"..i]:removeAllChildren()
            cardZZ.currentView.panel_1["panel_"..i]:visible(false)
        end
    end
end

function MemoryCardInfoThrView:getEffectName( index )
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

function MemoryCardInfoThrView:close()
    self:startHide()
end


return MemoryCardInfoThrView;