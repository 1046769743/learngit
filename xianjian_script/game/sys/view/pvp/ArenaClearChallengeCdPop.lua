local ArenaClearChallengeCdPop = class("ArenaClearChallengeCdPop", UIBase)

function ArenaClearChallengeCdPop:ctor(winName)
	ArenaClearChallengeCdPop.super.ctor(self, winName)
end

function ArenaClearChallengeCdPop:loadUIComplete()
	self:registerEvent()
	local left = FuncPvp.getPvpCdLeftTime()
	self.cost = FuncCommon.getCdCostById("2")--FuncPvp.getClearCdCost(left)--//每次购买剩余次数的花费固定
	self:updateUI()
end

function ArenaClearChallengeCdPop:updateUI()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_pvp_1027"))
	self:setCost()
end

function ArenaClearChallengeCdPop:setCost()
	self.txt_cost:setString(self.cost)
	if self.cost > UserModel:getGold() then
		self.txt_cost:setColor(FuncCommUI.COLORS.TEXT_RED)
	end
end

function ArenaClearChallengeCdPop:registerEvent()
	self.UI_1.btn_close:setTap(c_func(self.close, self))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onConfirmTap, self))
	self:registClickClose("out")
    --如果冷却时间到了,此UI自动关闭,目前竞技场主场景已经有了该自动检测功能
    --EventControler:addEventListener("CD_ID_PVP_UP_LEVEL",self.close,self)
end

function ArenaClearChallengeCdPop:onConfirmTap()
    local   _user_vip=UserModel:vip()
    --冷却时间,必须是VIP6级以下
    assert(_user_vip<6);
	if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, self.cost, true) then
		self:close()
		return
	end
	local id = CdModel.CD_ID.CD_ID_PVP_UP_LEVEL
--[[	if UserModel:level() >= FuncPvp.PVP_CD_LEVEL then
		id = CdModel.CD_ID.CD_ID_PVP_UP_LEVEL
	end]]
	CdServer:clearCD(id, c_func(self.onClearCdOk, self),nil,nil,true)
end
--numeric_not_exist
function ArenaClearChallengeCdPop:onClearCdOk(event)
   if(event.result==nil)then
        if(event.error.message=="user_no_cd")then
            WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1048"));
            echo("--error in --ArenaClearChallengeCdPop------",event.error.message);
         	local eventKey = "CD_ID_PVP_UP_LEVEL"
--	            if tonumber(UserModel:level()) >= FuncPvp.PVP_CD_LEVEL then
--		                 eventKey = "CD_ID_PVP_UP_LEVEL"
--	            end
	        TimeControler:startOneCd(eventKey,0);
         end
    end
     EventControler:dispatchEvent(PvpEvent.PVPEVENT_CLEAR_CHALLENGE_CD_OK)
	 self:close()
end

function ArenaClearChallengeCdPop:close()
	self:startHide()
end

return ArenaClearChallengeCdPop

