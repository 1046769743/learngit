local ArenaPlayerTalkView = class("ArenaPlayerTalkView", UIBase)

function ArenaPlayerTalkView:ctor(winName)
	ArenaPlayerTalkView.super.ctor(self, winName)
end

function ArenaPlayerTalkView:loadUIComplete()
	local txt_content = self.panel_talk.txt_content
	local x,y = txt_content:getPosition()
	self.box_width = self:getContainerBox().width
	self.txt_content_px = x
	self.txt_content_py = y
end

function ArenaPlayerTalkView:setTalkContent(contentStr)
	self.panel_talk.txt_content:setString(contentStr)
end

return ArenaPlayerTalkView

