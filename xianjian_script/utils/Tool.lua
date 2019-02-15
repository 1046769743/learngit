 --
-- User: ZhangYanGuang
-- Date: 15-5-14
-- 全局工具方法
--

local function swapGem(str)
	--预留扩展，该方法中修改str
    return str
end

function getPlotLanguage(id)
    --先从csv配置从读取
    local result = FuncTranslate.getPlotLanguage(id, 'zh_CN') --GameConfig:getRaw("translate", id, 'zh_CN');
 
    if result == nil then
        echo("没有找到这个语言id配置:",id) 
        return id 
    end
    if type(result)=='string' then
        result=swapGem(result);
    elseif type(result)=='table' then
        for i,v in pairs(result) do
            if type(result[i])=='string' then
                result[i]=swapGem(result[i]);
            end
        end
    end
    return result;
end
 
--三元运算符
function _yuan3(a, b, c)
    if a == nil then return c end
    return(a and { b } or { c })[1]
end 

Tool = Tool or {}

function Tool:getDeviceId()
	-- local device_id = LS:pub():get(StorageCode.device_id, "")
    local device_id = nil
	if not device_id or device_id == "" then
		--TODO 获取设备id
		if false then
			--首先通过公司技术支持的方法获取deviceid
            
		else
			device_id = self:getFakeDeviceId()
		end
	end
    
	return device_id
end
local socket 
if not DEBUG_SERVICES  then
    socket = require("socket")
end

function Tool:getFakeDeviceId()
    local client = socket.connect("www.baidu.com", 80)
    local ip = nil

    -- 没有网络时client为nil
    if client then
        ip = client:getsockname() 
    end

    local hostname = nil
    if ip == nil then
        hostname = socket.dns.gethostname()
        ip = socket.dns.toip(hostname)
    end

    if ip == nil then
        return hostname
    end

    ip = string.gsub(ip, "%." , "-")

    local deviceid = "pc-dev-id-" .. ip
    return deviceid
end

--先用时间戳和随机串来模拟设备id
function Tool:getFakeDeviceId_old()
	local device_id_max_len = 30
	local strs = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","_","1","2","3","4","5","6","7","8","9","0"}
	math.randomseed(os.time()) 
    
    local randomIn = math.random()
    table.shuffle(strs, math.random(1,os.time()))
	local deviceid = os.time().."_"..string.sub(table.concat(strs), 1, device_id_max_len)
	return deviceid
end

--判断是否是敏感词 ,replaceStr 把敏感词替换成指定的词
function Tool:checkIsBadWords(str,replaceStr)
    local time = os.clock()
    replaceStr = replaceStr or "*"

   local isBadWord = false;

   local isAllow, strAfterReplace = BanWordsHelper:isStringPlayerCanUse(str, replaceStr)
   if isAllow == false then 
        isBadWord = true;
   end 

    return isBadWord, strAfterReplace;
end

-- 坐标转换为gl坐标
function Tool:convertToGL(pos)
    local glView = cc.Director:getInstance():getOpenGLView();

    local designResolutionSize = glView:getDesignResolutionSize();

    pos = cc.Director:getInstance():convertToGL(
        {x = pos.x, y = pos.y}); 

    if designResolutionSize.width > GameVars.maxScreenWidth then 
        pos.x = pos.x - (designResolutionSize.width - GameVars.maxScreenWidth) / 2;
    elseif designResolutionSize.height > GameVars.maxScreenHeight then 
        pos.y = pos.y - (designResolutionSize.height - GameVars.maxScreenHeight) / 2;
    end 

    return pos;
end

--打印node box坐标
function Tool:printNodeRect( nd,rect ,event )
    if not SHOW_CLICK_POS then
        return
    end
    --如果点击区域大于 半屏了  就不打印
    if rect.width> 700 then
        return
    end
    local cx = rect.x + rect.width/2
    local cy = rect.y + rect.height/2

    local pos =nd:convertToWorldSpaceAR(cc.p(cx,cy))

    printf("当前响应区域中心点:%d,%d,宽:%d,高%d,点击坐标:%d,%d",
        math.round(pos.x),math.round(pos.y),rect.width,rect.height,
        math.round(event.x),math.round(event.y)
        )

end

--绘制node box区域
function Tool:drawNodeRect( nd,rect,event )
    -- 调试情况下才显示
    if not SHOW_CLICK_RECT then return end
    
    -- 如果点击区域大于半屏了 就不绘制
    if rect.width > 700 then
        return
    end

    -- 如果已经绘制过则不再绘制
    if nd.__tRect and not tolua.isnull(nd.__tRect) then
        nd.__tRect:visible(true)
        if nd.__tTxt and not tolua.isnull(nd.__tTxt) then
            nd.__tTxt:visible(true)
        end
        return 
    end

    local cx = rect.x + rect.width/2
    local cy = rect.y + rect.height/2

    local topRoot =  WindowControler:getScene()._topRoot

    local pos = nd:convertLocalToNodeLocalPos(topRoot,cc.p(cx, cy))

    local tRect = cc.rect(pos.x - rect.width/2, pos.y - rect.height/2, rect.width, rect.height)
    local r = display.newRect(tRect,{fillColor = cc.c4f(0,1,0,0.3),borderColor = cc.c4f(1,0,0,1)}):addTo(topRoot)

    -- 获取适配方式
    local adapt = ScreenAdapterTools.getUIAdaptMethod(nd)
    adapt = string.format("%s;%s;", adapt[1], adapt[2])
    -- 文本
    local txt = display.newTTFLabel({text = adapt, size = 20, color = cc.c3b(0,0,0),font="ttf/"..GameVars.fontName})
            :align(display.CENTER)
            :addTo(topRoot)
            :anchor(0.5, 0.5)
            :pos(pos.x, pos.y)

    nd.__tTxt = txt
    nd.__tRect = r

    return r,txt
end

--清理(隐藏)绘制的node 的box区域
function Tool:hideDrawNodeRect(nd)
    if nd.__tRect and not tolua.isnull(nd.__tRect) then
        nd.__tRect:visible(false) 
    end

    if nd.__tTxt and not tolua.isnull(nd.__tTxt) then
        nd.__tTxt:visible(false) 
    end
end

-- 一般方法求直线与圆交点
function Tool:GetLineAndCirclePoint(cx,cy,r,stx,sty,edx,edy )
    --(x - cx )^2 + (y - cy)^2 = r^2
    --y = kx +b

    --求得直线方程
    local k = ((edy - sty) ) / (edx - stx);
    local b = edy - k*edx;
  
    --列方程
    --[[
    (1 + k^2)*x^2 - x*(2*cx -2*k*(b -cy) ) + cx*cx + ( b - cy)*(b - cy) - r*r = 0
    ]]
    local x1,y1,x2,y2;
    local c = cx*cx + (b - cy)*(b- cy) -r*r;
    local a = (1 + k*k);
    local b1 = (2*cx - 2*k*(b - cy));
    --得到下面的简化方程
    -- a*x^2 - b1*x + c = 0;
    if b1*b1 - 4*a*c < 0 then 
    -- 此时没有相交
        return nil
    end
    
    local tmp = math.sqrt(b1*b1 - 4*a*c);
    x1 = ( b1 + tmp )/(2*a);
    y1 = k*x1 + b;
    x2 = ( b1 - tmp)/(2*a);
    y2 = k*x2 + b;
    echo("x1 ==== ",x1)
    echo("y1 ==== ",y1)
    echo("x2 ==== ",x2)
    echo("y2 ==== ",y2)
    --判断求出的点是否在圆上
    local res = (x1 -cx)*(x1 -cx) + (y1 - cy)*(y1 -cy);
    local p = {}; 
    if( res == r*r) then --我这里 r = 50,res = 2500.632,还是比较准确的
        p.x = x1;
        p.y = y1;  
    else
        if stx > cx and x1 >= cx then
            p.x = x1;
            p.y = y1;
        else
            p.x = x2;
            p.y = y2;
        end
    end
    return p;
end



--记录当前_G里面的所有变量
function Tool:getGlobalKey( )
    local resultArr = {}
    local keyArr = {}
    
    for k,v in pairs(_G) do
        table.insert(keyArr,k)
    end
    table.sort( keyArr )
    for i,v in ipairs(keyArr) do
        table.insert(resultArr, {key = v,value = _G[v] })
    end
    return resultArr
end

--比较_G里面的所有变量
function Tool:compareKey( keyArr1,keyArr2 )
    local addKey = {}
    for i,v in ipairs(keyArr2) do
        local hasFind =false
        for ii,vv in ipairs(keyArr1) do
            if v.key == vv.key then
                hasFind = true
                break
            end
        end
        if not hasFind then
           table.insert(addKey, v)
        end
        
    end
    --返回增加的数组
    return addKey 

end

-- 转换含有nil value的有序数组
function Tool:getTableNoNil(t)
    local temp = {unpack(t)}
    local maxNums = 0
    for k,v in pairs(temp) do
        maxNums = math.max(maxNums,k)
    end

    for i=1,maxNums do
        if not t[i]  then
            t[i] = false
        end
    end

    return t
end

-- 监控一个表里变量的变化
function Tool:monitorTableVaue(t)
    local newT = {}
    local realT = {}
    for k,v in pairs(t) do
        realT[k] = v
    end

    local mt = {
        __index = function(t, k)
            return realT[k]
        end,
        __newindex = function(t, k, v)
            echo(string.format("修改表属性:%s为:%s",k,v))
            realT[k] = v
        end,
    }  

    setmetatable(newT,mt)

    return newT
end

-- 深度比较两个表
function Tool:deepCompareT(t1,t2,key)
    if not t1 or not t2 then
        return
    end
    key = key or "table"
    local des = nil
    for k,v in pairs(t1) do
        des = string.format("%s-->%s",key,k)
        if type(v) ~= "table" then
            if t1[k] ~= t2[k] then
                echo("有值变化",des,"t1",t1[k],"t2",t2[k])
            end
        else
            self:deepCompareT(t1[k],t2[k],des)
        end
    end
end

-- url地址补/(无/,部分Android设备会访问失败)
function Tool:turnUrl(url)
    if url and string.len(url) > 0 then
        local newUrl = url

        local url_1 = url
        local url_2 = ""

        if string.find(url,"?") then
            local tempArr = string.split(url,"?")
            url_1 = tempArr[1]
            url_2 = "?" .. tempArr[2]
        end

        local urlArr = string.split(url_1,".")
        if urlArr and #urlArr > 0 then
            local isFind = false
            -- 从2个开始查找，第1个可能含有http://
            for i=2,#urlArr do
                if string.find(urlArr[i],"/") then
                    isFind = true
                end
            end

            if isFind then
                newUrl = url_1 .. url_2
            -- 补/
            else
                urlArr[#urlArr] = urlArr[#urlArr] .. "/"
                newUrl = table.concat(urlArr, '.') .. url_2
            end
        end

        return newUrl
    end

    return url
end


--忽略加载的表
local battleIgnoreMap = {
    ["activity.ActivityTask"] = true,
    ["activity.Activity"] = true,
    ["activity.ActivityCondition"] = true,
    ["battle.Loading"] = true,
    ["char.CharLevelUp"] = true,
    ["cimelia.CimeliaLotteryValue"] = true,
    ["common.GetMethod"] = true,
    -- ["common.StrengthenUser"] = true,
    -- ["common.SystemOpen"] = true,
    ["crosspeak.CrossPeakBox"] = true,
    -- ["crosspeak.CrossPeakPartnerMapping"] = true,
    -- ["crosspeak.CrossPeakOptionPartner"] = true,
    ["danmu.DanmuSystem"] = true,
    ["delegate.DelegateTask"] = true,
    ["elite.EliteBox"] = true,
    -- ["endless.Endless"] = true,
    ["endless.EndlessFloor"] = true,
    ["god.GodExp"] = true,
    ["guide.NoviceGuide"] = true,
    ["guide.BattleGuide"] = true,
    ["home.NPCevent"] = true,
    ["items.Item"] = true,
    ["items.Reward"] = true,
    ["level.Source"] = true,
    ["level.SourceEx"] = true,
    ["loading.Loading"] = true,
    ["lottery.Lottery"] = true,
    ["lottery.LotteryReward"] = true,
    ["lottery.LotteryRewardNew"] = true,
    ["lottery.LotteryOrder"] = true,
    -- ["mission.Mission"] = true,
    ["mission.MissionQuest"] = true,
    ["partner.PartnerExp"] = true,
    ["partner.PartnerSkillUpCost"] = true,
    ["plot.PlotTem"] = true,
    ["plot.AnimBoneNew"] = true,
    ["quest.MainlineQuest"] = true,
    
    ["shop.Goods"] = true,
    ["shop.ShopWeight"] = true,
    -- ["story.Raid"] = true,
    ["story.Story"] = true,
    ["story.NpcInfo"] = true,
    ["story.Scene"] = true,
    ["story.Npc"] = true,
    
    ["tower.TowerBox"] = true,
}


--配表reuqire
function Tool:configRequire( path )
    -- if battleIgnoreMap[path] then
    if DEBUG_SERVICES   and  battleIgnoreMap[path] then
        return {}
    end
    return require(path)
end

--计算节省的内存
function Tool:countSaveMemory( )
    collectgarbage("collect")
    local beforeCount =  collectgarbage("count")
    for i,v in pairs(battleIgnoreMap) do
        local filePath = string.gsub(i, "[.]", "/")
        filePath= filePath..".lua"
        if cc.FileUtils:getInstance():isFileExist(filePath) then
            require(i)
        end
        
    end
    local afterCount =  collectgarbage("count")
    collectgarbage("collect")
    local afterCount2 =  collectgarbage("count")

    echo(beforeCount,afterCount,afterCount2,"__add1:",afterCount -beforeCount,"add2",afterCount2 - beforeCount)
end

-- 将阿拉伯数字转化成中文 一 二 三...
-- isComplex 是否中文繁体,默认不传,为简体
function Tool:transformNumToChineseWord( num,isComplex )
    -- 阿拉伯数字到中文数字的映射表
    local arabMap = {
        [0] = "十",
        [1] = "一",
        [2] = "二",
        [3] = "三",
        [4] = "四",
        [5] = "五",
        [6] = "六",
        [7] = "七",
        [8] = "八",
        [9] = "九",
    }
    if isComplex then
        arabMap = {
            [0] = "拾",
            [1] = "壹",
            [2] = "贰",
            [3] = "叁",
            [4] = "肆",
            [5] = "伍",
            [6] = "陆",
            [7] = "柒",
            [8] = "捌",
            [9] = "玖",
        }
    end

    local numStr = ""
    local len = 0

    local num = tonumber(num)
    if not num or num == nil or num == "nil" then
        return numStr,len
    elseif tonumber(num) == 0 then
        numStr = "零"
        len = 1
        return numStr,len
    else
        local modNum = num % 10 
        local divNum = math.floor(num / 10)

        if modNum == 0 then
            if divNum ~= 0 then
                if divNum == 1 then
                    numStr = arabMap[0]
                    len = 1
                else
                    numStr = arabMap[divNum] .. arabMap[0]
                    len = 2
                end
            end
        else
            if divNum ~= 0 then
                if divNum > 1 then
                    numStr = arabMap[divNum] .. arabMap[0] .. arabMap[modNum]
                    len = 3
                else
                    numStr = arabMap[0] .. arabMap[modNum]
                    len = 2
                end
            else
                numStr = arabMap[modNum]
                len = 1
            end
        end
    end

    return numStr,len
end

--[[
    将剩余秒数转为天/时/分/秒格式
]]
function Tool:formatLeftTime(sec)
    local day = nil
    if sec == 86400 then
        day = 0
    else
        day = math.floor(sec / 86400)
    end

    local hour = nil
    if sec == 3600 then
        hour = 0
    else
        hour = math.floor( (sec - day * 86400) / 3600 )
    end

    local min = nil
    if sec == 60 then
        min = 0
    else
        min = math.floor( (sec - day * 86400 - hour * 3600) / 60 )
    end

    local second = sec - day * 86400 - hour * 3600 - min * 60

    local leftTimeStr = ""
    if day > 0 then
        leftTimeStr = string.format("%s%s天",leftTimeStr,tostring(day))
    end

    if hour > 0 then
        leftTimeStr = string.format("%s%s时",leftTimeStr,tostring(hour))
    end

    if min > 0 then
        leftTimeStr = string.format("%s%s分",leftTimeStr,tostring(min))
    end

    if second > 0 or (second == 0 and (day == 0 and hour  == 0 and min  == 0) )then
        leftTimeStr = string.format("%s%s秒",leftTimeStr,tostring(second))
    end

    return leftTimeStr
end

-- 返回函数栈调用层数
-- @@flag traceback
-- 很费效率，正式代码一定不要保留
function Tool:GetStackDepth(flag)
    local depth = 0
    while true do
        if not debug.getinfo(3 + depth) then
            break
        elseif flag then
            echo(debug.getinfo(3 + depth,'S').source,debug.getinfo(3 + depth,'n').name,debug.getinfo(3 + depth,'l').currentline)
        end
        depth = depth + 1
    end
    return depth
end


local cacheKeyMap = {}
function Tool:getCacheKeyNums( key )
    return cacheKeyMap[key] or 0
end

function Tool:addCacheKeyNums( key )
    if not cacheKeyMap[key] then
        cacheKeyMap[key] = 1
    else
        cacheKeyMap[key] = cacheKeyMap[key] +1
    end
end

-- 画一个测试框
function Tool:drawRect(nd, color)
    color = color or cc.c4f(0,0.5,0.5,0.3)
    local rect = nd:getContainerBox()
    rect.x = 0
    rect.y = -rect.height

    local r = display.newRect(rect,{fillColor = color,borderColor = cc.c4f(1,0,0,1)})

    r:setAnchorPoint(cc.p(0,1))
    nd:addChild(r, 100)

    return r,nd
end

-- 获取一个去重插入的方法
function Tool:getInsertFunc(targetTable)
    local mark = {}
    local result = {}
    if targetTable then
        -- 先对已有的做一下去重
        for _,v in ipairs(targetTable) do
            if not mark[v] then
                mark[v] = true
                result[#result + 1] = v
            end
        end
    end

    return result,function(value)
        if not mark[value] then
            mark[value] = true
            result[#result + 1] = value
        end
    end
end