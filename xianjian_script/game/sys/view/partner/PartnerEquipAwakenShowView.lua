
local PartnerEquipAwakenShowView = class("PartnerEquipAwakenShowView",UIBase)
--[[
defaultParam = {
    partnerId 
    equipId
    awakeEquipId
    befor = {
        power = 3,
        hp = 3,
        act = 10,
        def = 32,
        magicDef = 100,
    },
    after
}
]]

function PartnerEquipAwakenShowView:ctor(_name,defaultParam,callback)
    PartnerEquipAwakenShowView.super.ctor(self,_name)
    self.data = defaultParam

    self.offset_table1 = {
        [1] = 0,
        [2] = -10,
        [3] = -30,
        [4] = -30,
        [5] = -50,
    }

    self.offset_table2 = {
        [1] = -40,
        [2] = -50,
        [3] = -55,
        [4] = -80,
        [5] = -90,
    }
end

function PartnerEquipAwakenShowView:loadUIComplete()
    self:registerEvent()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_efbg,UIAlignTypes.Middle)
    -- self.txt_jixu:setVisible(false)
    self:initData()
    self:updataUI()
end
function PartnerEquipAwakenShowView:initData()
    self.beforeData = self.data.before
    self.afterData = self.data.after
    self.partnerId = self.data.partnerId
    self.equipId = self.data.equipId
    self.awakeEquipId = self.data.awakeEquipId

    local parData = PartnerModel:getPartnerDataById(self.partnerId)
    self.equData = parData.equips[self.equipId]
    self.equDataCfg = FuncPartner.getEquipmentById(self.equipId)
    self.frame = self.equDataCfg[tostring(self.equData.level)].quality or 1

end

function PartnerEquipAwakenShowView:setEquipmentName(_panel, nameColor, equipmentName)
    _panel.mc_name:showFrame(tonumber(nameColor[1]))
    if tonumber(nameColor[2]) > 1 then
        local colorNum = tonumber(nameColor[2]) - 1
        _panel.mc_name.currentView.txt_1:setString(GameConfig.getLanguage(equipmentName).." +"..colorNum)
    else
        _panel.mc_name.currentView.txt_1:setString(GameConfig.getLanguage(equipmentName))
    end
end

function PartnerEquipAwakenShowView:updataUI()
    local _partnerInfo = nil
    ----------before---------
    local sprPath1 = FuncPartner.getEquipmentIconById( self.partnerId,self.equipId )
    sprPath1 = FuncRes.iconPartnerEquipment(sprPath1)
    local spr1 = cc.Sprite:create(sprPath1)
    
    self.panel_tou1.mc_tou1:showFrame(self.frame)
    local ctn = self.panel_tou1.mc_tou1.currentView.ctn_1
    ctn:removeAllChildren()
    ctn:addChild(spr1)

    local beforeName = FuncPartner.getEquipmentName(self.equipId, self.partnerId)
    local equData = self.equDataCfg[tostring(self.equData.level)]
    --装备名称
    local nameColor = equData.nameColor
    nameColor = string.split(nameColor,",")
    self:setEquipmentName(self.panel_tou1, nameColor, beforeName)

    --战力
    local beforePower = self.beforeData.power

    self.panel_number1.UI_1:setPower(beforePower)
    self.powerOffsetX1 = self.offset_table1[string.len(tostring(beforePower))]

    self.allNum = 0
    -- 属性
    for i,v in pairs(self.beforeData.beforeAttr) do
        self["panel_number"..(i+1)].mc_1:showFrame(1)
        local panel = self["panel_number"..(i+1)].mc_1.currentView
        panel.txt_1_2:setString(v.value)
        local frame = FuncPartner.ATTR_KEY_MC[tostring(v.key)]
        self["panel_number"..(i+1)].panel_1.mc_biao0:showFrame(frame)
        self["panel_number"..(i+1)].panel_1.txt_1:setString(v.name)

        self.allNum = self.allNum+1
    end

    ----------after----------
    local sprPath2 = FuncPartnerEquipAwake.getEquipAwakeIcon( self.awakeEquipId )
    sprPath2 = FuncRes.iconPartnerEquipment(sprPath2)
    local spr2 = cc.Sprite:create(sprPath2)
    
    self.panel_tou2.mc_tou1:showFrame(self.frame)
    local ctn2 = self.panel_tou2.mc_tou1.currentView.ctn_1
    ctn2:removeAllChildren()
    ctn2:addChild(spr2)
    local anim = self:createUIArmature("UI_shop", "UI_shop_zhuangbeijuexing", ctn2, true, GameVars.emptyFunc)
    anim:setScale(1.1)
    anim:pos(0, 5)

    local index = FuncPartner.getEquipIndexById(self.partnerId, self.equipId)
    local _equipId = FuncPartner.getAwakeEquipIdByIndex(self.partnerId, index)
    local awakeName = FuncPartnerEquipAwake.getEquipAwakeName(_equipId)
    self:setEquipmentName(self.panel_tou2, nameColor, awakeName)
    --战力
    self.panel_number1.UI_2:setPower(self.afterData.power)
    self.powerOffsetX2 = self.offset_table2[string.len(tostring(self.afterData.power))]

    for i,v in pairs(self.afterData.afterAttr) do
        self["panel_number"..(i+1)].mc_2:showFrame(2)
        local panel = self["panel_number"..(i+1)].mc_2.currentView
        panel.txt_1_3:setString(v.value)
    end
    
    --播放动画
    self:initAnim()
    -- self:onClose()

    self.panel_djjx:setVisible(false)
end


function PartnerEquipAwakenShowView:initAnim()

    -- 标题特效
    FuncCommUI.addCommonBgEffect(self.ctn_efbg, 11)

    self.panel_tou1:visible(false)
    self.panel_tou2:visible(false)
    self.panel_t1:visible(false)
    self.panel_t2:visible(false)
    self.panel_zhalisuoqu:visible(false)
    self.panel_number1:visible(false)
    self.panel_number2:visible(false)
    self.panel_number3:visible(false)
    self.panel_number4:visible(false)
    self.panel_number5:visible(false)
    local _animFunc = function ( ... )
        local jiesuanAnim = self:createUIArmature("UI_huoban","UI_huoban_shengpin_jiesuan", nil, false, 
        function ()
            self:registClickClose(-1, c_func( function()
                
                self:onClose()
            end , self))
        end)
        self.ctn_ani:addChild(jiesuanAnim)

        --替换 bones
        self.panel_tou1:pos(-160, 40)
        self.panel_tou2:pos(-150, 40)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"node1",self.panel_tou1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"node2",self.panel_tou2)
        --战力
        self.panel_zhalisuoqu:pos(-60,25)
        self.panel_number1.UI_1:pos(cc.p(self.powerOffsetX1, 12))
        self.panel_number1.UI_2:pos(cc.p(self.powerOffsetX2, 12))
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a6",self.panel_zhalisuoqu)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a7",self.panel_number1.UI_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a8",self.panel_number1.UI_2)
        --
        
        local shuxingPos = cc.p(-60,20)
        local numPos1 = cc.p(-200,16)
        local numPos2 = cc.p(-160,16)

        self.panel_number2.panel_1:pos(shuxingPos)
        self.panel_number2.mc_1:pos(numPos1)
        self.panel_number2.mc_2:pos(numPos2)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a11",self.panel_number2.panel_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a12",self.panel_number2.mc_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a13",self.panel_number2.mc_2)

        self.panel_number3.panel_1:pos(shuxingPos)
        self.panel_number3.mc_1:pos(numPos1)
        self.panel_number3.mc_2:pos(numPos2)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a16",self.panel_number3.panel_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a17",self.panel_number3.mc_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a18",self.panel_number3.mc_2)

        self.panel_number4.panel_1:pos(shuxingPos)
        self.panel_number4.mc_1:pos(numPos1)
        self.panel_number4.mc_2:pos(numPos2)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a21",self.panel_number4.panel_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a22",self.panel_number4.mc_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a23",self.panel_number4.mc_2)

        self.panel_number5.panel_1:pos(shuxingPos)
        self.panel_number5.mc_1:pos(numPos1)
        self.panel_number5.mc_2:pos(numPos2)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a26",self.panel_number5.panel_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a27",self.panel_number5.mc_1)
        FuncArmature.changeBoneDisplay(jiesuanAnim,"a28",self.panel_number5.mc_2)

        echo("\n\nself.allNum===", self.allNum)
        for i = 1,4 do
            if i > self.allNum then
                local index = i + 1
                local jiantou = jiesuanAnim:getBone("n0"..index)
                jiantou:setVisible(false)
                for k = 1,3 do
                    local tempIndex = index * 5 + k
                    echo("\n\ntempIndex====", tempIndex)
                    local node = jiesuanAnim:getBone("a"..tempIndex)
                    node:visible(false)
                end
            end
        end

    end
    self:delayCall(_animFunc, 0.5)

end

function PartnerEquipAwakenShowView:isXiangdeng(before,after)
    if before == after then
        return true
    else
        return false
    end
end
function PartnerEquipAwakenShowView:registerEvent()
    PartnerEquipAwakenShowView.super.registerEvent(self)
--    self:registClickClose("out")
    
    --关闭
--    self.btn_1:setTap(c_func(self.onClose,self))
end
function PartnerEquipAwakenShowView:onClose()
    local _partnerInfo = PartnerModel:getPartnerDataById(self.partnerId)
    local _star = PartnerModel:getAwakenSkillStar(self.partnerId)
    local treasureId = TeamFormationModel:getOnTreasureId()
    local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(_partnerInfo,_star,treasureId)
    local isWuqiAwake, wuqiSkillData = FuncPartner.checkWuqiAwakeSkill(_partnerInfo)
    local params = {}
    params._partnerInfo = _partnerInfo

    local playPowerAnim = true

    local callBack = function ()
        EventControler:dispatchEvent(PartnerEvent.PARTNER_EQUIPMENT_AWAKE__BACK_EVENT)
    end

    if equipAwake then
        params.isAwakeSkill = true
        WindowControler:showWindow("PartnerOpenSkillShowView", awakeSkillData.id, callBack, params)
        playPowerAnim = false
    end
    if self.equipId == FuncPartner.getPartnerWuqiId(_partnerInfo.id) and isWuqiAwake then
        params.isWeaponAwakeSkill = true
        WindowControler:showWindow("PartnerOpenSkillShowView", wuqiSkillData.id, callBack, params)
        playPowerAnim = false
    end

    if playPowerAnim then
        callBack()
    end

    self:startHide()
end
return PartnerEquipAwakenShowView
