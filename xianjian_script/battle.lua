if jit then
    jit.off()
    jit.flush()
end

local arg = {...}
local path = arg[1]
print(path,"__path",path == "local",arg[2])
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

local _currentBattleData = ""



--系统报错回调
function __G__TRACKBACK__(msg)
    local str = debug.traceback("",2)
    runTimeErrorMessage = "runTimeError:\n" .. msg ..  str
    if IS_LOCAL_RUN_BATTLE then
        print(runTimeErrorMessage)
        return
    end
    local lineChar = "<br>"
    str = string.gsub(str, "[\n\r]", lineChar)
    str = msg ..lineChar .." ".. str
    
    if _currentBattleData ~= "" then
        str = str .. lineChar .. _currentBattleData
    end
    print(str)
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



--手动指定一些require
require("game.sys.GameVars")

require("utils.GameLuaLoader")

local packageName = "game.sys.func."
-- 加载func
local debugServerGroup = {
    "FuncDataResource",
    "FuncDataSetting",
    "FuncRes",
    "FuncChar",
    "FuncBattleBase",
    "FuncPvp",
    "FuncTreasure",
    "FuncTreasureNew",
    "GameConfig",
    "FuncTranslate",
    "FuncArmature",
    "FuncMatch",
    "FuncPartner",
    "FuncPartnerSkin",
    "FuncPartnerEquipAwake",
    "FuncGarment",
    "FuncNewLove",
    "FuncTitle",
    "FuncArtifact",
    "FuncChapter",
    "FuncGuildActivity",
    "FuncShareBoss",
    "FuncTower",
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

--加载事件
BattleEvent = require("game.sys.event.BattleEvent")
LoadEvent = require("game.sys.event.LoadEvent")
SystemEvent = require("game.sys.event.SystemEvent")



--加载controler
packageName = "game.sys.controler."

require(packageName .. "EventControler")
GameLuaLoader:loadGameSysFuncs()

-- UserModel = require("game.sys.model.UserModel")
require("game.sys.controler.EventControler")



BattleControler = require(packageName.."BattleControler")
LoginControler = require(packageName.."LoginControler")

--加载battleserver
BattleServer = require("game.sys.service.BattleServer")


require("game.battle.init")


-- local json 
local function safeLoad(  )
    json = require("cjson")
end

if not pcall(safeLoad) then
    --说明没有json
    json = nil
end




local projectPath = ""

--[[
    服务器传递给客户端 或者调用战斗服的数据 原始数据格式
    battleInfo = {
        -- userRid = UserModel:rid()          --必须要带userRid  否则没法知道我改操作谁 ,战斗中应该禁止使用UserModel:rid()
                                            --因为纯跑逻辑时可能需要用到rid  但是实际上是没有UserModel:rid()是空的
        battleId = 0        --必须要配置这个参数
        battleUsers = { {玩家A信息.,team =1,formation = ...},{玩家B信息..,team =2},..  }, -- team 是必须有的字段,可以为1或者2,可以都为 1
        -- formation = {}.         阵容,针对 gve(已废弃)
        randomSeed = 100,   --随机种子
        battleLabel = GameVars.battleLabels.worldPve 战斗标签.用来接受消息时候的 参数 必须有,没有就报错
       
        battleParams: {
        
            -- 共享副本相关信息、
            shareBossInfo={
                bossId = ""
                buffId = ""
                bossHp =
                {
                    rid="600013_2_1", --角色id
                    hpPercent=2760, --角色血量百分比
                }
            },
                
            --伙伴血量初始相关信息(目前只给锁妖塔用,后面可能别的玩法也需要所以拿出来了)
            unitInfo = {
                {   rid="dev_1001",   --角色rid
                    hid = "5003",--主角传1
                    --血量万分比
                    hpPercent = 9999,
                    teamFlag = 2, --teamFlag:1怪物、2真实玩家数据 3机器人
                }
            }
            
            --需要加入怪物的血量信息
            explore = {
                hpInfo = {
                    enemy= {
                        {rid = 101,hpPercent = 1000},
                        {},
                        ...
                    },
                    levelHpPercent = 30%,
                }
            }
            

            

            --雇佣兵血量信息，teamFlag:1怪物、2真实玩家数据 3机器人
            employeeInfo={hid = "101",hpPercent = 1000,teamFlag = 1}
            
            --仙盟战场怪物血量


            --锁妖塔相关的额外信息
            towerInfo = {
                --世界boss的血量
                bossHp = 1000
                --buff信息
                buffs = {
                   {    
                        buffid:100, 
                        count = 1,
                   }     
                },

                --吃了会加战斗buff的物品
                tempBuffs = {
                    {    
                        goodsId:100, 
                        count = 1,
                   } 
                },

                --比如某个怪物死亡对指定的怪物 造成攻防血降低10%,
                propChange = 1000;

                bossHp = 1000,
                --需要加入怪物的血量信息
                hpInfo = {
                    enemy= {
                        {rid = 101,hpPercent = 1000},
                        {},
                        ...
                    },
                    levelHpPercent = 30%,
                }
                energy = 5, --怒气值
                isSleep = 0, --是否是沉睡怪、1是，0否
            }
        }
    }

]]



    
    
--[[
    转换后进战斗的数据: battleInfo (完整的数据,包括客户端自己重放) 
    {
        userRid = UserModel:rid()          --必须要带userRid  否则没法知道我改操作谁 ,战斗中应该禁止使用UserModel:rid()
                                            --因为纯跑逻辑时可能需要用到rid  但是实际上是没有UserModel:rid()是空的
        
        battleId = 0        --必须要配置这个参数
        levelId 战斗关卡id  战斗回放需要配这个参数
        battleUsers = { {玩家A信息.,team =1,formation = ...},{玩家B信息..,team =2},..  }, -- team 是必须有的字段,可以为1或者2,可以都为 1
        formation = {}.         阵容,针对 gve
        randomSeed = 100,   --随机种子
        battleLabel = GameVars.battleLabels.worldPve 战斗标签.用来接受消息时候的 参数 必须有,没有就报错
        
        -- 共享副本相关信息、
        shareBossInfo={
            bossId = ""
            buffId = ""
            bossHp =
            {
                rid="600013_2_1", --角色id
                hpPercent=2760, --角色血量百分比
            }
        },
            
        --伙伴血量初始相关信息(目前只给锁妖塔用,后面可能别的玩法也需要所以拿出来了)
        partnersInfo = {
            {   rid="600013_2_1",   --如果是主角 就是avatar id
                --血量万分比
                hpPercent = 9999,
            }
        }
        --雇佣兵血量信息，teamFlag:1怪物、2真实玩家数据 3机器人
        employeeInfo={hid = "101",hpPercent = 1000,teamFlag = 1}

        
        --锁妖塔相关的额外信息
        towerInfo = {
            --世界boss的血量
            bossHp = 1000
            --buff信息
            buffs = {
               {    
                    buffid:100, 
                    count = 1,
               }     
            },

            --吃了会加战斗buff的物品
            tempBuffs = {
                {    
                    goodsId:100, 
                    count = 1,
               } 
            },

            --比如某个怪物死亡对指定的怪物 造成攻防血降低10%,
            propChange = 1000;

            bossHp = 1000,
            --需要加入怪物的血量信息
            hpInfo = {
                enemy= {
                    {rid = 101,hpPercent = 1000},
                    {},
                    ...
                },
                levelHpPercent = 3000,--万分比
            }
        }

        --如果是战斗回放或者复盘的 需要的信息
        operation, 
        {
            
        }
        replayGame  2表示是回放,空或者0表示非回放

        --战斗结果信息
        battleResult = {}

    }
]]

--[[

    --返回信息数据格式  
    --客户端上行 需要传 battleParams的战斗数据信息
    battleParams = {
        --结束帧数
        rt = self.gameControler._gameResult,
        star = self.gameControler._battleStar,
        battleId = self._battleInfo.battleId,
        operation = self.gameControler.logical.operationMap ,
        isPauseOut = 0,--1为暂停退出，服务器是否跑战斗服校验
        restartIdx = 0 ,--重新开始战斗次数、默认为0(没有重新开始过)
        handleCount = 0,--奇侠出手总次数
        round = 1,--战斗回合数(服务器打点用)
        battleResultParams = {
            -- 共享副本相关信息
            shareBossInfo={
                isDie = 0,
                damage = 66666,
                bossHp =
                {
                    rid="600013_2_1", --角色id
                    hpPercent=2760, --角色血量百分比
                }
            }

            partnersInfo = {
                {   

                    rid="600013_2_1",
                    --填写血量万分比
                    hpPercent = 8800,
                    -- 能量绝对值
                    energyPercent = 1000,
                }
            }

            --爬塔世界boss 对boss造成的血量
            towerInfo = {
                energy = 10,--怒气相关
                bossHp = 1000,
                --血量相关的信息
                hpInfo = {
                    --关卡内敌人的血量信息, 二维数组
                    enemy= {
                        {rid = 101,hpPercent = 1000,energyPercent = 1000},
                        {},
                        ...
                    },
                    --本次战斗怪物剩余的血量万份比
                    levelHpPercent = 3000,
                    --后面有需要在扩展
                    ...
                }
                energy = 5, --怒气值
            }

        }
        --日志信息以后在扩展
        -- losInfo = {
        --     log = ...
        --     error = ..
        --     runTime = ...
        -- }
    }

]]

local errorCodeMap = {
    resutlError = 1,    --结果错误
    starError = 2,      --星级错误
    logsError = 3,      -- 日志比对错误(如果星级或者结果错误了 肯定会 日志比对错误)
    normal = 0 ,        --正确结果
    runTimeError = 4,   -- 运行环境错误
    battleNoFinish = 5,  -- 战斗未结束(没打完,只针对多人战斗)
}

local errorCodeMessage = {
    [1] = "result error",
    [2] = "starError error",
    [3] = "logsError error",
    [4] = "runTimeError error",
    -- [0] = "",
    [5] = "battle not finish",

}


local function checkBattleError( beforeData,currentData,battleInfo )
    local bc = BattleControler:getMultyErrorCode()
    if runTimeErrorMessage ~= "" then
        errorCode = errorCodeMap.runTimeError
        return errorCode,""
    end
    if bc then
        return errorCodeMap.battleNoFinish,""
    end
    if not beforeData or table.isEmpty(beforeData) then
        return errorCodeMap.normal,""
    end
    local beforeLogs = beforeData.logsInfo or ""
    local curentLogs = currentData.logsInfo or ""
    -- if beforeLogs == "" or curentLogs == ""  then
    --     return errorCodeMap.normal,""
    -- end

    local errorCode
    if currentData.rt == Fight.result_none or (not currentData.rt ) or runTimeErrorMessage ~= "" then
        errorCode = errorCodeMap.runTimeError
        return errorCode,""
    end

    local message = ""
    --如果日志完全正常  message 为空
    if beforeLogs == curentLogs then
        errorCode = errorCodeMap.normal
    else

        local tp = table.copy(battleInfo)
        tp.battleResultClient = nil
        
        if beforeData.rt ~= currentData.rt then
            errorCode =  errorCodeMap.resutlError
        elseif beforeData.star ~= currentData.star then
            errorCode =  errorCodeMap.starError
        else
            -- 如果是不需要校验的关卡(仙界对决认输操作)，则直接返回正常
            if BattleControler.gameControler and 
                (not BattleControler.gameControler.isNeedCheckServerDummy() ) then
                errorCode = errorCodeMap.normal
            else
                errorCode = errorCodeMap.logsError
            end
        end

        -- message = "battleInfo:\n"..json.encode(battleInfo)..
        --         "\nviewLog:\n"..beforeLogs.."\ndummyLog:\n" .. curentLogs..
        --         "\nerrorCode:"..errorCode

    end
    return errorCode,message
end

function run( luaFunc,data )
    if luaFunc == "explore.getExploreMap" then
        data = json.decode(data)
        local resultData 
        local callExplore = function (  )
            resultData = FuncGuildExplore.getServerMap( data.mapId,data.randomSeed )
        end
        xpcall(callExplore, __G__TRACKBACK__)
        if not resultData then
            return json.encode( {errorInfo = {code = 1,message = runTimeErrorMessage}} )
        end
        return resultData
    end
    runTimeErrorMessage = ""
    --记录当前战斗数据,当发生报错的时候 把这个数据发送 日志平台
    _currentBattleData = data
    if not json then
        print("___this lua vision has no json")
    end
    if json and data then
        if type(data) == "table" then
        else
            data = json.decode(data)
        end 
       
    end
    if(not data) then 
        print( "this battle has not datas")
    end

    Fight.dum_frame_num = 1000000
    Fight.isDummy = true
    Fight.game_statistic=false

    --测试开启战斗高血量
    -- Fight.all_high_hp = false


    local battleInfo = { }
    if not data then
        battleInfo = {
            levelId = "10101",
        }

    else
        if type(data) == "table" then
            battleInfo = data
        end
    end

    local errorInfo = {}
    local errorStr  = ""

    if not battleInfo.battleLabel then
        errorStr = errorStr .."   not config battleLabel \n "
        battleInfo.battleLabel = GameVars.battleLabels.worldPve
        --table.insert(errorInfo, {code = 101,message = "battle data not config battleLabel"})
    end
    local label = battleInfo.battleLabel
    battleInfo.operation = battleInfo.operation or {}

    if battleInfo.battleResultClient then
        battleInfo.restartIdx = battleInfo.battleResultClient.restartIdx or  battleInfo.restartIdx
        battleInfo.restartIdx = battleInfo.restartIdx or 0
    end

    

    BattleControler:resetBattleData()
    -- local encInfo = numEncrypt:encodeObject( battleInfo )
    -- BattleControler:startPVP(encInfo)
    battleInfo.isDebug = true
    local t1 = os.clock()
    local tempFunc =function (  )
        -- error("handleError-")
        battleInfo = BattleControler:turnServerDataToBattleInfo(battleInfo)
        BattleControler:startBattleInfo(battleInfo)
    end
    xpcall(tempFunc, __G__TRACKBACK__)
    local battleResultData
    -- 说明runtimeerror
    if (runTimeErrorMessage ~= "") then

        if battleInfo.battleResultClient and battleInfo.battleResultClient.rt ~= nil then
            battleResultData = battleInfo.battleResultClient
        else
            battleResultData = {
                rt = Fight.result_lose,
                operation = {},
                star = 0,
                battleLabel = BattleControler.battleLabel,
                battleId = BattleControler._battleInfo.battleId
            }
        end
        
    else
        battleResultData = BattleControler:getBattleDatas(  )
    end

    -- 如果战斗胜利、再做战斗结果的补丁校验(先在这校验，需要优化，理论上需要校验的)
    -- if (not BattleControler:checkIsPVP()) and battleResultData.rt == Fight.result_win then
    --     BattleControler.gameControler:checkBattleStar()
    -- end
    local errorCode,errorMessage 
    --如果是不需要校验的
    if BattleControler._isNoNeedCheck then
        errorCode = errorCodeMap.normal 
        
        
    else
        errorCode,errorMessage = checkBattleError(battleInfo.battleResultClient,battleResultData,battleInfo)
    end
    --强制给是否校验提示
    battleResultData.skipCheckMsg = BattleCheckControler.checkMessage .."_"..battleInfo.battleLabel
    if errorCode == errorCodeMap.normal then
        errorInfo = nil
    else
        errorInfo.code = errorCode
        errorInfo.message = errorMessage
        errorInfo.message = errorCodeMessage[errorCode]
        if battleResultData.logsInfo then
            errorInfo.message = errorInfo.message.."\ndummy log: \n".. battleResultData.logsInfo
        end
    end
    if errorInfo and errorInfo.code == errorCodeMap.runTimeError then
        if runTimeErrorMessage ~= "" then
            errorInfo.message = runTimeErrorMessage
        end
    end
    local costTime = os.clock() - t1
    battleResultData.costTime = costTime
    battleResultData.errorInfo = errorInfo
    --清理所有注册的事件
    if FightEvent then
        FightEvent.eventListenerArr = {}
    end
    

    BattleControler:onExitBattle()
    -- 做一次垃圾回收
    local memery = collectgarbage("count")
    currentRunTimes = currentRunTimes +1
    --
    if collectRate >= 1 then
        if currentRunTimes % collectRate == 0 then
            --执行一次垃圾回收
            collectgarbage("collect")
        end
    end
    -- dump(battleResultData.operation,"operation")
    print("battleLabel:"..battleInfo.battleLabel..",battleId,"..battleInfo.battleId..",costTime,"..costTime..",gameResult:"..battleResultData.rt..",errorCode:"..errorCode..",memory:"..memery..",checkMsg:"..BattleCheckControler.checkMessage)

    
    -- dump(battleResultData,"battleResultData")
    if json then
        battleResultData.logsInfo = nil
        return json.encode( battleResultData )
    end
    return battleResultData 
    
end
