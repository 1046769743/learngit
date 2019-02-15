if jit then
    jit.off()
    jit.flush()
end

local arg = {...}
local path = arg[1]
if arg and arg[1] == "local" then
    package.path = package.path..";".."config/?.lua" ..";" .."asset/?.lua" ..";" .."script/?.lua"
end

--垃圾回收 频率 跑1000次 执行一次回收, 0或者-1 不执行回收
local collectRate = 1000
-- 当前运行次数 
local currentRunTimes = 0

--是否强制校验 线上关闭
IS_MUST_BATTLECHECK= false

require("config")

require("framework.debug")

DEBUG_SERVICES = true
local runTimeErrorMessage = ""


--系统报错回调
function __G__TRACKBACK__(msg)
    local str = debug.traceback("",2)
    runTimeErrorMessage = "runTimeError:\n" .. msg ..  str

    print(runTimeErrorMessage)
end

-- 是否开启打印战斗日志
local is_open_echo = false
--设置是否开启日志
function set_is_open_echo( value )
    is_open_echo = value
end

local formatTable = function(array)
    local tmp =""
    for k,v in pairs(array) do
        tmp = tmp .." " .. tostring(v)
    end
    return tmp
end
local turnStr = function ( ... )
    local args = {...}
    --遍历最大数
    local maxNums = 0
    for k,v in pairs(args) do
        maxNums = math.max(maxNums,k)
    end
    for i=1,maxNums do
        if not args[i]  then
            args[i] = false
        end
    end

    local firstStr = args[1]
    local resultArr = args
    if type(firstStr)== "string" and string.find(firstStr, "%%") then
        local resultStr = string.format(unpack(args))
        resultArr = {resultStr}
    end
    return resultArr
end
   
echo = function (...)
    if is_open_echo then
        local resultArr = turnStr(...)
        print("echo:"..formatTable(resultArr))
    end
end

echoWarn = function ( ... )
    if is_open_echo then
        local resultArr = turnStr(...)
        print("warn:"..formatTable(resultArr))
    end
end

echoError = function (... )
    if is_open_echo then
        local resultArr = turnStr(...)
        print("error:"..formatTable(resultArr))
    end
end

require("framework.functions")
--require("framework.init")
require("utils.init")
require("game.battle.tools.RandomControl")


--手动指定一些require
require("game.sys.GameVars")


local packageName = "game.sys.func."
-- 加载func
local debugServerGroup = {
    "FuncGuildExplore",
}
for i,v in ipairs(debugServerGroup) do
    local loadPath = packageName..v
    if not package.loaded[loadPath] then
        require(loadPath)
        local t = _G[v]
        if t and t.init then
            t.init()
        end
    end
end


-- local json 
local function safeLoad(  )
    json = require("cjson")
end
if not cjson then
    if not pcall(safeLoad) then
        json = nil
    end
else
    json = cjson
end

local projectPath = ""

--开启日志
set_is_open_echo(true)


--java服调用随机地图生成地图序列
--[[
结构:
 {
    [x*10000+y] = {
        block = 0,      -- int,是否可走, 0或者空可走,1不可走.
        events = {
            {   
                {
                    type=1,     --事件类型  比如是怪物还是矿洞 还是什么..
                    tid =101,   --对应事件类型的id
                }, 
            }
        }
        sub = 1001      --int 从属于哪个格子 默认为空
    }
    [10*10000+5] = {x=10,y= 5} -- key是int ,值为10000*x+y

    
]]
echo("start require explore")
echo("start require explore")
function getExploreMap( mapId,randomSeed )

    local data = nil
    local tempFunc =function (  )
        echo("___start get getExploreMap,id,randomSeed,",mapId,randomSeed)
        data = FuncGuildExplore.getOneRandomMap(mapId, randomSeed )
        
        local length = 0
        local tmp  ={}
        for k,v in pairs(data.cells) do
            v.terrain =nil
            v.decorate = nil
            tmp[tostring(k)] = v
            length = length +1
        end
        echo("___end get getExploreMap,length",length)
        data = tmp
    end
    xpcall(tempFunc, __G__TRACKBACK__)
    if not json then
        echo("this run time has no json ")
    end
    local rt = json.encode(data)
    return rt
end

