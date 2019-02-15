ArenaListBaseItem = require('game.sys.view.pvp.ArenaListBaseItem')
local ArenaListCommonItem = class("ArenaListCommonItem", ArenaListBaseItem)

function ArenaListCommonItem:ctor(winName)
	ArenaListCommonItem.super.ctor(self, winName)
end

function ArenaListCommonItem:loadUIComplete()
	ArenaListCommonItem.super.loadUIComplete(self)
	self.cloudAnim = self:createUIArmature("UI_arena","UI_arena_di", self.ctn_middle_cloud, false, GameVars.emptyFunc)
	self.cloudAnim:setScaleX(0.7)	
	self.panel_bg:setPositionY(40)
	self.cloudAnim:startPlay(true)

	local pos_1 = {x = self.UI_p1:getPositionX(), y = self.UI_p1:getPositionY()}
	local pos_2 = {x = self.UI_p2:getPositionX(), y = self.UI_p2:getPositionY()}
	local pos_3 = {x = self.UI_p3:getPositionX(), y = self.UI_p3:getPositionY()}
	local pos_4 = {x = self.UI_p4:getPositionX(), y = self.UI_p4:getPositionY()}
	self.UI_p1:pos(pos_1.x, pos_1.y + GameVars.UIOffsetY)
	self.UI_p2:pos(pos_2.x, pos_2.y + GameVars.UIOffsetY)
	self.UI_p3:pos(pos_3.x, pos_3.y + GameVars.UIOffsetY)
	self.UI_p4:pos(pos_4.x, pos_4.y + GameVars.UIOffsetY)
end


return ArenaListCommonItem

