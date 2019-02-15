local TreasureShowView = class("TreasureShowView", UIBase)

function TreasureShowView:ctor(winName,treasureId)
	TreasureShowView.super.ctor(self, winName)
    self.treasureId = treasureId
end

function TreasureShowView:loadUIComplete()
    self:registerEvent()
    self:initTreasure()
end

function TreasureShowView:initTreasure()
	local dataCfg = FuncTreasureNew.getTreasureDataById(self.treasureId)
    local quality = dataCfg.initQuality
    local star = dataCfg.initStar

    -- 天 地 通天
    self.panel_name.mc_pj:showFrame(dataCfg.aptitude)
    -- name -- quality 
    local name = FuncRes.NameTreasureNew( self.treasureId )
    local treasureName = display.newSprite(name)
    self.panel_name.ctn_1:removeAllChildren()
    self.panel_name.ctn_1:addChild(treasureName)

    --定位
    self.panel_name.txt_1:setString(GameConfig.getLanguage(dataCfg.position))

    -- 描述
    self.panel_fb.txt_1:setString(GameConfig.getLanguage(dataCfg.des))

    -- icon 
    local iconPath = FuncRes.iconTreasureNew(self.treasureId)
    local treasureIcon = display.newSprite(iconPath)
    self.ctn_3:removeAllChildren()
    self.ctn_3:addChild(treasureIcon)
    treasureIcon:scale(1.7)

    -- bg
    local bgSpr = display.newSprite("icon/treasure/treasure_bg_chendi.png" )
    self.ctn_2:removeAllChildren()
    self.ctn_2:addChild(bgSpr)

    --大招
    local skillT = dataCfg.skill

    local dataSkillCfg = FuncTreasureNew.getTreasureSkillDataDataById(skillT[1])
    -- icon 
    local iconPath = FuncRes.iconSkill(dataSkillCfg.icon)
    local skillIcon = display.newSprite(iconPath)
    self.panel_dz.ctn_1:removeAllChildren()
    self.panel_dz.ctn_1:addChild(skillIcon)
    --name
    self.panel_dz.txt_1:setString(GameConfig.getLanguage(dataSkillCfg.name))
    --简介
    if dataSkillCfg.describe then
        self.panel_dz.txt_2:setString(GameConfig.getLanguage(dataSkillCfg.describe))
    else
        self.panel_dz.txt_2:setString("表里是空的。。。。")
    end
end
function TreasureShowView:registerEvent()
    TreasureShowView.super.registerEvent();
    self:registClickClose()
end


--返回 
function TreasureShowView:onBtnBackTap()
	self:startHide()
end

return TreasureShowView
