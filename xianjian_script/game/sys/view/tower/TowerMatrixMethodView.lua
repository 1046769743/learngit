--[[
	Author: caocheng
	Date:2017-09-11
	Description: TODO
]]

local TowerMatrixMethodView = class("TowerMatrixMethodView", UIBase);

function TowerMatrixMethodView:ctor(winName,viewId,girdPos)
    TowerMatrixMethodView.super.ctor(self, winName)
    self.matrixMethodId = viewId
    self.girdPos = girdPos or {}
end

function TowerMatrixMethodView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerMatrixMethodView:registerEvent()
	TowerMatrixMethodView.super.registerEvent(self);
	self.btn_back:setTouchedFunc(c_func(self.press_btn_close,self))
	EventControler:addEventListener(TowerEvent.TOWEREVENT_GOINTO_MATRIXMETHOD,self.changePosView,self) 
end

function TowerMatrixMethodView:initData()
	--临时使用
	self.matrixMethodData = FuncTower.getTowerAltarDataByID(1)
	--阵位数据
	self.matrixMethodPosition = {}
    --阵位动画
    self.matrixMethodAni = {}
end

function TowerMatrixMethodView:initView()
	self:createPositionView()
	self.mc_btn.currentView.btn_1:setTouchedFunc(c_func(self.oneKeyByView,self))
end

function TowerMatrixMethodView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res,UIAlignTypes.MiddleTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_btn,UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res,UIAlignTypes.RightTop);
end

function TowerMatrixMethodView:updateUI()
	-- TODO
end

function TowerMatrixMethodView:createPositionView()
	self.mc_fazhen:showFrame(self.matrixMethodData.which)
	self.mc_fazhen.currentView.txt_1:setString(GameConfig.getLanguage(self.matrixMethodData.des))
	for k,v in pairs(self.matrixMethodData.condition) do
		local positionView = self.mc_fazhen.currentView["mc_"..k]
		self:createOnePosition(positionView,v,k)
		local nameText = self.matrixMethodData.translate[k]
		 self.mc_fazhen.currentView["mc_"..k].currentView.rich_1:setString(GameConfig.getLanguage(nameText))
	end	
end

function TowerMatrixMethodView:createOnePosition(view,data,pos)
	local posData = string.split(data,",")
	if tostring(posData[1]) == "1" or  tostring(posData[1]) == "3" or tostring(posData[1]) == "6" then
		view.currentView.panel_1:setTouchedFunc(c_func(self.enterChooseTargetView,self,data,pos))
	else
		--法宝备用
	end
end	


function TowerMatrixMethodView:enterChooseTargetView(posData,pos)
	local tempData = string.split(posData,",")
	local tempType = nil
	local hasHero  = true 
	if tostring(tempData[1]) == "1" then
		tempType = tonumber(tempData[2])
	else
		tempType = 0
	end
	if self.matrixMethodData.lead == 0 then
		hasHero = false
	end
	WindowControler:showWindow("TowerChooseBuffTarget",FuncTower.CHOOSEHERO_TYPE.FORMATION_VIEW,nil,nil,tempType,pos,self.matrixMethodPosition,hasHero)	

end


function TowerMatrixMethodView:press_btn_close()
	self:startHide()
end

function TowerMatrixMethodView:changePosView(event)
	local pos = event.params.pos
     self:disabledUIClick()
	local viewData = event.params.heroData
	self:upDataPosView(pos,viewData)
	self:checkComplete()
end

function TowerMatrixMethodView:upDataPosView(pos,viewData)
	local view = self.mc_fazhen.currentView["mc_"..pos]
	view:showFrame(2)
	local star = viewData.star
    view.currentView.UI_1.mc_dou:visible(true)
    if star ==0 then
        view.currentView.UI_1.mc_dou:visible(false)
    else
        view.currentView.UI_1.mc_dou:showFrame(star)
    end
	local quality = viewData.quality
    local qualityNum = nil
    if tonumber(viewData.id) == 101 or tonumber(viewData.id) ==104 then
        qualityNum = FuncChar.getCharQualityDataById(quality).border
    else
        qualityNum = FuncPartner.getPartnerQuality(tostring(viewData.id))[tostring(viewData.quality)].color
    end
    view.currentView.UI_1.mc_di:showFrame(tonumber(qualityNum))
    view.currentView.UI_1.mc_kuang:showFrame(tonumber(qualityNum))
    local icon = viewData.icon
    --这里应该判断是否是主角
    if tonumber(viewData.id) == 101 or tonumber(viewData.id) ==104 then
        local avatarId = UserModel:avatar()
        local iconid = UserModel:head()
        icon = FuncUserHead.getHeadIcon(iconid,avatarId)
    end
    
    view.currentView.UI_1.ctn_1:removeAllChildren()
    view.currentView.UI_1.panel_lv:visible(false)
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:setScale(1.2)

    -- 通过遮罩实现头像裁剪
    local  _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,display.newSprite( FuncRes.iconHero(icon) ):scale(1.2) )
    view.currentView.UI_1:setTouchedFunc(c_func(self.comeDownPos,self,pos))
    view.currentView.UI_1.ctn_1:addChild(_spriteIcon)
    self.matrixMethodPosition[pos] = viewData.id

    --动画
    local sealAni = self:createUIArmature("UI_suoyaota","UI_suoyaota_dangejihuo",nil, false, function ()
        self:resumeUIClick()
    end) 
    sealAni:pos(29,-30)   
    self.mc_fazhen.currentView["mc_"..pos]:addChild(sealAni)
    self.matrixMethodAni[pos] = sealAni
end

function TowerMatrixMethodView:comeDownPos(pos)
	local view = self.mc_fazhen.currentView["mc_"..pos]
	view:showFrame(1)
	self.matrixMethodPosition[pos] = 0
    -- WindowControler:showTips({text = "填充取消"})
    self:checkComplete()
end

function TowerMatrixMethodView:deleteMe()
	TowerMatrixMethodView.super.deleteMe(self);
end

function TowerMatrixMethodView:oneKeyByView()
	local hasHero  = true 
	if self.matrixMethodData.lead == 0 then
		hasHero = false
	end
	self.matrixMethodPosition = {}
	local showTips = nil
	for k,v in pairs(self.matrixMethodData.condition) do 
		local posData = string.split(v,",")
		local tempType = nil
		if tostring(posData[1]) == "1" or  tostring(posData[1]) == "3" or tostring(posData[1]) == "6" then
			if tostring(posData[1]) == "1" then
				tempType = tonumber(posData[2])
			else
				tempType = 0
			end
			local matchConditionData = TowerMainModel:getBruiseTeamFormation(nil,hasHero,tempType,true,self.matrixMethodPosition) 
			if table.length(matchConditionData) ~= 0 then
				self:upDataPosView(k,matchConditionData[1])
			else
				if not showTips then
					showTips = FuncTower.SHOW_TIPS.PARTNER
				end
			end
		else
			--法宝备用
		end
	end

	if showTips then
		if showTips == FuncTower.SHOW_TIPS.PARTNER then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_045")) 
		else
			--法宝备用
		end
	end
	self:checkComplete()
end

function TowerMatrixMethodView:checkComplete()
	local nowHasCompleteNum  =0
	for k,v in pairs(self.matrixMethodPosition) do
		if tonumber(v) ~= 0 then
			nowHasCompleteNum = nowHasCompleteNum + 1
		end
	end
	if nowHasCompleteNum == table.length(self.matrixMethodData.condition) then
		self.mc_btn:showFrame(2)
		self.mc_btn.currentView.btn_1:setTouchedFunc(c_func(self.completeMatrixMethod,self))
	else
		self.mc_btn:showFrame(1)
		self.mc_btn.currentView.btn_1:setTouchedFunc(c_func(self.oneKeyByView,self))	
	end
end

function TowerMatrixMethodView:completeMatrixMethod()
	-- WindowControler:showTips("完成了破阵")
	local matrixMethod = {}
	matrixMethod.x = self.girdPos.x
	matrixMethod.y = self.girdPos.y
	matrixMethod.units = self.matrixMethodPosition
    TowerServer:takeAltar(matrixMethod,c_func(self.takeAltarEffect,self))
end

function TowerMatrixMethodView:takeAltarEffect(event)
    if event.error then

    else
       self:disabledUIClick()
        local closeViewAni = self:createUIArmature("UI_suoyaota","UI_suoyaota_pozhen",self.ctn_effect, false, function ()
            self:resumeUIClick()
            TowerMainModel:updateData(event.result.data)
            EventControler:dispatchEvent(TowerEvent.TOWEREVENT_TAKEALTAR,{x = self.girdPos.x,y = self.girdPos.y+7}) 
            self:startHide()
        end) 
        FuncArmature.setArmaturePlaySpeed(closeViewAni,0.8)
    end
end

return TowerMatrixMethodView;
