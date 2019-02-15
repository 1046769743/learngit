require("battle")
IS_LOCAL_RUN_BATTLE = true
--本地run
function localRun(  )
   
    collectgarbage("stop")
    --可以自行在这里配复盘哪一个文件
    --ConstValues里面的变量都可以在这里修改 比如高血量
    Fight.use_operate_info = false -- 表示根据文件复盘战斗情况
    Fight.statistic_file = "bt_2018_5_29_15_19_02_dev_8693" -- 记录战斗操作信息的文件
    



    --是否开启日志,测试性能时候就不需要
    -- set_is_open_echo(true)
    --需要跑几次 可以测试性能
    local runTimes = 10  
    local perTime = 0.3

    --是否还纯跑一次战斗复盘校验
    local isBattleRepeatCheck =true

    Fight.isDummy = true
    Fight.game_statistic=false
    Fight.all_high_hp = false
    


    require("framework.init")
    TimeControler = require("game.sys.controler.TimeControler")


    local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    local btInfo = GameStatistics:getLogsBattleInfo( Fight.statistic_file )

    local totalTime = 0
    --只有当runIndex为1的时候 才会保存一份本地日志
    local runOneFunc = function ( runIndex  )
        local t1 = TimeControler:getTempTime()
        local btResultClent
        btInfo.battleResultClient = nil
        local tempFunc =function (  )

            
            
            BattleControler:setCampData(btInfo.gameMode, btInfo )
            if runTimes == 1 then
                BattleControler:saveBattleInfo()
            end

            btResultClent = BattleControler:getBattleDatas()
            BattleControler:onExitBattle()
        end
        xpcall(tempFunc, __G__TRACKBACK__)
        
         local memery = collectgarbage("count")
         local dt  = TimeControler:getTempTime() - t1
        print(dt,"__runTime__",runIndex,"luamemrog:",memery)    
        totalTime = totalTime+ dt

        --是否需要模拟跑一下战斗服并进行校验
        if isBattleRepeatCheck then
            btInfo.battleResultClient = btResultClent
            local rt = run("pvp",btInfo)
        end
        if runIndex == runTimes then
            print("totalRunTime:",totalTime,"average:",totalTime/runTimes)
            GameStatistics:dumpStatitistice(  )
        end



    end

    for i=1,runTimes do
        
        -- scheduler.performWithDelayGlobal(c_func(runOneFunc,i),i*perTime)
        runOneFunc(i)
    end

    
    
    -- BattleControler:onExitBattle()
end


-- if not json then
--     run()
-- end

