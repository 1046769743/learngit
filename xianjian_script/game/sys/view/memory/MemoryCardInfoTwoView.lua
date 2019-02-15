--zhangqiang
--2018.3.20 

local MemoryCardInfoTwoView = class("MemoryCardInfoTwoView", UIBase);


function MemoryCardInfoTwoView:ctor(winName)
    MemoryCardInfoTwoView.super.ctor(self, winName);
    -- self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
    --     local result = self:onTouch_(event)
    --     return result or false
    -- end)
end

function MemoryCardInfoTwoView:onTouch_( event )
    local panel = self.mc_img.currentView.panel_1
    local point = panel:convertToNodeSpace(cc.p(event.x,event.y))
    if not self.cardId then
        return
    end
    local pointsArr = {}
    local cardData = FuncMemoryCard.getMemoryCardDataById(self.cardId)
    for i=1,6 do
        local points = cardData["a"..i]
        local pointT = {}
        for ii,vv in pairs(points) do
            local t = string.split(vv,",")
            for m = 1,#t do
                t[m] = tonumber(t[m])
            end
            table.insert(pointT,t)
        end
        table.insert(pointsArr,pointT)
    end
    local num = MemoryCardModel:getAreaByPos(point.x,point.y, pointsArr)

    echo("选中 第几个 == ",num)

    local chipId = cardData.pieceId[num]
    if chipId then
        if not MemoryCardModel:checkChipLightById(chipId,self.cardId) then
            self:lightChipTap( num,chipId )
        end
    end
end

--分辨率适配
function MemoryCardInfoTwoView:uiAdjust()
    

end
function MemoryCardInfoTwoView:registerEvent()
    MemoryCardInfoTwoView.super.registerEvent();

    -- 退出
    -- self.btn_back:setTap(c_func(self.close,self))
    -- -- 详情
    -- self.btn_guize:setTap(c_func(self.clickLabel,self))
end


function MemoryCardInfoTwoView:loadUIComplete()
    self:registerEvent();
    self:uiAdjust()
end 



function MemoryCardInfoTwoView:updateUI( cardId ,onlyShow)
    self.cardId = cardId
    self.onlyShow = onlyShow
    local ctn_card = self.ctn_card
    ctn_card:removeAllChildren()

    self.mc_img:showFrame(1)
    -- self.mc_img.currentView.panel_1:setTouchedFunc(c_func(self.onTouch_,self))

    local cardData = FuncMemoryCard.getMemoryCardDataById(cardId)

    
    local cardIconPath = FuncRes.memoryCardIcon( cardData.source )
    local cardIconSp = display.newSprite(cardIconPath)
    cardIconSp:setScaleX(0.6)
    cardIconSp:setScaleY(0.6)

    
    ctn_card:addChild(cardIconSp)

    -- 遮罩
    
    local items = cardData.pieceId
    for i = 1,6 do
        local chipId = items[i]
        local isLight = MemoryCardModel:checkChipLightById(chipId,cardId)
        local _panel = self.mc_img.currentView.panel_1["panel_"..i]
        local ctnEff = self.mc_img.currentView.panel_1["ctn_"..i]
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
        else
            _panel:visible(false)
        end
    end
    local isJiHuo = MemoryCardModel:checkCardFinishJiHuo(cardId)
    if isJiHuo then
        for i = 1,6 do
            self.mc_img.currentView.panel_1["ctn_"..i]:removeAllChildren()
            self.mc_img.currentView.panel_1["panel_"..i]:visible(false)
        end
    end
end

function MemoryCardInfoTwoView:getEffectName( index )
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

-- 点亮操作
function MemoryCardInfoTwoView:lightChipTap( index,chipId )
    local isHas = MemoryCardModel:checkHasChipById( chipId )
    if isHas then
        local _panel = self.mc_img.currentView.panel_1["panel_"..index]
        _panel:visible(false)
        local ctnEff = self.mc_img.currentView.panel_1["ctn_"..index]
        ctnEff:removeAllChildren()
        MemoryCardModel:setChipLightById(chipId)
    else
        -- WindowControler:showTips(GameConfig.getLanguage("#tid_memory_016"))
        local methodTips = FuncMemoryCard.getMethodString( self.cardId )
        WindowControler:showTips(methodTips)
    end
end

function MemoryCardInfoTwoView:close()
    self:startHide()
end


return MemoryCardInfoTwoView;