local TreasureUpStarShowView = class("TreasureUpStarShowView", UIBase)

function TreasureUpStarShowView:ctor(winName,treasureId,callback)
	TreasureUpStarShowView.super.ctor(self, winName)
    self._treaSureId = treasureId or "302"
    self.callback = callback
end

function TreasureUpStarShowView:loadUIComplete()
    self:registerEvent()
    self:initUI()
end
function TreasureUpStarShowView:initUI()
    -- 标题特效
    FuncCommUI.addCommonBgEffect(self.ctn_efbg,7)
    self.panel_sp:setVisible(false)
    self.txt_jixu:setVisible(false)
    local anim = self:createUIArmature("UI_jinglian_shengxingchenggong","UI_jinglian_shengxingchenggong", 
        self.ctn_anim, true)
    anim:doByLastFrame(false, false)
    anim:setPositionY(220)
    -- 头1
    FuncArmature.changeBoneDisplay(anim, "layer1", self.panel_tou1)
    self.panel_tou1:setPositionX(0)
    self.panel_tou1:setPositionY(0)
    -- 头2
    FuncArmature.changeBoneDisplay(anim, "node2", self.panel_tou2)
    self.panel_tou2:setPositionX(0)
    self.panel_tou2:setPositionY(0)


    FuncArmature.changeBoneDisplay(anim, "node4", self.panel_3)
    self.panel_3:setPositionX(15)
    self.panel_3:setPositionY(-30)

    FuncArmature.changeBoneDisplay(anim, "shentong", self.rich_1)
    self.rich_1:setPositionX(-115)
    self.rich_1:setPositionY(0)
    
    FuncArmature.changeBoneDisplay(anim, "layer6", display.newNode())
    FuncArmature.changeBoneDisplay(anim, "layer6_copy", display.newNode())


    local dataCfg = FuncTreasureNew.getTreasureDataById(self._treaSureId)
    local data = TreasureNewModel:getTreasureData(self._treaSureId)
    local beforStar = data.star - 1
    local afterStar = data.star
    -- -- icon 
    local frame = FuncTreasureNew.getKuangColorFrame(self._treaSureId)
    self.panel_tou1.mc_2:showFrame(frame)
    self.panel_tou2.mc_2:showFrame(frame)

    local iconPath = FuncRes.iconTreasureNew(self._treaSureId)
    local treasureIcon = display.newSprite(iconPath)
    self.panel_tou1.mc_2.currentView.ctn_1:removeAllChildren()
    self.panel_tou1.mc_2.currentView.ctn_1:addChild(treasureIcon)
    -- treasureIcon:setScale(0.5)
    local treasureIcon2 = display.newSprite(iconPath)
    self.panel_tou2.mc_2.currentView.ctn_1:removeAllChildren()
    self.panel_tou2.mc_2.currentView.ctn_1:addChild(treasureIcon2)
    -- treasureIcon2:setScale(0.5)
    -- 星级
    self.panel_tou1.mc_dou:showFrame(7)
    for i=1,7 do
        if i <= beforStar then
            self.panel_tou1.mc_dou.currentView["mc_"..i]:showFrame(1)
        else
            self.panel_tou1.mc_dou.currentView["mc_"..i]:showFrame(2)
        end
    end
    self.panel_tou2.mc_dou:showFrame(7)
    for i=1,7 do
        if i <= afterStar then
            self.panel_tou2.mc_dou.currentView["mc_"..i]:showFrame(1)
        else
            self.panel_tou2.mc_dou.currentView["mc_"..i]:showFrame(2)
        end
    end
    
    -- 解锁仙术
    local skillStarT = FuncTreasureNew.getStarSkillMap(self._treaSureId)
    local skillId = nil
    for i,v in pairs(skillStarT) do
        if v.star == afterStar then
            skillId = i
            break
        end
    end
    if not skillId then
        self.panel_3.panel_skill:setVisible(false)
        self.panel_3.txt_2:setVisible(false)
    else
        self.panel_3.panel_skill:setVisible(true)
        self.panel_3.txt_2:setVisible(true)
        local skillData = FuncTreasureNew.getTreasureSkillDataDataById(skillId)
        local iconPath = FuncRes.iconSkill(skillData.icon)
        local skillIcon = display.newSprite(iconPath)
        self.panel_3.panel_skill.ctn_1:removeAllChildren()
        self.panel_3.panel_skill.ctn_1:addChild(skillIcon)
        self.panel_3.panel_skill.panel_number.txt_1:setString(UserModel:level())
        self.panel_3.panel_skill.txt_1:setString(GameConfig.getLanguage(skillData.name))
        self.panel_3.panel_skill.mc_nu:showFrame(skillData.jiaobiao)
    end
    

    -- 解锁的属性类型
    local _str = ""
    if afterStar == 7 then
        else
            local starCfg = FuncTreasureNew.getTreasureUpstarDataByKeyID(self._treaSureId, afterStar)
        local _key = starCfg.addAttr7[1].key
        local attrData = FuncChar.getAttributeData()
        local attrName = GameConfig.getLanguage(attrData[tostring(_key)].name)
        -- qianhoupai
        local _dingwei = dataCfg.site
        local _dingweiStr = "前排"
        if _dingwei == 1 then
            _dingweiStr = "前排"
        elseif _dingwei == 2 then
            _dingweiStr = "中排"
        elseif _dingwei == 3 then
            _dingweiStr = "后排"
        end
        _str = GameConfig.getLanguageWithSwap("#tid_treature_unlockAddEffect_001",_dingweiStr,attrName)
        _str = "解锁永久属性:".._str
    end
    self.rich_1:setString(_str)
    
end

function TreasureUpStarShowView:registerEvent()
    TreasureUpStarShowView.super.registerEvent();
    self:registClickClose()
    self:registClickClose(-1, c_func( function()  
        self:startHide()  
        if self.callback then
            self.callback()
        end   
    end , self))
end


return TreasureUpStarShowView
