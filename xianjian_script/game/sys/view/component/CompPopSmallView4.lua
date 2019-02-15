local CompPopSmallView4 = class("CompPopSmallView4", UIBase)

function CompPopSmallView4:ctor(winName)
	CompPopSmallView4.super.ctor(self, winName)
end

function CompPopSmallView4:loadUIComplete()
	self:registerEvent()
end

function CompPopSmallView4:registerEvent()
	CompPopSmallView4.super.registerEvent(self)
end

function CompPopSmallView4:updateUI()
	
end

return CompPopSmallView4