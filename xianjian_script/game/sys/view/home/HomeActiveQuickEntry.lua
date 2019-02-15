-- HomeActiveQuickEntry.lua
local HomeActiveQuickEntry = class("HomeActiveQuickEntry", UIBase);

	
local cdTime =  FuncDataSetting.getDataByConstantName("ActivityListShowTime")

function HomeActiveQuickEntry:ctor(winName)

    HomeActiveQuickEntry.super.ctor(self, winName);
end

function HomeActiveQuickEntry:loadUIComplete()
	self:registerEvent();
    -- self:initUI();
    -- self:scheduleUpdateWithPriorityLua(c_func(self.isOnTimeVisible, self) ,0)
    -- self.panel_1:setVisible(false)
end 


function HomeActiveQuickEntry:initUI()
	-- if self.panel_1:isVisible() then
	-- 	return
	-- end
	echo("=====刷新===HomeActiveQuickEntry====")
	local data =  HomeModel:getsystemIsOpen()
	self.openTime = TimeControler:getServerTime()
	if table.length(data) ~= 0 then
		--TODO  --处理是否显示过
		for i=1,table.length(data) do
			local systemName = data[i].associateActivity
			local systemData = HomeModel:getSystemIsHas(systemName)
			if not systemData then
				self:setUIData(data[i])
				return
			end
		end
	end
	-- HomeModel.systemToArr = {}
	self.panel_1:setVisible(false)
	EventControler:dispatchEvent(HomeEvent.LIMIT_NEXT_UI,{})
	

end

function HomeActiveQuickEntry:setUIData(baseData)
	dump(baseData,"基础数据 ===== === ")
	if baseData == nil then
		self.panel_1:setVisible(false)
		return
	end
	self.panel_1:setVisible(true)

	self.newbaseData = baseData
	local activityName = baseData.activityName
	-- self.panel_1.txt_1:setString(GameConfig.getLanguage(activityName))
	self.panel_1.mc_star:setVisible(false)
	if baseData.star then
		self.panel_1.mc_star:setVisible(true)
		local prame =  math.floor( baseData.star/2) 
		local index =  math.fmod(baseData.star, 2)
		if index ~= 0 then
			prame = prame + 1
		end
		self.panel_1.mc_star:showFrame(prame)
		local mc_star = self.panel_1.mc_star:getViewByFrame(prame)
		local prames = 1
		if index == 0 then
			prames = 2
		else
			prames = 1 
		end
		for i=1,prame-1 do
			mc_star["mc_"..i]:showFrame(2)
		end
		mc_star["mc_"..prame]:showFrame(prames)
	end
	self.panel_1.txt_1:setVisible(false)
	local name = baseData.associateActivity
	local systemicon1 = name.."_title.png"
    local spices = FuncRes.iconSys(systemicon1)
    local icon = display.newSprite(spices)
    -- icon:setScale(0.8)
    -- icon:anchor(0.1,0.8)
    self.panel_1.ctn_sytemname:removeAllChildren()
    self.panel_1.ctn_sytemname:addChild(icon)


	self.panel_1:setTouchedFunc(c_func(self.leaveforUI, self,baseData),nil,true);
	local ctn = self.panel_1.ctn_1
	ctn:removeAllChildren()
	local systemicon2 = FuncRes.iconSys(baseData.icon)
	local systemSprite =  display.newSprite(systemicon2)
	systemSprite:size(ctn.ctnWidth, ctn.ctnHeight);
	ctn:addChild(systemSprite)
	if name ~= FuncCommon.SYSTEM_NAME.SHAREBOSS then
		self:isOnTimeVisible()
	end


	
    local _effect = self.panel_1.ctn_eff:getChildByName("UI_tishi_zong")--armatureName[colorframe])
    if not _effect then
        -- echoError("=====self.panel_1.ctn_eff========",self.panel_1.ctn_eff)
        _effect= self:createUIArmature("UI_tishi","UI_tishi_zong", self.panel_1.ctn_eff, true, GameVars.emptyFunc)
        _effect:setName("UI_tishi_zong")
    end
    _effect:startPlay(true)


end

--前往按钮
function HomeActiveQuickEntry:leaveforUI(baseData)
 
	dump(baseData," ===== 前往按钮的数据 ========  ")
	local systemName  = baseData.associateActivity
	local arr = FuncHome.Timelimit_activity
	if arr[systemName] then
		if systemName  ~= FuncCommon.SYSTEM_NAME.SHAREBOSS then
			HomeModel:setSystemToArr(systemName)
			self.panel_1:setVisible(false)
			EventControler:dispatchEvent(HomeEvent.LIMIT_NEXT_UI,{})
		end
		arr[systemName].funName()
	end
end

--时间是否到，显示不显示
function HomeActiveQuickEntry:isOnTimeVisible()

	local serverTime =  TimeControler:getServerTime()
	if self.openTime + cdTime < serverTime then
		self.panel_1:setVisible(false)
		self.openTime = nil
		HomeModel:setSystemToArr(self.newbaseData.associateActivity)
		EventControler:dispatchEvent(HomeEvent.LIMIT_NEXT_UI,{})
	else
		self.panel_1:setVisible(true)
		local time = self.openTime + cdTime - serverTime
		self:delayCall(function ()
			self.panel_1:setVisible(false)
			HomeModel:setSystemToArr(self.newbaseData.associateActivity)
			EventControler:dispatchEvent(HomeEvent.LIMIT_NEXT_UI,{})
		end,time)
	end
end


--推送开启了
function HomeActiveQuickEntry:notifyOpen()
	local openArr = HomeModel:getsystemIsOpen()
	for i=1,#openArr do
		local systemName = openArr[i].associateActivity
		local ishave = HomeModel:getSystemIsHas(systemName)
		if not ishave then
			EventControler:dispatchEvent(HomeEvent.LIMIT_NEXT_UI,{})
			return
		end
	end
end



function HomeActiveQuickEntry:registerEvent()
	HomeActiveQuickEntry.super.registerEvent();

end



function HomeActiveQuickEntry:updateUI()
	
end


return HomeActiveQuickEntry;
