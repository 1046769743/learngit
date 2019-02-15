--[[
	Author: TODO
	Date:2017-10-31
	Description: TODO
]]

local WuLingRuleTips = class("WuLingRuleTips", UIBase);

function WuLingRuleTips:ctor(winName)
    WuLingRuleTips.super.ctor(self, winName)
end

function WuLingRuleTips:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuLingRuleTips:registerEvent()
	WuLingRuleTips.super.registerEvent(self);
	self.UI_diban.btn_close:setTouchedFunc(c_func(self.press_btn_close,self))
	self:registClickClose("out")
end

function WuLingRuleTips:initData()
	-- TODO
end

function WuLingRuleTips:initView()
	self.rich_1:setVisible(false)
	self.UI_diban.txt_1:setVisible(false)
	self.UI_diban.panel_1:setVisible(false)
	self.UI_diban.mc_1:setVisible(false)
	self.ruleStr = GameConfig.getLanguage("tid_fivesoul_rule_666")
end

function WuLingRuleTips:initViewAlign()
	-- TODO
end

function WuLingRuleTips:updateUI()
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

function WuLingRuleTips:updateItem(view, itemData)
    view:setStringByAutoSize(self.ruleStr, 0)
end

function WuLingRuleTips:press_btn_close()
	self:startHide()
end

function WuLingRuleTips:deleteMe()
	-- TODO

	WuLingRuleTips.super.deleteMe(self);
end

return WuLingRuleTips;
