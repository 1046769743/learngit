-- ChallengePvPModel
--wk

local ChallengePvPModel = class("ChallengePvPModel");

ChallengePvPModel.KEYS = {
    PVP = "pvp", ---登仙台
    SHAREBOSS = "shareBoss", --幻境协战
    DELEGATE  = "delegate", --仙灵委托
    CROSSPEAK = "crossPeak",  --仙界对决
    RING = "ring", --跑环  情缘任务 
}


function ChallengePvPModel:ctor()

end

function ChallengePvPModel:init()
    EventControler:addEventListener(ChallengeEvent.CHALLENG_PVP_RED, self.dispatchTZHDEvent, self) 
    self:dispatchTZHDEvent()
end




function ChallengePvPModel:checkShowRed()
   
	local isShow1 = PVPModel:isRedPointShow()
	local isShow2 = CrossPeakModel:isShowRed()
	local isShow3 = DelegateModel:isShowRedPoint()
	return isShow1 or isShow2 or isShow3 or false
end

function ChallengePvPModel:dispatchTZHDEvent()
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        {redPointType = HomeModel.REDPOINT.DOWNBTN.PVP, isShow = self:checkShowRed()});
end


function ChallengePvPModel:getChallengeSystemPos(systemName)
    local ChallengePvpView = WindowControler:getWindow("ChallengePvpView") 
    if not ChallengePvpView then
        return nil 
    end
    --跳转到对应的位置
    local groupIndex = ChallengePvpView:todoView(systemName)
    local _viewArr = ChallengePvpView.scroll_1:getAllView()
    for i=1,#_viewArr do
        if i == groupIndex then
            local box = _viewArr[i]:getContainerBox()
            local cx = box.x + box.width/2
            local cy = box.y + box.height/2
            turnPos = _viewArr[i]:convertToWorldSpaceAR(cc.p(cx,cy))
            echo("========系统位置  x   y  =========",turnPos.x,turnPos.y)
            return  turnPos
        end
    end
    return nil
end



function ChallengePvPModel:getChallengModelData()
    local config_pvp_challenge = FuncChallenge.getPvpSystemData() 
    local newArr = {}
    for k,v in pairs(config_pvp_challenge) do
        table.insert(newArr,v) 
    end
    table.sort( newArr, function (a,b)
        return a.frame < b.frame
    end )
    return newArr
end


function ChallengePvPModel:getIconsBySystemId(typeID)
    local itemIds = FuncChallenge.getPvpIconByitemId(typeID)
    return itemIds
end



return ChallengePvPModel;





















