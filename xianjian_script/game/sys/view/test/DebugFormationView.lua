-- Author: pangkangning
-- Date: 2017.08.12
-- Detail：简易五行布阵
local DebugFormationView = class("DebugFormationView", UIBase)

G_DebugFormationArray = {0,1,0,2,3,5}
local trans = {
	"风","雷","水","火","土","无"
}
function DebugFormationView:ctor(winName)
    DebugFormationView.super.ctor(self, winName)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self,UIAlignTypes.MiddleTop)
    self._idx = 0
end

function DebugFormationView:loadUIComplete()
	self.btn_1:setTouchedFunc(c_func(self.pressSureBtn,self),nil,true)
	for i=1,6 do
		local panel = self["panel_"..i]
		panel.txt_1:setString(trans[G_DebugFormationArray[i]])
		panel:setTouchedFunc(function()
			self.panel_eleall:visible(true)
			self._idx = i
		end)
	end
	self.panel_eleall:visible(false)
	-- 懒得改资源了，做一个映射
	local AXIBA = {1,3,5,2,4,6}
	for p=1,6 do
		local i = AXIBA[p]
		local panel = self.panel_eleall["panel_ele"..p]
		panel.txt_1:setString(trans[p])

		panel:setTouchedFunc(function()
			G_DebugFormationArray[self._idx] = p < 6 and p or 0
			self.panel_eleall:visible(false)
			self["panel_"..self._idx].txt_1:setString(trans[p])
		end)
	end
end
function DebugFormationView:pressSureBtn( )
	dump(G_DebugFormationArray, "G_DebugFormationArray")
	self:startHide()
end


return DebugFormationView
