
FuncPlot = {}
local plotCfg = nil
local plotID = 1



function FuncPlot.init(  )
    plotCfg= Tool:configRequire("plot.PlotTem") 
end 

function FuncPlot.getPlotData( plotID )
    local _ps = plotCfg
    local data = plotCfg[tostring(plotID)]
    if not data then
        echoError("这个plotId数据没有",plotID)
    end
    return data
end 


--[[
获取order对应的一个 row
]]
function FuncPlot.getStepPlotData( plotId,oreder )
    local datga = FuncPlot.getPlotData(plotId)
    if(datga==nil)then
        echoError("剧情对话配置FuncPlot.plotID: ",plotId,"  没有找到","当前索引的id:",id);
    end
    return datga[tostring(oreder)] or {}
end 



function FuncPlot.getLanguage(key,repacName)
    return FuncTranslate.getPlotLanguage(key,nil,repacName)
end

--通过plotId 获取音效
function FuncPlot.getSoundsById(plotId,avatar)
    local data = plotCfg[tostring(plotId)]
    if not data then
        echoError("这个plotId数据没有",plotId)
    end
    local sounds = {}
    for i,v in pairs(data) do
        if tonumber(avatar) == 101 then
            if v.bsound then
                table.insert(sounds, v.bsound)
            end
        else
            if v.gsound then
                table.insert(sounds, v.gsound)
            end
        end
    end
    return sounds
end
-- 判断是否是序章剧情
function FuncPlot.isXuZhangAnim( animId )
    if not animId then
        return false
    end
    local xuzhangT = {"100000","100001","100010","100011","100020","100021"}
    if table.indexof(xuzhangT,tostring(animId) ) then
        return true
    else
        return false
    end
end

--
function FuncPlot.getAllPlotsByEvents( events )
    local plots = {}
    if not empty(events ) then

        for kk,vv in pairs(events) do
            for k,v in pairs(vv) do
                local keys = string.split(k, "#")
                if keys[1] == "plot" then
                    --
                    table.insert(plots, keys[2])
                end
            end

        end
    end
    return plots
end
-- 剧情的一键查错
function FuncPlot.yijianchacuo( animId )
    local allEvents =FuncAnimPlot.getAllEvents( animId )
    local cfgData = FuncAnimPlot.getRowData(animId)

    -- 遍历事件 
    local eventBodys = {}
    local actionT = {}
    local effSource = {}
    local lockPlotT = {}
    local unLockPlotT = {}

    local insertffectFunc = function (str)
        for m,n in pairs(str) do
            local effect = n.string
            if effect ~= "" then
                local effectName = string.split(effect, "#")
                for mm,nn in pairs(effectName) do
                    local nnn = string.split(nn, ",")
                    local data = {}
                    data.effectName = nnn[1]
                    data.frame = n.frame
                    table.insert(effSource, data)
                end    
            end      
        end
    end
    for kk,vv in pairs(allEvents) do
        for k,v in pairs(vv) do
            local keys = string.split(k, "#")
            if keys[1] == "action" then
                table.insert(eventBodys, keys[2])
                insertffectFunc(v)
                if actionT[keys[2]] then
                    table.insert(actionT[keys[2]], keys[3])
                else
                    actionT[keys[2]] = {}
                    table.insert(actionT[keys[2]], keys[3])
                end
                
            elseif keys[1] == "effect1" then
                table.insert(eventBodys, keys[2])
                insertffectFunc(v)
            elseif keys[1] == "effect2" then
                table.insert(eventBodys, keys[2])
                for m,n in pairs(v) do
                    local effect = n.string  
                    insertffectFunc(v)
                end
            elseif keys[1] == "plot" then
                table.insert(lockPlotT, keys[2])
            elseif keys[1] == "scene" then
                
            elseif keys[1] == "chat" then
                
            elseif keys[1] == "lock" then
                for m,n in pairs(v) do
                    if n.name == "lock" then
                        local str = n.string
                        local strT = string.split(str, ",")
                        local data = {}
                        data.plotId = strT[2]
                        data.plotOrder = strT[3]
                        table.insert(unLockPlotT, data)
                    end
                end
            elseif keys[1] == "animend" then
                  
            elseif keys[1] == "emoticon" then
                
            elseif keys[1] == "sound" then
               
            elseif keys[1] == "shake" then
                
            elseif keys[1] == "change" then
                
            elseif keys[1] == "InsertPictures" then
                
            end
        end

    end

    --检查body是否都配了
    for ii,vv in pairs(eventBodys) do
        if cfgData[vv] ~= nil then
            local bodyId = vv
            local sid = cfgData[bodyId]
            if sid == "empty" then
                echo("剧情中空body 是 == "..bodyId)
            elseif sid == "1" then
                echo("剧情中主角 是 == "..bodyId)
            else
                -- 查找其他body资源是否都有
                echo("此时bodyId === ",vv)
                FuncRes.checkSpineBySourceId(sid,nil,true )
            end
        else
            echoError("animbonenew 表里没配 "..vv,"  剧情id== ",animId)
        end
    end

    dump(effSource, "________特效_________", 5)
    -- 检查 特效资源是否存在
    for ii,vv in pairs(effSource) do
        local effName = vv.effectName
        if effName and effName ~= "" then
            local name = FuncArmature.getSpineName(effName)
            if name == nil then
                echoError("SpineAniConfig 中找不到特效名对应的资源",name)
                
            else 
                local effSpine = ViewSpine.new(name,{},nil,nil)
                if not effSpine then
                    echoError(effName,"空不存在这样的资源")
                end
            end
        end
    end

    -- 检查是否所有的plot 都可以解锁
    dump(lockPlotT, "上锁plot", 4)
    dump(unLockPlotT, "解锁plot", 4)
    for i,v in pairs(lockPlotT) do
        local isFand = false
        for m,n in pairs(unLockPlotT) do
            if n.plotId == v then
                isFand = true
                local data = plotCfg[tostring(v)]
                if not data then
                    echoError("plotTem 中没有id == ",v,"的数据")
                else
                    if not data[n.plotOrder] then
                        echoError("plotTem 表中id == ",v,"的数据 中 没有order == ",n.plotOrder)
                    end
                end
            end
        end

        if not isFand then
            echoError("剧情plot锁",v,"没有对应的解锁plotid")
        end
    end

    -- 检查所有的动作是否存在
    for i,v in pairs(actionT) do
        local sid = cfgData[i]
        if sid ~= "empty" then
            local sourceCfg = FuncTreasure.getSourceDataById(sid)
            for m,n in pairs(v) do
                if not sourceCfg[n] then
                    echoError(i,"对应的source表里的动作没配",n)
                end
            end
        end
        
    end
end

return FuncPlot  
