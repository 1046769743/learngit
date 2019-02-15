

-- 上方覆盖全屏的纯view (锚点在左上角)
local DivBase = class("DivBase", function(name)
	return display.newNode(name)
end)

DivBase.cx = d.cx
DivBase.top = 0
DivBase.bottom = -d.h
DivBase.cy = -d.cy
--[[
DivBase.left = 0
DivBase.right = d.r
DivBase.width = d.w
DivBase.height = d.h
]]

function DivBase:ctor()
	--cover
	ui.cover(self)
	--bg
	self.bg = d.sp9("#g1.png"):size(d.w,d.h):pos(d.cx,-d.cy):addto(self)
end

function DivBase:close()
	WindowControler.clearDiv()
end


return DivBase
