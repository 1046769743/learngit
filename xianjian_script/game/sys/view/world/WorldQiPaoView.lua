--[[
	Author: lxh
	Date:2018-01-17
	Description: TODO
]]

local WorldQiPaoView = class("WorldQiPaoView", UIBase);

function WorldQiPaoView:ctor(winName, dataInfo, isPvp)
    WorldQiPaoView.super.ctor(self, winName)
    self.dataInfo = dataInfo
    self.isPvp = isPvp
end

function WorldQiPaoView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WorldQiPaoView:registerEvent()
	WorldQiPaoView.super.registerEvent(self);

	if not self.isPvp then
		EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, self.setBubbleString, self)
		EventControler:addEventListener(WorldEvent.WORLDEVENT_FIRST_PASS_RAID, self.setBubbleString, self)	
	end
end

function WorldQiPaoView:initData()
	self.chat = self.dataInfo.chat
	self.ctn_pos = self.dataInfo.pos
end

function WorldQiPaoView:initView()
	self.panel_qipao.rich_name:setString(self.chat)
	local _posX = self.ctn_pos.x
	local _posY = self.ctn_pos.y
	if self.isPvp then
		self.panel_qipao.mc_1:showFrame(2)
		self.offset_x = -233 
		self.offset_y = 45
	else
		local frame = self:setOffSetAndFrame(_posX, _posY)
		self.panel_qipao.mc_1:showFrame(frame)
	end
end

function WorldQiPaoView:setBubbleString()
	local curRaidId = WorldModel:getNextMainRaidId()
	local raidData = FuncChapter.getRaidDataByRaidId(curRaidId)
	local chat = raidData.chat
	local desStr = ""
	if not WorldModel:isRaidLock(curRaidId) then
		if chat and chat[1] then
			-- local raidName = GameConfig.getLanguage(raidData.name) 
			desStr = FuncTranslate._getLanguageWithSwap(chat[1], UserModel:name())
		end			
	else
		if chat and chat[2] then			
			local openLevel = raidData.condition[2].v 
			desStr = FuncTranslate._getLanguageWithSwap(chat[2], openLevel)
		end	
	end

	if tostring(self.chat) ~= tostring(desStr) then
		self.panel_qipao.rich_name:setString(desStr)
		self.chat = desStr
	end
end

function WorldQiPaoView:getOffset()
	return self.offset_x, self.offset_y
end

function WorldQiPaoView:setOffSetAndFrame(_posX, _posY)
	local frame = 1
	if _posX < 200 then
		frame = 1
		self.offset_x = 25
		self.offset_y = 45
	elseif _posX > 1000 then
		frame = 2
		self.offset_x = -49 - 233
		self.offset_y = 45
	elseif _posY < -400 then
		frame = 3
		self.offset_x = -125
		self.offset_y = 25 + 99
	else
		frame = 4
		self.offset_x = -125
		self.offset_y = -25
	end
	return frame
end

function WorldQiPaoView:updateBubbleStatus(_posX, _posY)
	local oldOffset_x = self.offset_x
	local oldOffset_y = self.offset_y
	
	local frame = self:setOffSetAndFrame(_posX, _posY)
	if oldOffset_x == self.offset_x and oldOffset_y == self.offset_y then
		return 
	else
		EventControler:dispatchEvent(WorldEvent.BUBBLE_NEED_CHANGED, {frame = frame})
	end
end

function WorldQiPaoView:setViewByFrame(frame)
	self.panel_qipao.mc_1:showFrame(frame)
end

function WorldQiPaoView:getIntervalTime()
	local appeartime = 1
	local displaytime = 3
	local intervaltime = 1
	if self.dataInfo ~= nil then
		local appear = self.dataInfo.appear
		local display = self.dataInfo.display
		local interval = self.dataInfo.interval
		local gametime = GameVars.GAMEFRAMERATE
		appeartime = math.floor(appear/gametime)
		displaytime = math.floor(display/gametime)
		intervaltime = math.floor(interval/gametime)
	end
	return appeartime,displaytime,intervaltime
end

function WorldQiPaoView:initViewAlign()
	-- TODO
end

function WorldQiPaoView:updateUI()
	-- TODO
end

function WorldQiPaoView:deleteMe()
	-- TODO

	WorldQiPaoView.super.deleteMe(self);
end

return WorldQiPaoView;