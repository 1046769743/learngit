local ItemListView = class("ItemListView", UIBase);

function ItemListView:ctor(winName)
    ItemListView.super.ctor(self, winName);
end

function ItemListView:loadUIComplete()
    self:initData()
    self:registerEvent();

    self:initUI()

    self:initScrollCfg()
    local curTagType = ItemsModel:getSelectedType() or self.selectTagType.TAG_TYPE_ALL
    self:updateUI(curTagType)
end 

function ItemListView:registerEvent()
    ItemListView.super.registerEvent();
    self.btn_back:setTap(c_func(self.press_btn_back, self));

    -- 监听item选择事件
    EventControler:addEventListener(ItemEvent.ITEMEVENT_CLICK_ITEM_VIEW,self.onClickItemView,self);

    local tagPanel = self.panel_1
    self.tagPanel = tagPanel

    tagPanel.mc_yeqian1.currentView:setTouchedFunc(c_func(ItemListView.pressItemTag, self, self.selectTagType.TAG_TYPE_ALL));
    tagPanel.mc_yeqian2.currentView:setTouchedFunc(c_func(ItemListView.pressItemTag, self, self.selectTagType.TAG_TYPE_BOX));
    tagPanel.mc_yeqian3.currentView:setTouchedFunc(c_func(ItemListView.pressItemTag, self, self.selectTagType.TAG_TYPE_MATERIAL));
    tagPanel.mc_yeqian4.currentView:setTouchedFunc(c_func(ItemListView.pressItemTag, self, self.selectTagType.TAG_TYPE_PIECE));
    -- tagPanel.mc_yeqian5.currentView:setTouchedFunc(c_func(ItemListView.pressItemTag, self, self.selectTagType.TAG_TYPE_ARTIFACT));
    tagPanel.mc_yeqian1.currentView:setTouchSwallowEnabled(true);
    tagPanel.mc_yeqian2.currentView:setTouchSwallowEnabled(true);
    tagPanel.mc_yeqian3.currentView:setTouchSwallowEnabled(true);
    tagPanel.mc_yeqian4.currentView:setTouchSwallowEnabled(true);
    -- tagPanel.mc_yeqian5.currentView:setTouchSwallowEnabled(true);
    -- 道具更新消息
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.updateItems, self)
    -- 合成等成功返回消息
    EventControler:addEventListener(TreasureEvent.TREASURE_COMBINE_EVENT, self.onActionSuccess, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT, self.updateItemDetail, self)
end

-- 初始化数据
function ItemListView:initData()
    self.selectAnimCache = {}

    -- 页签类别
    self.selectTagType = {
        TAG_TYPE_ALL = 1,       --全部
        TAG_TYPE_BOX = 2,       --宝箱
        TAG_TYPE_MATERIAL = 3,  --材料
        TAG_TYPE_PIECE = 4,     --碎片
        -- TAG_TYPE_ARTIFACT = 5,     --神器
    }

    self.selectSubType = {
        TAG_SUBTYPE_UPQUALITY = 1,
        TAG_SUBTYPE_EQUIPMENT = 2,    --这个是装备升品材料
        TAG_SUBTYPE_ARTIFACT = 3,
        TAG_SUBTYPE_FIVESOUL = 4,
        TAG_SUBTYPE_QIXIA = 5,
        TAG_SUBTYPE_TREASURE = 6,
        TAG_SUBTYPE_MATERIAL = 7,
        TAG_SUBTYPE_EQUIPMENT_FRAGMENT = 8,   --这个是装备碎片
    }

    --材料类下方 子页签
    self.map_selectSubType1 = {
        [1] = "TAG_SUBTYPE_UPQUALITY",
        [2] = "TAG_SUBTYPE_EQUIPMENT",
        [3] = "TAG_SUBTYPE_ARTIFACT",
        [4] = "TAG_SUBTYPE_FIVESOUL",
    }

    --碎片类下方  子页签
    self.map_selectSubType2 = {
        [1] = "TAG_SUBTYPE_QIXIA",
        [2] = "TAG_SUBTYPE_TREASURE",
        [3] = "TAG_SUBTYPE_MATERIAL",
        [4] = "TAG_SUBTYPE_EQUIPMENT_FRAGMENT"
    }

    --材料类下方 子页签对应的名字
    self.selectSubTypeName1 = {
        [1] = "tid_up_157",
        [2] = "tid_up_158",
        [3] = "tid_up_131",
        [4] = "tid_up_159",
    }

    --碎片类下方  子页签对应的名字
    self.selectSubTypeName2 = {
        [1] = "tid_up_160",
        [2] = "tid_up_133",
        [3] = "tid_up_161",
        [4] = "tid_up_158",
    }
    --[[
    self.itemSubTypes_New = {
        ITEM_SUBTYPE_100 = 100,         --宝箱(可以打开的道具)
        ITEM_SUBTYPE_201 = 201,         --法宝碎片
        -- ITEM_SUBTYPE_305 = 305,         --法宝万能碎片
        ITEM_SUBTYPE_202 = 202,         --奇侠碎片
        -- ITEM_SUBTYPE_203 = 203,          --主角星魂碎片
        ITEM_SUBTYPE_203 = 203,         --其他碎片，在背包系统可以直接合成的一种碎片
        ITEM_SUBTYPE_312 = 312,         --神器
        -- ITEM_SUBTYPE_402 = 402,         --神器升级
        ITEM_SUBTYPE_310 = 310,         --升品
        ITEM_SUBTYPE_311 = 311,         --装备
    }]]

    self.itemType = ItemsModel.itemType
    self.itemSubTyes = ItemsModel.itemSubTypes_New
    -- dump(self.itemSubTyes, "\n\nself.itemSubTyes")
    -- 全部item展示类别顺序
    self.itemOrderList = {
        self.itemType.ITEM_TYPE_COST,
        self.itemType.ITEM_TYPE_MATERIAL,
        self.itemType.ITEM_TYPE_PIECE,
        -- self.itemType.ITEM_TYPE_ARTIFACT,
    }

    -- 获取道具所有子类别
    self.itemSubType = ItemsModel:getAllItemSubTypes()
    -- dump(self.itemSubType, "\n\nself.itemSubTye=")
    -- 当前选择的itemId
    self.curSelectItemId = nil
    -- 页签总数量
    self.tagNum = 4
    -- 打开宝箱数量
    self.openBoxNum = 10
    -- 是否是初始化
    self.isInit = true
    -- 是否正在开宝箱
    self.isOpeningBox = false

    ShopModel:getGuildModelData()
end

-- 初始化滚动配置
function ItemListView:initScrollCfg()
    -- 创建道具item
    local createItemFunc = function ( itemData )
        local view = WindowsTools:createWindow("CompResItemView")
        self:setItemViewData(view,itemData)
        return view
    end

    -- 道具item的更新方法
    local updateItemFunc = function(itemData,itemView)
        self:setItemViewData(itemView,itemData)
        return itemView
    end

    -- -------------------------------------------------------
    -- 创建碎片item
    local createPieceItemFunc = function(itemData)
        local view = WindowsTools:createWindow("CompResItemView")
        self:setItemViewData(view,itemData)
        -- view:setQualityScale(0.8)
        return view
    end

    -- 碎片item的更新方法
    local updatePieceItemFunc = function(itemData,itemView)
        self:setItemViewData(itemView,itemData)
        return itemView
    end
    -- -------------------------------------------------------

    -- 创建道具分割线itemLine
    -- self.itemLineView:setVisible(false)
    -- local createItemLineFunc = function ( itemData )
    --     local view = UIBaseDef:cloneOneView(self.itemLineView)
    --     return view
    -- end

    -- 创建途径滚动区上部分
    local mcGoods = self.mc_goodxq
    mcGoods:showFrame(2)
    local panelGoods = mcGoods.currentView.panel_xq1
    local createScrollFunc = function ( itemData )
        local mcGundong =  panelGoods.mc_gundong

        -- 是否隐藏合成按钮
        if self:needHideActionBtn() then
            mcGundong:showFrame(2)
        else
            mcGundong:showFrame(1)
        end

        -- todo
        -- local panelScroll = mcGundong.currentView.panel_gundong
        local panelScroll = mcGundong.currentView.panel_title
        panelScroll:setVisible(false)

        local view = UIBaseDef:cloneOneView(panelScroll)
        self:setScrollDetail(view,itemData)
        return view
    end

    -- 创建途径item
    local panelGoods = mcGoods.currentView.panel_xq1
    
    local createGetWayItemFunc = function (itemData)
        local mcGundong =  panelGoods.mc_gundong
        -- 是否隐藏合成按钮
        if self:needHideActionBtn() then
            mcGundong:showFrame(2)
        else
            mcGundong:showFrame(1)
        end

        -- 隐藏模板获取途径itemView
        local panelGetWay = panelGoods.mc_gundong.currentView.panel_tujing
        panelGetWay:setVisible(false)

        local view = UIBaseDef:cloneOneView(panelGetWay)
        local scrollList = mcGundong.currentView.scroll_list

        view.UI_1:setGetWayItemData(itemData,scrollList)

        return view
    end

    -- itemList 滚动配置，根据道具类型，动态生成
    self.__listParams = {

    }

    -- itemView参数配置
    self.itemViewParams = {
        data = nil,
        itemRect = {x=0,y=-89,width = 98,height = 98},
        createFunc = createItemFunc,
        perNums= 5,
        offsetX = 15,
        offsetY = 5,
        widthGap = 4,
        heightGap = 8,
        perFrame = 1,
        updateCellFunc = updateItemFunc,
        cellWithGroup = 1
    }

    -- 碎片间距不同，单独配置
    -- itemPieceView参数配置
    self.itemPieceViewParams = {
        data = nil,
        itemRect = {x=0,y=-98,width = 98,height = 98},
        createFunc = createPieceItemFunc,
        perNums= 5,
        offsetX = 15,
        offsetY = 12,
        widthGap = 4,
        heightGap = 8,
        perFrame = 1,
        updateCellFunc = updatePieceItemFunc,
        cellWithGroup = 1
    }

    --[[
    -- item分割线参数配置
    self.itemLineParams = {
        data = {""},
        createFunc = createItemLineFunc,
        itemRect = {x=0,y=-11,width = 384,height = 11},
        perNums= 1,
        offsetX = 26,
        offsetY = 8,
        widthGap = 7,
        heightGap = 0,
        perFrame = 1,
        updateCellFunc = GameVars.emptyFunc,
        cellWithGroup = 2
    }
    --]]

    self.__getWaylistParams = {
        {
            data = self.getWayListData,
            createFunc = createGetWayItemFunc,
            itemRect = {x=8,y=0,width = 372,height = 59},
            perNums= 1,
            offsetX = 20,
            offsetY = 6,
            widthGap = 0,
            heightGap = 6,
            perFrame = 4
        },
    }
end

-- 初始化UI
function ItemListView:initUI()
    -- FuncArmature.loadOneArmatureTexture("UI_common", nil, true)

    --分辨率适配
    -- --关闭按钮右上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop) 
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop) 
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res,UIAlignTypes.RightTop)
    -- FuncCommUI.setScale9Align(self.widthScreenOffset,self.UI_1.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
    -- 页签适配
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_left.panel_1,UIAlignTypes.LeftTop,0.7) 

    self.mc_beibaonei:showFrame(1)
    -- 道具列表滚动区
    self.scrollItemList = self.mc_beibaonei.currentView.panel_goodskuang1.scroll_list
    -- 分割线
    -- self.itemLineView = self.panel_left.mc_beibaonei.currentView.panel_goodskuang1.panel_1
    -- 默认隐藏道具详情
    self.mc_goodxq:setVisible(false)
    -- self.scrollItemList:setPositionY(20)
    -- self.scrollItemList:keepDragBar()
    -- self.scrollItemList:enableMarginBluring();
end

-- 切换背包页签
function ItemListView:pressItemTag(tagType)
    if self.curTagType == tagType then
        return
    end
    self.curSubTagType = nil
    ItemsModel:setSelectedType(tagType)
    self:updateUI(tagType, self.curSubTagType)
end

-- 更新所有UI
function ItemListView:updateUI(tagType, tagSubType)
    --修改当前tagType
    self.curTagType = tagType
    -- 当前选择的道具类型
    self.curItemType = self:getItemTypeByTagType(self.curTagType) 
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_item34006")) 
    self:showItemsByTagType(tagType)

    if tagType == 3 then
        self.mc_nx:setVisible(true)
        self.mc_nx:showFrame(#self.selectSubTypeName1)
        local panel = self.mc_nx.currentView
        for i = 1, #self.selectSubTypeName1 do 
            panel["panel_"..tostring(i)].panel_1.panel_1:setVisible(false)         
            panel["panel_"..tostring(i)].txt_1:setString(GameConfig.getLanguage(self.selectSubTypeName1[i]))
            local _key = self.map_selectSubType1[i]
            panel["panel_"..tostring(i)]:setTouchedFunc(c_func(self.pressSubTypeTag, self, self.selectSubType[_key])) 
        end
    elseif tagType == 4  then
        self.mc_nx:setVisible(true)
        self.mc_nx:showFrame(#self.selectSubTypeName2)
        local panel = self.mc_nx.currentView
        for i = 1, #self.selectSubTypeName2 do
            panel["panel_"..tostring(i)].panel_1.panel_1:setVisible(false) 
            panel["panel_"..tostring(i)].txt_1:setString(GameConfig.getLanguage(self.selectSubTypeName2[i]))
            local _key = tostring(self.map_selectSubType2[i])
            panel["panel_"..tostring(i)]:setTouchedFunc(c_func(self.pressSubTypeTag, self, self.selectSubType[_key]))
        end      
    else
        self.mc_nx:setVisible(false)
    end

    self:updateTagStatus(tagType)
    if tagSubType then
        self:pressSubTypeTag(tagSubType)
    end
end

-- 切换背包子类型
function ItemListView:pressSubTypeTag(tagSubType)
    local panel = self.mc_nx.currentView
    local _tagSubType = tonumber(tagSubType) <= #self.selectSubTypeName1 and tagSubType or (tagSubType - #self.selectSubTypeName1)
    local _curSubTagType
    if self.curSubTagType ~= nil then
        _curSubTagType = tonumber(self.curSubTagType) <= #self.selectSubTypeName1 and self.curSubTagType or (self.curSubTagType - #self.selectSubTypeName1)
    end
    
    if _curSubTagType == nil then
        self.curSubTagType = tagSubType        
        panel["panel_"..tostring(_tagSubType)].panel_1.panel_1:setVisible(true)
    else
        self.curSubTagType = tagSubType
        panel["panel_"..tostring(_curSubTagType)].panel_1.panel_1:setVisible(false)
        panel["panel_"..tostring(_tagSubType)].panel_1.panel_1:setVisible(true)
    end

    self:showItemsByTagSubType(tagSubType)
    self:updateTagSubTypeStatus(tagSubType)
end

-- 更新道具明细
function ItemListView:onClickItemView(event)
    local itemId = event.params.itemId
    self.curSelectItemId = itemId

    self:updateItemDetail()
end

-- 更新右侧道具明细
function ItemListView:updateItemDetail()
    if self.curSelectItemId == nil then
        return 
    end
    
    local itemId = self.curSelectItemId
    local item = ItemsModel:getItemById(itemId)
    local itemData = FuncItem.getItemData(itemId)
    local itemDesc = GameConfig.getLanguage(itemData.des)
    local itemNum = item:num()

    local mcGoods = self.mc_goodxq
    mcGoods:setVisible(true)
    local panelGoods = nil

    -- 如果选择的是宝箱
    if ItemsModel:isBox(itemId) then
        mcGoods:showFrame(1)
        panelGoods = mcGoods.currentView.panel_xq1

        self:setBoxBtnAction(panelGoods,itemId,itemNum)
    elseif ItemsModel:isOptionBox(itemId) then
        mcGoods:showFrame(1)
        panelGoods = mcGoods.currentView.panel_xq1

        self:setOptionBoxBtnAction(panelGoods,itemId,itemNum)
    else
        mcGoods:showFrame(2)
        panelGoods = mcGoods.currentView.panel_xq1

        -- 获取途径滚动条条初始化
        local getWayListData
        --五灵珠类型需要特殊处理  获取途径的列表需要动态生成
        -- if itemData.subType_display == self.itemSubTyes.ITEM_SUBTYPE_314 then
        --     getWayListData = ItemsModel:creatDynamicAccess(itemData.subType_display, itemId, itemData.accessWay)
        -- else
            getWayListData = itemData.accessWay
        -- end
        -- 更新获取途径滚动条
        self:updateGetWayListView(panelGoods,getWayListData,itemData)

        local mcGundong =  panelGoods.mc_gundong
        -- 是否隐藏合成按钮
        if self:needHideActionBtn() then
            mcGundong:showFrame(2)
        else
            mcGundong:showFrame(1)
            self:updateBtnAction(mcGundong,itemData)
        end
    end

    -- 道具名字
    local txtItemName = self:getItemNameTxt(panelGoods,itemId)
    txtItemName:setString(GameConfig.getLanguage(itemData.name))

    -- 道具数量
    panelGoods.txt_shuzhi1:setString(GameConfig.getLanguageWithSwap("tid_common_1002",itemNum))

    -- 道具描述
    if panelGoods.txt_djmiaoshu ~= nil then
        panelGoods.txt_djmiaoshu:setString(itemDesc)
    end

    -- 更新Item图标框
    local  data = {
        itemId=itemId,
        itemNum=itemNum,
    }
    -- panelGoods.UI_goods:setItemData(item,ITEM_VIEW_TYPE.TYPE_ITEM_LIST_DETAIL_VIEW,self)
    panelGoods.UI_goods:setResItemData(data)
    panelGoods.UI_goods:showResItemNum(false)
end

-- 设置按钮显示状态及按钮响应行为
function ItemListView:updateBtnAction(mcGundong,itemData)
    local itemId = itemData.id
    local itemSubType = itemData.subType_display

    -- 设置动作按钮显示状态
    self:updateItemActionBtnStatus(mcGundong.currentView.mc_qitabtn,itemId,itemSubType)
    -- 设置按钮响应行为
    mcGundong.currentView.mc_qitabtn.currentView:setTouchedFunc(c_func(ItemListView.doItemAction, self, itemId,itemSubType));
end

-- 获取道具名字文本框
function ItemListView:getItemNameTxt(panelGoods,itemId)
    local itemData = FuncItem.getItemData(itemId)
    local itemType = itemData.type

    -- 道具名字
    local mcItemName = panelGoods.mc_daojuming

    -- if itemType == self.itemType.ITEM_TYPE_PIECE then
    --     -- 碎片固定为第7帧
    --     mcItemName:showFrame(7)
    -- else
    mcItemName:showFrame(itemData.quality or 1)
    -- end

    local txtItemName = mcItemName.currentView.txt_daojuming
    return txtItemName
end

-- 设置开宝箱按钮
function ItemListView:setBoxBtnAction(panelGoods,itemId,itemNum)
    local boxActionMc = panelGoods.mc_1

    -- 开十个按钮
    local btnOpenTen = nil
    -- 打开按钮
    local btnOpen = nil

    local openTenFunc = function()
        self:openBoxes(itemId,ItemsModel.boxType.TYPE_BOX_NUM_TEN,itemNum)
    end

    local openFunc = function()
        self:openBoxes(itemId,ItemsModel.boxType.TYPE_BOX_NUM_ONE,itemNum)
    end

    if tonumber(itemNum) > 1 then
        boxActionMc:showFrame(1)
        btnOpenTen = boxActionMc.currentView.btn_kaishigebtn
        btnOpen = boxActionMc.currentView.btn_dakaibtn

        btnOpenTen:setTap(c_func(openTenFunc, self));

        local showBoxNum = ItemsModel.boxType.TYPE_BOX_NUM_TEN 
        if itemNum < ItemsModel.boxType.TYPE_BOX_NUM_TEN then
            showBoxNum = itemNum
        end

        local btnTxt = GameConfig.getLanguageWithSwap("tid_bag_1003",showBoxNum)
        btnOpenTen:setBtnStr(btnTxt,"txt_ten")
    else
        boxActionMc:showFrame(2)
        btnOpen = boxActionMc.currentView.btn_dakaibtn
    end

    -- 设置按钮红点状态
    self:setBoxBtnRedPointStatus(boxActionMc,itemId,itemNum)
    btnOpen:setTap(c_func(openFunc, self));
end

-- 设置可选宝箱按钮
function ItemListView:setOptionBoxBtnAction(panelGoods,itemId,itemNum)
    local boxActionMc = panelGoods.mc_1

    boxActionMc:showFrame(2)
    local btnOpen = boxActionMc.currentView.btn_dakaibtn
    btnOpen:getUpPanel().panel_red:setVisible(false)
    btnOpen:setTouchedFunc(c_func(self.openOptionBox, self, itemId, itemNum))
end

-- 打开选择奖励窗口
function ItemListView:openOptionBox(itemId, itemNum)
    WindowControler:showWindow("ItemOptionView", itemId, itemNum)
end

-- 设置打开按钮红点状态
function ItemListView:setBoxBtnRedPointStatus(boxActionMc,itemId,itemNum)
    local btnOpen = boxActionMc.currentView.btn_dakaibtn
    local btnOpenTen = boxActionMc.currentView.btn_kaishigebtn

    -- 初始隐藏红点
    btnOpen:setBtnChildVisible("panel_red", false)
    -- btnOpenTen可能会没有
    if btnOpenTen then
        btnOpenTen:setBtnChildVisible("panel_red", false)
    end

    -- 如果不显示红点,如药水等会忽略显示红点
    if not ItemsModel:showRedPoint(itemId) then
        return
    end

    -- 宝箱数量大于等于10个，打开10个按钮显示红点
    -- if tonumber(itemNum) >= self.openBoxNum then
    --     if btnOpenTen then
    --         btnOpenTen:setBtnChildVisible("panel_red", true)
    --     end
    -- else
    --     btnOpen:setBtnChildVisible("panel_red", true)
    -- end
end

-- 更新明细的滚动条
function ItemListView:updateGetWayListView(panelGoods,getWayListData,itemData)
    if getWayListData == nil then
        -- 如果没有获取途径，设置默认第一个为空
        getWayListData = {""}
    end

    -- 更新获取途径列表
    -- 获取途径id降序排
    -- 以策划配置顺序为准，屏蔽排序
    -- ItemsModel:sortGetWayListData(getWayListData)
    self.__getWaylistParams[1].data = getWayListData

    local mcGundong =  panelGoods.mc_gundong
    -- 是否隐藏操作按钮
    if self:needHideActionBtn() then
        mcGundong:showFrame(2)
    else
        mcGundong:showFrame(1)
    end

    local getWayScrollList = mcGundong.currentView.scroll_list
    getWayScrollList:cancleCacheView()
    getWayScrollList:styleFill(self.__getWaylistParams)
    getWayScrollList:gotoTargetPos(1,1,0,false)

    self.getWayScrollList = getWayScrollList
end

-- 是否隐藏操作按钮
function ItemListView:needHideActionBtn()
    -- 当前碎片对应的法宝已经拥有
    local treasure = TreasureNewModel:getTreasureData(self.curSelectItemId)
    
    local result = false
    -- 拥有该法宝，无法合成
    if treasure ~= nil then
        result = true
    else
        local itemData = FuncItem.getItemData(self.curSelectItemId)
        local hideBtn = FuncItem.getItemActionValue(itemData.subType_display,"hideBtn")

        if hideBtn and tonumber(hideBtn) == 1 then
            result = true
        else
            result = false
        end
    end

    return result
end

-- 道具修炼、强化、进阶
function ItemListView:doItemAction(itemId,itemSubType)
    local mcGoods = self.mc_goodxq
    local panelGoods = mcGoods.currentView.panel_xq1
    local getWayScrollList = panelGoods.scroll_list
    if getWayScrollList ~= nil then
        if getWayScrollList:isMoving() then
            return
        end
    end
    
    -- 道具碎片合成
    if itemSubType == self.itemSubType.ITEM_SUBTYPE_203 then
        self:doComposeItemPieceAction(itemId)
    else
        self:doItemJumpAction(itemId,itemSubType)
    end
end

-- 道具碎片合成操作
function ItemListView:doComposeItemPieceAction(itemPieceId)
    local composeItemId = FuncItem.getComposeItemId(itemPieceId)
    if composeItemId == nil then
        echoWarn("ItemListView:doItemPieceComposeAction itemPieceId 没有合成配置")
        return
    end

    local itemPieceNums = ItemsModel:getItemNumById(itemPieceId)
    local itemData = FuncItem.getItemData(composeItemId)

    local rewardNum = 1
    local rewardStr = string.format("%s,%s,%s",FuncDataResource.RES_TYPE.ITEM,composeItemId,rewardNum)
    local data = {}
    data.reward = {rewardStr}
    data.itemId = composeItemId
    data.itemPieceId = itemPieceId
    data.itemPieceNums = itemPieceNums
    -- 合成消耗
    local cost = UserModel:getCombineResCost(itemPieceId)
    -- 如果满足，返回的第一个参数为true
    local resType,resId = UserModel:isResEnough(cost)
    if resType == true then
        WindowControler:showWindow("ItemCombineView",data)
    else               
        local resName = FuncDataResource.getResNameById(resType,resId)
        WindowControler:showTips(resName .. GameConfig.getLanguage("#tid_item34007")) 
    end
end

function ItemListView:composeItemPieceCallBack()

end

-- 重构后根据配表进行跳转
function ItemListView:doItemJumpAction(itemId,itemSubType)
    local itemSubType = tonumber(itemSubType)
    -- if itemSubType == self.itemSubType.ITEM_SUBTYPE_401 then
    --     WindowControler:showTips("该功能暂未开放")
    --     return
    -- end

    -- 从ItemAction表中获取跳转配置
    local actionData = FuncItem.getItemActionData(itemSubType)
    if actionData == nil then
        echoError ("ItemListView:doItemJumpAction actionData is nil")
        return
    end

    -- 跳转对应的系统名称
    local actionSys = actionData.sys
    local isOpen, condValue,condType,lockTip
    if actionSys == nil or actionSys == "" then
        isOpen = true
    else
        isOpen, condValue,condType,lockTip = FuncCommon.isSystemOpen(actionSys);
    end

    if not isOpen then
        -- 奇侠碎片单独处理
        if itemSubType == self.itemSubType.ITEM_SUBTYPE_202 then
            if PartnerModel:isHavedPatnner(itemId) then
                WindowControler:showTips(lockTip)
                return
            else
                -- 跳到合成界面
                local _isShow = FuncPartner.getPartnerById(itemId).isShow
                if _isShow == 1 then
                    WindowControler:showWindow("PartnerView",FuncPartner.PartnerIndex.PARTNER_COMBINE,itemId)
                else
                    WindowControler:showTips(GameConfig.getLanguage("tid_common_2073")..itemId)
                end
            end
        else
            WindowControler:showTips(lockTip)
            return
        end
    end

    if actionSys == FuncCommon.SYSTEM_NAME.GUILD and not GuildModel:isInGuild() then
        WindowControler:showTips(GameConfig.getLanguage("tid_rank_1015"))
        return
    end

    -- 特殊处理碎片
    if itemSubType == self.itemSubType.ITEM_SUBTYPE_202 then
        if PartnerModel:isHavedPatnner(itemId) then
            -- 跳到升星界面
            -- todo 如果有伙伴显示使用，否则显示合成
            WindowControler:showWindow("PartnerView",FuncPartner.PartnerIndex.PARTNER_UPSTAR,itemId)
        else
            -- 跳到合成界面
            local _isShow = FuncPartner.getPartnerById(itemId).isShow
            if _isShow == 1 then
                WindowControler:showWindow("PartnerView",FuncPartner.PartnerIndex.PARTNER_COMBINE,itemId)
            else
                WindowControler:showTips(GameConfig.getLanguage("tid_common_2073")..itemId)
            end
        end
    else
        local linkViewName = actionData.link
        if linkViewName then
            local linkArr = actionData.linkPara or {}
            linkArr[#linkArr+1] = itemId

            local viewClassName = WindowsTools:getWindowNameByUIName(linkViewName)
            if viewClassName == "HandbookMainView" then
                local dirId = FuncHandbook.itemToDir[tostring(itemId)]
                local needLevel = FuncHandbook.getUnlockLevel( dirId )
                if UserModel:level() < needLevel then
                    WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_handbooktips_004",needLevel,FuncHandbook.dirId2Name[dirId]))
                else
                    WindowControler:showWindow("HandbookOneDirDetailView",dirId) 
                end
            else
                WindowControler:showWindow(viewClassName, unpack(linkArr))
            end
            
        end
    end
end

-- 根据item 子类型更新点击按钮状态
function ItemListView:updateItemActionBtnStatus(btnAction,itemId,itemSubType)
    if self:needHideActionBtn() then
        btnAction:setVisible(false)
    else
        btnAction:setVisible(true)
        -- 默认显示去合成
        btnAction:showFrame(1)

        -- 特殊处理伙伴碎片
        if itemSubType == self.itemSubType.ITEM_SUBTYPE_202 then
            if PartnerModel:isHavedPatnner(itemId) then
                -- 使用
                btnAction:showFrame(4)
            else
                -- 去合成
                btnAction:showFrame(1)
                btnAction.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("tid_item_5001"))
            end
        -- 道具碎片
        elseif itemSubType == self.itemSubType.ITEM_SUBTYPE_203 then
            -- 合成
            btnAction:showFrame(6)
        elseif itemSubType == self.itemSubType.ITEM_SUBTYPE_201 then
            if tostring(itemId) == "4050" then
                btnAction:showFrame(4)
            else
                if TreasureNewModel:isHaveTreasure(itemId) then
                    -- 使用
                    btnAction:showFrame(4)
                else
                    -- 去合成
                    btnAction:showFrame(1)
                    btnAction.currentView.btn_2:getUpPanel().txt_1:setString(GameConfig.getLanguage("tid_item_5002"))
                end
            end

            
        else
            local itemData = FuncItem.getItemData(itemId)
            local btnFrame = FuncItem.getItemActionValue(itemData.subType_display,"btnFrame")
            if btnFrame then
                btnAction:showFrame(tonumber(btnFrame))
            end
        end
    end 
end

-- 打开宝箱
function ItemListView:openBoxes(itemId,itemNum,leftBoxNum)
    -- 如果正在开宝箱中
    if self.isOpeningBox then
        return
    end

    local reward_status = {}
    if tostring(itemId) == "2200" then
        local rewardData = FuncItem.getRewardData(itemId).info
        for i,v in ipairs(rewardData) do
            local str_table = string.split(v, ",")
            local partnerId = str_table[3]
            if PartnerModel:isHavedPatnner(partnerId) then
                table.insert(reward_status, tostring(partnerId))
            end
        end
    end

    local customItemCallBack = function(event)
        self.isOpeningBox = false
        if event.result ~= nil then
            local rewardArr = event.result.data.reward
            local data = {}
            data.reward = rewardArr

            for i,v in ipairs(data.reward) do
                local str_table = string.split(v, ",")
                if tostring(str_table[1]) == FuncDataResource.RES_TYPE.PARTNER then
                    local partnerId = str_table[2]
                    if table.indexof(reward_status, partnerId) then
                        local partnerData = FuncPartner.getPartnerById(partnerId)
                        local debrisNum = partnerData.sameCardDebris
                        data.reward[i] = FuncDataResource.RES_TYPE.ITEM..","..partnerId..","..debrisNum
                    end
                end
            end
            data.itemId = itemId
            data.itemNum = itemNum
            WindowControler:showWindow("ItemBoxRewardView", data);
        end
    end

    local canUse = ItemsModel:checkItemUseCondition(itemId, itemNum)

    if canUse then
        self.isOpeningBox = true
        ItemServer:customItems(itemId, itemNum, c_func(customItemCallBack))
    else    
        -- 不足10个宝箱，有几个开几个
        if itemNum == ItemsModel.boxType.TYPE_BOX_NUM_TEN and leftBoxNum > 0 then
            self.isOpeningBox = true
            ItemServer:customItems(itemId, leftBoxNum, c_func(customItemCallBack))
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_item_5003"))
        end
    end
end

-- 处理强化、合成、精炼等操作成功后消息
function ItemListView:onActionSuccess()
    local data = {}
    data.params = {}
    data.params[self.curSelectItemId] = true

    self:updateItems(data)
end

-- 更新道具
function ItemListView:updateItems(data)
    if data.params == nil then
        return
    end

    local refreshList = false
    for k,v in pairs(data.params) do
        local itemId = k

        local item = ItemsModel:getItemById(itemId)
        -- 减少了一种道具
        if item == nil then
            if self.curItemType == self.itemType.ITEM_TYPE_ALL then
                refreshList = true
            else
                if ItemsModel:isSameItemType(self.curSelectItemId,itemId) then
                    refreshList = true
                end
            end
        else
            local targetItemData = self:findItemDataFromListData(itemId)
            -- 新增了一种道具
            if targetItemData == nil then
                if self.curItemType == self.itemType.ITEM_TYPE_ALL then
                    refreshList = true
                else
                    if ItemsModel:isSameItemType(self.curSelectItemId,itemId) then
                        refreshList = true
                    end
                end
            else
                self:updateOneItemView(itemId)
            end
        end
    end

    -- 需要刷新列表
    if refreshList then
        -- 刷新滚动列表
        -- self:showItemsByTagType(self.curTagType)
        if self.curSubTagType then
            self:updateUI(self.curTagType, self.curSubTagType)
        else
            self:updateUI(self.curTagType)
        end
        self.scrollItemList:refreshScroll()
    end

    -- -- 更新tag状态
    self:updateTagStatus(self.curTagType)
end

function ItemListView:updateOneItemView(itemId)
    -- 找到变化的item的tab引用
    local targetItemData = self:findItemDataFromListData(itemId)
    local item = ItemsModel:getItemById(itemId)

    local itemNum = ItemsModel:getFormatItemNum(itemId)
    if targetItemData then
        local targetView =  self.scrollItemList:getViewByData(targetItemData)
        if targetView == nil then
            -- echo("targetView is nil itemId====",itemId)
            return
        end

        targetView:setResItemNum(itemNum)

        if tonumber(itemId) == tonumber(self.curSelectItemId) then
            -- 更新itemDetail
            self:updateItemDetail()
        end 
    end
end

-- 更具itemId，从列表数据中查找itemData
function ItemListView:findItemDataFromListData(itemId)
    local itemType = self:getItemTypeByTagType(self.curTagType) 

    local targetItemData = nil
    if itemType == self.itemType.ITEM_TYPE_ALL then
        -- for i=1,#self.itemDatas do
        for k,v in pairs(self.itemDatas) do
            local data = v
            for n=1,#data do
                if tostring(data[n]:id()) == tostring(itemId) then
                    targetItemData = data[n]
                    return targetItemData
                end
            end
        end
    else
        for i=1,#self.itemDatas do
            if tostring(self.itemDatas[i]:id()) == tostring(itemId) then
                targetItemData = self.itemDatas[i]
                return targetItemData
            end
        end
    end

    return targetItemData
end

-- 更新页签状态
function ItemListView:updateTagStatus(tagType)
    if ItemsModel:isBagEmpty() then
        self:hideAllTag()
        return
    else
        self.scale9_1:setVisible(true)
        if self:getItemNumByTagType(self.curTagType) == 0 then
            -- 显示当前类别无道具
            self.mc_beibaonei:showFrame(tagType)
            --因为材料和碎片里又分了小页签，所以需要单独特殊处理下
            if tagType == self.selectTagType.TAG_TYPE_MATERIAL then
                self.mc_beibaonei.currentView.txt_1:setString(GameConfig.getLanguage("tid_item_001"))
                self.mc_nx:setVisible(false)
            elseif tagType == self.selectTagType.TAG_TYPE_PIECE then
                self.mc_beibaonei.currentView.txt_1:setString(GameConfig.getLanguage("tid_item_002"))
                self.mc_nx:setVisible(false)
            end
            -- 道具明细显示空
            -- self.mc_goodxq:showFrame(3)
            -- 2016-04-18 修改为隐藏明细
            self.mc_goodxq:setVisible(false)
            self.scale9_1:setVisible(false)

            -- ZhangYanguang 2016-07-20 出现动画已弃用，所以消失动画也需要注释掉
            -- 逐渐消失
            -- local act = cc.Sequence:create(act.fadeout(0.15),nil)
            -- self.mc_goodxq:runAction(act)

            -- self:doItemDetailDisappearAnim()
        end
    end

    local tagNum = self.tagNum
    local tagPanel = self.tagPanel
    tagPanel:setVisible(true)

    for i=1,tagNum do
        tagPanel["mc_yeqian" .. i]:setVisible(true)
        if i == tagType then
            tagPanel["mc_yeqian" .. i]:showFrame(2)
        else
            tagPanel["mc_yeqian" .. i]:showFrame(1)
        end
    end

    -- 是否有未使用的宝箱
    if ItemsModel:hasCanUseBox() then
        tagPanel.panel_yeqianred1:setVisible(true)
        tagPanel.panel_yeqianred2:setVisible(true)
    else
        tagPanel.panel_yeqianred1:setVisible(false)
        tagPanel.panel_yeqianred2:setVisible(false)
    end
end


-- 更新子类型按钮及界面状态
function ItemListView:updateTagSubTypeStatus(tagSubType)
    local map_string = {
        [1] = "tid_item_003",
        [2] = "tid_item_004",
        [3] = "tid_item_005",
        [4] = "tid_item_006",
        [5] = "tid_item_007",
        [6] = "tid_item_008",
        [7] = "tid_item_009",
        [8] = "tid_item_014",
    }
    if #self.itemSubTypeDatas == 0 then
        --因为第三帧和第四帧分别为材料和碎片
        local tagType = 3 + math.floor((tagSubType - 1) / #self.selectSubTypeName1)
        self.mc_beibaonei:showFrame(tagType)
        self.mc_beibaonei.currentView.txt_1:setString(GameConfig.getLanguage(map_string[tagSubType]))
        self.mc_goodxq:setVisible(false)
    end
end

function ItemListView:showItemsByTagType(tagType)
    self.itemDatas = self:getItemDataByTagType(tagType)

    -- 设置滚动数据
    self.__listParams = self:buildItemScrollParams()
    -- self:buildItemScrollParams()

    -- ZhangYanguang 2016-07-13 屏蔽动画
    -- 是否是初始化
    --[[
    if self.isInit then
        self.isInit = false
        self:doItemLeftAppearAnim()
    end
    --]]

    -- 有相应的道具，显示道具列表
    if self:getItemNumByTagType(self.curTagType) > 0 then
        self.mc_beibaonei:showFrame(1)
        self.scrollItemList:styleFill(self.__listParams)
        -- 切换类别，滚动条条重置并且默认选中第一个item
        self.scrollItemList:gotoTargetPos(1,1,2,false)
        -- self.curSelectItemId = self:getFirstItemId()
        local curSelectItemId = self:getFirstItemId()

        -- 默认选中第一个
        local targetItemData = self:findItemDataFromListData(curSelectItemId)
        local targetView =  self.scrollItemList:getViewByData(targetItemData)
        self:clickOneItemView(targetView, curSelectItemId)

        -- ZhangYanguang 2016-07-13 屏蔽动画
        -- self:doItemDetailAppearAnim()
    else
        self.mc_beibaonei:showFrame(2)

        self:resetData()
    end
end

function ItemListView:showItemsByTagSubType(tagSubType)
    self.itemSubTypeDatas = self:getItemDataByTagSubType(tagSubType)
    
    self.__listParams = self:buildSubTypeItemScrollParams()

    if #self.itemSubTypeDatas > 0 then
        self.mc_beibaonei:showFrame(1)
        self.scrollItemList:styleFill(self.__listParams)
        -- 切换类别，滚动条条重置并且默认选中第一个item
        self.scrollItemList:gotoTargetPos(1,1,2,false)
        -- self.curSelectItemId = self:getFirstItemId()
        local curSelectItemId = self.itemSubTypeDatas[1]:id()

        -- 默认选中第一个
        local targetItemData = self:findItemDataFromListData(curSelectItemId)
        local targetView =  self.scrollItemList:getViewByData(targetItemData)
        self:clickOneItemView(targetView, curSelectItemId)

        -- ZhangYanguang 2016-07-13 屏蔽动画
        -- self:doItemDetailAppearAnim()
    else
        self.mc_beibaonei:showFrame(2)

        self:resetData()
    end
end
-- 该类型背包数据为空的时候，重置数据
function ItemListView:resetData()
    self.curSelectItemId = nil
end

-- 动态生成item滚动区配置参数
function ItemListView:buildItemScrollParams()
    local itemType = self:getItemTypeByTagType(self.curTagType) 

    local scrollParams = {}

    if itemType == self.itemType.ITEM_TYPE_ALL then
        -- local isFirstPart = true
        local allDatas = {}
        -- for i=1,#self.itemDatas do
        for i=1,#self.itemOrderList do
            local curItemType = self.itemOrderList[i]
            local data = self.itemDatas[curItemType]
            -- local data = {}
            -- for k,v in pairs(self.itemDatas) do
            --     if #v > 0 then
            --         table.insert(data, v)
            --     end
            -- end

            -- dump(data, "\n\ndata=====")
            -- 背包全部类型展示规则修改，不再分块展示  by  LXH
            if #data > 0 then
                for i,v in ipairs(data) do
                    table.insert(allDatas, v)
                end

                -- if isFirstPart then
                --     isFirstPart = false
                -- else
                --     -- 分割线
                --     -- local copyLineParams = table.deepCopy(self.itemLineParams)
                --     -- scrollParams[#scrollParams+1] = copyLineParams
                -- end

                -- 道具数据
                -- local copyItemParams = nil
                -- if curItemType == self.itemType.ITEM_TYPE_PIECE then
                --     copyItemParams = table.deepCopy(self.itemPieceViewParams)
                -- else
                -- copyItemParams = table.deepCopy(self.itemViewParams)
                -- end

                -- copyItemParams.data = data
                -- scrollParams[#scrollParams+1] = copyItemParams
            end
        end
        local copyItemParams = table.deepCopy(self.itemViewParams)

        copyItemParams.data = allDatas
        scrollParams[#scrollParams+1] = copyItemParams
    else
        local copyItemParams = nil
        if itemType == self.itemType.ITEM_TYPE_PIECE then
            copyItemParams = table.deepCopy(self.itemPieceViewParams)
        else
            copyItemParams = table.deepCopy(self.itemViewParams)
        end

        copyItemParams.data = self.itemDatas
        scrollParams[#scrollParams+1] = copyItemParams
    end

    return scrollParams
end

-- 动态生成子类型item滚动区配置参数
function ItemListView:buildSubTypeItemScrollParams()
    -- local itemSubType = self:getItemTypeByTagSubType(self.curTagSubType) 
    local itemType = self:getItemTypeByTagType(self.curTagType) 
    local scrollParams = {}

    --[[
        self.selectSubType = {
            TAG_SUBTYPE_UPQUALITY = 1,
            TAG_SUBTYPE_EQUIPMENT = 2,
            TAG_SUBTYPE_ARTIFACT = 3,
            TAG_SUBTYPE_FIVESOUL = 4,
            TAG_SUBTYPE_QIXIA = 5,
            TAG_SUBTYPE_TREASURE = 6,
            TAG_SUBTYPE_MATERIAL = 7,
        }
    ]]
    local copyItemParams = nil
    if itemType == self.itemType.ITEM_TYPE_PIECE then
        copyItemParams = table.deepCopy(self.itemPieceViewParams)
    else
        copyItemParams = table.deepCopy(self.itemViewParams)
    end

    copyItemParams.data = self.itemSubTypeDatas
    scrollParams[#scrollParams + 1] = copyItemParams

    return scrollParams
end

-- 获取第一个道具
function ItemListView:getFirstItemId()
    local itemType = self:getItemTypeByTagType(self.curTagType) 

    local firstItemId = nil
    if itemType == self.itemType.ITEM_TYPE_ALL then
        -- for i=1,#self.itemDatas do
        for i=1,#self.itemOrderList do
            local curItemType = self.itemOrderList[i]
            local data = self.itemDatas[curItemType]
            if #data > 0 then
                firstItemId = data[1]:id()
                break
            end
        end
    else
        firstItemId = self.itemDatas[1]:id()
    end

    return firstItemId
end


-- 获取当前类型道具总数量
function ItemListView:getItemNumByTagType(tagType)
    local itemNum = 0
    local itemType = self:getItemTypeByTagType(tagType) 
    if itemType == self.itemType.ITEM_TYPE_ALL then
        -- for i=1,#self.itemDatas do
        for i=1,#self.itemOrderList do
            local curItemType = self.itemOrderList[i]
            local data = self.itemDatas[curItemType]
            itemNum = itemNum + #data
        end
    else
        itemNum = #self.itemDatas
    end

    return itemNum
end

-- 左侧道具列表动画特效
-- function ItemListView:doItemLeftAppearAnim()
--     local itemLeftWidth = 600

--     local panelLeft = self.panel_left

--     local x,y = panelLeft:getPosition()
--     if self.panelLeftViewX == nil then
--         self.panelLeftViewX = x
--     end

--     -- 出现动画（移动+渐现)
--     panelLeft:pos(self.panelLeftViewX - itemLeftWidth,y)
--     panelLeft:opacity(0)
--     local moveAction = act.moveto(0.3,self.panelLeftViewX,y)
--     local alphaAction = act.fadein(0.6)
--     local appearAnim = cc.Spawn:create(moveAction,alphaAction) 

--     panelLeft:stopAllActions()
--     panelLeft:runAction(
--         cc.Sequence:create(appearAnim)
--     )
-- end

-- 道具明细出现动画特效
function ItemListView:doItemDetailAppearAnim()
    local detailWidth = 354

    local mcGoods = self.mc_goodxq
    
    local x,y = mcGoods:getPosition()
    if self.detailViewX == nil then
        self.detailViewX = x
    end

    -- 出现动画（移动+渐现)
    mcGoods:pos(self.detailViewX + detailWidth,y)
    mcGoods:opacity(0)

    local moveAction = act.moveto(0.3,self.detailViewX,y)
    local alphaAction = act.fadein(0.6)
    local appearAnim = cc.Spawn:create(moveAction,alphaAction)

    mcGoods:stopAllActions()
    mcGoods:runAction(
        cc.Sequence:create(appearAnim)
    )
end

-- 根据tag类型获取道具数据
function ItemListView:getItemTypeByTagType(tagType)
    local itemType = 0
    if tagType == self.selectTagType.TAG_TYPE_ALL then
        itemType = self.itemType.ITEM_TYPE_ALL
    elseif tagType == self.selectTagType.TAG_TYPE_BOX then
         itemType = self.itemType.ITEM_TYPE_COST
    elseif tagType == self.selectTagType.TAG_TYPE_PIECE then
        itemType = self.itemType.ITEM_TYPE_PIECE
    elseif tagType == self.selectTagType.TAG_TYPE_MATERIAL then
        itemType = self.itemType.ITEM_TYPE_MATERIAL
    end

    return itemType
end

-- 根据tag类型获取道具数据
function ItemListView:getItemTypeByTagSubType(tagSubType)
    --[[
        self.selectSubType = {
            TAG_SUBTYPE_UPQUALITY = 1,
            TAG_SUBTYPE_EQUIPMENT = 2,
            TAG_SUBTYPE_ARTIFACT = 3,
            TAG_SUBTYPE_FIVESOUL = 4,
            TAG_SUBTYPE_QIXIA = 5,
            TAG_SUBTYPE_TREASURE = 6,
            TAG_SUBTYPE_MATERIAL = 7,
            TAG_SUBTYPE_EQUIPMENT_FRAGMENT = 8,
        }
        self.itemSubTypes_New = {
            ITEM_SUBTYPE_100 = 100,         --宝箱(可以打开的道具)
            ITEM_SUBTYPE_201 = 201,         --法宝碎片
            -- ITEM_SUBTYPE_305 = 305,         --法宝万能碎片
            ITEM_SUBTYPE_202 = 202,         --奇侠碎片
            ITEM_SUBTYPE_204 = 204,         --主角星魂碎片
            ITEM_SUBTYPE_203 = 203,         --其他碎片，在背包系统可以直接合成的一种碎片
            ITEM_SUBTYPE_205 = 205,         --装备碎片
            ITEM_SUBTYPE_312 = 312,         --神器
            -- ITEM_SUBTYPE_402 = 402,         --神器升级
            ITEM_SUBTYPE_310 = 310,         --升品
            ITEM_SUBTYPE_311 = 311,         --装备
            ITEM_SUBTYPE_314 = 314,         --五灵
        }
    ]]
    local itemSubType = 0
    if tagSubType == self.selectSubType.TAG_SUBTYPE_UPQUALITY then
        itemSubType = self.itemSubType.ITEM_SUBTYPE_310
    elseif tagSubType == self.selectSubType.TAG_SUBTYPE_EQUIPMENT then
         itemSubType = self.itemSubType.ITEM_SUBTYPE_311
    elseif tagSubType == self.selectSubType.TAG_SUBTYPE_ARTIFACT then
        -- itemSubType = {
        --     [1] = self.itemSubType.ITEM_SUBTYPE_401,
        --     [2] = self.itemSubType.ITEM_SUBTYPE_402,
        -- }
        itemSubType = self.itemSubType.ITEM_SUBTYPE_312
    elseif tagSubType == self.selectSubType.TAG_SUBTYPE_QIXIA then
        itemSubType = {
            [1] = self.itemSubType.ITEM_SUBTYPE_204,
            [2] = self.itemSubType.ITEM_SUBTYPE_202,
        }

    elseif tagSubType == self.selectSubType.TAG_SUBTYPE_TREASURE then
        -- itemSubType = {
        --     [1] = self.itemSubType.ITEM_SUBTYPE_201,
        --     [2] = self.itemSubType.ITEM_SUBTYPE_305,
        -- }
        itemSubType = self.itemSubType.ITEM_SUBTYPE_201
    elseif tagSubType == self.selectSubType.TAG_SUBTYPE_MATERIAL then
        itemSubType = self.itemSubType.ITEM_SUBTYPE_203
    elseif tagSubType == self.selectSubType.TAG_SUBTYPE_FIVESOUL then
        itemSubType = self.itemSubType.ITEM_SUBTYPE_314
    elseif tagSubType == self.selectSubType.TAG_SUBTYPE_EQUIPMENT_FRAGMENT then
        itemSubType = self.itemSubType.ITEM_SUBTYPE_205
    end

    -- dump(itemSubType, "\n\nitemSubType")
    return itemSubType
end

-- 根据tag类型获取道具数据
function ItemListView:getItemDataByTagType(tagType)
    local itemDatas = {};
    local itemType = self:getItemTypeByTagType(tagType) 

    if itemType == self.itemType.ITEM_TYPE_ALL then
        for i=1,#self.itemOrderList do
            local curItemType = self.itemOrderList[i]
            local curData = ItemsModel:getItemsByType(curItemType)
            itemDatas[curItemType] = curData
        end
    else
        itemDatas = ItemsModel:getItemsByType(itemType)
    end

    return itemDatas
end

-- 通过tag子类型获取道具数据
function ItemListView:getItemDataByTagSubType(tagSubType)
    --[[
        self.selectSubType = {
            TAG_SUBTYPE_UPQUALITY = 1,
            TAG_SUBTYPE_EQUIPMENT = 2,
            TAG_SUBTYPE_ARTIFACT = 3,
            TAG_SUBTYPE_FIVESOUL = 4,
            TAG_SUBTYPE_QIXIA = 5,
            TAG_SUBTYPE_TREASURE = 6,
            TAG_SUBTYPE_MATERIAL = 7,
            TAG_SUBTYPE_EQUIPMENT = 8,
        }
    ]]
    local itemSubTypeDatas = {}
    local itemSubType = self:getItemTypeByTagSubType(tagSubType)

    if type(itemSubType) == "table" then
        for i,v in ipairs(itemSubType) do
            local itemSubTypeDatas1 = ItemsModel:getItemsBySubType(v)
            for i,v in ipairs(itemSubTypeDatas1) do
                table.insert(itemSubTypeDatas, v)
            end            
        end
    else 
        itemSubTypeDatas = ItemsModel:getItemsBySubType(itemSubType)
    end
    
    return itemSubTypeDatas
end

-- 隐藏所有页签
function ItemListView:hideAllTag()
    local tagNum = self.tagNum
    local tagPanel = self.tagPanel

    -- tagPanel:setVisible(false)
    self.panel_1:setVisible(false)
    
    local mcGoods = self.mc_goodxq

    -- 隐藏明细
    mcGoods:setVisible(false)
    -- 显示空空如也
    self.mc_beibaonei:showFrame(5)
    self.scale9_1:setVisible(false)
end

function ItemListView:press_btn_back()
    self:startHide()
end

-- ItemView相关方法----------------------------------------------------------------
function ItemListView:setItemViewData(itemView,itemData)
    local itemId = itemData:id()
    local itemNum = ItemsModel:getFormatItemNum(itemId)

    local data = {
        itemId = itemId,
        itemNum = itemNum,
    }

    itemView:setResItemData(data)
    itemView:setResItemClickEnable(true)

    -- 如果是宝箱类型，显示小红点
    if ItemsModel:showRedPoint(itemId) then
        itemView:showResItemRedPoint(true)
    end

    self:updateSelectAnim(itemView, itemId, self.curSelectItemId)
    -- 展示一个itemview
    itemView.showItemView = function(itemView,event)
        local itemId = itemView:getItemData().itemId
        local selectItemId = event.params.itemId

        self:updateSelectAnim(itemView, itemId, selectItemId)
    end

    EventControler:addEventListener(ItemEvent.ITEMEVENT_SHOW_ITEM_VIEW,itemView.showItemView,itemView);
    itemView:setClickBtnCallback(c_func(self.clickOneItemView,self,itemView,itemId))
end

function ItemListView:updateSelectAnim(itemView, itemId, selectedItemId)
    if tonumber(itemId) == tonumber(selectedItemId) then
        self:showSelectAnim(itemView,true)
    else
        self:showSelectAnim(itemView,false)
    end
end

-- 点击itemView
function ItemListView:clickOneItemView(itemView,itemId)
    echo("clickOneItemView itemId=",itemId)
    if itemView:checkCanClick() then
        if itemId == self.curSelectItemId then
            return
        end

        self.curSelectItemId = itemId

        EventControler:dispatchEvent(ItemEvent.ITEMEVENT_CLICK_ITEM_VIEW,{itemId=itemId});
        EventControler:dispatchEvent(ItemEvent.ITEMEVENT_SHOW_ITEM_VIEW,{itemId=itemId});

        self:playSelectAnim(itemView)
    end
end

-- 是否显示选中动画
function ItemListView:showSelectAnim(itemView,visible)
   if visible then
       self:playSelectAnim(itemView)
   else
       local animCtn = itemView:getAnimationCtn()
       animCtn:setVisible(false)
   end 
end

-- 播放选择动画
function ItemListView:playSelectAnim(itemView)
    local selectAnim = self:getSelectAnim()
    local animCtn = itemView:getAnimationCtn()
    animCtn:setVisible(true)
    selectAnim:parent(animCtn)
end

-- 获取选中特效
function ItemListView:getSelectAnim()
    local itemId = self.curSelectItemId

    local itemData = FuncItem.getItemData(itemId)
    local itemType = itemData.type
    local subType = itemData.subType_display

    local animName = "UI_common_fang"
    if itemType == self.itemType.ITEM_TYPE_PIECE then
        animName = "UI_common_len"
        -- 如果是法宝碎片
        -- if subType == ItemsModel.itemSubTypes.ITEM_SUBTYPE_201 then
        --     animName = "UI_common_yuan"
        -- elseif subType == ItemsModel.itemSubTypes.ITEM_SUBTYPE_202 then
        --     animName = "UI_common_len"
        -- else
        --     animName = "UI_common_len"
        -- end
    end

    local anim = self.selectAnimCache[animName]
    if anim == nil then
        anim = self:createUIArmature("UI_common", animName, self._root, false, GameVars.emptyFunc)
        anim:pos(0,-1)
        anim:startPlay(true)
        self.selectAnimCache[animName] = anim
    end

    return anim
end

return ItemListView;
