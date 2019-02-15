--竞技场查看对手详情
--2017-1-11 15:57:33
--@Author:小花熊

local ArenaDetailView = class("ArenaDetailView",UIBase)

function ArenaDetailView:ctor(_window_name,_playerInfo,_pvp_class)
    ArenaDetailView.super.ctor(self,_window_name)
    self._playerInfo = _playerInfo
    self._pvpClass = _pvp_class
    self.sendaddFrined = false
end

function ArenaDetailView:loadUIComplete()
    self:freshFriendListUICommon()
    self:registerEvent()
    self:updatePlayerDetail()

end



function ArenaDetailView:registerEvent()
    ArenaDetailView.super.registerEvent(self)
    self:registClickClose("out")
    self.UI_di.btn_close:setTap(c_func(self.clickButtonClose,self))
    self.UI_di.mc_1:setVisible(false)
    self.UI_di.txt_1:setString(GameConfig.getLanguage("#tid_pvp_005")) 
    --按钮显示
    local _user_rid =UserModel:rid()
    if self._playerInfo.rid == _user_rid then
        self.mc_3:showFrame(2);
        self.mc_2:showFrame(2);
        self.mc_3.currentView.btn_1:setTap(c_func(self.clickButtonClose,self))
        self.mc_3.currentView.btn_2:setTap(c_func(self.clickButtonSetting,self))
        --对竞技场阵容变化通知监听
        EventControler:addEventListener(PvpEvent.PVP_FORMATION_CHANGED_EVENT,self.notifyPVPFormationChanged,self)
    else
        local _buyTimes = CountModel:getPVPBuyChallengeCount()
        self._challengeCost = FuncPvp.getChallengeOneTimesCost(_buyTimes)
        local _panel_btn
        if self._playerInfo.rank > PVPModel:getUserRank() then--需要挑战5次
            self.mc_3.currentView.mc_1:showFrame(2)
            local _pvp_need_level  = FuncDataSetting.getDataByConstantName("PvpFive")
            if UserModel:level() >= _pvp_need_level then --需要多少等级该功能开启
                self.mc_3.currentView.mc_1.currentView.btn_3:setTap(c_func(self.clickButtonChallenge5Times,self))
            else
                self.mc_3.currentView.mc_1.currentView.btn_3:setTap(c_func(self.clickButtonChallengeOpen,self))
            end
            _panel_btn = self.mc_3.currentView
            -- local _panel = self.mc_3.currentView.mc_1.currentView.btn_3:getUpPanel()
            -- _panel.txt_1:setString("挑战1次")
            -- _panel.txt_2:setString(tostring(self._challengeCost))
            --冷却时间
            -- EventControler:addEventListener("CD_ID_PVP_UP_LEVEL",self.notifyChallenge5Cost,self)
            -- EventControler:addEventListener(PvpEvent.SCORE_REWARD_REFRESH_EVENT, self.notifyChallenge5Cost, self)
        else--正常的挑战S
            --查看当前的挑战资格
            --购买的挑战次数
            local buyCount = CountModel:getPVPBuyChallengeCount()
            --已经挑战的次数
            local callengeCount = CountModel:getPVPChallengeCount()
            local firstTime = PVPModel:firstTime()
            local _challenge_count_left = FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime)
            local _user_rank = PVPModel:getUserRank()
            --第4名之后,或者自己进入了前10名
            if self._playerInfo.rank >=FuncPvp.SHOW_SELF_MIN_RANK or (self._playerInfo.rank <FuncPvp.SHOW_SELF_MIN_RANK and _user_rank<=10)then 
                self.mc_3:showFrame(1)
                _panel_btn = self.mc_3.currentView
                self.mc_3.currentView.mc_1:showFrame(1)
                self.mc_3.currentView.mc_1.currentView.btn_3:setTap(c_func(self.clickButtonChallenge,self))
            else
                self.mc_3:showFrame(3)
                _panel_btn = self.mc_3.currentView
                -- self.mc_3:getViewByFrame(3).btn_1:setPositionX(120)
            end
        end

        -- local frienddata =  FriendModel:getFriendList()
        -- if self._playerInfo.types ~= 2 then
        --     if #frienddata ~= 0 then 
        --         for i=1,#frienddata do
        --             if frienddata[i]._id == self._playerInfo.rid then
        --                 _panel_btn.btn_2:setVisible(false)
        --                 self.mc_3:getViewByFrame(3).btn_1:setPositionX(140)
        --             end
        --         end 
        --     end
        -- end

        _panel_btn.btn_1:setTap(c_func(self.clickButtonChat,self))
        _panel_btn.btn_2:setTap(c_func(self.clickButtonFriend,self))
    end
end
--竞技场阵容变化监听
function ArenaDetailView:notifyPVPFormationChanged(_param)
    local _playerInfo = self._playerInfo
    _playerInfo.formations = TeamFormationModel:getPVPFormation()
    self:updatePlayerDetail()
end
--查看阵容入口
function ArenaDetailView:checkLineUpInfo()
    -- 查看阵容入口
    local isOpen, lvl = LineUpModel:isLineUpOpen( self._playerInfo.level )

    if isOpen then
        if self._playerInfo.isRobot then
            LineUpViewControler:showMainWindow(self._playerInfo)
        else
            LineUpViewControler:showMainWindow({
                trid = self._playerInfo.rid,
                tsec = self._playerInfo.sec or LoginControler:getServerId(),
                formationId = FuncTeamFormation.formation.pvp_defend,
            })
        end
    else
        local xtname = GameConfig.getLanguage(FuncCommon.getSysOpenxtname(FuncCommon.SYSTEM_NAME.LINEUP))
        WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_teaminfo_1001", lvl, xtname))
    end
end

--update ui,真实玩家
function ArenaDetailView:updatePlayerDetail()
    local _playerInfo = self._playerInfo
    local _player_item = FuncChar.getHeroData(_playerInfo.avatar)
    local _iconPath = FuncRes.iconHead(_player_item.icon)

    local avatarId = _playerInfo.avatar..''

    local icon = FuncUserHead.getHeadIcon(_playerInfo.head, avatarId)
    if self._playerInfo.rid == UserModel:rid() then
        icon = FuncUserHead.getHeadIcon(UserModel:head(), avatarId)
    end

    icon = FuncRes.iconHero(icon)
    local iconSprite = display.newSprite(icon)
    local avatarCtn = self.ctn_tou
    local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", avatarCtn, false, GameVars.emptyFunc)
    iconAnim:setScale(1.1)
    FuncArmature.changeBoneDisplay(iconAnim, "node", iconSprite)

    if _playerInfo.isRobot == nil then
        avatarCtn:setTouchedFunc(c_func(self.checkLineUpInfo, self))
    end    
    -- self.panel_fbiconnew.mc_2:showFrame(_player_item.quality or 1)--资质
    -- self.panel_fbiconnew.mc_2.currentView.ctn_1:removeAllChildren()
    -- self.panel_fbiconnew.mc_2.currentView.ctn_1:addChild(cc.Sprite:create(_iconPath))--icon
    
    --level
    -- self.panel_fbiconnew.txt_3:setString(tostring(_playerInfo.level))
    --player name
    self.txt_name_1:setString(_playerInfo.name)
    -- 等级
    self.txt_lv2:setString(_playerInfo.level)
    --战力
    local ability = _playerInfo.ability
    if PVPModel:getUserRank() == _playerInfo.rank then
        ability = UserModel:getPvpAbility(FuncTeamFormation.formation.pvp_defend)
    end
    self.UI_comp_powerNum:setPower(ability)
    --排名
    self.txt_rank_2:setString(_playerInfo.rank)
    --星级
    -- self.panel_fbiconnew.mc_dou:showFrame(_playerInfo.star or 1)
    --仙盟
    self.txt_2:setString(_playerInfo.guildName ~= "" and _playerInfo.guildName or GameConfig.getLanguage("chat_own_no_league_1013"))
    self.txt_2:setVisible(false);

    -- 隐藏仙盟图标和名字
    self.panel_xm:setVisible(false)
    self.txt_2:setVisible(false)

    local charPos = _playerInfo.charPos
    --伙伴出战阵容
    for _index =1,6  do
        local _partnerId = nil
        if _playerInfo.isRobot == true then
            _partnerId = _playerInfo.formations.partnerFormation["p".._index] 
        else
            if table.length(_playerInfo.formations.partnerFormation) == 1 then
                _partnerId = _playerInfo.formations.partnerFormation["p".._index]
            else
                _partnerId = _playerInfo.formations.partnerFormation["p".._index].partner.partnerId
            end
            
            if _partnerId == "0" then
                _partnerId = nil
            else
                _partnerId = _partnerId
            end
        end
        
        if charPos and charPos == _index and _playerInfo.types == FuncPvp.PLAYER_TYPE_ROBOT then
            if not self._playerInfo.quality then
                self._playerInfo.quality = _playerInfo.partners[_partnerId].quality
                self._playerInfo.star = _playerInfo.partners[_partnerId].star
            end
            _partnerId = 1
        end
        local _panel = self.panel_1["panel_fbiconnew".._index] 
        _panel:setVisible(true)
        if _partnerId ~= nil then   --此处有伙伴
            _partnerId = tostring(_partnerId)
            if _partnerId ~= FuncPvp.ONESELE_VALUE and _partnerId ~= FuncPvp.INVALIDE_VALUE then
                local _partnerInfo = _playerInfo.partners[_partnerId]
                self:updateEveryPartnerView(_partnerInfo,_panel)
            elseif _partnerId == FuncPvp.ONESELE_VALUE then
                self:updateOneself(_panel)
            else
                _panel:setVisible(false)
            end
        else--否则隐藏槽位
            _panel:setVisible(false)
        end
    end

    -- 法宝修改为只有一个 by ZhangYanguang
    for _index=1,1 do
        local _treasureId = _playerInfo.formations.treasureFormation["p".._index]
        local _view = self.panel_1["panel_fbicon".._index]
        _view:setVisible(true)
        if _treasureId and _treasureId ~= FuncPvp.INVALIDE_VALUE then
            _treasureId = tostring(_treasureId)
            local _treasureInfo = _playerInfo.treasures[_treasureId]
            self:updateEveryTreasureView(_treasureInfo,_view)
        else
            _view:setVisible(false)
        end
    end
end
--更新挑战5次的花费
function ArenaDetailView:notifyChallenge5Cost()
    local _user_rank = PVPModel:getUserRank()
    if self._playerInfo.rank > _user_rank then
        self._challengeCost = FuncPvp.getChallenge5TimesCost()
         local _panel = self.mc_3.currentView.mc_1.currentView.btn_3:getUpPanel()
         _panel.txt_2:setString(tostring(self._challengeCost))
    end
end
--更新伙伴面板
function ArenaDetailView:updateEveryPartnerView(_partnerInfo,_view)
    -- dump(_partnerInfo, "\n\n_partnerInfo==")
    local _partner_item = FuncPartner.getPartnerById(_partnerInfo.id)
    local quality = _partnerInfo.quality

    -- 边框颜色
    local border = tonumber(FuncChar.getBorderFramByQuality(quality))
    --品质
    _view.mc_2:showFrame(border)
    --icon
    local _iconPath = FuncRes.iconHead(_partner_item.icon)
    _view.mc_2.currentView.ctn_1:removeAllChildren()
    local _iconSprite = cc.Sprite:create(_iconPath)
    if _partnerInfo.skin and _partnerInfo.skin ~= "" then
        _iconSprite = FuncPartnerSkin.getPartnerHeadIcon(_partnerInfo.id, _partnerInfo.skin)
    end
    _iconSprite:setScale(1.1)
    _view.mc_2.currentView.ctn_1:addChild(_iconSprite)
    --等级
    _view.txt_3:setString(tostring(_partnerInfo.level))
    --星级
    _view.mc_dou:showFrame(_partnerInfo.star)
end
--更新法宝
function ArenaDetailView:updateEveryTreasureView(_treasureInfo,_view)
    local _item_item = FuncTreasure.getTreasureById(_treasureInfo.id)
    --icon
    local _iconPath = FuncRes.iconTreasureNew(_treasureInfo.id)
    local _iconSprite = cc.Sprite:create(_iconPath)
    _iconSprite:setScale(0.6)
    _view.panel_1.ctn_1:removeAllChildren()
    _view.panel_1.ctn_1:addChild(_iconSprite)
    --等级 TODO  已没有等级的概念
    --_view.txt_3:setString(tonumber(_treasureInfo.level))
    _view.txt_3:setVisible(false)
    --星级
    _view.mc_dou:showFrame(_treasureInfo.star)
end

function ArenaDetailView:updateOneself(_view)
    -- local _char_item = FuncChar.getHeroData(self._playerInfo.avatar)
    local charIcon
    local garmentId = self._playerInfo.garmentId
    if self._playerInfo.rid ~= UserModel:rid() then
        if self._playerInfo.garments and table.length(self._playerInfo.garments) > 0 then
            if self._playerInfo.garments[garmentId] then
                if self._playerInfo.garments[garmentId].expireTime > 0 and self._playerInfo.garments[garmentId].expireTime < TimeControler:getServerTime() then
                    garmentId = ""
                end
            end           
        end
        charIcon = FuncGarment.getGarmentIcon(garmentId, self._playerInfo.avatar)
    else
        charIcon = FuncGarment.getGarmentIcon(GarmentModel:getOnGarmentId(), UserModel:avatar())
    end
     
    -- local _iconPath = FuncRes.iconHead(charIcon)
    -- local _iconSprite = cc.Sprite:create(_iconPath)
    -- 边框颜色
    local border = tonumber(FuncChar.getBorderFramByQuality(self._playerInfo.quality))

    _view.mc_2:showFrame(tonumber(border))
    --icon
    _view.mc_2.currentView.ctn_1:removeAllChildren()
    _view.mc_2.currentView.ctn_1:addChild(charIcon)
    charIcon:setScale(1.1)
    _view.mc_dou:showFrame(self._playerInfo.star or 1)
    --level
    _view.txt_3:setString(tostring(self._playerInfo.level))
end
function ArenaDetailView:clickButtonClose()
    self:startHide()
end
--私聊
function ArenaDetailView:clickButtonChat()
    -- dump(self._playerInfo,"111111111",8)
    -- WindowControler:showTips('努力研发中')


    local isopen = FuncCommon.isjumpToSystemView("chat")
    if not isopen then
        return 
    end

    local player = self._playerInfo
    if player.isRobot then
        player.rid = LoginControler:getServerId().."_"..player.rid
    end
    self:startHide();
    ChatModel:insertOnePrivateObject(player);
---_param如果是从聊天页面进入的
    local   _open,_level=FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHAT);
    local   _user_level=UserModel:level();
    if(_user_level<_level)then
             WindowControler:showTips(GameConfig.getLanguage("chat_common_level_not_reach_1014"):format(_level));
             return;
    end
--检测对方的等级
    if(player.level<_level)then--//对方未满足等级要求限制
            WindowControler:showTips(GameConfig.getLanguage("chat_extra_other_dont_reach_level_limit_1002"));
            return;
    end
    -- end
    WindowControler:showWindow("ChatMainView", 5);
end
--加为好友,或者删除好友
function ArenaDetailView:clickButtonFriend()
    -- local function _callback(_param)
    -- end
    -- dump(self._playerInfo,"22222222222222222")
    -- dump(ServiceData,"22222222222222222222")  
    local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.FRIEND)
    if not isopen then
        return 
    end    if self._playerInfo.isRobot then
        WindowControler:showTips('已发送好友申请')
        return
    end

    local frienddata =  FriendModel:getFriendList()
    if self._playerInfo.types ~= 2 then
        if #frienddata ~= 0 then 
            for i=1,#frienddata do
                if frienddata[i]._id == self._playerInfo.rid then
                    WindowControler:showTips('玩家已是你的好友')
                    return
                end
            end
        end
    end
    if self.sendaddFrined then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_1015"))
    else
        if self._playerInfo.types == 1 then
            -- local _param = { };
            -- _param.rids = { };
            -- _param.rids[1] = self._playerInfo.rid;
            -- FriendServer:applyFriend(_param, _callback);

            local _param = { };
            _param.ridInfos = {}
            local sce = LoginControler:getServerId()
            _param.ridInfos[1] = {[sce] = self._playerInfo.rid}
            FriendServer:applyFriend(_param, function () end);
            self.sendaddFrined = true
        end    
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_1015"))
    end
end

--重新设置布阵
function ArenaDetailView:clickButtonSetting()
    self:startHide()
    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pvp_defend)
end
--提示挑战5次需要等级
function ArenaDetailView:clickButtonChallengeOpen()
    local _pvp_need_level  = FuncDataSetting.getDataByConstantName("PvpFive")
    WindowControler:showTips(GameConfig.getLanguage("pvp_need_level_open_1006"):format(_pvp_need_level))
end
--挑战
function ArenaDetailView:clickButtonChallengeAfter()
    --检测是否还有挑战次数
    --购买的挑战次数
    local buyCount = CountModel:getPVPBuyChallengeCount()
    --已经挑战的次数
    local callengeCount = CountModel:getPVPChallengeCount()
    local firstTime = PVPModel:firstTime()
    local _times_left = FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime)
    if _times_left <= 0 then
        WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1042"))
        return
    end
    --构建数据结构
    local _user_formation = table.deepCopy(TeamFormationModel:getPVPFormation())
    local _formation = {
        treasureFormation = table.deepCopy(_user_formation.treasureFormation),
        partnerFormation = table.deepCopy(_user_formation.partnerFormation),
    }
    local _param = {
        opponentRid = self._playerInfo.rid_back, --对手的rid
        opponentRank = self._playerInfo.rank , --对手的排名
        userRank = PVPModel:getUserRank(), --玩家自己的排名
        formation = _formation, --玩家自己的PVP阵列
    }
--    dump(_param,"---_param----")
    PVPServer:requestChallenge(_param,c_func(self.onChallengeEvent,self))
end
--封装函数
function ArenaDetailView:clickButtonChallenge()
    --检测是否有挑战的资格
    local _user_rank = PVPModel:getUserRank()
    if _user_rank>10 and self._playerInfo.rank <FuncPvp.SHOW_SELF_MIN_RANK then --require top 10
        WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1043"));
        return
    end
    --检测是否有冷却行为
    -- local _time_left = FuncPvp.getPvpCdLeftTime()
    -- if _time_left > 0 then
    --     WindowControler:showWindow("ArenaClearChallengeCdPop")
    --     return 
    -- end
    --检测是否还有挑战次数
    --购买的挑战次数
    local buyCount = CountModel:getPVPBuyChallengeCount()
    --已经挑战的次数
    local callengeCount = CountModel:getPVPChallengeCount()
    local firstTime = PVPModel:firstTime()
    local _times_left = FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime)
    if _times_left <= 0 then
        PVPModel:tryShowBuyPvpView()
       -- WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1042"))
        return
    end
    self._playerInfo.isPvpAttack = true
    --此时关闭自身UI
    self:startHide()

    WindowControler:showWindow(     
        "WuXingTeamEmbattleView",
        FuncTeamFormation.formation.pvp_attack,
        self._playerInfo
       )
end
function ArenaDetailView:onChallengeEvent(_event)
    local _playerInfo = self._playerInfo
    if _event.result ~= nil then
        --存储战斗结果
        PVPModel:setLastFightResult(_event.result.data)
        local _treasure ={}
        local _treasures = TreasureNewModel:getAllTreasure()
        for _key,_value in pairs(_treasures) do
            _treasure[_value] = {
                id = _value,
                state = _value.state,
                star = _value.star,
                status = _value.status,
            }
        end
        local _CampSelf ={
            rid = UserModel:rid(),
       --     partners = PartnerModel:getAllPartner(),
       --     treasures = _treasure,
        --    formations = TeamFormationModel:getPVPFormation(), --玩家自己的PVP阵列
        }
        --敌方阵营
        local _CampEnemy = {
            rid = self._playerInfo.rid,
            treasures = self._playerInfo.treasures,
            formations = self._playerInfo.formation,
        }
        local _battleInfo = {
            battleLabel = GameVars.battleLabels.pvp,
            camp1 = _CampSelf, --表示己方
            camp2 = self._playerInfo,--,_CampEnemy,--表示敌方
            report = _event.result.data,
        }
        _battleInfo = _event.result.data
        _battleInfo.battleLabel = GameVars.battleLabels.pvp
        -- echo("pvp战斗的battleInifo---------------")
        -- dump(_battleInfo)
        -- echo("pvp战斗的battleInifo---------------")
        
        local backData = _event.result.data
        local info = {}
        info.battleLabel = backData.battleLabel
        info.battleUsers = backData.report.battleUsers
        info.randomSeed = backData.report.randomSeed
        info.battleId = backData.report.battleId
        local hisrank = PVPModel:getHistoryTopRank()
        if  backData.historyRank and backData.historyRank then
            hisrank = backData.historyRank
        end
        if backData.report.battleUsers[1].rid == _playerInfo.rid  then
            backData.report.battleUsers[1].rank = _playerInfo.rank
            backData.report.battleUsers[2].rank = hisrank
        else
            backData.report.battleUsers[1].rank = hisrank
            backData.report.battleUsers[2].rank = _playerInfo.rank 
        end
        
        info.historyRank = hisrank
        if  backData.historyRank and backData.userRank then
            info.userRank  = backData.userRank    
        end

--        self:startHide()
        WindowControler:showBattleWindow("ArenaBattleLoading", _playerInfo)
        --BattleControler:startBattleInfo(_event.result.data)
        BattleControler:startBattleInfo(info)
        --同时刷新主场景
        --self:delayCall(c_func(self.refreshMainViewClose,self,_event),0.001)
    else
        echo("-----ArenaDetailView:onChallengeEvent-----:",_event.error.message)
    end
    local errorData = _event.error
	if errorData then
		--战斗异常1.对手正在战斗 2. 对手排名变化 3 玩家排名变化
		local code = tonumber(errorData.code)
		local code_white_list = {110501, 110502, 110506}
        local   _refresh=false
        if(  _event.error.message=="user_pvprank_changed"  )then
            WindowControler:showTips(GameConfig.getLanguage("pvp_self_rank_changed_1001"));
            _refresh=true
        elseif(_event.error.message=="opponent_rank_have_changed")then
             WindowControler:showTip(GameConfig.getLanguage("pvp_enemy_rank_change_1002"));
              _refresh=true
        elseif(_event.error.message=="opponent_in_challenge")then
              WindowControler:showTips(GameConfig.getLanguage("pvp_enemy_fall_changing_1003"));
              _refresh=true
		end
	end
end
--发起事件监听
function ArenaDetailView:clickButtonChallenge5Times()
    EventControler:addEventListener(PvpEvent.PVP_CHALLENGE_5_TIMES_EVENT, self.notifyChallenge5Times, self)
    if self._challengeCost > 0 then
        WindowControler:showWindow("ArenaBuyCountView",FuncPvp.UICountType.Challenge5Times,FuncPvp.getChallengeOneTimesCost(CountModel:getPVPBuyChallengeCount()))
    else
        self:notifyChallenge5Times()
    end 
end

--挑战5次
function ArenaDetailView:notifyChallenge5Times()
    --删除事件监听器
    EventControler:removeEventListener(PvpEvent.PVP_CHALLENGE_5_TIMES_EVENT, self.notifyChallenge5Times, self)
    --检测仙玉是否足够
    local _user_gold = UserModel:getGold()
    echo("--------------需要花费:",self._challengeCost,"------现在拥有:,",_user_gold)
    if _user_gold < self._challengeCost then
        WindowControler:showTips(GameConfig.getLanguage("tid_shop_1030"))
        return
    end
    local _user_formation = table.deepCopy(TeamFormationModel:getPVPFormation())
    local _formation = {
        treasureFormation = table.deepCopy(_user_formation.treasureFormation),
        partnerFormation = table.deepCopy(_user_formation.partnerFormation),
    }
    local _param = {
        opponentRid = self._playerInfo.rid_back, --对手的rid
        formation = _formation, --自己的布阵内容
        userRank = PVPModel:getUserRank(),
    }
    PVPServer:requestChallenge5Times(_param,c_func(self.onChallenge5TimesEvent,self))
--    local _userInfo = {
--        avatar = UserModel:avatar(),
--        level = UserModel:level(),
--        vip = UserModel:vip(),
--        quality = UserModel:quality(),
--        star = 1,--UserModel:star(),
--    }
--    self:startHide()
--    WindowControler:showWindow("ArenaChallenge5View",_userInfo,self._playerInfo,{1,1,1,1,1})
end

function ArenaDetailView:onChallenge5TimesEvent(_event)
    if _event.result ~= nil then
        local _playerInfo = self._playerInfo
        local _userInfo = {
            avatar = UserModel:avatar(),
            level = UserModel:level(),
            vip = UserModel:vip(),
            quality = UserModel:quality(),
            star = UserModel:star(),
        }
        EventControler:dispatchEvent(PvpEvent.PVP_SWEEP_SUCCESS_EVENT)
        WindowControler:showWindow("ArenaChallenge5View",_userInfo,_playerInfo,_event.result.data.results)
        --在下方同时刷新UI
        self:delayCall(c_func(self.refreshMainView,self,_event),0.001)
    else
        echo("----ArenaPlayerView:onChallenge5Event------",_event.error.message)
    end
end
--刷新主场景
function ArenaDetailView:refreshMainView(_event)
--     self:startHide()
    self._pvpClass:onCloudDisappear(_event)
    self:startHide()
end
--刷新主场景,同时关闭UI
function ArenaDetailView:refreshMainViewClose(_event)
    
    self:startHide()
    self._pvpClass:onCloudDisappear(_event)
end
-- //重新获取好友列表页面
function ArenaDetailView:freshFriendListUICommon()
    local function _callback(_param)
        if (_param.result ~= nil) then
            -- dump(_param.result,"111111111111111")
            FriendModel:setFriendList(_param.result.data.friendList);
            FriendModel:setFriendCount(_param.result.data.count);
            FriendModel:updateFriendSendSp(_param.result.data);
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
        end
    end
    local param = { };
    param.page = 1
    FriendServer:getFriendListByPage(param, _callback);
end
return ArenaDetailView