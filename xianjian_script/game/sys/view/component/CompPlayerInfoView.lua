--[[
	Author: ZhangYanguang
	Date:2017-07-18
	Description: 玩家头像信息界面
]]

local CompPlayerInfoView = class("CompPlayerInfoView", UIBase);

function CompPlayerInfoView:ctor(winName)
    CompPlayerInfoView.super.ctor(self, winName)
end

function CompPlayerInfoView:loadUIComplete()
	self:registerEvent()
end 

function CompPlayerInfoView:registerEvent()
	CompPlayerInfoView.super.registerEvent(self);
end

function CompPlayerInfoView:setPlayerInfo(playerInfo)
	self.panel_1.txt_lvl:setString(playerInfo.level or 1)
	self:setPlayerIcon(self.panel_1.ctn_other,playerInfo)
end

function CompPlayerInfoView:setPlayerIcon(ctnIcon,playerInfo)
    if playerInfo.head == 0 then
        playerInfo.head = nil
    end
    local avatarId = playerInfo.avatar
    local iconid = playerInfo.head 
    local icon = FuncUserHead.getHeadIcon(iconid,avatarId)
    icon = FuncRes.iconHero(icon)
    local iconSprite = display.newSprite(icon)

    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(-1,0)
    -- headMaskSprite:setScale(0.99)
    headMaskSprite:setContentSize(cc.size(90,90))

    local spritesico = FuncCommUI.getMaskCan(headMaskSprite,iconSprite)
    spritesico:setScaleX(-1)
    ctnIcon:removeAllChildren()
    ctnIcon:addChild(spritesico)

    if playerInfo.frame == 0 then
        playerInfo.frame = nil
    end
    --头像框
    local framid = playerInfo.frame or FuncUserHead.getDefaultHeadFrame()
    local frameicon = FuncUserHead.getHeadFramIcon(framid)
    icon = FuncRes.iconHero( frameicon )
    local frameSprite = display.newSprite(icon)
    ctnIcon:addChild(frameSprite,100)
end

function CompPlayerInfoView:deleteMe()
	CompPlayerInfoView.super.deleteMe(self);
end

return CompPlayerInfoView;
