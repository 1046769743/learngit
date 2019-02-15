
local TreasureSkillTips = class("TreasureSkillTips",InfoTips1Base)

function TreasureSkillTips:ctor(_win_name,_skill_info)
    TreasureSkillTips.super.ctor(self,_win_name)
    self._skillInfo = _skill_info
end

function TreasureSkillTips:loadUIComplete()
    self:registerEvent()
    self:updateDetailView()
end

function TreasureSkillTips:registerEvent()
    TreasureSkillTips.super.registerEvent(self)
    -- self:registClickClose("out")
end

function TreasureSkillTips:updateDetailView()
    -- dump(self._skillInfo, "\n\nself._skillInfo==")
    local skillId = self._skillInfo.skillId
    local dataCfg = FuncTreasureNew.getTreasureSkillDataDataById(self._skillInfo.skillId)
    local data = self._skillInfo.data
    local initData = FuncTreasureNew.getTreasureDataById(self._skillInfo.treasureId)

    if not data then
        data = {}   
        data.star = initData.initStar
    end
    local level = nil
    if self._skillInfo.level then
        level = self._skillInfo.level 
    else
        level = UserModel:level() --math.floor((UserModel:level()-1)/3+1)
    end
    if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL) then
    -- 如果 伙伴技能未开启 将主角技能强制变为1
        level = 1
    end 
    local star = data.star

    -- icon
    local iconPath = FuncRes.iconSkill(dataCfg.icon)
    local skillIcon = display.newSprite(iconPath)
    self.panel_1.mc_skill:showFrame(1)
    if dataCfg.priority == 1 then       
        skillIcon:setScale(0.75)
        local xiaohao = FuncTreasureNew.getNuqiCost( self._skillInfo.treasureId,star )
        self.panel_1.txt_3:setString(xiaohao)
        self.panel_1.panel_nuqi:visible(true)
        self.panel_1.txt_3:visible(true)
    else
        self.panel_1.panel_nuqi:visible(false)
        self.panel_1.txt_3:visible(false)
    end
    
    local ctn = self.panel_1.mc_skill.currentView.ctn_1
    ctn:removeAllChildren()
    ctn:addChild(skillIcon)
    
    self.panel_1.txt_2:setString(GameConfig.getLanguage("#tid_treature_ui_010")..GameConfig.getLanguage(dataCfg.dis))
    self.panel_1.txt_2:visible(false) 


    -- name
    self.panel_1.txt_1:setString(GameConfig.getLanguage(dataCfg.name))

    --描述
    if dataCfg.describe then
        self.panel_1.rich_4:setString(GameConfig.getLanguage(dataCfg.describe))
    else
        self.panel_1.rich_4:setString("表里描述字段是空的")
    end
    
    local _final_content = FuncTreasureNew.getDescriptionBySkillId(skillId,level)
    -- 

    self.panel_1.rich_5:setString(_final_content)

end

return TreasureSkillTips