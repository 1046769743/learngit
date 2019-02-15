--[[
	Author: lxh
	Date:2018-05-02
	Description: 排行榜中法宝排行单一法宝详情查看界面
]]

local RankListTreasureDetailView = class("RankListTreasureDetailView", UIBase);

function RankListTreasureDetailView:ctor(winName, _itemData, _playerInfo)
    RankListTreasureDetailView.super.ctor(self, winName)
    self.treasureData = _itemData
    self.playerInfo = _playerInfo
end

function RankListTreasureDetailView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function RankListTreasureDetailView:registerEvent()
	RankListTreasureDetailView.super.registerEvent(self);

	self.panel_bg.btn_close:setTouchedFunc(c_func(self.startHide, self))
	self:registClickClose("out")
end

function RankListTreasureDetailView:initData()
	self.treasureId = self.treasureData.id
	self.treasureCfg = FuncTreasureNew.getTreasureDataById(self.treasureId)
end

function RankListTreasureDetailView:initView()
	for i = 1, 4 do
        self["panel_"..i]:visible(false)
    end
    local createFunc = function (itemData)
        local view = UIBaseDef:cloneOneView(self["panel_"..itemData])
        self:updateTreasInfoItem(view, itemData)
        return view
    end
    local updateFunc = function (_item, _view)
        self:updateTreasInfoItem(_view, _item)
    end

    local starAttrT = FuncTreasureNew.getStarAttrMap(self.treasureId)
    -- 计算永久激活高
    local gao = math.ceil(self.treasureData.star/2) < 4 and math.ceil(self.treasureData.star / 2) or 4
    local gao3 = 40 + 25 * gao 

    local _offSetX = -23
    local _scrollParams = {
            {
                data = {1},
                createFunc= createFunc,
                updateCellFunc = updateFunc,
                perFrame = 1,
                offsetX = _offSetX + 70,
                offsetY = 20,
                itemRect = {x = 0,y = -110,width = 330, height = 110},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            },
            {
                data = {2},
                createFunc= createFunc,
                updateCellFunc = updateFunc,
                perFrame = 1,
                offsetX = _offSetX + 70,
                offsetY = 0,
                itemRect = {x = 0, y = -130, width=330, height = 130},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            },
            {
                data = {3},
                createFunc= createFunc,
                updateCellFunc = updateFunc,
                perFrame = 1,
                offsetX = _offSetX + 90,
                offsetY = 10,
                itemRect = {x = 0,y= -gao3, width = 330, height = gao3},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            },
            {
                data = {4},
                createFunc= createFunc,
                updateCellFunc = updateFunc,
                perFrame = 1,
                offsetX = _offSetX + 85,
                offsetY = 36,
                itemRect = {x = 0,y = -420, width = 330,height = 420},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            }
        }
    self.scroll_1:styleFill(_scrollParams)
    self.scroll_1:hideDragBar()
end

function RankListTreasureDetailView:updateTreasInfoItem(_view, _itemData)
    if tonumber(_itemData) == 1 then
        self:treasName(_view)
    elseif tonumber(_itemData) == 2 then
        self:peidaiShuXing(_view)
    elseif tonumber(_itemData) == 3 then
        self:yongjiuShuXing(_view)
    elseif tonumber(_itemData) == 4 then
        self:skillShow(_view)
    end
end

function RankListTreasureDetailView:treasName(_view)
    local _name = GameConfig.getLanguage(self.treasureCfg.name)
    local _type = self.treasureCfg.type --定位 攻防辅
    local _aptitude = self.treasureCfg.aptitude -- 资质
    local panel = _view
    local iconPath = FuncRes.iconTreasureNew(self.treasureId)
    local treasureIcon = display.newSprite(iconPath)
    local nameFrame = FuncTreasureNew.getNameColorFrame(self.treasureId)
    local colorFrame = FuncTreasureNew.getKuangColorFrame(self.treasureId)
    panel.mc_1:showFrame(nameFrame)
    panel.mc_1.currentView.txt_1:setString(_name)
    panel.mc_dingwei:showFrame(_type)
    panel.mc_tu2:showFrame(self.treasureCfg.wuling)
    panel.panel_1.mc_2:showFrame(colorFrame)
    panel.panel_1.mc_1:showFrame(self.treasureData.star)
    panel.panel_1.mc_2.currentView.ctn_1:removeAllChildren()
    panel.panel_1.mc_2.currentView.ctn_1:addChild(treasureIcon)
    
end

function RankListTreasureDetailView:peidaiShuXing(_view)
	local panel = _view

    local key = "attribute"..self.treasureData.star   
    --显示基础属性
    local sxArra = FuncTreasureNew.getTreasureDataByKeyID(self.treasureId, key)
    -- dump(sxArra, "\nsxArra")
    for i,v in ipairs(sxArra) do
        if i <= 4 then
            local des = FuncTreasureNew.getAttrDesTable(v) 
            panel["panel_"..i].mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.key)])
            panel["panel_"..i].rich_1:setString(des)
        end
    end
end

function RankListTreasureDetailView:yongjiuShuXing(_view)
	local attrData = FuncChar.getAttributeData()
    local panel = _view
    panel.txt_biaoti3:setString(GameConfig.getLanguage("#tid_treature_ui_003")..GameConfig.getLanguage(self.treasureCfg.xianshiweizhi))
    -- for i = 1, 6 do
    --     panel["txt_"..i]:visible(false)
    -- end
    -- panel.rich_1:visible(false)
    -- panel.btn_eye:visible(false)

    local starAttrT = FuncTreasureNew.getStarAttrMap(self.treasureId)
    _view.panel_1:setVisible(false)
    for i= 1, self.treasureData.star do
        if i <= 6 then
            local panel_attr = UIBaseDef:cloneOneView(_view.panel_1)
            -- 获取星级属性加成
            local _starP = 6
            if i == self.treasureData.star then
                _starP = self.treasureData.starPoint
            end
            local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(self.treasureId, i)
            local attr = table.deepCopy(starData["addAttr"..7])
            for i=1, _starP do
                attr[1].value = attr[1].value + starData["addAttr"..i][1].value
            end
            local des = FuncTreasureNew.getAttrDesTable(attr[1])
            -- panel_attr["txt_"..i]:visible(true)
            local des_arr = string.split(des, "+")
            panel_attr.txt_1:setString(des_arr[1])
            panel_attr.txt_2:setString("+"..des_arr[2])
            panel_attr.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(attr[1].key)])
            local offsetX = math.floor((i - 1) % 2) * 200 - 15
            local offsetY = -math.floor((i - 1) / 2) * 40 - 45
            panel_attr:addto(_view)
            panel_attr:pos(offsetX, offsetY)
        end
    end

    -- local posY = -122
    -- if self.treasureData.star < 6 then
    --     local attrName = GameConfig.getLanguage(attrData[tostring(starAttrT[self.treasureData.star + 1].attr[1].key)].name)
        -- local _str1 = GameConfig.getLanguage("#tid_treature_ui_002")
        -- local _str2 = GameConfig.getLanguage("#tid_treature_ui_009")
        -- panel.rich_1:setString(attrName.._str1..(self.treasureData.star + 1).._str2)
        -- local gao = math.ceil(self.treasureData.star/2) < 4 and math.ceil(self.treasureData.star/2) or 4
        -- panel.rich_1:setPositionY(posY + 31*(4-gao))
        -- panel.btn_eye:setPositionY(posY + 28*(4-gao))

    --     panel.rich_1:visible(true)
    --     panel.btn_eye:visible(true)
    -- else
    --     panel.rich_1:visible(false)
    --     panel.btn_eye:visible(false)
    -- end
    -- if self.treasureData.star < 3 then
    --     panel.scale9_2:setScaleY(0.25)
    --     panel.panel_starxian2:visible(false)
    --     panel.panel_starxian3:visible(false)
    -- elseif self.treasureData.star < 5 then
    --     panel.scale9_2:setScaleY(0.5)
    --     panel.panel_starxian2:visible(true)
    --     panel.panel_starxian3:visible(false)
    -- else
    --     panel.scale9_2:setScaleY(0.8)
    --     panel.panel_starxian2:visible(true)
    --     panel.panel_starxian3:visible(true)
    -- end

    -- panel.btn_eye:scale(0.85)
    -- panel.btn_eye:setTap(function (  )
    --     WindowControler:showWindow("TreasureStarAttrView", self.treasureId)
    -- end)
end

function RankListTreasureDetailView:skillShow(_view)
    local avatar = self.playerInfo.avatar
    local dataCfg = FuncTreasureNew.getTreasureDataById(self.treasureId)
    local skills = FuncTreasureNew.getTeasureSkillsByIdAndAvatar(self.treasureId, avatar)
    local starSkillT = FuncTreasureNew.getStarSkillMap(self.treasureId, avatar)
    for i,v in pairs(starSkillT) do
        local skillPanel = _view["panel_"..v.star]
        local skillData = FuncTreasureNew.getTreasureSkillDataDataById(v.skill)
        local iconPath = FuncRes.iconSkill(skillData.icon)
        local skillIcon = display.newSprite(iconPath)
        if skillData.priority == 1 then
            skillIcon:setScale(0.8)
        else
            skillIcon:setScale(1.2)
        end
        skillPanel.ctn_1:removeAllChildren()
        skillPanel.ctn_1:addChild(skillIcon)
        skillPanel.panel_lv.txt_1:setString(self.playerInfo.level)
        skillPanel.txt_1:setString(GameConfig.getLanguage(skillData.name))
        if self.treasureData.star >= v.star then
            -- 技能解锁
            -- skillPanel.panel_suo:visible(false)
            FilterTools.clearFilter(skillIcon)
        else
            -- skillPanel.panel_suo:visible(false)
            FilterTools.setGrayFilter(skillIcon)
        end
        skillPanel.mc_nu1:showFrame(skillData.jiaobiao)

        FuncCommUI.regesitShowTreasureSkillTipView(skillIcon,
            {treasureId = self.treasureId, skillId = v.skill, index = i, data = self.treasureData, level = self.playerInfo.level})
    end
    
    --添加 全部装备觉醒+4星法宝的觉醒技能
    local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(self.playerInfo, self.treasureData.star, self.treasureId)
    local _skillPanel = _view["panel_7"]
    local _iconPath = FuncRes.iconSkill(awakeSkillData.icon)
    local skillIcon = display.newSprite(_iconPath)
    skillIcon:setScale(1.2)
    _skillPanel.ctn_1:removeAllChildren()
    _skillPanel.ctn_1:addChild(skillIcon)
    _skillPanel.panel_lv.txt_1:setString(self.playerInfo.level)
    _skillPanel.txt_1:setString(GameConfig.getLanguage(awakeSkillData.name))

    -- 判断是否解锁
    if equipAwake then
        FilterTools.clearFilter(skillIcon)
    else
        FilterTools.setGrayFilter(skillIcon)
    end
    _skillPanel.mc_nu1:showFrame(awakeSkillData.jiaobiao)

    FuncCommUI.regesitShowTreasureSkillTipView(skillIcon,
        {treasureId = self.treasureId, skillId = awakeSkillData.id, index = 7, data = self.treasureData, level = self.playerInfo.level})
end

function RankListTreasureDetailView:initViewAlign()
	-- TODO
end

function RankListTreasureDetailView:updateUI()
	-- TODO
end

function RankListTreasureDetailView:deleteMe()
	-- TODO

	RankListTreasureDetailView.super.deleteMe(self);
end

return RankListTreasureDetailView;
