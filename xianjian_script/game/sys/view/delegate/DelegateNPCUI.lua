--[[
	Author: lichaoye
	Date: 2017-05-31
	挂机NPC的UI-view
]]

local DelegateNPCUI = class("DelegateNPCUI",InfoTips1Base)

function DelegateNPCUI:ctor( winName, params, position )
	DelegateNPCUI.super.ctor(self, winName)
end

function DelegateNPCUI:loadUIComplete()
    self:registerEvent()
    self:updateUI()
end

function DelegateNPCUI:registerEvent()
    -- DelegateNPCUI.super.registerEvent(self)
    -- self:registClickClose("out")
end

function DelegateNPCUI:updateUI()
	
end

-- 显示叹号
function DelegateNPCUI:showSuprise()
	self.mc_1:showFrame(1)
end

-- 显示问号
function DelegateNPCUI:showDoubt( ... )
	self.mc_1:showFrame(2)
end

-- 显示时间
function DelegateNPCUI:showTime( time )
	self.mc_1:showFrame(3)
	self.mc_1.currentView.txt_time:setString(time or 0)
end

return DelegateNPCUI