--[[
	Author: lichaoye
	Date: 2017-04-13
	查看阵容-更换法宝
]]
local LineUpChTreasureView = class("LineUpChTreasureView", UIBase)

--[[
	self.txt_1
	self.panel_1
	self.scroll_list3
]]

function LineUpChTreasureView:ctor( winName )
	LineUpChTreasureView.super.ctor(self, winName)
end

function LineUpChTreasureView:registerEvent()
	LineUpChTreasureView.super.registerEvent(self)
    self.UI_1.btn_1:setTap(c_func(self.press_btn_close, self))
end

function LineUpChTreasureView:loadUIComplete()
	self:registerEvent()

	-- 标题
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_teaminfo_1005"))
	-- 隐藏需要复制的item
	self.panel_fb:visible(false)
	self:updateUI()
end

function LineUpChTreasureView:updateUI()
	local function createFunc( itemData, idx )
		local view = UIBaseDef:cloneOneView(self.panel_fb)

		self:updateItem(view, itemData, idx)
		return view
	end

	local function updateCellFunc( itemData, view, idx )
		self:updateItem(view, itemData, idx)
	end

	local scrollParams = {
		{
			data = LineUpModel:getTreasureList(),
			createFunc = createFunc,
			updateCellFunc = updateCellFunc,
			perFrame = 1,
			perNums = 3,
			widthGap = 60,
			offsetX = 70,
			offsetY = 0,
			itemRect = {x = 0,y = -258,width = 248,height = 308},
		}
	}

	local scrollList = self.scroll_1
	scrollList:styleFill(scrollParams)
end

function LineUpChTreasureView:updateItem(view, itemData, idx )
	-- icon
	local _sp = display.newSprite(FuncRes.iconTreasure(itemData.id)):size(80,70):scale(1)
	view.ctn_1:removeAllChildren()
	view.ctn_1:addChild(_sp)
	-- 名字
	-- view.txt_2:setString(GameConfig.getLanguage(TreasuresModel:getTreasureName(itemData.id)))
	-- 等级（隐藏）
	-- view.txt_1:visible(false)
	-- view.txt_1:setString(itemData.level)
	-- 是否在阵
	view.panel_dui:visible(itemData.inTeam == 1)
	-- 星级
	view.mc_dou:showFrame(itemData.star or 1)
	-- 更换
	view:setTouchedFunc(function()
		LineUpModel:treasureFormationChange(itemData.id)
		self:startHide()
	end)
end

function LineUpChTreasureView:press_btn_close()
	self:startHide()
end

return LineUpChTreasureView