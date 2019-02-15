local PartnerUpgradeView = class("PartnerUpgradeView", UIBase)

local upgradeItemId = {
    UPGRADEITEM1 = "9001",
    UPGRADEITEM2 = "9002",
    UPGRADEITEM3 = "9003",
    UPGRADEITEM4 = "9004",
    UPGRADEITEM5 = "9005",
}
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local schedulerID = nil
local UI_MOVE_TIME = 0.25
function PartnerUpgradeView:ctor(winName,data)
	PartnerUpgradeView.super.ctor(self, winName) 
    self.longTouchAddNum = 1
    self.data = data
    self.viewTable = {}
end

function PartnerUpgradeView:registerEvent() 
    PartnerUpgradeView.super.registerEvent();
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.itemRefresh,self)
    -- EventControler:addEventListener(PartnerEvent.PARTNER_EXP_CHANGE_EVENT,self.upgradeCallBack,self)
    -- EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT,self.upgradeCallBack,self)
    

    EventControler:addEventListener(PartnerEvent.PARTNER_VIEW_CLOSE_EVENT,self.duananServer,self)
    EventControler:addEventListener(HomeEvent.SYSTEM_OPEN_EVENT,self.duananServer,self)

    -- self.panel_1.btn_back:setTap(function ()
    --     local x = self.panel_1:getPositionX()
    --     local y = self.panel_1:getPositionY()
    --     local animCallBack = function ()
    --         self:startHide()
    --     end
    --     local moveAnim = act.moveto(UI_MOVE_TIME,x+480,y)
    --     self.panel_1:runAction(act.sequence(moveAnim, act.callfunc(animCallBack)))
    -- end)
    self.panel_1.btn_back:visible(true)   
    -- 点击空白区域关闭
    local outCall = function (  )
        EventControler:dispatchEvent(PartnerEvent.PARTNER_START_HIDE_UPGRADE_UI_EVENT)
    end
    self.panel_1.btn_back:setTap(outCall)
end

function PartnerUpgradeView:updataUI(data)
    if LS:prv():get(StorageCode.partner_skilledForUpgrade) then
        self.isSkillledPlayer = true
    else
        if PartnerModel:isSkilledPlayerForUpgrade() then
            self.isSkillledPlayer = true
        else
            self.isSkillledPlayer = false
        end
    end

    if self.lastPartnerId then
        self.hasChanged = true
        local lastPartnerData = PartnerModel:getPartnerDataById(self.lastPartnerId)
        EventControler:dispatchEvent(PartnerEvent.PARTNER_LEVEL_ANIM_EVENT, 
                        {level = lastPartnerData.level, partnerId = self.lastPartnerId, hasChanged = self.hasChanged})
    end

    self:stopAllActions()
    self:itemEnable(true)

    self.data = data
    self.level = self.data.level
    self.realLevel = self.level
    self.partnerId = self.data.id
    self.star = self.data.star
    self.lastPartnerId = self.partnerId
    -- 当前升级状态 一键升级2 或者普通升级1
    self.shengjiType = 1
    self.panel_1.mc_1:showFrame(1)
    self:initUpgradeCostList()
end

function PartnerUpgradeView:initUpgradeCostList()
    self.changanNum = 0
    self.duananNum = 0
    self.itemNum = {}
    self.viewTable = {}
    self.animCtn_table = {}
    self.viewStateTable = {}
    self.panelStateTable = {}
    for i = 1,5 do
        local data = { };
        data.itemId = upgradeItemId["UPGRADEITEM"..i];
        data.exp = FuncItem.getItemData(data.itemId).useEffect;
        data.subType = FuncItem.getItemData(data.itemId).subType;
        data.itemNum = ItemsModel:getItemNumById(data.itemId) or 0;
        local view = self.panel_1.panel_1["panel_"..i].UI_1;
        local anim_ctn = self.panel_1.panel_1["panel_"..i].ctn_itemBao
        self.viewTable[data.itemId] = view
        self.animCtn_table[data.itemId] = anim_ctn
        self.viewStateTable[data.itemId] = false
        self.panelStateTable[data.itemId] = self.panel_1.panel_1["panel_"..i].panel_dui
        self.panel_1.panel_1["panel_"..i].panel_dui:visible(false)
        data.view = view
        view:setResItemData(data);
        view:showResItemName(false)
        
        if data.itemNum > 0 then
            FilterTools.clearFilter(view);
            view:showResItemNum(true)
        else
            FilterTools.setGrayFilter(view);
            view:showResItemNum(false)
        end
        if data.subType == 308 then
            --view:setName("经验提升1级")
            self.panel_1.panel_1["panel_"..i].mc_1:showFrame(2)
        else
            --  view:setName("经验+"..data.exp)
            self.panel_1.panel_1["panel_"..i].mc_1:showFrame(1)
            self.panel_1.panel_1["panel_"..i].mc_1.currentView.txt_1:setString("+"..data.exp)
        end
        

        local  funcs = {};
        self.itemNum[data.itemId] = ItemsModel:getItemNumById(data.itemId)
        local changanTap = function ()
           -- echo("___aaaaaaaaaaaa长按了")
            if self.shengjiType == 2 then
                return
            end
            if self.itemNum[data.itemId] > 0 then           
                if self:isCanUpgrade() then
                    FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, anim_ctn)
                    self.itemNum[data.itemId] = self.itemNum[data.itemId]-self.longTouchAddNum
                    self.expType = "changan"
                    if self.changanNum >= 8 and data.subType ~= 308 then
                        -- 判断双倍是否超出边界
                        self.longTouchAddNum = 4
                        self.longTouchAddNum = self:getMoreItemCanUsedNum(data)
                        -- echo("===============xxxxxxxxxx",self.longTouchAddNum)
                    else
                        self.longTouchAddNum = 1
                    end 
                    self.changanNum = self.changanNum + self.longTouchAddNum
                    data.itemNum = self.itemNum[data.itemId] or 0
                    self:getRealLevel(data)
                    self:updataLevel(data)
                    self:refreshUsedItem(data)
                    -- echo("自己家的 === ",self.changanNum)
                else
                    -- echoError("给服务器的 数量",self.changanNum)
                    if self.changanNum > 0 then
                        local _item_param = {}
                        _item_param[data.itemId] = self.changanNum
                        PartnerServer:levelupRequest({partnerId = self.partnerId,items = _item_param })
                        self.changanNum = 0
                    end 
                   
                    WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_023"))
                end
            else
                if self.changanNum > 0 then
                    local _item_param = {}
                    _item_param[data.itemId] = self.changanNum
                    PartnerServer:levelupRequest({partnerId = self.partnerId,items = _item_param })
                    self.changanNum = 0
                end
                self:delayCall(function()
                    if self.itemNum[data.itemId] <= 0 then
                        WindowControler:showWindow("GetWayListView", data.itemId);
                    end
                end, 0.15)
            end
            
        end
        local duananTap = function ()
            if self.shengjiType == 2 then
                self:setItemSelectState(data.itemId )
                self:refreshYJSJUI(self.setLevel)
                return
            end
            if self.expType == "changan" then
                self.expType = ""
                echo("长按 次数 === ".. self.changanNum)
                self.selectView = view
                if self.changanNum > 0 then    
                    self:itemEnable(false)
                    local _item_param = {}
                    _item_param[data.itemId] = self.changanNum
                    PartnerServer:levelupRequest({partnerId = self.partnerId,items = _item_param})
                    
                    self.changanNum = 0
                end
            else    
                if self.itemNum[data.itemId] > 0 then                
                    if self:isCanUpgrade() then
                        FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, anim_ctn)
                        if self.duananItemId ~= nil and self.duananItemId ~= data.itemId then
                            --此时换了升级道具 ,将之前的道具发出
                            self:duananServer()
                            self.duananItemId = data.itemId
                            echo("**************************************此时更换道具")
                            self.changeItem = true
                        end
                       -- echo("*********************此时已经消耗了")
                        self.longTouchAddNum = 1
                        self.itemNum[data.itemId] = self.itemNum[data.itemId]-1
                        data.itemNum = self.itemNum[data.itemId] or 0
                        self.expType = "duanan"
                        self.duananNum = self.duananNum + 1
                        self:getRealLevel(data)
                        self:updataLevel(data)
                        self:refreshUsedItem(data)
                        self.selectView = view
                        self.duananItemId = data.itemId

                        local _item_param = {}
                        _item_param[self.duananItemId] = 1
                        PartnerServer:levelupRequest({partnerId = self.partnerId,items = _item_param })  
                    else
                        echo("------------请提升主角等级-----------"..self.realLevel)
                        self:duananServer()
                        WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_023"))
                    end
                else
                    self:duananServer()
                    self:itemEnable(false)
                    self:delayCall(function()
                        if self.itemNum[data.itemId] <= 0 then
                            WindowControler:showWindow("GetWayListView",data.itemId);
                        end
                        self:itemEnable(true)
                    end, 0.15)

                end
            end
        end
        funcs.endFunc = duananTap
        funcs.repeatFunc = changanTap
        view:setLongTouchFunc(funcs,nil,false,0.3,0)

        if not self.isSkillledPlayer then
            self.panel_1.panel_1["panel_"..i]:pos(128 + 120 * (i - 1), -45)
        else
            self.panel_1.panel_1["panel_"..i]:pos(68 + 120 * (i - 1), -45)
        end
    end
    self.currentExp = self.data.exp
    self.currentRealExp = self.data.exp

    self.panel_1.mc_1.currentView.btn_1:setTap(c_func(self.yjsjBtnTap,self))

    if not self.isSkillledPlayer then
        self.panel_1.mc_1.currentView.btn_1:setVisible(false)

        self.panel_1.mc_1.currentView.txt_up:setString(GameConfig.getLanguage("#tid_partner_level_001"))
        -- self.panel_1.mc_1.currentView.txt_2:setVisible(false)
    else
        self.panel_1.mc_1.currentView.btn_1:setVisible(true)
        -- self.panel_1.mc_1.currentView.txt_2:setVisible(true)
        self.panel_1.mc_1.currentView.txt_up:setString(GameConfig.getLanguage("#tid_partner_level_002"))
    end

    self:updataLevel({},1)
end
-------------------------star------------------------------------
-- 道具选中状态
function PartnerUpgradeView:setItemSelectState(itemId,notRefresh)
    local state = not self.viewStateTable[itemId]
    if ItemsModel:getItemNumById(itemId) == 0 then
        self.panelStateTable[itemId]:visible(false)
    else
        self.panelStateTable[itemId]:visible(state)
    end
    self.viewStateTable[itemId] = state
    if not notRefresh then
        self:refreshYJSJUI(UserModel:level(),true)
    end
    
end

-- 拥有的经验药是否够升一级
function PartnerUpgradeView:isCanSJ(  )
    -- 当前伙伴等级
    local partnerLevel = self.level
    -- 当前经验值
    local currentExp = self.currentExp
    -- 计算当前道具最大可升的等级
    local zizhi = FuncPartner.getPartnerById(self.partnerId).aptitude;
    local levelData = FuncPartner.getConditionByLevel(partnerLevel)
    local maxExp = levelData[tostring(zizhi)].exp
    local addExp = 0
    if ItemsModel:getItemNumById(upgradeItemId["UPGRADEITEM"..5]) > 0 then
        return true
    end
    for i = 1,4 do
        local itemId = upgradeItemId["UPGRADEITEM"..i]
        local effectExp = tonumber(FuncItem.getItemData(itemId).useEffect)
        addExp = addExp + ItemsModel:getItemNumById(itemId) * effectExp
    end
    if (addExp + currentExp) >= maxExp then
        return true
    end
    return false
end
-- 一键升级 按钮事件
function PartnerUpgradeView:yjsjBtnTap( )
    -- 首先判断经验药是否够升一级 不够打开9004 的获取途径
    if self.data.level >= UserModel:level() then
        WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_023"))
        return 
    end

    if not self:isCanSJ() then
        -- WindowControler:showTips(GameConfig.getLanguage("#tid_partner_34"))
        -- 快捷购买紫色经验药
        WindowControler:showWindow("QuickBuyItemMainView", upgradeItemId["UPGRADEITEM"..4])
        -- WindowControler:showWindow("GetWayListView", upgradeItemId["UPGRADEITEM"..4]);
        return 
    end

    self.panel_1.mc_1:showFrame(2)
    self.shengjiType = 2
    for i = 1,5 do 
        self:setItemSelectState(upgradeItemId["UPGRADEITEM"..i],true)
    end

    self:initYJSJUI()
end

function PartnerUpgradeView:initYJSJUI()
    -- 道具使用情况
    local useItemT = {}
    self.userItemT = useItemT
    -- 当前目标等级
    local goalLevel = level or UserModel:level()
    -- 当前伙伴等级
    local partnerLevel = self.level 
    -- 当前经验值
    local currentExp = self.currentExp
    -- 计算当前道具最大可升的等级
    local zizhi = FuncPartner.getPartnerById(self.partnerId).aptitude;
    local levelData = FuncPartner.getConditionByLevel(partnerLevel)
    local maxExp;
    local initExp = levelData[tostring(zizhi)].exp
    maxExp = levelData[tostring(zizhi)].exp
    if maxExp then
        for i = 1,5 do 
            if partnerLevel >= goalLevel then
                break
            end
            local isEnough = false
            local itemId = upgradeItemId["UPGRADEITEM"..i]
            --判断此道具是否选中
            if self.viewStateTable[itemId] then
                local itemNum = ItemsModel:getItemNumById(itemId)
                for ii = 1,itemNum do 
                    useItemT[itemId] = ii
                    if i == 5 then
                        -- 升一级的道具
                        partnerLevel = partnerLevel + 1
                        if partnerLevel >= goalLevel then
                            -- 已升到最大等级
                            isEnough = true
                            break
                        end
                    else
                        local addExp = tonumber(FuncItem.getItemData(itemId).useEffect);
                        currentExp = currentExp + addExp
                        while  currentExp > maxExp do
                            currentExp = currentExp - maxExp
                            partnerLevel = partnerLevel + 1
                            local levelData = FuncPartner.getConditionByLevel(partnerLevel)
                            maxExp = levelData[tostring(zizhi)].exp
                        end
                        if partnerLevel >= goalLevel then
                            -- 已升到最大等级
                            isEnough = true
                            break
                        end
                    end
                end
            end
        
            if isEnough then
                break
            end
        end
    end
    
    -- 记录升到的级数
    self.setLevel = partnerLevel
    -- 使用完道具之后 UI显示
    self.panel_1.mc_1:showFrame(2)
    local panel = self.panel_1.mc_1.currentView
    -- 等级显示
    panel.txt_1:setString(partnerLevel.."/"..UserModel:level())
    -- 滑动条
    local sliderChange = function (...)
        self:delayCall(function ()
            local num = panel.slider_r:getTxtPercent()
            if partnerLevel ~= num then
                self:refreshYJSJUI(tonumber(num)) 
            end 
            
        end,0.1)
    end
    -- 滑动条
    panel.slider_r:setMinMax(self.data.level, UserModel:level());
    panel.slider_r:onSliderChange(sliderChange);
    panel.slider_r:onSliderMax((partnerLevel-self.data.level)/(UserModel:level()-self.data.level)*100)
    if self:isCanShengji() then
        panel.slider_r:setTouchEnabled(true)
    else
        panel.slider_r:setTouchEnabled(false)
    end
    local percent = (partnerLevel-self.data.level)/(UserModel:level()-self.data.level)
    if percent > 1 or UserModel:level() == self.data.level then
        percent = 1
    end
    panel.slider_r:setPercent( percent* 100)
    -- panel.txt_5:setString(0 .." / "..wnFragNum)
    for key,value in pairs(self.viewTable) do
        if ItemsModel:getItemNumById(key) > 0 then
            FilterTools.clearFilter(value);
            value:showResItemNum(true)
            local useItems = useItemT[key] or 0
            local str = ItemsModel:getItemNumById(key).."/"..useItems
            value:setResItemNumType(str)
        else
            FilterTools.setGrayFilter(value);
            value:showResItemNum(false)
        end
        if not useItemT[key] or useItemT[key] == 0 then
            self.panelStateTable[key]:visible(false)
            self.viewStateTable[key] = false
        end
    end

    panel.btn_jian:setTap(c_func(self.changeLevel,self,-1))
    panel.btn_jia:setTap(c_func(self.changeLevel,self,1))

    panel.btn_1:setTap(c_func(self.yjsjServer,self))
end
function PartnerUpgradeView:yjsjServer()
    local _item_param={}
    for key,value in pairs(self.viewTable) do
        local useItems = self.userItemT[key] or 0
        if useItems > 0 then
            echo("key ===",key ,"====== 使用的道具数量 ==== ",useItems)

            _item_param[key] = useItems
        end
    end

    local partnerData = PartnerModel:getPartnerDataById(self.data.id)
    self.oldLevel = partnerData.level

    if table.length(_item_param) > 0 then
        PartnerServer:levelupRequest({partnerId = self.partnerId,items = _item_param },
             c_func(self.yjsjCallBack,self))
    else
        local zizhi = FuncPartner.getPartnerById(self.partnerId).aptitude;
        local levelData = FuncPartner.getConditionByLevel(self.level )
        local maxExp = levelData[tostring(zizhi)].exp
        if not maxExp then -- 此时满级
            self:yjsjCallBack()
        else
            WindowControler:showTips(GameConfig.getLanguage("#tid_partner_35"))
        end
    end
    
end

function PartnerUpgradeView:powerChangedCallBack()
    EventControler:dispatchEvent(PartnerEvent.PARTNER_UPGRADE_EVENT)
end

function PartnerUpgradeView:yjsjCallBack()
    self.hasChanged = false
    FuncPartner.playPartnerLevelUpSound()
    local data = PartnerModel:getPartnerDataById(self.data.id)
    local curLevel = data.level
    local partnerId = self.data.id
    self:updataUI(data)

    for key, value in pairs(self.animCtn_table) do
        if self.userItemT[key] and self.userItemT[key] > 0 then
            FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, value)
        end
    end
    --播放战力变化特效
    self:delayCall(function ()
            self:powerChangedCallBack()
        end, 10 / GameVars.GAMEFRAMERATE)

    --播放文字爆点特效
    local offsetX = curLevel < 10 and 5 or 0
    local ctn_anim = self.panel_1.mc_1.currentView.ctn_ziBao
    FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, ctn_anim, offsetX)

    EventControler:dispatchEvent(PartnerEvent.PARTNER_LEVEL_ANIM_EVENT, 
                        {level = curLevel, partnerId = partnerId, hasChanged = self.hasChanged})

    self:dispatchPlayAttrAnimEvent(self.oldLevel, curLevel, self.star)
end
-- 一键升级UI
function PartnerUpgradeView:refreshYJSJUI(level,isChangeMax)
    -- 道具使用情况
    local useItemT = {}
    self.userItemT = useItemT
    -- 当前目标等级
    local goalLevel = level or UserModel:level()
    -- 当前伙伴等级
    local partnerLevel = self.level 
    -- 当前经验值
    local currentExp = self.currentExp
    -- 计算当前道具最大可升的等级
    local zizhi = FuncPartner.getPartnerById(self.partnerId).aptitude;
    local levelData = FuncPartner.getConditionByLevel(partnerLevel)
    local maxExp;
    maxExp = levelData[tostring(zizhi)].exp
    if maxExp then
        for i = 1,5 do 
            if partnerLevel >= goalLevel then
                break
            end
            local isEnough = false
            local itemId = upgradeItemId["UPGRADEITEM"..i]
            --判断此道具是否选中
            if self.viewStateTable[itemId] then
                local itemNum = ItemsModel:getItemNumById(itemId)
                for ii = 1,itemNum do 
                    useItemT[itemId] = ii
                    if i == 5 then
                        -- 升一级的道具
                        partnerLevel = partnerLevel + 1
                        if partnerLevel >= goalLevel then
                            -- 已升到最大等级
                            isEnough = true
                            break
                        end
                    else
                        local addExp = tonumber(FuncItem.getItemData(itemId).useEffect);
                        currentExp = currentExp + addExp
                        while  currentExp > maxExp do
                            currentExp = currentExp - maxExp
                            partnerLevel = partnerLevel + 1
                            local levelData = FuncPartner.getConditionByLevel(partnerLevel)
                            maxExp = levelData[tostring(zizhi)].exp
                        end
                        if partnerLevel >= goalLevel then
                            -- 已升到最大等级
                            isEnough = true
                            break
                        end
                    end
                end
            end
        
            if isEnough then
                break
            end
        end
    else
        -- 此时满级
    end
    
    -- 记录升到的级数
    self.setLevel = partnerLevel
    -- 使用完道具之后 UI显示
    self.panel_1.mc_1:showFrame(2)
    local panel = self.panel_1.mc_1.currentView
    -- 等级显示
    panel.txt_1:setString(partnerLevel.."/"..UserModel:level())
    if self:isCanShengji() then
        panel.slider_r:setTouchEnabled(true)
    else
        panel.slider_r:setTouchEnabled(false)
    end
    local percent = (partnerLevel-self.data.level)/(UserModel:level()-self.data.level)
    if percent > 1 or UserModel:level() == self.data.level then
        percent = 1
    end
    if isChangeMax then
        panel.slider_r:onSliderMax(percent* 100)
    end
    
    -- panel.slider_r:setPercent( percent* 100)

    -- panel.txt_5:setString(0 .." / "..wnFragNum)
    for key,value in pairs(self.viewTable) do
        if ItemsModel:getItemNumById(key) > 0 then
            FilterTools.clearFilter(value);
            value:showResItemNum(true)
            local useItems = useItemT[key] or 0
            local str = ItemsModel:getItemNumById(key).."/"..useItems
            value:setResItemNumType(str)
        else
            FilterTools.setGrayFilter(value);
            value:showResItemNum(false)
        end
        --if not useItemT[key] or useItemT[key] == 0 then
        --    self.panelStateTable[key]:visible(false)
        --    self.viewStateTable[key] = false
        --end
    end
end

-- 判断现有道具是否可生一级
function PartnerUpgradeView:isCanShengji()
    if self.level >= UserModel:level() then
        return false
    end
    -- 当前经验值
    local currentExp = self.currentExp
    -- 计算当前道具最大可升的等级
    local zizhi = FuncPartner.getPartnerById(self.partnerId).aptitude;
    local levelData = FuncPartner.getConditionByLevel(self.level)
    local maxExp;
    maxExp = levelData[tostring(zizhi)].exp
    for i = 1,5 do 
        local itemId = upgradeItemId["UPGRADEITEM"..i]
        --判断此道具是否选中
        if self.viewStateTable[itemId] then
            local itemNum = ItemsModel:getItemNumById(itemId)
            for ii = 1,itemNum do  
                if i == 5 then
                    return true
                else
                    local addExp = FuncItem.getItemData(itemId).useEffect;
                    currentExp = currentExp + addExp
                    if currentExp > maxExp then
                        return true
                    end
                end
            end
        end
        
    end

    return false
end

function PartnerUpgradeView:changeLevel(num)
    local tempLevel = self.setLevel + num
    if tempLevel > UserModel:level() then
        return
    end
    if tempLevel < self.level then
        return
    end

    self.setLevel = self.setLevel + num
    self:refreshYJSJUI(self.setLevel)

    local percent = (self.setLevel-self.data.level)/(UserModel:level()-self.data.level)
    if percent > 1 or UserModel:level() == self.data.level then
        percent = 1
    end
    local panel = self.panel_1.mc_1.currentView
    panel.slider_r:setPercent( percent* 100)
end
----------------------end-----------------------------------
function PartnerUpgradeView:duananServer()
    if true then
        return
    end
    if self.duananSchedulerId then
        if self.duananNum > 0 then
            self:itemEnable(false)
            echoError("________duananServer________")
            echo("---------------------------------self.duananItemId = "..self.duananItemId.."  self.duananNum = "..self.duananNum)
            local _item_param = {}
            _item_param[self.duananItemId] = self.duananNum
            PartnerServer:levelupRequest({partnerId = self.partnerId,items = _item_param })
            self.duananNum = 0
        end
        self:stopAction(self.duananSchedulerId)
        self:unscheduleUpdate()
        self.duananSchedulerId = nil
    end          
end
-- 设置经验道具是否可点
function PartnerUpgradeView:itemEnable(_enable)
    if self.viewTable then
        for key,value in pairs(self.viewTable) do
            if value then
                value:setTouchEnabled(_enable)
            end
        end
    end
end
-- 是否满足升级条件，伙伴等级小于人物等级
function PartnerUpgradeView:isCanUpgrade()     
    if self.realLevel > UserModel:level() then
        self:duananServer()
        return false
    else
        local levelData = FuncPartner.getConditionByLevel(self.realLevel)
        local zizhi = FuncPartner.getPartnerById(self.partnerId).aptitude;
        local maxExp = levelData[tostring(zizhi)].exp
        if self.realLevel == UserModel:level() and 
            maxExp <= self.currentExp then
            return false
        end
        return true
    end
end
function PartnerUpgradeView:itemRefresh()
    self:itemEnable(false)
    
    for key,value in pairs(self.viewTable) do
        if ItemsModel:getItemNumById(key) > 0 then
            FilterTools.clearFilter(value);
            value:showResItemNum(true)
            value:setResItemNum(ItemsModel:getItemNumById(key))
        else
            FilterTools.setGrayFilter(value);
            value:showResItemNum(false)
        end
        self.itemNum[key] = ItemsModel:getItemNumById(key)
    end

    self:delayCall(c_func(self.itemEnable, self,true), 0.2) 
end

function PartnerUpgradeView:upgradeCallBack(event)
    --刷新战力
    self.data = PartnerModel:getPartnerDataById(self.data.id)
end

--判断同时添加多个经验道具的个数
function PartnerUpgradeView:getMoreItemCanUsedNum(data)
    local addNum = 1
    local level = self.realLevel
    local realExp = self.currentRealExp
    local _exp = realExp
    if self.changanNum >= 8 then 
        for i = 1,self.longTouchAddNum do
            -- 数量是否足够
            if self.itemNum[data.itemId] <= addNum then
                return addNum
            end
            local levelData = FuncPartner.getConditionByLevel(level)
            local zizhi = FuncPartner.getPartnerById(self.partnerId).aptitude;
            local maxExp = levelData[tostring(zizhi)].exp
            local exp = 0;
            if data.subType == 308 then -- 308代表升一级的道具
                exp = maxExp 
            else
                exp = data.exp or 0
            end
            _exp = tonumber(exp) + _exp
            while  _exp > maxExp do
                _exp = _exp - maxExp
                level = level + 1

                if level >= UserModel:level() then
                    -- echo("pppppppppppppp ==========",addNum)
                    return addNum
                end

                levelData = FuncPartner.getConditionByLevel(level)
                maxExp = levelData[tostring(zizhi)].exp
        
                local levelData = FuncPartner.getConditionByLevel(level)
                if levelData then
                    maxExp = levelData[tostring(zizhi)].exp
                    if maxExp == nil then
                        -- 满级
                        return addNum
                    end
                else
                    -- 满级
                    return addNum
                end
            end
            addNum = i
        end
        return addNum
    else
        return addNum
    end
end
--计算加经验后 真实的等级
function PartnerUpgradeView:getRealLevel(data)
    if data.exp == nil then
        return self.realLevel
    end
    local levelData = FuncPartner.getConditionByLevel(self.realLevel)
    local zizhi = FuncPartner.getPartnerById(self.partnerId).aptitude;
    local maxExp = levelData[tostring(zizhi)].exp
    local exp = 0;
    if data.subType == 308 then -- 308代表升一级的道具
        exp = maxExp 
    else
        exp = data.exp * self.longTouchAddNum or 0
    end
    local _exp = tonumber(exp) + self.currentRealExp
    while  _exp >= maxExp do
        _exp = _exp - maxExp
        self.realLevel = self.realLevel + 1

        if self.realLevel > 99 then
            return 
        end

        levelData = FuncPartner.getConditionByLevel(self.realLevel)
        maxExp = levelData[tostring(zizhi)].exp
        if self.realLevel >= UserModel:level() then
            if _exp > maxExp then
                _exp = maxExp
            end
            break
        end
        local levelData = FuncPartner.getConditionByLevel(self.realLevel)
        if levelData then
            maxExp = levelData[tostring(zizhi)].exp
            if maxExp == nil then
                -- 满级
                self.realLevel = UserModel:level()
                break
            end
        else
            -- 满级
            self.realLevel = UserModel:level()
            break
        end
    end
    self.currentRealExp = _exp
    if self.realLevel > UserModel:level() then
        self.realLevel = UserModel:level()
    end
    return self.realLevel
end

--添加升级特效
function PartnerUpgradeView:updateProgressAnim(percent, ctn_anim)
    -- local ctn_anim = self.panel_1.mc_1.currentView.panel_progress.ctn_progress
    local guangxiao = nil
    local zhezhao = nil

    if not ctn_anim:getChildByName("jindu") then
        local jinduAnim = self:createUIArmature("UI_qixiajindutiao", "UI_qixiajindutiao", ctn_anim, true)
        local runTag = self:createUIArmature("UI_qixiajindutiao", "UI_qixiajindutiao_dutiao", ctn_anim, true)
        jinduAnim:setName("jindu")
        runTag:setName("run")
    end
 
    if ctn_anim:getChildByName("jindu") then
        local anim = ctn_anim:getChildByName("jindu")
        local anim1 = anim:getBoneDisplay("layer4")
        zhezhao = anim1:getBoneDisplay("zhezhao")
        guangxiao = ctn_anim:getChildByName("run")
    end
    

    zhezhao:pos(math.ceil(percent)*1.0/100 * 210 - 95, -6)
    guangxiao:pos(math.ceil(percent)*1.0/100 * 210 - 100, -1)
    if percent <= 5 then
        guangxiao:setVisible(false)
    else
        guangxiao:setVisible(true)
    end
end

function PartnerUpgradeView:updateBoomAnim(_callBack)
    if not self.boomAnim then
        self.boomAnim = self:createUIArmature("UI_qixiajindutiao", "UI_qixiajindutiao_man", self.panel_1.ctn_zha, true)
        self.boomAnim:pos(0, -2)
        self.boomAnim:pause()
    else
        self.boomAnim:pause()
    end

    self.boomAnim:registerFrameEventCallFunc(5, 1, function ()
            if _callBack then
                _callBack()
            end 
        end)

    self.boomAnim:startPlay(false, true)
end

function PartnerUpgradeView:tweenToPercentByAnim(progress, targetPercent, ctn_anim)
    self.progressBar = progress
    self.curPercent = self.progressBar:getPercent()

    --先取消刷新
    self:unscheduleUpdate()
    --如果差距太小就不缓动了

    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self, ctn_anim), 1)
end

function PartnerUpgradeView:updateFrame(ctn_anim)
    if self.hasChanged then
        return
    end
    local percent = self.progressBar:getPercent()
    if percent < 100 then
        percent = math.ceil(percent)
    else
        percent = 100

    end

    self:updateProgressAnim(percent, ctn_anim)
end

function PartnerUpgradeView:dispatchPlayAttrAnimEvent(oldLevel, curLevel, star)
    local attr = {}
    local partnerId = self.partnerId
    -- local oldLevel_str = string.format("<color = 33ff00>%s<->", GameConfig.getLanguage("#tid_partner_ui_006")..oldLevel)
    local curLevel_str = string.format("<color = 33ff00>%s<->", GameConfig.getLanguage("#tid_partner_leveltips_001")..curLevel)
    local oldLevel_str = GameConfig.getLanguage("#tid_partner_leveltips_001")..oldLevel
    -- local curLevel_str = GameConfig.getLanguage("#tid_partner_leveltips_001")..curLevel
    attr[1] = oldLevel_str.." [partner/partner_img_jiantou.png] "..curLevel_str
    local attr_str = FuncPartner.getAttrForLevelUp(self.partnerId, curLevel - oldLevel, star)
    for i,v in ipairs(attr_str) do
        table.insert(attr, v)
    end
    EventControler:dispatchEvent(PartnerEvent.PARTNER_ATTR_ANIM_EVENT, 
                        {_type = "level", attr = attr, partnerId = partnerId})
end

function PartnerUpgradeView:updataLevel(data,sound)
    -- 音效
    if sound == nil then
        FuncPartner.playPartnerLevelUpSound()
    end
    --升级需要的经验值
    --资质
    local ctn_anim = self.panel_1.mc_1.currentView.ctn_ziBao
    local levelTxt = self.panel_1.mc_1.currentView.txt_1
    local progressPanel = self.panel_1.mc_1.currentView.panel_progress
    local progressBar = progressPanel.progress_1
    local zizhi = FuncPartner.getPartnerById(self.partnerId).aptitude;
    local levelData = FuncPartner.getConditionByLevel(self.level)
    local partnerId = self.partnerId
    local maxExp;
    maxExp = levelData[tostring(zizhi)].exp
    if maxExp == nil then
        -- 此时已满级
        progressBar:setPercent(100)
        -- 进度条显示
        progressPanel.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_024"))
        -- 等级显示
        local currentLevel = self.level
        levelTxt:setString(currentLevel..GameConfig.getLanguage("#tid_partner_ui_013"))
        return 
    end
    local exp = 0;
    if data.subType == 308 then -- 308代表升一级的道具
        exp = maxExp
    else
        if data.exp then
            exp = data.exp * self.longTouchAddNum
        else
            exp = 0
        end
         
    end
    if exp == 0 then -- 此处第一次进入升级时用到
        progressBar:setPercent(self.currentExp/maxExp*100)
        self:updateProgressAnim(self.currentExp/maxExp*100, progressPanel.ctn_progress)
        -- 进度条显示
        progressPanel.txt_1:setString(self.currentExp .. "/" .. maxExp)
        -- 等级显示
        local currentLevel = self.level
        levelTxt:setString(currentLevel..GameConfig.getLanguage("#tid_partner_ui_013"))

    else
        -- echo("----------------************-------------------updataLevel id = "..data.itemId .. " exp = "..data.exp)
        
        self.hasChanged = false
        local speed = exp / 4
        local lastExp = self.currentExp

        self.currentExp = self.currentExp + exp
        local upgrade = false 
        if self.currentExp >= maxExp and self.level < UserModel:level() then
            self.currentExp = self.currentExp - maxExp 
            self.level = self.level + 1
            if self.level > UserModel:level() then
                self.level = self.level - 1
                self.currentExp = maxExp
                upgrade = false
            else
                upgrade = true  
            end
            
        end
        function progressCallBack()
            if self.hasChanged then
                return
            end
            maxExp = FuncPartner.getConditionByLevel(self.level)[tostring(zizhi)].exp
            if maxExp == nil then
                -- 此时已满级
                progressBar:setPercent(100)
                -- 进度条显示
                progressPanel.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_024"))
                -- 等级显示
                local currentLevel = self.level
                levelTxt:setString(currentLevel..GameConfig.getLanguage("#tid_partner_ui_013"))
                EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
                return 
            end
            if self.level >= UserModel:level() then
                if self.currentExp > maxExp then
                    self.currentExp = maxExp
                end
            end

            -- 进度条显示
            progressPanel.txt_1:setString(self.currentExp .. "/" .. maxExp)
            -- 等级显示
            local currentLevel = self.level
            levelTxt:setString(currentLevel..GameConfig.getLanguage("#tid_partner_ui_013"))
            local isUpgrade = false;
            if self.currentExp >= maxExp and currentLevel < UserModel:level() then
                local levelData = FuncPartner.getConditionByLevel(self.level)
                maxExp = levelData[tostring(zizhi)].exp
                self.currentExp = self.currentExp - maxExp
                self.level = self.level + 1
                isUpgrade = true
                speed = maxExp / 9
            else
                speed = self.currentExp / 4
            end
            progressBar:setPercent(0)
            if isUpgrade then       
                local _time = maxExp / speed
                progressBar:tweenToPercent(100,_time+1,function ()
                        -- self:updateBoomAnim(c_func(progressCallBack))
                        -- self:updateBoomAnim()
                        self:delayCall(function ()
                                if self.hasChanged then
                                    return
                                end
                                local offsetX = self.level < 10 and 5 or 0
                                FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, ctn_anim, offsetX)
                                progressCallBack()
                                EventControler:dispatchEvent(PartnerEvent.PARTNER_LEVEL_ANIM_EVENT, 
                                                    {level = self.level, partnerId = partnerId, hasChanged = self.hasChanged})

                                if not (self.hasDispatchedLvel and self.hasDispatchedLvel == self.level) then
                                    self.hasDispatchedLvel = self.level
                                    self:dispatchPlayAttrAnimEvent(self.level - 1, self.level, self.star)
                                end
                            end, 1/30)
                        self:delayCall(function ()
                                if self.hasChanged then
                                    return
                                end
                                if self.realLevel == self.level then
                                    self:powerChangedCallBack()
                                    EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
                                end
                            end, 10/30)
                    end)
                self:tweenToPercentByAnim(progressBar, 100, progressPanel.ctn_progress)
            else
                local _time = self.currentExp / speed;
                progressBar:tweenToPercent(self.currentExp/maxExp*100,_time, function ()
                        self:delayCall(function ()
                                if self.hasChanged then
                                    return
                                end
                                if self.realLevel == self.level then
                                    self:powerChangedCallBack()
                                    EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
                                end
                            end, 10/30)
                    end)
                self:tweenToPercentByAnim(progressBar, self.currentExp/maxExp*100, progressPanel.ctn_progress)
            end
        end


        if upgrade then
            if not self.isSkillledPlayer then
                EventControler:dispatchEvent(PartnerEvent.PARTNER_PINGBI_UICLICK_EVENT, 1)
            end
            local _time = (maxExp - lastExp) / speed;
            progressBar:tweenToPercent(100,_time,function ()
                    -- self:updateBoomAnim()
                    self:delayCall(function ()
                                if self.hasChanged then
                                    return
                                end
                                local offsetX = self.level < 10 and 5 or 0
                                FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, ctn_anim, offsetX)
                                progressCallBack()
                                EventControler:dispatchEvent(PartnerEvent.PARTNER_LEVEL_ANIM_EVENT, 
                                                    {level = self.level, partnerId = partnerId, hasChanged = self.hasChanged})

                                if not (self.hasDispatchedLvel and self.hasDispatchedLvel == self.level) then
                                    self.hasDispatchedLvel = self.level
                                    self:dispatchPlayAttrAnimEvent(self.level - 1, self.level, self.star)
                                end
                            end, 1/30)
                    self:delayCall(function ()
                                if self.hasChanged then
                                    return
                                end
                                if self.realLevel == self.level then
                                    self:powerChangedCallBack()
                                    EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
                                end
                            end, 10/30)
                end)
            self:tweenToPercentByAnim(progressBar, 100, progressPanel.ctn_progress)
        else
            progressBar:tweenToPercent(self.currentExp/maxExp*100, 8, function ()
                    self:delayCall(function ()
                                if self.hasChanged then
                                    return
                                end
                                if self.realLevel == self.level then
                                    self:powerChangedCallBack()
                                    EventControler:dispatchEvent(PartnerEvent.PARTNER_HUIFU_UICLICK_EVENT)
                                end
                            end, 10/30)
                end)
            self:tweenToPercentByAnim(progressBar, self.currentExp/maxExp*100, progressPanel.ctn_progress)

            if self.level >= UserModel:level() then
                if self.currentExp > maxExp then
                    self.currentExp = maxExp
                end
            end
            -- 进度条显示
            progressPanel.txt_1:setString(self.currentExp .. "/" .. maxExp)
            -- 等级显示
            local currentLevel = self.level
            levelTxt:setString(currentLevel..GameConfig.getLanguage("#tid_partner_ui_013"))
        end
    end
end

--刷新 正在使用的道具
function PartnerUpgradeView:refreshUsedItem(data)
 --刷新道具数量
    if data.view and data.itemId then
        data.view:setResItemNum(data.itemNum)
        if data.itemNum > 0 then
            FilterTools.clearFilter(data.view);
            data.view:showResItemNum(true)
            data.view:setResItemNum(data.itemNum)
        else
            FilterTools.setGrayFilter(data.view);
            data.view:showResItemNum(false)
        end
    end
end
function PartnerUpgradeView:loadUIComplete()
	self:setAlignment()
	self:registerEvent()
    -- local x = self.panel_1:getPositionX()
    -- local y = self.panel_1:getPositionY()
    -- self.panel_1:setPositionX(x+480)

    -- local moveAnim = act.moveto(UI_MOVE_TIME,x,y)
    -- self.panel_1:runAction(moveAnim)

    -- self:updataUI(self.data)
end
function PartnerUpgradeView:setAlignment()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1,UIAlignTypes.MiddleBottom)
end
function PartnerUpgradeView:openPartnerInfoUI()
    WindowControler:showWindow("PartnerInfoUI",self.data.id)
end

return PartnerUpgradeView
