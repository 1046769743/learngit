--zhangqiang
--2018.3.20 

local MemoryCardMainView = class("MemoryCardMainView", UIBase);


function MemoryCardMainView:ctor(winName)
    MemoryCardMainView.super.ctor(self, winName);
end

--分辨率适配
function MemoryCardMainView:uiAdjust()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_latiao, UIAlignTypes.Right);


    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize, UIAlignTypes.LeftTop);
end
function MemoryCardMainView:registerEvent()
    MemoryCardMainView.super.registerEvent();

    EventControler:addEventListener(MemoryEvent.MEMORY_CHIP_LIGHT_EVENT,self.reFreshUI,self)
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.reFreshUI,self)

    -- 退出
    self.btn_back:setTap(c_func(self.close,self))
    -- 属性
    self.txt_shuxing:setTouchedFunc(function (  )
        WindowControler:showWindow("MemoryAttrView")
    end)

    --说明
    self.btn_guize:setTap(function ( ... )
        WindowControler:showWindow("MemoryCardConditionView")
    end)
    
end


function MemoryCardMainView:loadUIComplete()

	self:registerEvent();
    self:uiAdjust()

    self:initData()
    self:initUI()
end 

function MemoryCardMainView:initData( )
    self.allMemory = MemoryCardModel:getShowMemoryT()
    local sortFunc = function ( a,b )
        if tonumber(a.id) < tonumber(b.id) then
            return true
        end
        return false
    end
    table.sort(self.allMemory,sortFunc)
    -- 默认选中的id
    self.selectId = self.allMemory[1].id
end

function MemoryCardMainView:getDataById(id)
    for i,v in pairs(self.allMemory) do
        if v.id == id then
            return v
        end
    end
    return nil
end

function MemoryCardMainView:initUI()
    -- self:initList()
    self.panel_latiao.mc_1:visible(false)
    local data = self:getDataById(self.selectId)
    self:updateUI(data,true)
end
    

function MemoryCardMainView:initList()
    
    self.scroll = self.panel_latiao.scroll_1
    local panel = self.panel_latiao.mc_1
    panel:visible(false)
        
    local data = self.allMemory

    local createItemFunc = function (data)
        local itemPanel = UIBaseDef:cloneOneView(panel);
        self:updateCell(itemPanel, data);
        return itemPanel;
    end
    local updateCellFunc = function (data,itemPanel)
        self:updateCell(itemPanel, data);
        return itemPanel;
    end
    local scrollParams = { 
        {
            data = data,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 25,
            offsetY = 15,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -103, width = 51, height = 103},
        }
    };

    self.scroll:styleFill(scrollParams)
    self.scroll:hideDragBar()
end

function MemoryCardMainView:updateCell(itemPanel, data)
    itemPanel:showFrame(1)

    local btn = itemPanel.currentView.btn_x1
    -- local btnTxt = btn:getUpPanel().txt_1
    -- local name = data.name
    -- btnTxt:setString(GameConfig.getLanguage(name))

    btn:setTap(c_func(self.clickBtn,self,data))


    if data.id == self.selectId then
        itemPanel:showFrame(2)
        local btn1 = itemPanel.currentView.btn_x1
        -- local btnTxt1 = btn1:getUpPanel().txt_1
        -- btnTxt1:setString(GameConfig.getLanguage(name))
    else
        itemPanel:showFrame(1)
    end
end

function MemoryCardMainView:clickBtn(data)
    local currentData = self:getDataById(self.selectId)
    local currentPanel = self.scroll:getViewByData(currentData)
    if currentPanel then
        currentPanel:showFrame(1)
    end

    local selectPanel = self.scroll:getViewByData(data)
    if selectPanel then
        selectPanel:showFrame(2)
        local name = data.name
        local btn = selectPanel.currentView.btn_x1
        local btnTxt = btn:getUpPanel().txt_1
        btnTxt:setString(GameConfig.getLanguage(name))

        self:updateUI(data,true)
        self.selectId = data.id
    end
end

function MemoryCardMainView:btnsRed()
    for i,v in pairs(self.allMemory) do
        local view = self.scroll:getViewByData(v)
        if view then
            if self.selectId ~= v.id then
                local panel_red = view.currentView.panel_red
                local redShow = MemoryCardModel:checkMemoryShowRedById(v.id)
                panel_red:visible(redShow)
            end
        end
    end
end

function MemoryCardMainView:updateUI(data,isRefresh)
    if data.id == self.selectId then
        if not isRefresh then
            return 
        end
    end

    self.selectId = data.id

    -- 系列卡的显示
    local cards = data.pictureId

    local frame = 4 - #cards + 1
    if frame > 3 then
        echoError("系列的card数量配错了")
        frame = 3
    end
    self.mc_1:showFrame(frame)
    for i=1,#cards do
        if i <= 4 then
            local UICard = self.mc_1.currentView["UI_"..i]
            -- UICard:setScale(0.85)
            
            -- if i == 1 then
            --     local x = UICard:getPositionX()
            --     UICard:setPositionX(x + 100)
            --     local y = UICard:getPositionY()
            --     UICard:setPositionY(y - 40)
            -- elseif i == 2 then
            --     local x = UICard:getPositionX()
            --     UICard:setPositionX(x + 40)
            --     local y = UICard:getPositionY()
            --     UICard:setPositionY(y - 40)
            -- elseif i == 3 then
            --     local x = UICard:getPositionX()
            --     UICard:setPositionX(x + 100)
            -- elseif i == 4 then
            --     local x = UICard:getPositionX()
            --     UICard:setPositionX(x + 40)
            -- end
            
            UICard:updateUI( cards[i],i ) 
            UICard:setTouchedFunc(c_func(self.openCardInfoUI,self,cards[i]))
        end
    end

    -- 战力
    local power = MemoryCardModel:getMemoryPower( )
    self.panel_power.UI_number:setPower(power)
    -- 属性
    local attrT = FuncMemoryCard.getMemoryAttrById( self.selectId )
    local attrStr = ""
    for i,v in pairs(attrT) do
        local value = v.value
        if v.mode == 2 then
            value = (v.value/100).."%"
        end
        attrStr = attrStr .. v.name .. "+" .. value .. "  "
    end
    self.panel_1.txt_3:setString(attrStr)
    -- 加成type
    local typedes = FuncMemoryCard.getTypeDes( self.selectId )
    self.panel_1.txt_2:setString(typedes)

    -- 页签标签
    -- self:btnsRed()
end

-- 强制刷新当前UI
function MemoryCardMainView:reFreshUI()
    local data = self:getDataById(self.selectId)
    self:updateUI(data,true)
end

function MemoryCardMainView:openCardInfoUI(cardId)
    echo("打开的 情景卡 id==== ",cardId)
    if MemoryCardModel:checkCardCanShow(cardId) then
        WindowControler:showWindow("MemoryCardView",cardId,self.selectId)
    else
        local methodTips = FuncMemoryCard.getMethodString( cardId)
        WindowControler:showTips(methodTips)
        -- WindowControler:showTips("尚未获得")
    end
    
end

function MemoryCardMainView:close()
    self:startHide()
end

return MemoryCardMainView;