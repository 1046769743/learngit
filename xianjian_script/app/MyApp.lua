
require("config")  
require("framework.init")
require("lfs")

if device.platform == "windows" or device.platform == "mac"  then

    --判断是否是client目录
    if cc.FileUtils:getInstance():isFileExist("clientConfig.lua") then
        --client目录下强制使用散图
        CONFIG_USEDISPERSED = true
        require("clientConfig")
    end

    if IS_COVER_FORM_CONFIG_DEBUG and cc.FileUtils:getInstance():isFileExist("config_debug.lua") then
        require("config_debug.lua")
    end

end
local sharedDirector = cc.Director:getInstance()




-- 根据CONFIG_ASSET_PLATFOMR的值设置asset搜索路径
local setSearchPath = function()
    local assetSearchPath = nil
    if device.platform == "mac" then
        assetSearchPath = AppHelper:getResourcesRoot() ..  "/asset"
    elseif device.platform == "windows" then
        assetSearchPath = "asset"
    end

    if CONFIG_ASSET_PLATFOMR == nil or CONFIG_ASSET_PLATFOMR == "" or CONFIG_ASSET_PLATFOMR == "pc" then
        cc.FileUtils:getInstance():addSearchPath(assetSearchPath,true)
    else
        if device.platform == "android" or device.platform == "ios" then
            return
        end
        
        -- 强制使用大图，该类型资源没有散图
        CONFIG_USEDISPERSED = false

        local searchArr = cc.FileUtils:getInstance():getSearchPaths()
        dump(searchArr,"searchArr")

        assetSearchPath = assetSearchPath .. "_" .. CONFIG_ASSET_PLATFOMR
        cc.FileUtils:getInstance():addSearchPath(assetSearchPath) 
        local searchArr = cc.FileUtils:getInstance():getSearchPaths()
        dump(searchArr,"searchArr222")
    end
end

setSearchPath()


require("utils.init")



local minimumLoad = function()
    GameLuaLoader:loadGameStartupNeeded()
end

minimumLoad()

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    self.objects_ = {}
    self._timeClock = os.clock()
end

function MyApp:run()
    if IS_OPEN_MOBDEBUG then
        require("mobdebug").start()
    end
    if jit then
        jit.off()
        jit.flush()
    end

    if device.platform == "mac" then
        oldPrint = print
        print = function (...  )
            local arr = {...}
            local str = table.concat(arr,"  ")
            __G_insterLogs(str)
        end

        local tempFunc = function (  )
            __G_runOneLogs()
        end
        local scheduler = require("framework.scheduler")
        scheduler.scheduleUpdateGlobal(tempFunc)

    end

    --设置帧频
    cc.Director:getInstance():setAnimationInterval(1.0/(GAME_RUN_FPS or 30) )

    if IS_EDITER then
        self:init()
        WindowControler:chgScene("TerrainEditorScene");
        return
    end
    -- cc.Director:getInstance():getScheduler():setTimeScale(0.5)
    -- if (device.platform == "ios" or device.platform == "android") and (not SKIP_VIDEO) then
    if (device.platform == "ios" or device.platform == "android") and (not DEBUG_SKIP_VIDEO) then
        self:init()
        WindowControler:chgScene("FullScreenVideoScene");
    else
        -- 为使用StorageCode，前置init()方法
        self:init()
        local isQuickRestart = AppHelper:getValue(StorageCode.login_is_quick_restart)
        if DEBUG_SKIP_LOGO or isQuickRestart == "true" then
            WindowControler:chgScene("SceneMain");
            -- if not DEBUG_ENTER_SCENE_TEST then
            --     WindowControler:chgScene("SceneMain");
            -- else
            --     WindowControler:chgScene("SceneTest");
            -- end
        else
            -- WindowControler:chgScene("SceneLogo");
            self:chgScene("SceneLogo")
        end
    end
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local customListener = cc.EventListenerCustom:create(SystemEvent.SYSTEMEVENT_LOGS_NORMAL,
                                c_func(self.receiveCNormalLogs,self))
    eventDispatcher:addEventListenerWithFixedPriority(customListener, 1)

    local customListener = cc.EventListenerCustom:create(SystemEvent.SYSTEMEVENT_LOGS_ERROR,
                                c_func(self.receiveCErrorLogs,self))
    eventDispatcher:addEventListenerWithFixedPriority(customListener, 1)
end

function MyApp:receiveCNormalLogs( data )
    echo("c++echo", data:getDataString())
end

function MyApp:receiveCErrorLogs( data )
    echoError("c++error,", data:getDataString())
end

function MyApp:chgScene(sceneName)
    local scene = require("app.scenes." .. sceneName).new()

    local transitionType = nil
    if hasTransition then
        transitionType = "fade"
    end

    display.replaceScene(scene, transitionType, 0)
end

function MyApp:init()
    cc.Device:setKeepScreenOn(true)
    self:initTexturePixelFormatCfg()

    GameLuaLoader:loadFirstNeeded()
    self:doByFirst()
    --游戏启动打点
    ClientActionControler:sendNewDeviceActionToWebCenter(
        ActionConfig.login_game_start);

    --发送之前木有发送成功的打点或错误日志;
    self:sendStorageFileToDataCenter();

    --初始化敏感词
    BanWordsHelper:initBanWord();

    self:removeToLongLogsFile()
    AudioModel:init()
end

--  设置材质像素格式配置
function MyApp:initTexturePixelFormatCfg()
    -- 暂时取消 ZhangYanguang 2016.12.08
    -- AppHelper:setTexturePixelFormat("anim/spine",cc.TEXTURE2D_PIXEL_FORMAT_RGBA4444)
end

--[[
    发送没有发送的数据给数据中心
    可能是之前发送失败或是出错大退了

]]
function MyApp:sendStorageFileToDataCenter()
    ClientActionControler:sendStorageFileToDataCenter();
end

function MyApp:doByFirst(  )

end

function MyApp:setObject(id, object)
    assert(self.objects_[id] == nil, string.format("MyApp:setObject() - id \"%s\" already exists", id))
    self.objects_[id] = object
end

function MyApp:getObject(id)
    assert(self.objects_[id] ~= nil, string.format("MyApp:getObject() - id \"%s\" not exists", id))
    return self.objects_[id]
end

function MyApp:isObjectExists(id)
    return self.objects_[id] ~= nil
end

function MyApp:onEnterBackground()
    echo("游戏进入后台......")
    PushHelper:registerLocalNotices()
    audio.pauseAllSounds()
    audio.pauseMusic()
    local timeStap,usec = pc.PCUtils:getMicroTime()
    self._lastTimeStap = timeStap
    self._lastUsec = usec

    self._timeClock = os.clock()

    --Server:handleClose()
    EventControler:dispatchEvent(SystemEvent.SYSTEMEVENT_APP_ENTER_BACKGROUND,{time = timeStap,usec = usec} )
    --display.pause()
end


function MyApp:onEnterForeground()
    echo("游戏恢复到前台......")
    PushHelper:clearLocalNotices()
    audio.resumeAllSounds()
    audio.resumeMusic()
    --display.resume()
    local timeStap,usec = pc.PCUtils:getMicroTime()
    if not self._lastTimeStap then
        self._lastTimeStap = timeStap
    end
    local dt = timeStap - self._lastTimeStap   --os.clock() - self._timeClock
    if dt < 0 then
        echoError("__玩家修改了时间")
        dt = 1
    end
    AudioModel:setMusicVolume(AudioModel:getMusicVolume())
    AudioModel:setSoundVolume(AudioModel:getSoundVolume())
    echo(dt,"后台切换前台秒差s")
    --恢复焦点   那么记录下 恢复时间戳和  相隔时间
    EventControler:dispatchEvent(SystemEvent.SYSTEMEVENT_APP_ENTER_FOREGROUND ,{time = timeStap,usec = usec ,dt = dt} )


end

function MyApp:onWillTerminate()
    echo("游戏即将被杀死......")

    if Server then
        Server:handleClose()
    else
        print("onWillTerminate Server is nil ")
    end

    -- EventControler:dispatchEvent(SystemEvent.SYSTEMEVENT_APP_WILL_TERMINATE)
end
---删除时间长的logs文件
function MyApp:removeToLongLogsFile()
    local assetSearchPath = "/logs/clientlogs" 
    local assetSearchPath = nil
    
    if device.platform == "mac" then
        assetSearchPath = AppHelper:getResourcesRoot() .."/logs/clientlogs/"
    elseif device.platform == "windows" then
        assetSearchPath = lfs.currentdir()
        assetSearchPath = string.gsub(assetSearchPath, "\"","/");
        assetSearchPath = assetSearchPath .. "/logs/clientlogs/"
    else
        return
    end
    if  not cc.FileUtils:getInstance():isDirectoryExist(assetSearchPath) then
        return 
    end
    local sumtime = 1*30*24*60*60
     -- local alldata = FS.getFileList(logPath)
    if assetSearchPath ~= nil then
        for file in lfs.dir(assetSearchPath) do
            -- echo("---file---", file);
            local curDir = assetSearchPath..file
            local mode = lfs.attributes(curDir, "mode")
            if mode == "file" then
                local time = lfs.attributes(curDir, "access")
                if os.time() - time >= sumtime then
                    os.remove(curDir)
                end
            end
        end
    end
end
-- 安卓重新进入时需要reset GLPrograms
function MyApp:reloadGLPrograms()
    if FilterTools and FilterTools._GLProgramsNeedsReload then
        local glpCache = cc.GLProgramCache:getInstance()
        -- echo("是否收到了消息")
        for cacheKey,res in pairs(FilterTools._GLProgramsNeedsReload) do
            local glprogram = glpCache:getGLProgram(cacheKey)
            if glprogram then -- 已经在缓存中，说明正在被使用或已经被使用
                -- echo("是否进行了shader的重置")
                glprogram:reset()
                local vsh,fsh = unpack(res)
                glprogram:initWithFilenames(vsh,fsh)
                glprogram:link()
                glprogram:updateUniforms()
            else
                -- echo("没有进行shader的重置",unpack(res))
            end
        end
    end
    EventControler:dispatchEvent(SystemEvent.SYSTEMEVENT_RENTER_RE_CREATE)
end

return MyApp
