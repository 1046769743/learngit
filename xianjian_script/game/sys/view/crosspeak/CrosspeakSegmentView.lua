local CrosspeakSegmentView = class("CrosspeakSegmentView", UIBase)

function CrosspeakSegmentView:ctor(winName)
	CrosspeakSegmentView.super.ctor(self, winName)
end
function CrosspeakSegmentView:setAlignment()
    --设置对齐方式
end

function CrosspeakSegmentView:registerEvent()
    
    CrosspeakSegmentView.super.registerEvent();
    self.panel_di.btn_1:setTap(c_func(self.onBtnBackTap,self))
    self:registClickClose("out")
    self.panel_grmmp:visible(false)

    -- 找策划要
    self.panel_di.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_011"))
end
--返回 
function CrosspeakSegmentView:onBtnBackTap()
    self:startHide()
end

function CrosspeakSegmentView:loadUIComplete()
    self:registerEvent()

    self:initUI()
end
function CrosspeakSegmentView:initUI( )
    local data = FuncCrosspeak.getCrossPeakSegmentData()
    local data1 = {}
    for i,v in pairs(data) do
        table.insert(data1,v)
    end
    local sortFunc = function ( a,b )
        if a.scoreMax > b.scoreMax then
            return true
        else
            return false
        end
    end
    table.sort(data1, sortFunc )

    local createItemFunc = function (itemData)
        local itemView = UIBaseDef:cloneOneView(self.panel_grmmp);
        self:updateItem(itemView, itemData)
        return itemView
    end

    local updateCellFunc = function (itemData,itemView)
        self:updateItem(itemView, itemData);
        return itemView
    end

    local _scrollParams = { 
        {
            data = data1,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -330, width = 626, height = 330},
        }
    };
    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()

    -- 根据当前的阶段跳转至对应的位置
    local currentSeg = CrossPeakModel:getCurrentSegment()
    local index = 1
    for i,v in pairs(data1) do
        if tostring(currentSeg) == tostring(v.id) then
            index = i
            break
        end
    end
    self.scroll_1:gotoTargetPos(index,1,1)
end

function CrosspeakSegmentView:updateItem(itemView, itemData)
    -- 图标
    local panel_hz = itemView.panel_hz
    local iconPath = FuncRes.crossSegmentIcon( itemData.segmentIcon )
    local icon = display.newSprite(iconPath)
    panel_hz.ctn_1:removeAllChildren()
    panel_hz.ctn_1:addChild(icon)

    local name = GameConfig.getLanguage(itemData.segmentName)
    panel_hz.txt_1:setString(GameConfig.getLanguage(itemData.levelName))
    panel_hz.txt_2:setString(name)

    panel_hz.txt_time1:visible(false)
    panel_hz.txt_time2:visible(false)

    panel_hz.btn_guize:visible(false)
    --name
    
    local panel_gnmd = itemView.panel_gnmd
    panel_gnmd.txt_1:setString(name)
    --积分
    local minScore = itemData.scoreMin 
    local maxScore = itemData.scoreMax 
    panel_gnmd.txt_2:setString(minScore.."+")

    local currentSeg = CrossPeakModel:getCurrentSegment()
    if tostring(currentSeg) == tostring(itemData.id) then
        panel_gnmd.panel_dq:visible(true)
    else
        panel_gnmd.panel_dq:visible(false)
    end
    -- 仙气上限 godGass
    local sxStr = GameConfig.getLanguage("#tid_crosspeak_023")
    panel_gnmd.txt_3:setString(sxStr..itemData.godGass)


    if itemData.battleModel == 1 then
        -- 本周助战
        itemView.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_042"))
        itemView.btn_2:visible(false)
    elseif itemData.battleModel == 2 then
        if FuncCrosspeak.getBattleModel(itemData.id -1) == 1 then
            -- 可选奇侠
            itemView.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_043"))
        else
            -- 新增可选奇侠
            itemView.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_044"))
        end
        -- 按钮
        local batMName = FuncCrosspeak.getBattleModelName( itemData.id )
        itemView.btn_2:getUpPanel().txt_1:setString(batMName..">>")
        itemView.btn_2:visible(true)
        itemView.btn_2:setTap(c_func(self.onBtnTapInfo,self))
    end
    -- 助战奇侠
    self:initAddPartnerList(itemView,itemData.id)
    -- 宝箱奖励
    self:initRewardList(itemView,itemData.showReward )
end
-- 组选模式的tip
function CrosspeakSegmentView:onBtnTapInfo( ... )
    WindowControler:showWindow("CrosspeakPlayerTipsView",2)
end
function CrosspeakSegmentView:initRewardList(itemPanel,rewards )
    local _ui = itemPanel.UI_x1
    _ui:visible(false)
    local list = itemPanel.scroll_reward
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(_ui)
        self:updateRewardItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateRewardItem(view, itemData)
        return view;  
    end
    local _scrollParams = { 
        {
            data = rewards,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 5,
            offsetY = 10,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -70, width = 70, height = 70},
        },
    };
    list:styleFill(_scrollParams);
    list:hideDragBar()    
end
function CrosspeakSegmentView:updateRewardItem( view, itemData )
    local data = {}
    data.reward = itemData
    view:setRewardItemData(data)
    -- itemView:showResItemName(true)
    view:showResItemNum(false)
    -- 注册点击事件
    local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
    FuncCommUI.regesitShowResView(view, resType, needNum, resId,itemData,true,true)
end

function CrosspeakSegmentView:initAddPartnerList(itemPanel,segment)
    local T = CrossPeakModel:getNewAddPartnerByLevelId(segment)
    local list = itemPanel.panel_pt.scroll_1
    local panel = itemPanel.panel_pt.UI_1
    panel:visible(false)
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panel)
        self:updatePartnerItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updatePartnerItem(view, itemData)
        return view;  
    end
    local _scrollParams = { 
        {
            data = T,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -63, width = 66, height = 63},
        },
    };
    list:styleFill(_scrollParams);
    list:hideDragBar()
end
function CrosspeakSegmentView:updatePartnerItem( view, itemData )
    local panel = view
    panel:updataUI(itemData.id,"")
    local partnerData = FuncCrosspeak.getCrossPeakPartnerData(itemData.sid)
    panel:setStar( partnerData.star )
    panel:setQulity(partnerData.quality )
    panel:hideLevel(false)
    panel:setTouchedFunc(function ( ... )
        WindowControler:showWindow("PartnerCrosspeakInfoView", itemData.id,itemData.sid)
    end)
end

return CrosspeakSegmentView
