local CompPopSmallView3 = class("CompPopSmallView3", UIBase)

function CompPopSmallView3:ctor(winName)
	CompPopSmallView3.super.ctor(self, winName)
end

function CompPopSmallView3:loadUIComplete()
	self:registerEvent()
end

function CompPopSmallView3:registerEvent()
	CompPopSmallView3.super.registerEvent(self)
end

function CompPopSmallView3:updateUI()
	
end

return CompPopSmallView3

