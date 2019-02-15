--
--Author:      zhuguangyuan
--DateTime:    2018-03-12 15:31:03
--Description: 精英终点传送门类
--


local EliteEventModel = require("game.sys.view.elite.eliteModel.EliteEventModel")
EliteEndPointModel = class("EliteEndPointModel",EliteEventModel)

function EliteEndPointModel:ctor( controler,gridModel)
    EliteEndPointModel.super.ctor(self,controler,gridModel)
end

function EliteEndPointModel:registerEvent()
    EliteEndPointModel.super.registerEvent(self)
    EventControler:addEventListener(EliteEvent.ELITE_CONFIRM_TO_GOTO_SCENE, self.goToNextChapter, self)
end

function EliteEndPointModel:setEventId(eventId)
    EliteEndPointModel.super.setEventId(self,eventId)
end   

-- 事件回应
-- 判断本章是否还有未领取的宝箱 
-- 有则提示 否则进入下一章
function EliteEndPointModel:onEventResponse()
    local storyId = self.controler.storyId
    local isMainLineOK,isEliteOK = EliteMainModel:checkIfCangotoNextChapter( storyId )
    echo("____ storyId,isMainLineOK,isEliteOK ____",storyId,isMainLineOK,isEliteOK)
    if (not isMainLineOK) or (not isEliteOK) then
        return 
    end

    local isHas,eventType = EliteMapModel:isHasEventVisible()
    if isHas then
        local params = {
            viewType = FuncElite.TIPS_VIEW_TYPE.ENTER_NEXT_CHAPTER
        }
        WindowControler:showWindow("EliteReExploreRecomfirmView",params)
    else
        EventControler:dispatchEvent(EliteEvent.ELITE_GOTO_NEXT_CHAPTER)
    end
end

function EliteEndPointModel:goToNextChapter(event)
    if event and event.params and event.params.viewType then
        if event.params.viewType == FuncElite.TIPS_VIEW_TYPE.ENTER_NEXT_CHAPTER then
            EventControler:dispatchEvent(EliteEvent.ELITE_GOTO_NEXT_CHAPTER)
        end
    end
end

function EliteEndPointModel:createEventView()
    local viewCtn = self.grid.viewCtn
    local pointView = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_chuansongfazhen",nil, false, GameVars.emptyFunc)
    local tempYPos = 0
    local x = self.grid.pos.x
    local y = self.grid.pos.y +tempYPos
    local z = 0

    self:initView(viewCtn,pointView,x,y,z)
    local zorder = self.grid:getZOrder() + 1
    self:setZOrder(zorder)
end    


return EliteEndPointModel