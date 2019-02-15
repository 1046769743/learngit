--[[
	Author: lxh
	Date:2018-01-18
	Description: TODO
]]

local WuXingTreasureInfoView = class("WuXingTreasureInfoView", UIBase);

function WuXingTreasureInfoView:ctor(winName, isMuilt, systemId, mainView, curFormationWave)
    WuXingTreasureInfoView.super.ctor(self, winName)
    self.pIdx = 1
    self.isMuilt = isMuilt
    self.systemId = systemId
    self.mainTeamView = mainView
    self.curFormationWave = curFormationWave
end

function WuXingTreasureInfoView:loadUIComplete()
    -- self.mc_yeqian1:getViewByFrame(1).btn_quanbu1:setTouchedFunc(c_func(self.switchShowType, self, FuncTeamFormation.showTreasure.treasure))
    -- self.mc_yeqian1:getViewByFrame(2).btn_quanbu2:setTouchedFunc(c_func(self.switchShowType, self, FuncTeamFormation.showTreasure.treasure))
    -- self.mc_yeqian2:getViewByFrame(1).btn_baoxiang1:setTouchedFunc(c_func(self.switchShowType, self, FuncTeamFormation.showTreasure.attr))
    -- self.mc_yeqian2:getViewByFrame(2).btn_baoxiang2:setTouchedFunc(c_func(self.switchShowType, self, FuncTeamFormation.showTreasure.attr))
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
end 

function WuXingTreasureInfoView:registerEvent()
	WuXingTreasureInfoView.super.registerEvent(self);
    self.panel_5.btn_1:setTouchedFunc(c_func(self.startHide, self))
    self.btn_1:setTouchedFunc(c_func(self.showTeamAttrView, self))
	self:registClickClose("out")
    EventControler:addEventListener(TeamFormationEvent.TEAMVIEW_HAS_CLOSED, self.startHide, self)
end

function WuXingTreasureInfoView:initData()
	self.selectedId = TeamFormationModel:getCurTreaByIdx(1)

    self.isSecondWave = false

    if self.curFormationWave and self.curFormationWave == FuncEndless.waveNum.SECOND then
        self.isSecondWave = true
    end
end

function WuXingTreasureInfoView:initView()
	self:updateUI()
end

-- function WuXingTreasureInfoView:switchShowType(_showType)
--     if self.showType == _showType then
--         return 
--     else
--         self.showType = _showType
--         self:updateUI()
--     end
-- end

function WuXingTreasureInfoView:initViewAlign()
	
end

function WuXingTreasureInfoView:updateUI()
	-- if self.showType == FuncTeamFormation.showTreasure.treasure then
        self.panel = self.mc_1.currentView
        -- self.mc_yeqian1:showFrame(2)
        -- self.mc_yeqian2:showFrame(1)
        -- self.panel.btn_zb:getUpPanel().txt_1:setString("佩  戴")
        if self.selectedId and self.selectedId == TeamFormationModel:getCurTreaByIdx(1) then
            self.mc_2:showFrame(2)
        else
            self.mc_2:showFrame(1)
            self.mc_2.currentView.btn_zb:setTouchedFunc(c_func(self.changeCurTreasure, self))
        end
        
        self:updateTreasureScrollList()
        self:updateMiddleSpineView()
        self:updateLeftScrollView()
        -- self:updateTreasuresView()
    -- elseif self.showType == FuncTeamFormation.showTreasure.attr then
    --     self.mc_1:showFrame(2)
    --     self.mc_yeqian1:showFrame(1)
    --     self.mc_yeqian2:showFrame(2)
    --     self.panel = self.mc_1.currentView  
    --     self:updateTreasureAttrView()
    -- end
end

function WuXingTreasureInfoView:updateTreasureScrollList()
    local treaData = nil
    if self.isMulti then
        treaData = TeamFormationMultiModel:getAllTreas()
    else    
	    treaData = TeamFormationModel:getAllTreas()
    end  
    self.treasuresData = {}
    for k,v in pairs(treaData) do
        if table.length(v) ~= 0 then
            table.insert(self.treasuresData, v)
        end
    end    
    if tonumber(self.systemId) == FuncTeamFormation.formation.pve_tower then
        local banTreasures = TowerMainModel:getBanTreasure()
        for k,v in pairs(banTreasures) do
            for i,vv in ipairs(self.treasuresData) do
                if tostring(k) == tostring(vv.id) then
                    self.treasuresData[i].isBan = 1
                end
            end
        end
    end

    self.panel_list.panel_1:visible(false)
    local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_list.panel_1);
        --初始化法宝
        self:updateTreaItem(view,itemData)

        --view:setTouchedFunc(c_func(self.doChooseTreas,self,view,itemData))
        return view        
    end

    local updateCellFunc = function ( data,view )
        self:updateTreaItem(view, data)
    end

    local params =  {
        {
            data = self.treasuresData,
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 6,
            offsetY = 10,
            widthGap = 0,
            heightGap = 10,
            itemRect = {x = 0, y = -110, width = 100, height =110},
            perFrame = 1,
        }
        
    }
    self.panel_list.scroll_1:styleFill(params)
    self.panel_list.scroll_1:hideDragBar()
end

function WuXingTreasureInfoView:updateTreaItem(view, itemData)
    if table.length(itemData) ~= 0 then
        --判断是否推荐
        local tuijian = false
        view.panel_tuijian:visible(tuijian)

        --级别
        view.txt_1:setString(itemData.level)

        --是否上阵
        local shangzhen = false
        if self.isMulti then
            shangzhen = TeamFormationMultiModel:chkTreaInFormation(itemData.id)
        else
            shangzhen = TeamFormationModel:chkTreaInFormation(itemData.id, self.isSecondWave)
         end   
        view.panel_duihao:visible(shangzhen)
        --仙界对决时需要显示段位对应的星级
        if tonumber(self.systemId) == tonumber(FuncTeamFormation.formation.crossPeak) then
            local currentSegment = CrossPeakModel:getCurrentSegment()
            local currentSegmentData = FuncCrosspeak.getSegmentDataById(currentSegment)
            view.mc_1:showFrame(currentSegmentData.starTreasure)
        else
            view.mc_1:showFrame(itemData.star)
        end
        
        view.ctn_goodsicon:removeAllChildren()
        view.ctn_goodsicon:addChild(display.newSprite(FuncRes.iconTreasureNew(itemData.id)):size(87,87))
        view.data = itemData
        local frame = FuncTreasureNew.getKuangColorFrame(itemData.id)
        view.mc_di:showFrame(frame)
        view.mc_kuang:showFrame(frame)

        if itemData.id == self.selectedId then
        	view.panel_xuan:setVisible(true)
        else
        	view.panel_xuan:setVisible(false)
        end
        view.ctn_goodsicon:setTouchedFunc(c_func(self.doTreaItemClick,self,view))
        if itemData.isBan then
            view.panel_no:setVisible(true)
        else
            view.panel_no:setVisible(false)
        end
    end 
end

function WuXingTreasureInfoView:doTreaItemClick(_view)
	local itemData = _view.data
	if itemData.id == self.selectedId then
		return
	else
		self.selectedId = itemData.id
		if self.selectedId == TeamFormationModel:getCurTreaByIdx(1) then
            self.mc_2:showFrame(2)
		else
            self.mc_2:showFrame(1)
			self.mc_2.currentView.btn_zb:setTouchedFunc(c_func(self.changeCurTreasure, self))
		end
		
		
		self:updateTreasureScrollList()		
        self:updateMiddleSpineView()
        self:updateLeftScrollView()
	end
end

function WuXingTreasureInfoView:updateMiddleSpineView()
    self.dataCfg = FuncTreasureNew.getTreasureDataById(self.selectedId)
    self.data = TreasureNewModel:getTreasureData(self.selectedId)
    -- dump(self.dataCfg, "\n\nself.dataCfg=====")
    local _name = GameConfig.getLanguage(self.dataCfg.name)
    local _type = self.dataCfg.type --定位 攻防辅
    self.mc_1:showFrame(FuncTreasureNew.getNameColorFrame(self.selectedId))
    self.mc_1.currentView.txt_1:setString(_name)
    self.mc_nima:showFrame(_type)
    self.mc_tu2:showFrame(self.dataCfg.wuling)
    local lihui = ViewSpine.new(self.dataCfg.image, {}, nil, self.dataCfg.image)
    lihui:playLabel("stand")
    self.ctn_2:removeAllChildren()
    self.ctn_2:addChild(lihui)
    lihui:setScale(0.8)
    lihui:pos(0, 90)  
end

function WuXingTreasureInfoView:showTeamAttrView()
    WindowControler:showWindow("WuXingTreasureAttrView")
end

function WuXingTreasureInfoView:updateLeftScrollView()
    self.starSkillT = FuncTreasureNew.getStarSkillMap(self.selectedId, UserModel:avatar())
    self.skill_table = {}
    for k,v in pairs(self.starSkillT) do
        self.skill_table[v.star] = v
    end

    local mainSkillData = FuncTreasureNew.getTreasureSkillDataDataById(self.skill_table[1].skill)
    local skillDes = GameConfig.getLanguage(mainSkillData.describe)
    _, self.heightOffset = self.panel_3.rich_3:setStringByAutoSize(skillDes, 0)

    self.panel_1:setVisible(false)
    self.panel_2:setVisible(false)
    self.panel_3:setVisible(false)
    local star = self.data.star
    if star > 6 then
        star = 6
    end
    local offsetY = math.floor((star - 1) / 2) * 30

    local createFunc1 = function (itemData)
        local view = UIBaseDef:cloneOneView(self.panel_1)
        self:updateAdornAttr(itemData, view)
        return view
    end

    local createFunc2 = function (itemData)
        local view = UIBaseDef:cloneOneView(self.panel_2)
        self:updateTeamAttr(itemData, view)
        return view
    end

    local createFunc3 = function (itemData)
        local view = UIBaseDef:cloneOneView(self.panel_3)
        self:updateTreasureSkills(itemData, view)
        return view
    end

    local params = {
        {
            data = {1},
            createFunc = createFunc1,
            perNums = 1,
            offsetX = 20,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -100, width = 310, height = 100},
            perFrame = 1,
            cellWithGroup = 1,
        },
        {
            data = {2},
            createFunc = createFunc2,
            perNums = 1,
            offsetX = 20,
            offsetY = 10,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -(110 + offsetY), width = 234, height = 110 + offsetY},
            perFrame = 1,
            cellWithGroup = 1,
        },
        
        
        {
            data = {3},
            createFunc = createFunc3,
            perNums = 1,
            offsetX = 10,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -(580 - 100 + self.heightOffset), width = 280, height = (580 - 100 + self.heightOffset)},
            perFrame = 1,
            cellWithGroup = 1,
        }
    }
    self.scroll_1:cancleCacheView();
    self.scroll_1:styleFill(params)
    self.scroll_1:hideDragBar()
end

function WuXingTreasureInfoView:updateAdornAttr(_itemData, _view)
    local key = "attribute"..self.data.star
    local energyCost = 0  
    --显示基础属性
    local sxArra = self.dataCfg[key]
    for i,v in ipairs(sxArra) do
        if i <= 4 then
            local des = FuncTreasureNew.getAttrDesTable(v)
            _view["txt_"..i]:setString(des)
        end
        -- if tostring(v.key) == "5" then
        --     energyCost = v.value - 6000
        -- end
    end
end

function WuXingTreasureInfoView:updateTeamAttr(_itemData, _view)
    _view.txt_1:setVisible(false)
    _view.txt_miaoshu:setString(GameConfig.getLanguage("#tid_treature_ui_003")..GameConfig.getLanguage(self.dataCfg.xianshiweizhi))
    local star = self.data.star
    for i = 1, star, 1 do
        if i <= 6 then
            local panel_txt = UIBaseDef:cloneOneView(_view.txt_1)
            -- 获取星级属性加成
            local _starP = 6
            if i == self.data.star then
                _starP = self.data.starPoint
            end
            local des = FuncTreasureNew.getTreaStarAttr(self.selectedId, i, _starP)
            panel_txt:setString(des)

            local offsetX = (i - 1) % 2 * 166
            local offsetY = -math.floor((i - 1) / 2) * 30 - 70
            panel_txt:addto(_view)
            panel_txt:pos(offsetX, offsetY)
        end   
    end
end

function WuXingTreasureInfoView:updateTreasureSkills(_itemData, _view)  
    local skills = FuncTreasureNew.getTeasureSkillsByIdAndAvatar(self.selectedId, UserModel:avatar())

    for i,v in ipairs(self.skill_table) do
        local skillPanel = _view["panel_skill"..i]
        local skillData = FuncTreasureNew.getTreasureSkillDataDataById(v.skill)
        local iconPath = FuncRes.iconSkill(skillData.icon)
        local skillIcon = display.newSprite(iconPath)
        if skillData.priority == 1 then
            skillIcon:setScale(0.75)
            local skillDes = GameConfig.getLanguage(skillData.describe)
            _view.txt_1:setString(GameConfig.getLanguage(skillData.name)) 
            _view.txt_2:setString(GameConfig.getLanguage("#tid_treature_ui_010")..GameConfig.getLanguage(skillData.dis))
            _view.rich_3:setString(skillDes, "0")
            skillPanel.txt_1:setString("")
        else
            skillPanel.txt_1:setString(GameConfig.getLanguage(skillData.name))
            local y = skillPanel:getPositionY()
            skillPanel:setPositionY(y + 100 - self.heightOffset)
        end
        skillPanel.mc_skill:showFrame(1)
        skillPanel.mc_skill.currentView.ctn_1:removeAllChildren()
        skillPanel.mc_skill.currentView.ctn_1:addChild(skillIcon)
        -- skillPanel.panel_number.txt_1:setString(UserModel:lskillDataevel())
        
        if self.data.star >= v.star then
            FilterTools.clearFilter(skillIcon)
        else
            FilterTools.setGrayFilter(skillIcon)
        end
        skillPanel.mc_skill2:showFrame(skillData.jiaobiao)

        FuncCommUI.regesitShowTreasureSkillTipView(skillIcon,
            {treasureId = self.selectedId, skillId = v.skill, index = i, data = self.data})
    end

    local charData = CharModel:getCharData()
    local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(charData, self.data.star, self.selectedId)
    local awakeSkillPanel = _view["panel_skill7"]
    local iconPath = FuncRes.iconSkill(awakeSkillData.icon)
    local skillIcon = display.newSprite(iconPath)
    awakeSkillPanel.mc_skill:showFrame(1)
    awakeSkillPanel.mc_skill.currentView.ctn_1:removeAllChildren()
    awakeSkillPanel.mc_skill.currentView.ctn_1:addChild(skillIcon)
    awakeSkillPanel.txt_1:setString(GameConfig.getLanguage(awakeSkillData.name))
    local y = awakeSkillPanel:getPositionY()
    awakeSkillPanel:setPositionY(y + 100 - self.heightOffset)
    if equipAwake then
        FilterTools.clearFilter(skillIcon)
    else
        FilterTools.setGrayFilter(skillIcon)
    end
    awakeSkillPanel.mc_skill2:showFrame(awakeSkillData.jiaobiao)
    FuncCommUI.regesitShowTreasureSkillTipView(skillIcon,
            {treasureId = self.selectedId, skillId = awakeSkillData.id, index = 7, data = self.data})
end

--点击切换法宝按钮
function WuXingTreasureInfoView:changeCurTreasure()
	if self.isMulti then
        local isHas = TeamFormationMultiModel:chkTreaInFormation(self.selectedId)
        if not isHas then
            local params = {}
            params.battleId = TeamFormationMultiModel:getRoomId()
            params.treasureId = self.selectedId
            TeamFormationServer:doOnTreasure(params,nil)
        end    
    else
    	local curTrasureData = {}
    	for k,v in pairs(self.treasuresData) do
    		if tostring(v.id) == tostring(self.selectedId) then
    			curTrasureData = v
    			break
    		end
    	end

        if curTrasureData.isBan then
            WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_029"))
            return
        end
    	local isHas = TeamFormationModel:chkTreaInFormation(self.selectedId, self.isSecondWave)
        if not isHas then
            TeamFormationModel:updateTrea(self.pIdx, self.selectedId, self.isSecondWave)
        else
            --法宝原来所在的位置
            local srcIdx = TeamFormationModel:getTreaPIdx(self.selectedId)
            if tostring(srcIdx) ~= tostring(self.pIdx) then
                local otherIdx = self.pIdx
                if otherIdx == 1 then otherIdx = 2 else otherIdx = 1 end 
                local srcTreaId = TeamFormationModel:getCurTreaByIdx(self.pIdx) 
                TeamFormationModel:updateTrea(self.pIdx, self.selectedId, self.isSecondWave)
                TeamFormationModel:updateTrea(otherIdx, srcTreaId, self.isSecondWave)
            end
        end
        if self.systemId == FuncTeamFormation.formation.guildBossGve then
            local multiTreaOwner = TeamFormationModel:getMultiTreasureOwnerAndId()
            if multiTreaOwner and multiTreaOwner == UserModel:rid() then
                local curTreaId = TeamFormationModel:getCurTreaByIdx(1)
                local treaInfo = {tid = curTreaId}
                TeamFormationServer:sendExchangeTreasure(treaInfo)
                self.mainTeamView:setLoadingStatus(true)
                self.mainTeamView:disabledUIClick()
                self.mainTeamView:createLoadingAnim()
            end
        end
        
        EventControler:dispatchEvent(TeamFormationEvent.UPDATA_TREA, {changeHeroType = true, isSecondWave = self.isSecondWave})
        -- EventControler:dispatchEvent(TeamFormationEvent.UPDATA_POSNUMTEXT)
    end
    WindowControler:showTips(GameConfig.getLanguage("#tid_wuxing_030"))
    -- self:startHide()
    self.mc_2:showFrame(2)
    self.panel_list.scroll_1:refreshCellView(1)
end

function WuXingTreasureInfoView:updateTreasuresView()
	self.data = TreasureNewModel:getTreasureData(self.selectedId)
    local key = "attribute"..data.star
    local energyCost = 0  
    --显示基础属性
    local sxArra = self.dataCfg[key]
    -- dump(sxArra, "\nsxArra")
    for i,v in ipairs(sxArra) do
        if i <= 4 then
            local des = FuncTreasureNew.getAttrDesTable(v)
            self.panel.panel_1["txt_"..i]:setString(des)
        end
        if tostring(v.key) == "5" then
        	energyCost = v.value - 6000
        end
    end

    local avatar = UserModel:avatar()
    local skills = FuncTreasureNew.getTeasureSkillsByIdAndAvatar(self.selectedId, avatar)
    self.showSkill = skills[1]
    local skillData = FuncTreasureNew.getTreasureSkillDataDataById(self.showSkill)
    local skillDes = GameConfig.getLanguage(skillData.describe)
    local iconPath = FuncRes.iconSkill(skillData.icon)
    local skillIcon = display.newSprite(iconPath)
    skillIcon:setScale(0.75)
    local skillPanel = self.panel.panel_2.mc_skill.currentView
    skillPanel.ctn_1:removeAllChildren()
    skillPanel.ctn_1:addChild(skillIcon)
    self.panel.panel_2.txt_1:setString(GameConfig.getLanguage(skillData.name))
    self.panel.panel_2.txt_2:setString(GameConfig.getLanguage("#tid_wuxing_031")..energyCost)   
    self.panel.panel_2.rich_3:setString(skillDes)
end

function WuXingTreasureInfoView:updateTreasureAttrView()
	self:updateTreasureName()
	local tempFrontRowData = TeamFormationModel:getFrontRowNature(1)
	local tempMiddleRowData = TeamFormationModel:getFrontRowNature(2)
	local tempBackRowData = TeamFormationModel:getFrontRowNature(3)
	self:updataAttrText(tempFrontRowData, self.panel.panel_q)
	self:updataAttrText(tempMiddleRowData, self.panel.panel_z)
	self:updataAttrText(tempBackRowData, self.panel.panel_h)
end

function WuXingTreasureInfoView:updataAttrText(data, view)
 --    for i = 1, 8, 1 do
 --        view["txt_"..i]:setString("")
 --    end

    -- for i,v in ipairs(data) do
    --  if v == 1 then
    --      view.txt_1:setString("无")
 --        else
 --            self:updataItemText(v, view["txt_"..i])
    --  end
    -- end
    view.txt_1:setVisible(false)

    local createCellFunc = function (_item)
        local _view = UIBaseDef:cloneOneView(view.txt_1)
        self:updataItemText(_item, _view)
        return _view
    end

    local updateCellFunc = function (_item, _view)
        self:updataItemText(_item, _view)
    end

    local params = {
        {
            data = data,
            createFunc = createCellFunc,
            perNums = 2,
            offsetX = 10,
            offsetY = -12,
            widthGap = 0,
            updateCellFunc = updateCellFunc,
            heightGap = -6,
            itemRect = {x = 0, y = -30, width = 166, height = 40},
            perFrame = 2,
        }
    }

    view.scroll_1:styleFill(params)
    view.scroll_1:hideDragBar()
end

function WuXingTreasureInfoView:updataItemText(data, view)
    if data == 1 then
        view:setString(GameConfig.getLanguage("#tid_team_des_004"))
    else
        local tempType = TeamFormationModel:isCanConVert(data.key)
        if data.mode == 3 and tempType then
            view:setString(data.name.."+"..data.value)
        else    
            local textValue = data.value/100
            textValue = string.format("%0.1f", textValue) 
            view:setString(data.name.."+"..textValue.."%")
        end 
    end
        
end

function WuXingTreasureInfoView:updateTreasureName()
	self.dataCfg = FuncTreasureNew.getTreasureDataById(self.selectedId)
    local _name = GameConfig.getLanguage(self.dataCfg.name)
    local _type = self.dataCfg.type --定位 攻防辅
    local _aptitude = self.dataCfg.aptitude -- 资质
    self.panel.mc_1:showFrame(FuncTreasureNew.getNameColorFrame(self.selectedId))
    self.panel.mc_1.currentView.txt_1:setString(_name)
    self.panel.mc_nima:showFrame(_type)
    self.panel.mc_tu2:showFrame(self.dataCfg.wuling)
end

function WuXingTreasureInfoView:deleteMe()
	-- TODO

	WuXingTreasureInfoView.super.deleteMe(self);
end

return WuXingTreasureInfoView;
