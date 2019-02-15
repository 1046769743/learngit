-- ChatInfoCellView
-- wk
-- time  ： 2017/09/22/10:00
-- 聊天信息界面  


local ChatInfoCellView = class("ChatInfoCellView", UIBase)
local rich_width = 380

function ChatInfoCellView:ctor(winName)
    ChatInfoCellView.super.ctor(self, winName)
end

function ChatInfoCellView:loadUIComplete()


	-- _cell = self.mc_talk
	-- -- _cell:getViewByFrame(1).panel_copy1.rich_1:setString("会议要求，东航武汉公司要切实提高安全意识，加强安全管控能力，加强系统安全建设，完善训练体系，强化队伍建设，确保东航科学发展、安全发展。")
	
end

--[[
local data = {
    avatar  = 101,
    content = "adasdasdasdas",
    level   = 1,
    name    = "霸轰风雨侠",
    rid    = "dev_3806",
    time = 3,
    servetime    = 1506415599,
    type    = 1,
    vip    = 5,
    voice = true,   ---语音
    chattype = 2,
}

]]


function ChatInfoCellView:initData(_item,mc_scroll)
	-- dump(_item,"\n\nvoice -- 聊天数据结构",8)
    local _itemData = table.copy(_item)
    self.mc_scroll = mc_scroll

    if _itemData.type == nil then
        self:feedBackChat(_itemData)
    elseif _itemData.type == FuncChat.EventEx_Type.voice then
        local content = json.decode(_itemData.content)
        _itemData.voicedata = content
        _itemData.content = nil
        self:voiceChat(_itemData)
    elseif _itemData.type == FuncChat.EventEx_Type.guildinvite then
        self:addInviteUI(_itemData,_itemData.type)
    elseif _itemData.type == FuncChat.EventEx_Type.shareArtifact or  _itemData.type == FuncChat.EventEx_Type.shareTreasure then
        self:textChat(_itemData)
    elseif _itemData.type == FuncChat.EventEx_Type.guildExportMine then
        self:addInviteUI(_itemData,_itemData.type)
	else
		self:textChat(_itemData)
	end

end

--邀请加入
function ChatInfoCellView:addInviteUI(_item,_itemDataType)
    -- content = {
        -- guildID = 1,
        -- desc = "邀请加入"
    -- }
    -- dump(_item,"邀请加入shuju")

    local _cell = self.mc_talk
    local  _rid = UserModel:rid();
    local frameindex  = 5
    if _rid ==  _item.rid then
        frameindex = 7
    end

    _cell:showFrame(frameindex)
    local panel = _cell:getViewByFrame(frameindex).panel_copy1
    -- local playuid = ChatModel:getRidBySec(_rid)
    -- local otheruid =  ChatModel:getRidBySec(_item.rid)
    local pames = 1
    if _itemDataType == FuncChat.EventEx_Type.guildinvite then
        panel.mc_guildtalk:getViewByFrame(pames).btn_jr:setVisible(true)
        _item.content =  json.decode(_item.content)
        local info = _item.content
        local str = "\"<color=33ff00>"..info.level.."<->级仙盟<color=33ff00>"..info.name.."<->收人啦:"
        local desc = _item.content.desc
        if desc == nil  or desc == ""  then
            desc = FuncGuild.getdefaultDec()
        end
        local str2 = "\n仙盟宣言:"..desc.."\""
        _item.content = str..str2
        panel.mc_guildtalk:getViewByFrame(pames).btn_jr:setTouchedFunc(c_func(self.inviteToGuild, self,info),nil,true);
        -- panel.mc_guildtalk:getViewByFrame(pames).btn_jr:getUpPanel().txt_1:setString("我要加入")
    elseif _itemDataType == FuncChat.EventEx_Type.guildExportMine then
        panel.mc_guildtalk:getViewByFrame(pames).btn_jr:setVisible(true)
        local strAll =  json.decode(_item.content)
        _item.content = strAll.desc
        local eventModel = strAll.eventModel
        panel.mc_guildtalk:getViewByFrame(pames).btn_jr:setTouchedFunc(c_func(self.inviteToMineView, self,eventModel),nil,true);
        panel.mc_guildtalk:getViewByFrame(pames).btn_jr:getUpPanel().txt_1:setString("我要开采")
    -- else
    --     pames = 2
    --     panel.mc_guildtalk:showFrame(pames)
    --     if tostring(_item.arrData.rid) == tostring(UserModel:rid()) then
    --         panel.mc_guildtalk:getViewByFrame(pames).btn_1:setVisible(false)
    --     else
    --         panel.mc_guildtalk:getViewByFrame(pames).btn_1:setVisible(true)
    --         -- panel.mc_guildtalk:getViewByFrame(2).btn_jr:getUpPanel().txt_1:setString("领取委托")
    --         panel.mc_guildtalk:getViewByFrame(pames).btn_1:setTouchedFunc(c_func(self.inviteToRingTask, self, _item),nil,true);
    --     end

    end


    self:commonModel(_item,frameindex)

    -- if pames == 1 then
    --     local y = panel.mc_guildtalk:getViewByFrame(pames).btn_jr:getPositionY()
    --     panel.mc_guildtalk:getViewByFrame(pames).btn_jr:setPositionY(y-15)
    -- else
    --     local y = panel.mc_guildtalk:getViewByFrame(pames).btn_1:getPositionY()
    --     panel.mc_guildtalk:getViewByFrame(pames).btn_1:setPositionY(y-15)
    -- end
    local y = panel.mc_guildtalk:getPositionY()
    panel.mc_guildtalk:setPositionY(y-15)
    local size = 
        { 
            width = 390,
            height = 90,
        }
    panel.scale9_1:setContentSize(size)

end

--跳转到矿洞
function ChatInfoCellView:inviteToMineView(eventModel)
    GuildExploreEventModel:showMineUI(eventModel,true)
end

function ChatInfoCellView:inviteToGuild(info)
    echo("=====仙盟ID========",info.id)
    ---发送到服务器上
    local guildID = info.id


    local isopen =  FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.GUILD)
    if not isopen then
        local condition = FuncCommon.getSysOpenValue(FuncCommon.SYSTEM_NAME.GUILD, "condition")
        local conditionType = condition[1].t
        local conditionValue = condition[1].v
        local lockTip = nil
        local str  = GameConfig.getLanguage("#tid_group_guild_1601")
        if conditionType == FuncCommon.CONDITION_TYPE.LEVEL then
            lockTip = conditionValue .. str
        --境界是否满足
        elseif conditionType == FuncCommon.CONDITION_TYPE.STAGE then
            local raidId = conditionValue
            local raidData = FuncChapter.getRaidDataByRaidId(raidId)
            local raidName = WorldModel:getRaidName(raidId)
            local chapter = WorldModel:getChapterNum(FuncChapter.getChapterByStoryId(raidData.chapter))
            local section = WorldModel:getChapterNum(FuncChapter.getSectionByRaidId(raidId))
            lockTip = "通关第" .. chapter .. "章第" .. section .. "节" .. raidName .. GameConfig.getLanguage("#tid_group_guild_1604")
        end
        WindowControler:showTips(lockTip)
        return 
    end

    local guild =  UserModel:guildId()
    -- echo("=======guild==========",guild)
    if guild ~= nil and guild ~= "" then
        WindowControler:showTips(GameConfig.getLanguage("#tid_group_guild_1602"))
        return 
    end
    local function _callback(_param)
        -- dump(_param.result,"申请加入的数据返回",8)
        if _param.result then
            WindowControler:showTips(GameConfig.getLanguage("#tid_group_guild_1603"))
        else
            --错误和没查找到的情况
        end
    end 

    local params = {
        id = guildID
    };
    GuildServer:joinGuild(params,_callback)
    
end

--语音聊天
function ChatInfoCellView:voiceChat(_item)

    --  local fildtable = {
    --     fileID = fileID,
    --     time = self.send_time,
    --     voice = true,   ---语音
            -- content = "",
    -- }

    -- dump(_item,"voice -111111- 聊天数据结构",8)

    local _cell = self.mc_talk
    local  _rid = UserModel:rid();
    local frameindex  = 3
    _cell:showFrame(frameindex)

    local playuid = ChatModel:getRidBySec(_rid)
    local otheruid =  ChatModel:getRidBySec(_item.rid)
    if(playuid==otheruid)then--//自身
        frameindex = 4
        _cell:showFrame(frameindex)
    end
    _cell:getViewByFrame(frameindex).panel_copy1.rich_1:setString("")

    local size =  self:commonModel(_item,frameindex)
    -- panel_yuyin.panel_tanhao:
    self:voiceviewData(_item,size,frameindex)


end
function ChatInfoCellView:voiceviewData(_item,size,frameindex)
    local _cell = self.mc_talk
    local singcell =  _cell:getViewByFrame(frameindex).panel_copy1
    --:setTap(c_func(self.playVoice, self,1));
    local panel_yuyin = singcell.panel_yuyin--btn_yuyin:getUpPanel()

    local time = _item.voicedata.time


    singcell.txt_2:setString(self:FormatChatTime(_item.time))

    panel_yuyin.txt_time:setString(time.."\"")

    local width = FuncChat.timeConversionPercent(time)
    panel_yuyin.scale9_green:size(width,30)
    local scale9_x = panel_yuyin.scale9_green:getPositionX()
    panel_yuyin.panel_tanhao:setVisible(false)
    local  _rid=UserModel:rid();
    local playuid = ChatModel:getRidBySec(_rid)
    local otheruid =  ChatModel:getRidBySec(_item.rid)
    if playuid == otheruid then
        panel_yuyin.panel_tanhao:setPositionX(scale9_x - width- 20)
    else
        panel_yuyin.panel_tanhao:setPositionX(scale9_x + width)
    end



    if size.width < rich_width then
        if size.width < width then
            size.width = width + 15
        end
    else
        size.width = size.width - 10
    end

    local string = nil
    if _item.voicedata ~= nil then
        string = _item.voicedata.content
    end
    if string ~= nil or string ~= "" then
        size.height = size.height + 25
    else
       size.height = size.height - 25
       --翻译
        if device.platform ~= "windows" or device.platform ~="mac" then
            -- VoiceSdkHelper:speechToText(_item.voicedata.fileID)

        end
    end
    _cell:getViewByFrame(frameindex).panel_copy1.scale9_1:setContentSize(size)



    panel_yuyin.panel_tanhao:setTouchedFunc(c_func(self.replayVoice,self,_item),nil,true);
    singcell.panel_yuyin:setTouchedFunc(c_func(self.playVoice,self,_item),nil,true);
end


function ChatInfoCellView:replayVoice(_item)
    echo("=========重新播放语音=====")
end

--播放语音

function ChatInfoCellView:playVoice(_item)

    -- echo("=========播放语音=====",parame)
    dump(_item,"========播放语音===parame========")
    local voicedata = _item.voicedata
    local fildtable = {
        fileID = voicedata.fileID,
        time = voicedata.time,
        voice = true,   ---语音
        content = "",
        zitype = _item.zitype,
    }
    ChatModel:setisvoiceData(fildtable,fildtable.fileID)
    --播放一条消息后强制 时间后恢复
    VoiceSdkHelper:stopPlayFile()--fildtable.time+0.5)
    -- AudioModel:stopMusic()
    ChatServer:onClickPlay(fildtable.fileID)


end

function ChatInfoCellView:feedBackChat(_item)
    local _cell = self.mc_talk
    local frameindex = 2
    if _item.avatar == nil then
        frameindex = 6
    end
 
    _cell:showFrame(frameindex)

    self:commonModel(_item, frameindex)
end

---文本和资源聊天
function ChatInfoCellView:textChat(_item)
	local _cell = self.mc_talk
	local  _rid=UserModel:rid();
    local frameindex  = 1
    _cell:showFrame(frameindex)
    

    local playuid = ChatModel:getRidBySec(_rid)
    local otheruid =  ChatModel:getRidBySec(_item.rid)
    if(playuid==otheruid)then--//自身
        frameindex = 2
        _cell:showFrame(frameindex)
    end
    self:commonModel(_item,frameindex)


end

function ChatInfoCellView:commonModel(_item,frameindex)
    local _cell = self.mc_talk
    if frameindex == 6 then
        _cell:getViewByFrame(frameindex).panel_copy1.txt_1:setString(_item.name)
        _cell:getViewByFrame(frameindex).panel_copy1.mc_2:setVisible(false)
        _cell:getViewByFrame(frameindex).panel_copy1.panel_kefu:setVisible(true)
    else
        local  _rid=UserModel:rid();
        local playuid = ChatModel:getRidBySec(_rid)
        local otheruid =  ChatModel:getRidBySec(_item.rid)
        _cell:getViewByFrame(frameindex).panel_copy1.rich_1:setString("")
        --//玩家图标
        if otheruid ~= playuid  then--//不是自身
            local _node = _cell:getViewByFrame(frameindex).panel_copy1.btn_1:getUpPanel().panel_1.ctn_1
            ChatModel:setPlayerIcon(_node,_item.head,_item.avatar)
        else
            local _node = _cell:getViewByFrame(frameindex).panel_copy1.btn_1:getUpPanel().panel_1.ctn_1
            ChatModel:setPlayerIcon( _node,UserModel:head(),UserModel:avatar())
        end

        --//名字
        local namewidth = 0
        if(_item.name=="")then
            _cell:getViewByFrame(frameindex).panel_copy1.txt_1:setString(GameConfig.getLanguage("tid_common_2006"));
            _item.name = GameConfig.getLanguage("tid_common_2006")
        else
            _cell:getViewByFrame(frameindex).panel_copy1.txt_1:setString(_item.name);
        end
        namewidth = FuncCommUI.setRichwidth(_item.name)

        -- echo("==========playuid=============",playuid,otheruid)
        if(playuid~=otheruid)then--//不是自身
            if _item.name ~= "" then
                self.mc_scroll:getViewByFrame(2).txt_1:setString(_item.name);
            end
            if self.targetPlayer ~= nil then
                if self.targetPlayer.mk ~= nil then
                    _cell:getViewByFrame(frameindex).panel_copy1.txt_1:setString(self.targetPlayer.mk);
                    self.mc_scroll:getViewByFrame(2).txt_1:setString(self.targetPlayer.mk);
                    namewidth = FuncCommUI.setRichwidth(self.targetPlayer.mk)
                end
                if self.targetPlayer.liwu ~= nil then
                    if self.targetPlayer.liwu.mk ~= nil then
                        _cell:getViewByFrame(frameindex).panel_copy1.txt_1:setString(self.targetPlayer.liwu.mk)
                        self.mc_scroll:getViewByFrame(2).txt_1:setString(self.targetPlayer.liwu.mk);
                        namewidth = FuncCommUI.setRichwidth(self.targetPlayer.liwu.mk)
                    end
                end
            end
            _cell:getViewByFrame(frameindex).panel_copy1.btn_1:setTap(c_func(self.clickCellButtonQueryPlayerInfo,self,_item))
        end

        --//称号
        local titleid =  ""
        _cell:getViewByFrame(frameindex).panel_copy1.mc_2:showFrame(4)
        local _ctn =  _cell:getViewByFrame(frameindex).panel_copy1.mc_2:getViewByFrame(4).ctn_1
        if(_item.rid == _rid)then--//是自身
            titleid = TitleModel:gettitleids()
            -- namewidth
            if titleid ~= "" then
                local x = _cell:getViewByFrame(frameindex).panel_copy1.txt_1:getPositionX()
                _ctn:setPositionX(x - namewidth - 20)
            end
        else
            if _item.title ~= nil then
                titleid = _item.title.id
                local x = _cell:getViewByFrame(frameindex).panel_copy1.txt_1:getPositionX()
                local mc_ctn =  _cell:getViewByFrame(frameindex).panel_copy1.mc_2
                mc_ctn:setPositionX(x + namewidth)
            end
        end
        --echo("=========titleid========",titleid)
        ChatModel:addCharTitle(_ctn,titleid)
        _cell:getViewByFrame(frameindex).panel_copy1.btn_1:getUpPanel().panel_1.txt_1:setString("".._item.level)  
    end

--//时间
    _cell:getViewByFrame(frameindex).panel_copy1.txt_2:setString(self:FormatChatTime(_item.time));
    

    local string = _item.content
    if _item.voicedata ~= nil then
        string = _item.voicedata.content
    end

    
    -- if type(_item.content) == "table" then
    --     string = _item.content.content
    -- end
    local content,callback = ChatModel:ToDealWithShare(_item)
    if content ~= nil then
        string = content
        _cell:getViewByFrame(frameindex).panel_copy1.rich_1:setTouchedFunc(callback,nil,true);
    end

    local rich_1_X = _cell:getViewByFrame(frameindex).panel_copy1.rich_1:getPositionX()
   

    local spSize = {}
    local _Lineindex = string.find(string,"_line") 
    local newstring = string
    -- if _Lineindex ~= nil then
    --     newstring = string.gsub(string,"_line]","")
    -- end


    local widths,height = self:getImahigt(newstring,frameindex)

    local newheight,lengthnum = FuncCommUI.getStringHeightByFixedWidth(newstring,20,nil,380)

    if widths < 23 then
        widths = 23
    end
    if widths > 360 then
        widths = 370
    end


    local ricecell = _cell:getViewByFrame(frameindex).panel_copy1.rich_1

    if _item._type == 1 then
        spSize.width = widths + 18
        spSize.height = height + 18
        _cell:getViewByFrame(frameindex).panel_copy1:pos(530, 0)
        -- _cell:getViewByFrame(frameindex).panel_copy1.txt_2:pos(10, 0)
    elseif _item._type == 2 then
        spSize.width = widths + 18
        spSize.height = height + 18
        -- _cell:getViewByFrame(frameindex).panel_copy1.txt_2:pos(350, 0)
    else
        spSize.width = widths + 18
        spSize.height = height + 18
    end
    
    if string == nil or string == "" then
        spSize.height = height
    end
    -- dump(spSize,"22222222222222222222")
    _cell:getViewByFrame(frameindex).panel_copy1.scale9_1:setContentSize(spSize)


    local size =  _cell:getViewByFrame(frameindex).panel_copy1.scale9_1:getContentSize()

    
    _cell:getViewByFrame(frameindex).panel_copy1.txt_rizi:setVisible(false)

    local serverTime  = TimeControler:getServerTime()
    
    local oldservertimse  = ChatModel:getServerTimes()
    
    if _item.chattime ~= nil then
        local timeData = os.date("*t",_item.chattime)
        _cell:getViewByFrame(frameindex).panel_copy1.txt_rizi:setVisible(false)
        -- _cell:getViewByFrame(frameindex).panel_copy1.txt_rizi:setString(timeData.month.."月"..timeData.day.."日")
    else
        if _item.time >= oldservertimse + 5 * 60 then
            local timeData = os.date("*t",serverTime)
            _cell:getViewByFrame(frameindex).panel_copy1.txt_rizi:setVisible(false)
            -- _cell:getViewByFrame(frameindex).panel_copy1.txt_rizi:setString(timeData.month.."月"..timeData.day.."日")
            _item.chattime = serverTime
            ChatModel:setServerTime(serverTime)
        end
    end

    -- local myname = UserModel:name()
    -- local str_widths = tonumber(FuncCommUI.getStringWidth(myname, 20))
    if  _item.type == 1 then
        if lengthnum > 1 then
            ricecell:setPositionX(rich_1_X+10)
        end
    end


    return spSize

end

function ChatInfoCellView:getImahigt(targetStr,frameindex,width)
        
    local _cell = self.mc_talk
    local richText = _cell:getViewByFrame(frameindex).panel_copy1.rich_1
    local w,h =richText:setStringByAutoSize( targetStr,0,5 )
    return w ,h

end
--//查询任意一个角色信息
function ChatInfoCellView:clickCellButtonQueryPlayerInfo(_item)
    if _item.isRobot then 
        local   _playerUI=WindowControler:showWindow("CompPlayerDetailView",_item,self,1);
    else
        local function _callback(param)
            if(param.result~=nil)then
                local   _playerUI=WindowControler:showWindow("CompPlayerDetailView",param.result.data.data[1],self,1);--//从世界聊天进入
            end
        end
        local  _param={};
        _param.rids={};
        _param.rids[1]=_item.rid;
        ChatServer:queryPlayerInfo(_param,_callback);
    end
end

--//辅助函数,格式化时间
function  ChatInfoCellView:FormatChatTime(_time)
    -- echo("_time ===============",_time)
       local    _format;
       _format=os.date("%X",_time)--//string.format("%02d:%02d",math.floor(_time/3600),math.floor(_time%3600/60));
       local timeData = os.date("*t",_time)
       return _format  --timeData.month.."-"..timeData.day.." ".._format;
end

return ChatInfoCellView  

