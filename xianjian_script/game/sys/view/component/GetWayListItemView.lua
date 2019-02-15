local GetWayListItemView = class("GetWayListItemView", UIBase);

function GetWayListItemView:ctor(winName)
    GetWayListItemView.super.ctor(self, winName);
end

function GetWayListItemView:loadUIComplete()
    self.mc_1:showFrame(1)

    self.btn = self.mc_1.currentView.btn_1
	self.panelInfo = self.btn.spUp.panel_1

    self:registerEvent();
end 

function GetWayListItemView:registerEvent()
	GetWayListItemView.super.registerEvent();

    self.btn:setTap(c_func(self.pressGetWayItem, self));
    -- self.mc_1:setTouchedFunc(c_func(self.pressGetWayItem, self))

    --接受事件
    -- EventControler:addEventListener(UIEvent.UIEVENT_STARTHIDE, 
    --     self.onUIStartHide,self)
end

--设置道具数据
function GetWayListItemView:setGetWayItemData(getWayId,listView, getWayView)
	self.listView = listView
	self.getWayId = getWayId
    self._getWayView = getWayView;

    if getWayId == nil or getWayId == "" then
        self.mc_1:showFrame(2)
        return
    end
    echo("\n\n==getWayId==", getWayId)
    local getWayData = FuncCommon.getGetWayDataById(getWayId)

    self.getWayData = getWayData
    self.getWayType = self.getWayData.type

    -- 类型3不需要跳转
    if self.getWayType == FuncCommon.GETWAY_TYPE.TYPE_3 then
        self.mc_1:showFrame(3)
    end

    -- 描述
    self:setGetWayDes()

    -- 依赖的功能索引
    local funcIndex = self.getWayData.index

    self.isOpen = true
    ---- 新安当 特殊判断一下
    if self.getWayId == "1215" then 
        self.isOpen = true
    else
        self.isOpen = ItemsModel:isGetWayOpen(getWayData)
    end

    if not self.isOpen then
        FilterTools.setGrayFilter(self.btn);
    end 
end

-- 获取展示描述
function GetWayListItemView:getDisplayDes()
    local desDetail = ""
    local des = self.getWayData.des
    -- 副本类型
    if tonumber(self.getWayType) == FuncCommon.GETWAY_TYPE.TYPE_2 and self.getWayData.index ~= FuncCommon.SYSTEM_NAME.TRAIL then
        desDetail = WorldModel:getGetWayDes(self.getWayData.raidId,des)
    elseif tonumber(self.getWayType) == FuncCommon.GETWAY_TYPE.TYPE_4 then
        --五灵珠类型描述由动态生成的数据提供
        desDetail = self.getWayData.description
    else
        if des then
            desDetail = GameConfig.getLanguage(des) or ""
        end
    end

    return desDetail or ""
end

function GetWayListItemView:setGetWayDes()
    local desStr = GameConfig.getLanguage(self.getWayData.name) or ""

    if self.getWayType == FuncCommon.GETWAY_TYPE.TYPE_3 then 
        self.mc_1.currentView.txt_1:setString(desStr)
    else
        local desDetail = self:getDisplayDes()
        self.panelInfo.txt_1:setString("【" .. desStr .. "】")
        self.panelInfo.txt_2:setString(" ".. desDetail)
    end
end

-- 设置资源目标Id，用于资源追踪
function GetWayListItemView:setTargetResId(targetResId)
    self.targetResId = targetResId
end

-- 设置资源目标数量(需求数量)，用于资源追踪
function GetWayListItemView:setTargetResNum(targetResNum)
    self.targetResNum = targetResNum
end

function GetWayListItemView:pressGetWayItem()
	echo("点击获取途径，跳转到对应系统 getWayId=",self.getWayId)
    -- dump(self.getWayData, "\n\nself.getWayData===")

    if self.getWayId == nil or self.getWayId == "" then 
        return
    end

    local linkStr = self.getWayData.link
    local linkPara = self.getWayData.linkPara
    local index = self.getWayData.index
    -- 类型3不需要跳转
    if self.getWayType and self.getWayType == 3 then
        return
    end

    if linkStr == nil then
        echoError("GetWayListItemView:pressGetWayItem linkStr is nil")
        return
    end

    if self.listView ~= nil and self.listView:isMoving() then
        return
    end
    echo("linkStr = = = = = = = = ",linkStr)
    echo("index = = = = == = == = ",index)
    if not self.isOpen then

        if linkStr == "UI_world_new_3" or linkStr == "UI_elite_liebiao" then
            WindowControler:showTips(GameConfig.getLanguage("tid_item_5004"))
        elseif linkStr == "UI_shop" and FuncCommon.isSystemOpen(index) then
            WindowControler:showTips(GameConfig.getLanguage("tid_rank_1015"))
        elseif linkStr == "UI_mall_main" and FuncCommon.isSystemOpen(index) then
            WindowControler:showTips(GameConfig.getLanguage("tid_common_2079"))
        elseif linkStr == "UI_guild_dig" and FuncCommon.isSystemOpen(index) then
            WindowControler:showTips(GameConfig.getLanguage("tid_group_guild_1605"))
        elseif linkStr == "UI_guild_baoku" and FuncCommon.isSystemOpen(index) then
            WindowControler:showTips(GameConfig.getLanguage("tid_group_guild_1605"))
        elseif linkStr == "UI_gcmj_main" and FuncCommon.isSystemOpen(index) then
            WindowControler:showTips(GameConfig.getLanguage("tid_group_guild_1605"))
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_common_2002"))
        end        
        return
    end

    if linkStr ~= nil then
        -- local linkArr = string.split(linkPara, ",");
        local linkArr = self:buildLinkParamsArr(linkPara)
        local viewClassName = WindowsTools:getWindowNameByUIName(linkStr)

        -- 如果是PVE类型跳转
        if self.getWayData.index == FuncCommon.SYSTEM_NAME.PVE 
            and viewClassName == "WorldPVEListView" then
            local fromGetWay = true
            WorldControler:jumpToPVEView(fromGetWay,unpack(linkArr))
        elseif self.getWayData.index == FuncCommon.SYSTEM_NAME.ENDLESS then
            EndlessControler:enterEndlessMainView(unpack(linkArr))
        elseif self.getWayData.index == FuncCommon.SYSTEM_NAME.SHAREBOSS then
            ShareBossControler:enterShareBossMainView()
        elseif viewClassName == "GuildTreasureMainView" then
            WindowControler:showWindow(viewClassName, 2)
        elseif self.getWayData.index == "shop7" then  ---- 灵石商店
            WindowControler:showWindow("WelfareNewMinView", unpack(linkArr))
        else
            if viewClassName == "GuildBossOpenView" then
                GuildControler:showGuildBossUI()
            -- TODO 特殊处理福利-在当前页面中跳转到其他页签
            elseif viewClassName == "WelfareNewMinView" then
                WindowControler:closeWindow(viewClassName)
                WindowControler:showWindow(viewClassName, unpack(linkArr))
            else
                WindowControler:showWindow(viewClassName, unpack(linkArr))
            end        
        end
        
        if self._getWayView ~= nil then
            -- self._getWayView:setVisible(false);
            -- self._jumpToViewName = viewClassName;
            self._getWayView:startHide();
        end 
    end
end

function GetWayListItemView:buildLinkParamsArr(linkPara)
    local linkParamsArr = {}
    if linkPara then
        linkParamsArr = table.deepCopy(linkPara)
        echo("\n\nself.targetResId===", self.targetResId, "self.targetResNum===", self.targetResNum)
        if self.targetResNum then
            linkParamsArr[#linkParamsArr+1] = self.targetResId
            linkParamsArr[#linkParamsArr+1] = self.targetResNum
        end
    end
    return linkParamsArr
end

-- function GetWayListItemView:onUIStartHide(e)
--     local targetUI = e.params.ui;
--     if targetUI.windowName == self._jumpToViewName then 
--         self._getWayView:setVisible(true);
--     end 
-- end

function GetWayListItemView:updateUI()
	
end

return GetWayListItemView;
