
local PartnerCharSkillDetailView = class("PartnerCharSkillDetailView",InfoTips1Base)

function PartnerCharSkillDetailView:ctor(_win_name,_skill_info)
    PartnerCharSkillDetailView.super.ctor(self,_win_name)
    self._skillInfo = _skill_info
    self.partnerId = _skill_info.partnerId
end

function PartnerCharSkillDetailView:loadUIComplete()
    self:registerEvent()
    self:updateDetailView()
end

function PartnerCharSkillDetailView:registerEvent()
    PartnerCharSkillDetailView.super.registerEvent(self)
    -- self:registClickClose("out")
end

function PartnerCharSkillDetailView:updateDetailView()
    local _skill_item = FuncPartner.getSkillInfo(self._skillInfo.id)
    local _view = self.panel_1

    local level = UserModel:level()
    if self._skillInfo.level then
        level = self._skillInfo.level
    end
    if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL) then
    -- 如果 伙伴技能未开启 将主角技能强制变为1
        level = 1
    end
    --icon
    local _iconPath = FuncRes.iconSkill(_skill_item.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)
    -- if self._skillInfo.index == 1 then
    --     _view.mc_skill:showFrame(2)
    --     -- _iconSprite:setScale(0.8)
    -- else
    --     _view.mc_skill:showFrame(1)
    -- end
    _view.mc_skill:showFrame(1)
    _iconSprite:setScale(1)
    local iconCtn = _view.mc_skill.currentView.ctn_1
    iconCtn:removeAllChildren()
    iconCtn:addChild(_iconSprite)
    --name
    _view.txt_1:setString(GameConfig.getLanguage(_skill_item.name))
    --type
    _view.txt_2:setString(GameConfig.getLanguage("#tid_treature_ui_010")..GameConfig.getLanguage("#tid230"))
    _view.txt_2:setVisible(false)
--    --level
    _view.txt_3:visible(false)
    _view.panel_nuqi:visible(false)
    --描述
    _view.rich_4:setString(GameConfig.getLanguage(_skill_item.describe))
    --关于该技能对角色的属性的提升
    local skillStr = FuncPartner.getPartnerSkillDesc(_skill_item.id,level)
    if skillStr == nil then
        skillStr = ""
    end
    _view.rich_5:setString(skillStr)
end

return PartnerCharSkillDetailView