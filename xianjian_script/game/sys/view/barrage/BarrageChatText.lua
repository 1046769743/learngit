--[[
	Author: wk
	Date:2018-01-31
	Description: 聊天加标题的弹幕

]]

local BarrageBaseCell = require("game.sys.view.barrage.BarrageBaseCell")
BarrageChatText = class("BarrageChatText",BarrageBaseCell)

local diffFrame = 3  --纯文本的帧数

local chatType = {
	[1] = 1, --系统
	[2] = 2,--世界
	[3] = 3, --仙盟
}





function BarrageChatText:ctor(controler,view)
	BarrageChatText.super.ctor(self,controler)
	self.ui = view
	self:addUIToview()
	self.ui.mc_1:showFrame(diffFrame)
	self.panel = self.ui.mc_1:getViewByFrame(diffFrame)
end

function BarrageChatText:registerEvent()
	BarrageChatText.super.registerEvent(self)


end

function BarrageChatText:addUIToview()
	self.ui:setPosition(cc.p(0,0))
	self:addChild(self.ui)
end


--[[
data = {
	comment = "",--聊天信息
	istouch = false,--是否可以点击
	callback = ,--可点击跳转显示的东西--暂不需要
	titleType = ,--聊天的标题
	isvoice = true, 聊天中，是不是语音聊天
	voiceTime = ,--语音时间
	voiceID = , --语音ID
}
]]
--初始化数据
function BarrageChatText:initData(data)


	local titleImageW = 70  ---标题的宽度

	local _text = data.comment
	local maxLength = FuncBarrage.Maxlength
	-- local colorful = 1
	self.colorful = 1
	if data.titleType == FuncChat.CHAT_T_TYPE.system then
		self.colorful = 1
		_text = self:jieXiChatText(_text,data.titleType)
	elseif data.titleType == FuncChat.CHAT_T_TYPE.world then
		self.colorful = 2
	elseif data.titleType == FuncChat.CHAT_T_TYPE.tream then
		self.colorful = 3
	elseif data.titleType == FuncChat.CHAT_T_TYPE.troop then
		self.colorful = 6
	end


	self.panel.mc_colorful:showFrame(self.colorful)


	if data.isvoice then
		self.panel.mc_2:showFrame(2)
		local panel_qi = self.panel.mc_2:getViewByFrame(2).panel_qi
		panel_qi.txt_time:setString(voiceTime)
		panel_qi.scale9_green:size(200,30)
		panel_qi:setTouchedFunc(c_func(self.voiceButton, self,data),nil,true);
		self.widths = titleImageW + 200
	else
		self.panel.mc_2:showFrame(1)
		local rich_1 = self.panel.mc_2:getViewByFrame(1).rich_1
		_text = ChatModel:toStringExchangleImage( _text or "仙剑·六界情缘")
		local str,imagenumber  =  FuncChat.imageStrgetNewStr(_text)
		if imagenumber ~= 0 then
			local offY = 0
			if imagenumber >= 7 then
				offY = 12*2
			elseif imagenumber ==4 then
				offY = 12
			end
			_text = self:jieXiTextimage(_text)
			local length = string.len4cn2(_text)
			if length >= 51 then
				offY = 12
			end
			local y = rich_1:getPositionY()
			rich_1:setPositionY(y-offY)
		else
			_text = self:jieXiChatText(_text,data.titleType)
		end
		echo("=====_text======",_text)
		rich_1:setString(_text)
		local widths = tonumber(FuncCommUI.getStringWidth(_text, 24))
		self.widths = titleImageW + widths
	end
	

	
end
-- 获得控件数据宽度
function BarrageChatText:getCellSize()
	local size = {width = self.widths or 0,hight = 40}
	return size
end

function BarrageChatText:jieXiTextimage(text)
	local string,imageNum,txtArr = FuncChat.imageStrgetNewStr(text)

    local maxLength = FuncBarrage.Maxlength
    local strMaxLength = maxLength
    local strlength = 0
    local newArr = {}
    if txtArr ~= nil then
	    for i=1,#txtArr do
	    	local length = string.len4cn2(txtArr[i].str);
	    	if txtArr[i].image then  ---是图片的时候
	    		strMaxLength = strMaxLength - 6
	    	else
	    		strMaxLength = strMaxLength - length
	    	end
	    	if strMaxLength <= 0 then
	    		break
	    	end
	    	newArr[i] = txtArr[i]
	    end
	else
		return text  	
	end
	local newStr = ""
	for i=1,#newArr do
		if newArr[i].image then
			newStr = newStr..newArr[i].oldstr
		else
			newStr = newStr..newArr[i].str
		end
	end
	return newStr
end

function BarrageChatText:jieXiChatText(text,_type)
	local rich_1 = self.panel.mc_2:getViewByFrame(1).rich_1
	rich_1.text = text
	local maxLength = FuncBarrage.Maxlength
	if _type  ~= nil then
		if _type == FuncChat.CHAT_T_TYPE.system then
			maxLength = 38
		end
	end
	local txtArr =  rich_1:parseRichText() 
	-- dump(txtArr,"解析后数据的结构 ======")
	local newchar = ""
	local newArr = {}
	local newmax = maxLength
	-- echo("=======maxLength=======",maxLength)
	for i=1,#txtArr do
		local char = newchar..txtArr[i].char
		if char ~= nil then
			local length = string.len4cn2(char);
			if length > maxLength then
				local _text = string.subcn(txtArr[i].char,1,newmax/2)
				newArr[i] = {}
				newArr[i].char = _text.."···"
				newArr[i].color = txtArr[i].color
				break
			else
				newmax = newmax - string.len4cn2(txtArr[i].char)
				newchar = newchar..txtArr[i].char
				newArr[i] = txtArr[i]
			end
		end
	end
	local newchar = ""
	for i=1,#newArr do
		if newArr[i].color ~= nil then
			newchar = newchar.."<color ="..newArr[i].color..">"..newArr[i].char.."<->"
		else
			newchar = newchar..newArr[i].char
		end
	end
	return newchar
end





function BarrageChatText:voiceButton(data)
	echo("======播放语音======")
	local voiceID = data.voiceID
	ChatServer:onClickPlay(voiceID)
end

--重新刷数据
function BarrageChatText:UpTextData(data)
	self:initData(data)
end



return BarrageChatText

