--伙伴系统技能UI
--2016-12-9 10:32:22
--Author:xiaohuaxiong

local PartnerSkillView = class("PartnerSkillView" ,UIBase)
local LEVEL_LIMIT = 99

function PartnerSkillView:ctor(_winName)
    PartnerSkillView.super.ctor(self,_winName)
end

function PartnerSkillView:loadUIComplete()       
    self:initData()
    self:registerEvent()
    self.panel_1.panel_peipei.mc_xl.currentView.btn_1:setTap(c_func(self.onTouchYiJian, self))


    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_1, UIAlignTypes.Middle)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_name, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_gfj, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_dingwei, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_power, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_1.panel_peipei, UIAlignTypes.Right)
end

function PartnerSkillView:initData()
    self.isAnim = {}
    for i = 1, 9 do
        self.isAnim[i] = 0
    end
end

function PartnerSkillView:registerEvent()
    PartnerSkillView.super.registerEvent(self)
    --注册事件监听,伙伴的信息发生了变化
    -- EventControler:addEventListener(PartnerEvent.PARTNER_SKILL_CHANGED_EVENT, self.refreshSkillView, self)
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.updateUI, self)
    EventControler:addEventListener(TreasureNewEvent.UP_STAR_SUCCESS_EVENT, self.updateUI, self)
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.updateUI, self)  
    EventControler:addEventListener(TreasureNewEvent.DRESS_TREASURE_SUCCESS, self.updateUI, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_SKILL_UP_EVENT, self.updatePowerAnims, self)
end

-- function PartnerSkillView:refreshSkillView()
    -- self:updateUI()
-- end

--播放仙术修炼 后的战力特效  all为全部修炼   single为详情面板上的修炼
function PartnerSkillView:updatePowerAnims(event)
    local _type = "all"
    if event.params and event.params._type then
        _type = event.params._type
    end

    local oldAbility = self.oldAbility
    local _curAbility = CharModel:getCharOrPartnerAbility(self.partnerId)
    local powerChange = function ()
        if _type == "all" then
            FuncCommUI.showPowerChangeArmature(oldAbility or 10, _curAbility or 10)
        end
        self:refreshPower(_curAbility, oldAbility)
    end
    self:delayCall(c_func(powerChange), 5/GameVars.GAMEFRAMERATE) 
    self.oldAbility = _curAbility
end

function PartnerSkillView:tipsUI(ctn,_type)
    local _weight = 100
    local _height = 35
    if _type == FuncPartner.TIPS_TYPE.QUALITY_TIPS then --品质 名字
        _weight = 150
    elseif _type == FuncPartner.TIPS_TYPE.PARTNER_TYPE_TIPS then -- 类型
        _weight = 50
        _height = 50
    elseif _type == FuncPartner.TIPS_TYPE.STAR_TIPS then -- 星级
        _weight = 200
        _height = 40
    elseif _type == FuncPartner.TIPS_TYPE.POWER_TIPS then -- 战力
        
    elseif _type == FuncPartner.TIPS_TYPE.DESCRIBE_TIPS then -- 描述
        
    elseif _type == FuncPartner.TIPS_TYPE.LIKABILITY_TIPS then -- 好感度
    end
    local node = FuncRes.a_white( _weight,_height)
    ctn:removeAllChildren()
    ctn:addChild(node,10000)
    node:opacity(0)
    if FuncPartner.isChar(self.partnerInfo.id) and 
    _type == FuncPartner.TIPS_TYPE.PARTNER_TYPE_TIPS then 
        node:setTouchedFunc(function ()
            WindowControler:showWindow("PartnerCharDWTiShiView")
        end)
    else
        FuncCommUI.regesitShowPartnerTipView(ctn,{_type = _type,id = self.partnerInfo.id})
    end   
end

function PartnerSkillView:updateUI()
    if LS:prv():get(StorageCode.partner_skilledForSkill) then
        self.isSkillledPlayer = true
    else
        if PartnerModel:isSkilledPlayerForSkill() then
            self.isSkillledPlayer = true
        else
            self.isSkillledPlayer = false
        end
    end
            
    -- echo("\n\n_____________11111__________")
    local partnerData = FuncPartner.getPartnerById(self.partnerId)
    local elementFrom = partnerData.elements
    if not elementFrom then
        elementFrom = 6
    end
    if FuncPartner.isChar(self.partnerId) then
        local treasureId = TeamFormationModel:getOnTreasureId()
        local treaData = FuncTreasureNew.getTreasureDataById(treasureId)
        elementFrom = treaData.wuling or 6
    end
    -- if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FIVESOUL) then
    --     elementFrom = 6
    -- end
    self.panel_gfj.mc_tu2:showFrame(elementFrom)
    -- if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FIVESOUL) then
    --     self.panel_gfj.mc_tu2:visible(true)
    -- else
    --     self.panel_gfj.mc_tu2:visible(false)
    -- end

    local describe = FuncPartner.getDescribe(self.partnerId)  
    describe = GameConfig.getLanguage(describe)
    --姓名
    local quaData = FuncPartner.getPartnerQuality(self.partnerId) 

    if tonumber(self.partnerId) < 5000 then
        self.partnerInfo = PartnerModel:getPartnerDataById(self.partnerId)
        self:updateCharSkillView(self.partnerInfo)

        quaData = quaData[tostring(self.partnerInfo.quality)]
        local nameColor = quaData.nameColor
        nameColor = string.split(nameColor,",") 
        self.panel_name.mc_1:showFrame(tonumber(nameColor[1]))
        self.panel_name.mc_1.currentView.txt_1:setString(PartnerModel:getQiXiaName(self.partnerInfo))
    else
        --未拥有奇侠时 也需要能打开仙术界面 所以需要特殊处理
        if not PartnerModel:isHavedPatnner(self.partnerId) then
            self.partnerInfo = partnerData
            self.partnerInfo.id = self.partnerId
            quaData = quaData[tostring(1)]
            local nameColor = quaData.nameColor
            nameColor = string.split(nameColor,",") 
            self.panel_name.mc_1:showFrame(tonumber(nameColor[1]))
            self.panel_name.mc_1.currentView.txt_1:setString(PartnerModel:getQiXiaName(partnerData))
            self:updateNotObtainPartnerSkillView()
        else
            self.partnerInfo = PartnerModel:getPartnerDataById(self.partnerId)
            self:setPartnerInfo(self.partnerInfo)
            quaData = quaData[tostring(self.partnerInfo.quality)]
            local nameColor = quaData.nameColor
            nameColor = string.split(nameColor,",") 
            self.panel_name.mc_1:showFrame(tonumber(nameColor[1]))
            self.panel_name.mc_1.currentView.txt_1:setString(PartnerModel:getQiXiaName(self.partnerInfo))
        end 
    end

    
    self:tipsUI(self.panel_name.ctn_1,FuncPartner.TIPS_TYPE.QUALITY_TIPS)
    --type
    -- self.panel_gfj.mc_gfj:showFrame(partnerData.type)
    PartnerModel:partnerTypeShow(self.panel_dingwei.mc_1,partnerData )
    self:tipsUI(self.panel_gfj.ctn_1,FuncPartner.TIPS_TYPE.PARTNER_TYPE_TIPS)

    self.panel_dingwei.txt_bing:setString(describe)
    FuncCommUI.regesitShowPartnerTipView(self.panel_dingwei,{id = self.partnerId,_type = FuncPartner.TIPS_TYPE.DESCRIBE_TIPS})          
end

function PartnerSkillView:updateAwakenSkill(isChar)
    local _star = PartnerModel:getAwakenSkillStar(self.partnerId)
    local treasureId = TeamFormationModel:getOnTreasureId()
    local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(self.partnerInfo,_star,treasureId)
    local panel_awaken = self.panel_1.panel_skill8
    local skillId = awakeSkillData.id

    if isChar then
        local _iconPath = FuncRes.iconSkill(awakeSkillData.icon)
        local _iconSprite = cc.Sprite:create(_iconPath)
        local name = awakeSkillData.name
        panel_awaken.ctn_1:removeAllChildren()
        panel_awaken.ctn_1:addChild(_iconSprite)
        -- 仙术名称
        panel_awaken.txt_1:setString(GameConfig.getLanguage(name))
        panel_awaken.ctn_jin:removeAllChildren()
        panel_awaken.ctn_jin:setVisible(false)
        panel_awaken.panel_red:setVisible(false)
    end
    
    local skillLevel = 1
    if isChar then
        skillLevel = UserModel:level()
    else
        if self.partnerInfo.skills[tostring(skillId)] then
            skillLevel = self.partnerInfo.skills[tostring(skillId)]
        end
    end
    panel_awaken.panel_number.txt_1:setString(skillLevel)

    if awakeSkillData.order == 3 then
        panel_awaken.mc_nzb:showFrame(1)
    elseif awakeSkillData.order == 2 then
        panel_awaken.mc_nzb:showFrame(2)
    else
        panel_awaken.mc_nzb:showFrame(3)
    end

    if equipAwake then
        panel_awaken.txt_2:setVisible(false)
        FilterTools.clearFilter(panel_awaken)
        self:updateSaoguangAnim(panel_awaken.ctn_1, 0.56)
        panel_awaken.panel_number:setVisible(true)
        -- 仙术等级小于可提升上限时显示可提升提示图标 并标记为可添加特效
        if skillLevel < self.partnerInfo.level then
            -- 技能可提升时添加特效
            self.isAnim[9] = 1
            -- skillView.panel_jin:setVisible(true)
            panel_awaken.ctn_jin:removeAllChildren()
            self:createUIArmature("UI_common", "UI_common_xianshu_jiantou", panel_awaken.ctn_jin, true, GameVars.emptyFunc):setScale(0.6)
            panel_awaken.ctn_jin:setVisible(true)
        else
            self.isAnim[9] = 0
            -- skillView.panel_jin:setVisible(false)
            panel_awaken.ctn_jin:removeAllChildren()
            panel_awaken.ctn_jin:setVisible(false)
        end

        if not isChar then
            local _partner_skill = FuncPartner.getSkillInfo(skillId)
            self.yiJianCost = self.yiJianCost + self:getSkillCostSum(_partner_skill, skillLevel)
        end
        local showRed = self:isSkillCanLevelUp(awakeSkillData, skillLevel)
        panel_awaken.panel_red:setVisible(showRed)     
    else
        panel_awaken.txt_2:setVisible(true)
        -- panel_awaken.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_005"))
        FilterTools.setGrayFilter(panel_awaken)
        panel_awaken.panel_number:setVisible(false)
        panel_awaken.panel_red:setVisible(false)
    end
    
    local isAwaken = true
    panel_awaken.ctn_1:setTouchedFunc(c_func(self.onTouchSkillSingleView, self, skillId))
    
end

-- 必须实现的函数,以供PartnerView.lua统一调用，会将当前伙伴的信息传进来
function PartnerSkillView:updateUIWithPartner(_partnerInfo)
    self.hasPlayedAnim = false
    self.notObtain = false
    self.partnerInfo = _partnerInfo
    self.partnerId = _partnerInfo.id
    self.weaponAwakeSkillId = FuncPartner.getWeaponAwakeSkillIdByPartnerId(self.partnerId)
    
    if tonumber(self.partnerId) < 5000 then
        local treasureId = TeamFormationModel:getOnTreasureId()
        local partnerInfo = PartnerModel:getPartnerDataById(self.partnerId)
        -- self.awakeSkillId = FuncPartner.getAwakeSkillIdByPartnerId(self.partnerId, treasureId)
        -- local partnerData = FuncPartner.getPartnerById(self.partnerId)
        -- local skillId = partnerData.skill[1]
        -- local _skillInfo = FuncPartner.getSkillInfo(skillId)
        -- local _iconPath = FuncRes.iconSkill(_skillInfo.icon)
        self.panel_1.panel_peipei.mc_xl:showFrame(2)
        self.panel_1.panel_peipei:setVisible(true)
        self.panel_1.panel_peipei.mc_tong:setVisible(false)
        local btn = self.panel_1.panel_peipei.mc_xl.currentView.btn_1
        btn:setTouchedFunc(function ()
            if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TREASURE_NEW) then
                WindowControler:showTips(GameConfig.getLanguage("tid_common_2033")) 
            else    
                WindowControler:showWindow("TreasureMainView", treasureId)
            end
        end)
        self:updateUI()
        local _ability = UserModel:getCharAbility()
        self.oldAbility = _ability
        self.panel_power.UI_number:setPower(_ability)
        self.panel_power:setVisible(true)
    else
        self._starSkillCondition = {}
        -- 星级与技能的关系统计
        local _starSkillCondition={}
        local _starInfos = FuncPartner.getStarsByPartnerId(self.partnerId)
        for _key,_value in pairs(_starInfos) do
            if _value.skillId ~= nil then
                for k,v in pairs(_value.skillId) do
                    _starSkillCondition[v] = tonumber(_key)
                end
            end
        end
        self._starSkillCondition = _starSkillCondition

        if not PartnerModel:isHavedPatnner(self.partnerId) then
            self.notObtain = true
            self.panel_1.panel_peipei:setVisible(false)
            self:initSkillPanel(_partnerInfo)
            self:updateUI()
            self.panel_power:setVisible(false)
        else
            self.awakeSkillId = FuncPartner.getAwakeSkillIdByPartnerId(self.partnerId)

            self.panel_1.panel_peipei.mc_xl:showFrame(1)
            self:initSkillPanel(_partnerInfo)   
            self:updateUI()
            local _ability = PartnerModel:getPartnerAbility(self.partnerId)
            self.oldAbility = _ability
            self.panel_power.UI_number:setPower(_ability)
            self.panel_power:setVisible(true)
        end
    end
    
    self.hasPlayedAnim = true
end

function PartnerSkillView:updateNotObtainPartnerSkillView()
    local partnerData = FuncPartner.getPartnerById(self.partnerId)   
    local _skillInfos = partnerData.skill

    for i,v in ipairs(_skillInfos) do
        local skillId = v
        local skillInfo = FuncPartner.getSkillInfo(tostring(skillId))
        local skillView = self.panel_1["panel_skill"..i]
        if skillView.txt_2 then
            skillView.txt_2:setVisible(false)
        end
        
        if i > 1 then
            if skillInfo.order == 3 then
                skillView.mc_nzb:showFrame(1)
            elseif skillInfo.order == 2 then
                skillView.mc_nzb:showFrame(2)
            else
                skillView.mc_nzb:showFrame(3)
            end
        end

        skillView.panel_number:setVisible(false)
        skillView.ctn_1:setTouchedFunc(c_func(self.onTouchSkillSingleView, self, skillId))
        FilterTools.setGrayFilter(skillView)        
    end
end

function PartnerSkillView:updateCharSkillView(_partnerInfo)
    local charSkill = FuncChar.getCharSkillId(tostring(_partnerInfo.id))
    local treasureId = TeamFormationModel:getOnTreasureId()
    local treasureSkills = FuncTreasureNew.getTreasureSkills(treasureId,UserModel:avatar())
    local star_skill = TreasureNewModel:getStarSkillMap(treasureId)
    local treasureData = TreasureNewModel:getTreasureData(treasureId)
    self.awakeSkillId = FuncPartner.getAwakeSkillIdByPartnerId(self.partnerId, treasureId)
    local treasureStar = treasureData.star

    local _skillInfos = {}
    for i = 1, 9, 1 do
        if i == 1 then
            _skillInfos[i] = treasureSkills[i]
        elseif i == 2 then
            _skillInfos[i] = charSkill
        elseif i <= 7 then
            _skillInfos[i] = treasureSkills[i - 1]
        elseif i == 8 then
            _skillInfos[i] = self.weaponAwakeSkillId
        else
            _skillInfos[i] = self.awakeSkillId
        end        
    end

    for i, v in ipairs(_skillInfos) do
        local skillId = v
        local _skillInfo = nil
        local skillView = self.panel_1["panel_skill"..i]

        local level = _partnerInfo.level
        if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TREASURE_NEW) == false 
            or FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL) == false then
            level = 1
        end
        if skillId == charSkill or skillId == self.weaponAwakeSkillId then
            _skillInfo = FuncPartner.getSkillInfo(tostring(skillId))
            local _iconPath = FuncRes.iconSkill(_skillInfo.icon)
            local _iconSprite = cc.Sprite:create(_iconPath)
            skillView.ctn_1:removeAllChildren()
            skillView.ctn_1:addChild(_iconSprite)
            skillView.panel_number.txt_1:setString(level)
            skillView.panel_number:setVisible(true)
            skillView.txt_2:setVisible(false)
            skillView.mc_nzb:showFrame(2)
            if skillId == self.weaponAwakeSkillId then
                local isAwake = FuncPartner.checkWuqiAwakeSkill(_partnerInfo)
                if isAwake then
                    FilterTools.clearFilter(skillView)
                    self:updateSaoguangAnim(skillView.ctn_1, 0.56)
                else
                    FilterTools.setGrayFilter(skillView)
                    skillView.panel_number:setVisible(false)
                    skillView.txt_2:setVisible(true)
                    skillView.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_007"))
                end
            else
                self:updateSaoguangAnim(skillView.ctn_1, 0.56)
            end
        elseif skillId == self.awakeSkillId then
            _skillInfo = FuncTreasureNew.getTreasureSkillDataDataById(tostring(skillId))
            local _iconPath = FuncRes.iconSkill(_skillInfo.icon)
            local _iconSprite = cc.Sprite:create(_iconPath)
            skillView.ctn_1:removeAllChildren()
            skillView.ctn_1:addChild(_iconSprite)
            skillView.panel_number.txt_1:setString(level)
            skillView.panel_number:setVisible(true)
            local isAwake = FuncPartner.checkPartnerEquipSkill(_partnerInfo, treasureStar, treasureId)
            if isAwake then
                FilterTools.clearFilter(skillView)
                self:updateSaoguangAnim(skillView.ctn_1, 0.56)
                skillView.txt_2:setVisible(false)
            else
                FilterTools.setGrayFilter(skillView)
                skillView.panel_number:setVisible(false)
                skillView.txt_2:setVisible(true)
                skillView.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_008"))
            end
        else
            _skillInfo = FuncTreasureNew.getTreasureSkillDataDataById(tostring(skillId))
            local _iconPath = FuncRes.iconSkill(_skillInfo.icon)
            local _iconSprite = cc.Sprite:create(_iconPath)
            skillView.ctn_1:removeAllChildren()
            skillView.ctn_1:addChild(_iconSprite)
            skillView.panel_number:setVisible(true)

            local star_info = star_skill[tostring(skillId)]
            
            if i ~= 1 then
                if _skillInfo.order == 3 then
                    skillView.mc_nzb:showFrame(1)
                else
                    skillView.mc_nzb:showFrame(3)
                end

                if star_info.star <= treasureStar then
                    FilterTools.clearFilter(skillView)
                    self:updateSaoguangAnim(skillView.ctn_1, 0.6)
                    skillView.panel_number.txt_1:setString(level)
                    skillView.txt_2:setVisible(false)
                else
                    FilterTools.setGrayFilter(skillView)
                    skillView.panel_number:setVisible(false)
                    skillView.txt_2:setVisible(true)
                    skillView.txt_2:setString(GameConfig.getLanguage("#tid_partner_ui_015")..star_info.star..GameConfig.getLanguage("#tid_partner_ui_014"))
                end               
            else
                skillView.panel_number.txt_1:setString(level)
                FilterTools.clearFilter(skillView)
                self:updateSaoguangAnim(skillView.ctn_1, 0.79)
            end
            
        end 
        -- 仙术名称
        skillView.txt_1:setString(GameConfig.getLanguage(_skillInfo.name))
        skillView.ctn_jin:removeAllChildren()
        skillView.ctn_jin:setVisible(false)      
        -- 为每一个仙术添加点击 展示详情界面 事件
        skillView.ctn_1:setTouchedFunc(c_func(self.onTouchSkillSingleView, self, skillId))
        skillView.panel_red:setVisible(false)
    end

    local show = TreasureNewModel:homeRedPointEvent()
    self.panel_1.panel_peipei.mc_xl.currentView.btn_1:getUpPanel().panel_red:setVisible(show)
end

function PartnerSkillView:isCharSkill(_skillId)
    local charSkill = FuncChar.getCharSkillId(tostring(self.partnerId))
    if tostring(_skillId) == tostring(charSkill) then
        return true
    end
    return false
end

-- 设置伙伴仙术技能信息
function PartnerSkillView:setPartnerInfo(_partnerInfo)
    self.partnerId = _partnerInfo.id
    self.starLevel = _partnerInfo.star
    self.partnerLevel = _partnerInfo.level
    self.canYiJianXiuLian = false
    local partnerData = FuncPartner.getPartnerById(self.partnerId)

    --初始化技能    
    local _skillInfos = partnerData.skill
    self.yiJianCost = 0

    self:updateSkillInfo(_skillInfos)
    self:updateOneKeyButton()
end

--加载和刷新界面
function PartnerSkillView:updateSkillInfo(_skillInfos)
    for i, v in ipairs(_skillInfos) do
        local skillId = v
        -- 该技能是否解锁，并取得当前等级，未解锁等级为0
        local isUnlock, skillLevel =  PartnerModel:isUnlockSkillById(self.partnerId, skillId)
        local _partner_skill = FuncPartner.getSkillInfo(skillId)
        -- 通过解锁的技能求得一键升级需要的花费
        if isUnlock then
            self.yiJianCost = self.yiJianCost + self:getSkillCostSum(_partner_skill, skillLevel)    
        end

        local skillView = self.panel_1["panel_skill"..i]
        local saoguang_scale = 1
        if i == 1 then
            skillView.panel_number.txt_1:setString(skillLevel)  
            skillView.panel_number:setVisible(true) 
            saoguang_scale = 0.79      
        else
            if _partner_skill.order == 3 then
                skillView.mc_nzb:showFrame(1)
            elseif _partner_skill.order == 2 then
                skillView.mc_nzb:showFrame(2)
            else
                skillView.mc_nzb:showFrame(3)
            end

            if isUnlock then
                skillView.panel_number.txt_1:setString(skillLevel)
                skillView.txt_2:visible(false)
                skillView.panel_number:visible(true)
            else

                skillView.txt_2:visible(true)
                skillView.panel_number:visible(false)
                if tostring(v) == self.awakeSkillId then
                    skillView.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_008"))
                elseif tostring(v) == self.weaponAwakeSkillId then
                    skillView.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_007"))
                else
                    local starCondition = 1
                    if self._starSkillCondition[skillId] then
                        starCondition = self._starSkillCondition[skillId]
                    end
                    skillView.txt_2:setString(GameConfig.getLanguageWithSwap("#tid_partner_ui_034", starCondition))
                end         
            end
            saoguang_scale = 0.56
        end

        if isUnlock then
            -- 技能等级
            FilterTools.clearFilter(skillView)
            self:updateSaoguangAnim(skillView.ctn_1, saoguang_scale)
            if skillLevel < self.partnerLevel then
                -- 技能可提升时添加特效
                self.isAnim[i] = 1
                skillView.ctn_jin:removeAllChildren()
                self:createUIArmature("UI_common", "UI_common_xianshu_jiantou", skillView.ctn_jin, true, GameVars.emptyFunc):setScale(0.6)
                skillView.ctn_jin:setVisible(true)
            else
                self.isAnim[i] = 0
                skillView.ctn_jin:removeAllChildren()
                skillView.ctn_jin:setVisible(false)
            end
            local showRed = self:isSkillCanLevelUp(_partner_skill, skillLevel)
            skillView.panel_red:setVisible(showRed)
        else
            -- 未解锁，不显示等级，提示几星可开启
            FilterTools.setGrayFilter(skillView)
            skillView.panel_red:setVisible(false)
        end 
           
    end
end

function PartnerSkillView:updateOneKeyButton()
    -- 当前所有仙术已达满级后不显示一键修炼按钮
    if self:isAllMaxLevel() then
        self.panel_1.panel_peipei:setVisible(false)
    else
        if self.isSkillledPlayer then
            self.panel_1.panel_peipei:setVisible(true)
        else
            self.panel_1.panel_peipei:setVisible(false)
        end   
    end

    local btn = self.panel_1.panel_peipei.mc_xl:getViewByFrame(1).btn_1
    local userCoin = UserModel:getCoin()
    if self.yiJianCost == 0 then
        -- 不可一键修炼时不显示铜钱
        -- FilterTools.setGrayFilter(btn)
        self.panel_1.panel_peipei.mc_tong:setVisible(false)
    else
        -- 判断是否可以一键升级          
        if self.yiJianCost <= userCoin then
            self.panel_1.panel_peipei.mc_tong:showFrame(1)
            -- if self.yiJianCost > 0 then
            --     FilterTools.clearFilter(btn)
            -- end        
            self.canYiJianXiuLian = true
        else
            self.panel_1.panel_peipei.mc_tong:showFrame(2)
            -- FilterTools.setGrayFilter(btn)
        end
        self.panel_1.panel_peipei.mc_tong:setVisible(true)
        self.panel_1.panel_peipei.mc_tong.currentView.txt_1:setString(tostring(self.yiJianCost))
    end

    -- 刷新红点和战力
    self:refreshRedPoint()
end

--切换到仙术页签时  需要有有个扫光特效  之后再刷新就不再播放了
function PartnerSkillView:updateSaoguangAnim(_ctn, _scale)
    if self.hasPlayedAnim then
        return 
    end

    local saoguang = self:createUIArmature("UI_tubiaosaoguang", "UI_tubiaosaoguang", _ctn, false)
    local scale = _scale or 1
    saoguang:setScale(scale)
end

-- 初始化每一个技能panel中的不变元素   未唤醒的奇侠仙术需要全部置灰
function PartnerSkillView:initSkillPanel(_partnerInfo, isAllGray)
    self.partnerId = _partnerInfo.id
    --初始化技能 
    local partnerData = FuncPartner.getPartnerById(self.partnerId)   
    local _skillInfos = partnerData.skill  

    -- dump(_skillInfos, "\n\n_skillInfos======")
    for i, v in ipairs(_skillInfos) do
        local skillId = v
        local skillView = self.panel_1["panel_skill"..i]
        local _skillInfo = FuncPartner.getSkillInfo(skillId)
        local _iconPath = FuncRes.iconSkill(_skillInfo.icon)
        local _iconSprite = cc.Sprite:create(_iconPath)
        skillView.ctn_1:removeAllChildren()
        skillView.ctn_1:addChild(_iconSprite)
        -- 为每一个仙术添加点击 展示详情界面 事件
        skillView.ctn_1:setTouchedFunc(c_func(self.onTouchSkillSingleView, self, skillId))
        -- 仙术名称
        skillView.txt_1:setString(GameConfig.getLanguage(_skillInfo.name))
        skillView.ctn_jin:removeAllChildren()
        skillView.ctn_jin:setVisible(false)
        skillView.panel_red:setVisible(false)
    end
end

-- 计算 一键修炼 需要的铜钱  
function PartnerSkillView:getSkillCostSum(_partner_skill, skillLevel)
    if skillLevel == 0 then 
        skillLevel = 1
    end
    -- 根据不同的品质取得配表中仙术提升的铜钱花费列表
    local upSkillCost = FuncPartner.getSkillCostInfo(tostring(_partner_skill.quality))
    local costSum = 0
    local realCost = 0
    -- 当前等级已至最高消费为0
    if skillLevel == self.partnerLevel then
        costSum = 0
    else
        for i = skillLevel, tonumber(self.partnerLevel - 1) do
            realCost = upSkillCost[tostring(i)].coin        
            costSum = costSum + realCost
        end
    end
    
    return costSum
end

--判断仙术是否可以升级
function PartnerSkillView:isSkillCanLevelUp(_skillInfo, _level)
    local upSkillCost = FuncPartner.getSkillCostInfo(tostring(_skillInfo.quality))
    local skillLevel = _level
    local coinCost = 0
    if skillLevel == 0 then
        skillLevel = 1
    end    
    if skillLevel == self.partnerLevel then
        return false
    else
        coinCost = upSkillCost[tostring(skillLevel)].coin
        if coinCost <= UserModel:getCoin() then
            return true
        end
    end
    return false
end

-- 点击一键升级后扫光动画
function PartnerSkillView:playAnim()
    -- 为标记了可提升的仙术添加特效
    for i = 1, 9 do
        if self.isAnim[i] == 1 then
            local anim = self.panel_1["panel_skill"..i].ctn_1:getChildByName("xianshu")
            if not anim then
                anim = self:createUIArmature("UI_huoban_zhuangbei", "UI_huoban_zhuangbei_xianshu", self.panel_1["panel_skill"..i].ctn_1, true)
                anim:setName("xianshu")
            end
            anim:startPlay(false, false)
        end
    end 
end

-- 判断技能是否全部开启并提升至最高
function PartnerSkillView:isAllMaxLevel()
    -- 该接口可以取得已解锁的所有仙术及其等级
    local data = PartnerModel:getPartnerDataById(tostring(self.partnerId))
    local skills = data.skills
    local maxLevel = LEVEL_LIMIT
    local count = 0
    for k, v in pairs(skills) do
        if v < maxLevel then
            return false
        end
    end 
    return true 
end

-- 点击一键修炼按钮
function PartnerSkillView:onTouchYiJian()
    if self.canYiJianXiuLian and self.yiJianCost > 0 then
        self:playAnim()
        -- self.oldPower = CharModel:getCharOrPartnerAbility(self.partnerId)
        AudioModel:playSound(MusicConfig.s_skill_xiulian, false)     
        -- isAll传1为一键修炼，此时skillId和level可传可不传
        PartnerServer:skillLevelupRequest({partnerId = tonumber(self.partnerId), skillId = 0, level = 0, isAll = 1}, c_func(self.skillUp, self))

    elseif self.yiJianCost == 0 then
        WindowControler:showTips(GameConfig.getErrorLanguage("#error420902"))
    else
        FuncCommUI.showCoinGetView() 

        local tips = GameConfig.getLanguage("tid_common_2021")
        WindowControler:showTips(tips)

    end    
end

-- 点击一键升级后刷新界面
function PartnerSkillView:skillUp() 
    EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_UP_EVENT, {_type = "all"})
    -- self:updateUI()
    -- local powerChange = function ()
    --     self.curPower = CharModel:getCharOrPartnerAbility(self.partnerId)
    --     FuncCommUI.showPowerChangeArmature(self.oldPower or 10, self.curPower or 10 
    --                 );
    --     self:refreshPower(self.curPower, self.oldPower)
    -- end
    
    -- self:delayCall(c_func(powerChange), 20/GameVars.GAMEFRAMERATE)
end

-- 点击仙术icon弹窗
function PartnerSkillView:onTouchSkillSingleView(_skillId)
    WindowControler:showWindow("PartnerSkillSingleView", _skillId, self.partnerInfo, self.notObtain)
end

-- 刷新红点
function PartnerSkillView:refreshRedPoint()
    local btn_red = self.panel_1.panel_peipei.mc_xl.currentView.btn_1:getUpPanel().panel_red
    local redPoint = PartnerModel:isShowSkillRedPoint(self.partnerId)
    btn_red:setVisible(redPoint)   
end

--战力刷新
function PartnerSkillView:refreshPower(_curPower, _oldPower)
    local frame = _curPower - _oldPower
    if frame > 30 then
        frame = 30
    end

    for i = 1, frame do
        self:delayCall(function ()
                local num = math.floor((_curPower - _oldPower) * 1.0 / frame * i) + _oldPower
                self.panel_power.UI_number:setPower(num)
            end, i / GameVars.GAMEFRAMERATE)
    end 
end

return PartnerSkillView