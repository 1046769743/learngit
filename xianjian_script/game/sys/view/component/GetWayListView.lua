--[[
    --
    -- Author: ZhangYanguang
    -- Date: 2016-04-12
    -- 道具或资源获取途径公共弹出框组件
    参数：resId 资源ID
]]

local GetWayListView = class("GetWayListView", UIBase);

--[[
    resId:资源ID
    resNeedNum:资源需求数量
]]
function GetWayListView:ctor(winName,resId,resNeedNum,lingbaochan)
    GetWayListView.super.ctor(self, winName);
    self.resId = tostring(resId)
    self.resNeedNum = resNeedNum
    self.lingbaochan = lingbaochan   ---- 仙盟挖宝铲子特殊
    echo("\n\nself.resId===", self.resId, "self.resNeedNum==", self.resNeedNum)
    -- 资源是否是道具
    self.isItemRes = false
end

function GetWayListView:loadUIComplete()
	self:registerEvent();

    self:initData()
    self:initScrollCfg()

    self:updateUI()
    self:registClickClose("out")
end 

function GetWayListView:initData()
    local isItem = FuncItem.checkItemById(self.resId)
    if isItem == true then
        self.isItemRes = true
        -- 是道具
        self.itemData = FuncItem.getItemData(self.resId)
        self.getWayListData = nil
 
        --五灵珠类型需要特殊处理  动态生成获取途径列表 这个需求取消了
        -- local itemSubTyes = ItemsModel:getSubTypeDisplay()
        -- if self.itemData.subType_display == itemSubTyes.ITEM_SUBTYPE_314 then
        --     self.getWayListData = ItemsModel:creatDynamicAccess(self.itemData.subType_display, self.resId, self.itemData.accessWay)
        -- else
            self.getWayListData = self.itemData.accessWay
            -- 获取途径id降序排
            ItemsModel:sortGetWayListData(self.getWayListData)
        -- end

        if self.getWayListData == nil then
            self.getWayListData = {}
        end
        
        
    else
        -- 非道具资源
        local   _baseResource=FuncDataResource.getDataByID(self.resId);
        self.getWayListData = _baseResource.accessWay--FuncDataResource.getDataAccessWay(self.resId)
        if(_baseResource.listName ~=nil and _baseResource.listName~="")then
               self.txt_1:setString(GameConfig.getLanguage( _baseResource.listName));
        end
    end
end 

function GetWayListView:initScrollCfg()
    -- 创建途径item
    local createGetWayItemFunc = function ( itemData )
        local view = WindowsTools:createWindow("GetWayListItemView")
        -- 设置目标资源Id和数量
        view:setTargetResId(self.resId)
        if self.resNeedNum then
            view:setTargetResNum(self.resNeedNum)
        end
        
        view:setGetWayItemData(itemData,self.scroll_list,self)
        return view
    end

    self.__getWaylistParams = {
        {
            data = self.getWayListData,
            createFunc = createGetWayItemFunc,
            itemRect = {x=0,y=-78,width = 385,height = 78},
            perNums= 1,
            offsetX = 27,
            offsetY = 10,
            widthGap = -12,
            heightGap = -6,
            perFrame = 4
        },
    }
end

function GetWayListView:registerEvent()
	GetWayListView.super.registerEvent();
    self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self));
    -- 隐藏不需要的按钮
    self.UI_1.mc_1:setVisible(false)
end

function GetWayListView:updateUI()
   if(#self.__getWaylistParams>0 and self.__getWaylistParams[1].data ~=nil)then
    self.scroll_list:styleFill(self.__getWaylistParams)
    -- echo("GetWayList self.resId=",self.resId)
    end
    local resDesc = ""
    local resName = ""
    local resNum = 0
    local params = {}

    -- 如果是道具
    if self.isItemRes then
        local itemData = self.itemData
        resDesc = GameConfig.getLanguage(itemData.des)
        resName = GameConfig.getLanguage(itemData.name)

        resNum = ItemsModel:getItemNumById(self.resId)
        params = {
            itemId = self.resId,
            resNum = resNum,
        }

    -- 非道具资源
    else
        params.reward = self.resId .. ",0"
        resName = FuncDataResource.getResNameById(self.resId)
        resDesc = FuncDataResource.getResDescrib(self.resId)

        local _,hasNum = UserModel:getResInfo(params.reward)
        resNum = hasNum
        if self.lingbaochan ~= nil then
            resNum = self.lingbaochan
        end
    end
    self.UI_goods:setResItemData(params)
    self.UI_goods:showResItemNum(false)

    -- 获取途径
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid32107"))

    -- 资源名字
    self.txt_2:setString(resName)
    local resInfoDesc = GameConfig.getLanguageWithSwap("tid_common_2012",resNum)

    -- 数量描述
    self.rich_3:setString(resInfoDesc)
    if self.resId == FuncDataResource.RES_TYPE.EXP then
        self.rich_3:setVisible(false)
    else
        self.rich_3:setVisible(true)
    end
    -- 用途描述
    self.txt_4:setString(resDesc)
end

function GetWayListView:press_btn_close()
    self:startHide()
end

function GetWayListView:combineTxt()
    self.rich_3:setString(GameConfig.getLanguage("tid_common_2016"));
    self.txt_4:setVisible(false);
end

return GetWayListView;
