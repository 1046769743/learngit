--//聊天系统协议分发
--//2016-5-9
--/author:xiaohuaxiong
local  ChatServer=class("ChatServer");
--//初始化,注册监听事件
function  ChatServer:init()
--//
    EventControler:addEventListener("notify_chat_world_3512",self.requestWorldMessage,self);
    EventControler:addEventListener("notify_chat_league_3514",self.requestLeagueMessage,self);
    EventControler:addEventListener("notify_chat_private_3516",self.requestPrivateMessage,self);
    EventControler:addEventListener("notify_chat_system_3520",self.requestSystemMessage,self);
    EventControler:addEventListener("notify_guild_activity_chat_5660",self.requestTeamMessage,self);
    EventControler:addEventListener("notify_chat_love_3528",self.requestLoveMessage,self);
    EventControler:addEventListener(VoiceSdkHelper.EVENT_UPLOAD_RECORD_DONE,self.onUploadDone,self)
    EventControler:addEventListener(VoiceSdkHelper.EVENT_DOWNLOAD_RECORD_DONE,self.onDownloadDone,self)
    EventControler:addEventListener(VoiceSdkHelper.EVENT_STT_DONE,self.onSTTDone,self)
    EventControler:addEventListener(VoiceSdkHelper.EVENT_PLAYFILE_DONE,self.onPlayloadDone,self)  
    EventControler:addEventListener(VoiceSdkHelper.EVENT_RECORD_FAIL,self.endRecording,self)

    EventControler:addEventListener("notify_shore_World_3532",self.aAndfShareToworld,self);


    self.colorArr = {
      [2] = "<color = 008c0d>",
      [3] = "<color = 2172c3>",
      [4] = "<color = a80ad5>",
      [5] = "<color = bc7c00>",
    }

    
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


function ChatServer:aAndfShareToworld(param)
 
  local data = param.params.params.data
  -- dump(data,"分享数据 ===== ")
  -- data = json.decode(data)
  -- data.type = FuncChat.CHAT_T_TYPE.shareArtifact
  -- ChatModel:updateWorldMessage(data);
  -- local count =  json.decode(data)
  local linkData = json.decode(data.content)
  if data.type == 1 then   --法宝
    local str = "#tid_treature_share_01"
    local treasureID = linkData.id
    local dataCfg = FuncTreasureNew.getTreasureDataById(treasureID)
    local color = FuncTreasureNew.getNameColorFrame(treasureID)
    local _name = GameConfig.getLanguage(dataCfg.name)
    echo("=======color====111===",color)
    local des = FuncTranslate._getLanguageWithSwap(str,self.colorArr[color].."[".._name.."_line]<->")
    data.content = des
    data.linkData = linkData
    data.type = FuncChat.EventEx_Type.shareTreasure
  elseif data.type == 2 then    ---神器
    local str = "#tid_cimelia_share_01"
    local artifactId = linkData.id
    local artifactalldata = FuncArtifact.byIdgetCCInfo(artifactId)--组合神器数据
    local artifactname = GameConfig.getLanguage(artifactalldata.combineName)  --组合名称
    local color = artifactalldata.combineColor
    echo("=======color===2222====",color)
    local des = FuncTranslate._getLanguageWithSwap(str,self.colorArr[color].."["..artifactname.."_line]<->")
    data.content = des
    data.linkData = linkData
    data.type = FuncChat.EventEx_Type.shareArtifact
  end
  -- dump(data,"分享数据 ===== ")
  ChatModel:updateWorldMessage(data);

end

function ChatServer:requestSystemMessage(param)
  -- dump(param.params,"系统数据1")
  local data = param.params.params.data
  data.chattype = 1
  ChatModel:updateSystemMessage(data)
   
  self:sendMainChatMessage(data)

end
--//世界聊天中消息监听
function ChatServer:requestWorldMessage(param)

  dump(param.params.params,"====== 世界数据 ======") 
  -- echo("voice-======世界数据1========")
  local chatdata = param.params.params.data

  ChatModel:updateWorldMessage(chatdata);

  chatdata.chattype = 2
  self:sendMainChatMessage(chatdata)

  self:sendtxttranslation(chatdata)
  -- local data = ChatModel:getWorldMessage()
  -- dump(data,"11111111111")
end


function ChatServer:sendtxttranslation(chatdata)
    -- if device.platform == "windows" or device.platform =="mac" then
    --   return
    -- end
    -- if chatdata.type == FuncChat.EventEx_Type.voice then
    --   local content = json.decode(chatdata.content)
    --   local fileID = content.fileID
    --   VoiceSdkHelper:speechToText(fileID)
    -- end
end

--//联盟聊天中消息推送
function ChatServer:requestLeagueMessage(param)
	local data = param.params.params.data
  dump(data,"=======联盟聊天中消息推送========")
  ChatModel:updateLeagueMessage(data);    
  data.chattype = 3
  self:sendMainChatMessage(data)
  self:sendtxttranslation(data)
end

--//缘伴聊天中消息推送
function ChatServer:requestLoveMessage(param)
  local data = param.params.params.data
  dump(data,"=======缘伴聊天中消息推送========")
  ChatModel:updateLoveMessage(data);
  data.chattype = 6
end


function ChatServer:addTeamPlayer(playdata)
  self.TeamPlayerdata = playdata
end
--//队伍聊天中消息监听
function ChatServer:requestTeamMessage(chatData)
  local chatData = chatData.params.params.data
    -- dump(chatData,"队伍聊天数据",8)

    local chatDes = ""
    if tostring(chatData.type) == "3" then
        chatDes = FuncTeamFormation.getQuickChatContent(chatData.content)
    elseif tostring(chatData.type) == "2" then
        chatDes = chatData.content
    else
        echo("语音聊天  暂时不使用这个功能-----------")
    end

      local playerdata = {}
      if chatData.rid == UserModel:rid() then
        playerdata = {
            avatar   = UserModel:avatar(),
            chattype = 2,
            content  = chatDes,
            level    = UserModel:level(),
            name     = UserModel:name(),
            rid      = UserModel:rid(),
            time     = TimeControler:getServerTime(),
            type     = 4,
            vip      = UserModel:vip(),
            zitype  = 2,
            head = UserModel:head(),
          }
      else 

        local chattematype = ChatModel:gettematype()
        if chattematype == FuncChat.CHAT_TYPE.TRIAL then
            playerdata = {
              avatar   = self.TeamPlayerdata.avatar,
              chattype = 2,
              content  = chatDes,
              level    = self.TeamPlayerdata.level,
              name     = self.TeamPlayerdata.name,
              rid      = self.TeamPlayerdata.rid,
              time     = TimeControler:getServerTime(),
              type     = 4,
              vip      = self.TeamPlayerdata.vip,
              zitype  = 2,
              head = self.TeamPlayerdata.head or "",
            }
        else
            -- chattematype == FuncChat.CHAT_TYPE.GUILD 
            local data =  GuildModel._membersInfo[chatData.rid]
            playerdata = {
              avatar   = data.avatar,
              chattype = 4,
              content  = chatDes,
              level    = data.level,
              name     = data.name,
              rid      = chatData.rid,
              time     = TimeControler:getServerTime(),
              type     = 4,
              vip      = data.vip,
              zitype  = 2,
              head = data.head or "",
            }

        end
      end

      -- dump(playerdata,"发送的数据")
      -- echo("========chattematype===========",chattematype)
  ChatModel:updateTeamMessage(playerdata);
    self:sendtxttranslation(playerdata)
  -- local data = chatData.params.params.data
  playerdata.chattype = 4
  -- dump(chatData,"111111111111111111111")
  self:sendMainChatMessage(playerdata)


end
--//私人聊天中消息推送
function ChatServer:requestPrivateMessage(param)
    dump(param.params,"voice-- 聊天消息回调")
    
    ChatModel:updatePrivateMessage(param.params.params.data);
    local data = param.params.params.data
    data.chattype = 5
    self:sendMainChatMessage(data)
    self:sendtxttranslation(data)
    -- local chatadata = data

    local commentData = {
      comment = data.content or "仙剑",
      type = 1,  --文本聊天
      player = data,
    }
    EventControler:dispatchEvent(BarrageEvent.BARRAGE_CHAT_PRICES,commentData)


end


--主界面发送聊天消息
function ChatServer:sendMainChatMessage(data)
  -- dump(data,"111111111111111")
  -- ChatModel:Savedatalocal()
  -- if chattypes[data.type] then
  -- ChatModel:Savedatalocal()
  -- HomeModel:chatHomeDelegateMethod(data)
  ChatModel:setAlldatainsertMessage(data)
  -- end

end
--//获取玩家是否在线
function ChatServer:sendPlayIsonLine(param,callback)
        Server:sendRequest(param,MethodCode.player_online_361,callback,nil,nil,true);
end
--//向世界聊天中发送消息
function ChatServer:sendWorldMessage(param,callback)
        Server:sendRequest(param,MethodCode.chat_send_message_world_3501,callback,nil,nil,true);
end
--//向联盟聊天中发送消息
function    ChatServer:sendLeagueMessage(param,callback)
        Server:sendRequest(param,MethodCode.chat_send_message_league_3503,callback,nil,nil,true);
end

--//向联盟聊天中发送消息
function    ChatServer:sendLoveMessage(param,callback)
        Server:sendRequest(param,MethodCode.chat_get_Love_3525,callback,nil,nil,true);
end
--//向私聊页面中发送消息
function ChatServer:sendPrivateMessage(param,callback)
        Server:sendRequest(param,MethodCode.chat_send_message_private_3505,callback,nil,nil,true);
end
--//分享战报
function ChatServer:shareBattleMessage(param,callback)
        Server:sendRequest(param,MethodCode.chat_send_battle_info_3507,callback,nil,nil,true);
end
--//战报回放
function ChatServer:battleMessagePlay(param,callback)
        Server:sendRequest(param,MethodCode.chat_battle_info_play_3509,callback,nil,nil,true);
end



--//分享法宝和神奇的协议
function ChatServer:sendChatWorldShare(param,callback)
        Server:sendRequest(param,MethodCode.chat_share_treasure_artifact_3529,callback,nil,nil,true);
end




---仙盟gve队伍聊天
function ChatServer:sendTeamMessage(params)
    local function callback()
      
    end
    local teamId = GuildActMainModel:getMyTeamId()
    local guildId = UserModel:guildId()
    if guildId ~= "" or teamId ~= nil then
      local param = {
        guildId = guildId,
        teamId = teamId,
        content = params.content,
        type = params.type,
      }
      Server:sendRequest(param,MethodCode.guild_gve_chat_5657,callback,nil,nil,true);
    else
      WindowControler:showTips(GameConfig.getLanguage("tid_chat_001"))
    end
end



--//获取玩家是否在线
function ChatServer:sendgetnotline(param,callback)
        Server:sendRequest(param,MethodCode.chat_get_notline_data_3521,callback,nil,nil,true);
end
--//去离线公会信息
function ChatServer:sendgetGuildNotline(param,callback)
        Server:sendRequest(param,MethodCode.chat_get_guild_notline_3523,callback,nil,nil,true);
end

function ChatServer:chatSendLeague(_text,callback)
      local  param={};  
      param.content=_text;
      param.type = 1
      ChatServer:sendLeagueMessage(param,callback);   
end

function ChatServer:chatSendlove(_text,callback)
      local  param={};  
      param.content=_text;
      param.type = 1
      ChatServer:sendLoveMessage(param,callback);   
end


--//查询角色信息 
function ChatServer:queryPlayerInfo(param,callback)
      local sec = FriendModel:getRidBySec(param.rids[1])
      local  _param={};
      _param.tsec = sec
      _param.rids={};
      _param.rids[1]=param.rids[1];
      _param.detailed = param.detailed
      Server:sendRequest(_param,MethodCode.query_player_info_337,callback,nil,nil,true);
end

function ChatServer:sendChatShare(_item,ridtable)
    -- dump(ridtable,"好友分享数据")

      local function callback(param)  

        -- WindowControler:showWindow("ChatMainView", 5,2,_item._id);
        EventControler:dispatchEvent(GarmentEvent.GARMENT_CLOSE_SHARE_UI)
        WindowControler:showTips(GameConfig.getLanguage("tid_chat_002"))
      end
      -- local skinStr = FuncPartnerSkin.getSkinName(ridtable.data.skinId)
      local sex  = ""
      if ridtable.data.sex  ~= nil then
        sex  = "#"..ridtable.data.sex .."<->"
      end

      local  _param={};
      _param.type = ridtable._type -- ChatShareControler.sendChattypes.sendpartner
      _param.target=_item._id
      _param.content= ridtable.data.id..sex   --"恭喜获得"--..skinStr--GameConfig.getLanguage("#tid_partnerskin_des_02")..skinStr;
      -- dump(_param,"发送消息分享消息")
      self:sendPrivateMessage(_param,callback);
end
function ChatServer:sendChatShareWorld(_type,data)
    dump(data,"世界分享数据")
    local function callback(param)
      -- WindowControler:showWindow("ChatMainView",2);
      -- GarmentEvent.GARMENT_CLOSE_SHARE_UI
      EventControler:dispatchEvent(GarmentEvent.GARMENT_CLOSE_SHARE_UI)
      WindowControler:showTips(GameConfig.getLanguage("tid_chat_002"))
    end
    local sex  = ""
      if data.sex  ~= nil then
        sex  = "#"..data.sex .."<->"
      end
    local  param={};
    -- local skinStr = FuncPartnerSkin.getSkinName(data.skinId)
    param.content= data.id..sex --"恭喜获得"--..skinSt--GameConfig.getLanguage("#tid_partnerskin_des_02")..skinStr;
    local sendtype = ChatShareControler.ChatSharetype.sendchat
    if _type == ChatShareControler.ChatSharetype.CHAT_TYPE_GARMENT then  --时装
       sendtype = ChatShareControler.sendChattypes.sendgarment
    elseif _type == ChatShareControler.ChatSharetype.CHAT_TYPE_PARTNER_SKIN then  ---伙伴
      sendtype = ChatShareControler.sendChattypes.sendpartner
    end
    param.type = sendtype
    -- dump(param,"发送消息分享消息")
    self:sendWorldMessage(param,callback);
end


--开始录音接口
function ChatServer:startRecording()
    local filename = TimeControler:getServerTime()..".dat"
    local filePath = cc.FileUtils:getInstance():getWritablePath()..filename
    echo("voice-  ---   filePath==本地数据 =",filePath)
    VoiceSdkHelper:startRecording(filePath)
    self.filePath = filePath

end
--结束录音接口  录音失败，没有权限
function ChatServer:endRecording()
    WindowControler:showTips(GameConfig.getLanguage("#tid_voice_faild_1") )
end


-- 开始上传文件
function ChatServer:onClickUpload(_time,selectType)  
    echo("voice-上传  ======",self.filePath,selectType)
    -- self.txt_content:setString("开始上传...")
    self.send_time = _time
    self.selectType = selectType
    
    if cc.FileUtils:getInstance():isFileExist(self.filePath) then
      VoiceSdkHelper:uploadRecordedFile(self.filePath)
    else
      self:showVoiceTips()
    end
end

function ChatServer:showVoiceTips()
  WindowControler:showTips(GameConfig.getLanguage("#tid_Chat_115"))
end

--取消录音接口
function ChatServer:stopRecording()
    VoiceSdkHelper:stopRecording()
  -- local rt = cc.FileUtils:getInstance():isFileExist(self.filePath)
  -- echo("voice------文件是否存在",rt)
end

-- onUploadDone
-- onDownloadDone
-- onSTTDone
-- 上传完成回调
function ChatServer:onUploadDone(event) 
    echo("voice-上传回调")
    if event then
        local params = event.params
        local fileID = params.fileID
        local filePath = params.filePath 
        self.fileID = fileID
        if fileID then
            --翻译
            VoiceSdkHelper:speechToText(fileID)
            ChatModel:setVoiceData(fileID,filePath)
        else
            -- echo("=========上传失败=========")
            WindowControler:showTips(GameConfig.getLanguage("#tid_Chat_115"))
            ChatModel:sendMotched()
        end
  
    end
end

-- 下载完成回调
function ChatServer:onDownloadDone(event)
    echo("voice-下载回调")
    -- dump(event,"voice-下载回调 =====")
    if event then
        local params = event.params
        local fileID = params.fileID 
        local filePath = params.filePath 
        echo("voice- fileID==",fileID)
        echo("voice- filePath==",filePath)
        if fileID then
            -- echo("voice - 下载成功 filePath=======   ",filePath)
            ChatModel:setVoiceData(fileID,filePath)
            VoiceSdkHelper:playRecordedFile(filePath)
        else

        end
    end
end
--10-25 19:45:39.766: D/cocos2d-x debug info(24780): [echo:25-19:45:39] voice filePath= /data/data/com.playcrab.heracles/files/1508931939.dat

-- 翻译完成回调
function ChatServer:onSTTDone(event) 
    -- echo("voice-翻译回调")
    -- dump(event.params,"voice-翻译回调")
    if event then
        local params = event.params
        local content = params.content
        local fileID = params.fileID
        -- echo("voice-content ==",content)
        if content then
            -- self.txt_content:setString(content)
            -- self.fileID
            self:sendvoiceServer(fileID,content)
        else
            -- self.txt_content:setString("翻译失败")
        end
    end
end

---发送语音到服务器
function ChatServer:sendvoiceServer(fileID,content,isonline)
    -- self.selectType   --聊天发送语音的类型（世界，私聊，队伍，仙盟）
    local function callback( param )
        -- dump(param.result," voice = 语音聊天数据")
    end

    -- self.selectType = 1
    local fildtable = {
        fileID = fileID or 1,
        time = self.send_time  or 1,
        voice = true,   ---语音
        content = content,
    }
    local datatext = json.encode(fildtable)
    local param = {};
    param.content = datatext;
    param.type =  FuncChat.EventEx_Type.voice  --语音类型协议
    echo("=======voice= 类型======",self.selectType)

    if self.selectType == 2 then 
        self:sendWorldMessage(param,callback)
    elseif self.selectType == 3 then
        self:sendLeagueMessage(param,callback)
    elseif self.selectType == 5 then
        local _rid = ChatModel.privateTargetPlayer.rid
        param.target=_rid;
        self:sendPrivateMessage(param,callback)

    elseif  self.selectType == 6 then
      self:sendLoveMessage(param,callback)
    elseif self.selectType == FuncChat.BarrageType then  --弹幕的语音
        local _type,arrData = BarrageModel:getVoiceType()
        echo("=====发送服务器类型  =_type=========",_type)
        local length = string.len4cn2( content);
        if length > FuncBarrage.Maxlength then
          content = string.subcn(content,1,FuncBarrage.Maxlength/2) .. "···"
        end
        if _type ~= nil then
          if _type ==   FuncBarrage.SystemType.crosspeak then  ---巅峰对决的时候
            BarrageModel:sendCrosspeakToServe(arrData,content,content)
          elseif _type == FuncBarrage.SystemType.plot then   ---剧情对话
            local newdata = {
              plotID = arrData.plotData.plotID,
              _text = content,
              order = arrData.plotData.order,
            }
            BarrageModel:sendContentToServer(newdata)
          end
        end
    end
end


-- 开始下载文件
function ChatServer:onClickDownload(fileID)
    echo("voice-下载")
    local filename = TimeControler:getServerTime()..".dat"
    -- 音频文件名称根据具体业务进行规划
    local filePath = cc.FileUtils:getInstance():getWritablePath() .. filename
    VoiceSdkHelper:downloadRecordedFile(fileID,filePath)
end

-- 开始播放文件
function ChatServer:onClickPlay(fileID)
    echo("voice-播放",fileID)
    local filePath = LSChat:prv():get(fileID,nil)
    if filePath then
      local isfile  = cc.FileUtils:getInstance():isFileExist(filePath)   ---本地文件是否存在
      if not isfile then
          self:onClickDownload(fileID)  
          return 
      end
    else

      self:onClickDownload(fileID)  
      return 
    end
    VoiceSdkHelper:playRecordedFile(filePath)
end

--停止播放所有语音
function ChatServer:stopPlayFile()
  -- echo("device.platform =========",device.platform)
  if device.platform == "windows" or device.platform =="mac" then
    return
  end
  VoiceSdkHelper:stopPlayFile()
end


function ChatServer:onPlayloadDone(event)
  local tempfunc = function (  )
    PCSdkHelper:setVoicemode( 1  )
  end
  WindowControler:globalDelayCall(tempFunc,0.1)
   
end



--[[
--发送语音协议
function ChatServer:sendRecording(sendtime,other,selectType)
    local rid = UserModel:rid()
    local name = UserModel:name()
    local level = UserModel:level()
    local othertime = 3
    local content = "三昌西三西三昌西三昌西三昌西昌"
    -- if other then
    --     name = "霸轰风雨侠"
    --     rid = "dev_3806"
    --     level = 10
    --     content = "三昌西三西三昌西三昌西西三昌西三昌西西三昌西三昌西西三昌西三三昌西三昌三昌西昌"
    --     selectType = selectType or 2
    --     sendtime = othertime 
    -- end

    local data = {
            avatar  = 101,
            content = content,
            level   = level,
            name    = name,
            rid    = rid,
            time = sendtime,
            servetime    = TimeControler:getServerTime(),
            type    = 1,
            vip    = UserModel:vip(),
            voice = true,   ---语音
            chattype = 2,
        }
    if tonumber(selectType) == FuncChat.CHAT_T_TYPE.world then
        ChatModel:updateWorldMessage(data)
    elseif tonumber(selectType) == FuncChat.CHAT_T_TYPE.private then
        data.chattype = 5
        ChatModel:updatePrivateMessage(data)
    elseif tonumber(selectType) == FuncChat.CHAT_T_TYPE.troop then
        data.chattype = 4 
        -- ChatModel:updatePrivateMessage(data)
    end
    self:sendMainChatMessage(data)
end
]]


ChatServer:init()
return  ChatServer;