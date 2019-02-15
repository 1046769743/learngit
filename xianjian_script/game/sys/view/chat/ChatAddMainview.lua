-- ChatAddMainview
-- Author Wk
-- time  2017/05/26 14:10

local ChatAddMainview = class("ChatAddMainview", UIBase);
function ChatAddMainview:ctor(_winName)
    ChatAddMainview.super.ctor(self, _winName);
    self.setdata = {}
    self.systemchadata = {}
    self.typetable = {
    	[1]  = "world",
    	[2] = "guild",
    	[3] = "team",
    	[4] = "private",
	}
end
function ChatAddMainview:loadUIComplete()
    self:registerEvent()

    self:updataUI()
end

function ChatAddMainview:registerEvent()
	ChatAddMainview.super.registerEvent(self);
	
    EventControler:addEventListener(ChatEvent.CHATMAIN_MESSAGE ,self.updataUI,self)
    EventControler:addEventListener("REFRESHSETINFO" ,self.updataUI,self)
    
end
function ChatAddMainview:getAlldataView()
	
    self.systemchadata = ChatModel:getAllMessagedata()
end
function ChatAddMainview:updataUI()
    self:getAlldataView()
    self.panel_tishi.mc_colorful:setVisible(false)
    self.panel_tishi.rich_1:setVisible(false)
    self.panel_tishi.txt_1:setVisible(false)
    self.panel_tishi.mc_1:setVisible(false)

	local  function genPrivateObject(_item)   
        local  _cell=UIBaseDef:cloneOneView(self.panel_tishi);
        self:currencySystemTextModel(_cell,_item);
        return _cell;
    end
    local params = {}
    local sumindex = 0
    local data = self.systemchadata
    local setinfodata =  ChatModel:getChatSetinfo()
    self.panel_tishi.scroll_1:cancleCacheView();
    if data ~= nil then
        if  #data ~= 0 then
            for i=1,#data do
                -- dump(data[i],"+++++++++++++++++")
                local content = ChatModel:setSyetemdataStr(data[i])
                if content ==  nil then
                    content = ""
                end
                local kongge = "         "
                if data[i].name ~= nil then
                    local _,dstring =  RichTextExpand:parseRichText(data[i].name)
                    local widths = self:setRichwidth(dstring)
                    content = kongge..widths.." "..content

                end
                local width,height = FuncChat.getStrWandH(content,330)
                 -- echo("=======height====",height)
                local defhight = height + 15
                -- echo("=======height====",height)
                local ydefhight = defhight 
                
                if data[i].voice then
                    defhight = height + 25
                    ydefhight = height + 25
                elseif data[i].type == 6 then  ---邀请
                    defhight = height + 20
                    ydefhight = height + 30
                end
    
                local param={

                   data={data[i]},
                   createFunc=genPrivateObject,
                   perNums=1,
                   offsetX=10,
                   offsetY= 0,
                   widthGap=0,
                   itemRect={x=0,y=-ydefhight,width = 320,height = defhight},
                   perFrame=0,
                };
                -- dump(ChatModel.Chattypes,"111111111111111111111111111111")
                local types = ChatModel.Chattypes[data[i].chattype]
                --echo("=======types========================",types)
                if types == "system" then
                	sumindex =  sumindex + 1
                	table.insert(params,param)
                else
	                if  setinfodata[types] ~= nil then
	                    if setinfodata[types] == 1 then
	                        sumindex =  sumindex + 1
                            
	                        table.insert(params,param)
	                    end
	                end
	            end
                
            end
            if #params ~= 0 then
                --self.panel_tishi.scroll_1:setCanScroll( false )
                self.panel_tishi.scroll_1:setVisible(true)
                self.panel_tishi.scroll_1:styleFill(params);
                local nexts = 1
                if #params -1 ~= 0 then
                    nexts = #params
                end
                self.panel_tishi.scroll_1:gotoTargetPos(1,nexts);
            else
                self.panel_tishi.scroll_1:setVisible(false)
            end
            -- self.panel_tishi:setTouchedFunc(c_func(self.chatBtnClick, self),nil,true);
        end
    end

end
function ChatAddMainview:chatBtnClick()
    -- echo("111111111111111111111111111111")
    -- WindowControler:showWindow("ChatMainView");
end

function ChatAddMainview:currencySystemTextModel(_cell,_item)

    _cell:setVisible(true)
    _cell.mc_1:getViewByFrame(1).panel_ppap:setVisible(false)
    ---[[
    local Frames = _item.chattype
    if _item.chattype == 9 then  --系统
    	Frames = 1
    end


    _cell.mc_colorful:showFrame(Frames)
    local kongge = "         "
    if _item.name ~= nil then
    	_cell.txt_1:setString(_item.name..":")
    	local _,dstring =  RichTextExpand:parseRichText(_item.name)
    	local widths = self:setRichwidth(dstring)
    	kongge = kongge..widths.." "
    else
    	_cell.txt_1:setVisible(false)
    end
    _cell.scroll_1:setVisible(false)
    -- _cell.mc_colorful:showFrame(1)
    local content = ChatModel:setSyetemdataStr(_item)

    if content == nil then
        content = " "
    end
    local height,length = FuncCommUI.getStringHeightByFixedWidth(kongge..content,20,nil,330)
    -- echo("=========add2======height=============",height,length)
   -- _cell.rich_1:setPositionY(_cell.rich_1:getPositionY()+height*length+2)
    -- if length == 1 then
    --     -- _cell.rich_1:setPositionY(_cell.rich_1:getPositionY()-height/length+2)
    -- end
    --_cell.mc_colorful:setPositionY(_cell.mc_colorful:getPositionY()+15)
    _cell.rich_1:setPositionX(_cell.rich_1:getPositionX()+3)
    -- if _item.chattype == 9 then
    --     if length > 3 then
    --         _cell.rich_1:setPositionY( _cell.rich_1:getPositionY() - height/length + 10 )
    --     else
    --         _cell.rich_1:setPositionY( _cell.rich_1:getPositionY() + height/length-5)
    --     end
    -- elseif _item.chattype == 1 then
    --     if length <= 1 then
    --         _cell.rich_1:setPositionY( _cell.rich_1:getPositionY() + height+6 )
    --     else
    --         _cell.rich_1:setPositionY( _cell.rich_1:getPositionY() + height/length-5)
    --     end
    -- else
    -- 	if length <= 1 then
    -- 		_cell.rich_1:setPositionY( _cell.rich_1:getPositionY() + height+8 )
    -- 	else
    --         -- echo("222222222222222222222222222222222222")
    --         if length <= 2 then
    -- 		  _cell.rich_1:setPositionY( _cell.rich_1:getPositionY() + height/2-23/2 + 8)
    --         elseif length <= 3 then
    --             _cell.rich_1:setPositionY( _cell.rich_1:getPositionY() - height/(length+1) + 28)
    --         else
    --             _cell.rich_1:setPositionY( _cell.rich_1:getPositionY() - height/length + 18)
    --         end
    -- 	end
    -- end


     _cell.rich_1:setVisible(true)
     _cell.rich_1:setString(kongge..content)
    if _item.type == FuncChat.EventEx_Type.voice then
        self:voiceViewData(_cell,_item)
        _cell.rich_1:setVisible(false)
        _cell.mc_1:getViewByFrame(1).panel_ppap:setVisible(true)
    elseif _item.type == FuncChat.EventEx_Type.guildinvite then
        _cell.mc_1:showFrame(2)
        _cell.rich_1:setVisible(false)
        local kk = kongge
        self:sendInviteGuild(_cell,_item,kk)
    end
    -- if _item.voicedata  then
    --     self:voiceviewData(_cell,_item)
    --     _cell.rich_1:setVisible(false)
    --     _cell.mc_1:getViewByFrame(1).panel_ppap:setVisible(true)
    -- end
    
    -- _cell.rich_1:setfunc( callBack )
    -- dump(table,"可点击的文本")
    --]]

end

function ChatAddMainview:voiceViewData(_cell,_item)
    local _,dstring =  RichTextExpand:parseRichText(_item.name)
    local newstr = self:setRichwidth(dstring)
    local widths = FuncCommUI.getStringWidth(newstr, 20)
    local panel = _cell.mc_1:getViewByFrame(1).panel_ppap
    local txt_1 = panel.txt_1
    txt_1:setString(_item.name)
    local txt_x =  txt_1:getPositionX()
    local panel_qi = panel.panel_qi
    panel_qi:setPositionX(txt_x+widths+10)
    panel_qi.scale9_green:size(80,30)
    panel_qi.panel_tanhao:setPositionX(90)
    panel_qi.panel_tanhao:setVisible(false)
    -- local content = ChatModel:setSyetemdataStr(_item)
    panel.rich_1:setString("")--content)

    local data = json.decode(_item.content)
    panel_qi.txt_time:setString(data.time.."\"")



end

--处理仙盟邀请
function ChatAddMainview:sendInviteGuild(_cell,_item,kongg)
dump(_item,"消息详情",8)
   local _, dstring = RichTextExpand:parseRichText(_item.name)
    local newstr = self:setRichwidth(dstring)
    -- local widths = FuncCommUI.getStringWidth(newstr, 20)
    local panel = _cell.mc_1:getViewByFrame(2).panel_ppap
    local txt_1 = panel.txt_1
    txt_1:setString(_item.name)
    local txt_x =  txt_1:getPositionX()
    local panel_qi = panel.panel_qi
    panel_qi:setVisible(false)
    local info = json.decode(_item.content)
    local str = "\"<color=33ff00>"..info.level.."级<->仙盟<color=33ff00>"..info.name.."<->收人啦:"
    local desc = info.desc
    panel.rich_1:setString(kongg..str..desc)
    panel.btn_jr:setVisible(false)
    -- -:setTouchedFunc(c_func(self.inviteButton, self,_item),nil,true);
end


function ChatAddMainview:setRichwidth(string)
    -- echo("==========111111====================",string)
    local str = tostring(string)
    local fontSize = 13
    local lenInByte = #str
    local width = " "
    -- dump(lenInByte,"1111111111111")
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        -- echo("============curByte================",curByte)
        if curByte>0 and curByte<97 then   ---字符数字
            byteCount = 5
        elseif curByte>=97 and curByte<127 then   --字母
            byteCount = 1
        elseif curByte>=127 and curByte<192 then
            byteCount = 0
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
         -- if byteCount == 0 then

         -- end
        local char = string.sub(str, i, i+byteCount-1)
        -- i = i + byteCount -1
        -- echo("=========000==============",byteCount)
        if byteCount == 0 then
            width = width.." "
        elseif byteCount == 1 then
            width = width.." "
        elseif byteCount == 5 then
            width = width.."  "
        else
            width = width.." "
        end
    end
    return width
end

return ChatAddMainview
