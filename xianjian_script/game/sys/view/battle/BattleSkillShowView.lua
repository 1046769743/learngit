--[[
	Author: lcy
	Date:2018-07-04
	Description: 奇侠技能展示时的ui
]]

local BattleSkillShowView = class("BattleSkillShowView", UIBase)

local MOVEDIS = 100

function BattleSkillShowView:loadUIComplete()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2, UIAlignTypes.MiddleBottom)

	self:registEvent()

	self:setDes("")
	-- 先把黑条移出屏幕
	self.panel_1:setPositionY(self.panel_1:getPositionY() + MOVEDIS)
	self.panel_2:setPositionY(self.panel_2:getPositionY() - MOVEDIS)

	self:showInAnim()

	-- 给个大黑屏转场
	self.black = FuncRes.a_black(GameVars.width,GameVars.height,0):anchor(0, 1):zorder(100):addTo(self)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.black, UIAlignTypes.LeftTop)
end

function BattleSkillShowView:registEvent()
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)
	
	self.panel_1.btn_1:setTouchedFunc(c_func(self.onClickClose,self))
end

-- 直接设置条幅
function BattleSkillShowView:setDes(str)
	self.panel_2.txt_1:setString(str)
end

-- 有动画的方式显示条幅
function BattleSkillShowView:showDes(str)
	-- 以前的消失，换完新的出现
	local actarr = {
		cc.FadeOut:create(0.3),
		cc.CallFunc:create(function()
			self.panel_2.txt_1:setString(str)
		end),
		cc.FadeIn:create(0.3),
	}
	self.panel_2.txt_1:runAction(cc.Sequence:create(actarr))
end

-- 播放进场动画
function BattleSkillShowView:showInAnim()
	self.panel_1:runAction(cc.MoveBy:create(0.3, cc.p(0, -MOVEDIS)))
	self.panel_2:runAction(cc.MoveBy:create(0.3, cc.p(0, MOVEDIS)))
end

-- 播放转场
function BattleSkillShowView:shwoTransitionEff(middleCallFunc, finalCallFunc)
	-- 播转场时屏蔽返回，结束打开
	self:disabledUIClick()
	-- 渐变变黑后再渐变变亮
	self.black:runAction(cc.Sequence:create({
		cc.FadeIn:create(0.9),
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(middleCallFunc),
		cc.FadeOut:create(0.9),
		cc.CallFunc:create(function()
			if finalCallFunc then finalCallFunc() end
			self:resumeUIClick()
		end)
	}))
end

function BattleSkillShowView:setControler(controler)
	self.controler = controler
end
-- override
function BattleSkillShowView:updateFrame()
	
end

function BattleSkillShowView:onClickClose()
	-- self:startHide()
	-- FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SUREQUIT )
	self.controler:pressGameQuit()
end
-- override
function BattleSkillShowView:showBuzhenFinish()

end
-- override
function BattleSkillShowView:onRoundStart()
	local camp = self.controler:getUIHandleCamp()
	local ani = self["ani_chushou_"..camp]

	if not ani then
	    local aniName 
	    local aniNameQuan
	    if camp == 1 then
	        aniName = "UI_zhandou_youfangjingong"
	    else
	        aniName = "UI_zhandou_difangjingong"
	    end
	    ani = self:createUIArmature("UI_zhandou", aniName, self._root, true)

	    local xpos,ypos
	    ypos = -100
	    if camp == 2 then
	        xpos = 150
	        ani:pos(xpos,ypos)
	        FuncCommUI.setViewAlign(self.widthScreenOffset,ani,UIAlignTypes.Left)
	    else
	        xpos = GameVars.gameResWidth  - 150
	        ani:pos(xpos,ypos)
	        FuncCommUI.setViewAlign(self.widthScreenOffset,ani,UIAlignTypes.Right)
	    end

	    self["ani_chushou_"..camp] = ani
	end
	ani:visible(true)
	ani:stopAllActions()
	ani:runEndToNextLabel(0,1,false,true,60)
end

return BattleSkillShowView