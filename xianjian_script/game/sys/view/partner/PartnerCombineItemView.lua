--伙伴系统伙伴合成
--2016-12-10 15:18:50
--Author:xiaohuaxiong
local PartnerCombineItemView = class("PartnerCombineItemView",UIBase)

function PartnerCombineItemView:ctor(_winName)
    PartnerCombineItemView.super.ctor(self,_winName)
    self.showFrame = {
        [1] = 1,
        [2] = 2,
        [3] = 2,
        [4] = 1,
        [5] = 3,
    }
end

function PartnerCombineItemView:loadUIComplete()
    self:registerEvent()
end

-- data.partnerId 道具属于的伙伴
-- data.itemId 道具ID
-- data.num 道具数
-- data.frame 合成状态
-- data.isShowNum 是否显示数量 
function PartnerCombineItemView:setResource(data)
    echo("\n\n____________data.itemId,frame === ", data.itemId, data.frame)

    self.data = data
    self.itemData = FuncItem.getItemData(data.itemId)
    self.partnerId = data.partnerId
    self.itemType = data.frame
    local _frame = data.frame
    if _frame == 6 then
        _frame = 3
        self.itemType = 3
    end
    if _frame >= 4 then
        _frame = 1
    end

    if data.frame == 4 and ItemsModel:isItemCanGetByPve(data.itemId) then
        _frame = 5
    end

    self.mc_1:showFrame(self.showFrame[_frame])
    self.panel_red:setVisible(false)
    
    -- 判断是否是碎片
    if self.itemData.subType_display == 203 then

        self.mc_1:showFrame(4)
        self.txt_1:visible(false)
        self.mc_number:visible(true)
        -- self.mc_1.currentView.panel_1:visible(true)
        local needNum = FuncItem.getNumFrag(data.parentItemId,data.itemId)
        local hasNum = ItemsModel:getItemNumById(data.itemId)
        self.needNum = needNum

        
        local params = {
            itemId = data.itemId,
            resNum = hasNum,
        }
        self.mc_1.currentView.UI_1:setResItemData(params)
        self.mc_1.currentView.UI_1:showResItemNum(false)
        if hasNum >= needNum then
            self.mc_number:showFrame(1)
            FilterTools.clearFilter(self.mc_1.currentView.UI_1);
        else
            FilterTools.setViewFilter(self.mc_1.currentView.UI_1,FilterTools.colorMatrix_gray2)
            self.mc_number:showFrame(2)
        end
        self.mc_number.currentView.txt_1:setString(hasNum.."/"..needNum)

        self.mc_1.currentView:setTouchedFunc(c_func(function()
                    echo("---PartnerCombineItemView---获取材料的数量--------",self.needNum)
                    WindowControler:showWindow("GetWayListView", data.itemId,self.needNum);
                end, self))

    else
        -- 隐藏
        self.txt_1:visible(true)
        self.mc_number:visible(false)
        self.mc_1.currentView.panel_1:visible(false)
        
        local num = ItemsModel:getItemNumById(data.itemId)
        if data.isShowNum and num > 0 and self.itemType ~= 5 then
            self.txt_1:setString(num .. "/" .. 1)
            self.txt_1:visible(true)
        else
            self.txt_1:visible(false)
        end

        -- 道具品质
        -- echo("-------------------itemData-----------",itemData.id,itemData.quality)
        if data.frame == 2 or data.frame == 3 or data.frame == 4 then
            self.mc_1.currentView.mc_3:showFrame(7) 
        else
            self.mc_1.currentView.mc_3:showFrame(self.itemData.quality)
        end
        
        self.mc_1.currentView.mc_3.currentView.panel_1:visible(false)
        -- 图标
        local itemIcon = display.newSprite(FuncRes.iconItem(data.itemId)):anchor(0.5,0.5)
        -- itemIcon:setScale(1)
        local iconCtn = self.mc_1.currentView.mc_3.currentView.ctn_1
        iconCtn:removeAllChildren()
        iconCtn:addChild(itemIcon)

        self.mc_1.currentView.mc_3.currentView.ctn_1:visible(true)

        if self.itemType ~= 10 then
            local _touchFunc = function ( ... )
                self:openCombineUI(data)
            end   
            self.mc_1.currentView:setTouchedFunc(_touchFunc)
        end

        self:clearShangzhuangTishiAni()
        self:clearKeHeChengTishiAni()
        self:updateItemStatus(itemIcon)
    end
end

--根据当前的状态  显示不同的底框和特效 以及置灰状态  
function PartnerCombineItemView:updateItemStatus(itemIcon)
    if self.itemType == 2 then -- 可装备  
        self.panel_red:setVisible(true)
        self:addShangzhuangTishiAni()
        itemIcon:opacity(160)

        FilterTools.setGrayFilter(itemIcon)
        -- FilterTools.setViewFilter(self.mc_1.currentView.mc_3,FilterTools.colorMatrix_gray2)
    elseif self.itemType == 3 then -- 可合成
        self.panel_red:setVisible(true)
        self:addShangzhuangTishiAni()
        itemIcon:opacity(160)

        FilterTools.setGrayFilter(itemIcon)
        -- FilterTools.setViewFilter(self.mc_1.currentView.mc_3,FilterTools.colorMatrix_gray2)
    elseif self.itemType == 4 then -- 置灰
        itemIcon:opacity(160)
        if ItemsModel:isItemCanGetByPve(self.data.itemId) then
            self:addKeHeChengTishiAni()
        end
        FilterTools.setGrayFilter(itemIcon)
        -- FilterTools.setViewFilter(self.mc_1.currentView.mc_3,FilterTools.colorMatrix_gray2)
    else       
        itemIcon:opacity(255)

        FilterTools.clearFilter(itemIcon);
    end
end

function PartnerCombineItemView:playEatFoodMaterialAnim(data)
    self:addShangzhuangAni(data.pos, function ()
            self:setResource(data)
        end)
end

function PartnerCombineItemView:addShangzhuangAni(pos, callBack)
    local shangzhuangT = PartnerModel:getShengPinId(pos)
    if shangzhuangT and shangzhuangT.id then
        self:clearShangzhuangTishiAni()
        if pos == shangzhuangT.id and shangzhuangT.partnerId == self.partnerId then
            PartnerModel:cleanShengPinId(pos)
            if self.shangzhuangAnim then
                self.shangzhuangAnim:visible(true)
            else
                local shangzhuangAnim = self:createUIArmature("UI_huoban","UI_huoban_shengpin_zhuangdaoju", nil, false, GameVars.emptyFunc)
                self.ctn_shangzhuang:addChild(shangzhuangAnim)
                self.shangzhuangAnim = shangzhuangAnim
            end

            self.shangzhuangAnim:registerFrameEventCallFunc(15, 1, function ()
                    if callBack then
                        callBack()
                    end
                end)
            self.shangzhuangAnim:startPlay(false,true)
            self.shangzhuangAnim:doByLastFrame(false,false,function() 
                                        self.shangzhuangAnim:visible(false)
                                    end)
        else
            -- self.ctn_shangzhuang:removeAllChildren()
            if self.shangzhuangAnim then
                self.shangzhuangAnim:visible(false)
            end
        end
    end
end
function PartnerCombineItemView:clearShangzhuangTishiAni()
    -- self.ctn_tishi:removeAllChildren()
    if self.tishigAnim then
        self.tishigAnim:visible(false)
    end
end
function PartnerCombineItemView:clearKeHeChengTishiAni()
    -- self.ctn_tishi:removeAllChildren()
    if self.kehechengAnim then
        self.kehechengAnim:visible(false)
    end
end
function PartnerCombineItemView:addShangzhuangTishiAni()
    -- self.ctn_tishi:removeAllChildren()
    if self.tishigAnim then
        self.tishigAnim:visible(true)
    else
        local tishigAnim = self:createUIArmature("UI_huoban","UI_huoban_shengpin_keshiyongtishi", nil, true, GameVars.emptyFunc)
        self.ctn_tishi:addChild(tishigAnim)
        self.tishigAnim = tishigAnim
    end
    self.tishigAnim:startPlay(true,false)
    -- self.tishigAnim:doByLastFrame(false,false,function() self.tishigAnim:visible(false) end)
end
function PartnerCombineItemView:addKeHeChengTishiAni()
    -- self.ctn_tishi:removeAllChildren()
    if self.kehechengAnim then
        self.kehechengAnim:visible(true)
    else
        local kehechengAnim = self:createUIArmature("UI_huoban","UI_huoban_shengpin_kehecheng", nil, true, GameVars.emptyFunc)
        self.ctn_tishi:addChild(kehechengAnim)
        kehechengAnim:pos(8, -7)
        kehechengAnim:setScale(1.2)
        self.kehechengAnim = kehechengAnim
    end
    self.kehechengAnim:startPlay(true,false)
    -- self.tishigAnim:doByLastFrame(false,false,function() self.tishigAnim:visible(false) end)
end
--打开合成UI 
function PartnerCombineItemView:openCombineUI(_data)
    local _itemId = _data.itemId
    -- if _data.frame == 2 then
    --     local pos = PartnerModel:getUpqualityPosition(_itemId, self.partnerId);
    --     if pos >= 0 and pos < 4 then
    --         FuncPartner.playPartnerBtnSound()
    --         PartnerModel:setShengPinId(pos, self.partnerId)

    --         local posT = {}
    --         table.insert(posT, pos)
    --        -- PartnerModel:getQualityItemUsedCallBackData({ position = tostring(pos),partnerId = tostring(self.partnerId) ,_item = self.itemEquipId })
    --         if FuncPartner.isChar(tostring(self.partnerId)) then
    --             CharServer:qualityEquip({positions = posT})
    --         else  
    --             PartnerServer:qualityItemEquipRequest({positions = posT, partnerId = tostring(self.partnerId)})
    --         end
    --         FuncPartner.playPartnerShengPinPointSound( )
    --     else
    --         echoError("self.partnerId ======= ",self.partnerId)
    --         WindowControler:showTips("位置取得有问题")
    --     end
    --     return
    -- end
 
    local itemCfg = FuncItem.getItemData(_itemId)  
    if not itemCfg.cost and not itemCfg.fragmentId and self.data.frame ~= 2 then
        WindowControler:showWindow("GetWayListView", _itemId, 1)
    else
        if not WindowControler:checkCurrentViewName("PartnerUpQualityItemCombineView") then
            PartnerModel:clearCombine()
        end

        echo("\nPartnerModel:getCombineLastItemId()=-==", PartnerModel:getCombineLastItemId(), "_itemId==", _itemId)
        if PartnerModel:getCombineLastItemId() ~= _itemId then
            PartnerModel:addCombineItemId(_itemId,self.partnerId)
            local _id = PartnerModel:getCombineFirstItemId()
            Cache:set("qualityCombinePartnerId",self.partnerId)
            
            local _ui = WindowControler:showWindow("PartnerUpQualityItemCombineView", _id, tostring(self.partnerId));
            echo("_itemId ==== ",_itemId)
            _ui:initUI(_itemId)
        end
    end  
end

function PartnerCombineItemView:setTouchCallBack(_callBack)
    self.mc_1.currentView:setTouchedFunc(_callBack)
end
function PartnerCombineItemView:numVisible(show)
    self.txt_1:visible(show)
end

function PartnerCombineItemView:registerEvent()
    PartnerCombineItemView.super.registerEvent(self) 

end

return PartnerCombineItemView