--
-- Author: LXH
-- Date: 2017-10-27
-- loading控制器


local NewLoadingControler = NewLoadingControler or {}

function NewLoadingControler:init()
	
end

function NewLoadingControler:isDataInArray(_array, _data)
    if _array == nil or table.length(_array) == 0 then
        return false
    end

    for k,v in pairs(_array) do
        if _data == v then
            return true
        end
    end
    return false
end


function NewLoadingControler:getLoadingNumberByTypeAndLevelId(_gameType, _withStory, _curRid)
    if not LoginControler:isLogin() then
        local loadingNumber = 101
        return loadingNumber
    end

    if _gameType == "guildBossPve" then
        _gameType = "pve"
    end
    if _curRid and tonumber(_curRid) and tonumber(_curRid) > 20100 and tonumber(_curRid) < 29999 then
        _gameType = "elite"
    end

    if _withStory == nil then
        _withStory = false
    end

    local onlineDays = HappySignModel:getOnlineDays()
    -- echo("\n\nonlineDays==", onlineDays)
    local passMaxMainRaidId = UserExtModel:getMainStageId()
    local passMaxEliteRaidId = UserExtModel:getEliteStageId()
    -- echo("\n\n_gameType ====", _gameType, "_curRid===", _curRid, "_withStory==", _withStory)
    local level = UserModel:level()
    local vipLevel = UserModel:vip()
    -- local systemOpenData = FuncCommon.getSysOpenData()
    local allDatas = FuncLoadingNew.getAllLoadingDatas()
    local onlineDayDatas = FuncLoadingNew.getDataByOnlineDays(onlineDays, allDatas)
    local loadingDataOld = FuncLoadingNew.getLoadingNumberByGameType(_gameType, allDatas)
    -- dump(onlineDayDatas, "\n\nonlineDayDatas=====")
    local loadingNumber = nil
    if _gameType == "pve" and _withStory == true then       
        local copyData = FuncLoadingNew.getLoadingNumberByLevelId(tostring(_curRid), loadingDataOld)
        -- dump(copyData, "\n\ncopyData===")
        loadingNumber = NewLoadingControler:getOneLoadingNumber(copyData)
    elseif _gameType == "pve" and _withStory == false then
        -- echo("\n\n_withStory===", _withStory)
        local allMemoryDataOld = FuncLoadingNew.getLoadingNumberByKeyAndValue("memory", "1")
        local allMemoryData = {}
        for i,v in ipairs(allMemoryDataOld) do
            if v.onlineDays == nil then
                table.insert(allMemoryData, v)
            elseif v.onlineDays and NewLoadingControler:isDataInArray(onlineDayDatas, v) == true then
                table.insert(allMemoryData, v)
            end
        end
        local nextLevelData = FuncLoadingNew.getLoadingNumberByNextLevel(level, allMemoryData)
        local levelData = FuncLoadingNew.getLoadingNumberByLevel(level, allMemoryData)
        local vipData = FuncLoadingNew.getLoadingNumberByVips(vipLevel, allMemoryData)

        -- dump(allMemoryData, "\n\nallMemoryData=====")
        -- dump(nextLevelData, "\n\nnextLevelData=====")
        -- dump(levelData, "\n\nlevelData=====")
        -- dump(vipData, "\n\nvipData=====")
        
        if nextLevelData and table.length(nextLevelData) > 0 then
            loadingNumber = NewLoadingControler:getOneLoadingNumber(nextLevelData)
        elseif levelData and table.length(levelData) > 0 then
            loadingNumber = NewLoadingControler:getOneLoadingNumber(levelData)
        elseif vipData and table.length(vipData) > 0 then
            loadingNumber = NewLoadingControler:getOneLoadingNumber(vipData)
        else
            local defaultData = FuncLoadingNew.getDefaultLoadingNumber(allMemoryData)
            -- dump(defaultData, "\n\ndefaultData==")
            loadingNumber = NewLoadingControler:getOneLoadingNumber(defaultData)
        end
    elseif _gameType == "elite" then
        -- echo("\n\n________elite___________")
        local loadingData = {}
        for i,v in ipairs(loadingDataOld) do
            if v.onlineDays == nil then
                table.insert(loadingData, v)
            elseif v.onlineDays and NewLoadingControler:isDataInArray(onlineDayDatas, v) == true then
                table.insert(loadingData, v)
            end
        end
        local copyData = FuncLoadingNew.getLoadingNumberByLevelId(_curRid, loadingData)
        local nextLevelData = FuncLoadingNew.getLoadingNumberByNextLevel(level, loadingData)
        local levelData = FuncLoadingNew.getLoadingNumberByLevel(level, loadingData)

        local vipData = FuncLoadingNew.getLoadingNumberByVips(vipLevel, loadingData)

        -- dump(loadingData, "\n\nloadingData=====")
        -- dump(copyData, "\n\ncopyData=====")
        -- dump(levelData, "\n\nlevelData=====")
        -- dump(vipData, "\n\nvipData=====")
        
        if copyData and table.length(copyData) > 0 then
            loadingNumber = NewLoadingControler:getOneLoadingNumber(copyData)
        elseif nextLevelData and table.length(nextLevelData) > 0 then
            loadingNumber = NewLoadingControler:getOneLoadingNumber(nextLevelData)
        elseif levelData and table.length(levelData) > 0 then
            loadingNumber = NewLoadingControler:getOneLoadingNumber(levelData)
        elseif vipData and table.length(vipData) > 0 then
            loadingNumber = NewLoadingControler:getOneLoadingNumber(vipData)
        else
            local defaultData = FuncLoadingNew.getDefaultLoadingNumber(loadingData)
            loadingNumber = NewLoadingControler:getOneLoadingNumber(defaultData)
        end
    elseif _gameType == "miniBattle" then
        local copyData = FuncLoadingNew.getLoadingNumberByLevelId(tostring(_curRid), loadingDataOld)
        -- dump(copyData, "\n\ncopyData===")
        loadingNumber = NewLoadingControler:getOneLoadingNumber(copyData)
    else
        local loadingData = {}
        for i,v in ipairs(loadingDataOld) do
            if v.onlineDays == nil then
                table.insert(loadingData, v)
            elseif v.onlineDays and NewLoadingControler:isDataInArray(onlineDayDatas, v) == true then
                table.insert(loadingData, v)
            end
        end
        local levelData = FuncLoadingNew.getLoadingNumberByLevel(level, loadingData)
        local vipData = FuncLoadingNew.getLoadingNumberByVips(vipLevel, loadingData)
        -- dump(loadingData, "\n\nloadingData=====")
        -- dump(levelData, "\n\nlevelData====")
        -- dump(vipData, "\n\nvipData=====")
        if levelData and table.length(levelData) > 0 then
            loadingNumber = NewLoadingControler:getOneLoadingNumber(levelData)
        elseif vipData and table.length(vipData) > 0 then
            loadingNumber =  NewLoadingControler:getOneLoadingNumber(vipData)
        else
            loadingNumber = NewLoadingControler:getOneLoadingNumber(loadingData)
        end 
    end

    if loadingNumber == nil then
        -- echo("\n\n_____________nil_____________")
        loadingNumber = NewLoadingControler:getOneLoadingNumber(FuncLoadingNew.getDataByLoadingType("5"))
    end

    -- echo("\n\n_____loadingNumber=====", loadingNumber)
    return loadingNumber
end

function NewLoadingControler:getLoadingNumberWhileLose(_gameType)
    local allDatas = FuncLoadingNew.getAllLoadingDatas()
    local onlineDayDatas = FuncLoadingNew.getDataByOnlineDays(onlineDays, allDatas)
    local allLoseDataOld = FuncLoadingNew.getLoadingNumberByKeyAndValue("lose", "1")
    local allLoseData = {}
        for i,v in ipairs(allLoseDataOld) do
            if v.onlineDays == nil then
                table.insert(allLoseData, v)
            elseif v.onlineDays and NewLoadingControler:isDataInArray(onlineDayDatas, v) == true then
                table.insert(allLoseData, v)
            end
        end
    local curTypeData = FuncLoadingNew.getLoadingNumberByGameType(_gameType, allLoseData)
    local level = UserModel:level()
    local vipLevel = UserModel:vip()
    -- dump(allLoseData, "\n\nallLoseData====")
    -- dump(curTypeData, "\n\ncurTypeData====")
    local vipData = FuncLoadingNew.getLoadingNumberByVips(vipLevel, curTypeData)
    -- dump(vipData, "\n\nvipData===")
    local loadingNumber = nil
    if vipData and table.length(vipData) > 0 then
        loadingNumber = NewLoadingControler:getOneLoadingNumber(vipData)
    else
        loadingNumber = NewLoadingControler:getOneLoadingNumber(curTypeData)
    end 

    if loadingNumber == nil then
        loadingNumber = NewLoadingControler:getOneLoadingNumber(FuncLoadingNew.getDataByLoadingType("5"))
    end

    return loadingNumber
end

function NewLoadingControler:getLoadingNumberByTypeAndStoryId(_gameType, _storyId)
    local loadingNumber
    local allDatas = FuncLoadingNew.getAllLoadingDatas()
    if _gameType == "pve" then
        -- echo("\n\n_________withStory_________  _storyId=", _storyId)
        local allStoryData = FuncLoadingNew.getLoadingNumberByKeyAndValue("storyId", _storyId)
        -- dump(allStoryData, "\n\nallStoryData===")
        loadingNumber = NewLoadingControler:getOneLoadingNumber(allStoryData)       
    end
    
    if loadingNumber == nil then
        -- local allDatas = FuncLoadingNew.getAllLoadingDatas()
        local loadingData = FuncLoadingNew.getDataByLoadingType("5")
        loadingNumber = NewLoadingControler:getOneLoadingNumber(loadingData)
    end

    return loadingNumber
end

-- function NewLoadingControler:getLoadingNumberByMemory()
--     local allMemoryData = FuncLoadingNew.getLoadingNumberByKeyAndValue("memory", "1")
--     local level = UserModel:level()
--     local vipLevel = UserModel:vip()
--     dump(allLoseData, "\n\nallMemoryData====")
--     local levelData = FuncLoadingNew.getLoadingNumberByLevel(level, allMemoryData) 
--     local vipData = FuncLoadingNew.getLoadingNumberByVips(vipLevel, allMemoryData)
--     dump(vipData, "\n\nvipData===")
--     if levelData and table.length(levelData) > 0 then
--         return NewLoadingControler:getOneLoadingNumber(levelData)
--     elseif vipData and table.length(vipData) > 0 then
--         return NewLoadingControler:getOneLoadingNumber(vipData)
--     else
--         return NewLoadingControler:getOneLoadingNumber(allLoseData)
--     end 
-- end

function NewLoadingControler:getOneLoadingNumber(_loadingData)
    if _loadingData and table.length(_loadingData) > 0 then
        if table.length(_loadingData) == 1 then
            return _loadingData[1].loadingNumber
        else
            local weightSum = 0
            for i,v in ipairs(_loadingData) do
                weightSum = weightSum + tonumber(v.weight)
            end

            local randomValue = RandomControl.getOneRandomInt(weightSum + 1, 1)
            local weight = 0
            local resultData 
            for i,v in ipairs(_loadingData) do
                if randomValue < weight then
                    break
                else
                    weight = weight + tonumber(v.weight)
                end
                resultData = v
            end

            return resultData.loadingNumber
        end
    end

    return nil
end

NewLoadingControler:init()

return NewLoadingControler