--
-- Author: lxh
-- Date: 2018-05-02 09:44:27
--
local RankListModel = class("RankListModel", BaseModel);

RankListModel.rankListType = {
	RANK_TYPE_LEVEL = 1,                  --等级排行
	RANK_TYPE_ABILITY = 2,                --战力排行
	RANK_TYPE_TREASURE = 3,				  --法宝排行
	RANK_TYPE_GUILD = 4,				  --仙盟排行
	RANK_TYPE_WONDERLAND_1 = 5,           --须臾仙境1排行
	RANK_TYPE_WONDERLAND_2 = 6,			  --须臾仙境2排行
	RANK_TYPE_WONDERLAND_3 = 7,           --须臾仙境3排行
	RANK_TYPE_ENDLESS = 8,                --无底深渊排行
	RANK_TYPE_PARTNER = 9,                --奇侠排行
	RANK_TYPE_CIMELIA = 10,               --神器排行
	RANK_TYPE_PARTNER_COUNT = 11,         --奇侠唤醒排行
	RANK_TYPE_PARTNER_AWAKE = 12,         --奇侠装备觉醒排行
	RANK_TYPE_TRIAL_DAILY_ABILITY = 31,   --试炼最强路人排行
}

--页签排序 与 类型的映射
RankListModel.rankTabsType = {
	RANK_TYPE_ABILITY = 1,
	RANK_TYPE_PARTNER = 2,
	RANK_TYPE_PARTNER_COUNT = 3,
	RANK_TYPE_PARTNER_AWAKE = 4,
	RANK_TYPE_CIMELIA = 5,	
	RANK_TYPE_TREASURE = 6,
	RANK_TYPE_GUILD = 7,
}

RankListModel.rankTabsKeys = {
	[1] = "RANK_TYPE_ABILITY",
	[2] = "RANK_TYPE_PARTNER",
	[3] = "RANK_TYPE_PARTNER_COUNT",
	[4] = "RANK_TYPE_PARTNER_AWAKE",
	[5] = "RANK_TYPE_CIMELIA",
	[6] = "RANK_TYPE_TREASURE",
	[7] = "RANK_TYPE_GUILD",	
}

function RankListModel:init(data)
    RankListModel.super.init(self, data)
    self.rankList = {}
    self.playerInfos = {}
    self.scrollParams = {}
    self.dataForSelf = {}
end

function RankListModel:setCurrentSelectTag(_rankType)
	self.curSelectedTag = _rankType
end

function RankListModel:getCurrentSelectTag()
	return self.curSelectedTag or self.rankTabsType.RANK_TYPE_ABILITY
end

function RankListModel:cacheRankListDataByType(_rankType, _data)
	self.rankList[tostring(_rankType)] = _data
end

function RankListModel:getCacheRankListDataByType(_rankType)
	return self.rankList[tostring(_rankType)]
end

function RankListModel:clearCacheRankListData()
	self.rankList = {}
end

function RankListModel:cachePlayerInfoByRid(_rid, _playerInfo)
	self.playerInfos[tostring(_rid)] = _playerInfo
end

function RankListModel:getCachePlayerInfoByRid(_rid)
	return self.playerInfos[tostring(_rid)]
end

function RankListModel:clearCachePlayerInfo()
	self.playerInfos = {}
end

function RankListModel:cacheScrollParamsByType(_rankType, _begainAndEnd)
	self.scrollParams[tostring(_rankType)] = _begainAndEnd
end

function RankListModel:getCacheScrollParamsByType(_rankType)
	return self.scrollParams[tostring(_rankType)]
end

function RankListModel:clearCacheScrollParams()
	self.scrollParams = {}
end

function RankListModel:setCacheRankListDataForSelfByType(_rankType, _dataForSelf)
	self.dataForSelf[tostring(_rankType)] = _dataForSelf
end

function RankListModel:getCacheRankListDataForSelfByType(_rankType)
	return self.dataForSelf[tostring(_rankType)]
end

function RankListModel:clearCacheRankListDataForSelf()
	self.dataForSelf = {}
end

RankListModel:init()

return RankListModel;





















