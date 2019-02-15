--[[
	Author: TODO
	Date:2018-05-03
	Description: TODO
]]

local RankListPlayerIconView = class("RankListPlayerIconView", UIBase);

function RankListPlayerIconView:ctor(winName)
    RankListPlayerIconView.super.ctor(self, winName)
end

function RankListPlayerIconView:loadUIComplete()
	self:registerEvent()
end 

function RankListPlayerIconView:registerEvent()
	RankListPlayerIconView.super.registerEvent(self);
end

function RankListPlayerIconView:initData()
	-- TODO
end

function RankListPlayerIconView:initView()
	-- TODO
end

function RankListPlayerIconView:initViewAlign()
	-- TODO
end

function RankListPlayerIconView:updateUI(_avatar, _head, _frame, _level)
	local iconId = FuncUserHead.getHeadIcon(_head, _avatar)
    local icon = FuncRes.iconHero(iconId)
    local iconSprite = display.newSprite(icon)
    local frame = _frame or ""
    local frameIcon = FuncUserHead.getHeadFramIcon(frame)
    local iconK = FuncRes.iconHero(frameIcon)
    local frameSprite = display.newSprite(iconK)
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(0,0)
    local spriteIcon = FuncCommUI.getMaskCan(headMaskSprite, iconSprite)
    spriteIcon:setScale(0.47)
    spriteIcon:pos(1, -1)
    frameSprite:setScale(0.5)
    self.ctn_1:removeAllChildren()
    self.ctn_2:removeAllChildren()
    self.ctn_1:addChild(spriteIcon)
    self.ctn_2:addChild(frameSprite)
    local level = _level or ""
    self.panel_1.txt_1:setString(level)
end

function RankListPlayerIconView:deleteMe()
	-- TODO

	RankListPlayerIconView.super.deleteMe(self);
end

return RankListPlayerIconView;
