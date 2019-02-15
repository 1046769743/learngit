--[[
	Author: TODO
	Date:2018-01-24
	Description: TODO
]]

local EndlessRuleView = class("EndlessRuleView", UIBase);

function EndlessRuleView:ctor(winName)
    EndlessRuleView.super.ctor(self, winName)
end

function EndlessRuleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function EndlessRuleView:registerEvent()
	EndlessRuleView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_diban.btn_close:setTouchedFunc(c_func(self.close, self))
end

function EndlessRuleView:initData()
	self.UI_diban.txt_1:setVisible(false)
	self.UI_diban.panel_1:setVisible(false)
	self.UI_diban.mc_1:setVisible(false)
	self.rich_1:setVisible(false)
	self.ruleStr = GameConfig.getLanguage("#tid_endless_rule_1")
end

function EndlessRuleView:initView()
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

function EndlessRuleView:updateItem(view, itemData)
	view:setStringByAutoSize(self.ruleStr, 0)
end

function EndlessRuleView:initViewAlign()
	-- TODO
end

function EndlessRuleView:updateUI()
	-- TODO
end

function EndlessRuleView:close()
	self:startHide()
end

function EndlessRuleView:deleteMe()
	-- TODO

	EndlessRuleView.super.deleteMe(self);
end

return EndlessRuleView;
