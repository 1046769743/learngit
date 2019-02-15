--伙伴系统,技能详情
--2017年1月6日15:40:55
--@Author:xiaohuaxiong
local PartnerSkillDetailView = class("PartnerSkillDetailView",InfoTips1Base)

function PartnerSkillDetailView:ctor(_win_name,_skill_info,_worldPoint)
    PartnerSkillDetailView.super.ctor(self,_win_name)
    self._skillInfo = _skill_info
    self.partnerId = _skill_info.partnerId
    --self.panel_1需要调整对齐的位置,这个只是一个推荐位置,具体的实现取决于面板本身所在的位置
    self._worldAlignPoint = _worldPoint
end

function PartnerSkillDetailView:loadUIComplete()
    self:registerEvent()
    self:initPartnerSkillStar()
    self:updateDetailView()
end

function PartnerSkillDetailView:registerEvent()
    PartnerSkillDetailView.super.registerEvent(self)
    -- self:registClickClose("out")
end

function PartnerSkillDetailView:initPartnerSkillStar()

    --星级与技能的关系统计
    local _starSkillCondition={}
    self._starSkillCondition = {}
    local _starInfos = FuncPartner.getStarsByPartnerId(self.partnerId)
    for _key,_value in pairs(_starInfos) do
        if _value.skillId ~= nil then
            for k,v in pairs(_value.skillId) do
                _starSkillCondition[v] = tonumber(_key)
            end
        end
    end
    self._starSkillCondition = _starSkillCondition
--
end
function PartnerSkillDetailView:updateDetailView()
    local _skill_item = FuncPartner.getSkillInfo(self._skillInfo.id)
    local _view = self.panel_1
    --icon
    local _iconPath = FuncRes.iconSkill(_skill_item.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)
    if self._skillInfo._index == 1 then
        _view.mc_skill:showFrame(2)
        _iconSprite:setScale(0.85) 

        local xiaohao = FuncPartner.getNuQiCost( self.partnerId )
        -- 怒气消耗值
        _view.txt_3:setVisible(true)
        _view.panel_nuqi:setVisible(true)
        _view.txt_3:setString(xiaohao)
    else
        _view.mc_skill:showFrame(1)
        _view.txt_3:setVisible(false)
        _view.panel_nuqi:setVisible(false)
    end
    local iconCtn = _view.mc_skill.currentView.ctn_1
    iconCtn:removeAllChildren()
    iconCtn:addChild(_iconSprite)
    --name
    _view.txt_1:setString(GameConfig.getLanguage(_skill_item.name))
    -- type
    _view.txt_2:setString(GameConfig.getLanguage("#tid_partner_ui_020")..GameConfig.getLanguage(_skill_item.dis))
    _view.txt_2:setVisible(false)
    --描述
    _view.rich_4:setString(GameConfig.getLanguage(_skill_item.describe))
    --关于该技能对角色的属性的提升
    echo("技能ID == ",_skill_item.id)
    local skillStr = FuncPartner.getPartnerSkillDesc(_skill_item.id,self._skillInfo.level)
    if skillStr == nil then
           skillStr = ""
    end   
    _view.rich_5:setString(skillStr)
end

return PartnerSkillDetailView