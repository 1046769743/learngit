local ArenaPlayerView = class("ArenaPlayerView", UIBase)

function ArenaPlayerView:ctor(winName)
	ArenaPlayerView.super.ctor(self, winName)
end

function ArenaPlayerView:loadUIComplete()
	self:registerEvent()
end

function ArenaPlayerView:registerEvent()
end

function ArenaPlayerView:setPlayerInfo(info)
	self.info = info
    local hid = self.info.avatar
    if info.type == FuncPvp.PLAYER_TYPE_ROBOT then
        local _robot_item = FuncPvp.getRobotById(info.rid)
        local _char_item = FuncChar.getHeroData(_robot_item.avatar)
        hid = _robot_item.avatar
        self.info.ability = _robot_item.ability
        self.info.level = _robot_item.lv
        self.info.avatar = _robot_item.avatar
        self.info.name = FuncAccountUtil.getRobotName(self.info.rid, self.info.rank)
        self.info.charPos = _robot_item.charPos
        self.info.garmentId = _robot_item.garmentId
    end

    EventControler:addEventListener(TeamFormationEvent.PVP_ATTACK_CHANGED, self.setAbility,self)
end
--只有角色本身才可以调用的函数

function ArenaPlayerView:setArenaMainView(mainView)
	self.arenaMainView = mainView
end

function ArenaPlayerView:isTopThree()
	local rank = self.info.rank or 20001
	return rank <= 3
end
--当调用这个函数的时候,一定是柱子上的Player View
function ArenaPlayerView:updateUI(showAnim)
	if not self.info then return end
    self.mc_info:showFrame(1)
    local _panel_item = self.mc_info.currentView.panel_1
    --判断是否为自己,以及是否为达到了前三名
    local _userId =UserModel:rid()
    --挑战5次功能需要满足这个条件限制
    local _user_level = UserModel:level()
    local _require_level = FuncDataSetting.getDataByConstantName("PvpFive")
    local _visibility = false

    --前三名
    if self.info.rid == _userId  then
        if self.info.rank < FuncPvp.SHOW_SELF_MIN_RANK then
            _panel_item.mc_g200:showFrame(3)
            _panel_item.mc_g200.currentView.btn_jian:setTap(c_func(self.clickButtonDefence,self))
            _panel_item.mc_g200:setVisible(true)
        else
          _panel_item.mc_g200:setVisible(false)
           _visibility = true
        end
        
    --排名在角色之后,且满足等级要求
    elseif self.info.rank > PVPModel:getUserRank() and _user_level >=_require_level then 
        _panel_item.mc_g200:showFrame(2)
        _panel_item.mc_g200.currentView.btn_jian:setTap(c_func(self.clickButtonChallenge5Times,self))
        local _buyTimes = CountModel:getPVPBuyChallengeCount()
        self._challengeCost = FuncPvp.getChallengeOneTimesCost(_buyTimes)
        -- _panel_item.mc_g200.currentView.panel_200.txt_1:setString(tostring(self._challengeCost)) --花费
        -- _panel_item.mc_g200.currentView.panel_200.txt_2:setString("挑战1次") --挑战5次改成挑战1次
        --玩家购买了挑战次数
        EventControler:addEventListener(PvpEvent.PVPEVENT_BUY_CHALLENGE_COUNT_OK,self.notifyChallengeTimes,self)
        --自己的已经经过的挑战次数发生了变化
        EventControler:addEventListener(FuncCount.COUNT_TYPE.COUNT_TYPE_PVPCHALLENGE,self.notifyChallengeTimes,self)
        --冷却时间发生了变化
        -- EventControler:addEventListener(PvpEvent.PVPEVENT_CLEAR_CHALLENGE_CD_OK,self.notifyChallengeTimes,self)
        -- EventControler:addEventListener("CD_ID_PVP_UP_LEVEL",self.notifyChallengeTimes,self)
        EventControler:addEventListener(PvpEvent.SCORE_REWARD_REFRESH_EVENT, self.notifyChallengeTimes, self)
    else
        --[[
        --如果自己小于前10名,则不可挑战前10名的
        if self.info.rank < 10 and PVPModel:getUserRank() >10 then
            _panel_item.mc_g200:setVisible(false)
        else
            _panel_item.mc_g200:showFrame(1)
            _panel_item.mc_g200.currentView.btn_jian:setTap(c_func(self.clickButtonChallenge,self))
        end
        ]]  
        _panel_item.mc_g200:showFrame(1)
        _panel_item.mc_g200.currentView.btn_jian:setTap(c_func(self.clickButtonChallenge,self))
    end
    -- _panel_item.btn_fs:visible(_visibility) --其他UI直接隐藏
    if  _visibility then
        -- _panel_item.btn_fs:setTap(c_func(self.clickButtonDefence,self))
    end
	self:setPlayerName(self.info.name)
	self:initAvatar(showAnim)
	--战力
	self:setAbility()
--	self:initTitle()
	self:setRank()
    if self.info.type == FuncPvp.PLAYER_TYPE_ROBOT then
        self:initRobotTeamFormation()
    end
    --设置按钮事件
    if self.info.rid == _userId then--如果是自己,点击弹出防御阵容
        _panel_item.btn_1:setTap(c_func(self.clickButtonViewSelf,self))
    else--否则弹出角色展示
        _panel_item.btn_1:setTap(c_func(self.clickButtonPlayerDetail,self))
    end
end

--竞技场挑战次数花费产生变化
function ArenaPlayerView:notifyChallengeTimes()
    --排名必须必玩家自己的低
    local _user_rank = PVPModel:getUserRank()
    local _user_level = UserModel:level()
    local _need_pvp_level = FuncDataSetting.getDataByConstantName("PvpFive")
    if self.info and self.info.rank > _user_rank and _user_level >= _need_pvp_level then
        local _panel_item = self.mc_info.currentView.panel_1
        local _buyTimes = CountModel:getPVPBuyChallengeCount()
        self._challengeCost = FuncPvp.getChallengeOneTimesCost(_buyTimes)
        -- _panel_item.mc_g200.currentView.panel_200.txt_1:setString(tostring(self._challengeCost)) --花费
    end
end

-- TreasureNewModel:getAllTreasure()" = {
-- -     1 = "304"
-- -     2 = "503"
-- -     3 = "603"
-- - }


--展示玩家自己的防御阵容
function ArenaPlayerView:clickButtonViewSelf()
        echo("-----------clickButtonViewSelf--------");

        local _treasure ={}
        -- local _treasures = TreasuresModel:getAllTreasure()

        local _treasures = TreasureNewModel:getAllTreasure()

        for _key,_value in pairs(_treasures) do
            -- _treasure[_key] = {
            --     id = _key,
            --     level = _value:level(),
            --     state = _value:state(),
            --     star = _value:star(),
            --     status = _value:status(),

            local treasureData = TreasureNewModel:getTreasureData(_value)
            if treasureData then
                _treasure[_value] = {
                    id = _value,
                    state = treasureData.state,   -- TODO 不知道是做什么，新版本是否需要？？？
                    star = treasureData.star,
                    status = treasureData.status, -- TODO 不知道是做什么，新版本是否需要？？？
                }
            end
            
        end
        local _playerInfo ={
            rid_back = self.info.rid,
            rid = self.info.rid,
            rank = self.info.rank,
            ability = self.info.ability,
            name = self.info.name ~= "" and  self.info.name or FuncCommon.getPlayerDefaultName(),
            level = UserModel:level(),
            avatar = self.info.avatar,
            vip = UserModel:vip(),
            guildName = "",
            quality = UserModel:quality(),
            star = UserModel:star(),--UserModel:star(), --现在因为主角没有星级,所以就暂时设置为1
            treasures = _treasure,
            partners = PartnerModel:getAllPartner(),
            formations = TeamFormationModel:getPVPDefenceFormation(),
        }

        if empty(_playerInfo.formations.partnerFormation) == true then 
            _playerInfo.formations.partnerFormation =  self:getDefaultPartnerFormation();
        end 

        if empty(_playerInfo.formations.treasureFormation) == true then
            _playerInfo.formations.treasureFormation = self:getDefaultTreasureFormation();
        end 

        WindowControler:showWindow("ArenaDetailView",_playerInfo,self.arenaMainView,self)
end

function ArenaPlayerView:getDefaultPartnerFormation()
    return {["p1"] = 1, ["p2"] = 0, ["p3"] = 0, ["p4"] = 0, ["p5"] = 0, ["p6"] = 0};
end
    
function ArenaPlayerView:getDefaultTreasureFormation()
    --todo 活动最猛的2个法宝
    local allTreasure = TreasureNewModel:getAllTreasure();
    local count = table.length(TreasureNewModel:getOwnTreasures())
    local f1 = "0";
    local f2 = "0";
    if count >=2 then 
        f1 = allTreasure[1]:getId();
        f2 = allTreasure[2]:getId();
    elseif count == 1 then 
        f1 = allTreasure[1].getId();    
    end 

    return {["p1"] = f1, ["p2"] = "0"};
end


--玩家详情展示
function ArenaPlayerView:clickButtonPlayerDetail()
    local _playerInfo = self.info
    if _playerInfo.types == FuncPvp.PLAYER_TYPE_ROBOT then--如果是机器人
        self:displayRobot()
        return
    end
    --发送协议,获取玩家的信息
    PVPServer:requestPlayerDetail(self.info.rid,c_func(self.onPlayerDetailEvent,self))
end

function ArenaPlayerView:onPlayerDetailEvent(_event)
    if _event.result ~= nil then
        local _playerInfo = _event.result.data
        _playerInfo.rank = self.info.rank --将排名数据增加进去,后面要用到
        _playerInfo.ability = self.info.ability
        _playerInfo.rid_back = self.info.rid
        _playerInfo.name = self.info.name~= "" and  self.info.name or FuncCommon.getPlayerDefaultName()
        _playerInfo.types  = self.info.type
        _playerInfo.star = self.info.star
        WindowControler:showWindow("ArenaDetailView",_playerInfo,self.arenaMainView,self)
    else
        echo("---------ArenaPlayerView:onPlayerDetailEvent------",_event.error.message)
    end
end
--如果是机器人,则构造信息并直接调用相关UI
function ArenaPlayerView:displayRobot()  
    WindowControler:showWindow("ArenaDetailView",self.info,self.arenaMainView,self)
end

function ArenaPlayerView:initRobotTeamFormation()
    --读取表格 config/robot/
    local _robot_item = FuncPvp.getRobotById(self.info.rid)
    --所携带的法宝,以及和法宝相关的槽位
    local _treasureInfos = {
    }
    local _treasureFormation = {}
    for _key,_value in pairs( _robot_item.treasures) do
        _treasureInfos[tostring(_value.id)] = _value
        if table.length(_treasureFormation) < 2 then
            _treasureFormation["p"..(table.length(_treasureFormation)+1)] = tostring(_value.id)
        end
    end
    --伙伴以及伙伴的阵型
    local _partners = {
    }
    local _partnerFormation={}
    for _index=1,6 do
        local _partnerInfo = _robot_item["showPart".._index]
        if _partnerInfo ~=nil then
            _partners[_partnerInfo[1] ] ={
                id = tonumber(_partnerInfo[1]),
                level = tonumber(_partnerInfo[2]),
                star = tonumber(_partnerInfo[3]),
                quality = tonumber(_partnerInfo[4]),
            }
            _partnerFormation["p".._index] = _partnerInfo[1]
        end
    end
    --有关伙伴,法宝的槽位
    local _formations ={
        partnerFormation = _partnerFormation,
        treasureFormation = _treasureFormation,
    }
    --数据的整合
    local _playerInfo = {
        rid_back =self.info.rid_back,
        rid = self.info.rid,
        name = self.info.name,
        rank = self.info.rank,
        level = _robot_item.lv,
        avatar = self.info.avatar,
        ability = self.info.ability,
        vip = 0,    --vip统一为0
        guildName = nil,--没有公会名字
        types = self.info.type,
        treasures = _treasureInfos,
        partners = _partners,
        formations = _formations,
        isRobot = true,
        charPos = self.info.charPos,
        garmentId = self.info.garmentId or "",
    }

    self.info = _playerInfo
end

--弹出防守阵容UI
function ArenaPlayerView:clickButtonDefence()
    --发送协议,获取玩家的信息
 --   PVPServer:requestPlayerDetail(self.info.rid,c_func(self.displayPlayerEvent,self))
--    self:displayPlayerEvent()
    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pvp_defend)
end
--展示玩家自己的防御阵容
function ArenaPlayerView:displayPlayerEvent(_event)
    if _event.result ~= nil then 
        local _playerInfo = _event.result.data
        _playerInfo.rid_back =self.info.rid_back
        _playerInfo.rank = self.info.rank
        _playerInfo.ability = self.info.ability
        _playerInfo.name = self.info.name ~= "" and  self.info.name or FuncCommon.getPlayerDefaultName()
        WindowControler:showWindow("ArenaDetailView",_playerInfo)
    else
        echo("-----error in ArenaPlayerView:displayPlayerEvent-------",_event.error.message);
    end
--        local _treasure ={}
--        local _treasures = TreasuresModel:getAllTreasure()
--        for _key,_value in pairs(_treasures) do
--            _treasure[_key] = {
--                id = _key,
--                level = _value:level(),
--                state = _value:state(),
--                star = _value:star(),
--                status = _value:status(),
--            }
--        end
--        local _playerInfo ={
--            rid = self.info.rid,
--            rank = self.info.rank,
--            ability = self.info.ability,
--            name = self.info.name ~= "" and  self.info.name or FuncCommon.getPlayerDefaultName(),
--            level = UserModel:level(),
--            avatar = self.info.avatar,
--            vip = UserModel:vip(),
--            guildName = "",
--            treasures = _treasure,
--            partners = PartnerModel:getAllPartner(),
--            formations = TeamFormationModel:getFormation(GameVars.battleLabels.pvp) or {},
--        }
--        _playerInfo.formations.partnerFormation = _playerInfo.formations.partnerFormation or {}
--        _playerInfo.formations.treasureFormation = _playerInfo.formations.treasureFormation or {}
--        WindowControler:showWindow("ArenaDetailView",_playerInfo)
end
function ArenaPlayerView:clickButtonChallenge5Times()
    -- echo("-----------------playerView-------------")
    EventControler:addEventListener(PvpEvent.PVP_BUY_COUNT_VIEW_CLOSED, self.removeChallengeListener, self)
    EventControler:addEventListener(PvpEvent.PVP_CHALLENGE_5_TIMES_EVENT,self.notifyChallenge5TimesEvent,self)   
    if self._challengeCost > 0 then
        WindowControler:showWindow("ArenaBuyCountView",FuncPvp.UICountType.Challenge5Times,FuncPvp.getChallengeOneTimesCost(CountModel:getPVPBuyChallengeCount()))
        
    else
        self:notifyChallenge5TimesEvent()
    end 

end

function ArenaPlayerView:removeChallengeListener()
    --移除事件监听器
    EventControler:removeEventListener(PvpEvent.PVP_CHALLENGE_5_TIMES_EVENT, self.notifyChallenge5TimesEvent, self)
end

--挑战5次
function ArenaPlayerView:notifyChallenge5TimesEvent()
    --移除事件监听器
    EventControler:removeEventListener(PvpEvent.PVP_CHALLENGE_5_TIMES_EVENT, self.notifyChallenge5TimesEvent, self)
    --检测仙玉是否足够
    local _user_gold = UserModel:getGold()
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
        opponentRid = self.info.rid_back, --对手的rid
        userRank = PVPModel:getUserRank(),
        formation = _formation, --自己的布阵内容
        times = 1,
    }

    if self.info.rank > 3 then
        PVPModel:setRefreshType(true)
    else
        PVPModel:setRefreshType(false)
    end
    -- echo("\nopponentRid playerView", _param.opponentRid)
    PVPServer:requestChallenge5Times(_param,c_func(self.onChallenge5Event,self))
end
--挑战5次返回
function ArenaPlayerView:onChallenge5Event(_event)
    if _event.result ~= nil then
        local _playerInfo = _event.result.data
        local _userInfo = {
            avatar = UserModel:avatar(),
            level = UserModel:level(),
            vip = UserModel:vip(),
            quality = UserModel:quality(),
            star = UserModel:star(),
        }
        EventControler:dispatchEvent(PvpEvent.PVP_SWEEP_SUCCESS_EVENT)
        WindowControler:showWindow("ArenaChallenge5View",_userInfo,self.info,_event.result.data.results)
        --在下方同时刷新UI
        self:delayCall(c_func(self.refreshMainView,self,_event),0.001)
    elseif _event.error.message == "user_gold_not_enough" then
        WindowControler:showTips(GameConfig.getLanguage("tid_shop_1030")) --仙玉不足
    else
        echo("----ArenaPlayerView:onChallenge5Event------",_event.error.message)
    end
end
function ArenaPlayerView:refreshMainView(_event)
    self.arenaMainView:onCloudDisappear(_event)
 --   self:startHide()
end
--挑战
function ArenaPlayerView:clickButtonChallenge()
     --检测是否有挑战的资格
    local _user_rank = PVPModel:getUserRank()
    if _user_rank>10 and self.info.rank <FuncPvp.SHOW_SELF_MIN_RANK then --require top 10
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
        -- WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1042"))
        PVPModel:tryShowBuyPvpView()
        return
    end
    self.info.isPvpAttack = true
    WindowControler:showWindow(     
        "WuXingTeamEmbattleView",
        FuncTeamFormation.formation.pvp_attack,
        self.info
       )
end

function ArenaPlayerView:setAbility()
    local infoUI = self.mc_info.currentView.panel_1

    -- 如果为nil 表示存在未加载的空UI（左侧隐藏的UI） 将其跳过
    if infoUI == nil then
        return
    end
    local ability
    if PVPModel:getUserRank() == self.info.rank then
        ability = UserModel:getPvpAbility(FuncTeamFormation.formation.pvp_defend)
        infoUI.txt_power:setString(GameConfig.getLanguage("#tid_pvp_008")..tostring(ability))
    else
        ability = self.info.ability
        infoUI.txt_power:setString(GameConfig.getLanguage("#tid_pvp_008")..tostring(ability))
    end 
 
    
    -- local numArray = number.split(ability);
    -- local len = table.length(numArray);

    -- if len > 7 then 
    --     echoWarn("------error: setPower len > 7 !!!-----");
    -- end 
    -- if len > 0 then
    --     infoUI.mc_3:showFrame(len);
    --     for k, v in pairs(numArray) do
    --         local mcs = infoUI.mc_3:getCurFrameView();
    --         mcs["mc_zi" .. tostring(k)]:showFrame(v + 1);
    --     end
    -- else
    --     echo("self.info.rank = "..self.info.ability)
    --     echo("self.info.rankLen = "..len)
    --     echoWarn("------error: setPower len <= 0 !!!-----");
    -- end
end

function ArenaPlayerView:setRank()
	local rank = tonumber(self.info.rank)
	--排名
    local _user_rank = PVPModel:getUserRank()
--    local _userId = UserModel:rid()
    local _player_item = self.info
    local _panel_rank = self.mc_info.currentView.panel_1
    if _player_item.rank > 3 then --第3名以上,统一为程序字
        -- 龙头
        -- _panel_rank.mc_1:showFrame(1)
        _panel_rank.mc_2:showFrame(1);
        local rankPanel = _panel_rank.mc_2.currentView
        
        local numArray = number.split(_player_item.rank);
        local len = table.length(numArray);

        if len > 6 then 
            echoWarn("------error: setRank len > 6 !!!-----");
        end

        if len > 0 then
            rankPanel.mc_paiming:showFrame(len);
            for k, v in pairs(numArray) do
                local mcs = rankPanel.mc_paiming:getCurFrameView();
                mcs["mc_" .. tostring(k)]:showFrame(v + 1);
            end
        end
    else
        -- 龙头
        _panel_rank.mc_1:showFrame(_player_item.rank+ 1)
        -- 名次
        _panel_rank.mc_2:showFrame(_player_item.rank + 1)
    end

--//英雄的底部的底座显示
    local    _viewBottom=self.mc_info:getViewByFrame(1).panel_1.mc_bottom;
   -- _viewBottom:setVisible(self.info.rank~=1);--//第一名底座消失
--    if(self.info.rank<=10)then
--            _viewBottom:showFrame(1);
--    elseif(self.info.rank<=100)then
--            _viewBottom:showFrame(2);
--    else
--            _viewBottom:showFrame(3);
--    end
       local _frame = self.info.rank > 3 and 4 or self.info.rank
       _viewBottom:showFrame( 4 - _frame +1)
end

function ArenaPlayerView:getTalkCtn()
	return self.mc_info.currentView.panel_1.ctn_talk
end

function ArenaPlayerView:showRandomTalk()
	if not self.arenaMainView then
		return
	end
	local scalePos = cc.p(0,-40)
	local scaleTime = 0.2
	local talkContent = FuncPvp.getRandomTalk(self.info.rank)
	if self.talkView then
		self.talkView:visible(true)
	else
		local arenaMain = self.arenaMainView
		self.talkView = UIBaseDef:cloneOneView(arenaMain.UI_player_talk)
		local talkCtn = self:getTalkCtn()
		local newPos = talkCtn:convertLocalToNodeLocalPos(arenaMain, cc.p(0,0))
		self.talkView:addTo(arenaMain):pos(newPos)
	end
	self.talkView:setTalkContent(talkContent)
	self.talkView:runAction(self.talkView:getFromToScaleAction(scaleTime, 0.1, 0.1, 1, 1, true, scalePos))

	--TODO 播放动作崩溃
	-- self:playTalkAction()
	--
	self:delayCall(c_func(self.talkView.visible, self.talkView, false), 2)
	return self.talkView
end

--播放攻击、施法动作
function ArenaPlayerView:playTalkAction()
    --删掉其他动作
--	local keys = {"atkNear", "giveOutA"}
--	local index = RandomControl.getOneRandomInt(#keys+1, 1)
--	local actionKey = keys[index]
	--echo(index, 'ArenaPlayerView,index')
	-- local label = self.treasureSourceData[actionKey]
--	if label and self.viewSpine then
    if  self.viewSpine then
   --     self.viewSpine:playLabel(label, false)
		FuncChar.playNextAction(self.viewSpine); --     self.viewSpine:playLabel(label, false)
		local frame = self.viewSpine:getCurrentAnimTotalFrame()
		local onActionOver = function()
			self.viewSpine:playLabel("stand", true)
		end
		self.viewSpine:delayCall(onActionOver, 1.0/GameVars.GAMEFRAMERATE*frame)
	end
end


function ArenaPlayerView:adjustTalkViewPos(deltaY)
	local talkView = self.talkView
	if talkView then
		local x,y = talkView:getPosition()
		talkView:pos(cc.p(x, y + deltaY))
	end
end

function ArenaPlayerView:hideTalk()
	if self.talkView then
		self.talkView:visible(false)
	end
end

function ArenaPlayerView:showTopThreeMark()
	self.mc_info:showFrame(5 - tonumber(self.info.rank))
end

function ArenaPlayerView:initTitle()
--PVP 称号功能砍掉
    self.mc_info.currentView.panel_1.mc_title:visible(false)
end

function ArenaPlayerView:setPlayerName(name)
	name = name or ""
	if self.info.type ~= FuncPvp.PLAYER_TYPE_ROBOT then
		name = _yuan3(name == "", FuncCommon.getPlayerDefaultName(), name)
	end
	self.mc_info.currentView.panel_1.txt_playername:setString(name)
end

function ArenaPlayerView:setTapFunc(tapCFunc)
	self.mc_info.currentView.panel_1.btn_1:setTap(tapCFunc)
end

function ArenaPlayerView:initAvatar(showAnim)
    -- dump(self.info, "\n\nself.info==")
	local avatarId = self.info.avatar
	local ctn = self.mc_info.currentView.panel_1.btn_1:getUpPanel().ctn_1
	local showArtSpine = function()
        if self.viewSpine then
               FuncChar.deleteCharOnTreasure(self.viewSpine);
               self.viewSpine=nil;
        end
        self:updatePlayerAttachState(true);
    	ctn:removeAllChildren()
        local  sp;
        local  other_flag=nil
        local     _rid=UserModel:rid();
        local     other_flag=   _rid ~= self.info.rid

        --[[
        if(self.info.pvpTreasureNatal~=nil)then
            sp= FuncChar.getCharOnTreasure( tostring(avatarId), self.info.pvpTreasureNatal,   false ):addto(ctn)
        else
		   -- sp = FuncChar.getSpineAni(avatarId..'', self.info.level or 1):addto(ctn)
            sp= FuncChar.getCharOnTreasure( tostring(avatarId), tostring(tonumber(avatarId)-100),   false ):addto(ctn)
        end
        ]]

        local garmentId = nil
        if self.info.garmentId and self.info.garmentId ~= "" then
            garmentId = self.info.garmentId
        end

        sp = GarmentModel:getSpineViewByAvatarAndGarmentId(tostring(avatarId), garmentId)
        if other_flag then
            sp:setRotationSkewY(0)
        else
            if self.info.rank <= 3 then
                sp:setRotationSkewY(0)
            else
                sp:setRotationSkewY(180)
            end
        end
        sp:pos(0, 20)
        sp:setScale(1.1)

        sp:addto(ctn)

		self.viewSpine = sp
        --非主角,可以播放站立动作
       --  if(other_flag)then
	     	-- sp:playLabel("stand", true)
       --  end
		sp:setSkin("zi_se")
		-- sp:setScale(1.2)
		if self.playerBgAnim == nil then
			local ctn_bottom =  self.mc_info.currentView.panel_1.ctn_bottom
            local      ani_name="UI_arena_lihuishenhou_lanse"
            if(self.info.rank<=10)then
                   ani_name="UI_arena_lihuishenhou_huangse"
            elseif(self.info.rank<=100)then
                   ani_name="UI_arena_lihuishenhou_zise"
            end
			self.playerBgAnim = self:createUIArmature("UI_arena",ani_name, ctn_bottom, true, GameVars.emptyFunc)
		end
	end
    local    function   _delayCallFunc()
        local ctn_texiao = self.mc_info.currentView.panel_1.ctn_chuxian_texiao
		if not self.chuxianAnim then
			local chuxianAnim = self:createUIArmature("UI_chuchangguang","UI_chuchangguang", ctn_texiao, false, GameVars.emptyFunc)
			self.chuxianAnim = chuxianAnim
		end

		self.chuxianAnim:registerFrameEventCallFunc(12, 1, c_func(showArtSpine))
		self.chuxianAnim:gotoAndPause(1)
		self.chuxianAnim:startPlay(false)
    end
	if showAnim then
        if self.viewSpine then
               FuncChar.deleteCharOnTreasure(self.viewSpine);
               self.viewSpine=nil;
        end
        ctn:removeAllChildren();
        self:delayCall(_delayCallFunc,0.3);
	else
		showArtSpine()
	end
end
--//清除角色
function    ArenaPlayerView:removeOriginPlayer()
    local   _panel=self.mc_info.currentView.panel_1.btn_1:getUpPanel();
    local ctn = _panel.ctn_1
     if self.viewSpine then
           FuncChar.deleteCharOnTreasure(self.viewSpine);
           self.viewSpine=nil;
    end
    self:updatePlayerAttachState(false);
    ctn:removeAllChildren()
end
function   ArenaPlayerView:updatePlayerAttachState( isShow)
    local   _panel=self.mc_info.currentView.panel_1;
    -- _panel.mc_1:setVisible(isShow);
    _panel.mc_2:setVisible(isShow);
    _panel.txt_playername:setVisible(isShow);
    -- _panel.mc_3:setVisible(isShow);
--    _panel.mc_bottom:setVisible(isShow)
    local _user_rid = UserModel:rid()
    local _user_rank = PVPModel:getUserRank()
    --可以操作挑战按钮的条件
    local _operate_condition =false
    if not self.info then
        _operate_condition = true
    elseif _user_rid ~= self.info.rid then
        if self.info.rank >= FuncPvp.SHOW_SELF_MIN_RANK then
            _operate_condition = true
        elseif _user_rank <= 10 then --挑战资格
            _operate_condition = true
        end
    end
    if _operate_condition then
        _panel.mc_g200:setVisible(isShow)
    end
    -- _panel.panel_zhandi:setVisible(isShow)
    if(not isShow and self.talkView )then
           self.talkView:setVisible(false);
    end
end

--构造pvp战斗需要的数据
function ArenaPlayerView:createBattleInfo(data)
	local enemyInfo = data.opponentBattleInfo
	local myInfo = data.userBattleInfo
	if myInfo.rank then
		PVPModel:setUserRank(tonumber(myInfo.rank))
	end

	enemyInfo.team = 2
	if enemyInfo.userBattleType == Fight.people_type_robot then
		local treasures =enemyInfo.treasures
		local t = {}
		for _, treasure in ipairs(treasures) do
			t[treasure.id] = treasure
		end
		enemyInfo.treasures = t
		enemyInfo.name = GameConfig.getLanguage(enemyInfo.name)
	end


	myInfo.team = 1
    enemyInfo.avatar = enemyInfo.avatar or GameVars.defaultAvatar

    enemyInfo.rank = enemyInfo.rank or  self.info.rank

    myInfo.avatar = myInfo.avatar or GameVars.defaultAvatar
	local battleInfo = {
		battleUsers = {
			myInfo,
			enemyInfo, 
		},
		randomSeed = data.randomSeed,
		battleId = data.battleId,
		battleLabel = GameVars.battleLabels.pvp,
	}
	return battleInfo
end


function ArenaPlayerView:testShowPvpBattle(battleInfo)
	PVPModel:testOnPvpChallengeBattleEnd(battleInfo)
end


return ArenaPlayerView

