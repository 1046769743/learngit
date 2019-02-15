local CrosspeakRankView = class("CrosspeakRankView", UIBase)

function CrosspeakRankView:ctor(winName)
	CrosspeakRankView.super.ctor(self, winName)
end
function CrosspeakRankView:setAlignment()
    --设置对齐方式
end

function CrosspeakRankView:registerEvent()
    CrosspeakRankView.super.registerEvent();
    self.btn_back:setTap(c_func(self.close,self))
    self:registClickClose("out")

    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_RANK_RANK_CHANGE_EVENT, self.rankDataCallBack, self)
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_RANK_RANK_CALLBACK_EVENT, self.resetQuestState, self)
    
end

function CrosspeakRankView:loadUIComplete()
    self:registerEvent()
    self:setAlignment()
    self.currentRankType = 1 -- 默认是 1个人  2 仙盟
    self:initBtns( )
end
--
function CrosspeakRankView:initBtns( )
    self.mc_2:showFrame(1)
    local btn1 = self.mc_2.currentView.btn_1
    self.mc_2.currentView.panel_hongdian:visible(false)
    self.mc_3:showFrame(1)
    local btn2 = self.mc_3.currentView.btn_1
    self.mc_3.currentView.panel_hongdian:visible(false)

    btn1:setTap(c_func(self.updatePlayerRank,self))
    btn2:setTap(c_func(self.updateGuildRank,self))

    self:updatePlayerRank()

end

-- 玩家排名
function CrosspeakRankView:updatePlayerRank(  )
    self.currentRankType = 1
    self.panel_2:visible(true)
    self.panel_3:visible(false)

    self.mc_2:showFrame(2)
    self.mc_3:showFrame(1)
    self.panel_2.mc_3:showFrame(1)
    self:initData( )
    self:initUI( )
end

function CrosspeakRankView:initData( )
    self.data = table.deepCopy(CrossPeakModel:getCrossPeakRankData( 1 ))
    self.dataLength = table.length(self.data)
    local num = 20
    if self.dataLength > 0 and math.fmod(self.dataLength,num) == 0 then
        local data = {}
        data.waitting = true
        table.insert(self.data, data)
    end
    self.selectIndex = 1

    self.myData = {}
    self.myData.rank = CrossPeakModel:getCurrentRank( )
    self.myData.name = UserModel:name()
    self.myData.currScore = CrossPeakModel:getCurrentScore()
    self.myData.head = UserModel:head()
    self.myData.frame = UserModel:frame()
    self.myData.avatar = UserModel:avatar()
    self.myData.rid = UserModel:rid()
    self.myData.sec = LoginControler:getServerId()
    self.myData.garment = UserExtModel:garmentId()

    if table.length(self.data ) > 0 then
        self.firstdata = self.data[1]
    end
    
end
function CrosspeakRankView:initUI( )
    local panel = self.panel_2.panel_2
    self:updateItem(panel, self.myData)
    self:initFirstPanel( )
    self:initList( )
end
function CrosspeakRankView:initFirstPanel( )
    if self.firstdata then
        self.mc_1:showFrame(3)
        local panel = self.mc_1.currentView.panel_1
        -- name 
        local name = self.firstdata.name
        local sec = self.firstdata.sec
        local secName = LoginControler:getServerNameById( sec )
        panel.txt_1:setString(name)
        panel.txt_2:visible(false)
        -- 
        local avatar = self.firstdata.avatar
        local garmentId = self.firstdata.garment
        local npc = FuncGarment.getSpineViewByAvatarAndGarmentId(avatar, garmentId,false,self.firstdata)
        npc:setScale(1.4)
        panel.ctn_1:removeAllChildren()
        panel.ctn_1:addChild(npc)
    else
        self.mc_1:showFrame(2)
    end
end
function CrosspeakRankView:initList( )
    local panel = self.panel_2.panel_2
    self.list = self.panel_2.scroll_1
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
            data = self.data,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            itemRect = {x=0,y= -60,width=623,height = 60},
            widthGap = 0,
            heightGap = 0,
 
        }
    }
    self.list:styleFill(_scrollParams);
    self.list:hideDragBar()
    self.list:onScroll(c_func(self.onMyListScroll, self))
    -- self.list:gotoTargetPos(self.selectIndex,1,0)
end
function CrosspeakRankView:onMyListScroll( event )
    local maxNum = 100
    local currentDatas = self.data
    local length = table.length(currentDatas)
    local num = 20
    if event.name == "scrollEnd" then
        if length < maxNum and math.fmod(length-1,num) == 0 then
            if not self.questing then
                echo("1111111111")
                self.questing = true
                local function call(  )
                    self.questing = false
                    self:rankDataCallBack(1)
                end
                CrossPeakModel:requestCrossPeakRank( 1,call )
            end
        end
    end
end
function CrosspeakRankView:resetQuestState()
    self.questing = false
end 
-- 请求排行榜数据
function CrosspeakRankView:rankDataCallBack(rankType)
    echo("rankType ======== ",rankType)
    if rankType == 1 then
        self.data = table.deepCopy(CrossPeakModel:getCrossPeakRankData( rankType ))
        local length = table.length(self.data)
        local num = 20
        if length < 100 and math.fmod(length,num) == 0 then
            local data = {}
            data.waitting = true
            table.insert(self.data, data)
        end
        self:initList()
    else
        self.gildData = table.deepCopy(CrossPeakModel:getCrossPeakRankData( rankType ))
        local length = table.length(self.gildData)
        local num = 20
        if length < 100 and math.fmod(length,num) == 0 then
            local data = {}
            data.waitting = true
            table.insert(self.gildData, data)
        end
        self:initGuildList()
    end
    
end

function CrosspeakRankView:updateItem( view, itemData )
    if itemData.waitting then
        view.mc_2:showFrame(1)
        local panel = view.mc_2.currentView
        panel.panel_ziji:visible(false)
        panel.mc_1:visible(false)
        panel.panel_kuang:visible(false)
        panel.txt_lv:visible(false)
        panel.txt_3:visible(false)
        panel.txt_name:setString(GameConfig.getLanguage("#tid_crosspeak_005"))
    else
        local rid = itemData.rid
        local userRid = UserModel:rid()
        local name = itemData.name
        local score = itemData.currScore
        local head = itemData.head 
        local frame = itemData.frame
        local sec = itemData.sec
        local rank = itemData.rank
        local avatar = itemData.avatar
        view.mc_2:showFrame(1)
        local panel = view.mc_2.currentView
        panel.panel_ziji:visible(true)
        panel.mc_1:visible(true)
        panel.panel_kuang:visible(true)
        panel.txt_lv:visible(true)
        panel.txt_3:visible(true)
        -- 排行
        if rank > 3 then
            panel.mc_1:showFrame(4)
            panel.mc_1.currentView.txt_1:setString(rank)
        elseif rank == 0 then
            panel.mc_1:showFrame(4)
            panel.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_006"))
        elseif rank <= 3 and rank > 0 then
            panel.mc_1:showFrame(rank)
        end
        
        -- name
        panel.panel_kuang.ctn_touxiang:removeAllChildren()
        panel.txt_name:setString(name)
        local headPath = FuncUserHead.getHeadIcon(head,avatar)
        headPath = FuncRes.iconHero( headPath )
        local iconSprite = display.newSprite(headPath)
        local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
        headMaskSprite:anchor(0.5,0.5)
        headMaskSprite:setPositionY(-1)
        headMaskSprite:setScale(1.02)
        local spritesico = FuncCommUI.getMaskCan(headMaskSprite,iconSprite)
        -- spritesico:setScale(0.8)
        panel.panel_kuang.ctn_touxiang:addChild(spritesico)
        local framePath = FuncUserHead.getHeadFramIcon(frame)
        framePath = FuncRes.iconHero( framePath )
        local frameSprite = display.newSprite(framePath)
        panel.panel_kuang.ctn_touxiang:addChild(frameSprite)
        --区服
        local secName = LoginControler:getServerNameById( sec )
        panel.txt_qu:setString(secName)

        -- 积分
        panel.txt_lv:setString(score)
        -- 段位
        local id = FuncCrosspeak.getCurrentSegment(tonumber(score))
        local segName = FuncCrosspeak.getSegmentRankName( id )
        panel.txt_3:setString(GameConfig.getLanguage(segName))

        if rid == userRid then
            panel.panel_ziji:visible(true)
        else
            panel.panel_ziji:visible(false)
        end
    end
end

-- 仙盟排名
function CrosspeakRankView:updateGuildRank(  )
    self.currentRankType = 2
    local function call(  )
        self.panel_2:visible(false)
        self.panel_3:visible(true)

        self.mc_2:showFrame(1)
        self.mc_3:showFrame(2)
        self.panel_3.mc_3:showFrame(2)
        self:initGuildData( )
        self:initGuildUI( )
    end
    if not self.gildData then
        CrossPeakModel:requestCrossPeakRank( self.currentRankType,call )
    else
        call()
    end
    
end
function CrosspeakRankView:initGuildData( )
    local pData = CrossPeakModel:getCrossPeakRankData( 2 )
    if not pData then
        return
    end
    self.gildData = table.deepCopy(pData)
    self.gildDataLength = table.length(self.gildData)
    local num = 20
    if self.gildDataLength > 0 and math.fmod(self.gildDataLength,num) == 0 then
        local data = {}
        data.waitting = true
        table.insert(self.gildData, data)
    end
    

    local _rank,_score = CrossPeakModel:currentGuildRankAndScore( )
    self.myGuildData = {}
    self.myGuildData.isMy = true
    if GuildModel:isInGuild() then
        self.myGuildData.rank = _rank or 0 
        self.myGuildData.currScore = _score
    else
        self.myGuildData.rank = -1 
        self.myGuildData.currScore = "暂无"
    end
    
    self.myGuildData.name = GuildModel:getGuildName().name
    self.myGuildData.afterName = GuildModel:getGuildName()._type
    local iconData = GuildModel:getIconData()
    self.myGuildData.logo = iconData.borderId 
    self.myGuildData.color = iconData.bgId 
    self.myGuildData.icon = iconData.iconId 
    self.myGuildData.rid = UserModel:rid()
    self.myGuildData.sec = LoginControler:getServerId()
    self.myGuildData.garment = UserExtModel:garmentId()

    if table.length(self.gildData ) > 0 then
        self.firstGuildData = self.gildData[1]
    end
    
end
function CrosspeakRankView:initGuildUI( )
    -- 自己仙盟的
    local panel = self.panel_3.panel_2
    if not self.myGuildData then
        panel:visible(false)
        return
    end
    self:updateGuildItem(panel, self.myGuildData)
    self:initFirstGuidPanel( )
    self:initGuildList( )
end
function CrosspeakRankView:initFirstGuidPanel( )
    -- 左侧仙盟最强仙盟信息
    if self.firstGuildData then
        self.mc_1:showFrame(1)
        local panel = self.mc_1.currentView.panel_1
        -- name 
        local name = self.firstGuildData.name
        local afterName = FuncGuild.guildNameType[self.firstGuildData.afterName]
        local sec = self.firstGuildData.sec
        local secName = LoginControler:getServerNameById( sec )
        panel.txt_1:setString(name..afterName)

        -- 
        local icon = WindowControler:createWindowNode("CompGuildIconCellView")
        icon:initData({borderId = 1,bgId = 1,iconId = 1})
        icon:setScale(1.2)
        panel.ctn_1:removeAllChildren()
        panel.ctn_1:addChild(icon)
        icon:pos(0,0)
    else
        self.mc_1:showFrame(2)
    end
end
function CrosspeakRankView:initGuildList( )
    local panel = self.panel_3.panel_2
    self.guildList = self.panel_3.scroll_1
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panel)
        self:updateGuildItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateGuildItem(view, itemData)
        return view;  
    end

    local _scrollParams = {
        {
            data = self.gildData,
            createFunc = createItemFunc,
            updateCellFunc = updateCellFunc,
            offsetX = 0,
            offsetY = 0,
            itemRect = {x=0,y= -60,width=623,height = 60},
            widthGap = 0,
            heightGap = 0,
 
        }
    }
    self.guildList:styleFill(_scrollParams);
    self.guildList:hideDragBar()
    self.guildList:onScroll(c_func(self.onMyGuildListScroll, self))
    -- self.guildList:gotoTargetPos(self.selectIndex,1,0)
end
function CrosspeakRankView:onMyGuildListScroll(event)
    local maxNum = 100
    local currentDatas = self.gildData
    local length = table.length(currentDatas)
    local num = 20
    if event.name == "scrollEnd" then
        if length < maxNum and math.fmod(length-1,num) == 0 then
            if not self.questing then
                echo("1111111111")
                self.questing = true
                local function call(  )
                    self.questing = false
                    self:rankDataCallBack(2)
                end
                CrossPeakModel:requestCrossPeakRank( 2,call )
            end
        end
    end
end

function CrosspeakRankView:updateGuildItem( view, itemData )
    view.mc_2:showFrame(3)
    local panel = view.mc_2.currentView

    panel.panel_ziji:visible(true)
    panel.mc_1:visible(true)
    panel.txt_lv:visible(true)
    panel.txt_qu:visible(true)
    panel.ctn_icon:visible(true)
    if itemData.waitting then
        panel.panel_ziji:visible(false)
        panel.mc_1:visible(false)
        panel.txt_lv:visible(false)
        panel.txt_qu:visible(false)
        panel.ctn_icon:visible(false)
        panel.txt_name:setString(GameConfig.getLanguage("#tid_crosspeak_005"))
    else
        -- 排行
        local rank = itemData.rank
        if rank > 3 then
            panel.mc_1:showFrame(4)
            panel.mc_1.currentView.txt_1:setString(rank)
        elseif rank == 0 then
            panel.mc_1:showFrame(4)
            panel.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_006"))
        elseif rank <= 3 and rank > 0 then
            panel.mc_1:showFrame(rank)
        elseif rank == -1 then
            panel.mc_1:showFrame(4)
            panel.mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_006"))
            
            local sec = itemData.sec
            local secName = LoginControler:getServerNameById( sec )
            panel.txt_name:setString("暂无仙盟")
            panel.txt_qu:setString(secName)
            panel.txt_lv:setString(itemData.currScore)
            panel.panel_ziji:visible(true)
            return
        end

        local iconCtn = panel.ctn_icon
        local icon = WindowControler:createWindowNode("CompGuildIconCellView")
        icon:initData({borderId = itemData.logo ,bgId = itemData.color,iconId = itemData.icon })
        icon:setScale(0.4)
        iconCtn:removeAllChildren()
        iconCtn:addChild(icon)
        icon:pos(0,0)

        local name = itemData.name
        local afterName = FuncGuild.guildNameType[itemData.afterName]
        local sec = itemData.sec
        local secName = LoginControler:getServerNameById( sec )
        panel.txt_name:setString(name..afterName)
        panel.txt_qu:setString(secName)

        panel.txt_lv:setString(itemData.currScore)

        if itemData.guildId == UserModel:guildId() then
            panel.panel_ziji:visible(true)
        else
            panel.panel_ziji:visible(false)
        end
    end
    
end
function CrosspeakRankView:close()
    self:startHide()
end

return CrosspeakRankView
