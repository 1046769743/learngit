--guan
--todo WorldEvent.WORLDEVENT_TRAIL_RED_POINT_UPDATE 红点

local TrailModel = class("TrailModel");

TrailModel.TrailType = {
    ATTACK = 1,  --山神， --输出试炼   --- 攻击类、辅助  1 - 3
    DEFAND = 2,  --火神， --生存试炼   --- 防御，辅助    2 - 3 
    DODGE = 3,   --盗宝者 --主角试炼   --- 只上辅助类的  0 - 3 
};
TrailModel.MatchingType = {
    FREE = "1",  --空闲
    MATCHING = "2",  --匹配中
    BATTLE = "3",   --战斗中
    TEAM = "4",     --组队中
};
--1攻击,2辅助,3防御
TrailModel.partnerType = {
    attack = 1,
    auxiliary = 2,
    defense = 3,
}

--背景图
TrailModel.BgName = {
    [1] = "other_Trial_shanshenbj",
    [2] = "other_Trial_huoshenbi2",
    [3] = "other_Trial_houzibj",
}




function TrailModel:ctor()

end
--根据试炼类型获得需要的类型
function TrailModel:byTypegetPT( trialtype )
    local _type1 = nil
    if trialtype == TrailModel.TrailType.ATTACK then
        _type1 = TrailModel.partnerType.attack
    elseif trialtype == TrailModel.TrailType.DEFAND then
        _type1 = TrailModel.partnerType.auxiliary
    elseif trialtype == TrailModel.TrailType.DODGE then
        _type1 = TrailModel.partnerType.defense
    end
    return _type1
end

function TrailModel:settrialselectType(trialtype)
    self.trialselectType = trialtype
end
function TrailModel:init(starData)
    UserModel:cacheUserData();
    EventControler:dispatchEvent(WorldEvent.WORLDEVENT_TRAIL_RED_POINT_UPDATE, false);
    
    self:EventListener()

    -- dump(starData,"登陆试炼数据======")
    self.onTempShopOpentype = nil
    self.starData = starData
    self.TrailPlayData = nil
    self.Traildifftypeid = nil
    self.challengaddfrienddata = nil
    self.shopType = nil 
    -- self:bytimeGetCount()
    self.ispipeizhong = false
    self.viewName = nil
    self.pipeiDoTime = 0
    self.pipeiqiantime = 0





end
function TrailModel:EventListener()
    EventControler:addEventListener("notify_battle_player_level_5052", self.challengButton, self)
    EventControler:addEventListener("notify_battle_player_BuZhen_5060", self.playernotonline, self)

    EventControler:addEventListener("notify_trial_add_team_1814",
        self.notifyAddChallengView, self);
    EventControler:addEventListener("notify_trial_Doing_Array_5004",
        self.addchallengview, self);
    -- EventControler:addEventListener("推送匹配失败推送",
        --     self.UNpipeiWeiSuccess, self);
    EventControler:dispatchEvent("TIAOZHANHONGDIANSHUAXIN")   ---主城红点显示

    EventControler:addEventListener(BattleEvent.BATTLEEVENT_MULITI_START_BATTLE_AFTER5008,
        self.startPiPeiBattleCallback, self);  ---布阵战斗开始

    EventControler:addEventListener(TrialEvent.CLOSE_BLACK_EVENT,
        self.removeTeamView, self); 
        --临时商店功能更
    EventControler:addEventListener(ShopEvent.SHOPEVENT_TEMP_SHOP_OPEN, 
        self.onTempShopOpen, self);


    -- 没有网络回调
    EventControler:addEventListener(NetworkEvent.SERVER_ON_CLOSE,
        self.doCloseViewForServerClose,self)
    --- 后台时间
    EventControler:addEventListener(SystemEvent.SYSTEMEVENT_APP_ENTER_FOREGROUND,
        self.BoltReconneCtion, self)
    
        --开始战斗界面
    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.onTeamFormationComplete, self)


end
function TrailModel:playernotonline()
    echo("对方玩家已掉线")
end

function TrailModel:onTempShopOpen(event)
    local params = event.params
    local shopType = params.shopType
    if shopType then
        -- WindowControler:showWindow("ShopKaiqi", shopType)
        self.shopType = shopType
    end
end


---加入队伍中的数据
function TrailModel:addteamData(data)
   self.addteamDatas = data
end
function TrailModel:InPipeiViewGetdata(data)
    self.addteamDatas = data
end
function TrailModel:challengButton(event)

    -- local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    -- TrialServer:startBattle(c_func(self.newstartBattleCallback, self),id,2)
    -- WindowControler:showWindow("TrialNewFriendPiPeiView", self.SelectType);   ---跳到匹配界面
        -- CompNotifeAddFriendView
        -- WindowControler:showWindow("CompNotifeAddFriendView")
    dump(event.params,"对方匹配退出")
    
    local rid = event.params.params.data.rid 
    if rid == UserModel:rid() then
        return 
    end
    WindowControler:showTips(GameConfig.getLanguage("#tid_trail_001"))
    local function _callback(_param)
        dump(_param.result,"创建组队数据")
        if _param.result ~= nil then
            -- self:button_btn_close()
            local data = {
                _type =  self.addteamDatas._type or 1,
                diffic = self.addteamDatas.diffic or 1,
            }
            WindowControler:showWindow("TrialNewFriendPiPeiView",data);
        end
    end 

    local id = TrailModel:getIdByTypeAndLvl(self.addteamDatas._type or 1, self.addteamDatas.diffic or 1);
    local params = {}
    params.trialId = id
    TrialServer:sendCreateTeam(params,_callback)

    -- 发送扫荡协议
 --    TrailModel:setTraildiffid(self._selectIndex)
    -- local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    -- TrialServer:sweep(c_func(self.sweepCallback, self), id, 1);
end
---是否在组队中
function TrailModel:setispipeizhong(file)
    self.ispipeizhong = file
end
function TrailModel:getispipeizhong()
    return self.ispipeizhong
end
function TrailModel:startPiPeiBattleCallback(event)
    if event.error == nil then 
        local battleInfo = {
            battleLabel = nil,battleParams={},battleId = tostring(event.params.data.battleId),
            battleUsers = self.battleUsers,
            randomSeed = event.params.data.randomSeed,
            formation = event.params.data.formation,
        }
        if types == TrailModel.TrailType.ATTACK then 
            battleInfo.battleLabel = GameVars.battleLabels.trailGve1
        elseif types == TrailModel.TrailType.DEFAND then
            battleInfo.battleLabel = GameVars.battleLabels.trailGve2
        else
            battleInfo.battleLabel = GameVars.battleLabels.trailGve3
        end
        battleInfo.battleParams.trialId = TrailModel:getIdByTypeAndLvl(self.battletypeId,self.battleselectid)

        battleInfo = BattleControler:turnServerDataToBattleInfo( battleInfo )

        EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)--,self.doBackClick,self)
        BattleControler:startBattleInfo(battleInfo);
    end
end
---中途匹配失败
function TrailModel:UNpipeiWeiSuccess()
    WindowControler:showWindow("TrialNewFriendPiPeiView",data);
end
function TrailModel:isopenType(typeid)
    local sourdata = FuncTrail.getTrialResourceIsOpen(typeid)
    local newsourdata =  string.split(sourdata[1], ",")
    if tonumber(newsourdata[1]) == 1 then
        if UserModel:level() >= tonumber(newsourdata[2])  then
            return true
        else
            return false,tonumber(newsourdata[2])
        end
    end
end
-----推送给玩家是不是要进入加入界面
function TrailModel:notifyAddChallengView(event)
    dump(event.params,"推送数据")

    --[[
    {
       "method" = 1814
        "params" = {
            "data" = {
                "avatar"  = 104
                "level"   = 80
                "name"    = "许亦"
                "rid"     = "dev_129"
                "sec"     = "dev"
                "trialId" = 3001
                "uid"     = "129"
            }
            "serverTime" = 1495090824040
        }
    }
]]  
    local trialId = event.params.params.data.trialId
    local friendRid = event.params.params.data.rid
    local frienddata = event.params.params.data
    -- local frienddata = self:getFriendList(friendRid)
    local types,index = self:ByIdgettypeAndIndex(trialId)
    -- echo("===types=====index=============",types,index)
    ---[[
    local data = {
        name = frienddata.name,
        id = tonumber(frienddata.uid),
        avatar = frienddata.avatar,
        _type = types,
        diffic =  index,
        sec = frienddata.sec,
        rid = friendRid,
        level = frienddata.level,
        battle = frienddata.battle or 1500,
        friendalldata = frienddata,

    }
    -- if data.id ~= UserModel:rid() then
        -- local id = self:getIdByTypeAndLvl(data._type, data.diffic)
        if BattleControler:isInBattle() == false then
            if self.starData[tostring(trialId)] ~= nil then   --是否开启这个试炼关卡
                if self.ispipeizhong == false then
                    if self.teamView == nil then
                        -- local isinview =  WindowControler:getCurrentWindowView()
                        -- local scene = WindowControler:getCurrScene()
                        local scene =  display.getRunningScene()
                        self.teamView = WindowsTools:createWindow("TriaNewlTeamView"):addto(scene._topRoot,WindowControler.ZORDER_TIPS)
                        self.teamView:pos(0,display.height)
                        self.teamView:updateUI(data)
                    else
                        self.teamView:setVisible(true) 
                        self.teamView:updateUI(data)
                    end
                end
            end
        end

    --当重新匹配到人的时候执行  重置当前的状态
    TeamFormationMultiModel:resetTimeOut()
    -- end
    -- ]]
end
function TrailModel:removeTeamView()
    if self.teamView ~= nil then
        self.teamView:setVisible(false) 
        --removeFromParent() 
    end
end
function TrailModel:getFriendList(friendRid)
    local friendlist =  FriendModel:getFriendList()
    -- dump(friendlist,"1111111111")
    if friendlist.count ~= 0 then
        local data = friendlist.friendList
        for k,v in pairs(data) do
            if friendRid == v._id then
                return v
            end
        end
    end
end
function TrailModel:ByIdgettypeAndIndex(battleId)
     -- (kind - 1) * 5 + lvl + 3000;
     for types=1,3 do
        for index=1,5 do
            if (battleId - 3000 - index)/5 + 1 == types then
                return types,index
            end
        end
     end

end
function TrailModel:setparamsdatabattleUsers(data)
    self.battleUsers = data
end
function TrailModel:addchallengview(event)
    if event.error ~= nil then
        return 
    end
    self.doingBattleData = event.params.params.data
    local serverlist =  LoginControler:getServerList()
    local playdata = nil
    if event.params ~= nil then
        local data = event.params.params.data.battleUsers
        -- echo("===========UserModel:rid()========================",UserModel:rid())
        self:setparamsdatabattleUsers(data)
        for k,v in pairs(data) do
            dump(v.rid,"当前的数据")
            if v.rid  ~= UserModel:rid() then
                playdata = v
            end
        end 
    end
    -- dump(playdata,"推送加入的数据")
    -- local sec = playdata._id
    local garmentid = ""
    if playdata.userExt ~= nil then
            garmentid = playdata.userExt.garmentId or ""
    end
    local total = 1000
    if playdata.ability and playdata.abilityNew.total then
        total = playdata.abilityNew.total
    end    
    local data = {
        avatar = playdata.avatar,
        sec = playdata.sec or "dev",
        name = playdata.name or GameConfig.getLanguage("tid_common_2006"),
        level = playdata.level,
        battle = total,
        rid = playdata._id,
        garmentid = garmentid,
    }
    ChatServer:addTeamPlayer(data)


    local Windowname =  WindowControler:getWindow( "TrialNewFriendPiPeiView" )
    if Windowname ~= nil then
        Windowname:Addplaydata(data)
        TeamFormationMultiModel:updateData(event.params.params.data)
    end

end
---设置挑战完后好友的添加
function TrailModel:setchallengaddfrienddata(data)
    self.challengaddfrienddata = data
end
---挑战完成后好友推荐方法
function TrailModel:getchallengaddfrienddata()
    local Friendlist = FriendModel:getFriendList()
    local id  = 1--self.challengaddfrienddata.id
    -- dump(Friendlist,"1111111111111111111111")
    if #Friendlist ~= nil then 
        if Friendlist.friendList ~= nil then
            for k,v in pairs(Friendlist.friendList) do
                if id == v.uid then
                    return nil
                end
            end
        end
    end
    return self.challengaddfrienddata
end
function TrailModel:bytimeGetCount()
   
    -- local minute = os.date("%M",time)
    -- local second = os.date("%S",time)
    -- dump(self.StarData,"111111111111",8)
    -- for k,v in pairs(self.starData) do
    --     local time =  tonumber(v.expireTime)
    --     if time ~= nil then
    --         if tonumber(TimeControler:getServerTime()) >= time then
    --             self.starData[k].count = 0
    --         end
    --     end
    -- end
end
function TrailModel:panduantime(time)
    local serverTime = tonumber(TimeControler:getServerTime())
    local serveryear = tonumber(os.date("%Y",serverTime))
    local servermonth = tonumber(os.date("%m",serverTime))
    local serverday = tonumber(os.date("%d",serverTime))
    local serverhour = tonumber(os.date("%H",serverTime))
    local landtime = tonumber(time)
    local landyear = tonumber(os.date("%Y",landtime))
    local landmonth = tonumber(os.date("%m",landtime))
    local landday = tonumber(os.date("%d",landtime))
    -- local landhour = os.date("%H",landtime)
    -- echo("======serverday=====landday======================",serverday,landday)

    if serveryear >= landyear and servermonth >= landmonth and serverday > landday and serverhour >= 4 then
        return true

    else
        if serveryear >= landyear and servermonth >= landmonth then
            if serverday == landday then
                if landday < 4 and serverhour >= 4 then
                    return true
                end
            end
        end
        return false
    end



end
--现在某试炼类型trailKind是否开启
function TrailModel:isTrialTypeOpenCurrentTime(trailKind)

    --试炼全部开启
    -- return true;

    -- 根据时间开启
   local serverTime = TimeControler:getServerTime();

   local offsetHour = FuncCount.getHour(trailKind + 10);

   -- echo("offsetHour " .. tostring(offsetHour));

   local timestampOffset = -offsetHour * 60 * 60;
   local relativeTime = serverTime + (timestampOffset or 0);
   --relativeTime 时间是星期几
   local dates = os.date("*t", relativeTime);

   -- dump(dates, "--isTrialTypeOpenCurrentTime--")

   local wday = (dates.wday - 1) % 7; --周日是第一天

   if wday == 0 then 
       wday = 7;
   end 

   local openDays = self:getTrialKindOpenDays(trailKind);
   -- dump(openDays,"时间")
   if table.isValueIn(openDays, wday) == true then 
       return true;
   else 
       return false;
   end 
end


function TrailModel:getTrialKindOpenDays(trailKind)
    -- 
    local openTime = FuncTrail.getTrialResourcesData(trailKind,"openCycle")
    -- if trailKind == 1 then 
    --     return {1, 4, 7};
    -- elseif trailKind == 2 then
    --     return {2, 5, 7};
    -- else 
    --     return {3, 6, 7};
    -- end 
    local timeyable = {}
    local reward = string.split(openTime, ",");
    for i=1,#reward do
        timeyable[i] = tonumber(reward[i])
    end
    return timeyable
end

function TrailModel:getTrialPointsByKind(trailKind)
    return UserModel:trialPoints()[tostring(trailKind)] or 0;
end

--某试炼种类的试炼难度是否开启扫荡了
function TrailModel:isSweepOpenThatKindAndLvl(trailKind, lvl)
    local id = self:getIdByTypeAndLvl(trailKind, lvl);
    -- local needPoint = FuncTrail.getTrailData(id, "openSweep");
    local havePoint = self:getPointsByType(trailKind);
    local haveCount = self:getLeftCounts(trailKind)
    -- echo(" 难度 == " .. lvl .. "  需要 == " .. needPoint .. " 已有 == " .. havePoint .. " 剩余挑战次数 == " .. haveCount .. "类型 == " .. trailKind)
    -- if haveCount > 0 and haveCount < self:getTotalCount()   then --needPoint <= havePoint
    --     return true;
    -- else 
    --     return false;
    -- end 
    local TrailStar = TrailModel:getTrailStar(id)
    if tonumber(TrailStar) == 3 then
        return true;
    else
        return false;
    end

end

--某种试炼的某种等级是否达到了试炼点数
function TrailModel:isTrailPointEnough( trailKind, lvl )
    local id = self:getIdByTypeAndLvl(trailKind, lvl);
    local needPoint = FuncTrail.getTrailData(id, "openSweep");
    local havePoint = self:getPointsByType(trailKind);
    if needPoint <= havePoint then 
        return true;
    else 
        return false;
    end   
end

--某种类型的试炼 某种难度是否 解封 了
function TrailModel:isDeblockThanKindAndLvl(trailKind, lvl)
    local id = self:getIdByTypeAndLvl(trailKind, lvl);
    local isDeBlock = self.starData[tostring(id)];
    -- dump(UserModel:trials(),"=======11111111======",6)
    if isDeBlock == nil then 
        return false
    else 
        return true;
    end 
end
function TrailModel:updateData(data)
    dump(data,"试炼服务器数据数据",9)
    -- -- self.StarData = data
    -- dump(self.StarData,"111111111111111",6)
    if self.starData ~= nil then
        for k,v in pairs(data) do
            if self.starData[tostring(k)] ~= nil then
                self.starData[tostring(k)] = v

            else
                self.starData[tostring(k)] = {}
                self.starData[tostring(k)] = v
            end
        end
    end
end






function TrailModel:sweepdata(data)
    
    -- for k,v in pairs(data) do
    --     if self.starData[k] ~= nil then
    --         self.starData[k].count = v.count
    --     end
    -- end
end
function TrailModel:setserverStarData(data)
       --[["3006" = {
            "count"      = 0
            "expireTime" = 1494619200
            "id"         = 3006
        }]] 
        -- dump(data,"111111试炼服务器数据数据")
        if data ~= nil then
            for k,v in pairs(data) do
                self.starData[k] = v
            end
        end


end
function TrailModel:getServerData(TrailId)
    if self.starData[tostring(TrailId)] ~= nil then
        return self.starData[tostring(TrailId)]
    else
        return nil
    end
end

function TrailModel:getIdByTypeAndLvl(kind, lvl)
    if kind == nil or lvl == nil then
        return 
    end
    return (kind - 1) * 5 + lvl + 3000;
end

function TrailModel:getPointsByType(kind)
    return UserModel:trialPoints()[tostring(kind)] or 0;
end

function TrailModel:getLeftCounts(kind)
   local leftTime = CountModel:getTrialCountTime(kind);
   return self:getTotalCount() - leftTime;
end

function TrailModel:isTrailOpen(kind, difficult)
    local playerLvl = UserModel:level();
    local id = self:getIdByTypeAndLvl(kind, difficult);
    local needLvl = FuncTrail.getTrailData(id, "condition");
    -- dump(needLvl,"22222222")

    local isOpen = true;
    if playerLvl < needLvl[1].v then 
        isOpen = false;
    end 
    return isOpen, needLvl[1].v;
end 

--现在开启的试炼类型
function TrailModel:getOpenKind()
    local ret = {};
    for i = 1, 3 do
        if self:isTrialTypeOpenCurrentTime(i) == true then 
            table.insert(ret, i);
        end 
    end
    return ret;
end

function TrailModel:isRedPointShow()
    local openKind = self:getOpenKind();
    for k, kind in pairs(openKind) do
        if self:getLeftCounts(kind) > 0 then 
            return false;
        end 
    end
    return false;
end

function TrailModel:getTotalCount()
    return FuncTrail.getTotalTimes("3001");
end
function TrailModel:getTrailStar(id)
    -- dump(self.StarData,"1111111111")
    if self.starData[tostring(id)] ~= nil then
        return self.starData[tostring(id)]
    else
        return 0
    end
end
function TrailModel:setTrailStar(id,starnumber)
    if self.starData[tostring(id)] ~= nil then
        self.starData[tostring(id)] = starnumber
    else
        self.starData[tostring(id)] = starnumber
    end
end
function TrailModel:TrailCustomsClearance(checkpointID)
    local starnumber = self.starData[tostring(checkpointID)]
    if starnumber ~= nil then
        return true
    else
        return false        
    end
end

function TrailModel:getSweepFinishTime(id)
    -- dump(self.StarData,"试炼数据")
    -- echo("============id============",id)
    local time = 0
    if self.starData[tostring(id)] ~= nil then
        local times = self.starData[tostring(id)].lastMatchTime  ---服务器数据
        if times ~= nil then
            time = FuncTrail.getServerTime(id,times)
        end
    end
    return time

end
function TrailModel:setTrailPlayData(data)
   self.TrailPlayData = data
end
function TrailModel:getTrailPlayData()
    return self.TrailPlayData 
end
---判断挑战界面的红点
function TrailModel:showChallengTrailMainRed()
    for i=1,3 do
        local isred = TrailModel:newRedisShow(i)
        if isred then
            return true
        end
    end
    return false

end
---判断试炼主界面红点
function TrailModel:showTrailMainRed(Trailtypeid)  ---1,2,3

    local difftype = 5
    local openindex = nil
    for i=1,difftype do
        if TrailModel:isTrailOpen(Trailtypeid, i) == true then
           local isred = self:ByTypeAndIDgetRedIshow(Trailtypeid,i)
           if isred then
                return isred
           end
        end 
    end
    if openindex == nil then
        return false
    end
    return self:ByTypeAndIDgetRedIshow(Trailtypeid,openindex)

end
function TrailModel:ByTypeAndIDgetRedIshow(typeid,diffId)
    if not TrailModel:isTrailOpen(typeid, diffId) then
        return false
    end

    if not TrailModel:isDeblockThanKindAndLvl(typeid, diffId) then
        return true
    end

    local Trailid = self:getIdByTypeAndLvl(typeid, diffId)
    -- echo("=====================",Trailid)
    local alldata = FuncTrail.getTrailIDbyReward(typeid,Trailid)
    -- dump(alldata)
    local allnumber = self:getIdByrewardNumber(typeid)

    local sum = FuncTrail.getSumChallengNum()
    local num = self.starData[tostring(Trailid)].count or 0
    if sum - num > 0 then
        return true
    end
    -- for i=1,#alldata do
    --     local reward =  string.split(alldata[i], ",")
    --     local number = reward[3]
    --     local id = reward[2]

    --     local idgetnumber = 0
    --     if allnumber ~= nil then
    --         if allnumber[tostring(id)] ~= nil then
    --             idgetnumber = tonumber(allnumber[tostring(id)])
    --         end
    --     end 
    --     if number - idgetnumber > 0 then
    --         return true
    --     end
    -- end
    return false

end
---显示详情按钮上的红点
function TrailModel:byIdGetRedtruewOrFalse(typeid,index)
    if not TrailModel:isDeblockThanKindAndLvl(typeid, index) then
        return true
    end
    local Trailid = self:getIdByTypeAndLvl(typeid, index)
    -- echo("=====================",Trailid)
    local alldata = FuncTrail.getTrailIDbyReward(typeid,Trailid)
    local allnumber = self:getIdByrewardNumber(typeid)
    for i=1,#alldata do
        local reward =  string.split(alldata[i], ",")
        local number = reward[3] * 2
        local id = reward[2]

        local idgetnumber = 0
        if allnumber ~= nil then
            if allnumber[tostring(id)] ~= nil then
                idgetnumber = tonumber(allnumber[tostring(id)])
            end
        end 
        if number - idgetnumber > 0 then
            return true
        end
    end
    return false
end
function TrailModel:getIdByrewardNumber(typeid,_file)

    local difftype = 5
    local allrewarddata = nil
    local countnumber = nil

    for i=difftype,1,-1 do
        local challengID = self:getIdByTypeAndLvl(typeid,i)
        local traildata = self.starData[tostring(challengID)]
        if traildata ~= nil then
            if traildata.count ~= nil then
                if traildata.count > 0 then
                    if countnumber == nil then
                        countnumber = traildata.count
                    else
                        if countnumber == 0 then
                            countnumber = traildata.count
                        elseif countnumber == 1 then
                            if traildata.count >= 0 then
                                countnumber  = traildata.count
                            else
                                countnumber = countnumber
                            end
                        else
                            countnumber = 2
                        end
                    end
                else
                    countnumber = 0
                end
            else
                countnumber = 0
            end
        else
            countnumber = 0
        end
        -- echo("=====challengID=========",challengID)
        local award = FuncTrail.byIdgetdata( challengID ).trialReward
        for _x=1,#award do
            local reward =  string.split(award[_x], ",")
            if allrewarddata == nil then
                allrewarddata = {}
                allrewarddata[reward[2]] = reward[3] * countnumber
            else
                if _file then
                    allrewarddata[reward[2]] = reward[3] * countnumber
                else
                    if allrewarddata[reward[2]] == nil then
                        allrewarddata[reward[2]] = reward[3] * countnumber
                    else
                        allrewarddata[reward[2]] = allrewarddata[reward[2]] + reward[3] * countnumber
                    end
                end
               
            end
        end
    end
    return allrewarddata
end
function TrailModel:IsTrailjiefeng(typeid,index)

    local TrailID =  self:getIdByTypeAndLvl(typeid, index);
    local Traildata = FuncTrail.byIdgetdata( TrailID ).condition
     -- Traildata[2].v
     -- dump(Traildata,"1111111111111")
    if Traildata[2] ~= nil then
        if self.starData[tostring(Traildata[2].v)] ~= nil then
            return true
        else
            return false
        end
    else
        return true
    end
end
function TrailModel:setTraildiffid(Trailtypeid)
    self.traildifftypeid = Trailtypeid
end
function TrailModel:getTraildiffid()
    return self.traildifftypeid
    -- body
end
function TrailModel:setbattleTypeAndId(typeId,selectid)
    self.battletypeId = typeId
    self.battleselectid = selectid
end
function TrailModel:getbattleTypeAndId()
    return TrailModel:getIdByTypeAndLvl(self.battletypeId,self.battleselectid);
end
function TrailModel:setTrailPve(trailPve)
    self.trailPve = trailPve
end


--设置匹配过的时间
function TrailModel:setPiPeiDoTimes(pipeiqiantime,time)
    self.pipeiqiantime = pipeiqiantime
    self.pipeiDoTime = time
end

--设置匹配是否有玩家
function TrailModel:setPiPeiPlayer(isboor)
    self.isServePlayer = isboor
end
function TrailModel:getPiPeiPlayer()
    return  self.isServePlayer
end
function TrailModel:doCloseViewForServerClose()
    self.doCloseServe = true
    local WindownamesPiPei =  WindowControler:getWindow( "TrialNewFriendPiPeiView" )
    local WindownamesMulti =  WindowControler:getWindow( "WuXingTeamEmbattleView" )
    -- if WindownamesPiPei ~= nil then
    --     WindownamesPiPei:unscheduleUpdate()
    -- end
    if WindownamesMulti ~= nil then
        WindownamesMulti:unscheduleUpdate()
    end
end

---断线重连机制
function TrailModel:BoltReconneCtion(event)
    local WindownamesPiPei =  WindowControler:getWindow( "TrialNewFriendPiPeiView" )
    local WindownamesMulti =  WindowControler:getWindow( "WuXingTeamEmbattleView" )
    local dt = math.floor(event.params.dt)   
    local pipeitiotime = 5
    local sumMulti = 50
    local pipeiDotimes = math.floor(self.pipeiDoTime/30)
    local noPiPeiplayertime = 15


    --如果走重登逻辑，则不走重连机制
    -- if self.doCloseServe then
    --     if WindownamesPiPei ~= nil then
    --         WindownamesPiPei:startHide()
    --     end
    --     return
    -- end
    -- echo("=========222222222222222=====1=======",self.isServePlayer,dt)

    if self.isServePlayer  == nil then  --是否匹配到玩家
        if WindownamesPiPei ~= nil then
            if dt >= noPiPeiplayertime then
                -- if math.floor(self.pipeiqiantime/30) <= pipeitiotime then
                    WindowControler:showTips("匹配超时，重新匹配")
                -- end
                WindownamesPiPei:startHide()
                 local data = {
                    _type =  self.battletypeId,
                    diffic = self.battleselectid,
                }
                WindowControler:showWindow("TrialNewFriendPiPeiView",data);
            end
            return 
        end
    end

    --获得当前视图
    if WindownamesPiPei ~= nil then   ---在匹配界面
        -- echo("====dt=====44444444==========",dt,pipeiDotimes)
        local time = sumMulti + (pipeitiotime -pipeiDotimes - dt )
        if dt >= (pipeitiotime -pipeiDotimes )  and dt < time then  --跳转到布阵界面  
            WindownamesPiPei:startHide()
            local multiView = WindowControler:showWindow("WuXingTeamEmbattleView",self.trailPve,nil,false,true)
            -- multiView:setBackGroundTime(time)
        elseif dt > time then   ---跳转到战斗界面
            echo("跳转到战斗界面")
            WindownamesPiPei:startHide()
            local multiView = WindowControler:showWindow("WuXingTeamEmbattleView",self.trailPve,nil,false,true)
            -- if WindownamesMulti ~= nil then
            --     echo("00000000000000000000000000000000")
                multiView:setBackGroundTime(time)
            -- end
        end
    elseif WindownamesMulti ~= nil then   --在布阵界面
        local restime = TimeControler:getCdLeftime("multiFormation_leftTime_CD")
        if dt >= restime then
            if WindownamesMulti ~= nil then
                -- echo("1111111111111111111111111111111111111111111")
                WindownamesMulti:setBackGroundTime(sumMulti)
            end
        end
    end
    self.doCloseServe = false
end

function TrailModel:isOpenByRaid(_raid, _typeid)
    if _raid == nil then
        echoError("=======试炼  跳转 _raid is nil ========")
        return false
    end
    local isopen, level = self:isopenType(_typeid)
    if isopen then
        local playerLvl = UserModel:level();
        local needLvl = FuncTrail.getTrailData(_raid, "condition");
        local isOpen = true;
        if playerLvl < needLvl[1].v then 
            isOpen = false;
        end
        return isOpen
    end
    return false
end


---根据试炼的关卡ID获得是否解封
function TrailModel:getIsOpenByLevel(levelID)
    local alldata = FuncTrail.getAlltrialData()
    local trailid = nil
    if levelID == nil then
        return false
    end
    for k,v in pairs(alldata) do
        if tonumber(v.level1) == tonumber(levelID) then
            trailid = k
        end
    end
    if trailid == nil then
        return false
    end
    if self.starData ~= nil then
        local isDeBlock = self.starData[tostring(trailid)];
        if isDeBlock ~= nil then 
            return true
        end 
    end
    return false
end


-- 根据试炼类型获得最大的关卡
function TrailModel:getTrialLevelIsOpen(trial_type)
    local trialData =  FuncTrail.getTrialDataById(trial_type)
    for i=#trialData,1,-1 do
        local condition =  trialData[i].condition
        for k,v in pairs(condition) do
            if v.t == UserModel.CONDITION_TYPE.LEVEL then
                if UserModel:level() >= v.v then
                    return trialData[i]
                end
            end
        end
    end

end
--根据试炼类型获取挑战次数
function TrailModel:getTrialCount(_trialtype)
    local count = 0
    if _trialtype == TrailModel.TrailType.ATTACK then
        count = CountModel:getLimitSSNum()
    elseif _trialtype == TrailModel.TrailType.DEFAND then
        count = CountModel:getLimitHSSum()
    elseif _trialtype == TrailModel.TrailType.DODGE then
        count = CountModel:getTrialDBNum()
    end
    return count
end

--新的红点显示问题
function TrailModel:newRedisShow(_trialtype)
    local sumcount = FuncTrail.getallchallengCount()
    -- local openCycle = FuncTrail.getTrialResourcesData(_trialtype, "openCycle")
    local isopen = self:isopenType(_trialtype)
    if isopen then
        local count = TrailModel:getTrialCount(_trialtype)
        local num = sumcount[tonumber(_trialtype)] - count
        if num > 0  then
            return true,num
        else
            return false,0
        end
    end
    return false,sumcount[tonumber(_trialtype)]
end
--显示总的挑战次数
function TrailModel:getAllCountNum()
    local sumcount = FuncTrail.getSumChallengNum()
    local  count = 0
    local systemcun = 0
    for i=1,3 do 
        local isopen = self:isopenType(i)
        if isopen then
            count = count + self:getTrialCount(i) 
            systemcun = systemcun + 1
        end
    end
    return sumcount *systemcun - count

end

function TrailModel:getChallengStar(_trialtype)
    local stardata = self.starData

    dump(stardata,"=====试炼数据==========")
    local starnum = stardata[tostring(_trialtype)]
    if starnum ~= nil then
        return true
    end
    return false
end

--获取奖励进度
function TrailModel:getRewardProgress(diffID)
    local stardata = self.starData
    local data = stardata[tostring(diffID)]
    if data then
        local allData = FuncTrail.byIdgetdata( diffID )
        local bossNum = data.boss or 0
        local monsterNum = data.monster or 0
        if monsterNum ~= 0 or bossNum ~= 0 then
            local sumNum = allData.showReward[1] --总数量
            local rewardbase = allData.rewardbase[1]  --基础
            local rewardmonster = allData.rewardmonster[1]  --怪物数量
            local rewardboss = allData.rewardboss[1]  --boss数量

            local sumNumArr = string.split(sumNum,",")
            local rewardbaseArr = string.split(rewardbase,",")
            local rewardmonsterArr = string.split(rewardmonster,",")
            local rewardbossArr = string.split(rewardboss,",")
            if sumNumArr[1] == FuncDataResource.RES_TYPE.ITEM then
                local sumRewardNum  =  tonumber(rewardbaseArr[3]) + bossNum*tonumber(rewardbossArr[3]) +  monsterNum*tonumber(rewardmonsterArr[3]) 
                -- echo("=====rewardbaseArr=========",tonumber(rewardbaseArr[3]))
                -- echo("=====rewardbossArr=========",tonumber(rewardbossArr[3]))
                -- echo("=====bossNum=========",tonumber(bossNum))
                -- echo("=====monsterNum=========",tonumber(monsterNum))
                -- echo("=====rewardmonsterArr=========",tonumber(rewardmonsterArr[3]))
                -- echo("=====sum = =========",tonumber(sumRewardNum))
                -- echo("=====sum =/ =========",tonumber((sumRewardNum/tonumber(sumNumArr[3]))*100))
                if sumRewardNum > tonumber(sumNumArr[3]) then
                    sumRewardNum = tonumber(sumNumArr[3])
                end
                return math.floor(((sumRewardNum/tonumber(sumNumArr[3]))*100)).."%"
            else
                local sumRewardNum  =  tonumber(rewardbaseArr[2]) + bossNum*tonumber(rewardbossArr[2]) +  monsterNum*tonumber(rewardmonsterArr[2]) 
                if sumRewardNum > tonumber(sumNumArr[2]) then
                    sumRewardNum = tonumber(sumNumArr[2])
                end
                return math.floor(((sumRewardNum/tonumber(sumNumArr[2]))*100)).."%"
            end
        end
    end
    return "0%"
end


--布阵挑战
function TrailModel:onTeamFormationComplete(data)
    -- dump(data.params,"布阵挑战")


    local params = data.params
    if params.systemId == FuncTeamFormation.formation.trailPve1 or 
        params.systemId == FuncTeamFormation.formation.trailPve2 or
        params.systemId == FuncTeamFormation.formation.trailPve3  then
        local id =  self.traildifftypeid--TrailModel:getIdByTypeAndLvl( self.traildifftypeid, self._selectIndex);
        TrialServer:startBattle(c_func(self.startBattleCallback, self,id,2), id, 1,params.formation);
    end
end
function TrailModel:startBattleCallback(level,sigleFlag,event)

    if event.error == nil then 
        --单人战斗
        local _battleId = tostring(event.result.data.battleInfo.battleId);
        TrialServer:setBattleId(_battleId);
        local battleInfo = BattleControler:turnServerDataToBattleInfo( event.result.data.battleInfo )
        --暂时的
        EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)--,self.doBackClick,self)
        BattleControler:startPVE(battleInfo); 
    end
end


function TrailModel:setSelectChallengeID(_selecttype)
   
    self._selecttype = _selecttype
end

return TrailModel;






















