-- ArtifactActivationSuccess.lua
-- Author: Wk
-- Date: 2017-07-22
-- 组合神器激活系统成功界面

local ArtifactActivationSuccess = class("ArtifactActivationSuccess", UIBase);

-- ccid  是组合神器ID
function ArtifactActivationSuccess:ctor(winName,ccId,_callback)
    ArtifactActivationSuccess.super.ctor(self, winName);
    self.ccId = ccId
    self._callback = _callback
end

function ArtifactActivationSuccess:loadUIComplete()
	self:addBgEfftet()
	self:addJiantouEff()
	self:initData()
	self:cellviewData()
	
end 

function ArtifactActivationSuccess:registerEvent()
	
end

function ArtifactActivationSuccess:addJiantouEff()
	
	local aim = self:createUIArmature("UI_common", "UI_common_jiantou" ,self.panel_3.ctn_jiantou, false ,function ()
		-- self:middleView(self.cimeliaId,true)
	end )
end

function ArtifactActivationSuccess:initData()
	local ccid = self.ccId
	local cimeliainfo = FuncArtifact.byIdgetCCInfo(ccid)
	local cimelianame = GameConfig.getLanguage(cimeliainfo.combineName)  --组合名称
	local anim  = cimeliainfo.combineicon  --组合动画
	local colorFrome = cimeliainfo.combineColor -- 名称颜色
	local quality = ArtifactModel:getCimeliaCombinequality(ccid)  --品质
	local _str = cimelianame.."+"..(quality)   -- 神器名称
	self.panel_2.mc_1:showFrame(colorFrome)
	self.panel_2.mc_1:getViewByFrame(colorFrome).txt_1:setString(_str)
	local ctn = self.panel_2.ctn_1
	FuncArtifact.addChildMiddle(ctn,ccid)

end

function ArtifactActivationSuccess:cellviewData()

	local baseCell1 = self.panel_3.panel_1
	local baseCell2 = self.panel_3.panel_2

	local artifactId = self.ccId 
	local artifactalldata = FuncArtifact.byIdgetCCInfo(artifactId)
	local CCInfo =  FuncArtifact.byIdgetCCInfo(artifactId)
	local colortframe = CCInfo.combineColor

 	local ctn1 = baseCell1.ctn_2
 	FuncArtifact.addChildToCtn(ctn1,artifactId,0)
 	baseCell1.mc_1:showFrame(colortframe-1)

 	baseCell1.btn_1:setVisible(false)
	baseCell1.panel_xuan:setVisible(false)
	baseCell1.panel_c:setVisible(false)
	baseCell1.panel_suo:setVisible(false)
	baseCell1.panel_red:setVisible(false)

	local ctn2 = baseCell2.ctn_2
 	FuncArtifact.addChildToCtn(ctn2,artifactId,1)
 	baseCell2.mc_1:showFrame(colortframe-1)
 	baseCell2.btn_1:setVisible(false)
	baseCell2.panel_xuan:setVisible(false)
	baseCell2.panel_c:setVisible(false)
	baseCell2.panel_suo:setVisible(false)
	baseCell2.panel_red:setVisible(false)


	local powernumber = ArtifactModel:getSinglePower(artifactId)
	self.panel_3.UI_2:setPower(powernumber)
		


	local artifactalldata = FuncArtifact.byIdgetCCInfo(artifactId)--组合神器数据
	local skillname = GameConfig.getLanguage(artifactalldata.skillName)  --组合技能名称
	self.panel_1.txt_1:setString(skillname)
	local skillLevel = 1
	local skilldata =  FuncArtifact.byIdgetcombineUpInfo(artifactId)--组合神器进阶数据
	skilltable = skilldata[tostring(1)]
    local des = FuncArtifact.byIdgetCCInfo(artifactId).combineSkillDes
	local skillsArrtStr = FuncPartner.getCommonSkillDesc(skilltable,tonumber(skillLevel),des)
	self.panel_1.rich_1:setString(skillsArrtStr)


end




function ArtifactActivationSuccess:addBgEfftet()

	local function _callback()
		self:registClickClose(-1, c_func( function()
			if self._callback then
				self._callback()
			end
	        self:press_btn_close()
	    end , self))
	end

	local _bgctn = self.ctn_2
	local _type = FuncCommUI.EFFEC_TTITLE.ACTIVATION
	FuncArtifact.playArtifactActiveSound()
	FuncCommUI.addCommonBgEffect(_bgctn,_type,_callback)
	-- self:effectReplaceUI()
end




function ArtifactActivationSuccess:press_btn_close()
	-- EventControler:dispatchEvent(ArtifactEvent.ACTEVENT_COMBINATION_ADVANCED)
	self:startHide()
end


return ArtifactActivationSuccess;
