ArenaListBaseItem = require('game.sys.view.pvp.ArenaListBaseItem')
local ArenaListTopItem = class("ArenaListTopItem", ArenaListBaseItem)

function ArenaListTopItem:ctor(winName)
	ArenaListTopItem.super.ctor(self, winName)
end

function ArenaListTopItem:loadUIComplete()
	ArenaListTopItem.super.loadUIComplete(self)
	self.cloudAnim = self:createUIArmature("UI_arena","UI_arena_di", self.ctn_middle_cloud, false, GameVars.emptyFunc)
	self.cloudAnim:setScaleX(0.7)	
	self.cloudAnim:startPlay(true)
	-- self.panel_bg:setPositionY(-10)
end

return ArenaListTopItem

