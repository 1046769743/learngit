--[[
	Author: lxh
	Date:2018-05-02
	Description: 排行榜中仙盟排行信息查看界面
]]

local RankListGuildInfoView = class("RankListGuildInfoView", UIBase);

function RankListGuildInfoView:ctor(winName, _curSelectTag, _itemData, _guildInfo)
    RankListGuildInfoView.super.ctor(self, winName)
    self.itemData = _itemData
    self.rankTagType = _curSelectTag
    self._guildInfo = _guildInfo
end

function RankListGuildInfoView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI(self._guildInfo)
end 

function RankListGuildInfoView:registerEvent()
	RankListGuildInfoView.super.registerEvent(self);

	self.panel_bg.btn_close:setTouchedFunc(c_func(self.startHide, self))
	self:registClickClose("out")
end

function RankListGuildInfoView:initData()
	self.panel_guildInfo:setVisible(false)
	-- local guildInfo = RankListModel:getCachePlayerInfoByRid(self.itemData.rid)
	-- if guildInfo then
	-- 	self:updateUI(guildInfo)
	-- else		
	-- 	RankServer:getGuildInfo(self.itemData.rid, c_func(self.getGuildInfoCallBack, self))
	-- end
end

function RankListGuildInfoView:getGuildInfoCallBack(event)
	if event.result then
		local _guildInfo = event.result.data.guild
		RankListModel:cachePlayerInfoByRid(self.itemData.rid, _guildInfo)
		self:updateUI(_guildInfo)
	else
		echoError("获取玩家主线阵容信息返回数据报错")
	end
end

function RankListGuildInfoView:initView()
	self.panel_bg.txt_1:setString(GameConfig.getLanguage("#tid_ranklisttitle_1004"))
end

function RankListGuildInfoView:initViewAlign()
	-- TODO
end

function RankListGuildInfoView:updateUI(_guildInfo)
	local iconData = {
		borderId = _guildInfo.logo,
		bgId = _guildInfo.color,
		iconId = _guildInfo.icon,
	}
	self.panel_guildInfo.UI_1:initData(iconData)
	local afterName = FuncGuild.guildNameType[tonumber(_guildInfo.afterName)]
	self.panel_guildInfo.txt_1:setString(_guildInfo.name..afterName)
	self.panel_guildInfo.txt_2:setString(_guildInfo.level..GameConfig.getLanguage("#tid_ranklist_002"))
	self.panel_guildInfo.txt_4:setString(_guildInfo.leaderName)
	self.panel_guildInfo.txt_6:setString(_guildInfo.markId)
	local curNum = _guildInfo.members
	local guildData = FuncGuild.getGuildLevelByPreserve(_guildInfo.level)
	local totalNum = tonumber(guildData.nop)
	self.panel_guildInfo.txt_8:setString(curNum.."/"..totalNum)
	self.panel_guildInfo.txt_10:setString(_guildInfo.qqGroup)
	local notice = _guildInfo.notice
	if not notice or notice == "" then
		notice = FuncGuild.getdefaultNotice()
	end
	self.panel_guildInfo.txt_12:setString(notice)
	if GuildModel:isInGuild() then
		self.panel_guildInfo.btn_1:setVisible(false)
	else
		self.panel_guildInfo.btn_1:setVisible(true)
		self.panel_guildInfo.btn_1:setTouchedFunc(c_func(self.clickEnterGuildButton, self, _guildInfo.name, curNum, totalNum))
	end
	
	self.panel_guildInfo:setVisible(true)
end

function RankListGuildInfoView:clickEnterGuildButton(name, curNum, totalNum)
	if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.GUILD) then
		WindowControler:showTips(GameConfig.getLanguage("#tid_ranklisttips_2003"));
    	return
	end

	if curNum >= totalNum then
		WindowControler:showTips(GameConfig.getLanguage("#tid_ranklisttips_2002"))			
		return
	end

	if GuildModel:closeGuildTime() then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_023"))			
		return
	end

	GuildServer:sendAppAndAdd(self.itemData.rid, function ()			
			if UserModel:guildId() ~= "" then
				WindowControler:showTips(string.format(GameConfig.getLanguage("#tid_guildAddCell_005"), name))
			else
				WindowControler:showTips(GameConfig.getLanguage("#tid_guildAddCell_004"))
			end
			
			RankServer:getGuildInfo(self.itemData.rid, c_func(self.getGuildInfoCallBack, self))

		end)
end

function RankListGuildInfoView:deleteMe()
	-- TODO

	RankListGuildInfoView.super.deleteMe(self);
end

return RankListGuildInfoView;
