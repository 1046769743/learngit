--[[
	Author: wk
	Date:2018-01-31
	Description: 纯文本弹幕

]]

local BarrageBaseCell = require("game.sys.view.barrage.BarrageBaseCell")
BarragePraiseAndText = class("BarragePraiseAndText",BarrageBaseCell)

local diffFrame = 2  --文本和赞的帧数

function BarragePraiseAndText:ctor(controler,view)
	BarragePraiseAndText.super.ctor(self,controler)
	self.ui = view
	self:addUIToview()
	self.ui.mc_1:showFrame(diffFrame)
	self.panel = self.ui.mc_1:getViewByFrame(diffFrame)
	self.randomData = nil
end

function BarragePraiseAndText:registerEvent()
	BarragePraiseAndText.super.registerEvent(self)


end

function BarragePraiseAndText:addUIToview()
	self.ui:setPosition(cc.p(0,0))
	self:addChild(self.ui)
end

--[[
data = {
	comment = "",--聊天信息
	istouch = false,--是否可以点击
	praiseNum = 100,--赞的数量‘
	myPraise = 1,0---自己是否赞过
}
]]
--初始化数据
function BarragePraiseAndText:initData(data)

	self.data = data
	self.panel.txt_1:setString(ChatModel:toStringExchangleImage(data.comment or "仙剑·六界情缘"))
	local praiseFrame = 1
	if data.myPraise >= 1 then
		praiseFrame = 1
		self.panel.mc_2:showFrame(praiseFrame)
	else
		praiseFrame = 2
		self.panel.mc_2:showFrame(praiseFrame)
	end
	local panel =  self.panel.mc_2:getViewByFrame(praiseFrame)
	local  praiseNum = data.praiseNum
	if praiseNum >= FuncRankAndcomments.GOODANDNOTGOOD then
		praiseNum = FuncRankAndcomments.GOODANDNOTGOOD
	end
	-- if self.data.systemName == nil then 
	-- 	if self.randomData == nil then
	-- 		self.randomData = math.random(1,50)
	-- 		self.data.praiseNum = self.randomData
	-- 		praiseNum = self.randomData
	-- 	end
	-- end
	panel.txt_1:setString(praiseNum or 0)
	panel.btn_1:setTouchedFunc(c_func(self.praiseBtn, self),nil,true);
	self:setPraisePos()
end
function BarragePraiseAndText:praiseBtn()
	-- echo("======self.data.myPraise==========",self.data.myPraise)
	-- if self.data.myPraise >= 1 then
	-- 	return 
	-- end
	local num = 1
	if self.data.systemName ~= nil then
		local function _callback(param)
			if param.result ~= nil then
				
				if self.data.myPraise >= 1 then
					self.data.myPraise = 0
					self.data.praiseNum = tonumber(self.data.praiseNum) - 1
					num = -1 
				else
					self.data.myPraise = 1
					self.data.praiseNum = tonumber(self.data.praiseNum) + 1 
					num = 1
				end
				self:UpTextData(self.data,num)
			end
		end

		local params = {
			system  = self.data.systemName,
			systemInnerIndex  = self.data.diifID,
			postId = self.data.postId,  
			type = 1,
		}
		local level =  FuncDataSetting.getOriginalData("PlotDanmu")
		if UserModel:level() >= level then
			RankAndcommentsServer:goodAndStopOnToServer(params, _callback)
		else
			_callback({result = true})
		end
	else
		
		if self.data.myPraise >= 1 then
			self.data.myPraise = 0
			num = -1 
			self.data.praiseNum = tonumber(self.data.praiseNum) - 1 
		else
			self.data.myPraise = 1
			num = 1
			self.data.praiseNum = tonumber(self.data.praiseNum) + 1 
		end
		self:UpTextData(self.data,num)
	end
end

--重新刷数据
function BarragePraiseAndText:UpTextData(data,num)

	self:initData(data)

	-- if data.myPraise >= 1 then
	-- 	praiseFrame = 1
	-- 	self.panel.mc_2:showFrame(praiseFrame)
	-- else
	-- 	praiseFrame = 2
	-- 	self.panel.mc_2:showFrame(praiseFrame)
	-- end
	-- local panel =  self.panel.mc_2:getViewByFrame(praiseFrame)
	-- local num = self.num + num
	-- panel.txt_1:setString(num or 0)
end
function BarragePraiseAndText:setPraisePos()
	local comment = self.data.comment
	-- echo("======comment=======",comment)
	comment = ChatModel:toStringExchangleImage(comment)
	local newstr,imagenumber = FuncChat.imageStrgetNewStr(comment) 
	local width =  tonumber(FuncCommUI.getStringWidth(newstr, 24))
	local x = 0
	if imagenumber >= 3 then
		-- local y = self.panel.rich_1:getPositionY()
		self.panel.rich_1:setPositionY(-10)
		
	end
	if imagenumber ~= 0 then
		width = width - imagenumber * 15
	end
	self.panel.mc_2:setPositionX(x+width+20)
	self.widths = width + 150
end


function BarragePraiseAndText:getCellSize()
	local size = {width = self.widths or 0,hight = 40}
	return size
end


return BarragePraiseAndText
