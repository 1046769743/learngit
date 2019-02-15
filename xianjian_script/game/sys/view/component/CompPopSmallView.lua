local CompPopSmallView = class("CompPopSmallView", UIBase)

function CompPopSmallView:ctor(winName)
	CompPopSmallView.super.ctor(self, winName)
end

function CompPopSmallView:loadUIComplete()
	self:registerEvent()
end

function CompPopSmallView:registerEvent()
	CompPopSmallView.super.registerEvent(self)
end

function CompPopSmallView:updateUI()
	
end

return CompPopSmallView

