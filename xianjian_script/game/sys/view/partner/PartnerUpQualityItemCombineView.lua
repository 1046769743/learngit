--伙伴系统伙伴合成
--2016-12-10 15:18:50
--Author:xiaohuaxiong
local PartnerUpQualityItemCombineView = class("PartnerUpQualityItemCombineView",UIBase)

function PartnerUpQualityItemCombineView:ctor(_winName,itemId,partnerId)
    PartnerUpQualityItemCombineView.super.ctor(self,_winName)
    self.itemEquipId = PartnerModel:getCombineFirstItemId()
    self.partnerId = Cache:get("qualityCombinePartnerId")
    self.parentItemId = PartnerModel:getCombineSecondItemId() or self.itemEquipId
end
-- 
function PartnerUpQualityItemCombineView:registerColse( )
    local touchNode = self.ctn_touch
    touchNode:removeAllChildren()
    --创建覆盖点
    local coverLayer = FuncRes.a_white(GameVars.width *4 , GameVars.height  *4):anchor(0.5,0.5)
    coverLayer:opacity(0)
    local nd = FuncRes.a_white(460 ,580 ):addto(touchNode,10):anchor(0.5,0.5)
    nd:setTouchedFunc(GameVars.emptyFunc,nil,true)
    nd:opacity(0)
    coverLayer:addto(touchNode,1)
    coverLayer:setTouchEnabled(true)
    coverLayer:setTouchedFunc(function (  )
        echo("点击事件响应")
        PartnerModel:clearCombine()
        self:startHide()
    end)

end
function PartnerUpQualityItemCombineView:loadUIComplete()
    self:registerEvent()
    self:registerColse()
    -- 判断是否显示合成UI
    if ItemsModel:getItemNumById(self.itemEquipId) > 0 
            or PartnerModel:upQualityEquiped(self.itemEquipId,self.itemEquipId,self.partnerId) then
        self.isShowUI = false
    else
        self.isShowUI = true
    end
    local itemCfg = FuncItem.getItemData(self.itemEquipId) 
    if itemCfg and not itemCfg.cost and not itemCfg.fragmentId then
        self.isShowUI = false
        self.hideBtn = true
    end

    self:UIShow(self.isShowUI)
    self:initEquipUI(self.itemEquipId)
    -- 此处是出战斗 刷新右侧合成
    local _item = PartnerModel:getCombineLastItemId();
    if _item then
        self:initUI(_item)
    end
end
function PartnerUpQualityItemCombineView:UIShow(isShow)
    if isShow then
        self.panel_1.mc_1:visible(true)
        self.panel_1.mc_1:setPositionX(588)
        self.panel_1.panel_1:setPositionX(171)
        self.ctn_touch:removeAllChildren()
        self.panel_1.panel_1.btn_xxx:setScaleX(-1)
        self.panel_1.panel_1.btn_xxx:setPositionX(445)
        if PartnerModel:getCombineLastItemId() == nil then
            PartnerModel:addCombineItemId(self.itemEquipId,self.partnerId)
        end
    else
        self:registerColse()
        self.panel_1.mc_1:visible(false)
        self.panel_1.panel_1:setPositionX(338)
        self.panel_1.panel_1.btn_xxx:setScaleX(1)
        self.panel_1.panel_1.btn_xxx:setPositionX(398)
    end

    if self.hideBtn then
        self.panel_1.panel_1.btn_xxx:setVisible(false)
    else
        self.panel_1.panel_1.btn_xxx:setVisible(true)
    end

    self.isShowUI = isShow
end
--装备显示
function PartnerUpQualityItemCombineView:initEquipUI(_itemId)
    local itemCombineData = FuncPartner.getConbineResById(_itemId)
    local itemData = FuncItem.getItemData(_itemId)

    ------------ 装备显示 -----------
    local equipPanel = self.panel_1.panel_1
    -- 显示
    equipPanel.UI_1:setResource({itemId = _itemId,num = 0 ,frame = 10,isShowNum = false})
    -- 名称
    equipPanel.mc_daojuming:showFrame(FuncItem.getItemQuality( _itemId )) 
    equipPanel.mc_daojuming.currentView.txt_daojuming:setString(GameConfig.getLanguage(itemData.name))
     -- 数量
    local num = ItemsModel:getItemNumById(_itemId); 
    equipPanel.txt_2:setString(GameConfig.getLanguage("#tid_partner_ui_025")..num)

--     equipPanel.txt_3:setString(num)
--     if num > 9999 then
--        num = 9999
--    end
--    self.initTxt4PosX = 260
--    local numArr = number.split( num )
--    equipPanel.txt_4:setPositionX(self.initTxt4PosX - (4 - #numArr) * 16)
     -- 描述
    equipPanel.txt_5:setString(GameConfig.getLanguage(itemData.des))   
     -- 属性
    local plusVec = itemCombineData.attr  
    equipPanel.mc_three:showFrame(#plusVec)
    local shuxingpanel= equipPanel.mc_three.currentView
    for i,v in pairs(plusVec) do  
        shuxingpanel["panel_"..i].txt_1:setString(PartnerModel:getDesStahe(v))
        shuxingpanel["panel_"..i].mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.key)])
    end
end

function PartnerUpQualityItemCombineView:initUI(_itemId)
     self.itemId = _itemId
     local itemCombineData = FuncPartner.getConbineResById(_itemId)
     local itemData = FuncItem.getItemData(_itemId)
     self.panel_1.mc_1:showFrame(1)
     local combinePanel = self.panel_1.mc_1.currentView

    ------------------- 刷新按钮 ---------------------
    self:btnFresh()
    ------------合成显示-------------
    local combineCostVec = FuncItem.getItemPropByKey(_itemId,"cost")
    if not combineCostVec then
        return
    end
    local frameNum = 3 - #combineCostVec + 2
    combinePanel.panel_2.mc_1:showFrame(frameNum)
    for i = 1, (#combineCostVec + 1) do
        local  _id;
        local frame;
        local _clear;
        local _showNum = true
        if i == 1 then
            _id = self.itemId
            frame = 5
        else
            local idStr = combineCostVec[i-1]
            local idStrVec = string.split(idStr,",");
            if tonumber(idStrVec[1]) == 1 then
                _id = idStrVec[2]
                frame = PartnerModel:getItemFrame(idStrVec[2],self.itemId,self.partnerId)
                -- 打个补丁  
                if ItemsModel:getItemNumById(idStrVec[2]) >= tonumber(idStrVec[3]) then
                    frame = 7
                end

            elseif tonumber(idStrVec[1]) == 3 then
                if UserModel:getCoin() >= tonumber(idStrVec[2]) then
                    combinePanel.panel_2.mc_tong:showFrame(1)
                else
                    combinePanel.panel_2.mc_tong:showFrame(2)
                end
                combinePanel.panel_2.mc_tong.currentView.txt_1:setString(idStrVec[2])
            end
        end
        if i ~= (#combineCostVec + 1)  then
            combinePanel.panel_2.mc_1.currentView["UI_"..i]:setResource(
                {parentItemId = self.itemId,itemId = _id ,frame = frame,partnerId = self.partnerId,isShowNum = true})
        end
        
    end
     
    --道具名字
    combinePanel.panel_2.mc_daojuming:showFrame(FuncItem.getItemQuality( _itemId )) 
    combinePanel.panel_2.mc_daojuming.currentView.txt_daojuming:setString(GameConfig.getLanguage(itemData.name))

    ------------------- 刷新顶部提示 ----------------------
    self:combineTop()
end

function PartnerUpQualityItemCombineView:getItemFrame(itemId,partnerId)   
    local positions = {}
    local value = 8
    while value ~= 0 do
		local num = value % 2;
		table.insert(positions, 1, num);
		value = math.floor(value / 2);
	end
    -- 判断是否已装备

    if positions[index] and positions[index] == 1 then
        return 1 
    end
    -- 判断是否可装备
    if ItemsModel:getItemNumById(itemId) > 0 then
        return 2
    end
    -- 判断是否可合成
    local enough = PartnerModel:isCombineQualityItem(itemId)
    if enough == 1 then
        return 4
    end
    
    return 3

end

--按钮 刷新
function PartnerUpQualityItemCombineView:btnFresh()
    self.panel_1.mc_1:showFrame(1)
    local combinePanel = self.panel_1.mc_1.currentView
    -- 合成按钮
    local btn2 = combinePanel.panel_2.btn_2
    -- 判断是否可合成
    local canCombine, costItemId, curTargetNum = PartnerModel:isCombineQualityItem(self.itemId,false)
    
    if canCombine == 3 then
        -- FilterTools.clearFilter(btn2);
        btn2:setTap(c_func(self.combineTap,self))
        btn2:disableClickSound()
    elseif canCombine == 1 then 
        -- FilterTools.setGrayFilter(btn2);
        btn2:setTap(c_func(function ()
            WindowControler:showTips(GameConfig.getLanguage("#tid1561"))
            if costItemId and curTargetNum then
                WindowControler:showWindow("GetWayListView", costItemId, tonumber(curTargetNum))
            end
        end,self))
    elseif canCombine == 2 then 
        -- FilterTools.setGrayFilter(btn2);
        btn2:setTap(c_func(function ()
            WindowControler:showTips(GameConfig.getLanguage("#tid1557"))
            WindowControler:showWindow("CompBuyCoinMainView")
        end,self))
    end
    -- 装备按钮
    self.partnerId = Cache:get("qualityCombinePartnerId")
    local btn1_mc = self.panel_1.panel_1.mc_ysy
    btn1_mc:setVisible(true)
    if ItemsModel:getItemNumById(self.itemEquipId) > 0 then
        if PartnerModel:upQualityEquiped(self.itemEquipId,self.itemEquipId,self.partnerId) then
            -- FilterTools.setGrayFilter(btn1_mc);
            -- btn1:setTap(c_func(function ()
            --     WindowControler:showTips("已装备")
            -- end,self))
            btn1_mc:showFrame(2)
        else
            btn1_mc:showFrame(1)
            local btn1 = btn1_mc.currentView.btn_1
            FilterTools.clearFilter(btn1_mc); 
            btn1:setTap(c_func(self.equipTap,self))
            btn1:disableClickSound()
        end
        
    else
        if PartnerModel:upQualityEquiped(self.itemEquipId,self.itemEquipId,self.partnerId) then
            -- FilterTools.setGrayFilter(btn1);
            -- btn1:setTap(c_func(function ()
            --     WindowControler:showTips("已装备")
            -- end,self))
            btn1_mc:showFrame(2)
        else
            btn1_mc:showFrame(1)
            btn1_mc:showFrame(1)
            btn1_mc:setVisible(false)
            local btn1 = btn1_mc.currentView.btn_1
            FilterTools.setGrayFilter(btn1_mc);
            btn1:setTap(c_func(function () 
                WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_026"))
            end,self))
        end
        
    end
    
 end
 function PartnerUpQualityItemCombineView:combineTap()
    local canCombine = PartnerModel:isCombineQualityItem(self.itemId,false)
    if canCombine == 1 then 
        WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_027"))
    elseif canCombine == 2 then 
        WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_028"))
    elseif canCombine == 3 then 
        echo("--------------合成之前 数量 "..self.itemId.." = ".. ItemsModel:getItemNumById(self.itemId) )
        PartnerServer:qualityItemLevelupRequest(self.itemId, c_func(self.combineCallBack,self))
        
    end
 end
 function PartnerUpQualityItemCombineView:combineCallBack(event)
    echo("++++++++++++++++++ 服务器返回------------------")
    if event.result then
        if self.parentItemId ~= self.itemId then
            PartnerModel:deleteCombineItemId(self.itemId)
        end
        self:initUI(self.parentItemId)
    end
 end

 --装备
 function PartnerUpQualityItemCombineView:equipTap()
    local pos = PartnerModel:getUpqualityPosition(self.itemEquipId,self.partnerId);
    if pos >= 0 and pos < 4 then
        FuncPartner.playPartnerBtnSound()
        PartnerModel:setShengPinId(pos,self.partnerId)

        local posT = {}
        table.insert(posT,pos)
       -- PartnerModel:getQualityItemUsedCallBackData({ position = tostring(pos),partnerId = tostring(self.partnerId) ,_item = self.itemEquipId })
        if FuncPartner.isChar(tostring(self.partnerId)) then
            CharServer:qualityEquip({positions = posT},c_func(self.equipTapCallBack,self))
        else
           
            PartnerServer:qualityItemEquipRequest({ positions = posT,partnerId = tostring(self.partnerId) }
                , c_func(self.equipTapCallBack,self),self.itemEquipId)
        end
        FuncPartner.playPartnerShengPinPointSound( )
    else
        echoError("self.partnerId ======= ",self.partnerId)
        WindowControler:showTips("位置取得有问题")
    end
    
 end
 function PartnerUpQualityItemCombineView:equipTapCallBack(event)
    echo("++++++++++++++++++ 服务器返回------------------")
   -- if event.error == nil then
   --     local num = ItemsModel:getItemNumById(self.itemEquipId);
   --     self.panel_1.txt_3:setString(num)
   --     local btn1 = self.panel_1.btn_1
   --     if ItemsModel:getItemNumById(self.itemEquipId) > 0 then
   --         if PartnerModel:getItemFrame(self.itemEquipId,self.itemEquipId,self.partnerId) == 1 then
   --             FilterTools.setGrayFilter(btn1);
   --             btn1:setTap(c_func(function ()
   --                 WindowControler:showTips("已装备")
   --             end,self))
   --         else
   --             FilterTools.clearFilter(btn1); 
   --             btn1:setTap(c_func(self.equipTap,self))
   --         end

   --     else
   --         FilterTools.setGrayFilter(btn1);
   --         btn1:setTap(c_func(function ()
   --             WindowControler:showTips("装备条件不满足")
   --         end,self))
   --     end
        PartnerModel:clearCombine()
        
       -- EventControler:dispatchEvent(PartnerEvent.PARTNER_QUALITY_ITEM_COMBINE_EVENT)
        self:startHide()
   -- end
 end
 
 -- 合成顶部列表
 function PartnerUpQualityItemCombineView:combineTop()
    self.panel_1.mc_1:showFrame(1)
    local combinePanel = self.panel_1.mc_1.currentView

    local itemVec = PartnerModel:getCombineItemId()
    local frameNum = #itemVec
    echo("#itemVec ==== ",frameNum)
    combinePanel.panel_2.mc_duo:showFrame(frameNum)
    for i,v in pairs(itemVec) do
        combinePanel.panel_2.mc_duo.currentView["UI_"..i]:setResource({itemId = v,frame = 5,partnerId = self.partnerId ,isShowNum = false})
        local _callBack = function()
            self.itemId = v
            PartnerModel:deleteCombineToItemId(self.itemId)

            self:initUI(self.itemId)    
        end
        
        combinePanel.panel_2.mc_duo.currentView["UI_"..i]:setTouchCallBack(_callBack)
    end
    
 end

function PartnerUpQualityItemCombineView:registerEvent()
    PartnerUpQualityItemCombineView.super.registerEvent(self)

    --合成返回按钮
    self.panel_1.mc_1:showFrame(1)
    local combinePanel = self.panel_1.mc_1.currentView
    combinePanel.panel_2.btn_back:setTap(c_func(function ()
        PartnerModel:clearCombine()
        self:startHide()
    end,self))

    -- 显示合成按钮
    local showUIBtn = self.panel_1.panel_1.btn_xxx
    showUIBtn:setTap(function ( )
        echo("此时 合成UI ---- ",self.isShowUI)
        self:UIShow(not self.isShowUI)
    end)

    --装备返回按钮 -- 11.01 UI没有关闭按钮
    -- self.panel_1.panel_1.btn_back:setTap(c_func(function ()
    --     PartnerModel:clearCombine()
    --     self:startHide()
    -- end,self))

    -- 点击空白区域关闭
    function closeCall(  )
        PartnerModel:clearCombine()
        self:startHide()
    end
    self:registClickClose("out",closeCall)

    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.refreshUI, self);  
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, 
        self.refreshUI, self); 
    
--    EventControler:addEventListener(HomeEvent.SYSTEM_OPEN_EVENT, 
--        self.clearCombine, self);  

-- 装备成功
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_POSITION_CHANGE_EVENT,self.equipTapCallBack,self)

 
end
function PartnerUpQualityItemCombineView:clearCombine()
    PartnerModel:clearCombine()
end
function PartnerUpQualityItemCombineView:refreshUI()
    --此处是 进战斗 回来后重新加载装备的ID
    self.partnerId = Cache:get("qualityCombinePartnerId")
    self:initEquipUI(self.itemEquipId)

    local _id = PartnerModel:getCombineLastItemId()
    if _id then
        self.itemId = _id
        self:initUI(self.itemId)
    end
end

return PartnerUpQualityItemCombineView    