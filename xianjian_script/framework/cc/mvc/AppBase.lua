
local AppBase = class("AppBase")

AppBase.APP_ENTER_BACKGROUND_EVENT = "APP_ENTER_BACKGROUND_EVENT"
AppBase.APP_ENTER_FOREGROUND_EVENT = "APP_ENTER_FOREGROUND_EVENT"
AppBase.APP_WILL_TERMINATE = "APP_WILL_TERMINATE_EVENT"
AppBase.EVENT_RENDERER_RECREATED = "event_renderer_recreated"

function AppBase:ctor(appName, packageRoot)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    self.name = appName
    self.packageRoot = packageRoot or "app"

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local customListenerBg = cc.EventListenerCustom:create(AppBase.APP_ENTER_BACKGROUND_EVENT,
                                handler(self, self.onEnterBackground))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
    local customListenerFg = cc.EventListenerCustom:create(AppBase.APP_ENTER_FOREGROUND_EVENT,
                                handler(self, self.onEnterForeground))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)

    local customListenerTerminate = cc.EventListenerCustom:create(AppBase.APP_WILL_TERMINATE,
                                handler(self, self.onWillTerminate))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerTerminate, 1)
    
    --暂时注掉之后调试
    local customListenerGl = cc.EventListenerCustom:create(AppBase.EVENT_RENDERER_RECREATED,
                                handler(self, self.reloadGLPrograms))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerGl, 1)
    
    self.snapshots_ = {}

    -- set global app
    app = self
end

function AppBase:run()
end

function AppBase:exit()
    cc.Director:getInstance():endToLua()
    if device.platform == "windows" or device.platform == "mac" then
        os.exit()
    end
end

function AppBase:enterScene(sceneName, args, transitionType, time, more)
    local scenePackageName = self.packageRoot .. ".scenes." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(unpack(checktable(args)))
    display.replaceScene(scene, transitionType, time, more)
end

function AppBase:createView(viewName, ...)
    local viewPackageName = self.packageRoot .. ".views." .. viewName
    local viewClass = require(viewPackageName)
    return viewClass.new(...)
end

function AppBase:onEnterBackground()
    -- self:dispatchEvent({name = AppBase.APP_ENTER_BACKGROUND_EVENT})
end

function AppBase:onEnterForeground()
    -- self:dispatchEvent({name = AppBase.APP_ENTER_FOREGROUND_EVENT})
end

function AppBase:onWillTerminate()
    -- self:dispatchEvent({name = AppBase.APP_WILL_TERMINATE})
end

return AppBase
