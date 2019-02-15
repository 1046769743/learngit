local CompResItemView = class("CompResItemView", ItemBase);

function CompResItemView:ctor(winName)
    CompResItemView.super.ctor(self, winName);
    
    self:initData()
end

function CompResItemView:loadUIComplete()
    self:registerEvent();
end 


function CompResItemView:registerEvent()
    CompResItemView.super.registerEvent();
end

function CompResItemView:initData()
    self.itemSubTypes = ItemsModel.itemSubTypes

    self.isPieceItem = false
end

-- 更新itemUI
function CompResItemView:updateItemUI()
    if self.panelInfo.panel_skin then
        self.panelInfo.panel_skin:setVisible(false)
    end

    -- 初始化数据
    local itemId = self.itemId
    local itemNum = self.itemNum
    
    if itemId == false then
        itemId = nil
    end
    local star = 0
    -- echo("\n\nitemId===", itemId, "sourceType=", self.sourceType)
    local itemName = nil
    local itemIcon = nil

    local quality = nil
    local qualityMc = self.panelInfo.mc_kuang
    -- 道具类型资源
    if itemId ~= nil then
        if self.sourceType == FuncDataResource.RES_TYPE.ITEM then
            local itemType = self.itemType

            -- 如果是碎片
            if itemType ~= nil and tonumber(itemType) == ItemsModel.itemType.ITEM_TYPE_PIECE then
                self.isPieceItem = true

                -- 资质
                quality = FuncItem.getItemQuality(itemId)

                -- 如果是法宝碎片
                if self.itemSubType == self.itemSubTypes.ITEM_SUBTYPE_201 then
                    itemIcon = display.newSprite(FuncRes.iconTreasureNew(itemId)):anchor(0.5,0.5)

                    -- itemIcon = display.newSprite(FuncRes.iconTreasure(itemId)):anchor(0.5,0.5)
                    itemIcon:setScale(0.78)

                -- 如果是伙伴碎片
                elseif self.itemSubType == self.itemSubTypes.ITEM_SUBTYPE_202 then
                    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
                    headMaskSprite:anchor(0.5,0.5)
                    headMaskSprite:pos(-1,0)
                    headMaskSprite:setScale(0.99)

                    tempItemIcon = display.newSprite(FuncRes.iconHead(FuncItem.getItemData(itemId).icon)):anchor(0.5,0.5)
                    tempItemIcon:setScale(1.3)

                    -- 通过遮罩实现头像裁剪
                    itemIcon = FuncCommUI.getMaskCan(headMaskSprite,tempItemIcon)
                --  装备碎片
                elseif self.itemSubType == self.itemSubTypes.ITEM_SUBTYPE_205 then
                    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
                    headMaskSprite:anchor(0.5,0.5)   
                    headMaskSprite:pos(-1,0)
                    headMaskSprite:setScale(0.95)
                    local iconName = FuncItem.getIconPathById(itemId)
                    tempItemIcon = display.newSprite(FuncRes.iconPartnerEquipment(iconName)):anchor(0.5,0.5)
                    tempItemIcon:setScale(1.0)

                    -- 通过遮罩实现头像裁剪
                    itemIcon = FuncCommUI.getMaskCan(headMaskSprite,tempItemIcon)
                -- 其他类型碎片
                else
                    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
                    headMaskSprite:anchor(0.5,0.5)   
                    headMaskSprite:pos(-1,0)
                    headMaskSprite:setScale(0.95)
                    tempItemIcon = display.newSprite(FuncRes.iconItem(itemId)):anchor(0.5,0.5)
                    tempItemIcon:setScale(1.0)

                    -- 通过遮罩实现头像裁剪
                    itemIcon = FuncCommUI.getMaskCan(headMaskSprite,tempItemIcon)
                end
            -- elseif tonumber(itemType) == ItemsModel.itemType.ITEM_TYPE_ARTIFACT then
            --     itemIcon = display.newSprite(FuncRes.iconTalent(FuncItem.getItemData(itemId).icon)):anchor(0.5,0.5)
            --     itemIcon:setScale(0.44)
            --     quality = FuncItem.getItemQuality(itemId)
            elseif tonumber(itemType) == ItemsModel.itemType.ITEM_TYPE_MEMORY then
                local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
                headMaskSprite:anchor(0.5,0.5)   
                headMaskSprite:pos(-1,0)
                headMaskSprite:setScale(0.95)
                tempItemIcon = display.newSprite(FuncRes.iconItem(itemId)):anchor(0.5,0.5)
                tempItemIcon:setScale(1.0)

                -- 通过遮罩实现头像裁剪
                itemIcon = FuncCommUI.getMaskCan(headMaskSprite,tempItemIcon)
                quality = FuncItem.getItemQuality(itemId)
            else
                local itemData = FuncItem.getItemData(itemId)
                local  iconName = itemData.icon
                if itemData.subType == ItemsModel.itemSubTypes.ITEM_SUBTYPE_401 then
                    itemIcon = display.newSprite(FuncRes.iconCimelia(iconName)):anchor(0.5,0.5)
                    itemIcon:setScale(0.5)
                else
                    itemIcon = display.newSprite(FuncRes.iconItem(itemId)):anchor(0.5,0.5)
                    itemIcon:setScale(1.0)
                end 
                -- 道具边框颜色
                quality = FuncItem.getItemQuality(itemId)
            end

            itemName = FuncItem.getItemName(itemId)
        --
        elseif self.sourceType == FuncDataResource.RES_TYPE.USERHEADFRAME then
            local iconPath = FuncUserHead.getHeadFramIcon(itemId)
            itemIcon = display.newSprite(FuncRes.iconHero(iconPath)):anchor(0.5,0.5)
            itemIcon:pos(-3, 2)
            itemName = FuncUserHead.getHeadFrameName(itemId)
            quality = FuncDataResource.getQualityById(self.sourceType)
            qualityMc:setVisible(false)
        elseif self.sourceType == FuncTower.towerItemType then
            local nameStr = FuncTower.getGoodsValue(itemId, "name")
            local iconName = FuncTower.getGoodsValue(itemId, "iconImg")
            itemName = FuncTranslate._getLanguage(nameStr)
            itemIcon = display.newSprite(FuncRes.iconTowerEvent(iconName))
            quality = 2

        elseif  self.sourceType == FuncDataResource.RES_TYPE.PANRTNERSKIN  then
            local skin = self.rewardId
            local skindata = FuncPartnerSkin.getPartnerSkinById( self.rewardId)
            itemIcon = display.newSprite(FuncRes.iconHead(skindata.icon)):anchor(0.5,0.5)
            quality = FuncDataResource.getQualityById(self.sourceType)
        end

    -- 非道具类型资源
    else

        local rewardType = self.rewardType
        -- echo("\n\nrewardType==", rewardType)
        itemNum = self.rewardNum
    
        -- 完整法宝
        if tostring(rewardType) == FuncDataResource.RES_TYPE.TREASURE then
            local treasureId = self.rewardId
            itemIcon = display.newSprite(FuncRes.iconTreasure(treasureId))
            itemIcon:setScale(0.5)
            
            local treasureName = FuncTreasure.getValueByKeyTD(treasureId,"name")
            treasureName = GameConfig.getLanguage(treasureName)

            -- 法宝名字
            itemName = treasureName

            -- 法宝资质
            quality = FuncTreasure.getValueByKeyTD(treasureId,"initQuality")

        -- 完整伙伴
        elseif tostring(rewardType) == FuncDataResource.RES_TYPE.PARTNER then
            local partnerId = self.rewardId
            -- 伙伴资质
            local partnerInfo = FuncPartner.getPartnerById(partnerId)
            star = partnerInfo.initStar
            local tempItemIcon = display.newSprite(FuncRes.iconHero(partnerInfo.icon)):anchor(0.5,0.5)
            -- itemIcon:setScale(0.8)
            local headMaskSprite =  display.newSprite(FuncRes.iconOther("partner_tou"))
            -- local headMaskSprite = display.newSprite(FuncRes.iconHero("headKuang_101"))
            headMaskSprite:anchor(0.5,0.5)
            -- headMaskSprite:pos(-1,0)
            -- headMaskSprite:setScale(0.99)
                
            itemIcon = FuncCommUI.getMaskCan(headMaskSprite,tempItemIcon)

            -- itemIcon:setScale(1.1)
            quality = FuncDataResource.getQualityById(rewardType)

            -- local PartnerName = FuncTreasure.getValueByKeyTD(treasureId,"name")
            local PartnerName = GameConfig.getLanguage(partnerInfo.name)

            -- 法宝名字
            itemName = PartnerName
        -- 其他类资源
        elseif tostring(rewardType) == FuncDataResource.RES_TYPE.PANRTNERSKIN then
            self.panelInfo.panel_skin:setVisible(true)
            local skin = self.rewardId
            local skindata = FuncPartnerSkin.getPartnerSkinById(skin)
            itemName = GameConfig.getLanguage(skindata.name) 
            itemIcon = display.newSprite(FuncRes.iconHead(skindata.iconId)):anchor(0.5,0.5)--FuncPartner.getPartnerIconByIdAndSkin(_partnerId, skin)
            quality = FuncDataResource.getQualityById(rewardType)
        elseif tostring(rewardType) == FuncDataResource.RES_TYPE.USERHEADFRAME then
            itemName = FuncUserHead.getHeadFrameName(self.rewardId)
            itemIcon = display.newSprite(FuncRes.iconHead(FuncUserHead.getHeadFramIcon(self.rewardId))):anchor(0.5,0.5)
            quality = FuncDataResource.getQualityById(rewardType)
            qualityMc:setVisible(false)
            itemIcon:pos(-3, 2)
        elseif tostring(rewardType) == FuncDataResource.RES_TYPE.CLOTHES then
            self.panelInfo.panel_skin:setVisible(true)
            local garmentId = self.rewardId
            itemName = FuncDataResource.getResNameById(tonumber(rewardType),garmentId)
            local icon = FuncGarment.getValueByKey(garmentId, UserModel:avatar(), "iconId")
            itemIcon = display.newSprite(FuncRes.iconHead(icon)):anchor(0.5,0.5)
            quality = FuncDataResource.getQualityById(rewardType)
        elseif tostring(rewardType) == FuncDataResource.RES_TYPE.MONTH then
            itemIcon = display.newSprite(FuncRes.iconRes(rewardType)):anchor(0.5,0.5)
            itemName = FuncDataResource.getResNameById(tonumber(rewardType),self.rewardId)
            quality = FuncDataResource.getQualityById(rewardType)
        elseif tostring(rewardType) == FuncGuildExplore.guildExploreResType then
            local resData = FuncGuildExplore.getCfgDatas( "ExploreResource",self.rewardId )
            itemIcon = display.newSprite(FuncRes.getIconResByName(resData.icon)):anchor(0.5,0.5)
            quality = resData.quality
            itemName = GameConfig.getLanguage(resData.translateId)
        else
            itemIcon = display.newSprite(FuncRes.iconRes(rewardType)):anchor(0.5,0.5)
            itemName = FuncDataResource.getResNameById(tonumber(rewardType))

            quality = FuncDataResource.getQualityById(rewardType)
        end
    end 

    if not quality  then
        echoError("rewardType:",rewardType,"没有quality")
    else
        if qualityMc then
            qualityMc:showFrame(quality)
        end
    end
    if self.mc_1.currentFrame == 1 then
        self.panelInfo.mc_dou:showFrame(star + 1)
    end
    -- 存一下品质
    self.__quality = quality
    self.qualityMc = qualityMc
    -- 道具icon
    local iconCtn = self.panelInfo.ctn_1
    iconCtn:removeAllChildren()
    iconCtn:addChild(itemIcon)

    self:checkShowLingcai()
    -- 道具数量
    local txtNum = self.panelInfo.txt_goodsshuliang
    local newtxtNum = FuncCommUI.turnOneNumToStr(itemNum )

    -- if tonumber(newtxtNum) > 9999 then
    --     newtxtNum = 9999
    -- end
    
    if self.sourceType and self.sourceType == FuncDataResource.RES_TYPE.USERHEADFRAME then
        newtxtNum = ""
    end
    if self.rewardType and self.rewardType == FuncDataResource.RES_TYPE.USERHEADFRAME then
        newtxtNum = ""
    end
    txtNum:setString(newtxtNum)

    -- 道具小红点
    local redPanel = self.panelInfo.panel_red
    -- 默认不显示小红点
    if redPanel then
        redPanel:setVisible(false)
    end

    -- 道具名称
    --itemName = GameConfig.getLanguage(itemName)

    -- 不带数量的名称
    self.itemNameWithNotNum = itemName
    -- 带数量的名称
    self.itemNameWithNum = GameConfig.getLanguageWithSwap("tid_common_1018",itemName,FuncCommUI.turnOneNumToStr(itemNum ))

    -- 默认使用带数量的名称
    local nameTxt = self.panelInfo.mc_zi.currentView.txt_1
    nameTxt:setString(self.itemNameWithNum)
end
     
--设置道具数据
-- data 为用户已获取道具的动态数据
function CompResItemView:setItemData(data)
    CompResItemView.super.setItemData(self,data)

    -- dump(data, "\n\ndata====setItemData====")
    self.itemId = data.itemId
    self.itemNum = data.itemNum or 0

    if FuncItem.checkItemById(self.itemId) == true then
        local itemData = FuncItem.getItemData(self.itemId)
        self.itemType = itemData.type
        self.itemSubType = itemData.subType or 0
    else
        self.itemSubType =0
    end
    
    -- local itemData = FuncItem.getItemData(self.itemId)
    -- if itemData then
    --     self.itemType = itemData.type
    --     self.itemSubType = itemData.subType or 0
    -- end
    self.sourceType = data.itemType or FuncDataResource.RES_TYPE.ITEM
    
     -- 根据viewType初始化UI
    self:initUI()
    self:updateItemUI()
end

function CompResItemView:setClickBtnCallback(cfunc)
    self.mc_1.currentView.btn_1:setTap(cfunc)
end

-- 设置奖品数据
function CompResItemView:setRewardItemData(data)
    CompResItemView.super.setItemData(self,data)
    
    self.rewardStr = data.reward
    self.itemSubType = 0
    -- dump(self.rewardStr, "\n\nself.rewardStr===")
    local data
    if type(self.rewardStr) == "table" then
        data = self.rewardStr
    else
        data = string.split(self.rewardStr, ",")
    end
    local rewardType = data[1]

    local rewardId = nil
    local rewardNum = 0

    -- 如果奖品是道具
    if rewardType == UserModel.RES_TYPE.ITEM then
        rewardId = data[2]
        rewardNum = data[3]

       local data = {
            itemId = rewardId,
            itemNum = rewardNum,
       }
        self:setItemData(data)
        self.rewardNum = rewardNum
    -- 奖品为非道具资源
    elseif rewardType == FuncTower.towerItemType then
        rewardId = data[2]
        rewardNum = data[3]

       local data = {
            itemType = rewardType,
            itemId = rewardId,
            itemNum = rewardNum,
       }
        self:setItemData(data)
        self.rewardNum = rewardNum
    else
        self.itemType = nil
        -- 如果奖品是法宝
        if rewardType == FuncDataResource.RES_TYPE.TREASURE or rewardType == FuncDataResource.RES_TYPE.PARTNER then
            rewardId = data[2]
            rewardNum = 1

            self.rewardId = rewardId
        elseif rewardType == FuncDataResource.RES_TYPE.PANRTNERSKIN then
            rewardId = data[2]
            rewardNum = 1
            self.rewardId = rewardId
        elseif rewardType == FuncDataResource.RES_TYPE.USERHEADFRAME then
            rewardId = data[2]
            rewardNum = 1
            self.rewardId = rewardId
        elseif rewardType == FuncDataResource.RES_TYPE.CLOTHES then
            rewardId = data[2]
            rewardNum = 1
            self.rewardId = rewardId

        elseif rewardType == UserModel.RES_TYPE.MONTH then
            rewardId = data[2]
            rewardNum = 1
            self.rewardId = rewardId
        elseif tostring(rewardType) == FuncGuildExplore.guildExploreResType then --探索资源
            rewardId = data[2]
            rewardNum = data[3]
            self.rewardId = rewardId
        else
            rewardNum = data[2]
        end
        
        -- 非道具类型资源，将道具id设置为nil
        self.itemId = nil

        self.rewardType = rewardType
        self.rewardNum = rewardNum
        -- echo("\n\n___________here__________")
        -- echo("\n\nself.rewardType===", self.rewardType, "self.rewardNum===", self.rewardNum, "self.itemId==", self.itemId)
        -- 根据viewType初始化UI
        self:initUI()
        self:updateItemUI()
    end
end

function CompResItemView:initUI()
    -- 如果是碎片
    -- echo("===self.rewardType====self.itemType=====",self.rewardType,self.itemType)
    if self.itemType ~= nil and tonumber(self.itemType) == tonumber(ItemsModel.itemType.ITEM_TYPE_PIECE) then
        -- 法宝碎片
        if self.itemSubType == self.itemSubTypes.ITEM_SUBTYPE_201 then
            -- 法宝碎片
            self.mc_1:showFrame(3)
        -- 伙伴碎片
        elseif self.itemSubType == self.itemSubTypes.ITEM_SUBTYPE_202 then
            self.mc_1:showFrame(3)
        else
        -- 其他类型碎片
            self.mc_1:showFrame(3)
        end
    --情景卡碎片显示成碎片的样子
    elseif self.itemType ~= nil and tonumber(self.itemType) == tonumber(ItemsModel.itemType.ITEM_TYPE_MEMORY) then
        self.mc_1:showFrame(3)
    elseif self.rewardType ~= nil and tostring(self.rewardType) == FuncDataResource.RES_TYPE.TREASURE then
        self.mc_1:showFrame(2)
    -- elseif tonumber(self.itemType) == tonumber(ItemsModel.itemType.ITEM_TYPE_ARTIFACT) then --神器类型
    --     self.mc_1:showFrame(1)
    else
        self.mc_1:showFrame(1)
    end

    if self.sourceType and self.sourceType == FuncDataResource.RES_TYPE.USERHEADFRAME then
        self.mc_1:showFrame(1)
    end
    self.mc_1.currentView.btn_1:setTouchSwallowEnabled(true)

    -- 初始化panelInfo
    self.panelInfo = self.mc_1.currentView.btn_1:getUpPanel().panel_1
    -- 设置点击区域，解决透明区域过大，导致点击左边item，后边item响应的bug
    self.mc_1.currentView.btn_1:setRect(cc.rect(0,-90,90,90))

    -- 默认功能
    -- mc_zi深色版本字体 mc_ziqian浅色版字体
    -- 默认隐藏浅色版字体
    self.panelInfo.mc_ziqian:setVisible(false)

    -- 使用第二帧字体
    self.panelInfo.mc_zi:showFrame(2)
    
    -- 默认隐藏选中框
    self.panelSelectKuang = self.panelInfo.panel_xuanzhongkuang
    if self.panelSelectKuang then
        self.panelSelectKuang:setVisible(false)
    end

    -- 隐藏名字
    self:showResItemName(false)
    -- 显示数量
    self:showResItemNum(true)
    -- 不可以点击
    self:setResItemClickEnable(false)
end

-- 对外接口------------------------------------------------------------------------------------------------
--[[
    -- 道具数据格式
    data数据格式：{
        itemId="",          --道具ID
        itemNum="",         --道具数量
    }

    -- 奖品数据格式
    data数据格式：{
        reward="3,10",      --奖品是金币
    }
    或
    data数据格式：{
        reward="1,101,1",   --奖品是道具
    }
--]]
function CompResItemView:setResItemData(data)
    CompResItemView.super.setItemData(self,data)
    
    -- dump(data, "\n\ndata=====setResItemData===", 4)
    -- 如果是奖品
    if data.reward ~= nil then
        self:setRewardItemData(data)
    else
    -- 如果是道具
        self:setItemData(data)
    end
end

-- 设置itemView是否可以点击
function CompResItemView:setResItemClickEnable(visible)
    if visible then
        self.mc_1.currentView.btn_1:enabled(true)
    else
        self.mc_1.currentView.btn_1:disabled(true)
    end
end

-- 是否显示道具名称
-- whichFrame传1or2, 默认是2 第一帧黄色 第二帧褐色
-- isShallow:是否是浅色字体
function CompResItemView:showResItemName(visible, hideNum, whichFrame,isShallow)
    local mcZi = nil
    self.__isShallow = isShallow

    if isShallow then
        self.panelInfo.mc_zi:setVisible(false)
        mcZi = self.panelInfo.mc_ziqian
    else
        self.panelInfo.mc_ziqian:setVisible(false)
        mcZi = self.panelInfo.mc_zi
    end
    
    mcZi:setVisible(visible)

    if visible then
        if whichFrame == 1 then 
            self.panelInfo.mc_zi:showFrame(1);
        end 
        
        local nameTxt = mcZi.currentView.txt_1
        if hideNum then
            self.__hideNum = true
            nameTxt:setString(self.itemNameWithNotNum)
        else
            self.__hideNum = false
            nameTxt:setString(self.itemNameWithNum)
        end
    end
end

function CompResItemView:getItemInfo(  )
    return self.itemNameWithNotNum,self.__quality,self.rewardNum
end

--[[
    按照品质显示道具名称
    TODO by ZhangYanguang
    之前的设计，调用该接口前必须先调用showResItemName，暂时保持不作修改
]]
function CompResItemView:showResItemNameWithQuality()
    local mcZi = self.panelInfo.mc_zi
    if self.__isShallow then
        mcZi = self.panelInfo.mc_ziqian
    end

    -- 加2的原因是：mc中前两帧颜色是写死的颜色值与quality无关
    mcZi:showFrame(tonumber(self.__quality) + 2)

    local nameTxt = mcZi.currentView.txt_1
    if self.__hideNum then
        nameTxt:setString(self.itemNameWithNotNum)
    else
        nameTxt:setString(self.itemNameWithNum)
    end
end

-- 是否显示道具数量
function CompResItemView:showResItemNum(visible)
    self.panelInfo.txt_goodsshuliang:setVisible(visible)
end

-- 是否显示道具小红点
function CompResItemView:showResItemRedPoint(visible)
    local redPanel = self.panelInfo.panel_red

    -- 第二帧碎片没有小红点，所以需要判断是否为nil
    if redPanel then
        redPanel:setVisible(visible)
    end
end

-- 修改资源数量
function CompResItemView:setResItemNum(num)
    local txtNum = self.panelInfo.txt_goodsshuliang
    if num > 9999 then
        num = 9999
    end
    txtNum:setString(num)
end
-- 修改资源数量显示格式
function CompResItemView:setResItemNumType(str)
    local txtNum = self.panelInfo.txt_goodsshuliang
    txtNum:setString(str)
end

-- 修改资质比例
function CompResItemView:setQualityScale(scale)
    if self.qualityMc and scale then
        self.qualityMc:setScale(scale)
    end
end

-- 是否显示道具选中框
function CompResItemView:setResSelected(visible)
    if self.panelSelectKuang then
        self.panelSelectKuang:setVisible(visible)
    end
end

--隐藏背景框
function CompResItemView:hideBgCase(  )
    if self.panelInfo.mc_kuang then
        self.panelInfo.mc_kuang:visible(false)
    else
        if self.panelInfo.panel_bg   then
            self.panelInfo.panel_bg:visible(false)
        end
    end
end

-- 返回动画特效ctn
function CompResItemView:getAnimationCtn()
    return self.panelInfo.ctn_2
end

-- 获取资源icon的ctn
function CompResItemView:getResItemIconCtn()
    return self.panelInfo.ctn_1
end

function CompResItemView:setResItemIconScale(scale)
    self.panelInfo.ctn_1:setScale(scale)
end

--隐藏法宝碎片或法宝右上角的quality
function CompResItemView:hideTreasureOrPieceQuality(hide)
    local visible = _yuan3(hide, false, true)
    self.mc_1:getViewByFrame(2).btn_1:getUpPanel().panel_1.mc_2:visible(visible)
end
-- 获取格式化后的数量
-- 超过10000，以万为单位
function CompResItemView:getFormatItemNum(itemNum)
    -- echo("=========1111==============",itemNum)
    local limitNum = 10000
    itemNum = tonumber(itemNum)
    if itemNum <= limitNum then
        return itemNum
    else
        itemNum = math.floor(itemNum/10^3)
        --屏蔽1.0万的情况
        local yushu = itemNum % 10
        if yushu == 0 then
            newItemNum = string.format("%.0f", itemNum/10^1)
        else
            newItemNum = string.format("%.1f", itemNum/10^1)
        end
        
        newItemNum =  newItemNum .. "万"
        return newItemNum
    end
end

function CompResItemView:needHideGarmentLabel()
    if self.panelInfo.panel_skin then
        self.panelInfo.panel_skin:setVisible(false)
    end
end

--[[
    检查是否是碎片类型道具
]]
function CompResItemView:checkIsPiece()
    return self.isPieceItem 
end

--判断是否需要显示灵材
function CompResItemView:checkShowLingcai(  )
    --所有的灵材加一个icon
    if self.itemSubType ~= self.itemSubTypes.ITEM_SUBTYPE_299 and self.itemSubType ~= self.itemSubTypes.ITEM_SUBTYPE_310 then
        return
    end
    -- echo(self.itemSubType ,self.itemId ,"__aaaaa")
    local iconName = FuncRes.iconItemWithImage("item_img_lingcai")
    local icon = display.newSprite(iconName):addto(self.panelInfo.ctn_1)
    icon:pos(26,5)

end


return CompResItemView;
