local CompShopItemView = class("CompShopItemView", UIBase)
local COST_TO_MC_INDEX = {
	[FuncDataResource.RES_TYPE.COIN] = 1,
	[FuncDataResource.RES_TYPE.DIAMOND] = 2,
	[FuncDataResource.RES_TYPE.ARENACOIN] = 3,
	[FuncDataResource.RES_TYPE.CHIVALROUS] = 5,

    [FuncDataResource.RES_TYPE.CIMELIACOIN] = 7,
    [FuncDataResource.RES_TYPE.DIMENSITY] = 8,
    [FuncDataResource.RES_TYPE.GUILDCOIN] = 10, 
    [FuncDataResource.RES_TYPE.XIANFU] = 11, 
}
function CompShopItemView:ctor(winName, dataForDisplay, index,globalIndex,aniId,isUnlocdk)
	CompShopItemView.super.ctor(self, winName)
	--itemData:
	--:itemId
	--:num
	--:costInfo
	--:soldOut
	--:itemIndex
    -- dump(dataForDisplay, "\n\ndataForDisplay===")
	self.itemData = dataForDisplay
	self.index = index
    self.shopId = dataForDisplay.shopId
    self.globalIndex=globalIndex;--
    self.aniId=aniId;--
    self.itemData.isLocked = false
end

function CompShopItemView:loadUIComplete()
	self:registerEvent()
    self.panel_qp:setVisible(false)
    self.panel = self.btn_1:getUpPanel().panel_1
    self.panel.panel_grl.mc_time:setVisible(false)
    -- self.mc_quality= self.panel.mc_di;
    -- self.mc_quality:showFrame(self.globalIndex<=4 and self.globalIndex or 4);
    -- if self.globalIndex > 1 then
    --     _panel.mc_coin:setPositionX(2)
    --     _panel.UI_1:setPositionX(82)
    -- else
    --     _panel.mc_coin:setPositionX(22)
    --     _panel.UI_1:setPositionX(102)
    -- end
    self.panel.panel_grl.panel_condition:setVisible(false)
    -- _panel.mc_coin:setPositionX(22)
    -- _panel.panel_grl.UI_1:setPositionX(102)
    -- self.panel_quality=self.mc_quality.currentView;
	self:showSoldOutMark()
	self:updateUI()
end

function CompShopItemView:registerEvent()
	EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.onUserModelUpdate, self)

    EventControler:addEventListener(ShopEvent.SHOPEVENT_BUY_ITEM_END,self.onUserModelUpdate,self);
    EventControler:addEventListener(ShopEvent.OPEN_ANIM_END, self.setQipaoVisible, self)
end

function CompShopItemView:setQipaoVisible()
    local _itemId = self.itemData.itemId
    local isShow, tips = FuncShop.isQiPaoVisibleById(_itemId)
    local isSoldOut = self.itemData.soldOut
    local isLocked = self.itemData.isLocked
    -- echo("\n\n_________-setQipaoVisible________", _itemId, isShow, isSoldOut, isLocked)
    if isShow and not isSoldOut and not isLocked then
        self.panel_qp:setVisible(true)
        self.panel_qp:setScale(0)
        local random_index = RandomControl.getOneRandomInt(#tips + 1, 1)
        local showTip = GameConfig.getLanguage(tips[random_index])
        self.panel_qp.txt_1:setString(showTip)
        if not self.isActing then
            local seqAct = cc.Sequence:create(act.scaleto(0.5, 0.6, 0.8),
                                         act.delaytime(1.5),
                                         act.scaleto(0.3, 0, 0),
                                         act.delaytime(2))
            self.panel_qp:runAction(act._repeat(seqAct))
            self.isActing = true
        end
        
    else
        self.panel_qp:setVisible(false)
    end   
end

function CompShopItemView:onUserModelUpdate(_params)
--    self.itemData.soldOut=ShopModel:isSomeItemSoldOut(self.itemData.shopId,tostring(self.itemData.shopGoodsId));
    if(_params.params~=nil) and _params.params.itemId == self.itemData.itemId then
        self.itemData.soldOut=_params.params.soldOut;
    end
	self:setCostInfo()
    self:setQipaoVisible()
end

function CompShopItemView:updateUI()
    if not self.itemData then return end

    self:setItemView()
    self:setCostInfo()
    self:setItemNameAndNum()
    self:showSoldOutMark()
    self:setLeftCorerMark()
    self:updateLockShow()
    
    local flagString = self.itemData.specials;
    local genAni = false;
    if (flagString) then
        for _index = 1, #flagString do
            if (tonumber(flagString[_index]) == self.aniId) then
                genAni = true;
            end
        end
    end
    local panel = self.panel;
    panel.panel_grl.ctn_s:removeAllChildren();
    panel.panel_grl.ctn_s2:removeAllChildren()
    if (genAni) then
        local _effectType = {
            [1] = {
                "UI_shop_yuanshangceng", 
                "UI_shop_yuanxiaceng", 
                "UI_shop_yuansaoguang",
                },
            [2] ={
                "UI_shop_fangshangceng",
                "UI_shop_fangxiaceng",
                "UI_shop_fangsaoguang",
                },
            [3] ={
                    "UI_shop_lenshangceng",
                    "UI_shop_lenxiaceng",
                    "UI_shop_lensaoguang",
                 },
        }
        local ani = self:createUIArmature("UI_shop", _effectType[self.itemData.effectType][2], panel.panel_grl.ctn_s, true, GameVars.emptyFunc);--ÏÂ²ã
        self:createUIArmature("UI_shop",_effectType[self.itemData.effectType][1],panel.panel_grl.ctn_s2,true,GameVars.emptyFunc) 
        self:createUIArmature("UI_shop",_effectType[self.itemData.effectType][3],panel.panel_grl.ctn_s2,true,GameVars.emptyFunc) 
    end

    if ShopModel:getOpenAnimStatus() then
        self:setQipaoVisible()
    end
end
function CompShopItemView:updateLockShow()
    local panel = self.panel
    ---[[加了一个if语句的判断，单独处理仙盟商店的数据]]  --wk
    if self.shopId == FuncShop.SHOP_TYPES.GUILD_SHOP then
        self:guildIsUnlock()
    elseif self.shopId == FuncShop.SHOP_TYPES.PVP_SHOP then
        self:pvpShopItemIsUnlock()
    elseif self.shopId == FuncShop.SHOP_TYPES.TOWER_SHOP then
        self:towerIsUnlock()
    elseif self.shopId == FuncShop.SHOP_TYPES.WONDER_SHOP then
        self:wonderShopItemIsUnlock()
    else
        self.isUnlock,self.unLockStr = ShopModel:checkItemByIndexAndShopId( self.shopId,self.index )
        if self.isUnlock then
            panel.panel_grl.panel_suo:visible(false)
        else
            panel.panel_grl.panel_suo:visible(true)
            panel.panel_grl.scale9_3:visible(true)
            panel.panel_grl.panel_s1:showFrame(6)
            panel.panel_grl.panel_s1.currentView.txt_1:setString(self.unLockStr)
        end
    end
end

--判断仙盟商店道具是否解锁 --wk
function CompShopItemView:guildIsUnlock()

    local panel = self.panel
    local isUnlock,unLockStr = ShopModel:getGuildItemUnlock(self.index)
    if isUnlock then
        panel.panel_grl.panel_suo:visible(false)
        panel.panel_grl.panel_s1:visible(true)
        panel.panel_grl.panel_condition:visible(false)
    else
        panel.panel_grl.panel_suo:visible(true)
        panel.panel_grl.scale9_3:visible(true)
        panel.panel_grl.panel_s1:setVisible(false)
        panel.panel_grl.panel_condition:setVisible(true)
        panel.panel_grl.panel_condition.txt_1:setString(unLockStr)
        -- showFrame(6)
        -- panel.mc_1.currentView.txt_1:setString(unLockStr)
    end
end

function CompShopItemView:pvpShopItemIsUnlock()
    local panel = self.panel
    local isUnlock,unLockStr = ShopModel:getPvpShopItemUnLock(self.index)
    if isUnlock then
        panel.panel_grl.panel_suo:visible(false)
        panel.panel_grl.panel_s1:visible(true)
        panel.panel_grl.panel_condition:visible(false)
    else
        panel.panel_grl.panel_suo:visible(true)
        panel.panel_grl.scale9_3:visible(true)
        panel.panel_grl.panel_s1:setVisible(false)
        panel.panel_grl.panel_condition:setVisible(true)
        panel.panel_grl.panel_condition.txt_1:setString(unLockStr)
        -- showFrame(6)
        -- panel.mc_1.currentView.txt_1:setString(unLockStr)
        self.itemData.isLocked = true
    end
end

--判断锁妖塔商品是否解锁
function CompShopItemView:towerIsUnlock()
    local panel = self.panel
    local isUnlock,unLockStr = ShopModel:checkIsTowerShopItemUnlock(self.index)
    echo("___isUnlock,unLockStr________",isUnlock,unLockStr)
    if isUnlock then
        panel.panel_grl.panel_suo:visible(false)
        panel.panel_grl.panel_s1:visible(true)
        panel.panel_grl.panel_condition:visible(false)
    else
        panel.panel_grl.panel_suo:visible(true)
        panel.panel_grl.scale9_3:visible(true)
        panel.panel_grl.panel_s1:setVisible(false)
        panel.panel_grl.panel_condition:setVisible(true)
        panel.panel_grl.panel_condition.txt_1:setString(unLockStr)
        -- showFrame(6)
        -- panel.mc_1.currentView.txt_1:setString(unLockStr)
        self.itemData.isLocked = true
    end
end

function CompShopItemView:wonderShopItemIsUnlock()
    local panel = self.panel
    local isUnlock,unLockStr = ShopModel:getWonderShopItemUnlock(self.index)
    if isUnlock then
        panel.panel_grl.panel_suo:visible(false)
        panel.panel_grl.panel_s1:visible(true)
        panel.panel_grl.panel_condition:visible(false)
    else
        panel.panel_grl.panel_suo:visible(true)
        panel.panel_grl.scale9_3:visible(true)
        panel.panel_grl.panel_s1:setVisible(false)
        panel.panel_grl.panel_condition:setVisible(true)
        panel.panel_grl.panel_condition.txt_1:setString(unLockStr)
        -- showFrame(6)
        -- panel.mc_1.currentView.txt_1:setString(unLockStr)
        self.itemData.isLocked = true
    end
end

function CompShopItemView:setLeftCorerMark()
	local contentPanel = self.panel
	local label = self.itemData.label
	if not label then
		contentPanel.mc_tuijian:visible(false)
	else
		contentPanel.mc_tuijian:visible(true)
		contentPanel.mc_tuijian:showFrame(tonumber(label))
	end
end

function CompShopItemView:setItemNameAndNum()
    local itemName = ""
    local quality = 1
    if self.itemData.itemType == FuncDataResource.RES_TYPE.ITEM then
        itemName = FuncItem.getItemName(tostring(self.itemData.itemId))
        quality = FuncItem.getItemQuality(self.itemData.itemId)
    elseif self.itemData.itemType == FuncDataResource.RES_TYPE.USERHEADFRAME then
        itemName = FuncUserHead.getHeadFrameName(tostring(self.itemData.itemId))
        quality = FuncDataResource.getQualityById(self.itemData.itemType)
    else
        quality = FuncDataResource.getQualityById(self.itemData.itemType)
    end
    local num = self.itemData.num
	local itemStr = string.format("%s", itemName, num)

	local contentPanel = self.panel

--	contentPanel.txt_1:setString(itemStr)
--    local  itemData=FuncItem.getItemData(self.itemData.itemId);
--    if(itemData.type==2)then
--          contentPanel.mc_coin:showFrame(6);
--          contentPanel.mc_coin.currentView.txt_1:setString(itemStr);
--    else
--         contentPanel.mc_coin:showFrame(itemData.quality);
--         contentPanel.mc_coin.currentView.txt_1:setString(itemStr);
--    end

    -- 目前策划要求全部用没效果的颜色
    contentPanel.panel_cshang.mc_coin:showFrame(6);
    contentPanel.panel_cshang.mc_coin.currentView.txt_1:setString(itemStr);
end

function CompShopItemView:setCostInfo()
	local contentPanel = self.panel
	local panel_cost = contentPanel.panel_grl.panel_s1
	local costInfo = self.itemData.costInfo
    local needNums,hasNums,isEnough,resType = UserModel:getResInfo(costInfo)
    local index = COST_TO_MC_INDEX[tostring(resType)]
	panel_cost.mc_1:showFrame(index)
    local width = FuncCommUI.getStringWidth(needNums, 26)
	if needNums > hasNums then
        panel_cost.mc_2:showFrame(2)
        panel_cost.mc_2.currentView.txt_1:setString(needNums)
	else
		panel_cost.mc_2:showFrame(1)
        panel_cost.mc_2.currentView.txt_1:setString(needNums)
	end

    panel_cost:setPositionX(71 - (width - 40) / 2)
end


function CompShopItemView:setItemView()
	local ui_item = self.panel.panel_grl.UI_1
	if ui_item then
        local data = {
            itemId = self.itemData.itemId,
            itemNum = self.itemData.num,
            itemType = self.itemData.itemType
        }
        ui_item:setItemData(data)
	end
end

function CompShopItemView:setItemData(data)
	self.itemData = data
end

function CompShopItemView:getItemIndex()
	return self.itemData.itemIndex or 1
end

function CompShopItemView:showSoldOutMark()
	local show = self.itemData.soldOut or false
	local contentPanel = self.panel
	contentPanel.panel_grl.scale9_3:visible(show)
	contentPanel.panel_grl.panel_2:visible(show)
end

function CompShopItemView:playSoldOutAnim()
	self:zorder(self:getLocalZOrder()+100-self.index)
	local contentPanel = self.panel
	local ctn = contentPanel.panel_grl.ctn_2
	local soldOutPanel = contentPanel.panel_grl.panel_2
	local grayScale9 = contentPanel.panel_grl.scale9_3
	grayScale9:visible(true)
	local anim = self:createUIArmature("UI_common", "UI_common_shouqing", ctn, false, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(anim, "layer1", soldOutPanel)
	soldOutPanel:pos(0,0)
end


function CompShopItemView:setOpenAnim(index, _shopId)
    local arr = {
        [1] = 20,
        [2] = 14,
        [3] = 20,
        [4] = 20,
        [5] = 14,
        [6] = 20,
    }
    if index <= 6 then
        self.panel.panel_grl:setVisible(false)
        self.panel.mc_tuijian:setVisible(false)
        self.panel.panel_cshang:setVisible(false)
        self.panel.panel_cxia:setVisible(false)
        self.panel.panel_grl:pos(-118, 45.6)
        self.panel.mc_tuijian:pos(0, 0)
        self.panel.panel_cxia:pos(0.8, 0)
        self.panel.panel_cshang:pos(-123.5, 13.5)
        local delayShow = function ()
            local itemAnim = self:createUIArmature("UI_shangdian", "UI_shangdian_05", self.panel.ctn_anim, true)
            FuncArmature.changeBoneDisplay(itemAnim, "layer3", self.panel.panel_cshang)
            FuncArmature.changeBoneDisplay(itemAnim, "layer2", self.panel.panel_cxia)
            FuncArmature.changeBoneDisplay(itemAnim, "layer6", self.panel.panel_grl)
            -- FuncArmature.changeBoneDisplay(itemAnim, "layer9", self.panel.mc_tuijian)
            itemAnim:startPlay(false, true)
        end
        
        self:delayCall(c_func(delayShow), arr[index] / GameVars.GAMEFRAMERATE)
    end
end

function CompShopItemView:close()
	self:startHide()
end

return CompShopItemView
