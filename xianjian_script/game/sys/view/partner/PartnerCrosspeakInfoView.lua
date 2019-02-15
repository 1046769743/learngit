local PartnerCrosspeakInfoView = class("PartnerCrosspeakInfoView", UIBase)

function PartnerCrosspeakInfoView:ctor(winName,id,enemyId)
    PartnerCrosspeakInfoView.super.ctor(self, winName)
    self.id = id
    self.enemyId = enemyId
end
function PartnerCrosspeakInfoView:loadUIComplete()
    self:setAlignment()
    self:registerEvent()
    self:updataUI(self.id,self.enemyId);
end


function PartnerCrosspeakInfoView:setAlignment()
end

function PartnerCrosspeakInfoView:registerEvent()
    PartnerCrosspeakInfoView.super.registerEvent(); 

    local closeCall = function (  )
        self:startHide()
    end
    self.panel_2.UI_tc.btn_close:setTap(closeCall)
    -- 点击空白区域关闭
    self:registClickClose("out",closeCall,nil,nil,{0.9,0.38,false})

    self.panel_2.UI_tc.mc_1:visible(false)
end

function PartnerCrosspeakInfoView:updataUI(_partnerId,_enemyId)
    --  标题 
    self.panel_2.UI_tc.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_008"))
    --  奇侠信息
    local enemyData = FuncCrosspeak.getParternerData(_enemyId)
    local dataCfg = FuncPartner.getPartnerById(_partnerId)
    local quality = enemyData.quality
    
    
    local panel = self.panel_2
    panel.UI_tx:updataUI(_partnerId,skin)
    panel.UI_tx:setStar(enemyData.star)
    panel.UI_tx:setQulity(enemyData.quality)
    panel.UI_tx:setLevel( enemyData.level )
    --姓名
    local quaData = FuncPartner.getPartnerQuality(_partnerId)
    quaData = quaData[tostring(quality)]
    local nameColor = quaData.nameColor
    nameColor = string.split(nameColor,",") 
    panel.panel_name.mc_1:showFrame(tonumber(nameColor[1]))
    if tonumber(nameColor[2]) > 1 then
        local colorNum = tonumber(nameColor[2]) - 1
        panel.panel_name.mc_1.currentView.txt_1:setString(FuncPartner.getPartnerName(_partnerId).."+"..colorNum)
    else
        panel.panel_name.mc_1.currentView.txt_1:setString(FuncPartner.getPartnerName(_partnerId))
    end
    -- 五行
    -- if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FIVESOUL) then
        panel.mc_tu2:visible(true)
        if FuncPartner.isChar(_partnerId) then
            local treasureId = TeamFormationModel:getOnTreasureId()
            local treaData = FuncTreasureNew.getTreasureDataById(treasureId)
            local elementFrom = treaData.wuling or 6 
            panel.mc_tu2:showFrame(elementFrom)
        else
            panel.mc_tu2:showFrame(dataCfg.elements)
        end
    -- else
    --     panel.mc_tu2:visible(false)
    -- end
    
    -- 定位 攻防辅
    -- panel.panel_gfj.mc_gfj:showFrame(dataCfg.type)
    PartnerModel:partnerTypeShow(panel.panel_gfj.mc_gfj,dataCfg )
    -- 战力
    panel.mc_power:showFrame(1)

    panel.mc_power:showFrame(1)
    local partnerData = PartnerModel:getPartnerDataById(tostring(_partnerId));
    local _ability = 0    --CharModel:getCharOrPartnerAbility(_partnerId)
    panel.mc_power.currentView.panel_power.UI_number:setPower(_ability)
    panel.mc_power:visible(false)

    panel.txt_1:setString(99)
    -- 情缘 
    panel.txt_1:visible(false)
    panel.panel_daye:visible(false)
    ----- 伙伴信息 ------
    self:initPartnerInfo()
end

function PartnerCrosspeakInfoView:initPartnerInfo()
    self.panel_2.panel_1:visible(false)
    self.panel_2.panel_2:visible(false)
    self.panel_2.panel_3:visible(false)
    self.panel_2.panel_4:visible(false)
    self.panel_2.panel_5:visible(false)
    self.panel_2.panel_6:visible(false)

    local _scrollParams = self:initScrollData()
    self.panel_2.scroll_1:refreshCellView( 1 )
    self.panel_2.scroll_1:styleFill(_scrollParams);
    self.panel_2.scroll_1:hideDragBar()
end
function PartnerCrosspeakInfoView:initScrollData( )
    local createFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_2["panel_"..itemData])
        self:updateItem(view, itemData)
        return view
    end
    local updateFunc = function (_item,_view)
        self:updateItem(_view,_item)
    end
     -- 技能panel 长度 
    local skillY = 540
    if not self.attrY then
        self.attrY = 220
    end
     
    local pianyiX = -20
    local _scrollParams = {
            {
                data = {1},
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX = 20,
                offsetY =0,
                itemRect = {x=0,y= -self.attrY,width=446,height = self.attrY},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            },
            {
                data = {2},
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX =pianyiX,
                offsetY =0,
                itemRect = {x=0,y= -83,width=446,height = 83},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            },
            {
                data = {3},
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX =pianyiX,
                offsetY =0,
                itemRect = {x=0,y= -skillY,width=446,height = skillY},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            },
            {
                data = {5},
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX =pianyiX,
                offsetY =20,
                itemRect = {x=0,y= -200,width=446,height = 220},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            }
        }
    local partnerTagData = {
            data = {6},
            createFunc= createFunc,
            updateFunc = updateFunc,
            perFrame = 1,
            offsetX = pianyiX,
            offsetY =0,
            itemRect = {x=0,y= -116,width=446,height = 116},
            widthGap = 0,
            heightGap = 0,
            perNums = 1,
        }
        table.insert(_scrollParams,2 ,partnerTagData)
    return _scrollParams
end
function PartnerCrosspeakInfoView:updateItem(view, itemData)
    local partnerData = FuncPartner.getPartnerById(self.id);
    local enemyData = FuncCrosspeak.getParternerData(self.enemyId)
    if itemData == 1 then --属性
        self:initProperty(view)
    elseif itemData == 2 then --定位
        self:initDingWei(view)
    elseif itemData == 3 then --技能
        local skills = partnerData.skill

        local _starSkillCondition={}
        local _starInfos = FuncPartner.getStarsByPartnerId(self.id)
        for _key,_value in pairs(_starInfos) do
            if _value.skillId ~= nil then
                for k,v in pairs(_value.skillId) do
                    local _data = {skill = v,star = _key}
                    table.insert(_starSkillCondition, _data)
                end
            end
        end
        local _sortF = function(a,b)
            if tonumber(a.star)<tonumber(b.star) then
                return true
            else
                return false
            end
        end
        table.sort(_starSkillCondition,_sortF)
        local index = 1
        for i,v in pairs(_starSkillCondition) do
        	local isUnLock = false
        	local skillLevel = enemyData.level
            if tonumber(enemyData.star) >= tonumber(v.star) then
            	isUnLock = true
            end
            self:initSkill(view["panel_"..(index+1)],v.skill,skillLevel,isUnLock,index)
            index = index + 1
        end

        local skillLevel = 1
        local partnerMappingData = FuncCrosspeak.getPartnerMapping(self.enemyId)
        local weaponAwakeSkillId = partnerData.weaponAwakeSkillId
        local weaponAwake = false
        if partnerMappingData.weaponAwake then
            weaponAwake = true
            skillLevel = enemyData.level
        end
        local awakeSkillId = partnerData.awakeSkillId
        local awake = false
        if partnerMappingData.awake then
            awake = true
            skillLevel = enemyData.level
        end
        self:initSkill(view["panel_"..9], weaponAwakeSkillId, skillLevel, weaponAwake, 8)
        self:initSkill(view["panel_"..10], awakeSkillId, skillLevel, awake, 9)
    elseif itemData == 4 then --情缘

 
    elseif itemData == 5 then --描述
        view.rich_1:setString(GameConfig.getLanguage(partnerData.describe))
    elseif itemData == 6 then --传记
        self:zhuanjiDes(view )
    end
    
end
-- 传记
function PartnerCrosspeakInfoView:zhuanjiDes(view )
    -- body
    if not FuncPartner.isChar(self.id) then
        local partnerData = FuncPartner.getPartnerById(self.id)
        local partnerTag = partnerData.tag
        if not partnerTag then
            echoError("伙伴的传记信息没配",self.id)
            -- view:visible(false)
            return
        end
        -- 仙剑版本 #tid_partner_ui_011
        local banben = FuncCommon.getPartnerTagDataByIdAndTag( "2",partnerTag[2] )
        banben = GameConfig.getLanguage(banben)
        view.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_009")..banben)
        -- 种族
        local zhongzu = FuncCommon.getPartnerTagDataByIdAndTag( "4",partnerTag[4] )
        zhongzu = GameConfig.getLanguage(zhongzu)
        view.txt_2:setString(GameConfig.getLanguage("#tid_partner_ui_010")..zhongzu)
        -- 门派
        local menpai = FuncCommon.getPartnerTagDataByIdAndTag( "6",partnerTag[6] ) 
        menpai = GameConfig.getLanguage(menpai)
        view.txt_3:setString(GameConfig.getLanguage("#tid_partner_ui_011")..menpai)
        -- 武器
        local wuqi = FuncCommon.getPartnerTagDataByIdAndTag( "5",partnerTag[5] ) 
        wuqi = GameConfig.getLanguage(wuqi)
        view.txt_4:setString(GameConfig.getLanguage("#tid_partner_ui_012")..wuqi)
    end
end

-- 情缘加成
function PartnerCrosspeakInfoView:loveDes(_view)
    -- local txt = _view.rich_1
    _view.rich_1:setVisible(false)
    local posX = _view.rich_1:getPositionX()
    local posY = _view.rich_1:getPositionY()
    local mainPartnerData = PartnerModel:getPartnerDataById(self.id)
    local vicePartners = FuncNewLove.getVicePartnersListByPartnerId(self.id) or {}
    local mainName = FuncPartner.getPartnerName(self.id)
    local viceName = nil

    -- 情缘详情按钮
    local a,b,c,d = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.LOVE)
    local _func = function ( ... )
        if a then
            WindowControler:showWindow("NewLovePartnerView",self.id)
        else
            --
            local str = GameConfig.getLanguageWithSwap("#tid_partner_32",b)
            WindowControler:showTips(str)
        end
    end
    if FuncPartner.isChar(self.id) or (not PartnerModel:isHavedPatnner(self.id)) then
        _view.btn_xq:visible(false)
    else
        local touchNode = FuncRes.a_white( 420,200)
        touchNode:setTouchedFunc(_func,nil,nil,nil,nil,false)
        touchNode:addto(_view)
        touchNode:setAnchorPoint(cc.p(0,1))
        touchNode:setPositionX(posX)
        touchNode:setPositionY(posY)
        touchNode:opacity(0)
    end
    
    if a then
        FilterTools.clearFilter(_view.btn_xq);
    else
        FilterTools.setGrayFilter(_view.btn_xq);
    end
    _view.btn_xq:setTap(_func)
    if not self.adddesNode then 
        self.adddesNode = display.newNode()
        self.adddesNode:addto(_view)
    end 
    self.adddesNode:removeAllChildren()
    for k,vicePartnerId in ipairs(vicePartners) do             
        local txt = UIBaseDef:cloneOneView(_view.rich_1)
        txt:setPositionX(posX)
        txt:setPositionY(posY - 50*(k-1) )
        txt:addto(self.adddesNode)

        viceName = FuncPartner.getPartnerName(vicePartnerId)
        local str = "【"..mainName.."--"..viceName.."】"..mainName

        local dataArrCur,isHas = nil,nil
        if not mainPartnerData then
            dataArrCur,isHas = FuncNewLove.getOneLoveCurrentProperty( self.id,vicePartnerId )
        else
            dataArrCur,isHas = FuncNewLove.getOneLoveCurrentProperty( mainPartnerData,vicePartnerId )
        end
        local dataArrMax = FuncNewLove.getOneLoveTopProperty( self.id,vicePartnerId )
        local index = 0
        -- local str = ""

        -- dump(dataArrCur,"情缘属性加成")
        dataArrCur = FuncBattleBase.formatAttribute( dataArrCur )
        -- dump(dataArrCur,"处理后情缘属性加成")

        -- dump(dataArrMax,"情缘属性zuida加成")
        dataArrMax = FuncBattleBase.formatAttribute( dataArrMax )
        -- dump(dataArrMax,"处理后情缘属性zuida加成")

        local attrStr = ""
        for k,m in pairs(dataArrCur) do
            local value = m.value
            if m.mode == 2 then
                value = value / 100
                value = value .. "%"
            end
            attrStr = attrStr .. m.name.."+"..value
            -- echo("\n\n一条属性---",attrStr)
            for kk,vv in pairs(dataArrMax) do
                if vv.name == m.name then
                    attrStr = attrStr.."(最大"..(vv.value/100).."%), "
                end
            end
            -- echo("\n\n一条属性222---",attrStr)
        end
        -- echo("是否拥有--- ",isHas)
        if isHas then
            str = "<color = 009407>"..str..attrStr.."<->"
        else
            str = "<color = 999999>"..str..attrStr.."<->"
        end

        txt:setString(str)
        
    end
    self.loveDesFinish = true
end

-- 定位
function PartnerCrosspeakInfoView:initDingWei(_view)
    local charaCteristic = FuncPartner.getDescribe(self.id)
    _view.txt_1:setString(GameConfig.getLanguage(charaCteristic))
end
-- 描述
function PartnerCrosspeakInfoView:initDescribe( _view )
    _view.rich_1:setString(GameConfig.getLanguage(partnerData.describe))
end
function PartnerCrosspeakInfoView:getSkillIcon(skillId,_skillLevel)
    skillLevel = _skillLevel or 1
    local  _skillInfo = FuncPartner.getSkillInfo(skillId)
    --图标
    local  _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local  _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:scale(0.4)
    return _iconSprite
end
function PartnerCrosspeakInfoView:initSkill(view,skillId,skillLevel,isUnlock,index)
    if skillLevel == 0 then
        skillLevel = 1
    end
    local partnerCfg = FuncPartner.getPartnerById(self.id)
    local _skillInfo = FuncPartner.getSkillInfo(skillId)
    local _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)
   -- _iconSprite:scale(0.7)
    if index == 1 then
        view.mc_skill:showFrame(2)
    else
        view.mc_skill:showFrame(1)
    end
    
    local ctn = view.mc_skill.currentView.ctn_1
    ctn:removeAllChildren()
    ctn:addChild(_iconSprite)
    --技能名称
    view.txt_1:setString(GameConfig.getLanguage(_skillInfo.name))
    --
    view.panel_number:visible(false)
    -- 判断是否解锁
    if isUnlock then
        --技能等级
        view.txt_3:setString(GameConfig.getLanguage("#tid_partner_ui_006")..skillLevel..GameConfig.getLanguage("#tid_partner_ui_013"))
        -- view.panel_suo:visible(false)
    else
        if skillId == partnerCfg.weaponAwakeSkillId then
            view.txt_3:setString(GameConfig.getLanguage("#tid_partner_awaken_007"))
        elseif skillId == partnerCfg.awakeSkillId then
            view.txt_3:setString(GameConfig.getLanguage("#tid_partner_awaken_008"))
        else
            --解锁条件 #tid_partner_ui_014
            local starNum = FuncPartner.unlockSkillStar(self.id,skillId)
            view.txt_3:setString(starNum..GameConfig.getLanguage("#tid_partner_ui_014"))
        end
        
        -- view.panel_suo:visible(true)
        FilterTools.setGrayFilter(view.mc_skill)
    end
    FuncCommUI.regesitShowSkillTipView(_iconSprite,{partnerId = self.id, id = skillId,level = skillLevel or 1,isUnlock = isUnlock,_index = index},false)
end

function PartnerCrosspeakInfoView:initProperty(view)
    local propertyVec1 = {};
    local propertyVec2 = {};
    local function initPropertyF(propertyData)
        for i,v in pairs(propertyData) do
            if self:isInitProperty(v.key) then
                table.insert(propertyVec1,v)
            else
                v.value = (tonumber(v.value)/100).. "%"
                table.insert(propertyVec2,v)
            end
        end
    end;
    local enemyData = FuncCrosspeak.getParternerData(self.enemyId)
    local attrData = enemyData.attr
    initPropertyF(attrData)
    if not self.currentStage then
        self.currentStage = 1 -- 当前显示详情状态
    end
    local dataAttr = propertyVec1
    if self.currentStage == 2 then
        dataAttr = propertyVec2
    end
    local partnerData = nil
    --初始属性
    self:showProperty(view,self.currentStage,partnerData,dataAttr)

    local btnTapFunc = function ()
        if self.currentStage == 1 then
            self.currentStage = 2
            view.btn_1:getUpPanel().mc_1:showFrame(self.currentStage)
            self:showProperty(view,self.currentStage,partnerData,propertyVec2)
        elseif self.currentStage == 2 then
            self.currentStage = 1
            self:showProperty(view,self.currentStage,partnerData,propertyVec1)
            view.btn_1:getUpPanel().mc_1:showFrame(self.currentStage)
        end
        self:initPartnerInfo()
        -- self.panel_2.scroll_1:refreshScroll()
    end

    
    local btn = view.btn_1
    view.btn_1:getUpPanel().mc_1:showFrame(self.currentStage)
    btn:setTap(btnTapFunc)
    
--    echo(os.clock() - t1,"-------- 初始 属性 消耗时间");
end
function PartnerCrosspeakInfoView:showProperty(view,_type,partnerData,data)
    -- echoError("_type === ",_type)
    local MAX_NUM  = 8
    for i = 2,MAX_NUM do
        view["panel_"..i]:visible(false)
    end
    local ctn = view.ctn_1
    ctn:removeAllChildren()
    local partnerConfigData = FuncPartner.getPartnerById(self.id);
    local buteData = FuncChar.getAttributeData()
    if tonumber(_type) == 1 then -- 显示基础属性 等级 品质等
        -- 添加 等级
        view.panel_2:visible(true)
        local enemyData = FuncCrosspeak.getParternerData(self.enemyId)
        view.panel_2.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_006")..enemyData.level)
        self.attrY = 220
        local index = 0
        for i,v in pairs(data) do
            index = index + 1
            if index < MAX_NUM+1 then
                view["panel_"..(index+2)]:visible(true)
                view["panel_"..(index+2)].txt_1:setString(FuncBattleBase.getAttributeName( v.key )..": "..v.value)
                -- view["panel_"..(index+3)].txt_2:setString(v.value)
                -- view["panel_"..(index+3)].txt_2:visible(false)
                view["panel_"..(index+2)].mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.key)])
            else
                echo("没有显示的属性 : "..FuncBattleBase.getAttributeName( v.key ))
            end
        end
    else
         -- 添加属性
        for i = 2,MAX_NUM do
            view["panel_"..i]:visible(false)
        end
        local index = 0
        for i,v in pairs(data) do
            local panel_attr = UIBaseDef:cloneOneView(view["panel_2"])
            panel_attr:visible(true)
            local posX = 20
            local posY = 0
            if index % 2 == 1 then
                posX = 250
            end
            posY =  math.floor(index/2) * -40 + 10
            self.attrY = 90 + math.floor(index/2) * 60
            ctn:addChild(panel_attr)
            panel_attr:pos(posX,posY)
            panel_attr.txt_1:setString(FuncBattleBase.getAttributeName( v.key )..": "..v.value)
            panel_attr.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.key)])
            index = index + 1
        end
    end
end
-- 是否会放到初始属性里 -- 这里 先这样写死
function PartnerCrosspeakInfoView:isInitProperty(_type) 
    if tonumber(_type) == 2 then
        return true
    elseif tonumber(_type) == 10 then
        return true
    elseif tonumber(_type) == 11 then
        return true
    elseif tonumber(_type) == 12 then
        return true
    else
        return false
    end
end


return PartnerCrosspeakInfoView
