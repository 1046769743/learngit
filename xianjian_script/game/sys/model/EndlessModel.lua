--
-- Author: lxh
-- Date: 2018-01-19 16:50:48
--
local EndlessModel = class("EndlessModel", BaseModel)

--[[
UserModel:
self._data = {
        ["1"] = {
            endless= {
                ["1"] = 2,
                ["5"] = 2,
            },
            rewardBit = 6,
        },
        ["2"] = {
            endless = {
            },
            rewardBit = 7,
        },
        ["3"] = {
            endless = {
                ["11"] = 2,
                ["12"] = 2,
                ["13"] = 1,
                ["14"] = 1,
                ["15"] = 2,
            },
            rewardBit = 0,
        },
        ["4"] = {
            endless = {
                ["16"] = 2,
                ["17"] = 2,
                ["18"] = 1,
                ["19"] = 1,
                ["20"] = 2,
            },
            rewardBit = 0,
        },
        ["5"] = {
            endless = {
                ["21"] = 2,
                ["22"] = 2,
                ["25"] = 2,
            },
            rewardBit = 2,
        }
    }

UserExtModel:
endlessId = 15
]]
function EndlessModel:init(d)
	EndlessModel.super.init(self, d)
    
	self:initData()
end

function EndlessModel:initData()
    self.endlessStatus = FuncEndless.endlessStatus

    -- dump(self._data, "\n\nself._data===")
    self.historyEndlessId = UserExtModel:getEndlessId()
    -- echoError("\n\nself.historyEndlessId===", self.historyEndlessId)
    EventControler:dispatchEvent(ChallengeEvent.YIMENG_RED_POINT_CHANGE)
end

function EndlessModel:updateRedPointStatus()
    local showRedPoint = false
    if UserExtModel:getEndlessId() > 0 then
        local highestFloor = FuncEndless.getFloorAndSectionById(UserExtModel:getEndlessId())
        for i = highestFloor, 1, -1 do
            for index = 1, 3, 1 do
                local boxStatus = self:getBoxStatusByFloorAndBoxType(i, index)
                if boxStatus == FuncEndless.boxRewardType.CANRECEIVED then
                    showRedPoint = true
                    return showRedPoint
                end
            end  
        end
    end

    return showRedPoint
end

function EndlessModel:updateData(d)
    EndlessModel.super.updateData(self, d)

    -- dump(self._data, "\n\nself._data=========")
    EventControler:dispatchEvent(EndlessEvent.ENDLESS_BOX_STATUS_CHANGED)
end

function EndlessModel:setFriendAndGuildData(_data)
    self.friendAndGuildData = _data
end

function EndlessModel:getFriendAndGuildData()
    return self.friendAndGuildData or {}
end

function EndlessModel:updateEndlessId()
    self.historyEndlessId = UserExtModel:getEndlessId()
end

function EndlessModel:getEndlessData()
    return self._data
end

--获取最高通关记录
function EndlessModel:getHistoryEndlessId()
    return UserExtModel:getEndlessId()
end

--获取最高纪录所在的层数
function EndlessModel:getHistoryEndlessFloorAndSection()
    self.historyFloor, self.historySection = FuncEndless.getFloorAndSectionById(UserExtModel:getEndlessId())
    return self.historyFloor, self.historyFloor
end

--获取最高纪录下一关卡所在层数
function EndlessModel:getNextEndlessIdAndFloorAndSection()
    local nextEndlessId = UserExtModel:getEndlessId() + 1
    local nextFloor, nextSection = FuncEndless.getFloorAndSectionById(nextEndlessId)
    return nextEndlessId, nextFloor, nextSection
end

--检查是否需要进入下一层
function EndlessModel:checkEnterNextFloor()
    local _, nextFloor, _ = self:getNextEndlessIdAndFloorAndSection()
    if nextFloor > self.historyFloor then
        return true
    end
    return false
end

--根据endlessId来获取该关卡的状态
function EndlessModel:getStatusByEndlessId(endlessId)
    local status = 0
    --如果是比自己的历史endlessId还大 说明还未通关
    if tonumber(endlessId) > tonumber(UserExtModel:getEndlessId()) then
        status = self.endlessStatus.NOT_PASS
    else
        --通过id获得该id所在的层数
        local floor, section = FuncEndless.getFloorAndSectionById(endlessId)
        local endless = nil
        if self._data[tostring(floor)] then
            endless = self._data[tostring(floor)].endless
        end       
        --如果不存在说明该关卡已经三星通关
        if endless then
            if not endless[tostring(endlessId)] then
                status = self.endlessStatus.THREE_STAR
            else
                if FuncCommon:getBattleStar(endless[tostring(endlessId)]) == 1 then
                    status = self.endlessStatus.ONE_STAR  
                else
                    status = self.endlessStatus.TWO_STAR
                end
            end
        else
            status = self.endlessStatus.THREE_STAR
        end        
    end

    return status
end

--根据层数获取当前层星级宝箱的领取状态 111 每一位表示一个宝箱的状态  1 为已领取  0 为未领取 2为可领取
function EndlessModel:getBoxStatusByFloorAndBoxType(_floor, _boxRewardType)
    local boxStatus = FuncEndless.boxRewardType.NOTRECEIVED

    if self._data[tostring(_floor)] then
        local rewardBit = self._data[tostring(_floor)].rewardBit
        local toBit = number.splitByNum(rewardBit, 2)
        local bit_table = {0, 0, 0}
        if #toBit == 3 then
            bit_table[1] = toBit[1]
            bit_table[2] = toBit[2]
            bit_table[3] = toBit[3]
        elseif #toBit == 2 then
            bit_table[1] = toBit[1]
            bit_table[2] = toBit[2]
        elseif #toBit == 1 then
            bit_table[1] = toBit[1] 
        end
        if bit_table[_boxRewardType] == 1 then
            boxStatus = FuncEndless.boxRewardType.HASRECEIVED
        else
            local stars = self:getCurStarsByFloor(_floor)
            local star_table = FuncEndless.getFloorStarById(_floor)
            if stars >= tonumber(star_table[_boxRewardType]) then              
                boxStatus = FuncEndless.boxRewardType.CANRECEIVED
            end
        end
    else
        local endlessIds = FuncEndless.getBossIdsByFloorId(_floor)
        if tonumber(endlessIds[#endlessIds]) <= tonumber(UserExtModel:getEndlessId()) then
            boxStatus = FuncEndless.boxRewardType.HASRECEIVED
        end
    end
    return boxStatus
end

function EndlessModel:getCurStarsByFloor(_floor)
    local endlessIds = FuncEndless.getBossIdsByFloorId(_floor)
    local length = #endlessIds
    local endless = nil
    if self._data[tostring(_floor)] then
        endless = self._data[tostring(_floor)].endless
    end
    local stars = 0
    if endless then
        for i = endlessIds[1], endlessIds[length], 1 do
            if endless[tostring(i)] then
                stars = stars + FuncCommon:getBattleStar(endless[tostring(i)])
            elseif tonumber(i) <= tonumber(UserExtModel:getEndlessId()) then
                stars = stars + 3
            end
        end
    else
        for i = endlessIds[1], endlessIds[length], 1 do
            if tonumber(i) <= tonumber(UserExtModel:getEndlessId()) then
                stars = stars + 3
            end
        end
    end
    
    return stars
end

function EndlessModel:setChallengeNewEndless(_endlessId)
    if tonumber(_endlessId) > tonumber(UserExtModel:getEndlessId()) then
        self.isChallengeNew = true
    else
        self.isChallengeNew = false
    end
end

function EndlessModel:isChallengeNewEndless()
    return self.isChallengeNew
end

function EndlessModel:setCurrentFloor(_floor)
    self.currentView = _floor
end

function EndlessModel:getCurrentFloor()
    return self.currentView
end

function EndlessModel:enterEndlessRankView(_beginRank, _endRank)
    local rankType = FuncEndless.rankType 
    local beginRank = _beginRank
    local endRank = _endRank
    local rankData = self:getRankCacheData()
    RankServer:getRankList(rankType, beginRank, endRank, function (event)
            if event.result then
                rankData = event.result.data
                self:saveRankCacheData(rankData)
            end
            WindowControler:showWindow("EndlessBossRankView", rankData)
        end)
end
function EndlessModel:getRankList()
    local rankType = FuncEndless.rankType 
    local rankList =  RankServer:getRankList(rankType, nil, nil, nil)
end

function EndlessModel:saveRankCacheData(rankData)
    self.rankCacheData = rankData
end

function EndlessModel:getRankCacheData()
    return  self.rankCacheData or {}
end

function EndlessModel:getFriendAndGuildEndlessData(_friendList, _guildList, _endlessId)
    local allDataList = {}
    local rid_table = {}
    for k,v in pairs(_friendList) do
        if v._id ~= UserModel:rid() and v.userExt and v.userExt.endlessId 
            and tonumber(v.userExt.endlessId) >= tonumber(_endlessId) then
            local data = {}
            data.rid = v._id
            data.name = v.name
            data.head = v.head
            data.frame = v.frame
            data.avatar = v.avatar
            data.endlessId = v.userExt.endlessId
            data.endlessTime = v.userExt.endlessTime
            table.insert(rid_table, v._id)
            table.insert(allDataList, data)
        end
    end

    for k,v in pairs(_guildList) do
        if tostring(k) ~= UserModel:rid() and v.endlessId and tonumber(v.endlessId) >= tonumber(_endlessId) then
            local data = {}
            data.rid = tostring(k)
            data.name = v.name
            data.head = v.head
            data.frame = v.frame
            data.avatar = v.avatar
            data.endlessId = v.endlessId
            data.endlessTime = v.endlessTime
            if not table.indexof(rid_table, tostring(k)) then
                table.insert(allDataList, data)
                table.insert(rid_table, tostring(k))
            end         
        end
    end

    local sortByEndlessTime = function (a, b)
        return a.endlessTime <  b.endlessTime
    end

    table.sort(allDataList, sortByEndlessTime)

    return allDataList
end

function EndlessModel:getFriendAndGuildRankList(_friendList, _guildList)
    local allRankList = {}
    local rid_table = {}
    for k,v in pairs(_friendList) do
        if v.userExt and v.userExt.endlessId then
            local data = {}
            data.head = v.head
            data.rid = v._id
            data.name = v.name
            data.frame = v.frame
            data.avatar = v.avatar
            data.level = v.level
            data.endlessId = v.userExt.endlessId
            data.endlessTime = v.userExt.endlessTime
            table.insert(rid_table, v._id)
            table.insert(allRankList, data)
        end
    end

    for k,v in pairs(_guildList) do
        if tostring(k) ~= UserModel:rid() and v.endlessId then
            local data = {}
            data.rid = tostring(k)
            data.head = v.head
            data.name = v.name
            data.frame = v.frame
            data.avatar = v.avatar
            data.level = v.level
            data.endlessId = v.endlessId
            data.endlessTime = v.endlessTime
            if not table.indexof(rid_table, tostring(k)) then
                table.insert(allRankList, data)
                table.insert(rid_table, tostring(k))
            end         
        end
    end

    if UserExtModel:endlessId() > 0 then
        local self_data = {
            rid = UserModel:rid(),
            level = UserModel:level(),
            name = UserModel:name(),
            head = UserModel:head(),
            frame = UserModel:frame(),
            avatar = UserModel:avatar(),
            endlessId = UserExtModel:endlessId(),
            endlessTime = UserExtModel:endlessTime(),
        }
        if not table.indexof(rid_table, UserModel:rid()) then
            table.insert(allRankList, self_data)
            table.insert(rid_table, UserModel:rid())
        end    
    end


    local sortFunc = function (a, b)
        if tonumber(a.endlessId) > tonumber(b.endlessId) then
            return true
        elseif tonumber(a.endlessId) < tonumber(b.endlessId) then
            return false
        end

        if tonumber(a.endlessTime) < tonumber(b.endlessTime) then
            return true
        else
            return false
        end
    end

    table.sort(allRankList, sortFunc)

    for i,v in ipairs(allRankList) do
        v.rank = i
    end

    return allRankList
end

function EndlessModel:setTheFastData(data)
    self.fastData = data
end

function EndlessModel:getTheFastData()
    return self.fastData
end

function EndlessModel:setCurEndlessId(_endlessId)
    self.curEndlessId = _endlessId
end

function EndlessModel:getCurEndlessId()
    return self.curEndlessId
end

function EndlessModel:setInitFloor(_floorId)
    self.initFloor = _floorId
end

function EndlessModel:getInitFloor()
    return self.initFloor
end

--获得最大重数
function EndlessModel:getCurrentTopFloor()
    local curEndlessId = UserExtModel:endlessId()
    -- if curEndlessId <= 0 then
    --     return 0
    -- else
    --     local curFloor, curSection = FuncEndless.getFloorAndSectionById(curEndlessId)
    --     local sections = FuncEndless.getSectionNumById(curFloor)
    --     if tonumber(curSection) < tonumber(sections) then
    --         return curFloor - 1
    --     else
    --         return curFloor
    --     end
    -- end  
    return curEndlessId or 0
end

function EndlessModel:setCurChallengeEndlessId(_endlessId)
    self.curChallengeEndlessId = _endlessId
end

function EndlessModel:getCurChallengeEndlessId()
    return self.curChallengeEndlessId or 1
end

--第一场进战斗时将battleUsers信息存起来 然后第二场结束发给服务端
function EndlessModel:cacheBattleUsers(_battleUsers)
    self.battleUsers = _battleUsers
end

function EndlessModel:getCacheBattleUsers()
    return self.battleUsers
end

function EndlessModel:clearCacheBattleUsers()
    self.battleUsers = nil
end

--存第一场战斗出手次数 用于关卡评论使用  因为现在无底深渊是两场战斗
function EndlessModel:setHandleCount(_handleCount)
    self.handleCount = _handleCount
end

function EndlessModel:getHandleCount()
    return self.handleCount
end

return EndlessModel