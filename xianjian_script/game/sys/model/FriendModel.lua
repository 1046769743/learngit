-- //@好友系统的数据
-- //&2016-4-23
-- //@author:xiaohuaxiong
local FriendModel = class("FriendModel");
-- //不属于玩家角色本身的属性
function FriendModel:init(_data)
    -- dump(_data,"好友liem")
    -- //好友列表
    self.friendList = { };
    -- //当前是好友列表中的多少页(好友界面需要分页显示好友)
    self.friendNowPage = 1;
    -- //好友的数目
    self.friendCount = 0;
    -- //向自己申请好友的玩家列表
    self.friendApplyList = { };
    -- //当前处于申请好友页面的第几页
    self.applyFriendNowPage = 1;
    -- //系统推荐的好友列表
    self.recommendFriendList = { };
    -- //自己搜索的好友列表
    self.researchFriendList = { };
    self.recommendedFriend = {}
    -- //玩家自己的签名
    self.motto = _data.sign;
    if (self.motto == nil) then
        self.motto = "";
    end
    self.worldChatCD = 0

    self.tianjiarenshu = 0
    -- //好友申请数目
    self.friendApplyCount = 0;
    -- //好友赠送的体力数目
    self.friendSendSpCount = 0;
    self:getLandFriendData()
    self:sendServerdata()
end
function FriendModel:sendServerdata()
    local function _callback(_param)
        -- dump(_param.result.data,"获取好友申请列表") 
        if (_param.result ~= nil) then
            local data = _param.result.data
            if data.applyList ~= nil then
                if table.length(data.applyList) ~= 0 then
                    self:updateFriendApply(data); 
                    self:checkHomeRedPointEvent(true, FriendEvent.FRIEND_APPLY_REQUEST);
                end
            end
        else
            echo("----FriendMainView:freshFriendApplyCommon--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.page = 1;
    FriendServer:getFriendApplyList(param, _callback);
end
function FriendModel:isFriendApply()
    -- //是否有好友申请
    return self.friendApplyCount > 0;
end
function FriendModel:removeFriendUID( uid )
    -- dump(self.friendList,"000000")
    for i=1,#self.friendList do
        if uid == self.friendList[i].uid then
            self.friendList[i] = nil
        end
    end
    -- dump(self.friendList,"0101110110")
    local index = 1
    for i=1,#self.friendList do
        if self.friendList[i]   ~= nil then
            self.friendList[index] = self.friendList[i]
            index =index + 1
        end
    end
    -- dump(self.friendList,"1111111111111")
end
function FriendModel:insertFriendData(data)
    if #self.friendList == 0 then
        table.insert(self.friendList,data)
    else
        local isfriend = false
        for i=1,#self.friendList do
            if data._id == self.friendList[i]._id then
                isfriend = true
            end
        end
        if isfriend == false then
            table.insert(self.friendList,data)
        end
    end
end
function FriendModel:setfriendApplyCount(_type)
    if _type ~= nil then
        self.friendApplyCount = 0
    end
    if self.friendApplyCount > 0 then
        self.friendApplyCount = self.friendApplyCount - 1
    else
        self.friendApplyCount = 0
    end
end
function FriendModel:isFriendSendSp()
    -- //是否满足领取好友赠送的体力的条件
    local _maxSpNum = FuncDataSetting.getDataByConstantName("ReceiveTimes");
    -- //体力领取的上限
    local _achieveCount = CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_ACHIEVE_SP_COUNT);
    

    if  _achieveCount < _maxSpNum then
        return true
    end
    return false
    -- local _other_flag = UserExtModel:sp() + FuncDataSetting.getDataByConstantName("FriendGift") <= FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
    -- local _send_flag = _achieveCount < _maxSpNum and self.friendSendSpCount > 0 and _other_flag
    -- return _send_flag;
end
-- //检查主页面是否需要显示红点
function FriendModel:checkHomeRedPointEvent(showRed, eventType)
    --        local    showRed=false;
    -- //如果满足需要刷新的条件,发送消息

    local  isshow = {}
    isshow[1] = showRed or self:isFriendApply() 
    isshow[2] = self:getFriendIsHaveSp() or false

    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, 
        {
            redPointType = HomeModel.REDPOINT.LEFTMARGIN.FRIEND,
            isShow =   showRed or self:isFriendApply() or self:getFriendIsHaveSp(),   --{[1] =isshow[1],[2] = isshow[2]  }, --self:isFriendApply()  or MailModel:checkShowRedForFriend(),
            eventType = eventType, -- //需要在标记红点事件上做细分时使用
        }
    );
end

-- //更新好友赠送体力数据,注意这里面传送的数据
function FriendModel:updateFriendSendSp(_data)
    self.friendCount = _data.count;
    self.friendSendSpCount = 0--_data.spCount;
    -- self:checkHomeRedPointEvent(true, FriendEvent.FRIEND_SEND_SP_UPDATE);
    -- //分发好友赠送体力事件
    EventControler:dispatchEvent(FriendEvent.FRIEND_SEND_SP_UPDATE);
end
-- //好友申请数据更新
function FriendModel:updateFriendApply(_data)
    -- //判断是否有好友申请
    self.friendApplyCount = _data.count;
    self.friendApplyData = _data.applyList
    self:checkHomeRedPointEvent(_data.count > 0, FriendEvent.FRIEND_APPLY_REQUEST);
    EventControler:dispatchEvent(FriendEvent.FRIEND_APPLY_REQUEST);
end
function FriendModel:setnowFriendPage(Page)
    self.Page = Page
end
function FriendModel:getnowFriendPage()
    return self.Page or 1
end
function FriendModel:getLandFriendData()
    local friendlist = LS:pub():get(StorageCode.friend_list..UserModel:uid(),nil)
    if friendlist ~= nil then
        self.friendList  = json.decode(friendlist)
    end
end
function FriendModel:getFriendList()
    return self.friendList;
end
function FriendModel:removeFriend(friendid)
    -- dump(self.friendList,"删除前的好友列表")
    -- echo("==========friendid=========",friendid)
    for i=1,#self.friendList do
        if friendid == self.friendList[i]._id then
            self.friendList[i] = nil
        end
    end
    local index = 1
    for i=1,#self.friendList do
        if self.friendList[i] ~= nil then
            self.friendList[index] = self.friendList[i]
            index = index + 1
        end
    end
    -- dump(self.friendList,"删除后的好友列表")
end
function FriendModel:setFriendNiCheng(data)
    for i=1,#self.friendList do
        if data._id == self.friendList[i]._id then
            self.friendList[i].mk = data.name
        end
    end
end
function FriendModel:upfriendData(data)
    self.modefname = data
end
function FriendModel:getupfriendData()
    return self.modefname
end
-- //
function FriendModel:setFriendList(_list)
    self.friendList = _list;
    LS:pub():set(StorageCode.friend_list..UserModel:uid(),json.encode(self.friendList))
end
-- //当前是第几页
function FriendModel:getNowFriendPage()
    return self.friendNowPage;
end
-- //设置当前第几页
function FriendModel:setNowFriendPage(_nowPage)
    self.friendNowPage = _nowPage;
end
-- //每页显示的数目
function FriendModel:getCountPerPage()
    return 10;
end
-- //好友数目
function FriendModel:getFriendCount()
    return self.friendCount;
end
-- //
function FriendModel:setFriendCount(_count)
    self.friendCount = _count;
end
-- //获取向自己申请加好友的申请列表
function FriendModel:getFriendApplyList()
    return self.friendFriendList;
end
function FriendModel:settianjiarenshu( number )
    self.tianjiarenshu = number
end
function FriendModel:gettianjiarenshu()
    return tonumber(self.tianjiarenshu)
end
-- //
-- //获取玩家的签名
function FriendModel:getUserMotto()
    if (self.motto == "") then
        return GameConfig.getLanguage("tid_friend_sign_max_word_1037");
    end
    return self.motto;
end
-- //设置玩家的签名
function FriendModel:setUserMotto(_motto)
    self.motto = _motto;
end
-- //设置推荐好友列表
---------------------------------
-- //监听事件,是否好友数目发生了变化
function FriendModel:checkFriendNum(_friendMap)

end
-- //好友赠送的体力发生了变化
function FriendModel:checkFriendSp(friend_id)
    -- local friendList = FriendModel:getFriendList()
    for i=1,#self.friendList do
        if self.friendList[i]._id == friend_id then
            self.friendList[i].sendTili = true
            if self.friendList[i].lk == nil then
                self.friendList[i].lk = 101  --当好友度是0时候，默认给101
            else
                self.friendList[i].lk = self.friendList[i].lk + 1
            end
        end
    end
end
function FriendModel:getRidBySec(Rid)
    local findstring = "_"
    local sec = LoginControler:getServerId()
    local index = string.find(Rid,findstring)
    if index ~= nil then
        sec = string.sub(Rid,0,index-1)
    end
    return sec
end
function FriendModel:SendServergetFriendList(callBack)
    
    local function _callback(_param)
        -- dump(_param.result,"获取服务器好友列表")
        if (_param.result ~= nil) then
            self:setFriendList(_param.result.data.friendList);
            self:setFriendCount(_param.result.data.count);
            self:updateFriendSendSp(_param.result.data);
            -- dump(FriendModel:getFriendList(),"11111111111111111111111111111111111")
             EventControler:dispatchEvent("CHAT_GETFRIEND_DATA_EVENT")
            if callBack then
                callBack()
            end
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
            echo("-----FriendMainView:clickButtonPrevPage-------", _param.error.code, _param.error.message);
        end

    end
    local param = { };
    param.page = 1;
    FriendServer:getFriendListByPage(param, _callback);

end
function FriendModel:setapplyFriendData(data)
    table.insert(self.applyFriendData,data)
end
function FriendModel:getapplyFriendData(playerID)
    local playertable = {}
    for i=1,#self.applyFriendData do
        if playerID == self.applyFriendData[i]._id then
            return self.applyFriendData[i]
        end
    end
    return player
end
function FriendModel:IsHaveFriend(firendId)
    local frienddata =  self:getFriendList()
    if #frienddata ~= 0 then 
        for i=1,#frienddata do
            if frienddata[i]._id == firendId then
                WindowControler:showTips('玩家已是你的好友')
                return
            end
        end
    end
end
function FriendModel:setChatDataInFriendData(chatData)

    for k,v in pairs(chatData) do
        if #self.friendList ~= 0 then
            for i=1,#self.friendList do
                local rid = v.rid or v._id
                if rid == self.friendList[i]._id then
                    self.friendList[i].head = v.head
                    self.friendList[i].name = v.name
                end
            end
        end
    end
end

function FriendModel:byIdISFriend(firendId)
    local frienddata =  self:getFriendList()
    if #frienddata ~= 0 then 
        for i=1,#frienddata do
            if frienddata[i]._id == firendId then
                return true
            end
        end
    end
    return false
end

function FriendModel:getFriendDataByID(firendId)
   local frienddata =  self:getFriendList()
    if #frienddata ~= 0 then 
        for i=1,#frienddata do
            if frienddata[i]._id == firendId then
                return frienddata[i]
            end
        end
    end
    return nil
end

--保存已申请推荐好友的数据
function FriendModel:setRecommendedFriend(data)
    -- self.recommendedFriend = {}
    if #self.recommendedFriend ~=  0 then
        -- for k,v in pairs(data) do
            local ishave = nil
            for kk,vv in pairs(self.recommendedFriend) do
                if data._id == vv._id then 
                    ishave = vv
                end
            end
            if not ishave then
                table.insert(self.recommendedFriend,data)
            end
        -- end
    else
       table.insert(self.recommendedFriend,data)
    end
    -- dump(self.recommendedFriend,"1111111111111")
end


--获取离线时间 在线、XX分钟、XX小时、X天、大于7天。
function FriendModel:getOutDDHHSSTime(_time)
    local str = ""
    if _time == 0 then
        str = "在线"
        return str
    else
        local serveTime = TimeControler:getServerTime()
        local remainTime  = serveTime -_time

        local day =  math.floor(remainTime/(3600*24))
        if day ~= 0 then
            str = day.."天"
        else
            local hours = math.floor(remainTime/3600)
            if hours ~= 0 then
                str = hours.."小时"
            else
                local minutes =  math.floor(remainTime/60)
                if minutes ~= 0 then
                   str = minutes.."分钟" 
                end
            end
        end
    end
    if str == "" then
        str = "1分钟"
    end
    return "离线:"..str
end

function FriendModel:panelRunAction(_cell,callBack)
    if _cell then
        _cell:stopAllActions()
        _cell:setOpacity(255)
        local fadeout = act.fadeout(1.0)
        local delaytime = act.delaytime(1.0)
        local callfunc = act.callfunc(function ()
            if callBack then
                callBack()
            end
        end)
        local act = cc.Sequence:create(delaytime,fadeout,callfunc)
        _cell:runAction(act)
    end
end


--//发送好友详情查询
function FriendModel:clickCellPlayerInfo(_item)

    local function callback(param)
        if(param.result~=nil)then
            param.result.data.data[1].index = _item.index
            WindowControler:showWindow("CompPlayerDetailView",param.result.data.data[1],self,2)--param.result.data.data[1],self,2);--//从好友系统中进入
        end
    end
    local   param={};
    param.rids={};
    param.rids[1]=_item._id;
    ChatServer:queryPlayerInfo(param,callback);
end


--添加称号
function FriendModel:addCharTitle(_ctn,titleid)
    _ctn:removeAllChildren()
    if titleid ~= "" then
        local titlesprite = FuncTitle.bytitleIdgetpng(titleid)
        local titlepng = display.newSprite(titlesprite)
        titlepng:setScale(0.6)
        titlepng:setAnchorPoint(cc.p(0.5,0.5))
        titlepng:setPosition(cc.p(0,-13))
        _ctn:addChild(titlepng)
    end
end

--判断好友是否领取体力
function FriendModel:spIsGetAll()
    local data = self.friendList
    for k,v in pairs(data) do
        if v.hasSp then
            if not v.hasGetSp then
                return true
            end
        end
    end
    return false
end

function FriendModel:friendSort(addData)
    local function sortFunc(a, b)
        local logoutTime1 = FriendModel:getServerTime(a.userExt.logoutTime)
        local logoutTime2 = FriendModel:getServerTime(b.userExt.logoutTime)
        local lk_1 = a.lk or 0
        local lk_2 = b.lk or 0
        local ability1 = a.abilityNew.formationTotal
        local ability2 = b.abilityNew.formationTotal
        if logoutTime1 > logoutTime2 then
            return true
        else
            return false
            -- if lk_1 > lk_2 then
            --     return true
            -- else
            --     return false
            -- end
        end

    end

    table.sort(addData, sortFunc)
    return addData
end

function FriendModel:getServerTime(_time)
    if _time == 0 then
        return TimeControler:getServerTime()
    else
        return _time
    end
end


--//发送世界聊天信息
function  FriendModel:sendWorldChat(callBack)
    local function callback(_param)
        --//发言成功后需要置灰冷却发送信息按钮
        if(_param.result~=nil)then
            if callBack then
                callBack()
            end
        end  
    end

    local textArr = {
        [1] = "#tid_Talk_105",
        [2] = "#tid_Talk_106",
        [3] = "#tid_Talk_107",
        [4] = "#tid_Talk_108",
    }
    local random = math.random(1,4)
    local  param={};
    param.content= GameConfig.getLanguage(textArr[random]);
    param.type = 1
    ChatServer:sendWorldMessage(param,callback);
end


---获取好友是否有体力可领
function FriendModel:getFriendIsHaveSp()
    local data = self:getFriendList()
    local isCount = self:isFriendSendSp()


    for k,v in pairs(data) do
        if v.hasSp then
            if  isCount  then
                return true
            end
        end
    end
    return false
end


function FriendModel:setFriendSp(_item)
    local data = self:getFriendList()
    for k,v in pairs(data) do
        if v._id == _item._id then
            v.hasSp = nil
        end
    end
end

function FriendModel:getworldTalkTime()
    local time = FuncDataSetting.getDataByConstantName("FriendRequest")
    return  time
end



return FriendModel;
