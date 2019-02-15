--[[
	Author: wk
	Date:2018-01-31
	Description: 纯文本弹幕

]]

local BarrageBaseCell = require("game.sys.view.barrage.BarrageBaseCell")
BarrageText = class("BarrageText",BarrageBaseCell)

local diffFrame = 1  --纯文本的帧数

function BarrageText:ctor(controler,view)
	BarrageText.super.ctor(self,controler)
	self.ui = view

	self:addUIToview()
	self.ui.mc_1:showFrame(diffFrame)
	self.panel = self.ui.mc_1:getViewByFrame(diffFrame)

end

function BarrageText:addUIToview()
	-- local node = display.newNode()
	-- self:addChild(node)
	self.ui:setPosition(cc.p(0,0))
	self:addChild(self.ui)
	
end

function BarrageText:registerEvent()
	BarrageText.super.registerEvent(self)


end

--[[
data = {
	comment = "",--聊天信息
	istouch = false,--是否可以点击
}
]]
--初始化数据
function BarrageText:initData(data)
	local text = data.comment or "仙剑·六界情缘"
	local length = string.len4cn2( text);
	if length > FuncBarrage.Maxlength then
		text = string.subcn(text,1,FuncBarrage.Maxlength/2) .. "···"
	end
	local str = ChatModel:toStringExchangleImage(text)
	self.widths = tonumber(FuncCommUI.getStringWidth(str, 24)) + 10
	self.panel.txt_1:setString(str)
end

--获得控件宽度
function BarrageText:getCellSize()
	local size = {width = self.widths or 0,hight = 40}
	return size
end

--重新刷数据
function BarrageText:UpTextData(data)
	self:initData(data)
end



return BarrageText
