-- ChatSetview
-- Author Wk
-- time  2017/05/26 14:10

local ChatSetview = class("ChatSetview", UIBase);

function ChatSetview:ctor(_winName)
    ChatSetview.super.ctor(self, _winName);
    self.setdata = {}
    self.chattypetable = {
    	[1]  = "world",
    	[2] = "guild",
    	[3] = "team",
    	[4] = "private",
	}
	self.voicetypetable = {
    	[1]  = "vworld",
    	[2] = "vguild",
    	[3] = "vteam",
    	[4] = "vlove"--"vprivate",
	}
end
function ChatSetview:loadUIComplete()
    self:registerEvent()
    -- self:registClickClose(-1, c_func( function()
    --        self:clickButtonClose()
    -- end , self))
	local  function _callback()
		self:clickButtonClose()
	end
	self:registClickClose("out",_callback);
    -- self.btn_close:setTap(c_func(self.clickButtonClose,self));
    self:getChannelInfo()

    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_Chat_114"))
    self.UI_1.btn_close:setVisible(false)
    self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.clickButtonClose,self));
end

function ChatSetview:registerEvent()
	ChatSetview.super.registerEvent(self);
	
end

function ChatSetview:getChannelInfo()
	-- local callback = function ( param )
	-- 	dump(param.param,"设置信息")
	-- 	-- self:setdata()
	-- end
	self:setViewdata()   --测试
	self:showvoice()
	self:mainChannelInfo()
end
function ChatSetview:setViewdata(data)
	-- self.setdata = {
	-- 	world = 0,
	-- 	guild = 0,
	-- 	team = 0,
	-- 	private = 0,
	-- }
	self.setdata = ChatModel:getChatSetinfo()
	self.setchatVoicelist = ChatModel:getChatVoiceinfo()
end

function ChatSetview:mainChannelInfo()  --主屏显示
	dump(self.setdata,"设置信息1111111111")
	if ChatModel:getSetBarrageShow(FuncChat.Chat_Set_Type[1]) then
		self.panel_1.panel_1.mc_1:showFrame(2)--系统
	else
		self.panel_1.panel_1.mc_1:showFrame(1)--系统
	end
	if ChatModel:getSetBarrageShow(FuncChat.Chat_Set_Type[2]) then
		self.panel_1.panel_2.mc_1:showFrame(2)--世界
	else
		self.panel_1.panel_2.mc_1:showFrame(1)--世界
	end
	if ChatModel:getSetBarrageShow(FuncChat.Chat_Set_Type[3]) then
		self.panel_1.panel_3.mc_1:showFrame(2)--仙盟
	else
		self.panel_1.panel_3.mc_1:showFrame(1)--仙盟
	end
	-- if ChatModel:getSetBarrageShow(FuncChat.Chat_Set_Type[4]) then
	-- 	self.panel_1.panel_4.mc_1:showFrame(2)  --缘伴
	-- else
	-- 	self.panel_1.panel_4.mc_1:showFrame(1)  --缘伴
	-- end

	if self.setchatVoicelist.vworld == 1 then
		self.panel_2.panel_1.mc_1:showFrame(2)--世界
	else
		self.panel_2.panel_1.mc_1:showFrame(1)--世界
	end
	if self.setchatVoicelist.vguild == 1 then
		self.panel_2.panel_2.mc_1:showFrame(2)--仙盟
	else
		self.panel_2.panel_2.mc_1:showFrame(1)--仙盟
	end
	if self.setchatVoicelist.vteam == 1 then
		self.panel_2.panel_3.mc_1:showFrame(2)--队伍
	else
		self.panel_2.panel_3.mc_1:showFrame(1)--队伍
	end
	-- if self.setchatVoicelist.vlove == 1 then
	-- 	self.panel_2.panel_4.mc_1:showFrame(2)  --缘伴
	-- else
	-- 	self.panel_2.panel_4.mc_1:showFrame(1)  --缘伴
	-- end

	-- self.panel_1.panel_4:setVisible(false)
	-- self.panel_1.txt_4:setVisible(false)

	-- self.panel_3.txt_1:setString("缘伴")
	-- self.panel_3.panel_2:setVisible(false)
	-- self.panel_3.txt_2:setVisible(false)
	-- self.panel_3.panel_3:setVisible(false)
	-- self.panel_3.txt_3:setVisible(false)
	-- self.panel_3.panel_4:setVisible(false)
	-- self.panel_3.txt_4:setVisible(false)
	-- self.panel_3.panel_5:setVisible(false)
	-- self.panel_3.txt_5:setVisible(false)
	
	for i=1,3 do
		self.panel_1["panel_"..i]:setTouchedFunc(c_func(self.settouchmc, self,i))
	end

	for i=1,3 do
		self.panel_2["panel_"..i]:setTouchedFunc(c_func(self.setVoicTouchmc, self,i))
	end
end


function ChatSetview:setVoicTouchmc(index)
	local stringtype = self.voicetypetable[index]
	local value = 0
	if self.setchatVoicelist[stringtype] == 1 then
		self.setchatVoicelist[stringtype] = 0
		value = 0
		self.panel_2["panel_"..index].mc_1:showFrame(1)
	else
		value = 1
		self.setchatVoicelist[stringtype] = 1
		self.panel_2["panel_"..index].mc_1:showFrame(2)
	end

	local callback = function (_param)
		-- dump(_param.result,"设置问题")
		local setinfo = _param.result.data.dirtyList.u.options
		ChatModel:setChatSetinfo(setinfo)
		EventControler:dispatchEvent("REFRESHSETINFO");
	end
	local param = {}
	param.key = index + 4
	param.value = value
	OptionsServer:setOptions( param ,callback)

end




function ChatSetview:settouchmc(index)
	

	local inshow =	ChatModel:getSetBarrageShow(FuncChat.Chat_Set_Type[index]) 


	local stringtype = self.chattypetable[index]
	local isshow = false

	if inshow then
		isshow = false
		self.panel_1["panel_"..index].mc_1:showFrame(1)
	else
		isshow = true
		self.panel_1["panel_"..index].mc_1:showFrame(2)
	end

	local _type = FuncChat.Chat_Set_Type[index]

	ChatModel:setChatbarrageModeData(_type,isshow)

	EventControler:dispatchEvent(BarrageEvent.BARRAGE_CHAT_SET_SHOW_EVENT)


	-- ChatModel:setChatSetinfo(self.setdata)
	-- local callback = function (_param)
	-- 	-- dump(_param.result,"设置问题")
	-- 	local setinfo = _param.result.data.dirtyList.u.options
	-- 	ChatModel:setChatSetinfo(setinfo)
	-- 	EventControler:dispatchEvent("REFRESHSETINFO");
	-- end
	-- local param = {}
	-- param.key = index
	-- param.value = value
	-- ChatServer:Setattribute( param ,callback)

end

function ChatSetview:showvoice()  ---语音显示
	self.panel_2.panel_1.mc_1:showFrame(1)
	self.panel_2.panel_2.mc_1:showFrame(1)
	self.panel_2.panel_3.mc_1:showFrame(1)
	-- self.panel_2.panel_4.mc_1:showFrame(1)
end






function ChatSetview:clickButtonClose()
    self:startHide()
end
return ChatSetview
