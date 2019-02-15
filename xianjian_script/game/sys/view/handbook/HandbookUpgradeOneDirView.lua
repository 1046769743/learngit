--
--Author:      zhuguangyuan
--DateTime:    2018-05-22 16:10:26
--Description: 名册系统 - 册系等级提升界面
--

local HandbookUpgradeOneDirView = class("HandbookUpgradeOneDirView", UIBase);

function HandbookUpgradeOneDirView:ctor(winName,dirId)
    HandbookUpgradeOneDirView.super.ctor(self, winName)
    self.dirId = dirId
end

function HandbookUpgradeOneDirView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function HandbookUpgradeOneDirView:registerEvent()
	HandbookUpgradeOneDirView.super.registerEvent(self);
    self.panel_1.btn_close:setTap(c_func(self.onClose,self))
	self.btn_1:setTap(c_func(self.upgradeOneDir,self))
	self:registClickClose("out")

    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE,self.refreshView,self)
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.refreshView, self)

end

function HandbookUpgradeOneDirView:upgradeOneDir()
    dump(self.dirData.cost, "self.dirData.cost", nesting)
    local isConditionOk = UserModel:isResEnough(self.dirData.cost) --true
    -- for k,itemString in pairs(self.dirData.cost) do
    --     local oneItemArr = string.split(itemString,",")
    --     local resType = oneItemArr[1]
    --     local needNum = tonumber(oneItemArr[#oneItemArr])
    --     isConditionOk = isConditionOk and UserModel:tryCost(resType, needNum, true)
    -- end

    if isConditionOk ~= true then

        --铜币不足 弹出tips
        if self.needMoney > UserModel:getCoin() then
            WindowControler:showTips(GameConfig.getLanguage(self._errorStr),1)
            FuncCommUI.showCoinGetView() 
            return
        end

        if self._errorStr then
            local costItem = self.dirData.cost[1]
            costItem = string.split(costItem,",")
            WindowControler:showWindow("GetWayListView", costItem[2]);
            WindowControler:showTips(GameConfig.getLanguage(self._errorStr),1)
        else
            WindowControler:showTips("提升条件不足",1)
        end
        
        return
    end
    -- if not self.hasSentRequest then
        self.hasSentRequest = true
        local function _callBack(serverData)
            if serverData.error then
                return
            else
                -- dump(serverData.result.data, "desciption", nesting)
                -- UserModel:updateData(serverData.result.data)
                -- HandbookModel:updateData(serverData.result.data)
                -- if HandbookModel:getOneDirLevel( self.dirId ) == 8 then
                --     self:onClose()
                --     return
                -- end
                self:refreshView()
                EventControler:dispatchEvent(HandbookEvent.ONE_DIR_UPGRADE_SUCCEED)
                HandbookModel:onePartnerPosChanged()
                -- self:onClose()
            end
        end
        HandbookServer:upgradeOneDir(self.dirId,_callBack)
    -- end
end


function HandbookUpgradeOneDirView:refreshView(  )
    self._errorStr = nil
    self:initData()
    self:initView()
end

function HandbookUpgradeOneDirView:initData()
	local dirLevel = HandbookModel:getOneDirLevel( self.dirId )
	self.dirData = FuncHandbook.getOneDirLvData( self.dirId,dirLevel )
end

function HandbookUpgradeOneDirView:initView()
	self.panel_1.txt_1:setString("提升名册")
	-- self.UI_1:visible(false)
    self.ctn_3:removeAllChildren()
    local icon = FuncHandbook.getDirIconSp( self.dirId ):addto(self.ctn_3)

	local curLevel = HandbookModel:getOneDirLevel( self.dirId )
	local nextLevel = curLevel + 1
	local curData = FuncHandbook.getOneDirLvData( self.dirId,curLevel )
	local nextData = FuncHandbook.getOneDirLvData( self.dirId,nextLevel )
    local nextAddition = 0
    if nextData then
        nextAddition = (nextData.score/100).."%"
    else 
        WindowControler:showTips("已达到最大等级")
        self:onClose()
        return
    end
	-- 富文本显示标题
	local dirName = FuncHandbook.dirId2Name[tostring(self.dirId)]
    -- dump(self.dirData,"dirData")
    -- dump(nextData,"nextData")
	local curcolor = self.dirData.color
    local nextcolor = nextData.color
	local dirName1 = "<color = "..curcolor..">"..dirName.."+"..curLevel.."<->"
	self.rich_1:setString(dirName1)
	self.rich_2:setString(dirName1)
	local dirName2 = "<color = "..nextcolor..">"..dirName.."+"..nextLevel.."<->"
	self.rich_3:setString(dirName2)

	local curAddition = (curData.score/100).."%"
	
	self.txt_3:setString(curAddition)
	self.txt_4:setString(nextAddition)

	-- 提升等级需要花费的仙玉
	local needMoney = self.dirData.cost[2]
	needMoney = string.split(needMoney,",")
    if not self._initTxtColor then
        self._initTxtColor = self.txt_2.params.color
    end
	self.txt_2:setString(needMoney[2])
    self.needMoney = tonumber(needMoney[2])
    

	-- 提升等级需要花费的xx 卷轴
    local itemView = self.panel_costItem
    local costItem = self.dirData.cost[1]
	costItem = string.split(costItem,",")
    self:initCostItem(itemView,costItem[2],tonumber(costItem[3]))
    if self.needMoney >  UserModel:getCoin() then
        self._errorStr = "#tid_handbooktips_003"
        self.txt_2:setTextColor(cc.c3b(255,0,0))
    else
        self.txt_2:setTextColor(self._initTxtColor)
    end
    -- 动画
    if not self.upAni then
        self.upAni = self:createUIArmature("UI_zhujue_levelup", "UI_zhujue_levelup_16", self.ctn_1,true, GameVars.emptyFunc);  
        self.upAni2 = self:createUIArmature("UI_zhujue_levelup", "UI_zhujue_levelup_16", self.ctn_2,true, GameVars.emptyFunc);  
    end
end

--消耗道具显示
function HandbookUpgradeOneDirView:initCostItem(panelView,itemId,needNum)
	local view = panelView.mc_1
    local num = ItemsModel:getItemNumById(itemId);
    view:showFrame(1)
    local _view = view.currentView
    echo(itemId,"___initCostItem__itemId")
   -- _view.panel_1:visible(false)
   	local itemName = FuncItem.getItemName(itemId)
   	panelView.txt_2:setString(itemName)
   	
    local itemData = FuncItem.getItemData(itemId)
    _view.mc_1:showFrame(itemData.quality)
    --隐藏选中框
    _view.mc_1.currentView.panel_1:visible(false)

    _view.mc_1:showFrame(itemData.quality)
    local ctn = _view.mc_1.currentView.ctn_1;
    local sprPath = FuncRes.iconItemWithImage(itemData.icon)
    local spr = cc.Sprite:create(sprPath)
    ctn:removeAllChildren()
    ctn:addChild(spr)
    if num >= needNum then
        _view.panel_lv:visible(false)
        FilterTools.clearFilter(_view.mc_1)
        panelView.txt_1:setColor(cc.c3b(0x8E,0x5F,0x35));
        local str = "1,"..itemId ..","..num
        -- FuncCommUI.regesitShowResView(_view, FuncDataResource.RES_TYPE.ITEM, needNum, itemId,str,true,true)
        _view:setTouchedFunc(c_func(function ()
            echo("PartnerEquipmentEnhanceView_______获取数量=11===",needNum)
            -- 点击道具仍弹获取途径
            WindowControler:showWindow("GetWayListView", itemId,needNum);
        end,self))
        
    else
        _view.panel_lv:visible(true)
        FilterTools.setGrayFilter(_view.mc_1)
        panelView.txt_1:setColor(cc.c3b(255,0,0));
        self._errorStr = "#tid_handbooktips_002"
        _view:setTouchedFunc(c_func(function ()
            echo("PartnerEquipmentEnhanceView_______获取数量=22===",needNum)
            -- 点击道具仍弹获取途径
            WindowControler:showWindow("GetWayListView", itemId,needNum);
        end,self))
    end
    view.currentView.txt_1:visible(false)
    panelView.txt_1:setString(num .."/"..needNum)
end

function HandbookUpgradeOneDirView:initViewAlign()
	-- TODO
end

function HandbookUpgradeOneDirView:updateUI()
	-- TODO
end

function HandbookUpgradeOneDirView:deleteMe()
	HandbookUpgradeOneDirView.super.deleteMe(self);
end

function HandbookUpgradeOneDirView:onClose( ... )
	self:startHide()
end

return HandbookUpgradeOneDirView;
