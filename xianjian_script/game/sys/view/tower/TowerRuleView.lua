--[[
	Author: caocheng
	Date:2017-08-08
	Description: 锁妖塔玩法规则
]]

local TowerRuleView = class("TowerRuleView", UIBase);

function TowerRuleView:ctor(winName)
    TowerRuleView.super.ctor(self, winName)
end

function TowerRuleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerRuleView:registerEvent()
	TowerRuleView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))
end

function TowerRuleView:initData()
	-- TODO
end

function TowerRuleView:initView()
	self.UI_1.mc_1:visible(false)
	self.UI_1.panel_1:visible(false)
	self.UI_1.txt_1:visible(false)
	-- self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_054"))
	local wholeText = GameConfig.getLanguage("tid_tower_rule_101")
	self.wholeText = string.split(wholeText,"\n")
	dump(self.wholeText, "self.wholeText", nesting)
	local stringUI = self.rich_1
	-- local lineNum = 0
	self.rich_1:visible(false)
	self.lineNum = 0
	self:initScrollCfg()

	-- for k,v in pairs(wholeText) do
	-- 	local nowLineNum = lineNum
	-- 	local nowTextLable = UIBaseDef:cloneOneView(stringUI)

	-- 	nowTextLable:setString(v)
	-- 	nowTextLable:setPosition(70,-102-lineNum*42)
	-- 	lineNum = lineNum +1
	-- 	self:addChild(nowTextLable)
	-- end	
	-- self.rich_1:setString(GameConfig.getLanguage("tid_rule_101"))
end

function TowerRuleView:initScrollCfg()
	local createFunc = function( itemView,itemData )
		local itemView = UIBaseDef:cloneOneView(self.rich_1)
		self:createOneTxtItem(itemView,itemData)
		return itemView
	end

	local updateCellFunc = function( itemView,itemData )
		self:createOneTxtItem(itemView,itemData)
		return itemView
	end

	self.scrollParams = {
		{        
			data = self.wholeText,
	        createFunc = createFunc,
	        -- updateCellFunc = updateCellFunc,
	        perNums= 1,
	        offsetX = 0,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x= 0,y=-35,width = 565,height = 35}, 
	        perFrame = 1
	    }
	}
	self.scroll_1:styleFill(self.scrollParams)
	self.scroll_1:hideDragBar()
end

function TowerRuleView:createOneTxtItem(itemView, itemData)
	itemView:setString(self.wholeText[itemData])
	-- itemView:setPosition(70,-102-self.lineNum*42)
	self.lineNum = self.lineNum +1
end
function TowerRuleView:initViewAlign()
	-- TODO
end

function TowerRuleView:updateUI()
	-- TODO
end

function TowerRuleView:deleteMe()
	-- TODO

	TowerRuleView.super.deleteMe(self);
end

function TowerRuleView:press_btn_close()
	self:startHide()
end


return TowerRuleView;
