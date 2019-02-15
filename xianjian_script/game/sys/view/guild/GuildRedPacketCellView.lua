-- GuildRedPacketCellView
-- Author: Wk
-- Date: 2018-03-07
-- 公会抢红包控件单独的界面
local GuildRedPacketCellView = class("GuildRedPacketCellView", UIBase);

function GuildRedPacketCellView:ctor(winName,redpacketData,cellback,nextPacket)
    GuildRedPacketCellView.super.ctor(self, winName);
    self.redpacketData = redpacketData
    self.cellback = cellback
    self.nextPacket = nextPacket
end

function GuildRedPacketCellView:loadUIComplete()
	self:registClickClose("out",function ()
		GuildRedPacketModel:removeMainRedPacket(self.redpacketData)
		if GuildRedPacketModel.redPacketView then
			GuildRedPacketModel.redPacketView:initData()
		end
		self:press_btn_close()

	end)
	self:initData(self.redpacketData)

	if self.nextPacket then
		self.btn_next:setVisible(true)
		local data = GuildRedPacketModel.notifyPacketArr
		if data then
			if #data > 1 then
				self.btn_next:setVisible(true)
			else
				self.btn_next:setVisible(false)
			end
		else
			self.btn_next:setVisible(false)
		end
	else
		self.btn_next:setVisible(false)
	end
	self.btn_next:setTouchedFunc(c_func(self.nextRedPacket, self),nil,true);
end 


function GuildRedPacketCellView:nextRedPacket()
	echo("=======下一个红包===")
	GuildRedPacketModel:removeMainRedPacket(self.redpacketData)
	if GuildRedPacketModel.redPacketView then
		GuildRedPacketModel.redPacketView:initData()
	end
	self:press_btn_close()
	GuildRedPacketModel:openRedPacket()
end



function GuildRedPacketCellView:registerEvent()

end




function GuildRedPacketCellView:initData(itemData)
	local view = self.panel_1
	-- dump(itemData,"=====抢红包的数据情况====")
	local _avatar = itemData.avatar
	local _headId = itemData.head
	local _headFrameId = itemData.frame

	local _ctn = self.panel_1.panel_tou.ctn_touxiang
	-- UserHeadModel:setPlayerHeadAndFrame(_ctn,_avatar,_headId,_headFrameId)
	_ctn:anchor(0.5,0.5)
    _ctn:removeAllChildren()
    GuildRedPacketModel:setPlayerHead(_ctn,_avatar,_headId)
	GuildRedPacketModel:setPlayerFrame(_ctn,_headFrameId)


	local name = itemData.name 
	view.panel_tou.txt_name:setString(name)

	--显示资源
	local packetId = itemData.packetId
	local baseData = FuncGuild.getpacketDataById(packetId)
	local iconpath = FuncRes.iconRes(baseData.rewardType,baseData.rewardType)
	local icon = display.newSprite(iconpath)
	icon:setScale(0.4)
	view.ctn_1:removeAllChildren()
	view.ctn_1:addChild(icon)

	view.mc_1:showFrame(1)

	view.btn_qiang:setTouchedFunc(c_func(self.grabRedpacket, self,itemData),nil,true);
	view.mc_1:getViewByFrame(1).rich_1:setString(GameConfig.getLanguage(baseData.description))

end



--抢红包
function GuildRedPacketCellView:grabRedpacket(itemData)
	-- echo("===========抢红包ID=========",itemData._id)
	-- local playdata  = GuildModel:getMemberInfo(itemData.rid)
	-- if playdata then
		local function cellFunc()
			if self.cellback then
				 self.cellback()
			end
			self:press_btn_close()
		end
		GuildRedPacketModel:grabRedpacket(itemData,cellFunc)
	-- else
	-- 	WindowControler:showTips("该玩家已被剔除仙盟,红包不存在")--GameConfig.getLanguage("#tid_guild_redpacket_002"));
	-- 	self:press_btn_close()
	-- end

end







function GuildRedPacketCellView:press_btn_close()
	GuildRedPacketModel:setSendRedPacketIndex(false)
	self:startHide()
end


return GuildRedPacketCellView;
