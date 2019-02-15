-- GuildMianPacketView
-- Author: Wk
-- Date: 2017-09-30
-- 公会创加入通用cell界面
local GuildMianPacketView = class("GuildMianPacketView", UIBase);

function GuildMianPacketView:ctor(winName)
    GuildMianPacketView.super.ctor(self, winName);
end

function GuildMianPacketView:loadUIComplete()
	self:registerEvent()
end 

function GuildMianPacketView:registerEvent()
	-- self.panel_1:setTouchedFunc(c_func(self.openRedPacket, self),nil,true);
end

function GuildMianPacketView:initData()
	
	local data = GuildRedPacketModel.notifyPacketArr

	-- dump(data,"=========红包推送的数据=======")
	self.panel_1:setVisible(false)
	self.panel_1.txt_1:setString("")
	if data ~= nil then
		local count = table.length(data)
		if count  > 0 then
			local isok =  GuildRedPacketModel:countIsOk()
			if not isok then
				return
			end
			self.panel_1.txt_1:setString(count)
			self.panel_1:setVisible(true)
		end
	end
	
end

function GuildMianPacketView:openRedPacket()
	local data = GuildRedPacketModel.notifyPacketArr
	local count = 0
	if data ~= nil then
		count = table.length(data)
	end
	local packetData = data[count]

	local function cellFunc()
		GuildRedPacketModel:removeMainRedPacket(packetData)
		self:initData()
	end
	GuildRedPacketModel:grabRedpacket(packetData,cellFunc)


end

function GuildMianPacketView:press_btn_close()
	
	self:startHide()
end


return GuildMianPacketView;
