
local PartnerOpenSkillShowView = class("PartnerOpenSkillShowView",UIBase)

function PartnerOpenSkillShowView:ctor(_name,skillId,callback,params)
    PartnerOpenSkillShowView.super.ctor(self,_name)
    
    self.skillId = skillId

    self.callback = callback

    self.params = params
end

function PartnerOpenSkillShowView:loadUIComplete()
    self:registerEvent()

    local skillId = self.skillId
    local skillData = nil
    if self.params then
        local partnerInfo = self.params._partnerInfo
        if FuncPartner.isChar(partnerInfo.id) then
            if self.params.isAwakeSkill then
                skillData = FuncTreasureNew.getTreasureSkillDataDataById(skillId)
            elseif self.params.isWeaponAwakeSkill then
                skillData = FuncPartner.getSkillInfo(skillId)
            end
        else
            skillData = FuncPartner.getSkillInfo(skillId)
        end
    else
        skillData = FuncPartner.getSkillInfo(skillId)
    end
    
    local _name = GameConfig.getLanguage(skillData.name)
    local _iconPath = FuncRes.iconSkill(skillData.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)

    self.panel_newSkill.txt_1:setString(_name)
    self.panel_newSkill.ctn_skill:removeAllChildren()
    self.panel_newSkill.ctn_skill:addChild(_iconSprite)
    _iconSprite:setScale(0.5)


    local skillStr = FuncPartner.getCommonSkillDesc(skillData, 1)
    local skillDes = GameConfig.getLanguage(skillData.describe)
    self.panel_rich.rich_1:setString(skillDes)
    self.panel_rich.rich_2:setString(skillStr)


    -- WindowControler:showTips("现在 还没有 特效")
    -- FuncCommUI.addCommonBgEffect(self.ctn_efbg,1)

    local jiesuanAnim = self:createUIArmature("UI_xianshuhuode","UI_xianshuhuode_zong", nil, GameVars.emptyFunc)
    jiesuanAnim:doByLastFrame(false, false, GameVars.emptyFunc)
    self.ctn_skillEff:addChild(jiesuanAnim)
    jiesuanAnim:startPlay(false, false )
    self.panel_newSkill:setPositionX(-48)
    self.panel_newSkill:setPositionY(61)
    FuncArmature.changeBoneDisplay(jiesuanAnim,"node",self.panel_newSkill)

    self:delayCall(function ( ... )
        local Anim = self:createUIArmature("UI_xianshuhuode","UI_xianshuhuode_anniu", nil, GameVars.emptyFunc)
        Anim:doByLastFrame(false, false, GameVars.emptyFunc)
        self.ctn_skillEff:addChild(Anim)
        Anim:startPlay(false, false )
        -- self.panel_newSkill:setPositionX(-48)
        -- self.panel_newSkill:setPositionY(61)
        FuncArmature.changeBoneDisplay(Anim,"node2",jiesuanAnim)
        FuncArmature.changeBoneDisplay(Anim,"node1",self.panel_rich)
        self.panel_rich:pos(-40, 40)
        jiesuanAnim:pos(0,0)
    end,0.01)

end


function PartnerOpenSkillShowView:registerEvent()
    PartnerOpenSkillShowView.super.registerEvent(self)

    self:delayCall(function (  )
        self:registClickClose(-1, c_func( function()    
            if self.callback then
                self.callback()
            end
            self:onClose()
        end , self))
    end, 2.0)
    
end
function PartnerOpenSkillShowView:onClose()
    self:startHide()
end
return PartnerOpenSkillShowView
