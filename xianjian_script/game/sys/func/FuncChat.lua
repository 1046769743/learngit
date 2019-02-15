FuncChat = FuncChat or {}

local data = nil;
FuncChat.CHAT_T_TYPE = {
    system = 1, --- 系统
    world = 2,  ---世界
    tream = 3,  ---仙盟
    troop = 4,---队伍
    private  = 5,  -- 私聊
    voice = 6,---语音
    love = 7, --缘伴
    shareArtifact = 101,--神器
    shareTreasure = 102,--法宝
    guildExportMine = 105, --仙盟探索跳转
}

FuncChat.Chat_Set_Type = {
    [1] = "system",
    [2] = "world",
    [3] = "tream",
    [4] = "love",
}

--聊天类型的
FuncChat.EventEx_Type = {
    private = 1,  --聊天
    fashion   =   2,   --时装分享
    partner   =  3,   --伙伴分享
    voice = 5,   --语音
    guildinvite = 6,   ---仙盟邀请其他玩家
    shareArtifact = 101,--神器
    shareTreasure = 102,--法宝
    guildAct = 103,--仙盟酒家邀请其他玩家
    guildBoss = 104, --仙盟副本跳转   
    guildExportMine = 105, --仙盟探索跳转
}

FuncChat.PLAYERNAME = "playName" --保存玩家列表
FuncChat.CONTENT = "content"   --保存聊天数据列表

-- 计数类型
FuncChat.CHAT_TYPE = {
	TRIAL = 1,                  -- 试炼类型
    GUILD = 2,
    GUILDBOSSGVE = 3,       --仙盟boss组队
}
FuncChat.CHAT_team_TYPE = {
	trial = 1,
    guild = 2,
    guildBossGve = 3,
}
FuncChat.CHAT_STRING = {
	friend = "我们已经成为好友！",
}

FuncChat.biaoqingtable = {
    jiong = "#1",
    kaixin = "#2",
    maimeng = "#3",
    qinqin = "#4",
    shengqi= "#5",
    zan = "#6",
}
FuncChat.BarrageType = 99  --弹幕语音类型


function FuncChat.init()
    -- data = Tool:configRequire("common/Count");
end

--手指滑动偏移量
function FuncChat.voiceMoveOffset()
	return 100
end

--语音说话的时间
function FuncChat.voiceTalkTime()
	return 60
end

--保存语音聊天数量
function FuncChat.seaveNumTalk()
    return 30
end

--最短的发送时间
function FuncChat.shortestSendTime()
	return 1
end

--点击间隔
function FuncChat.touchClickInterval()
	return 0.5
end


function FuncChat.imageStrgetNewStr(text)
    -- echo("=======texttexttexttext=======",text)
    local str = text ---"<kaishi1>时间等会三<ksj>sdsad<kaishi2><kaishi3>"
    local newresultObj = {}
    local file = true
    local _x = 0
    local imagenumber = 0
    while file do   
        local index = string.find(str,"%[") 
        local indey = string.find(str,"%]") 
        if string.len(str) ~= 0 then
            _x = _x + 1
            if index ~= nil and indey ~= nil  then
                if index == 1 then
                    local newstr = string.sub(str,index,indey)  
                    local icomname = ""  ---默认使用这个字符表示
                    -- echo("========newstr=======",newstr)
                    if string.sub(newstr,-5,-2) == ".png" then
					    icomname = "哈哈"  
                        imagenumber = imagenumber + 1
					end
                    -- echo
                    newresultObj[_x] = {}
                    newresultObj[_x].str = icomname
                    newresultObj[_x].oldstr = newstr
                    newresultObj[_x].image = true
                    str = string.sub(str,indey+1)
                else
                    local newstr = string.sub(str,0,index-1)
                    newresultObj[_x] = {}
                    newresultObj[_x].str = newstr
                    str = string.sub(str,index)
                end
            else
                newresultObj[_x] = {}
                newresultObj[_x].str = str
                file = false 
            end
        else
            file = false 
        end
    end

    -- dump(newresultObj,"语言数据结构",9)
    local newStr = ""
    for i=1,#newresultObj do
        newStr = newStr..newresultObj[i].str
    end
    -- echo("=======222222==========",newStr)
    return newStr,imagenumber,newresultObj
end
--获得字符串的长宽和高
function FuncChat.getStrWandH(string,textwidth,fontSize)
    local _, dstring =  RichTextExpand:parseRichText(string)
    fontSize = fontSize or 20
    textwidth = textwidth or 380
    local  widths 
    local height,lengthnum = FuncCommUI.getStringHeightByFixedWidth(dstring,fontSize,nil,textwidth )
    if lengthnum == 1 then
        widths = tonumber(FuncCommUI.getStringWidth(newstr, fontSize))
    else
        widths = textwidth
    end
       
    
    return widths,height
end


function FuncChat.timeConversionPercent(time)
    local percent = time/FuncChat.voiceTalkTime()
    local defaultlength = 350
    local defaulwidth = FuncChat.voiceTalkTime()
    local width = 0
    if time >= FuncChat.voiceTalkTime() then
        width =  defaultlength  ---默认总长度
    else
        width = defaultlength * percent
        if width <= defaulwidth then
            width = defaulwidth
        end
    end
    return  width
end
function FuncChat.ruleOutText(_text)
    local new_text = string.lower(_text)   --<==返回"abc"
    local index = string.find(_text,"<")
    local indey = string.find(_text,">")
    local indez = string.find(_text,"=")
    local colorInX = string.find(new_text,"color")
    if colorInX ~= nil then

    -- if index ~= nil then
    --     if indez ~= nil then
    --         local str  =  string.sub(_text, index +1, indez - 1)
    --         str = string.lower(str)
    --         local i, j = string.find(_text, "<->")
    --         if str == "color" then
                local file = true
                while file do 
                    local i, j = string.find(_text, "<->")
                    if i ~= nil and j ~= nil then
                        _text = string.gsub(_text, "<->","")
                    else
                        file = false
                    end
                end
    --         end
    --     end
    end
    return _text
end

function FuncChat.getWorldTime()
     local time =  FuncDataSetting.getDataByConstantName("WorldTalk")
    return  time
end


