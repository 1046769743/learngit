local CrosspeakHuiFangView = class("CrosspeakHuiFangView", UIBase)

function CrosspeakHuiFangView:ctor(winName,data)
	CrosspeakHuiFangView.super.ctor(self, winName)
    self.data = data
end
function CrosspeakHuiFangView:setAlignment()
    --设置对齐方式
end

function CrosspeakHuiFangView:registerEvent()
    CrosspeakHuiFangView.super.registerEvent();
    self.UI_1.btn_1:setTap(c_func(self.close,self))
    
    self:registClickClose("out")

end

function CrosspeakHuiFangView:loadUIComplete()
    self:registerEvent()
    self:initData( )
    self:initUI()
end

function CrosspeakHuiFangView:initData( )
    
    
end
function CrosspeakHuiFangView:initUI( )
    self:initTopPanel( )

    self:initData( )
    self:initList( )
end
function CrosspeakHuiFangView:initTopPanel( )
    -- title
    self.UI_1.txt_1:setString("战报")
    -- 当前积分
    local currentScore = CrossPeakModel:getCurrentScore()
    self.panel_alat.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_018")..currentScore) 
    -- 当前擂台等级
    local currentSegmentId = CrossPeakModel:getCurrentSegment()
    local levelName = FuncCrosspeak.getSegmentLevelName( currentSegmentId )
    levelName = GameConfig.getLanguage(levelName)
    self.panel_alat.txt_2:setString(GameConfig.getLanguage("#tid_crosspeak_019")..levelName) 
end
function CrosspeakHuiFangView:initData( )
    self.dataList = {}
    for i,v in pairs(self.data) do
        table.insert(self.dataList,v)
    end
    -- 根据时间排序
    table.sort(self.dataList,function( a,b )
        return a.time > b.time
    end)

    if table.length(self.dataList) > 0 then
        self.panel_alat.txt_notips:visible(false)
    else
        self.panel_alat.txt_notips:visible(true)
    end
end
function CrosspeakHuiFangView:initList( )
    local panel = self.panel_alat.panel_ge
    panel:visible(false)
    self.list = self.panel_alat.scroll_1
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panel)
        self:updateItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateItem(view, itemData)
        return view;  
    end

    local _scrollParams = {
        {
            data = self.dataList,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX =0,
            offsetY = 0,
            itemRect = {x=0,y= -132,width=932,height = 132},
            widthGap = 0,
            heightGap = 0,

        }
    }
    self.list:styleFill(_scrollParams);
    self.list:hideDragBar()
end


function CrosspeakHuiFangView:updateItem( view, itemData )
    -- 胜利or失败
    local result = itemData.result
    view.mc_sf:showFrame(result)
    -- 增加的积分
    local addScore = itemData.addScore
    if tonumber(addScore) >= 0 then
        view.mc_sf2:showFrame(1)
    else
        view.mc_sf2:showFrame(2)
    end
    view.mc_sf2.currentView.txt_1:setString(addScore)
    -- 敌方信息
    local userData = itemData.rivalInfo
    local userType = userData.userBattleType
    if tostring(userType) == "1" then
        -- 真实数据
        local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
        headMaskSprite:setScale(0.99)
        local iconSpr = FuncPartner.getPartnerIconByIdAndSkin(userData.avatar,"")
        local _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
        view.panel_tx.ctn_touxiang:removeAllChildren()
        view.panel_tx.ctn_touxiang:addChild(_spriteIcon)

        local neme = userData.name
        view.txt_1:setString(neme)

        -- 区服
        local secName = LoginControler:getServerNameById( userData.tsec )
        view.txt_2:setString(secName)


    elseif tostring(userType) == "2" then
        -- 机器人数据
        local rid = userData.rid
        local _data = FuncCrosspeak.getRobotData(tostring(rid))
        -- 头像
        local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
        headMaskSprite:setScale(0.99)
        local iconSpr = FuncPartner.getPartnerIconByIdAndSkin(_data.avatar,"")
        local _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
        view.panel_tx.ctn_touxiang:removeAllChildren()
        view.panel_tx.ctn_touxiang:addChild(_spriteIcon)
        -- 姓名
        local name = _data.robotName
        view.txt_1:setString(GameConfig.getLanguage(name))
        -- 区服
        local sec = LoginControler:getServerName()
        -- local secName = LoginControler:getServerNameById( sec )
        view.txt_2:setString(sec)
    end
    -- 结果类型
    local resultType = itemData.resultLabel
    view.mc_xx:showFrame(resultType)

    -- 回放按钮
    view.btn_1:setTouchedFunc(c_func(self.reportBattle,self,itemData))
    view.btn_1:getUpPanel().panel_hongdian:visible(false)
    
end
function CrosspeakHuiFangView:reportBattle( itemData)
     --这里做版本校验判断
    if BattleControler:checkBattleVersionIsOld( itemData ) then 
        return;
    end
    local isGlobal = 0
    if itemData.battleLabel == GameVars.battleLabels.crossPeakPvp2 then
        isGlobal = 1
    end
    local info = {reportId = itemData.reportId,isGlobal = isGlobal}
    CrossPeakServer:crossPeakRePlayReport(info,function(result )
        -- dump(result.result,"s====")
        if result.result then
            self:close()
            local battleInfo = BattleControler:turnServerDataToBattleInfo(result.result.data.battleInfo)
            battleInfo.replayGame = true
            BattleControler:startBattleInfo(battleInfo)
        end
    end)
end

function CrosspeakHuiFangView:close()
    self:startHide()
end

return CrosspeakHuiFangView
