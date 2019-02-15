-- TitleModel    称号数据
local TitleModel = class("TitleModel", BaseModel);

local times = 6   --延迟时间
local sumtimes = 24*60*60  ---总时间

function TitleModel:init(titlelist,privileges)
    TitleModel.super.init(self, titlelist)
    -- dump(titlelist,"称号数据")
    self.hisData = {}
    table.deepMerge(self.hisData,titlelist)
    -- dump(privileges,"特权列表数据")
    -- echo("======当前穿戴===============",UserExtModel:currentTitle())
    self:registerEvent()
    echo(UserExtModel:currentTitle())
    self.servetitlelist = titlelist
    self.alltitledata = {}
    self.gettitleID = UserExtModel:currentTitle() or ""     ---穿戴有个userExt里面有个title
    self.privileges = privileges
    self.alltitledata = {
        titles = {}
    }
    self:getQuestData()
    -- self:titledata(titlelist)  --称号列表数据
    self:ontimesenghome()
    self:sendHomeMainViewred()

end
function TitleModel:registerEvent()
    EventControler:addEventListener(TitleEvent.HONOR_REFRESH_TITLE, self.titletaskcomplete, self);
    --主线变化事件
    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.sendHomeMainViewred, self);

    EventControler:addEventListener("TITLE_ONTIME", self.onTimeReFreshEvent, self);
    
end

---六界第一刷新的时候数据刷新
function TitleModel:titletaskcomplete()
    local alltitle = FuncTitle.getAllTitleData()  --- 所有称号
    for k,v in pairs(alltitle) do
        if v.conditionType == nil then
            local honorrid = HomeModel:getHonorDataRid()
            if honorrid ~= nil then
                local isAction = 0
                if UserModel:rid() == tostring(honorrid) then
                    if self.servetitlelist[tostring(k)] ~= nil then
                        local expireTime = self.servetitlelist[tostring(k)].expireTime or 0
                        if expireTime  < TimeControler:getServerTime()  then
                            expireTime = TimeControler:getServerTime() + sumtimes
                        end
                        self.servetitlelist[tostring(k)] = 
                            { 
                                isActivate =  self.servetitlelist[tostring(k)].isActivate or isAction,
                                expireTime = expireTime or TimeControler:getServerTime() + sumtimes,
                            }
                    else
                        self.servetitlelist[tostring(k)] =  {isActivate = isAction,expireTime = TimeControler:getServerTime() + sumtimes}
                    end
                    EventControler:dispatchEvent(TitleEvent.HONOR_GET_COM)
                    self:sendHomeMainViewred()
                end
            end
        end
    end
end
function TitleModel:sendHomeMainViewred()
    local show =  self:sendHomeRed()
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, 
        {redPointType = HomeModel.REDPOINT.PLAYERINFO.TITLE, isShow = show})
end
--称号变化刷新数据回调
function TitleModel:updateData(data)
    TitleModel.super.updateData(self, data)
    dump(data,"称号变化数据")
    table.deepMerge(self.hisData,data)

    -- self.godFormula = self._data
end

function TitleModel:getHisData( )
    return self.hisData
end
--[[
    self.alltitledata = {
        titles = { 
            "101" = {isAction = 0,expireTime = -1}  isAction  0 获得未激活  1 获得已激活   
            "103" = {isAction = 0,expireTime = -1}  expireTime -1 是永久 >0 限时称号
            "104" = {isAction = 0,expireTime = 500} 
        }
    }

]]
--判断任务是否完成  放到一个表中
function TitleModel:getQuestData()
    local completetable = {}
    local alltitledata = FuncTitle.getAllTitleData()  --- 所有称号
    self.alltitledata = {
        titles = {}
    }
    for k,v in pairs(alltitledata) do
        if v.completeCondition ~= nil then
            local completedata  = TargetQuestModel:isMainLineQuestFinish(k,FuncTitle.titlettype.title_limit)
            if completedata then
                v.id = tonumber(k)
                table.insert(completetable,v)
            end
        end
    end
    for i=1,#completetable do  ----获得的称号
        self.alltitledata.titles[tostring(completetable[i].id)] =  {isAction = 0,expireTime = -1}
    end
    self:titledata(self.servetitlelist)  --称号列表数据
end
function TitleModel:titledata(titlelist)
    if table.length(titlelist) ~= 0 then
        for k,v in pairs(titlelist) do
            if self.alltitledata.titles[k] ~= nil then
                self.alltitledata.titles[k].isAction = v.isActivate
                self.alltitledata.titles[k].expireTime = v.expireTime or -1
            else
                self.alltitledata.titles[k] = {isAction = v.isActivate or 0 ,expireTime = v.expireTime or -1}
            end
        end
    end
    
    if self.alltitledata.titles[tostring(self.gettitleID)] ~= nil then
        local expireTime = self.alltitledata.titles[tostring(self.gettitleID)].expireTime
        -- echo("=======1=======2====3====",expireTime,TimeControler:getServerTime(),expireTime-TimeControler:getServerTime() )
        if expireTime ~= nil then
            if expireTime ~= -1  then
                if expireTime < TimeControler:getServerTime() then  ---超时不佩戴
                    self.gettitleID = ""   --未佩戴
                end
            end
        end
    end
end
--[["称号数据" = {
    "101" = {
        "isActivate" = 1
    }
    "104" = {
        "isActivate" = 1
    }
    "201" = {
        "isActivate" = 1
    }
    "202" = {
        "isActivate" = 1
    }
}]]
--设置所有称号的激活情况
function TitleModel:setalltitledataisAction(titlelist)
    -- dump(self.servetitlelist,"111111111111111111")
    -- self.servetitlelist
    if titlelist ~= nil then
        for k,v in pairs(titlelist) do
            if self.servetitlelist[k] ~= nil then
                self.servetitlelist[k].isActivate = v.isActivate
            else
                self.servetitlelist[k] = {}
                self.servetitlelist[k].isActivate = v.isActivate
            end
        end
    end
    -- dump(self.servetitlelist,"2222222222222222")
    self:titledata(self.servetitlelist)  --称号列表数据
    
end
--限时穿戴到时回调函数
function TitleModel:titleEventControler()
    if self.gettitleID ~= "" then
        local titledata = FuncTitle.byIdgettitledata(self.gettitleID)
        if titledata.titleType == FuncTitle.titlettype.title_limit then
            self.gettitleID = ""
            WindowControler:showTips(GameConfig.getLanguage("#tid_title_001"));
        end
    end
    EventControler:dispatchEvent(TitleEvent.TitleEvent_ONTIME_CALLBACK)
end

function TitleModel:ontimesenghome() 
    if self.alltitledata.titles ~= nil then
        if table.length(self.alltitledata.titles) ~= 0 then
            if self.alltitledata.titles[tostring(self.gettitleID)] ~= nil then
                local expireTimes = self.alltitledata.titles[tostring(self.gettitleID)].expireTime - TimeControler:getServerTime()
                if expireTimes > 0 then
                    TimeControler:startOneCd("TITLE_ONTIME",expireTimes+2 )
                end
            end
        end
    end
end

--刷新时间到了，更新的问题
function TitleModel:onTimeReFreshEvent()
    if HomeModel:getHonorDataRid() ~= UserModel:rid() then
        self:titleEventControler()
    end
end
--根据称号类型获得类型里面的数据  排序  
function TitleModel:byTtetypegetTteData(titletype)
    local alldata = table.copy(FuncTitle.bytypegetData(titletype))
    -- dump(alldata,"排序前的数据")
    self:getQuestData()
    local havedata = {}
    local nodehavedata = {}
    -- dump( self.alltitledata.titles,"22222称号数据",8)
    for k,v in pairs(alldata) do
        if self.alltitledata.titles[tostring(v.id)] ~= nil then
            -- if self.alltitledata.titles[tostring(v.id)].isAction ~= 0 then
                v.title = self.alltitledata.titles[tostring(v.id)]
                table.insert(havedata,v)
            -- end
        else
            if v.title ~= nil then
                v.title = nil
            end
            table.insert(nodehavedata,v)
        end
    end

    havedata = self:activationsorting(havedata)
    nodehavedata = self:getsorting(nodehavedata)

    -- dump(havedata,"排序后1的数据",6)
    -- dump(nodehavedata,"排序后2的数据",6)

    if #havedata ~= 0 then
        local newhavedata = {}
        for k,v in pairs(havedata) do
            if v.title.isAction == 0 then
                table.insert(newhavedata,1,v)
            else 
                table.insert(newhavedata,v)
            end
        end
        havedata = {}
        havedata = newhavedata

    end

        if table.length(nodehavedata) ~= 0 then

            local newTab = {}
            for k,v in pairs(nodehavedata) do
                local conditionType = v.conditionType
                if conditionType ~= nil and v.titleType ~= 4 then
                    if newTab[conditionType] == nil then
                        newTab[conditionType] = {}
                        newTab[conditionType][1] = v
                    else
                        table.insert(newTab[conditionType],v)
                    end
                else
                    newTab[1] = {}
                    newTab[1][1] = v
                end
            end
            local storeTab = {}
            local index = 1
            -- dump(newTab,"111111=======")
            for k,v in pairs(newTab) do
                local newstarArr = self:gettitleQualitysorting(v)
                storeTab[index] = newstarArr[1]
                index = index + 1
            end

            -- dump(storeTab,"22222222222222222=======")
            nodehavedata = storeTab
        end

    local allnewdata = {}
    for k,v in pairs(havedata) do
        table.insert(allnewdata,v)
    end
    for k,v in pairs(nodehavedata) do
        table.insert(allnewdata,v)
    end
        -- dump(havedata,"排序后1的数据",6)
    -- dump(nodehavedata,"排序后3的数据",6)
     -- dump(allnewdata,"排序后3的数据",6)
    return allnewdata
end   

--获得排序
function TitleModel:gettitleQualitysorting(alldata)
    local table_sort = function (a,b)
        if a.titleQuality < b.titleQuality then
            return true
        else
            return false
        end
    end

    table.sort(alldata,table_sort)
    return alldata
end
--获得排序
function TitleModel:getsorting(alldata)
    local table_sort = function (a,b)
        -- 不知道为什么会传入两个相同的
        if a.id == b.id then
            return false
        end
        if a.titleQuality < b.titleQuality then
            return true
        elseif a.titleQuality > b.titleQuality  then
            return false
        end  

        if a.conditionType < b.conditionType then
            return true
        elseif a.conditionType > b.conditionType  then
            return false
        end 

        return tonumber(a.id) < tonumber(b.id)
    end

    table.sort(alldata,table_sort)
    return alldata
end
--激活排序 和 佩戴排序
function TitleModel:activationsorting(alldata)
    if #alldata == 0 then
        return alldata
    end
    local table_sort = function (a,b)
        -- 不知道为什么会传入两个相同的
        if a.id == b.id then
            return false
        end

        if a.titleQuality < b.titleQuality then
            return true
        elseif a.titleQuality > b.titleQuality  then
            return false
        end  

        if a.conditionType < b.conditionType then
            return false
        elseif a.conditionType > b.conditionType  then
            return true
        end 

        return tonumber(a.id) > tonumber(b.id)
    end

    table.sort(alldata,table_sort)
    -- for k,v in pairs(alldata) do
    --     v.title.
    -- end
    return alldata
end


--称号属性显示
function TitleModel:getDesStaheTable(des,_type)
    if des == nil then
        return ""
    end
    local buteData = FuncChar.getAttributeData()
    local buteName = GameConfig.getLanguage(buteData[tostring(des.attr)].name)
    local str = nil
    local desvalue = nil
    if des.type == 2 then   --万分比
        desvalue = (des.value/100).."%<->"
    elseif des.type == 3 then  --固定值
        desvalue = des.value.."<->"
    end
    if _type == nil then
        str = buteName..": <color=009407>+"..desvalue
    else
        str = buteName..": <color=F3BB47>+"..desvalue
    end
    return str
end
--称号非战斗属性
function TitleModel:getNotStaheTable(des)
    local privileId = des.id
    local priviletype = des.type
    local privilevalue = des.value
    local desname = GameConfig.getLanguage("#tid3127")
    local str = ""
    if priviletype == 1 then --万分比
        local values = privilevalue/100
        str = desname..values.."%"
    elseif priviletype == 2 then    --固定值
        str = desname..privilevalue
    end
    return str
end
---获得当前穿戴的称号Id
function TitleModel:gettitleids()
    -- echo("==========1111111111=========",self.gettitleID)
    return self.gettitleID
end
function TitleModel:settitleid( titleid )
    self.gettitleID = titleid
end

---显示玩家称号  （传入ctn 和 称号Id）
function TitleModel:showtitle(titleID,_ctn)
    _ctn:removeAllChildren()
    if titleID ~= "" then
        local titlesprite = FuncTitle.bytitleIdgetpng(titleID) 
        local titleicon = display.newSprite(titlesprite)
        titleicon:setScale(0.8)
        _ctn:addChild(titleicon)
    end
end

--获得战斗力添加 总值
function TitleModel:getAllSumBattle()
    local battle,notbattle,sumbattle = self:getAllAttribute()
    if sumbattle ~= nil then
        return sumbattle
    end
    return 0
end
-- --属性
-- function TitleModel:getInitAttr(titledata)
--     local  battle,notbattle,sumbattl = FuncTitle.ByTitleIdgetbattle(titledata)(titledata)
--     local dataMap = {}
--     for _key,_value in pairs(battle) do
--         local _data = {
--             key = _value.attr,
--             value = _value.value,
--             mode = _value.type,
--         }
--         dataMap[_key] = _data
--     end
--     -- dump(dataMap,"称号属性",7)
--     return dataMap
-- end
-- --总战力
-- function TitleModel:ByTitleUIdGetsumbattl(titledata)
--     local  battle,notbattle,sumbattl = FuncTitle.ByTitleIdgetbattle(titledata)(titledata)
--     return  sumbattl
-- end
-- --万分比战力
-- function TitleModel:ByTitleIdgetsumWBbattl(titledata)
    
--     return  0
-- end
--获得所有属性
function TitleModel:getAllAttribute()
    if self.alltitledata == nil then
        return nil,nil,0
    end
    if self.alltitledata.titles == nil then
        return nil,nil,0
    end
    for k,v in pairs(self.alltitledata.titles) do
        if v.expireTime == -1  or v.expireTime > TimeControler:getServerTime() then
        else
            self.alltitledata.titles[k] = nil
        end
    end


    return FuncTitle.ByTitleIdgetbattle(self.alltitledata.titles)
end

--属性排序
function TitleModel:tableorder(battletable)
    local partner_table_sort = function (a,b)
        -- 不知道为什么会传入两个相同的
        -- local _typea = FuncTitle.byIdgettitledata(tonumber(a.id)).titleType
        -- local _typeb = FuncTitle.byIdgettitledata(tonumber(b.id)).titleType
        if a.order < b.order then
            return true
        else
            return false
        end
    end
    table.sort(battletable,partner_table_sort)
    return battletable
end
function TitleModel:battletostring()
    local battle,notbattle,sumbattle = self:getAllAttribute()
    local neworderbattle = {}
    for i=1,#battle do
        local order =  FuncChar.getAttributeOrderById(battle[i].attr)
        battle[i].order = order
    end
    battle = self:tableorder(battle)

    local newbattle = {}
    for i=1,#battle do
        local str = TitleModel:getDesStaheTable(battle[i])
        newbattle[i] =str 
    end
    local newnewbattle = {}
    for i=1,#notbattle do
        local str = TitleModel:getNotStaheTable(notbattle[i])
        newnewbattle[i] =str 
    end

    return newbattle,newnewbattle
end

function TitleModel:getLeafsign()
    -- self.alltitledata.titles
    local index = 1 -- 默认第一个
    self:getQuestData()
    if self.gettitleID == "" then
        index = self:bygetalltitledataToIndex()
    else
        local titledata = FuncTitle.byIdgettitledata(self.gettitleID)
        index = titledata.titleType
    end
    return index
end
function TitleModel:tablesort(alldata)
    local partner_table_sort = function (a,b)
        -- 不知道为什么会传入两个相同的
        -- local _typea = FuncTitle.byIdgettitledata(tonumber(a.id)).titleType
        -- local _typeb = FuncTitle.byIdgettitledata(tonumber(b.id)).titleType
        if a.id > b.id then
            return false
        else
            return true
        end
    end
    table.sort(alldata,partner_table_sort)
    return alldata
end
function TitleModel:bygetalltitledataToIndex()
    local indexs = 1
    local newtable = {}
    for k,v in pairs(self.alltitledata.titles) do
        v.id = tonumber(k)
        newtable[indexs] = v
        indexs = indexs + 1
    end
    newtable = self:tablesort(newtable)
    -- dump(newtable,"4444444444444444444")
    for i=1,#newtable do
        if newtable[i].isAction == 0 then
            local titileid = newtable[i].id
            return FuncTitle.byIdgettitledata(tonumber(titileid)).titleType
        end
    end

    for k,v in pairs(self.alltitledata.titles) do
        if v.isAction  == 0 then
            return FuncTitle.byIdgettitledata(tonumber(k)).titleType
        end
    end
    return 1
end
function TitleModel:titletypeRedShow()
    self:getQuestData()
    local redPoint = {}
    for i=1,table.length(FuncTitle.titlettype) do
        redPoint[i] =  false
    end
    -- dump(self.alltitledata,"称号的所有数据 ======")
    if self.alltitledata.titles ~= nil then
        if table.length(self.alltitledata.titles) ~= 0 then
            for k,v in pairs(self.alltitledata.titles) do
                local titleid = tonumber(k)
                local titleType = FuncTitle.byIdgettitledata(tonumber(k)).titleType
                -- echo("========0000===============",titleType)
                if v.isAction == 0 then
                    -- echo("========11111===============",titleType)
                    if  tonumber(v.expireTime) < 0 then
                        redPoint[tonumber(titleType)] = true
                    else
                        if v.expireTime > TimeControler:getServerTime() then
                            redPoint[tonumber(titleType)] = true
                            -- echo("========22222===============",titleType)
                        end
                    end
                else 
                    if v.isAction ~= nil then
                        if v.isAction ~= 1 then
                            if v.expireTime > TimeControler:getServerTime() then
                                redPoint[tonumber(titleType)] = true
                                -- echo("========22222===============",titleType)
                            end
                        end
                    end
                end
            end
        end
    end
    -- dump(redPoint,"11111111111111111111111")
    return redPoint
end
--主城左上角红点显示    ---详情里面也可以调用
function TitleModel:sendHomeRed()
    local isopen,valuer,_type  = FuncCommon.isSystemOpen("title")
    if isopen then
        local redtable = self:titletypeRedShow()
            -- dump(redtable,"55555555555555")
        for i=1,#redtable do
           if redtable[i] then
                return redtable[i]
           end
        end
    end
    return false
end
function TitleModel:openTitleSystem()

    local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.TITLE)
    -- local isopen,valuer,_type  = FuncCommon.isSystemOpen("title")
    -- -- echo("======111111========",isopen,_type,valuer)
    if isopen then
        WindowControler:showWindow("TitleMainView")--,TitleModel:getLeafsign());
    -- else
    --     WindowControler:showTips(valuer.."级开启称号功能");
    end
end

function TitleModel:AddtitleIcon(titleid,_ctn)
    local  titleids = titleid or self.gettitleID
    _ctn:removeAllChildren()
    if titleids ~= "" then
        local titlesprite = FuncTitle.bytitleIdgetpng(titleid)
        local titlepng = display.newSprite(titlesprite)
        _ctn:addChild(titlepng)
    end
end


function TitleModel:setSelectYeQian(_index)
    self.selectIndex = _index
end

return TitleModel;





















