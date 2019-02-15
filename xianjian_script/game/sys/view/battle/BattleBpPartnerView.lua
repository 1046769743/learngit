--
-- Author: pangkangning
-- Note:仙界对决bp选人
-- Date: 2018-02-27 
--

local BattleBpPartnerView = class("BattleBpPartnerView", UIBase)


function BattleBpPartnerView:ctor(winName,controler)
    BattleBpPartnerView.super.ctor(self, winName)
    self.controler = controler
    self._selectIds = {}
end
function BattleBpPartnerView:loadUIComplete(  )
    -- FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)
	for i=1,2 do
		self["btn_"..i]:setTap(c_func(self.doSelectClick,self,i))
	end
    self:updateShowPartner()
end
-- 更新时间显示
function BattleBpPartnerView:onUpdateCD( )
    local leftFrame = self.controler.logical:getLeftAutoFrame()
    if leftFrame < 0 then
    	self.UI_di.txt_1:visible(false)
        return 
    end
    local minSec = math.ceil( leftFrame/GameVars.GAMEFRAMERATE )
    self.UI_di.txt_1:setString(minSec)--倒计时
    if minSec == 1 then
    	-- 选择一张牌随机选择一张牌
    	if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
			self:doSelectClick()
    	end
    end
end
-- 更新显示的卡牌
function BattleBpPartnerView:updateShowPartner()
	-- self.UI_di.txt_1:setString(text)--倒计时
	self.UI_di.mc_1:visible(false)
	self.UI_di.btn_close:visible(false)
	local camp = BattleControler:getTeamCamp( )
	local selectIds = self.controler.levelInfo:getBPPartnerByCampIndex(camp)
	if selectIds then
		self._selectIds = selectIds
		for i,v in ipairs(self._selectIds) do
			local cartInfo = FuncCrosspeak.getPartnerMapping(v.cardId)
			local tmp = {quality=cartInfo.quality,star = cartInfo.star}
			local view = self["btn_"..i]:getUpPanel().UI_1:updataUI(cartInfo.partnerId,skin,tmp)
		end
	else
		-- self.controler.gameUi.crossPeakView:closeBPView()
		-- echoError ("可以关闭了===这里在crosspeak中关闭")
	end
end
-- 选中某张牌 idx 为空表示随机选一张
function BattleBpPartnerView:doSelectClick( idx )
	if #self._selectIds == 0 then
		return
	end
	local camp = BattleControler:getTeamCamp( )
	self.controler.cpControler:sendCrossPeakBP(table.deepCopy(self._selectIds),camp,idx)
	self._selectIds = {} --我发送了以后，就不能再点击了，所以直接在这里设置为{}

    local leftFrame = self.controler.logical:getLeftAutoFrame()
	self.controler.cpControler:updateUseTime(leftFrame)
end
return BattleBpPartnerView