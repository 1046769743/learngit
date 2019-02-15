--[[
	Author: wk
	Date: 2018-04-23
	WorldMainToMoreView  --更多按钮的显示
]]

local WorldMainToMoreView = class("WorldMainToMoreView", UIBase)

local allButton_Count = 7  --当前有的按钮数量


function WorldMainToMoreView:ctor( winName, callBack)
	WorldMainToMoreView.super.ctor(self, winName)
	self.callBack = callBack

end

function WorldMainToMoreView:registerEvent()
	WorldMainToMoreView.super.registerEvent()
	-- EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
   	EventControler:addEventListener(HomeEvent.RED_POINT_EVENT,
        self.onRedChange, self);
   
end

function WorldMainToMoreView:loadUIComplete()
	self:registerEvent()
	self.scale9_Rect = self.scale9_1:getContainerBox()
	self.scale9_posY =  self.scale9_1:getPositionY()


	for i=1,allButton_Count do
		self["btn_"..i]:setVisible(false)
		self["btn_"..i]:getUpPanel().panel_red:visible(false)
	end

	self:registClickClose("-1", function ()
		EventControler:dispatchEvent(HomeEvent.HIDDEN_MORE_VIEW)
	end,true)

end


function WorldMainToMoreView:initView()
	self:initCellfun()
	self:createByutton()
	self:setButtonRed()
	self:addBUttonEffect()
end

--按钮添加特效
function WorldMainToMoreView:addBUttonEffect()
	-- dump(self.allButton,"44444444444")
	for k,v in pairs(self.allButton) do
		local map = HomeModel:getButtonEffectIsShow(v.name)
		if map then
			if  map._type then
                FuncCommUI.addHomeButtonEffect(v.cloneBtn,map,50)
            end
		end
	end
end

--创建按钮	
function WorldMainToMoreView:createByutton()
	self.allButton = {}
	local more_button = HomeModel.MORE_OTHER
	for k,v in pairs(more_button) do
		if v == FuncCommon.SYSTEM_NAME.MEMORYCARD then
			if MemoryCardModel:memorySysOpen() then
				local cloneBtn = self["btn_"..k]--UIBaseDef:cloneOneView(self["btn_"..k]);
				cloneBtn:setVisible(true)
				cloneBtn:setTouchedFunc(c_func(self._btnFuncs[tonumber(k)], self), nil,true);
				table.insert(self.allButton,{cloneBtn=cloneBtn,name = v})
			end
		else
			local isopen = FuncCommon.isSystemOpen(v)
			if isopen then
				local cloneBtn = self["btn_"..k]--UIBaseDef:cloneOneView(self["btn_"..k]);
				cloneBtn:setVisible(true)
				cloneBtn:setTouchedFunc(c_func(self._btnFuncs[tonumber(k)], self), nil,true);
				table.insert(self.allButton,{cloneBtn=cloneBtn,name = v})
			end
		end
	end
	
	for k,v in pairs(self.allButton) do
		local ctn =  self["ctn_"..k]
		local posX =  ctn:getPositionX()
		local posY =  ctn:getPositionY()
		v.cloneBtn:setPosition(cc.p(posX,posY))
	end

	local num = table.length(self.allButton)
	-- dump(self.scale9_Rect,"1111111111111")
	if num <= 4 then
		self.scale9_1:setContentSize(cc.size(self.scale9_Rect.width,self.scale9_Rect.height/2+15))
		self.scale9_1:setPositionY(self.scale9_posY - self.scale9_Rect.height/2+15)
	else
		self.scale9_1:setContentSize(cc.size(self.scale9_Rect.width,self.scale9_Rect.height))
		self.scale9_1:setPositionY(self.scale9_posY)
	end
end


function WorldMainToMoreView:getRedData(_type)
	if _type== 1 then
		return HomeModel:isRedPointShow(HomeModel.REDPOINT.DOWNBTN.SHOP)
	elseif _type == 2 then
		return TeamFormationModel:checkFormationRedPoint()
	elseif _type == 3 then
		return MemoryCardModel:checkRedPointShow()
	elseif _type == 4 then
		return TreasureNewModel:homeRedPointEvent()
	elseif _type == 5 then
		return WuLingModel:checkRedPoint()
	elseif _type == 6 then
		return false
	elseif _type == 7 then
		return HandbookModel:isShowHandbookRed()
	end
	return false--reddata[tonumber(_type)]
end


function WorldMainToMoreView:onRedChange(e )
	self:stopAllActions()
	self:delayCall(c_func(self.setButtonRed,self,e), 0.01)
	-- self:setButtonRed(e)

end

function WorldMainToMoreView:setButtonRed(_file)
	local more_button = HomeModel.MORE_OTHER
	for k,v in pairs(more_button) do

		local isopen = false
		if v == FuncCommon.SYSTEM_NAME.MEMORYCARD then
			isopen = MemoryCardModel:memorySysOpen( )
		else
			isopen = FuncCommon.isSystemOpen(v)
		end

		if isopen then
			local cloneBtn = self["btn_"..k]--UIBaseDef:cloneOneView(self["btn_"..k]);
			local isShowRed = false
			if not _file then
				isShowRed = self:getRedData(k)
			else
				isShowRed = HomeModel:isRedPointShow(v)
			end
			cloneBtn:getUpPanel().panel_red:setVisible(isShowRed or false)
		end
	end
end



function WorldMainToMoreView:initCellfun()
	self._btnFuncs = {
        [1] = self.clickshop,
        [2] = self.clickArr,
        [3] = self.onClickGoMemoryView,
        [4] = self.clickTreasure,
        [5] = self.clickwuling,
        [6] = self.clickRankList,
        [7] = self.clickHandBook,
	}
end

-- 名册系统
function WorldMainToMoreView:clickHandBook()
	local isopen =  FuncCommon.isSystemOpen("handbook")
    if isopen then
        WindowControler:showWindow("HandbookMainView")
    end
    EventControler:dispatchEvent(HomeEvent.HIDDEN_MORE_VIEW)
end

--布阵
function WorldMainToMoreView:clickArr()
	local isopen =  FuncCommon.isSystemOpen("array")
    if isopen then
        local parameter = FuncTeamFormation.formation.pve
        params = {}
        WindowControler:showWindow("WuXingTeamEmbattleView",parameter,params,true,false)
    end
    EventControler:dispatchEvent(HomeEvent.HIDDEN_MORE_VIEW)
end


function WorldMainToMoreView:clickshop()
	EventControler:dispatchEvent(HomeEvent.HIDDEN_MORE_VIEW)
	FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.SHOP_1)
	
end

function WorldMainToMoreView:clickwuling()
	WindowControler:showWindow("WuLingMainView")
	EventControler:dispatchEvent(HomeEvent.HIDDEN_MORE_VIEW)
end

--前尘忆梦  --情景卡
function WorldMainToMoreView:onClickGoMemoryView()
	MemoryCardModel:showMemoryCardView( )
	EventControler:dispatchEvent(HomeEvent.HIDDEN_MORE_VIEW)
end

--法宝
function WorldMainToMoreView:clickTreasure()
	FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.TREASURE_NEW)
	EventControler:dispatchEvent(HomeEvent.HIDDEN_MORE_VIEW)
end

function WorldMainToMoreView:clickRankList()
	WindowControler:showWindow("RankListMainView")
	EventControler:dispatchEvent(HomeEvent.HIDDEN_MORE_VIEW)
end

function WorldMainToMoreView:removeUI()
end
return WorldMainToMoreView