--[[
	Author: TODO
	Date:2018-07-10
	Description: TODO
]]

local GuildExploreCostEnergy = class("GuildExploreCostEnergy", UIBase);

function GuildExploreCostEnergy:ctor(winName,costNums,callFunc)
    GuildExploreCostEnergy.super.ctor(self, winName)
    self.costNums = costNums
    self.callFunc = callFunc
end

function GuildExploreCostEnergy:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildExploreCostEnergy:registerEvent()
	GuildExploreCostEnergy.super.registerEvent(self);
	--注册精力发生变化事件
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLOREEVENT_ENERGYCHANGED, self.updateUI,self)
	self.btn_1:setTap(c_func(self.handCloseUI,self))
	self.btn_2:setTap(c_func(self.pressCostBtn,self))
	self:registClickClose("out",c_func(self.handCloseUI,self))

	if FuncGuildExplore.moveWithOutSure then
		self:pressCostBtn()
	end
end



--确认运动
function GuildExploreCostEnergy:pressCostBtn(  )

	--如果能量不够
	if GuildExploreModel:getEnegry( ) < self.costNums  then
		
		WindowControler:showWindow("GuildExploreBuyEnergy")
		-- self:startHide()
		
	else
		self:startHide()
		--那么直接开始走了
		if self.callFunc then
			self.callFunc()
		end
	end
end


function GuildExploreCostEnergy:initData()
	-- TODO
end

function GuildExploreCostEnergy:initView()
	-- TODO
end

function GuildExploreCostEnergy:initViewAlign()
	-- TODO
end

function GuildExploreCostEnergy:updateUI()
	self.txt_2:setString(tostring(self.costNums))
end

function GuildExploreCostEnergy:handCloseUI(  )
	echo("___开始关闭---")
	self:startHide()
	EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLORE_CLOSEMAPPATH )
end


return GuildExploreCostEnergy;
