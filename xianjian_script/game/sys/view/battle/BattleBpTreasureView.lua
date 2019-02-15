--
-- Author: pangkangning
-- Note:仙界对决bp选法宝
-- Date: 2018-02-27 
--

local BattleBpTreasureView = class("BattleBpTreasureView", UIBase)

function BattleBpTreasureView:ctor(winName,controler)
    BattleBpTreasureView.super.ctor(self, winName)
    self.controler = controler
    self._selectIds = {}
end

function BattleBpTreasureView:loadUIComplete(  )
	for i=1,2 do
		self["btn_"..i]:setTap(c_func(self.doSelectClick,self,i))
	end
    self:updateShowTreasure()
end
-- 更新时间显示
function BattleBpTreasureView:onUpdateCD( )
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
function BattleBpTreasureView:updateShowTreasure()
	self.UI_di.mc_1:visible(false)
	self.UI_di.btn_close:visible(false)

	local oData = self.controler.levelInfo:getCrossPeakOtherData()
	local segData = FuncCrosspeak.getSegmentDataById(oData.seg)
    local avatar = UserModel:avatar()
	local camp = BattleControler:getTeamCamp( )
	local selectIds = self.controler.levelInfo:getBPTreasureByCampIndex(camp)
	if selectIds then
		self._selectIds = selectIds
		for i,v in ipairs(self._selectIds) do
			local view = self["btn_"..i]:getUpPanel().panel_1
			local tData = FuncTreasureNew.getTreasureDataById(v.cardId)
			-- dump(tData,"====")
			view.txt_1:setString(GameConfig.getLanguage(tData.name))
			view.mc_skill:showFrame(1)
			local sp = display.newSprite(FuncRes.iconTreasureNew(v.cardId))
		    view.mc_skill.currentView.ctn_1:removeAllChildren()
		    view.mc_skill.currentView.ctn_1:addChild(sp)
		    view.mc_type:showFrame(tData.type)
		    view.mc_star:showFrame(segData.starTreasure)
		    -- view.mc_star:visible(false)
		    local energyCost = FuncTreasureNew.getEnergyCost(v.cardId,segData.starTreasure)
		    view.txt_cost:setString(GameConfig.getLanguage("#tid_wuxing_031")..energyCost)

		    local skills = FuncTreasureNew.getTeasureSkillsByIdAndAvatar(v.cardId, avatar)
		    local skillData = FuncTreasureNew.getTreasureSkillDataDataById(skills[1])
		    local skillDes = GameConfig.getLanguage(skillData.describe)
		    view.txt_name:setString(GameConfig.getLanguage(skillData.name))
		    view.rich_des:setString(skillDes)
		end
	end
end
-- 
function BattleBpTreasureView:doSelectClick( idx )
	if #self._selectIds == 0 then
		return
	end
	local camp = BattleControler:getTeamCamp( )
	self.controler.cpControler:sendCrossPeakBP(table.deepCopy(self._selectIds),camp,idx)
	self._selectIds = {} --我发送了以后，就不能再点击了，所以直接在这里设置为{}

    local leftFrame = self.controler.logical:getLeftAutoFrame()
	self.controler.cpControler:updateUseTime(leftFrame)
end
return BattleBpTreasureView