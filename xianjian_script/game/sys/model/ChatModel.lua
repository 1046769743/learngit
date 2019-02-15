-- //聊天系统数据
-- //2016-5-9
-- //author:xiaohuaxiong
local ChatModel = class("ChatModel", BaseModel);

function ChatModel:init()
    -- //系统消息
    self.systeMessage = {}
    -- //世界聊天中的数据
    self.worldMessage = { };
    -- //联盟聊天中的数据
    self.leagueMessage = { };
    -- //缘伴聊天中的数据
    self.loveMessage = {}
    --// 队伍聊天数据
    self.teamMessage = {}
    -- //私聊中的数据
    self.privateMessage = { };
    ---私聊的人列表
    self.fastPrivateMap = { };
    self.FriendPrivateMap = {}
    self.showChatArr = {};

    --所有聊天数据
    self.allMessage = {}
    -- self.addPrivatelist = {}
    self.chatattribute = {}
    self.typedata = {
        [1] = "ChatType_World",
        [2] = "ChatType_League",
        [3] = "ChatType_Private",
        [4] = "ChatType_team",
        [5] = "ChatType_system",
        [6] = "ChatType_alldata"
    }
    self.Chattypes = {
        [1] = "system" , ---系统
        [2] = "world", --世界
        [3] = "guild", --公会
        [4] = "team" ,  -- --队伍
        [5] = "private" , --私聊
        [9] = "system",
        -- [10] = "team",   --队伍

    }

    self.setchatsetlistindex = {
        [1] = "world" ,
        [2] = "guild" ,
        [3] = "team",
        [4] = "private" ,
        [5] = "vworld" ,
        [6] = "vguild" ,
        [7] = "vteam",
        -- [8] = "vprivate" ,
        [8] = "vlove",
    }

    self.biaoqingtable = {
        tu1001 = "开心",
        tu1002 = "囧",
        tu1003 = "呆萌",
        tu1004 = "亲亲",
        tu1005 = "生气",
        tu1006 = "大赞",
    }


    -- self.biaoqingtable = {
    --     [1] = "囧",
    --     [2] = "开心",
    --     [3] = "卖萌",
    --     [4] = "亲亲",
    --     [5] = "生气",
    --     [6] = "赞",
    -- }
    --文本聊天设置
    self.setchatsetlist = {
        world = 1,
        guild = 1,
        team = 1,
        private = 1,
        love = 1,
    }
    --语音聊天设置
    self.setchatVoicelist = {
        vworld = 0,
        vguild = 0,
        vteam = 0,
        vprivate = 0,
        vlove = 0,
    }


    self.tematype = nil

    self.voiceInitSdk = false    

    self.GetFriendSp = {}
    self.Teamplaydata = nil --队伍聊天的数据
    -- //快速查找私聊对象
    self.privateobjectnumber = 3
    -- //世界聊天中已经聊天的次数
    self.worldChatCount = 0;
    -- //聊天系统的最大记录数目,超过了这个数目,以后显示的消息将会把最初的顶掉
    self.maxChatRecordCount = 100;
    -- //如果有战报,则在原来的基础上减掉1
    -- //私聊的聊天对象
    self.privateTargetPlayer = nil;
    -- //私聊的消息是有否且没有被获取
    self.isPrivateMessageAchieve = true;
    ---默认选择世界的下标
    self.selectIndex = 2

    --缘伴红点数量
    self.loveChatRecNum = 0

    --世界聊天的CD
    self.worldChatCD = 0

    self.worldTreasureChatCD = 0
        
    self.worldArtifactChatCD = 0

    -- ChatModel:getattribute()  ---获得设置详情
    
    WindowControler:globalDelayCall(function ()
        -- FriendModel:SendServergetFriendList()
        self:sendMainTalk()  
    end,3)

    --走设置model的data
    self:setChatSetinfo(OptionsModel:data())

    self.voiceData  = {}
    self.getnotonlindata = {}




    self:createTable()

    self:getLangSetInfo()

    self:getAllChatdata()


    self:removeAllTimeData()
    -- self:getfriendData()
    self:EventListener()


    local sharedScheduler = cc.Director:getInstance():getScheduler()
    local times = GameStatic._local_data.playerOnlineTime
    local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    scheduler.scheduleGlobal(self.sendplayerOnline,times)

end


function ChatModel:setinitSdk(_bool)
    self.voiceInitSdk = _bool
end

---创建和获取表
function ChatModel:createTable()
    LSChat:createTable(FuncChat.PLAYERNAME)
    LSChat:createTable(FuncChat.CONTENT)
end

--保存玩家
function ChatModel:insertPlayerOnLocal(playerdata)
    local tabNam = FuncChat.PLAYERNAME
    local uid = playerdata.uid
    local player = LSChat:getData(tabNam,uid,nil)
    if  player == nil then 
        LSChat:setData(tabNam,uid,json.encode(playerdata))
    end
end

--保存本地文本信息
function ChatModel:insertTextOnLocal(chatuid,content)

    local tabNam = FuncChat.CONTENT
    local uid = chatuid
    LSChat:setData(tabNam,uid,json.encode(content))

end



---本地語音保存数据
function ChatModel:setVoiceData(fileID,filePath)
    LSChat:prv():set(fileID,filePath)
end


function ChatModel:EventListener()
    EventControler:addEventListener("notify_friend_send_sp_2926", self.requestFriendSp, self);
    EventControler:addEventListener("Chat_Server_land_data", self.Savedatalocal, self);
    EventControler:addEventListener(ChatEvent.CHAT_SHARE_EVENT, self.shareData, self);
    EventControler:addEventListener("notify_friend_Agreed_2928" ,self.AddFriendAgreedsendmassege,self)
    -- EventControler:addEventListener("CHAT_GETFRIEND_DATA_EVENT", self.GtFriendListData, self);
    EventControler:addEventListener("notify_friend_tihuan_server_2932", self.friendTihuanServer, self);

    EventControler:addEventListener(VoiceSdkHelper.EVENT_PLAYFILE_DONE, self.againeplayVoide, self)

    
end
function ChatModel:friendTihuanServer(_param)
    -- dump(_param.params,"好友换服数据",7)
    local frienddata = _param.params.params.data.data
    local friendlist =  FriendModel:getFriendList()
    for i=1,#friendlist do
        if friendlist[i].uid == frienddata.uid then
            friendlist[i] = {}
            friendlist[i] = frienddata
        end
    end
    -- self.privateMessage
    -- self.fastPrivateMap
    -- dump(self.privateMessage,"11111111111111",7)
    for i=1,#self.privateMessage do
        if self.privateMessage[i].uid == frienddata.uid then
            local newdata = self.privateMessage[i]
            newdata.rid = frienddata._id 
            newdata.name = frienddata.name
            self.privateMessage[i] = {}
            self.privateMessage[i] = newdata
        end
    end
    -- dump(self.privateMessage,"22222222222222",7)
    for k,v in pairs(self.fastPrivateMap) do
        if v.uid == frienddata.uid then
            local newtable = v
            newtable.rid = frienddata._id
            self.fastPrivateMap[k] = nil
            self.fastPrivateMap[frienddata._id] = newtable
        end
    end
    -- dump(self.fastPrivateMap,"3333333333333333333333333",7)
    local datatable = {  
        rid = frienddata.rid,
        uid = frienddata.uid,
     }
    self.selectTargetPlayer = datatable
    EventControler:dispatchEvent(ChatEvent.REFRESH_PLAYER_TIHUAN_SERVER)
    
end
function ChatModel:settematype(_types)
    if _types == nil then
        self.tematype = nil
        return
    end
    local _type = FuncChat.CHAT_team_TYPE[_types]
    self.tematype =  tonumber(_type) or 1

    echo("=========self.tematype==1111======",self.tematype)
end
function ChatModel:gettematype()
    echo("=========self.tematype===2222=====",self.tematype)
    return  tonumber(self.tematype)
end
function ChatModel:getBiaoqingIcon()
    -- dump(self.biaoqingtable,"22222222222222")
    return self.biaoqingtable
end
---多久显示一个
function ChatModel:chatShowDay()
    return 30 * 60 
end

--获得次数到限制花费的元宝
function ChatModel:getChatCost()
    return FuncDataSetting.getDataByConstantName("ChatCost")
end
--世界频道发言花费次数限制
function ChatModel:getChatCostNum()
    return FuncDataSetting.getDataByConstantName("ChatCostNum")
end
function ChatModel:getLangSetInfo()
    --文本设置
    local setchatsetlist = LS:pub():get(StorageCode.ChatSwtInfoData..UserModel:uid(),nil)
    if setchatsetlist ~= nil then
        self.setchatsetlist = json.decode(setchatsetlist)
    end
    --语音设置
    local setchatVoicelist = LS:pub():get(StorageCode.ChatVoiceInfoData..UserModel:uid(),nil)
    if setchatVoicelist ~= nil then
        self.setchatVoicelist = json.decode(setchatVoicelist)
    end



end
---设置设置
function ChatModel:setChatSetinfo(datainfo)
    -- datainfo = {"1" = "0"}
    for k,v in pairs(datainfo) do
        local title  =  self.setchatsetlistindex[tonumber(k)]
        if title ~= nil then
            if self.setchatsetlist[title] then
                self.setchatsetlist[title] = tonumber(v)
            else
                self.setchatVoicelist[title] = tonumber(v)
            end
        end
    end
    LS:pub():set(StorageCode.ChatSwtInfoData..UserModel:uid(),json.encode(self.setchatsetlist))
    LS:pub():set(StorageCode.ChatVoiceInfoData..UserModel:uid(),json.encode(self.setchatVoicelist))
    -- dump(self.setchatsetlist)

 
end
---获得文本聊天设置
function ChatModel:getChatSetinfo()
    return self.setchatsetlist
end
--获得语音聊天设置
function ChatModel:getChatVoiceinfo()
    return self.setchatVoicelist
end
--[[
    "系统数据1" = {
    "method" = 3520
    "params" = {
        "data" = {
            "param1" = "伍朱英"
            "param2" = "5020"
            "time"   = 1495765517
            "type"   = 1
        }
        "serverTime" = 1495765517236
    }
}

]]

function ChatModel:updateSystemMessage(_item)
    _item.zitype = 1
    if (#self.systeMessage < self.maxChatRecordCount) then
        table.insert(self.systeMessage, _item);
    else
        table.remove(self.systeMessage, 1);
        table.insert(self.systeMessage, _item);
    end
    -- self:dispatchEventMainRedShow()
    EventControler:dispatchEvent(ChatEvent.SYSTEM_CHAT_CONTENT_UPDATE);
    -- //分发系统聊天内容更新事件
end
function ChatModel:getSystemMessage()
    return self.systeMessage
end
     
function ChatModel:requestFriendSp( param )
    
    -- dump(param.params,"体力赠送消息回调")
    -- param.params.params.data.rid
    --[[ "体力赠送消息回调" = {
     "method" = 2926
     "params" = {
         "data" = {

             "rid" = "dev_241"
         }
         "serverTime" = 1495439436533
    }
    }]]
    local rid = param.params.params.data.rid
    -- WindowControler:globalDelayCall(function ()
        self:getfriendData()
    
        -- .content="【我刚刚送了你体力x1】礼物虽小，情谊无价，祝你在登仙之路越走越高！";
        -- local rid = param.params.params.data.rid
        -- local friendlist = FriendModel:getFriendList()
        -- for i=1,#friendlist.friendList do
        --     -- friendlist[]
        -- end
        -- self.GetFriendSp[rid].getSp = 1
        -- self.privateMessage  --LS:pub():get(StorageCode.friend_list..UserModel:rid(),nil)
        -- echo("=========我的RID============",UserModel:rid())
    if rid ~= UserModel:rid() then
        local friendlist = FriendModel:getFriendList()
        local friendinfo = nil
        -- dump(friendlist,"0000000")
        for i=1,#friendlist do
            if friendlist[i]._id == rid then
                friendinfo = friendlist[i]
                friendlist[i].hasSp = true
            end
        end
        -- dump(friendinfo,"111111")
        -- if friendinfo ~= nil then
        --     local _item = {
        --         avatar  = friendinfo.avatar,
        --         content = "【刚刚送了你体力x1】礼物虽小，情谊无价，祝你在登仙之路越走越高！",
        --         level   = friendinfo.level,
        --         name    = friendinfo.name,
        --         rid    = param.params.params.data.rid,
        --         time    = TimeControler:getServerTime(),
        --         type    = 1,
        --         vip     = friendinfo.vip
        --     }
        --     -- local tili = true 
        --     self:updatePrivateMessage(_item)
        --     self:getChatPrivateRedNumber()
        -- end
    end
    EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)

    
    -- end,1)
end
function ChatModel:getfriendData()
    local function _callback(_param)
        -- dump(_param.result,"获取服务器好友列表")
        if (_param.result ~= nil) then
            FriendModel:setFriendList(_param.result.data.friendList);
            FriendModel:setFriendCount(_param.result.data.count);
            FriendModel:updateFriendSendSp(_param.result.data);
            EventControler:dispatchEvent(ChatEvent.CHAT_SEND_SP_REWARD);
            -- dump(FriendModel:getFriendList(),"11111111111111111111111111111111111")
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
            echo("-----FriendMainView:clickButtonPrevPage-------", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.page = 1;
    -- if self.getfriendListdata == false then
    FriendServer:getFriendListByPage(param, _callback);
end
--获得本地所有数据
function ChatModel:getAllChatdata()
    local tableName = FuncChat.PLAYERNAME
    local tabNam = FuncChat.CONTENT
    local allplay = LSChat:getallData(tableName)
    local allcontent = LSChat:getallData(tabNam)
    local playtable = {}
    local index = 1
    local indey = 1
    for k,v in pairs(allplay) do
        -- dump(json.decode(v),"所有玩家详情数据",8)
        playtable[index] = json.decode(v)

        index = index + 1
    end
    for i=1,#playtable do
        for k,v in pairs(allcontent) do
            if tonumber(playtable[i].uid) == tonumber(k)  then
                playtable[i].chatContent = json.decode(v)
            end
        end
    end


    -- for k,v in pairs(allcontent) do
    --     dump(json.decode(v),"所有玩家聊天详情数据",8)
    --     echo("=====k=====",k)
    -- end
    -- dump(playtable,"=====所有玩家聊天详情数据====",8)

    self.privateMessage = playtable


    for k,v in pairs(self.privateMessage) do
        v.isread = true
    end
    --[[
    local userID = LS:pub():get(StorageCode.chat_userID,nil)
    if userID == UserModel:uid() then
        for i=1,#self.typedata do
            -- echo("=================",UserModel:uid()..self.typedata[i])
            local data = LS:pub():get(UserModel:uid()..self.typedata[i],nil)
            -- echo("============self.typedata[i]===========",self.typedata[i])
            if data ~= nil then
                -- dump(data,"55555555555555555555")  
                if i == 1 then
                    -- self.worldMessage = json.decode(data) or {}
                elseif i ==2 then
                    -- self.leagueMessage = json.decode(data) or {}
                elseif i ==3 then 
                    self.privateMessage = json.decode(data) or {}
                elseif i ==4 then

                elseif i ==5 then
                    -- self.systeMessage = json.decode(data) or {}
                elseif i ==6 then
                    -- self.allMessage = json.decode(data) or {}
                end
            end
        end
    end
    --]]

    self:setfastPrivateMap()
end
---设置聊天对象
function ChatModel:setfastPrivateMap()
    -- self.fastPrivateMap
    if #self.privateMessage ~= 0 then
        for k,v in pairs(self.privateMessage) do
            local object = { };
            local _item = v
            -- self.fastPrivateMap[_item.rid] = {};
            object.online = true;
            -- //在线状态
            object.name = _item.name;
            -- //名字
            object.rid = _item.rid;
            -- //rid
            object.level = _item.level;
            -- //等级
            object.avatar = _item.avatar;
            -- //头像
            object.guildName = _item.guildName or "";
            object.uid = _item.uid
            -- //联盟
            object.chatContent = { };
            _item.isread = true
            object.chatContent = _item.chatContent;
            if self.fastPrivateMap[_item.rid] ~= nil then
                self.fastPrivateMap[_item.rid] = object
            end
        end
    end
end
function ChatModel:getchatStract()
    return self.typedata
end
---发送  玩家每次登陆游戏，默认显示系统发送的防诈骗信息
function ChatModel:sendMainTalk() 

    local  data = {
            param1 = GameConfig.getLanguage("#tid_Talk_101"),
            param2 = nil,
            time   = 1495765517,
            chattype   = 9,
        }
    self:updateSystemMessage(data)
        self:setAlldatainsertMessage(data)
    end

---插入所有数据聊天
function ChatModel:setAlldatainsertMessage(_item)

    if (#self.allMessage < 10) then
        table.insert(self.allMessage, _item);
    else
        table.remove(self.allMessage, 1);
        table.insert(self.allMessage, _item);
    end
    EventControler:dispatchEvent(ChatEvent.CHATMAIN_MESSAGE);
end
function ChatModel:getAllMessagedata()
    return  self.allMessage
end

-- //设置聊天对象,党一个消息是自己发出的的时候,需要确认聊天对象的身份
function ChatModel:setPrivateTargetPlayer(_player)
    self.privateTargetPlayer = _player;
end
-- //获取私聊对象
function ChatModel:getPrivateTargetPlayer()
    -- //如果没有私聊对象,默认选择对话队列中第一个
    if (self.privateTargetPlayer == nil) then
        self.privateTargetPlayer = self.privateMessage[1];
    end
    return self.privateTargetPlayer;
end
-- //获取免费聊天次数(世界聊天中)
function ChatModel:getFreeOfChatCount()
    local _sendCount = CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_WORLD_CHAT_COUNT);
    -- 获取最大免费世界聊天次数
    local _level = UserModel:level();

    local data = FuncDataSetting.getDataVector( "ChatNum" )
    local arrTab = {}
    local _index = 1
    for k,v in pairs(data) do
        arrTab[_index] = {tonumber(k),tonumber(v)}
        _index = _index + 1
    end

    for i=1,#arrTab do
        if _level >= arrTab[i][1]  then
            if arrTab[i][2] == -1 then
                return 1
            else
                local valuer = arrTab[i+1] 
                if valuer then
                    if _level < arrTab[i+1][2]  then
                        return arrTab[i][1] - _sendCount
                    end
                end
            end
        end
    end

    return 1
end
function ChatModel:getRMBOfChatCount()

    local _sendCount =  CountModel:getTlakItems( )
    return self:getChatCostNum() - _sendCount
end
function ChatModel:setChatTeamData(playdata)
    -- dump(playdata,"试炼组队聊天玩家数据")
    self.Teamplaydata = playdata
end
function ChatModel:getChatTeamData()
    return self.Teamplaydata
end
function ChatModel:setTeamMessage( data )
    self.teamMessage = data 
end
--获得队伍聊天数据
function ChatModel:getTeamMessage()
    return self.teamMessage
end
-- //获取世界聊天数据
function ChatModel:getWorldMessage()
    return self.worldMessage;
end
-- //获取联盟的聊天数据
function ChatModel:getLeagueMessage()
    return self.leagueMessage;
end
-- //获取缘伴的聊天数据
function ChatModel:getLoveMessage()
    return self.loveMessage
end

-- -- //删除缘伴的聊天数据
-- function ChatModel:removeLoveMessage()
--     self.loveMessage = {}
-- end

-- //删除缘伴的聊天数据
function ChatModel:removeLoveMessage()
    self.loveChatRecNum = 0
end

--获得缘伴返回的数量
function ChatModel:getLoveNum()
    return self.loveChatRecNum
end



-- //是否可以显示私聊信息提示
function ChatModel:isChatFlag()
    return not self.isPrivateMessageAchieve;
end
-- //获取私聊数据
function ChatModel:getPrivateMessage()
    self.isPrivateMessageAchieve = true;
    -- //标志获取了所有的私聊数据
    self:dispatchEventMainRedShow()
    return self.privateMessage;
end
function ChatModel:setChatPrivateisread(privaterid)
    local alldata = self.privateMessage
    for i=1,#alldata do
        if alldata[i].rid == privaterid then
            alldata[i].isread = true
        end
    end
end
function ChatModel:getChatPrivateRedNumber()
    local alldata = self.privateMessage
    local friendlist =   FriendModel:getFriendList()
    local ridtable = {}
    for k,v in pairs(friendlist) do
        if v.hasGetSp ~= nil then
            table.insert(ridtable,v._id)
        end
    end


    local number = 0
    if #alldata ~= 0 then
        for i=1,#alldata do
            if alldata[i].isread ~= nil then
                if alldata[i].isread == false then
                    number = number +  1
                else
                    if alldata[i].liwu ~= nil then
                        if alldata[i].liwu.hasSp == true then
                            number = number + 1
                        end
                    else
                        if alldata[i].tili ~= nil then
                            number = number + 1
                        end
                    end
                end
            else
                if alldata[i].liwu ~= nil then
                    if alldata[i].liwu.hasSp == true then
                        number = number + 1
                    else
                        if alldata[i].tili ~= nil then
                            number = number + 1
                        end
                    end
                end
            end
        end
    end
    return number
end

-- 删除聊天的数据
function ChatModel:RemoveChatprivateMessage(rid)
    if #self.privateMessage == 0 then
        return
    end
    for i=1,#self.privateMessage do
        if self.privateMessage[i].rid == rid then
            self.privateMessage[i] = nil
        end
    end
    local index = 1
    local newtable = {}
    for k,v in pairs(self.privateMessage) do
        -- if self.privateMessage[k] ~= nil then
            newtable[index] = v
            index = index + 1
        -- end
    end
    self.privateMessage = nil 
    self.privateMessage = newtable
end

function ChatModel:FenLeigetPrivateData()
    local notFriend = {}
    local frienbd = {}
    -- FriendModel:SendServergetFriendList()


    local friendlist =   FriendModel:getFriendList()-- LS:pub():get(UserModel:rid().."friend",nil)
    
    local allfriend = friendlist
    -- dump(allfriend,"好友列表",8)

    local index = 1
    if #allfriend ~= 0 then
        for k,v in pairs(allfriend) do
            local frd = {}
            local online = false
            if v.online ~= nil then
                online = v.online
            else
                if  v.userExt ~= nil then
                    if v.userExt.logoutTime == 0 then
                        online = true
                    end
                end
            end
            frd.avatar   = v.avatar
            frd.chatContent = {
            }
            frd.head = v.head or nil
            frd.guildName  = v.guildName or ""
            frd.index     = index
            frd.level     = v.level
            frd.name      = v.name
            frd.online    = online
            frd.rid       = v._id 
            frd.uid       = v.uid
            frd.isread    = true
            index         = index + 1
            -- self.FriendPrivateMap[v._id] = v
            -- table.insert(frienbd,frd)
            frienbd[v._id] = frd
            frienbd[v._id].lk = v.lk or 100
            frienbd[v._id].mk = v.mk 
            frienbd[v._id].liwu = {}
            frienbd[v._id].liwu = v
            frienbd[v._id].tili = v.tili


            self.fastPrivateMap[v._id] = frd
        end
    end


    ---临时列表的数据
    for i=1,#self.privateMessage do
        if allfriend ~= nil then

            if #allfriend ~= 0 then
                -- if #allfriend.friendList ~= 0 then
                local friendinfo = false
                    for k,v in pairs(allfriend) do  --.friendList) do
                        local fsce =  self:getRidBySec(v._id)
                        local psce =  self:getRidBySec(self.privateMessage[i].rid or self.privateMessage[i]._id)
                        if fsce == psce then
                            frienbd[v._id].chatContent = self.privateMessage[i].chatContent
                            frienbd[v._id].isread = self.privateMessage[i].isread or true
                            frienbd[v._id].time = self.privateMessage[i].time
                            if v.hasSp == nil then
                                frienbd[v._id].liwu = nil 
                            end
                            self.privateMessage[i].rid = v._id
                            for _k,_v in pairs(self.fastPrivateMap) do
                                if v.uid == _v.uid or v._id == _v.rid then
                                    self.fastPrivateMap[_k] = {}
                                    self.fastPrivateMap[_v.rid] = {}
                                    self.fastPrivateMap[_v.rid] = _v
                                end
                            end
                            -- frienbd[v._id].tili  = self.privateMessage[i].tili or nil
                            friendinfo = true
                        end
                        -- frienbd[v._id].chatContent = self.privateMessage[i].chatContent
                    end
                    if friendinfo  then
                        -- table.insert(frienbd,friendinfo)
                    else
                        if self.privateMessage[i].mk ~= nil then
                            self.privateMessage[i].mk = nil
                        end
                        if self.privateMessage[i].liwu ~= nil then
                            if self.privateMessage[i].liwu.mk ~= nil then
                                self.privateMessage[i].liwu.mk = nil
                            end
                        end
                        table.insert(notFriend,1,self.privateMessage[i])
                    end
                -- end
            else
                if self.privateMessage[i].mk ~= nil then
                    self.privateMessage[i].mk = nil
                end
                if self.privateMessage[i].liwu ~= nil then
                    if self.privateMessage[i].liwu.mk ~= nil then
                        self.privateMessage[i].liwu.mk = nil
                    end
                end
                notFriend[i] = self.privateMessage[i]
            end
        else
            if self.privateMessage[i].mk ~= nil then
                self.privateMessage[i].mk = nil
            end
            if self.privateMessage[i].liwu ~= nil then
                if self.privateMessage[i].liwu.mk ~= nil then
                    self.privateMessage[i].liwu.mk = nil
                end
            end
            notFriend[i] = self.privateMessage[i]
        end
    end
    if #allfriend == 0 then
        for k,v in pairs(allfriend) do
            table.insert(self.privateMessage,v)
        end
    end
    -- dump(frienbd,"sssssssssssssssssss")
    local indexs = 1
    local newfriendb = {}
    for k,v in pairs(frienbd) do
        newfriendb[indexs]= v
        indexs = indexs + 1
    end
    frienbd = newfriendb
    for k,v in pairs(notFriend) do
        if v.liwu ~= nil then
            v.liwu = nil
        end
        self.fastPrivateMap[v.rid] = v
    end
    -- dump(frienbd,"好友22222222222",8)
    -- dump(notFriend,"非好友",7)
    return frienbd,notFriend
end
function ChatModel:getRidBySec(rid,isgetRes)
    local findstring = "_"
    local numberuid = nil
    local index = string.find(rid,findstring)
    if index ~= nil then
        numberuid = string.sub(rid,index+1,-1)
    end
    if isgetRes then
        return string.sub(rid,0,index-1)
    end
    return tostring(numberuid)
end

function ChatModel:removemseeage(friendid)
    if self.fastPrivateMap[friendid] ~= nil then
        self.fastPrivateMap[friendid] = nil
    end
    for i=1,#self.privateMessage do
        local rid = self.privateMessage[i].rid
        if rid ~= nil then
            if friendid == rid then
                self.privateMessage[i] = nil
            end
        end
    end
    local index = 1
    for i=1,#self.privateMessage do
        if self.privateMessage[i] ~= nil then
            self.privateMessage[index] = self.privateMessage[i]
            index = index + 1
        end
    end
end
---获得好友数据
function ChatModel:ByFriendIDgetData( friendid )
    local frienbd,notFriend = self:FenLeigetPrivateData()
    -- dump(frienbd,"000000000000000")
    for i=1,#frienbd do
        if friendid == frienbd[i].rid then
            return frienbd[i]
        end
    end
    return nil
end
---判断临时按钮的红点和好友的红点（未聊天的信息）
function ChatModel:panduanfriengListRed()
    local frienbd,notFriend = self:FenLeigetPrivateData()
    local frienbdred = false
    local notFriendred = false
    if #frienbd ~= 0 then
        for i=1,#frienbd do
            if #frienbd[i].chatContent ~= 0 then
                for k,v in pairs(frienbd[i].chatContent) do
                    if v.isread == false then
                        frienbdred = true
                    end
                end
            end
        end
    end
    if #notFriend ~= 0 then
        for i=1,#notFriend do
            if #notFriend[i].chatContent ~= 0 then
                for k,v in pairs(notFriend[i].chatContent) do
                    if v.isread == false then
                        notFriendred = true
                    end
                end
            end
        end
    end
    -- dump(notFriend,"2222222222222222222")
    -- echo("===========11===============",notFriendred)
    return frienbdred,notFriendred
end


--是否有获得的礼物
function ChatModel:getLiwuRewrad()
    local liwusp = false
    -- local frienbd,notFriend = self:FenLeigetPrivateData()
    -- -- dump(frienbd,"好友数据")
    -- for k,v in pairs(frienbd) do
    --     if v.liwu ~= nil then
    --         if v.liwu.hasSp then
    --             liwusp = true
    --         end
    --     end
    --     if v.tili ~= nil then
    --         liwusp = true
    --     end
    -- end
   return liwusp
end

---获得奖励
function ChatModel:setLingQuTili(friendrid)
    local frienlist = FriendModel:getFriendList()
    for i=1,#frienlist do
        if friendrid == frienlist[i]._id then
            frienlist[i].tili = nil
        end
    end
end


function ChatModel:setPrivateMessageFriend(list)
    -- dump(self.privateMessage,"aaaaaaaaaaaaaaaaas")
    self.privateMessage = list
end
-- //更新队伍聊天数据
function ChatModel:updateTeamMessage(_item)
    -- _item.content = json.decode(_item.content)
    -- _item.zitype = 2
    _item.content = self:toStringExchangleImage(_item.content)
    _item.zitype = 4
    -- _item.content = json.decode(_item.content)
    if self.teamMessage ~= nil then
        if (#self.teamMessage < 50) then
            table.insert(self.teamMessage, _item);
        else
            table.remove(self.teamMessage, 1);
            table.insert(self.teamMessage, _item);
        end
        -- self:dispatchEventMainRedShow()
        EventControler:dispatchEvent(ChatEvent.TEAM_CHAT_CONTENT_UPDATE);
        -- //分发世界聊天内容更新事件
    end
end
-- //更新世界聊天数据
function ChatModel:updateWorldMessage(_item)
   

    _item.content = self:toStringExchangleImage(_item.content)
     -- _item.content = json.decode(_item.content)
    _item.zitype = 2
    if (#self.worldMessage < self.maxChatRecordCount) then
        table.insert(self.worldMessage, _item);
    else
        table.remove(self.worldMessage, 1);
        table.insert(self.worldMessage, _item);
    end
    self:dispatchEventMainRedShow()
    EventControler:dispatchEvent(ChatEvent.WORLD_CHAT_CONTENT_UPDATE);
    -- //分发世界聊天内容更新事件
end
-- //更新联盟聊天数据
function ChatModel:updateLeagueMessage(_item)
    -- dump(_item,"更新联盟聊天数据")
    _item.content = self:toStringExchangleImage(_item.content)
    _item.zitype = 3
    -- _item.content = json.decode(_item.content)
    if (#self.leagueMessage < self.maxChatRecordCount) then
        table.insert(self.leagueMessage, _item);
    else
        table.remove(self.leagueMessage, 1);
        table.insert(self.leagueMessage, _item);
    end
    -- //分发消息
    -- self:dispatchEventMainRedShow()
    EventControler:dispatchEvent(ChatEvent.LEAGUE_CHAT_CONTENT_UPDATE);
end

-- //更新缘伴聊天数据
function ChatModel:updateLoveMessage(_item)
    -- dump(_item,"更新联盟聊天数据")
    _item.content = self:toStringExchangleImage(_item.content)
    _item.zitype = 6
    -- _item.content = json.decode(_item.content)
    if (#self.loveMessage < self.maxChatRecordCount) then
        table.insert(self.loveMessage, _item);
    else
        table.remove(self.loveMessage, 1);
        table.insert(self.loveMessage, _item);
    end
    -- //分发消息
    self.loveChatRecNum = self.loveChatRecNum + 1
    EventControler:dispatchEvent(ChatEvent.LOVE_CHAT_CONTENT_UPDATE);
end




-- //返回所有私聊对象的rid
function ChatModel:getAllPrivateRid()
    local rids = { };
    for key, value in pairs(self.fastPrivateMap) do
        table.insert(rids, key);
    end
    return rids;
end
function ChatModel:removefastPrivateMap(playerRid)
    if self.fastPrivateMap[tostring(playerRid)] ~= nil then
        self.fastPrivateMap[tostring(playerRid)] = nil
    end
    -- dump(self.fastPrivateMap,"00000000000000000000000000000000000000000000000")
end
-- //更新私聊中的数据
function ChatModel:updatePrivateMessage(_item,otherplay,tili)
    -- //确认发送消息的人物身份
    
    _item.content = self:toStringExchangleImage(_item.content)
    -- _item.content = json.decode(_item.content)
    --echoError("========11111111============",UserModel:rid())
    _item.zitype = 5
    FriendModel:setChatDataInFriendData({_item})
    local _self_rid = UserModel:rid();
    local _rid = nil;
    local heads = nil;
    if (_item.rid ~= _self_rid) then -- //如果发送消息的人不是自己
        _rid = _item.rid;
        heads = _item.head
    else
        if self.privateTargetPlayer ~= nil then
            _rid = self.privateTargetPlayer.rid;
        else
            return
        end
        -- //否则,取出目标对象
    end

    local uid = self:getRidBySec(_rid)    
    local  object = nil
    for k,v in pairs(self.fastPrivateMap) do
        if uid == v.uid or _rid == v.rid then
            object = v
        end
    end


    if (object ~= nil) then
        -- //插入相关人物的对话队列,并更换聊天的顺序
        if (_item.rid ~= _self_rid) then
            _item.isread = false   ---是否读取
            object.isread = false
            object.name = _item.name;
        end
        local number = #object.chatContent
        if number >= FuncChat.seaveNumTalk() then
            table.remove(object.chatContent,1);
        end
        object.time = TimeControler:getServerTime()
        object.online = true
        if heads ~= nil then
            object.head = heads
        end
        local newchatContent = table.copy(object.chatContent)

        table.insert(object.chatContent, _item);
        self.fastPrivateMap[tostring(_rid)] = object
        local index = 1
        self.privateMessage = {}
        for k,v in pairs(self.fastPrivateMap) do
            self.privateMessage[index] = v
            index = index + 1
        end
        _item.isread = false
        table.insert(newchatContent, _item);
        self:insertTextOnLocal(uid,newchatContent)
    else
        local object = { };
        local uid = self:getRidBySec(_item.rid)
        object.online = true;
        -- //在线状态
        object.name = _item.name;
        -- //名字
        object.rid = _item.rid;
        -- //rid
        object.level = _item.level;
        -- //等级
        object.avatar = _item.avatar ;
        -- //头像
        object.guildName = _item.guildName or _item.name or "";
        object.head = _item.head;
        -- //联盟
        object.chatContent = {};
        --时间
        object.time = TimeControler:getServerTime()
        --体力
        -- object.tili = tili  
        object.uid = uid;
        _item.isread = false
        object.isread = false
        object.chatContent[1] = _item;
        self.fastPrivateMap[_item.rid] = object;
        table.insert(self.privateMessage, 1,object);
        self:insertPlayerOnLocal(object)
        object.chatContent[1].isread = true
        self:insertTextOnLocal(uid,object.chatContent)
    end
    -- dump(self.privateMessage,"55555555555555555",6)


    -- //分发私聊事件
    self.isPrivateMessageAchieve = false;
    EventControler:dispatchEvent(ChatEvent.PRIVATE_CHAT_CONTENT_UPDATE);
    -- //发起红点事件
    -- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, {
    --     redPointType = HomeModel.REDPOINT.LEFTMARGIN.CHAT,
    --     isShow = true,
    -- } );
    self:dispatchEventMainRedShow()
end

---私聊红点
function ChatModel:getPrivateDataRed()
    -- dump(self.privateMessage,"私聊数据========",6)
    for k,v in pairs(self.privateMessage) do
        if  not v.isread then
            return true
        end
    end
    return false
end



function ChatModel:getIconNmae( iconname )
    local imagename = ""
    local icontable =  self.biaoqingtable
    for k,v in pairs(icontable) do
        if v == iconname then
            imagename = k
        end
    end
    local path = "chat/"
    if imagename ~= "" then
        imagename  = path..imagename..".png"
    end
    -- echo("=======imagename======",imagename)
    return imagename

end
function ChatModel:toStringExchangleImage(text)

    -- echo("====111111=====",text)
    local str = text ---"<kaishi1>时间等会三<ksj>sdsad<kaishi2><kaishi3>"
    local newresultObj = {}
    local file = true
    local _x = 0
    while file do   
        local index = string.find(str,"%[") 
        local indey = string.find(str,"%]") 
        if string.len(str) ~= 0 then
            _x = _x + 1
            if index ~= nil and indey ~= nil  then
                if index == 1 then
                -- local newstr = string.sub(str,0,index)
                    local newstr = string.sub(str,index+1,indey-1)
                    -- local tables = {}
                    local icomname = self:getIconNmae( newstr )
                    if icomname ~= "" then
                        str = string.gsub(str, newstr, icomname);
                    end
                    newresultObj[_x] = string.sub(str,0,indey)
                    str = string.sub(str,indey+1)
                else
                    local newstr = string.sub(str,0,index-1)
                    newresultObj[_x] = newstr
                    str = string.sub(str,index)
                end
            else
                newresultObj[_x] = str
                file = false 
            end
        else
            file = false 
        end
    end
    local newStr = ""
    for i=1,#newresultObj do
        newStr = newStr..newresultObj[i]
    end
    return newStr
end
function ChatModel:dispatchEventMainRedShow()
    ---主城红点显示事件
    EventControler:dispatchEvent(ChatEvent.SHOW_RED_TRACK)

        -- HomeEvent.RED_POINT_EVENT, {
        -- redPointType = HomeModel.REDPOINT.LEFTMARGIN.CHAT,
        -- isShow = true
        -- })

end
-- //更新聊天对象的在线状态
function ChatModel:updatePrivateOnlineState(players)
    for _index = 1, #players do
        local player = players[_index];
        local object = self.fastPrivateMap[player._id];
        object.online = player.userExt.logoutTime == 0;
    end
end
-- //向私聊数据队列中接入一个待聊天的对象
function ChatModel:insertOnePrivateObject(_player)
    -- //先查找是否有这个对象

    --dump(_player,"先查找是否有这个对象")
    -- dump(self.fastPrivateMap,"2222222")
    -- dump(self.privateMessage,"333333333333")
    local player = self.fastPrivateMap[_player.rid];
    -- local friend,notfrind = self:FenLeigetPrivateData() 
    self.privateTargetPlayer = _player;
    if (player ~= nil) then
        -- local index = table.indexof(self.privateMessage, player);
        -- echo("==========index============",index)
        --     if (index > 1 ) then
        --         table.remove(self.privateMessage, index);
        --         table.insert(self.privateMessage, player);
        --     end
        
    else
        -- local number = #self.privateMessage - #friend
        -- echo("=======number================",#self.privateMessage,#friend)
        player = { };
        player.online = _player.online  or true;
        player.name = _player.name;
        player.level = _player.level;
        player.avatar = _player.avatar;
        player.rid = _player.rid;
        player.head = _player.head;
        player.uid = _player.uid or self:getRidBySec(_player.rid)
        player.ability = _player.ability or 1000;
        player.isRobot = _player.isRobot or false;
        player.isread = true
        -- player.isread = false
        player.guildName = _player.guildName or _player.name or "";
        player.chatContent = { };
        self.fastPrivateMap[_player.rid] = player
        table.insert(self.privateMessage, 1,player);
        self:insertPlayerOnLocal(player)

    end
    -- dump(self.privateMessage,"0000000")
end
-- //清理私聊对象队列,清理目标为发起了聊天但是却没有真正聊天的对象,程序应该在退出私聊页面时调用一次
function ChatModel:clearPrivateQueue()
    for _index = #self.privateMessage, 1, -1 do
        local player = self.privateMessage[_index];
        if (#player.chatContent <= 0) then
            self.fastPrivateMap[player.rid] = nil;
            -- //在快速查找表中删除该玩家
            table.remove(self.privateMessage, _index);
            -- //从对话队列中删除该玩家
        end
    end
    self.privateTargetPlayer = nil;
    -- //清除聊天对象
end
function ChatModel:getattribute()
    local function callback(param)
        -- if (param.result ~= nil) then 
        -- end
        -- dump(param.result,"获得聊天设置属性")
        -- self.chatattribute
        local data = param.result.data.data
        if data ~= nil then



        end
    end
    
end

function ChatModel:setSelectType(chattype)
    self.selectIndex = chattype
end
function ChatModel:getSelectType()
    return self.selectIndex
end
---获取保存100条的数据
function ChatModel:getSeavDatanumber()
   return 100
end
function ChatModel:saveLandData()
    -- WindowControler:globalDelayCall(function ()
    --     self:Savedatalocal()  
    -- end,0.2)
end

function ChatModel:Savedatalocal()  ---本地数据保存
    local world =  nil --self:getWorldMessage()
    local League = nil --self:getLeagueMessage()
    local private = self:getPrivateMessage()
    local system = nil --self:getSystemMessage()
    local alldata = nil -- self:getAllMessagedata()
    local team = nil
      -- dump(private,"2222222222222222222")
      -- LS:pub():get("worldchatdata",nil)
      -- LS:pub():set("worldchatdata",world)
    local typedata = ChatModel:getchatStract()
    local data = {
        [1] = world,
        [2] = League,
        [3] = private,
        [4] = team,
        [5] = system,
        [6] = alldata,
    }
   LS:pub():set(StorageCode.chat_userID,UserModel:uid())   --保存玩家uid
    -- for i=1,#typedata do
    --     if i == 3 then
            local value = typedata[3]
            -- if data[i] ~= nil then
                LS:pub():set(UserModel:uid()..value,json.encode(data[3]))
    --         end
    --     end
    -- end

end
function ChatModel:shareData(event)
    -- dump(event.params,"分享数据")
    local _type = event.params._type
    local typeid = ChatShareControler.ChatSharetype[_type]
    local subtypes = ChatShareControler.Chatsubtypes[event.params.subtypes]
    local data = event.params.data
    if typeid == nil then
        echo("=============传入的分享ID  is  不存在=================")
        return
    end
    if typeid == 1 then  ---私聊

    elseif typeid == 2 then --时装
        self:shareCharSkinData(2,subtypes,data)
    elseif typeid == 3 then--伙伴
        self:sharePartnerData(3,subtypes,data)
    elseif typeid == 4 then--战报
        self:shareBattleData()
    elseif typeid == 5 then---伙伴皮肤
        self:sharePartnerSkinData(5,subtypes,data)
    end

end

---伙伴皮肤
function ChatModel:sharePartnerSkinData(type,subtypes,data)
    if subtypes == 1 then    ---系统

    elseif subtypes == 2 then --世界
        ChatServer:sendChatShareWorld(type,data)
    elseif subtypes == 3 then  --公会

    elseif subtypes == 4 then  --好友
        local number = FriendModel:getFriendCount()
        if number ~= 0 then
            FriendViewControler:forceShowFriendList(type,data,1)
        else
            WindowControler:showTips(GameConfig.getLanguage("#tid_chat_001"))
        end
    elseif subtypes == 5 then   --私聊

    end

end
--战报
function ChatModel:shareBattleData()
    if subtypes == 1 then

    elseif subtypes == 2 then

    elseif subtypes == 3 then

    elseif subtypes == 5 then

    end
end
--伙伴
function ChatModel:sharePartnerData()
    if subtypes == 1 then

    elseif subtypes == 2 then

    elseif subtypes == 3 then

    elseif subtypes == 5 then

    end
end
 --时装
function ChatModel:shareCharSkinData(type,subtypes,data)

    if subtypes == 1 then

    elseif subtypes == 2 then
        ChatServer:sendChatShareWorld(type,data)
        -- ChatServer:sendChatShareWorld(type,data)
     elseif subtypes == 3 then
    elseif subtypes == 4 then
        -- data.type = type
        local number = FriendModel:getFriendCount()
        if number ~= 0 then
            FriendViewControler:forceShowFriendList(type,data,1)
        else
            WindowControler:showTips(GameConfig.getLanguage("#tid_chat_001"))
        end
    elseif subtypes == 5 then

    end
end



function ChatModel:ToDealWithShare(_item)
    -- dump(_item,"11111111111111111111111111111111111")
    local callback = nil
    local content = nil

    if _item.type == ChatShareControler.ChatSharetype.CHAT_TYPE_TEXT then  ---私聊
        content,callback = self:jieXiGuildChatText(_item)
    elseif _item.type == ChatShareControler.ChatSharetype.CHAT_TYPE_GARMENT then  --时装
        content,callback = self:charskin(_item)
    elseif _item.type == ChatShareControler.ChatSharetype.CHAT_TYPE_PARTNER then  ---伙伴时装
        content,callback = self:partnerskin(_item)
    elseif _item.type == ChatShareControler.ChatSharetype.CHAT_TYPE_PVP then

    elseif _item.type == ChatShareControler.ChatSharetype.CHAT_TYPE_PARTNER_SKIN then

    elseif _item.type == FuncChat.CHAT_T_TYPE.shareArtifact then
        content,callback = self:aAndfShare(_item,1)
    elseif _item.type == FuncChat.CHAT_T_TYPE.shareTreasure then
        content,callback = self:aAndfShare(_item,2)
    elseif _item.type == FuncChat.CHAT_T_TYPE.shareTreasure then
        content,callback = self:guildExportInvitation(_item)
    end  
    return content,callback
end

--仙盟探索的邀请跳转
function ChatModel:guildExportInvitation()
    local content = nil
    local callback = function () end

    local contentArr =  json.decode(_item.content)

    local index,indey =  string.find(contentArr.des,"_link")
    if index == nil and indey == nil then
        content = _item.content
        return  content,callback
    end
    content =  string.sub(contentArr.des,0,index - 1)
    callback= function ( )
        local minID = contentArr.id
        --TODO
        -- 跳转到仙盟探索的界面

    end
    return content,callback
end


--神器和法宝分享
function ChatModel:aAndfShare(_item,_type)
    local  content = nil
    local callback = function () end

    local index,indey =  string.find(_item.content,"_link")
    if index == nil and indey == nil then
        content = _item.content
        return  content,callback
    end
    content =  string.sub(_item.content,0,index - 1)
    callback= function ( )
        if _type == 1 then  --神器
            local data = _item.linkData
            WindowControler:showWindow("ArtifactShareView",data)
        elseif _type == 2 then   --法宝
            local data = _item.linkData
            WindowControler:showWindow("TreasureShareView",data)
        end
    end
    return content,callback


end

-- 跳转到仙盟副本
function ChatModel:jieXiGuildChatText(_item)
    -- dump(_item,"解析后的数据结构111")
    local  content = nil
    local callback = function () end

    local index,indey =  string.find(_item.content,"_link")
    if index == nil and indey == nil then
        content = _item.content
        return  content,callback
    end
    content =  string.sub(_item.content,0,index - 1)
    callback= function ( )
        if _item.linkType == FuncChat.EventEx_Type.guildAct then
            self:jieXiGuildActChatText()
        elseif _item.linkType == FuncChat.EventEx_Type.guildBoss then
            GuildControler:showGuildBossUI()
        end
    end
    return content,callback
end

-- 跳转到仙盟酒家
function ChatModel:jieXiGuildActChatText()
    -- if not GuildModel:isInGuild() then
    --     return
    -- end
    -- local sysName = FuncCommon.SYSTEM_NAME.GUILDACTIVITY
    -- local open = FuncCommon.isSystemOpen(sysName)
    -- if not open then
    --     WindowControler:showTips("未开启不能跳转")
    --     return 
    -- end
    -- local function callBack()
    --     WindowControler:showWindow("GuildActivityMainView")
    -- end
    -- GuildActMainModel:requestGVEData(callBack)
    GuildActMainModel:enterGuildActMainView()
end


function ChatModel:charskin(_item)
    -- dump(_item,"1111111111111111111111111111111111")
    
    local index = string.find(_item.content,"#")
    local indey = string.find(_item.content,"<")
    local id = nil
    -- echo("======index==========================",index,indey)
    if index ~= nil then
        if indey ~= nil then
            id = string.sub(_item.content,1,index-1)
            -- echo("11111111111111111111111111")
        end
    else
        id = tonumber(_item.content)
    end
    -- echo("========id=====================",_item.content,id)
   
    -- local id = tonumber(_item.content)

    local content = nil
    local avatar = nil
    if _item.rid == UserModel:rid() then
        avatar = UserModel:avatar()
        local houzui = ""
        if FuncChar.getCharSex(avatar) == 1 then --男
            houzui = "战袍"
        else
            houzui = "霓裳"
        end
         local skinStr = FuncGarment.getGarmentName(id,avatar)
        content = "成功分享【<color = fc0000>"..skinStr.."<->】"..houzui
    else
        
        if index ~= nil then
            avatar = string.sub(_item.content,index+1,indey-1)
        end
        local houzui = ""
        if FuncChar.getCharSex(avatar) == 1 then --男
            houzui = "战袍"
        else
            houzui = "霓裳"
        end
         local skinStr = FuncGarment.getGarmentName(id,avatar) 
        -- echo("=======sex========houzui================",type(sex),sex,houzui)
        content = "查看分享【<color = fc0000>"..skinStr.."<->】"..houzui
        -- echo("========sex=====================",sex)
    end

    callback = function ( )
        echo("=========主角时装id===sex======",id,avatar)
        EventControler:dispatchEvent(GarmentEvent.GARMENT_SHARE_UI ,{id = id,sex = avatar})
    end
    if _item.rid ~= UserModel:rid() then
        return content,callback
    else
        callback = function () end
        return content,callback

    end

end
function ChatModel:partnerskin(_item)
    local callback = nil
    local content = nil
    local skinStr = FuncPartnerSkin.getSkinName(_item.content)
    local id = tonumber(_item.content)
    if _item.rid == UserModel:rid() then
        content = "成功分享奇侠【<color = fcff00>"..skinStr.."<->】皮肤"
    else
        content = "查看分享奇侠【<color = fcff00>"..skinStr.."<->】皮肤"
    end
    callback = function ( )
        echo("=========伙伴时装id=========",id)
        EventControler:dispatchEvent(PartnerSkinEvent.SKIN_FRINED_SHOW_EVENT ,{id = id})
    end
    if _item.rid ~= UserModel:rid() then
        return content,callback
    else
        callback = function () end
        return content,callback
    end
end




--[[
时间问题" :{
   "day"   = 14
   "hour"  = 15
   "isdst" = false
   "min"   = 4
   "month" = 6
   "sec"   = 11
   "wday"  = 1 -- 
   "yday"  = 165
   "year"  = 2017
]]
function ChatModel:setServerTime(time)
    self.servertime = time
end
function ChatModel:getServerTimes()
    return self.servertime or 0 
end
---到时删除数据
function ChatModel:removeAllTimeData()
    local landserverTime = LS:pub():get("RemoveChatData"..UserModel:uid(),nil)
    local oldserverTime = nil
    if landserverTime ~= nil then
        oldserverTime = os.date("*t",landserverTime)
    end
    local serverTime  = TimeControler:getServerTime()
    local timeData = os.date("*t",serverTime)
    -- dump(timeData,"时间问题")
    if timeData.wday == 2 then
        if timeData.hour >= 4 then
            if  oldserverTime == nil then
                self.privateMessage = {}
                LS:pub():set("Private"..UserModel:uid(),nil)
                LS:pub():set("RemoveChatData"..UserModel:uid(),serverTime)
            else
                if oldserverTime.month == timeData.month  then
                    if  oldserverTime.day  == timeData.day then  

                    else
                        self.privateMessage = {}
                        LS:pub():set("Private"..UserModel:uid(),nil)
                        LS:pub():set("RemoveChatData"..UserModel:uid(),serverTime)
                    end
                else
                    self.privateMessage = {}
                    LS:pub():set("Private"..UserModel:uid(),nil)
                    LS:pub():set("RemoveChatData"..UserModel:uid(),serverTime)
                end
            end
        end
    end
end


function ChatModel:AddFriendAgreedsendmassege(_param)

    -- dump(_param.params.params,"加好友推送2928协议")
    -- local friendid = _param.params.params.data.rid
    if _param.params.params.data.type == 1 then
        local friendinfo = _param.params.params.data.data
        local shaoxia = GameConfig.getLanguage("tid_common_2001")
        if friendinfo ~= nil then
            local _item = {
                avatar  = friendinfo.avatar or 101,
                content = FuncChat.CHAT_STRING.friend,
                level   = friendinfo.level or 1,
                name    = friendinfo.name or shaoxia,
                rid    = friendinfo._id or friendinfo.rid,
                time    = TimeControler:getServerTime(),
                type    = 1,
                vip     = friendinfo.vip or 0,
                uid     =  friendinfo.uid,
            }
            self:updatePrivateMessage(_item)
            FriendModel:insertFriendData(friendinfo)
            self:getChatPrivateRedNumber()
        end
    else  ---删除好友
        local uid = _param.params.params.data.uid
        FriendModel:removeFriendUID( uid )
    end
end

function ChatModel:setPlayerIcon(_ctn,headid,avatarid ,size)
    -- echo("==========11111111======",headid,avatarid)

    local avatarId = avatarid --or UserModel:avatar()
    local iconids = headid --or UserModel:head()
    local iconid = iconids
    local icon = FuncUserHead.getHeadIcon(iconid,avatarId)
    icon = FuncRes.iconHero( icon )
    local iconSprite = display.newSprite(icon)
    local headMaskSprite = display.newSprite(FuncRes.iconOther("icon_other_bgMask1"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:setScale(0.2)
    local spritesico = FuncCommUI.getMaskCan(headMaskSprite,iconSprite)
    spritesico:setScale(size or 0.5)
    _ctn:addChild(spritesico,10)
    
end

--添加称号
function ChatModel:addCharTitle(_ctn,titleid)
    -- local titleid = TitleModel:gettitleids()
    if titleid ~= "" then
        local titleType = FuncTitle.gettitletype(titleid,"titleType")
        if titleType == FuncTitle.titlettype.title_limit then
            local titlesprite = FuncTitle.bytitleIdgetpng(titleid)
            local titlepng = display.newSprite(titlesprite)
            titlepng:setScale(0.5)
            _ctn:addChild(titlepng)
        end
    end
end

function ChatModel:sendplayerOnline()
    
    local Windowname =  WindowControler:getWindow( "ChatMainView" ) 
    if Windowname == nil then
        return 
    end
    ChatModel:sendMotched()
end

function ChatModel:sendMotched()
    -- local param = {rids = {}}
        local param = {}
        param.infos = {}
    
    local friendList =  FriendModel.friendList
    -- if #self.privateMessage ~= 0 then
    --     for i=1,#self.privateMessage do
    --         local rid = self.privateMessage[i].rid
    --         table.insert(param.rids,rid)
    --     end
    -- else
        for i=1,#friendList do
            local rid = friendList[i]._id
            if i <= 20 then
                param.infos[i] = {}
                param.infos[i].sec = self:getRidBySec(rid,true)
                param.infos[i].rid = rid
            end
        end
    -- end

    for i=1,#friendList do
        friendList[i].online = friendList[i].online or false
    end
    for i=1,#self.privateMessage do
        self.privateMessage[i].online = self.privateMessage[i].online or false
    end
    local function _callback(_param)
        -- dump(_param.result,"在线请求返回数据")
        if _param.result ~= nil then
            local onlinedata = _param.result.data.onlines
            local messagearr = {}
            if #onlinedata ~= 0 then
                if self.privateMessage ~= nil  and #self.privateMessage ~= 0 then
                    for x=1,#onlinedata do
                        for i=1,#self.privateMessage do
                            if self.privateMessage[i].rid == onlinedata[x] then
                                self.privateMessage[i].online = true
                            end
                        end
                    end
                end
                for i=1,#friendList do
                    for x = 1,#onlinedata do
                        if friendList[i]._id == onlinedata[x] then
                            friendList[i].online = true
                        end
                    end
                end
            end
            EventControler:dispatchEvent(ChatEvent.REFRESH_PLAYER_ONLOINE);
        end
    end

    ChatServer:sendPlayIsonLine(param,_callback)

end
function ChatModel:setSyetemdataStr(data)
    -- dump(data,"设置内容",8)
    local string = ""
    -- if data.chattype == nil then
    --     echo("===========系统不存在该 chattype===============")
    --     return 
    -- end

    if data.chattype == 1 then---系统
        -- local strMap = {}
        -- strMap[1] = data.param1
        -- local Partnerinfo =  FuncPartner.getPartnerById(data.param2)
        -- strMap[2] = GameConfig.getLanguage(Partnerinfo.name)
        string = self:getStrWithSwap(data)
        -- string = GameConfig.getLanguageWithSwap("#tid_Talk_102",unpack(strMap))
    elseif data.chattype == 2 then --世界聊天
        if data.type == 1 then 
            string = data.content--"<color = fc66cc00>"..data.name..":<->"..data.content
        elseif data.type == 2 then  --时装分享
            local callback = nil
            string,callback = self:charskin(data)
        elseif data.type == 3 then  --伙伴分享  
            string,callback = self:partnerskin(data)
        elseif data.type == 4 then  --队伍聊天
            string = data.content
        elseif data.type == 5 then   --语音
            string =  "一"--json.encode( data.voicedata )
        elseif data.type == 6 then   --仙盟邀请
            local info = json.decode(data.content)
            string = info.desc
        end
    elseif data.chattype == 3 then
        string = self:jieXiGuildChatText(data)
    elseif data.chattype == 4 then --队伍
        string = data.content
    elseif data.chattype == 5 then --私聊
        local callback = nil
        if data.type == 1 then
            string = data.content
        elseif data.type == FuncChat.EventEx_Type.voice then   --语音
            string = " "
        else
            string,callback = self:charskin(data)
        end
    elseif data.chattype == 9 then  ---本地系统推送
        string = data.param1
        -- string = self:parseRichText(string)
    end
    return string

end
--[[
{
  "method": 3520,
  "params": {
    "data": {
      "params": {
        "name": "劲血海之神",
        "rank": 6,   --申到了第几名
        "opponentType": 2,
        "opponentRid": "6"
      },
      "type": 10,   --lanternId
      "time": 1505875456
    },
    "serverTime": 1505875456046
  }
}
    {
        "horsetext"=0,
        "id"="1",
        "text"="#tid1701",
        "typeArr" = { 
            [1]="0",
            [2]="1",
        },
    },
--]]
function ChatModel:getStrWithSwap(data)
    local _str = nil
    local strMap = {}
    local lanternAlldata = FuncLamp.getLamp()
    local lanternId = data.type
    local params = data.params
    local lanterndata =  lanternAlldata[tostring(lanternId)]
    local systemname = FuncLamp.id_type[tonumber(lanternId)]
    if systemname == FuncCommon.SYSTEM_NAME.LOTTERY then
        strMap[1] = params.name
        local Partnerinfo =  FuncPartner.getPartnerById(params.itemId)
        strMap[2] = GameConfig.getLanguage(Partnerinfo.name)
    elseif systemname == FuncCommon.SYSTEM_NAME.PVP  then
        strMap[1] = params.name
        if params.opponentType ~= FuncPvp.PLAYER_TYPE_ROBOT then 
            strMap[2] = params.opponentName
        else
            if params.opponentRid then
                 local robitId = FuncPvp.genRobotRid(params.opponentRid);
                strMap[2] = FuncAccountUtil.getRobotName(robitId)
            end
        end
        if params.rank then
            strMap[3] = params.rank
        end
    elseif systemname == FuncCommon.SYSTEM_NAME.TOWER  then
        strMap[1] = params.name
        strMap[2] = params.floor
    elseif systemname == FuncCommon.SYSTEM_NAME.GUILD then
        strMap[1] = params.name
        strMap[2] = params.level
    elseif systemname == FuncCommon.SYSTEM_NAME.CROSSPEAK then
        strMap[1] = params.name
        local num  = params.segment
        strMap[2] = Tool:transformNumToChineseWord( num )
    end

   _str = GameConfig.getLanguageWithSwap(lanterndata.text,unpack(strMap))
   return _str
end


--设置已读语音类型
function ChatModel:setisvoiceData(_item,fileID)
    -- local fileID = _item.zitype
    -- dump(_item,"===设置已读语音类型====",3)
    if _item.zitype ~= 5 then  --非私聊的数据
        for i=1,#self.worldMessage do
            if self.worldMessage[i].type == FuncChat.EventEx_Type.voice then
                local contents =  json.decode(self.worldMessage[i].content)
                if contents.fileID == fileID then
                    self.worldMessage[i].isvoice = true
                end
            end
        end
        for i=1,#self.teamMessage do
            if self.teamMessage[i].type == FuncChat.EventEx_Type.voice then
                local content=  json.decode(self.teamMessage[i].content)
                if content.fileID == fileID then
                    self.teamMessage[i].isvoice = true
                end
            end
        end
        --仙盟聊天数据
        for i=1,#self.leagueMessage do
            if self.leagueMessage[i].type == FuncChat.EventEx_Type.voice then
                local content=  json.decode(self.leagueMessage[i].content)

                if content.fileID == fileID then
                    self.leagueMessage[i].isvoice = true
                end
            end
        end

        for i=1,#self.loveMessage do
            if self.loveMessage[i].type == FuncChat.EventEx_Type.voice then
                local content=  json.decode(self.loveMessage[i].content)
                if content.fileID == fileID then
                    self.loveMessage[i].isvoice = true
                end
            end
        end

    else  ---私聊数据
        for i=1,#self.privateMessage do
            local chatContent = self.privateMessage[i].chatContent
            if #chatContent ~= 0 then
                for _x=1,#chatContent do
                    local contents = chatContent[_x]
                    if contents.type == FuncChat.EventEx_Type.voice then
                        local voicetable = json.decode(contents.content)
                        if voicetable.fileID == fileID then
                            self.privateMessage[i].chatContent[_x].isvoice = true
                        end
                    end
                end
            end
        end
    end
end




--自动播放语音
function ChatModel:automaticallyPlayVoice(systemindx)
    local voiceList = nil
    local _index = systemindx + 3   --差值
    if _index == 9 then
        _index = 8
    end
    local voicename = self.setchatsetlistindex[_index]
    if voicename == nil then
        return nil
    end

    -- dump(self.setchatVoicelist,"获取设置情况 =======")
    local valuer = self.setchatVoicelist[voicename]
    if valuer == 0  then
        return nil
    end
    local chatdata = nil
    if systemindx == FuncChat.CHAT_T_TYPE.world then
        chatdata = self.worldMessage
    elseif  systemindx == FuncChat.CHAT_T_TYPE.tream then
        chatdata = self.leagueMessage
    elseif  systemindx == FuncChat.CHAT_T_TYPE.troop  then
        chatdata = self.teamMessage
    elseif  systemindx == FuncChat.CHAT_T_TYPE.voice  then
        chatdata =  self.loveMessage 
    end
    -- echo("=====--自动播放语音 --========",systemindx)
    self.allVvoiceList = nil
    if chatdata ~= nil then
        self.allVvoiceList = self:cacheVoiceData(chatdata)
        self.allIndex = 1
        self:playVoice(self.allVvoiceList,self.allIndex)
    end

    -- return voiceList

end

function ChatModel:playVoice(voiceList,index)
    -- dump(voiceList,"自动播放语音数据",8)
    echo("=====--自动播放语音 --========",index)
    --播放所有语音
    self:setopVoice()
    local Windownames =  WindowControler:getWindow( "ChatMainView" )
    if Windownames then
        if voiceList ~= nil then
            if #voiceList ~= 0 then
                local _item = voiceList[index]
                if _item ~= nil then
                    if _item.type == FuncChat.EventEx_Type.voice then
                        local content = json.decode(_item.content)
                        self:setisvoiceData(_item,content.fileID)
                        ChatServer:onClickPlay(content.fileID)
                        local time = content.time
                        WindowControler:globalDelayCall(function ()
                            self:playVoice(voiceList,index + 1)
                        end,time+3.0)
                    end
                end
            end
        end
    end
end

-- 播放完成
function ChatModel:againeplayVoide()
    -- echo("====播放完成回调======")
    -- if self.allVvoiceList ~= nil then
    --     self.allIndex = self.allIndex + 1
    --     self:playVoice(self.allVvoiceList,self.allIndex)
    -- end
end




--缓存语音列表
function ChatModel:cacheVoiceData(chatdata)


    local voiceList = {}
    if #chatdata == 0 then
        return voiceList
    end
    for i=1,#chatdata do
        if chatdata[i].type == FuncChat.EventEx_Type.voice then  --语音
            if chatdata[i].isvoice == nil or chatdata[i].isvoice == false then
                table.insert(voiceList,chatdata[i])
            end
        end
    end
    -- dump(voiceList,"voice- 语音缓存列表") ---世界，仙盟，队伍
    return voiceList
end

--私聊播放语音
function ChatModel:playPrivate(rid)
    if rid == nil then
        return
    end
    local _index = 8 
    local voicename = self.setchatsetlistindex[_index]
    local valuer = self.setchatVoicelist[voicename]
    if valuer == 0 then
        return
    end
    local chatdata = self.privateMessage

    local playuid = self:getRidBySec(rid)
    local voiceList = {}

    -- dump(chatdata,"222222222222222222",8)
    for k,v in pairs(chatdata) do
        local uid = self:getRidBySec(v.rid)
        if playuid  == uid then
            -- if v.type == FuncChat.EventEx_Type.voice then  --语音
                local data = v.chatContent 
                if data ~= nil then
                    for i=1,#data do
                        if data[i].type == FuncChat.EventEx_Type.voice then  --语音
                            if data[i].isvoice == nil or data[i].isvoice == false then
                                if data[i].rid ~= UserModel:rid() then
                                    table.insert(voiceList,data[i])
                                end
                            end
                        end
                    end
                end
            -- end
        end
    end
    -- dump(voiceList,"voice- 私聊语音缓存列表")


    local index = 1
    self:playVoice(voiceList,index)
    -- return voiceList
end
--[[
    - "avatar" = 104
- "chattype" = 2
- "level" = 1
- "name" = "解无痕蛊"
- "rid" = "dev9_147"
- "time" = 1509173987
- "type" = 5
- "vip" = 5
- "voicedata" = {
- "content" = "有事我想去哪。"
- "fileID" = "304f020100044830460201000408677a79672d
64657602037a13f502041c4c977b020459f42ae30420646665393339326232
62376336313663373637613361646433323036373861320201000201000400
"
- "time" = 3
- "voice" = true
- }
- "zitype" = 2
- }


]]


function ChatModel:setopVoice()
    --停止播放所有语音
    ChatServer:stopPlayFile()
end



function ChatModel:byPlayidGetData(rid,_callback)

    local function callback(_param)
        -- dump(self.privateMessage,"2222222",7)
        if (_param.result ~= nil) then
            -- dump(_param.result,"离线玩家发送的语音")
            local privateMessagedata =  self.privateMessage
            if #privateMessagedata ~= 0 then
                local contdata = _param.result.data.data
            --     local playuid = _param.result.data.rid
                local otheruid = self:getRidBySec(rid)
                for k,v in pairs(privateMessagedata) do
                    local uid = self:getRidBySec(v.rid)
                    if otheruid  == uid then
                        local num = #contdata
                        for _x=1,num do
                            local dataid = self:getRidBySec(contdata[_x].rid)
                            local isserve = false
                            if otheruid == dataid then
                                local chatContent = self.privateMessage[k].chatContent
                                for i=1,#chatContent do
                                    if chatContent[i].time == contdata[_x].time then
                                        isserve = true
                                    end
                                end
                                if not isserve then
                                    table.insert(self.privateMessage[k].chatContent,contdata[_x])
                                    ChatModel:insertTextOnLocal(uid,self.privateMessage[k].chatContent)
                                    -- ChatServer:sendtxttranslation(contdata[_x])
                                end
                            end
                        end
                    end
                end
            end
        end
        -- dump(self.privateMessage,"333333333333333",7)
        _callback()
        self.getnotonlindata[rid] = true
    end

    local param = {
        target = UserModel:rid(),
    }
    -- _callback()
    if self.getnotonlindata[rid] == nil or self.getnotonlindata[rid] == false then
        ChatServer:sendgetnotline(param,callback)
    else
        _callback()
    end
end


function ChatModel:insertVoiceTXT(fileID,content)

    --世界聊天数据
    local isworldvoice = false
    for i=1,#self.worldMessage do
        if self.worldMessage[i].type == FuncChat.EventEx_Type.voice then
            local contents =  json.decode(self.worldMessage[i].content)
            if contents.fileID == fileID then
                contents.content = content
                self.worldMessage[i].content = json.encode(contents)
                isworldvoice = true
            end
        end
    end

    ---队伍聊天数据
    local isteamvoice = false
    for i=1,#self.teamMessage do
        if self.teamMessage[i].type == FuncChat.EventEx_Type.voice then
            local content=  json.decode(self.teamMessage[i].content)
            if content.fileID == fileID then
                content.content = content
                self.teamMessage[i].content = json.encode(content)
                isteamvoice = true
            end
        end
    end
    local isleaguevoice = false
    --仙盟聊天数据
    for i=1,#self.leagueMessage do
        if self.leagueMessage[i].type == FuncChat.EventEx_Type.voice then
            local content=  json.decode(self.leagueMessage[i].content)
            if content.fileID == fileID then
                content.content = content
                self.leagueMessage[i].content = json.encode(content)
                isleaguevoice = true
            end
        end
    end

    local isprivatevoice = false
    for i=1,#self.privateMessage do
        local chatContent = self.privateMessage[i].chatContent
        if #chatContent ~= 0 then
            for _x=1,#chatContent do
                local contents = chatContent[_x]
                if contents.type == FuncChat.EventEx_Type.voice then
                    local voicetable = json.decode(contents.content)
                    if voicetable.fileID == fileID then
                        voicetable.content = content
                        self.privateMessage[i].chatContent[_x].content = json.encode(voicetable)
                        local newcontent = self.privateMessage[i].chatContent
                        local chatrid = self.privateMessage[i].rid
                        local uid = self:getRidBySec(chatrid)
                        self:insertTextOnLocal(uid,newcontent)
                        isprivatevoice = true
                    end
                end
            end
        end
    end

    if isprivatevoice then

        EventControler:dispatchEvent(ChatEvent.PRIVATE_CHAT_CONTENT_UPDATE);
    end

    if isleaguevoice then
        -- EventControler:dispatchEvent(ChatEvent.TEAM_CHAT_CONTENT_UPDATE);
    end

    if isworldvoice then
       EventControler:dispatchEvent(ChatEvent.WORLD_CHAT_CONTENT_UPDATE);
    end
    
    if isteamvoice then
        EventControler:dispatchEvent(ChatEvent.TEAM_CHAT_CONTENT_UPDATE);
    end

end

function ChatModel:setissendFriend(_file)
   self.issendFriend = _file
end


function ChatModel:setPrivesHeard(data)
    if data  == nil or #data == 0 then
        return data
    end
    local  _rid = UserModel:rid();
    local playuid = self:getRidBySec(_rid)
    local head = nil
    if type(data) == "table" then
        local num = #data[1]
        for i=num,1,-1 do
            local otheruid = self:getRidBySec(data[1][i].rid)
            if playuid ~= otheruid then
                local frienddata = FriendModel:getFriendDataByID(data[1][i].rid)
                if frienddata ~= nil then
                    -- data[1][i].head = head
                    if frienddata.head ~= nil then
                        data[1][i].head = frienddata.head
                    end
                end
            end
        end
    end
   
    return data
end
function ChatModel:setfriendListHead(data)
    if data  == nil then
        return data
    end
    local  _rid = UserModel:rid();
    for k,v in pairs(data) do
        local head = nil
        local playuid = self:getRidBySec(v.rid)
        local chatcontent = v.chatContent
        for i=#chatcontent,1,-1 do
           local otheruid = self:getRidBySec(chatcontent[i].rid)
            if playuid == otheruid then
                if head == nil then
                    local frienddata = FriendModel:getFriendDataByID(v.rid)
                    head = chatcontent[i].head
                    if head == nil then
                        if frienddata ~= nil then
                            head = frienddata.head
                            v.head = head
                        end
                    end
                    chatcontent[i].head = head
                else
                    chatcontent[i].head = head
                end
            end
        end
    end
    return data
end


--根据好友ID获得私聊数据
function ChatModel:getPrivateDataByRid(rid)
    -- self.privateMessage

    dump(self.privateMessage,"私聊数据 ================")
    local data = {}
    if self.privateMessage == nil then
        return data
    end
    if #self.privateMessage == 0 then
        return data
    end
    if rid ~= nil then
        for k,v in pairs(self.privateMessage) do
            if v.rid == rid then
                data = v
            end
        end
    end
    return data
end




--聊天的设置，放到本地
function ChatModel:setinfoToLocal(_type,isShow)
    LS:prv():set(StorageCode.chat_type.._type,isShow)
end


function ChatModel:getshowChatSet(_type)
    local isshow = LS:prv():get(StorageCode.chat_type.._type)
    echo("======_type=======",_type,isshow,type(isshow))
    if isshow == nil then
        isshow = true
    end

    if type(isshow) == "string" then
        if isshow == "false" then
            isshow = false
        else
            isshow = true
        end
        
    end
    return isshow
end

function ChatModel:getLocalShowBarrage()
    -- local arr = {
    --     [1] =  "system",
    --     [2] =  "world",
    --     [3] =  "tream",
    -- }
    local arr  = FuncChat.Chat_Set_Type 
    for k,v in pairs(arr) do
        self.showChatArr[v] = self:getshowChatSet(v)
    end
end

function ChatModel:getSetBarrageShow(_type)
    if self.showChatArr == nil then
        return true
    end
    if self.showChatArr[_type] ~= nil then
        return self.showChatArr[_type]
    end
    return true
end
---设置self.的数据是否显示
function ChatModel:setChatbarrageModeData(_type,isshow)
    if _type == nil then
        return  
    end
    if self.showChatArr ~= nil then
        self.showChatArr[_type] = isshow
    end

    self:setinfoToLocal(_type,isshow)
end


function ChatModel:sendTreasureShareToWorldCD()

    if not self.worldTreasureChatCD or self.worldTreasureChatCD == 0 then
        return true
    else
        local serveTime = TimeControler:getServerTime()
        local time = serveTime - ChatModel.worldTreasureChatCD
        local cdTime = FuncDataSetting.getDataByConstantName("ShareCd") + 2  ---加一个时间延迟
        if time >= cdTime then 
            self.worldTreasureChatCD = 0
            return true
        else
            return false
        end
    end
end

function ChatModel:sendArtifactShareToWorldCD(_time)

    if not self.worldArtifactChatCD or self.worldArtifactChatCD == 0 then
        return true
    else
        local serveTime = TimeControler:getServerTime()
        local time = serveTime - ChatModel.worldArtifactChatCD
        local cdTime = FuncDataSetting.getDataByConstantName("ShareCd") + 2  ---加一个时间延迟
        if time >= cdTime then 
            self.worldArtifactChatCD = 0
            return true
        else
            return false
        end
    end
end




return ChatModel;
