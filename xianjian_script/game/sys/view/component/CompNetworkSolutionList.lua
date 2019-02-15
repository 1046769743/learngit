--[[
	Author: caocheng
	Date:2018-03-30
	Description: 联网解决方案列表界面
]]


local CompNetworkSolutionList = class("CompNetworkSolutionList", UIBase);

function CompNetworkSolutionList:ctor(winName)
    CompNetworkSolutionList.super.ctor(self, winName)
end

function CompNetworkSolutionList:loadUIComplete()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close,UIAlignTypes.RightTop)
	FuncCommUI.setScrollAlign(self.widthScreenOffset, self.scroll_1, UIAlignTypes.Middle, nil,1,1)

	self.btn_close:setTap(c_func(self.startHide,self))
	self:updateUI()
end

function CompNetworkSolutionList:updateUI()
	local createItemView = function(index)
		local path = string.format("icon/other/network_tip%s.png",index)
		local itemView = display.newSprite(path)
		itemView:anchor(0,1)
		return itemView
	end

	self.listParams = 
	{
		{
			data = {"1","2","3"},
	        createFunc = createItemView,
	        itemRect = {x=0,y=0,width = 1136,height = 890},
	        perNums= 1,
	        offsetX = 0,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
		}
	}

	self.scroll_1:hideDragBar()
	self.scroll_1:styleFill(self.listParams)
end

return CompNetworkSolutionList;