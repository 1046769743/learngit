--zhangqiang
--2018.3.20 

local MemoryCardInfoView = class("MemoryCardInfoView", UIBase);


function MemoryCardInfoView:ctor(winName)
    MemoryCardInfoView.super.ctor(self, winName);
end

--分辨率适配
function MemoryCardInfoView:uiAdjust()
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_latiao, UIAlignTypes.Right);


    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.LeftTop);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize, UIAlignTypes.LeftTop);
end
function MemoryCardInfoView:registerEvent()
    MemoryCardInfoView.super.registerEvent();

    -- 退出
    -- self.btn_back:setTap(c_func(self.close,self))
    -- -- 详情
    -- self.btn_guize:setTap(c_func(self.clickLabel,self))
end


function MemoryCardInfoView:loadUIComplete()
    self:registerEvent();
    self:uiAdjust()
end 



function MemoryCardInfoView:updateUI( cardId ,onlyShow)

    if not MemoryCardModel:checkCardCanShow(cardId) then
        self.txt_1:visible(true)
        return
    end
    self.txt_1:visible(false)
    local cardData = FuncMemoryCard.getMemoryCardDataById(cardId)

    local ctn_card = self.ctn_card
    local cardIconPath = FuncRes.memoryCardIcon( cardData.source )
    local cardIconSp = display.newSprite(cardIconPath)
    cardIconSp:scale(0.5)

    ctn_card:removeAllChildren()
    ctn_card:addChild(cardIconSp)

    -- 遮罩
    self.mc_img:showFrame(1)
    local items = cardData.pieceId
    for i = 1,8 do
        local chipId = items[i]
        local isLight = MemoryCardModel:checkChipLightById(chipId,cardId)
        if not isLight then
            local zhezhaoPath = FuncRes.memoryCardZhezhaoIcon( "memory_zhezhao1" )
            local zhezhaoSp = display.newSprite(zhezhaoPath)

            local ctn = self.mc_img.currentView["ctn_"..i]
            ctn:removeAllChildren()
            ctn:addChild(zhezhaoSp)

            local isHas = MemoryCardModel:checkHasChipById( chipId )
            if isHas then
                -- 可点亮的提示
                local tsSp = display.newSprite("icon/memory/2.png")
                ctn:addChild(tsSp)
            end

            if not onlyShow then
                zhezhaoSp:setTouchedFunc(c_func(self.lightChipTap,self,i,chipId))
            end
        else
            local ctn = self.mc_img.currentView["ctn_"..i]
            ctn:removeAllChildren()
        end
    end

end

-- 点亮操作
function MemoryCardInfoView:lightChipTap( index,chipId )
    local isHas = MemoryCardModel:checkHasChipById( chipId )
    if isHas then
        local ctn = self.mc_img.currentView["ctn_"..index]
        ctn:visible(false)
        MemoryCardModel:setChipLightById(chipId)
    else
        echo("没有此碎片===========")
    end
end

function MemoryCardInfoView:close()
    self:startHide()
end


return MemoryCardInfoView;