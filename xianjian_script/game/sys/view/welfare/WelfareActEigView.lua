--[[
	Author: sjc
	Date:2018-03-22
	Description: sjc
]]

local WelfareActEigView = class("WelfareActEigView", UIBase);

function WelfareActEigView:ctor(winName)
    WelfareActEigView.super.ctor(self, winName)
end

function WelfareActEigView:loadUIComplete()
	self:registerEvent()

	self:initList()
end 

function WelfareActEigView:registerEvent()
	WelfareActEigView.super.registerEvent(self);
	EventControler:addEventListener(ActivityEvent.ACTEVENT_RETRIEVE_ITEM, self.refreshUI, self)
end

function WelfareActEigView:refreshUI()
	self:initList()
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end

function WelfareActEigView:initList()
	self.panel_gsq:visible(false)
	-- self.panel_1.txt_1:setString("资源找回")

	self.mf = FuncDataSetting.getDataByConstantName("ResRetrieveCommon")
	self.ff = FuncDataSetting.getDataByConstantName("ResRetrievePerfect")

	local Data = RetrieveModel:getRetrieveData()

	-- dump(Data,"--------sssssssss----------")

	-- 暂时屏蔽锁妖塔
	

	-- dump(openSys,"ddddddd")
	local createCellItemFunc = function ( itemData)
		local view = UIBaseDef:cloneOneView(self.panel_gsq)
		self:updateCellItem(view, itemData)
		return view
	end
	local updateCellItemFunc = function (itemData,itemView)
        self:updateCellItem(itemView, itemData);
        return itemView
    end
	local scrollParams = {
		{
			data = Data,
			createFunc = createCellItemFunc,
            -- updateCellFunc = updateCellItemFunc,
			offsetX = 330,
            offsetY = 110,
			perFrame = 1,
			-- itemRect = {x = -320,y = 100,width = 330,height = 155},
			itemRect = {x = 0,y = 0,width = 895.3,height = 107.7},
			perNums= 1,
			heightGap = 0
		}
	}
	
	self.scroll_1:styleFill(scrollParams);
	self.scroll_1:refreshCellView(1)
    self.scroll_1:hideDragBar()
end

function WelfareActEigView:updateCellItem( view, itemData )

-- - "资源找回数据" = {
-- -         "costGold" = 100
-- -         "reward" = {
-- -             1 = "1,40201,1"
-- -             2 = "1,40202,1"
-- -         }
-- -		"id" = "tower"
-- -        "complete" = 0
-- -}

	-- dump(itemData,"sssssssss")
	if not itemData.id then
		return
	end
	local panel = view
	local actTaskData = itemData
	-- panel.mc_2.currentView.panel_lq.btn_2:setBtnStr(itemData.costGold.."找回","txt_1")
	local mf = self.mf/100
	local ff = self.ff/100
	

	local name = RetrieveModel:getFuncTxt( itemData.id )
	if not name then
		echoError("表中没有这个系统")
	else
		panel.txt_1:setString(GameConfig.getLanguage(name))
	end
	local img = FuncRes.iconSys(itemData.id)
	-- RetrieveModel:getFuncImage( itemData.id )
	if not img then
		echoError("表中没有这个图片,找金钊")
	else
		local image = display.newSprite(img)
		-- local scaleImg = 143/image:getContentSize().width
		
		-- if itemData.id == "tower" then
		-- 	image:setPosition(cc.p(0,10))
		-- elseif itemData.id == "pvp" then
		-- 	image:setPosition(cc.p(5,0))
		-- elseif itemData.id == "shareBoss" then
		-- 	image:setPosition(cc.p(5,0))
		-- elseif itemData.id == "trial" then
		-- 	image:setPosition(cc.p(-5,5))
		-- elseif itemData.id == "wonderLand" then
		-- 	image:setPosition(cc.p(5,-5))
		-- elseif itemData.id == "endless" then
		-- 	image:setPosition(cc.p(3,0))
		-- elseif itemData.id == "spFood" then
		-- 	image:setPosition(cc.p(0,5))
		-- elseif itemData.id == "mission" then
		-- 	scaleImg = 120/image:getContentSize().width
		-- elseif itemData.id == "everydayQuest" then
		-- 	image:setPosition(cc.p(3,5))
		-- 	scaleImg = 120/image:getContentSize().width
		-- end
		panel.ctn_1:removeAllChildren()
		-- image:setScale(scaleImg)
		panel.ctn_1:addChild(image)
		
	end

	local rewardNum = 0
	
	for k,v in pairs(itemData.reward) do
		rewardNum = rewardNum + 1
	end
	
	local reData = {}

	if itemData.complete == 0 or itemData.complete == -1 then
		panel.mc_2:showFrame(1)
		local mc = panel.mc_2.currentView.panel_lq.mc_1
		panel.mc_2.currentView.panel_lq.btn_1:setBtnStr(mf.."%","txt_1")
		panel.mc_2.currentView.panel_lq.btn_2:setBtnStr(ff.."%","txt_1")
		panel.mc_2.currentView.panel_lq.txt_3:setString("免费")
		panel.mc_2.currentView.panel_lq.txt_4:setString(itemData.costGold)
		if rewardNum >= 4 then
			mc:showFrame(1)
			local showT = {}
			local keyNum = 0
			if itemData.id == "trial" then
				local data = FuncTrail.getAlltrialData()
				-- dump(itemData.reward,"-------试炼窟数据--------")
				for kk,vv in pairs(itemData.reward) do
					for k,v in pairs(data) do
						-- dump(value, desciption, nesting)
						local tag = false
						local reward = v.reward3
						for i=1,#v.reward3 do
							local tables = string.split(v.reward3[i], ",");
							local tables1 = string.split(vv, ",");
							if tables[2] and tables[2] == tables1[2] then
								keyNum = keyNum + 1
								if keyNum < 5 then
									table.insert(showT,vv)
									tag = true
									break
								else
									break
								end
							end
						end
						if tag then
							break
						end
					end
					if keyNum == 5 then
						break
					end
				end
				reData = showT
				-- dump(itemData.reward,"-------试炼窟整理数据--------")
			else
				reData = itemData.reward
			end

			reData = self:doSort(reData)

			local i =1
			for k,v in ipairs(reData) do
				local itemid = 0
				local tables = string.split(v, ",");
				if #tables == 2 then
					itemid = tables[1]
				elseif #tables == 3 then
					itemid = tables[2]
				end
				mc.currentView["UI_"..i]:setResItemData({reward = v})
				-- mc.currentView["UI_"..i]:showResItemName(true,true)
			    mc.currentView["UI_"..i]:showResItemNum(true)
			    mc.currentView["UI_"..i]:showResItemNameWithQuality()
			    mc.currentView["UI_"..i]:setTouchedFunc(c_func(self.getItemPath, self,itemid))
			    i = i + 1
			    if i > 4 then
			    	break
			    end
			end
		elseif rewardNum == 3 then
			mc:showFrame(2)
			local i =1
			local temp = self:doSort(itemData.reward)
			for k,v in ipairs(temp) do
				local itemid = 0
				local tables = string.split(v, ",");
				if #tables == 2 then
					itemid = tables[1]
				elseif #tables == 3 then
					itemid = tables[2]
				end
				mc.currentView["UI_"..i]:setResItemData({reward = v})
				-- mc.currentView["UI_"..i]:showResItemName(true,true)
			    mc.currentView["UI_"..i]:showResItemNum(true)
			    mc.currentView["UI_"..i]:showResItemNameWithQuality()
			    mc.currentView["UI_"..i]:setTouchedFunc(c_func(self.getItemPath, self,itemid))
			    i = i + 1
			end
		elseif rewardNum == 2 then
			mc:showFrame(1)
			mc.currentView.UI_1:visible(false)
			mc.currentView.UI_4:visible(false)
			local i =2
			local temp = self:doSort(itemData.reward)
			for k,v in ipairs(temp) do
				local itemid = 0
				local tables = string.split(v, ",");
				if #tables == 2 then
					itemid = tables[1]
				elseif #tables == 3 then
					itemid = tables[2]
				end
				mc.currentView["UI_"..i]:setResItemData({reward = v})
				-- mc.currentView["UI_"..i]:showResItemName(true,true)
			    mc.currentView["UI_"..i]:showResItemNum(true)
			    mc.currentView["UI_"..i]:showResItemNameWithQuality()
			    mc.currentView["UI_"..i]:setTouchedFunc(c_func(self.getItemPath, self,itemid))
			    i = i + 1
			end
		elseif rewardNum == 1 then
			mc:showFrame(2)
			mc.currentView.UI_1:visible(false)
			mc.currentView.UI_3:visible(false)
			local temp = self:doSort(itemData.reward)
			for k,v in ipairs(temp) do
				local itemid = 0
				local tables = string.split(v, ",");
				if #tables == 2 then
					itemid = tables[1]
				elseif #tables == 3 then
					itemid = tables[2]
				end
				mc.currentView["UI_"..2]:setResItemData({reward = v})
				-- mc.currentView["UI_"..2]:showResItemName(true,true)
			    mc.currentView["UI_"..2]:showResItemNum(true)
			    mc.currentView["UI_"..2]:showResItemNameWithQuality()
			    mc.currentView["UI_"..2]:setTouchedFunc(c_func(self.getItemPath, self,itemid))
			end
		else
			panel.mc_2:showFrame(3)
			return
		end

		
	elseif itemData.complete == 1 then
		panel.mc_2:showFrame(2)
		return
	end
	

	panel.mc_2.currentView.panel_lq.btn_1:setTouchedFunc(c_func(self.advancedButton, self, itemData.id, 1, view),nil,true);
	panel.mc_2.currentView.panel_lq.btn_2:setTouchedFunc(c_func(self.advancedButton, self, itemData.id, 0, view),nil,true);
end

function WelfareActEigView:advancedButton( id, isfree, view )
	local params = {ids = {id}, isFree = isfree}
	-- dump(params,"发送数据::::")
	self.free = isfree
	-- echo("free1111111 = = =  = =  = = = ",isfree)
	self.funcid = id
	local Data = RetrieveModel:getRetrieveData()
	local val = 0
	if isfree == 0 then
		for k,v in pairs(Data) do
			if v.id == id then
				val = v.costGold
			end
		end
		if UserModel:getGold() < val then
			local tips = GameConfig.getLanguage("tid_common_1001")
	        WindowControler:showTips(tips)
	        return
		end
	end
	if id == "spFood" then
		local num = 0
		
		for k,v in pairs(Data) do
			if v.id == "spFood" then
				for kk,vv in pairs(v.reward) do
					if kk == "5" then
						local tables = string.split(vv, ",");
						num = tables[2]
					end
				end
			end
		end
		----如果是免费  需要乘以60%
		if isfree == 1 then
			num = (num * 60)/100
		end

	    local tid = "#tid_welfare_007"
		if UserModel:isSpOverflow(num, tid) then
			return
		end
	end
	ActivityServer:zhaohuiReward(params,c_func(self.btnTapCallBack,self,view))
end

function WelfareActEigView:btnTapCallBack( view,event )
	if event.result then
		-- dump(event,"返回数据::::")
		
		-- self:initList()
		local bl = self.mf/10000
		local Data = RetrieveModel:getRetrieveData()
		-- local data = {}
		for k,v in pairs(Data) do
			if v.id == self.funcid then
				-- data = v
				local rewards = v.reward
				
				local t = {}
				local temp = ""
				for kk,vv in pairs(rewards) do
					if self.free == 1 then
						local tables = string.split(vv, ",");
						-- dump(vv,"获得奖励:::")
						-- table.insert(t, vv)
						if tables[3] then
							local renum = tonumber(tables[3])
							local num = math.ceil(renum * bl)
							temp = tables[1]..","..tables[2]..","..num
						else
							local renum = tonumber(tables[2])
							-- echo("原奖励:"..renum.." 免费奖励"..bl)
							local num = math.ceil(renum * bl)
							temp = tables[1]..","..num
						end
						table.insert(t, temp)
					else
						table.insert(t, vv)
					end
				end

				-- dump(t,"获得奖励:::")
				FuncCommUI.startRewardView(t)
			end
		end
		if UserModel:isLvlUp() == true then 
            EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE); 
        end 
		-- local view = self.scroll_1:getViewByData(data)
		view.mc_2:showFrame(2)
		local funName
		if event.result.data.dirtyList.u.retrieve then
			for k,v in pairs(event.result.data.dirtyList.u.retrieve) do
				funName = k
				break
			end
		end
		RetrieveModel:setRetrieveData(funName)
		EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
	else
		local code = event.error.code
		if tonumber(code) == 670101 then
			WindowControler:showTips("资源已找回")

		elseif tonumber(code) == 670102 then
			WindowControler:showTips("系统未开启")
		else
			echoError("服务端返回数据错误，错误码:"..code)
		end
		
	end
end

--获取道具路径
function WelfareActEigView:getItemPath(itemid)
	WindowControler:showWindow("GetWayListView",itemid)
end

function WelfareActEigView:deleteMe()
	-- TODO

	WelfareActEigView.super.deleteMe(self);
end

--[[
	现在需要对此界面的奖励进行排序，但是此功能代码很乱，项目状况又无法重构，
	只能在显示前进行结构修改和排序了
]]
function WelfareActEigView:doSort(reward)
	local result = {}
	-- 预处理排序信息
	local t = {}
	local count = 0
	for k,v in pairs(reward) do
		count = count + 1
		table.insert(result, v)
		local tmp = string.split(v, ",")
		t[v] = {
			oidx = count,
			resType = tonumber(tmp[1]),
			quality = tonumber(FuncDataResource.getQualityById(tmp[1],tmp[2]) or 0),
		}
	end

	-- 排序
	table.sort(result, function(a,b)
		local a = t[a]
		local b = t[b]
		if a.quality == b.quality then
			if a.resType == b.resType then
				return a.oidx < b.oidx
			end

			return a.resType < b.resType
		end

		return a.quality > b.quality
	end)

	return result
end

return WelfareActEigView;
