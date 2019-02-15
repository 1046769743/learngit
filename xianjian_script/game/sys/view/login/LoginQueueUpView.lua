--[[
	Author: ZhangYanguang
	Date:2018-06-06
	Description: 登录排队界面(剩余时间真实计算，剩余人数动态模拟)
]]

local LoginQueueUpView = class("LoginQueueUpView", UIBase)

function LoginQueueUpView:ctor(winName)
	LoginQueueUpView.super.ctor(self, winName)

	local queueData = LoginControler:getQueueData()
	-- 可以登录的时间戳
	self.loginTimeStamp = queueData.queueTime
	self.queueNum = queueData.queueNum
	self.leftNum = self.queueNum

	-- 总共等待的秒数
	self.waitTotalSec = queueData.waitTotalSec
	
	self.leftSec = self.loginTimeStamp - TimeControler:getTime()

	-- echo("\nself.waitTotalSec=",self.waitTotalSec)
	-- echo("self.loginTimeStamp=",self.loginTimeStamp,TimeControler:getTime())
	-- echo("leftSec=",self.leftSec)
end

function LoginQueueUpView:loadUIComplete()
	self:registerEvent()
	self:initView()
	self:updateUI()
end

function LoginQueueUpView:initView()
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
end

function LoginQueueUpView:registerEvent()
	self.btn_1:setTap(c_func(self.startHide,self))
end

function LoginQueueUpView:updateFrame()
	if not self.frameCount then
		self.frameCount = 1
	elseif self.frameCount > GameVars.GAMEFRAMERATE then
		self.frameCount = 1
	else
		self.frameCount = self.frameCount + 1
	end

	if self.frameCount == GameVars.GAMEFRAMERATE then
		if self.leftSec > 0 then
			self.leftSec = self.leftSec - 1
			self:updateUI()
		end
	end
end

function LoginQueueUpView:updateUI()
	-- 剩余时间
	local leftTimeStr = Tool:formatLeftTime(self.leftSec)
	self.panel_1.txt_5:setString(leftTimeStr)

	self:calLeftNum()
	self.panel_1.txt_4:setString(self.leftNum)

	-- 自动关闭
	if self.leftSec <= 0 then
		self:delayCall(c_func(self.startHide,self), 0.1)
	end
end

function LoginQueueUpView:calLeftNum()
	local leftNum = self.leftNum
	-- 剩余排队人数
	if self.waitTotalSec <= 0 then
		leftNum = 0
	else
		local value = RandomControl.getOneRandomInt(4,1)
		-- local percent = self.leftSec / self.waitTotalSec
		-- leftNum = math.ceil(self.leftNum * percent * value)
		-- 平均每秒减去的人数
		local avg = nil
		if self.leftSec <= 0 then
			avg = self.leftNum
		else
			avg = self.leftNum / self.leftSec
		end

		local minus = value / 2 * avg
		leftNum = math.ceil(leftNum - minus)
		-- echo("avg=",avg)
		-- echo("minus=",minus)
		-- echo("leftNum=",leftNum)
	end

	if (leftNum <= 0 and self.leftSec > 0) or self.leftSec == 0 then
		leftNum = self.leftSec
	elseif leftNum >= self.queueNum then
		leftNum = self.queueNum
	end

	self.leftNum = leftNum
end

function LoginQueueUpView:startHide()
	LoginQueueUpView.super.startHide(self)
	-- 如果排队时间结束，自动登录
	if self.leftSec <= 0 then
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_QUEUE_TIME_END)
	else
		-- 如果没结束，清空排队时间
		LoginControler:clearQueueTime()
	end
end

return LoginQueueUpView

