--[[
	Author: wk
	Date:2018-01-31
	Description: 语音的弹幕
]]

local BarrageBaseCell = require("game.sys.view.barrage.BarrageBaseCell")
BarrageVoice = class("BarrageVoice",BarrageBaseCell)

local diffFrame = 4  --纯文本的帧数

function BarrageVoice:ctor(controler,view)
	BarrageVoice.super.ctor(self,controler)
	self.ui = view
	self.ui.mc_1:showFrame(diffFrame)
	self.panel = self.ui.mc_1:getViewByFrame(diffFrame)
end

function BarrageVoice:registerEvent()
	BarrageVoice.super.registerEvent(self)


end

--[[
data = {
	comment = "",--聊天信息
	istouch = false,--是否可以点击
	voice = true,
	voiceID = ,--语音ID
	voiceTime = ，--语音时间
}
]]
--初始化数据
function BarrageVoice:initData(data)
	self.panel.panel_qi.txt_time:setString(data.voiceTime or 1)
	self.panel.panel_qi.scale9_green:size(200,30)  --固定一个大小
	self.widths = 200
	self.panel.panel_qi:setTouchedFunc(c_func(self.voiceButton, self,data),nil,true);
end

function BarrageVoice:voiceButton(data)
	echo("======播放语音======")
	local voiceID = data.voiceID
	ChatServer:onClickPlay(voiceID)
end

--重新刷数据
function BarrageVoice:UpTextData(data)
	self:initData(data)
end


function BarrageVoice:getCellSize()
	local size = {width = self.widths or 0,hight = 40}
	return size
end


return BarrageVoice

