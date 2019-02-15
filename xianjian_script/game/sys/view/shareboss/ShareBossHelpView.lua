--[[
	Author: TODO
	Date:2017-10-26
	Description: TODO
]]

local ShareBossHelpView = class("ShareBossHelpView", UIBase);

function ShareBossHelpView:ctor(winName)
    ShareBossHelpView.super.ctor(self, winName)
end

function ShareBossHelpView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function ShareBossHelpView:registerEvent()
	ShareBossHelpView.super.registerEvent(self);

	self.UI_1.btn_close:setTouchedFunc(c_func(self.close, self))
	self:registClickClose("out")
end

function ShareBossHelpView:initData()
	self.content = GameConfig.getLanguage("#tid_shareboss_rule_666")
end

function ShareBossHelpView:initView()
	self.UI_1.txt_1:setVisible(false)
	self.UI_1.panel_1:setVisible(false)
	self.UI_1.mc_1:setVisible(false)
	self.rich_1:setVisible(false)
	local width, height = self.rich_1:setStringByAutoSize(self.content, 0)

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

	self.scroll_1:styleFill(params)
	self.scroll_1:hideDragBar()
	if height < 300 then
		self.scroll_1:setCanScroll(false)
	end
end

function ShareBossHelpView:updateItem(view, itemData)
	view:setStringByAutoSize(self.content, 0)
end

function ShareBossHelpView:initViewAlign()
	-- TODO
end

function ShareBossHelpView:updateUI()
	-- TODO
end

function ShareBossHelpView:close()
	self:startHide()
end

function ShareBossHelpView:deleteMe()
	-- TODO

	ShareBossHelpView.super.deleteMe(self);
end

return ShareBossHelpView;
