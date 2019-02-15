--[[
	奇侠传玩法说明View
	author: lcy
	add: 2018.7.20
]]

local BiographyGuideView = class("BiographyGuideView", UIBase)

function BiographyGuideView:ctor(winName)
	BiographyGuideView.super.ctor(self, winName)
end

function BiographyGuideView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end

function BiographyGuideView:registerEvent()
	self.UI_diban.btn_close:setTap(c_func(self.onClickBack, self))

	-- self:registClickClose(-1, c_func( function()
	--         self:onClickBack()
	-- end , self))

	self:registClickClose(nil,nil,false,false)
end

function BiographyGuideView:initData()
	-- body
end

function BiographyGuideView:initViewAlign()
	-- body
end

function BiographyGuideView:initView()
	self.UI_diban.mc_1:setVisible(false)
	self.UI_diban.txt_1:setVisible(false)
	self.UI_diban.panel_1:setVisible(false)
	self.rich_1:setVisible(false)
end

function BiographyGuideView:updateUI()
	local createRankItemFunc = function(itemData)
	    local view = UIBaseDef:cloneOneView(self.rich_1);
	    self:updateItem(view, itemData)
	    return view;
	end
	self._scrollParams = {
	    {
	            data = {1},
	            createFunc= createRankItemFunc,
	            perNums= 1,
	            offsetX =15,
	            offsetY = 20,
	            itemRect = {x=0,y=-290,width=530,height = 290},
	            perFrame = 1,
	            heightGap = 0
	        }
	}
	self.scroll_huadong:styleFill(self._scrollParams)
end

function BiographyGuideView:updateItem(view, itemData)
	-- 
	view:setString(GameConfig.getLanguage(FuncBiography.getGuide()))
end

function BiographyGuideView:onClickBack()
	self:startHide()
end

return BiographyGuideView