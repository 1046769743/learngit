-- ArtifactCombinSuccess
-- Author: Wk
-- Date: 2017-07-22
-- 组合神器进阶系统成功界面

local ArtifactCombinSuccess = class("ArtifactCombinSuccess", UIBase);

-- ccid  是组合神器ID
function ArtifactCombinSuccess:ctor(winName,ccId,callBack)
    ArtifactCombinSuccess.super.ctor(self, winName);
    self.ccId = ccId
    self.callBack = callBack
end

function ArtifactCombinSuccess:loadUIComplete()
	-- local size = self.panel_sp:getContainerBox()
	-- self.panel_sp:setScaleX(GameVars.width/size.width)

	local a_black = FuncRes.a_black(1136*4,640*4)
	self.ctn_blackbg:addChild(a_black)
	self.panel_sp:setVisible(false)
	self.txt_2:setVisible(false)
	self:registerEvent()

	-- self:addBgEfftet()
	self:initData()
end 

function ArtifactCombinSuccess:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function ArtifactCombinSuccess:initData()
	local ccid = self.ccId
	local cimeliainfo = FuncArtifact.byIdgetCCInfo(ccid)
	local cimelianame = GameConfig.getLanguage(cimeliainfo.combineName)  --组合名称
	local anim  = cimeliainfo.combineicon  --组合动画
	local colorFrome = cimeliainfo.combineColor -- 名称颜色
	local quality = ArtifactModel:getCimeliaCombinequality(ccid)  --品质
	local _str = cimelianame.."+"..(quality)   -- 神器名称

	self.mc_name:showFrame(colorFrome)
	self.mc_name:getViewByFrame(colorFrome).txt_1:setString(_str)

	self.artifacticon = FuncArtifact.addChildMiddle(self.ctn_1,ccid)


	self:skillsDataShow()
end

function ArtifactCombinSuccess:setTwoDis(des)
	local combineId = self.ccId
	local skilldata =  FuncArtifact.byIdgetcombineUpInfo(combineId)--组合神器进阶数据
	local skillLevel =  ArtifactModel:getCimeliaCombinequality(combineId)  --品质
	if skillLevel == 0 then
		skillLevel = 1
	end
	self.txt_1:setVisible(false)
	local itemData =  skilldata[tostring(skillLevel)]
	if itemData ~= nil then
		if itemData.subAttr ~= nil then
			self.rich_1:setVisible(true)
			local str = FuncArtifact.byIdgetCCInfo(combineId).combineSkillDes
			local skillsArrtStr = FuncPartner.getCommonSkillDesc(itemData,tonumber(skillLevel),str)
			self.rich_1:setString(des.."\n\n"..skillsArrtStr)
		else
			self.rich_1:setString(des)
		end
	end
	-- if des == "" then
	-- 	local y = self.txt_1:getPositionY()
	-- 	self.rich_1:setPositionY(y)
	-- end
end

function ArtifactCombinSuccess:skillsDataShow()

	local ccid = self.ccId
	local ccinfo = FuncArtifact.byIdgetcombineUpInfo(ccid)  --组合进阶表
	local cimeliainfo = FuncArtifact.byIdgetCCInfo(ccid)    --组合表
	local quality = ArtifactModel:getCimeliaCombinequality(ccid)  --品质
	local datainfo = ccinfo[tostring(quality)] 
	local skillname = GameConfig.getLanguage(cimeliainfo.skillName)  -- 技能名称
	local skillicon = cimeliainfo.skillIcon  -- 技能图标
	local skilllevel = quality   -- 技能等级
	local des = ""
	local nextlvAbility = 0
	local lvAbility = 0--datainfo.lvAbility   ---进阶前的战力
	local nextdatainfo = ccinfo[tostring(quality)]
	if nextdatainfo ~= nil then
		if nextdatainfo.skillUpDes ~= nil then
			des = GameConfig.getLanguage(nextdatainfo.skillUpDes)   --技能进阶描述
		end
		nextlvAbility =  nextdatainfo.addAbility or 0 ---进阶后的战力
	end


	if datainfo ~= nil then
		lvAbility = datainfo.addAbility 
	end

	if skillicon ~= nil then
		local imagename =	FuncRes.iconSkill(skillicon)
		local sprites1 = display.newSprite(imagename)
		local sprites2 = display.newSprite(imagename)
		sprites1:setScale(0.9)
		sprites2:setScale(0.9)
		self.panel_ji1.ctn_1:addChild(sprites1)
		self.panel_ji2.ctn_1:addChild(sprites2)
	else
		echoError("没有技能资源图片，表里没配，找金钊 技能组合ID",ccid)
	end
	-- if skilllevel-1 >= 0 then
	-- 	skilllevel = skilllevel -1
	-- end
	local indexquality = ""
	if quality-1 ~= 0 then
		indexquality = "+"..quality-1
	end
	self.panel_ji1.txt_name:setString(skillname..indexquality)
	self.panel_ji2.txt_name:setString(skillname.."+"..quality)

	-- self.txt_1:setString(des)
	self:setTwoDis(des)

	local oldpower = ArtifactModel:getoldPower()
	-- local currentpower = ArtifactModel:getSinglePower(ccid)
	local currentpower = ArtifactModel:getSinglePower(ccid)
	if tonumber(oldpower) ~= tonumber(currentpower) then
		self.panel_number1.UI_1:setPower(oldpower)
		self.panel_number1.UI_2:setPower(currentpower)
	else
		self.panel_number1:setVisible(false)
		self.panel_zhalisuoqu:setVisible(false)
	end


	self:addBgEfftet()
end

function ArtifactCombinSuccess:addBgEfftet()
	local _bgctn = self.ctn_efbg
	local _type = FuncCommUI.EFFEC_TTITLE.ADVANCED
	FuncArtifact.playArtifactActiveSound()
	FuncCommUI.addCommonBgEffect(_bgctn,_type)
	self:effectReplaceUI()
end


--成功界面特效替换
function ArtifactCombinSuccess:effectReplaceUI()
	self.panel_zhalisuoqu:setVisible(false)
	self.panel_number1.panel_1:setVisible(false)
	self.panel_1:setVisible(false)
	local  lockAni  = self:createUIArmature("UI_shenqi_jinjie","UI_shenqi_jinjie_zhushenqi",self.ctn_1, false, function ()
		-- self.panel_zhalisuoqu:setVisible(true)
		self.panel_number1.UI_1:setVisible(true)
		self.panel_number1.UI_2:setVisible(true)


	end)
	lockAni:setPositionY(-20)
	FuncArmature.changeBoneDisplay(lockAni,"node6", self.artifacticon)
	FuncArmature.changeBoneDisplay(lockAni,"node1", self.panel_ji1)
	FuncArmature.changeBoneDisplay(lockAni,"node2", self.panel_ji2)
	FuncArmature.changeBoneDisplay(lockAni,"node4", self.panel_number1.UI_1)
	FuncArmature.changeBoneDisplay(lockAni,"node5", self.panel_number1.UI_2)
	-- FuncArmature.changeBoneDisplay(lockAni,"jt", self.panel_number1.panel_1)
	FuncArmature.changeBoneDisplay(lockAni,"shentong", self.panel_zhalisuoqu)
	-- panel_zhalisuoqu  

	self.artifacticon:setPosition(cc.p(0,0))
	self.panel_ji1:setPosition(cc.p(0,0))
	self.panel_number1.UI_1:setPosition(cc.p(-10,-10))
	self.panel_number1.UI_2:setPosition(cc.p(0,-10))
	self.panel_ji2:setPosition(cc.p(0,0))
	-- self.panel_number1.panel_1:setPosition(cc.p(0,25))
	self.panel_zhalisuoqu:setPosition(cc.p(38,5))
	lockAni:registerFrameEventCallFunc(50,1,function () 
		lockAni:pause(true)
	end)

	self:registClickClose(1, c_func( function()
        self:press_btn_close()
    end , self))

end


function ArtifactCombinSuccess:press_btn_close()
	-- EventControler:dispatchEvent(ArtifactEvent.ACTEVENT_COMBINATION_ADVANCED)
	if self.callBack then
		self.callBack()
	end
	self:startHide()
end


return ArtifactCombinSuccess;
