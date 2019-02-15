--[[
	Author: lichaoye
	Date: 2017-05-26
	挂机礼包tips界面-view
]]

local DelegatePkgTipsView = class("DelegatePkgTipsView",InfoTips1Base)

function DelegatePkgTipsView:ctor( winName, params, position )
	DelegatePkgTipsView.super.ctor(self, winName)
	self.__datas = params
	-- self.__datas = {
	-- 	ptype = 1,
	-- 	rewards = {
	-- 		"1,9641,1",
	-- 		"1,9641,1",
	-- 		"1,9641,1",
	-- 	}
	-- }
	-- self._pos = position
end

function DelegatePkgTipsView:loadUIComplete()
    self:registerEvent()
    self:updateUI()
end

function DelegatePkgTipsView:registerEvent()
    DelegatePkgTipsView.super.registerEvent(self)
    -- self:registClickClose("out")
end



function DelegatePkgTipsView:updateUI()
	-- 箱子
	self.mc_1:showFrame(self.__datas.ptype)
	-- 名字对应关系
	local nameTrans = {
		"tid_delegate_4001",
		"tid_delegate_4002",
		"tid_delegate_4003",
		"tid_delegate_4004",
		"tid_delegate_4005",
	}
	self.txt_1:setString(GameConfig.getLanguage(nameTrans[self.__datas.ptype]))
	-- 宝箱内容
	local str = nil
	if self.__datas.ptype < 5 then -- 宝箱
		str = {}
		for i,v in ipairs(self.__datas.rewards) do
			local _,nameWithNum = FuncCommon.getNameByReward( v )
			table.insert(str, nameWithNum)
		end

		str = table.concat(str, ",\n")
	else -- 经验
		str = GameConfig.getLanguageWithSwap("tid_delegate_4006", self.__datas.rewards)
	end

	self.txt_2:setString(str)
end

return DelegatePkgTipsView