local CrosspeakPartnerInfoView = class("CrosspeakPartnerInfoView", UIBase)

function CrosspeakPartnerInfoView:ctor(winName,id,enemyId)
    CrosspeakPartnerInfoView.super.ctor(self, winName)
    self.id = id
    self.enemyId = enemyId
end
function CrosspeakPartnerInfoView:loadUIComplete()
    self:setAlignment()
    self:registerEvent()
    self:updataUI(self.id,self.enemyId);
end


function CrosspeakPartnerInfoView:setAlignment()
end

function CrosspeakPartnerInfoView:registerEvent()
    CrosspeakPartnerInfoView.super.registerEvent(); 

    local closeCall = function (  )
        self:startHide()
    end
    self.panel_2.UI_tc.btn_close:setTap(closeCall)
    -- 点击空白区域关闭
    self:registClickClose("out",closeCall,nil,nil,{0.9,0.38,false})

    self.panel_2.UI_tc.mc_1:visible(false)

end

function CrosspeakPartnerInfoView:updataUI(_partnerId,_enemyId)
    --  标题 
    self.panel_2.UI_tc.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_008"))
    --  奇侠信息
    local enemyData = FuncCrosspeak.getParternerData(_enemyId)
    local dataCfg = FuncPartner.getPartnerById(_partnerId)
    local quality = enemyData.quality
    
    
    local panel = self.panel_2
    panel.UI_tx:updataUI(_partnerId,skin)

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
    local _ability = CharModel:getCharOrPartnerAbility(_partnerId)
    panel.mc_power.currentView.panel_power.UI_number:setPower(_ability)
    panel.txt_1:setString(99)
    -- 情缘 
    panel.txt_1:visible(false)
    panel.panel_daye:visible(false)
    ----- 伙伴信息 ------
    -- self:initPartnerInfo()
end

function CrosspeakPartnerInfoView:initPartnerInfo()
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

    if tostring(self.id) == "5003" then
        if not LS:prv():get("5003_opened",nil) then
            LS:prv():set("5003_opened",true);
            self.panel_2.scroll_1:gotoTargetPos(1, 2 ,0)
        end
    end
end
function CrosspeakPartnerInfoView:initScrollData( )
    local createFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_2["panel_"..itemData])
        self:updateItem(view, itemData)
        return view
    end
    local updateFunc = function (_item,_view)
        self:updateItem(_view,_item)
    end
     -- 技能panel 长度 
    local skillY = 450
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
function CrosspeakPartnerInfoView:updateItem(view, itemData)
    local partnerData = FuncPartner.getPartnerById(self.id);
    if itemData == 1 then --属性
        self:initProperty(view)
    elseif itemData == 2 then --定位
        self:initDingWei(view)
        -- view.txt_1:setString(GameConfig.getLanguage(partnerData.charaCteristic))
    elseif itemData == 3 then --技能
        if FuncPartner.isChar(self.id) then
            self:initCharSkill(view)
        else
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
                local isUnlock , skillLevel =  PartnerModel:isUnlockSkillById(self.id,v.skill)
                self:initSkill(view["panel_"..(index+1)],v.skill,skillLevel,isUnlock,index)
                index = index + 1
            end
        end
    elseif itemData == 4 then --情缘
        self:loveDes(view)
       -- view.rich_1:setString("情缘数据 找曹称要-------")
 
    elseif itemData == 5 then --描述
        view.rich_1:setString(GameConfig.getLanguage(partnerData.describe))
    elseif itemData == 6 then --传记
        self:zhuanjiDes(view )
    end
    
end
-- 传记
function CrosspeakPartnerInfoView:zhuanjiDes(view )
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
function CrosspeakPartnerInfoView:loveDes(_view)
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
function CrosspeakPartnerInfoView:initDingWei(_view)
    local charaCteristic = FuncPartner.getDescribe(self.id)
    _view.txt_1:setString(GameConfig.getLanguage(charaCteristic))
end
-- 描述
function CrosspeakPartnerInfoView:initDescribe( _view )
    _view.rich_1:setString(GameConfig.getLanguage(partnerData.describe))
end
function CrosspeakPartnerInfoView:getSkillIcon(skillId,_skillLevel)
    skillLevel = _skillLevel or 1
    local  _skillInfo = FuncPartner.getSkillInfo(skillId)
    --图标
    local  _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local  _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:scale(0.4)
    return _iconSprite
end
function CrosspeakPartnerInfoView:initSkill(view,skillId,skillLevel,isUnlock,index)
    if skillLevel == 0 then
        skillLevel = 1
    end
    local  _skillInfo = FuncPartner.getSkillInfo(skillId)
    local  _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local  _iconSprite = cc.Sprite:create(_iconPath)
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
        --解锁条件 #tid_partner_ui_014
        local starNum = FuncPartner.unlockSkillStar(self.id,skillId)
        view.txt_3:setString(starNum..GameConfig.getLanguage("#tid_partner_ui_014"))
        -- view.panel_suo:visible(true)
        FilterTools.setGrayFilter(view.mc_skill)
    end
    FuncCommUI.regesitShowSkillTipView(_iconSprite,{partnerId = self.id, id = skillId,level = skillLevel or 1,isUnlock = isUnlock,_index = index},false)
end

-- 初始主角技能
-- initCharSkill
function CrosspeakPartnerInfoView:initCharSkill(panel )
    local treasureId = TeamFormationModel:getOnTreasureId()
    local dataCfg = FuncTreasureNew.getTreasureDataById(treasureId)
    local quality = dataCfg.initQuality
    local star = dataCfg.initStar
    local data = TreasureNewModel:getTreasureData(treasureId)
    if TreasureNewModel:isHaveTreasure(treasureId) then
        quality = data.quality
        star = data.star
    end
    local level = UserModel:level() --math.floor((UserModel:level()-1)/3 + 1)

    if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL) then
        level = 1
    end
    local starSkillMap = FuncTreasureNew.getStarSkillMap(treasureId,UserModel:avatar())
    for i ,v in pairs(starSkillMap) do
        local skillData = FuncTreasureNew.getTreasureSkillDataDataById(v.skill)
        -- icon 
        local iconPath = FuncRes.iconSkill(skillData.icon)
        local skillIcon = display.newSprite(iconPath)
        local offsetIndex = 0
        if v.star == 1 then
            offsetIndex = 0
        else
            offsetIndex = v.star
        end
        local panel_index = panel["panel_"..(offsetIndex+2)] 
        panel_index.mc_skill:showFrame(1)
        if skillData.priority == 1 then
            panel_index.mc_skill:showFrame(2)
            -- skillIcon:setScale(0.75)
        end
        panel_index.mc_skill.currentView.ctn_1:removeAllChildren()
        panel_index.mc_skill.currentView.ctn_1:addChild(skillIcon)

        panel_index.panel_number:visible(false)
        --name
        panel_index.txt_1:setString(GameConfig.getLanguage(skillData.name))
        if star >= v.star then
            panel_index.txt_3:setString(GameConfig.getLanguage("#tid_partner_ui_006")..level)
            
        else
            panel_index.txt_3:setString(GameConfig.getLanguage("#tid_partner_ui_015")..v.star..GameConfig.getLanguage("#tid_partner_ui_014"))
            FilterTools.setGrayFilter(panel_index.mc_skill)
        end
        --不要锁
        panel_index.panel_suo:visible(false)
        FuncCommUI.regesitShowTreasureSkillTipView(skillIcon,
            {treasureId = treasureId,skillId = v.skill,index = v.star,data = data },playSound)
    end

    -- 主角小技能
    local partnerData = FuncPartner.getPartnerById(self.id);
    local skillId = partnerData.skill[1]
    local _skillInfo = FuncPartner.getSkillInfo(skillId)
    local _iconPath = FuncRes.iconSkill(_skillInfo.icon)
    local _iconSprite = cc.Sprite:create(_iconPath)
    local panel_index = panel["panel_"..(3)] 
    panel_index.mc_skill:showFrame(1)
    panel_index.mc_skill.currentView.ctn_1:removeAllChildren()
    panel_index.mc_skill.currentView.ctn_1:addChild(_iconSprite)
    panel_index.panel_suo:visible(false)
    panel_index.panel_number:visible(false)
    panel_index.txt_1:setString(GameConfig.getLanguage(_skillInfo.name))
    panel_index.txt_3:setString(GameConfig.getLanguage("#tid_partner_ui_006")..level)

    local params = {
        partnerId = partnerData.id,
        id = skillId,
        level = level,
        index = 1
    }
    FuncCommUI.regesitShowCharSkillTipView(panel_index,params,false)

    -- panel["panel_"..(8)]:visible(false)
    -- panel["panel_"..(9)]:visible(false)
end

function CrosspeakPartnerInfoView:initProperty(view)
    -- 属性vec

   -- local t1 = os.clock()

    local propertyVec1 = {};
    local propertyVec2 = {};

    local function initPropertyF(propertyData)
        for i,v in pairs(propertyData) do
            if self:isInitProperty(v.key) then
                table.insert(propertyVec1,v)
            else
                table.insert(propertyVec2,v)
            end
        end
    end;

    if not self.currentStage then
        self.currentStage = 1 -- 当前显示详情状态
    end
    local dataAttr = propertyVec1
    if self.currentStage == 2 then
        dataAttr = propertyVec2
    end
    local partnerData = nil
    --初始属性
    if FuncPartner.isChar(self.id) then
        partnerData = CharModel:getCharData()
        local charAttrData = CharModel:getCharAttr()
        charAttrData = FuncBattleBase.formatAttribute( charAttrData )
        initPropertyF(charAttrData)
        self:showProperty(view,self.currentStage,partnerData,dataAttr)
    else
        partnerData = PartnerModel:getPartnerDataById(tostring(self.id))
        if self.haved then
            local skins = PartnerSkinModel:getSkinsByPartnerId(partnerData.id)
            local data = PartnerModel:getPartnerAttr(tostring(self.id))
            data = FuncBattleBase.formatAttribute( data )
            initPropertyF(data)
            self:showProperty(view,self.currentStage,partnerData,dataAttr)
        else
            partnerData = FuncPartner.getPartnerById(self.id);
            local data1 = FuncBattleBase.countFinalAttr( partnerData.initAttr )
            data1 = FuncBattleBase.formatAttribute( data1 )
            initPropertyF(data1)
            self:showProperty(view,self.currentStage,partnerData,dataAttr)
        end
    end
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
function CrosspeakPartnerInfoView:showProperty(view,_type,partnerData,data)
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
        if self.haved or FuncPartner.isChar(self.id) then
            view.panel_2.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_006")..partnerData.level)
        else
            view.panel_2.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_006")..1)
        end
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
function CrosspeakPartnerInfoView:isInitProperty(_type) 
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


return CrosspeakPartnerInfoView
