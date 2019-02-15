

local TreasureGuiZeView = class("TreasureGuiZeView", UIBase);


function TreasureGuiZeView:ctor(winName,pames)
    TreasureGuiZeView.super.ctor(self, winName);
    self.pames = pames
end

function TreasureGuiZeView:loadUIComplete()
    self:registerEvent();
    self:updateUI();
end 

function TreasureGuiZeView:registerEvent()
    TreasureGuiZeView.super.registerEvent();
    self:registClickClose("out")
    self.UI_diban.btn_close:setTap(function ( ... )
        self:startHide()
    end)
end

function TreasureGuiZeView:updateUI()
    self.UI_diban.txt_1:setVisible(false)
    self.UI_diban.panel_1:setVisible(false)
    self.UI_diban.mc_1:setVisible(false)
    self.rich_1:setVisible(false)
    -- 标题
    if self.pames == nil then
        self.ruleStr = GameConfig.getLanguage("#tid_treature_new_666")
    else
        local title = self.pames.title
        local tid = self.pames.tid
        self.ruleStr = GameConfig.getLanguage(tid)
    end

    local width, height = self.rich_1:setStringByAutoSize(self.ruleStr, 0)

    local createFunc = function (itemData)
        local view = UIBaseDef:cloneOneView(self.rich_1)
        self:updateItem(view, itemData)
        return view
    end

    local params = {
        {
            data = {1},
            createFunc = createFunc,
            offsetX = 20,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            perFrame = 1,
            perNum = 1,
            itemRect = {x = 0, y = -height, width = 530, height = height},
        }
    }

    self.scroll_huadong:styleFill(params)
    self.scroll_huadong:hideDragBar()
    if height < 300 then
        self.scroll_huadong:setCanScroll(false)
    end
end

function TreasureGuiZeView:updateItem(view, itemData)
    view:setStringByAutoSize(self.ruleStr, 0)
end


return TreasureGuiZeView;
