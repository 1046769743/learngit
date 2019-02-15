-- GuildExploreCheckDispatchView
--[[
	Author: wk
	Date:2018-07-06
	Description: 查看派遣
]]

local GuildExploreCheckDispatchView = class("GuildExploreCheckDispatchView", UIBase);

function GuildExploreCheckDispatchView:ctor(winName,data)
    GuildExploreCheckDispatchView.super.ctor(self, winName)
    -- self.allData = GuildExploreModel:getAlleventsData(FuncGuildExplore.gridTypeMap.mine)
    self.allData = data
end

function GuildExploreCheckDispatchView:loadUIComplete()
	self:registerEvent()
	self:initViewAlign()
    self:getAllData()
	self:initData()
	
end 


function GuildExploreCheckDispatchView:getAllData()
    dump(self.allData,"获得map上所有的矿脉")
end

function GuildExploreCheckDispatchView:getServeData()
    local function callBack(data)
        self.allData = data
        self:initData()
    end
    GuildExploreEventModel:showGuildExploreCheckDispatchView(callBack)
end

function GuildExploreCheckDispatchView:registerEvent()
	GuildExploreCheckDispatchView.super.registerEvent(self);
	self:registClickClose("out")
	self.panel_1:setVisible(false)
	self.UI_1.btn_1:setTap(c_func(self.startHide,self))
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_126"))

    EventControler:addEventListener(GuildExploreEvent.GUILDEXPOREEVENT_SEND_PANTNER_UI, self.getServeData,self)

end

function GuildExploreCheckDispatchView:initData()


	local createFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_1);
        self:cellLineUpviewData(baseCell, itemData)
        return baseCell;
    end
     local updateCellFunc = function (itemData,view)
    	self:cellLineUpviewData(view, itemData)
	end



    local  _scrollParams = {
        {
            data = self.allData,
            createFunc = createFunc,
            updateCellFunc= updateCellFunc,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -155, width = 973, height = 155},
            perFrame = 1,
        }
    }    
    -- self.scroll_1:refreshCellView( 1 )
    self.scroll_1:cancleCacheView();
    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()
    -- self.scroll_2.setEnableScroll(false)
    self:unscheduleUpdate()
    self:scheduleUpdateWithPriorityLua(c_func(self.upDataFrame, self) ,0)
end

function GuildExploreCheckDispatchView:upDataFrame()
    if self.allData ~= nil then
        for k,v in pairs(self.allData) do
            if v.type == FuncGuildExplore.lineupType.mining then  ---矿脉的
                local cell = self.scroll_1:getViewByData( v )
                if cell  then
                    local serveTime = TimeControler:getServerTime()
                    local eventModel = GuildExploreModel:getEventData( v.eventId )
                    local percent =  0
                    if eventModel then
                    -- local percent = (serveTime - v.cTime)/(v.finishTime - v.cTime)*100
                        local baseData =  self:getFuncMineData("ExploreMine",eventModel.tid )
                        local sTime = baseData.time[v.index]
                        local minTime = v.finishTime - serveTime
                        percent = (minTime)/(sTime)*100
                    end

                    if percent > 0 then
                        local panel = cell.mc_1:getViewByFrame(1)
                        local panel2 = panel.mc_1:getViewByFrame(1)
                        local time = self:calculateTime(v.finishTime)
                        if time ~= "" then
                            panel2.txt_1:setString("此矿脉可开采"..time.."小时")
                            panel.progress_1:setPercent(percent)
                        else
                            cell.mc_1:showFrame(3)
                            local panel  = cell.mc_1:getViewByFrame(3)
                            panel.txt_2:setString("矿脉已崩塌")
                            cell.mc_2:setVisible(false)
                            cell.btn_1:setVisible(false)
                        end
                    end
                end
            end
        end
    end
end

function GuildExploreCheckDispatchView:cellLineUpviewData(baseCell, itemData)


    -- dump(itemData,"派遣的事件类型=====")

    -- if 1 then
    --     return 
    -- end
    local eventModel = GuildExploreModel:getEventData( itemData.eventId )
    -- dump(eventModel,"事件类型====")
    local _type = itemData.type ---派遣的事件类型
    if _type == FuncGuildExplore.lineupType.mining then  ---矿脉的
    	-- local isDispatch,pantnerList = GuildExploreModel:getPantnerIsbattle(itemData.eventId) --是否派遣
        local isDispatch = false 
        local pantnerList = {}--itemData.pidList
        for k,v in pairs(itemData.pidList) do
            isDispatch = true
            table.insert(pantnerList,{id = v})
        end
        
        -- echo("=======isDispatch======",isDispatch)
    	if isDispatch then
    		local isFinish = false ---是否完成，可以了领取奖励
    		local partherData = pantnerList  --派遣的伙伴数据
    		self:setPartnerData(baseCell,partherData)
            local _panel = nil
            local iconPath = nil
            local res = nil
            local allData =  self:getFuncMineData("ExploreMine",eventModel.tid )
            local resArr = allData.timeYield
            -- if resArr then  
                local reward = resArr[1]
                res = string.split(reward, ",")
                if res[2] == FuncGuildExplore.guildExploreResType then
                    local keyData = FuncGuildExplore.getCfgDatas("ExploreResource",res[3])
                    iconPath = FuncRes.getIconResByName(keyData.icon)
                else
                    local icon = FuncDataResource.getIconPathById( res[2] )
                    iconPath = FuncRes.getIconResByName(icon)
                end
            -- else
                -- local resArr =  self:getFuncMineData("ExploreMine",eventModel.tid,"timeYield2" )
                -- local reward = resArr[1]
                -- res = string.split(reward, ",")
                -- local iconName = FuncDataResource.getIconPathById( res[1] )
                -- iconPath = FuncRes.getIconResByName(iconName)
            -- end
    		if not isFinish then
    			baseCell.mc_1:showFrame(1)
    			local panel = baseCell.mc_1:getViewByFrame(1)
    			panel.mc_1:showFrame(1)
    			local panel2 = panel.mc_1:getViewByFrame(1)
                local serveTime = TimeControler:getServerTime()
    			-- local time = math.floor((itemData.finishTime - itemData.cTime)/3600) --测试时间
                local time = self:calculateTime(itemData.finishTime)
    			panel2.txt_1:setString("此矿脉可开采"..time.."小时")
                local shengyuTime  = (itemData.finishTime - serveTime)/3600
                local sTime = allData.time[itemData.index]
                -- local sTime = itemData.finishTime - 
                local minTime = itemData.finishTime - serveTime
                local percent = (minTime)/(sTime)*100
                -- echoError("======percent=======",percent)
                panel.progress_1:setPercent(percent)

    			baseCell.mc_2:showFrame(1)
    			_panel = baseCell.mc_2:getViewByFrame(1)
                dump(eventModel,"事件类型==111111==")
                local index = 0
                for i=1,3 do
                    local state = eventModel.params["state"..i]
                    if state ~= 0 then
                        index = index + 1
                    end
                end

                if index == 0 then
                    index = 1
                end
				_panel.mc_1:showFrame(index)

                local reward = resArr[index]
                local resArr = string.split(reward, ",")

                local txt_2 = _panel.mc_1:getViewByFrame(index).txt_2
                local num = 0
                if resArr[2] == FuncGuildExplore.guildExploreResType then
                    num = resArr[4]
                else
                    num = resArr[3]
                end


                if tonumber(resArr[1]) == 1 then
                    txt_2:setString(num.."/".."分钟")
                else
                    txt_2:setString(num.."/"..resArr[1].."分钟")--GameConfig.getLanguage("#tid_Explore_des_104"))
                end

                baseCell.btn_1:setTouchedFunc(c_func(self.checkButton, self,eventModel),nil,true)

                if itemData.finishTime <= TimeControler:getServerTime() then
                    -- baseCell.btn_1:setVisible(false)
                    baseCell.btn_1:getUpPanel().txt_1:setString("领取")
                    baseCell.btn_1:setTouchedFunc(c_func(self.evacuationButton, self,eventModel),nil,true)
                    baseCell.mc_2:setVisible(false)
                    baseCell.mc_1:showFrame(3)
                    baseCell.mc_1:getViewByFrame(3).txt_2:setString("已崩塌")
                end
	    	else
	    		baseCell.mc_1:showFrame(1)
	    		_panel = baseCell.mc_1:getViewByFrame(1)
	    		_panel.mc_1:showFrame(2)
	    		baseCell.mc_2:showFrame(2)
	    		local panel2 = baseCell.mc_2:getViewByFrame(2)
	    		panel2.txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_127"))
	    		local count = 0 ---累计开采总数量  -- 测试用
	    		panel2.txt_2:setString(count)
	    	
                baseCell.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_128"))
                baseCell.btn_1:setTouchedFunc(c_func(self.getReward, self,mineID),nil,true)
	    	end 

            local sprite = display.newSprite(iconPath)
            sprite:size(35,35)
            _panel.ctn_1:removeAllChildren()
            _panel.ctn_1:addChild(sprite)


    	else
    		self:setPartnerData(baseCell,{{},{},{}})  --传空的三个位
    		baseCell.mc_1:showFrame(3)
            baseCell.btn_1:setTouchedFunc(c_func(self.checkButton, self,eventModel),nil,true)
            baseCell.mc_2:setVisible(false)
    	end
        local mineType =  self:getFuncMineData("ExploreMine",eventModel.tid,"mineType" )
    	local mineID = eventModel.tid ---测试，矿脉的ID
    	local data = self:getFuncMineData("ExploreDispatch", mineType )
        -- local anim = data.img2
        -- local sprite = self:createUIArmature("UI_xianmengtansuo",anim,nil,true)
        local pathIcon = FuncRes.getGuildExporeIcon(data.img2)
        local sprite = display.newSprite(pathIcon)
    	baseCell.ctn_1:removeAllChildren()
    	-- sprite:setScale(0.65)
        sprite:anchor(0.5, 0)
        -- sprite:setPosition(cc.p(20,-20))
    	baseCell.ctn_1:addChild(sprite)

        if  data.img then
            local path = FuncRes.getGuildExporeIcon(data.img)
            local sprite1 = display.newSprite(path)
            sprite1:setPosition(cc.p(50,-14))
            baseCell.ctn_2:removeAllChildren()
            baseCell.ctn_2:addChild(sprite1)
        end
    	

    elseif  _type == FuncGuildExplore.lineupType.building then  ---建筑的
    	-- local isDispatch,partherData = GuildExploreModel:getPantnerIsbattle(itemData.id) --是否派遣
        local isDispatch = false 
        local pantnerList = {}--itemData.pidList
        for k,v in pairs(itemData.pidList) do
            isDispatch = true
            table.insert(pantnerList,{id = v})
        end


    	local frames = 1
    	if isDispatch then
    		local partherData = pantnerList  --派遣的伙伴数据
    		local isFinish = true ---是否完成，可以了领取奖励

            -- dump(partherData,"333333333333333333") 
            local power = GuildExploreModel:getPartnersAbility(itemData.pidList)
    		self:setPartnerData(baseCell,partherData) 
    		if not isFinish then


	    	else

	    		baseCell.mc_1:showFrame(1)
	    		local panel = baseCell.mc_1:getViewByFrame(1)
	    		panel.mc_1:showFrame(2)
	    		baseCell.mc_2:showFrame(2)
                frames = 2
	    		local panel2 = baseCell.mc_2:getViewByFrame(2)
	    		panel2.txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_127"))


                local count = self:getCityCount(itemData)


	    		-- local count = 10001 ---累计开采总数量  -- 测试用
	    		panel2.txt_2:setString(count)
	    		
	    	end
            

            baseCell.mc_1:showFrame(2)
            local panel = baseCell.mc_1:getViewByFrame(2)

              
                panel.txt_2:setString(power)
	    	-- frames = 1
	    	-- baseCell.mc_2:showFrame(frames)
            baseCell.btn_1:setTouchedFunc(c_func(self.checkButton, self,eventModel),nil,true)
            -- baseCell.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_128"))
            -- baseCell.btn_1:setTouchedFunc(c_func(self.getReward, self,cityID),nil,true)
	    	
    	else
    		self:setPartnerData(baseCell,{{},{},{},{}})  --传空的四个位
    		frames = 2
    		baseCell.mc_2:showFrame(frames)
    		local panel_icon =  baseCell.mc_2:getViewByFrame(frames)
    		local cityID = itemData.tid   ---建筑ID
    		local baseData  =  self:getFuncMineData("ExploreCity",cityID,"base" )
			local res = string.split(baseData[1], ",")
		    -- local resID = res[4] ---资源类型  测试用
		    -- local num = res[5]

            if res[4] == FuncGuildExplore.guildExploreResType then
                num = res[6]
            else
                num = res[5]
            end

            if tonumber(res[3]) == 1 then
                panel_icon.txt_2:setString(num.."/分钟")
            else
                panel_icon.txt_2:setString(num.."/"..res[3].."分钟")
            end

    		

            baseCell.btn_1:setTouchedFunc(c_func(self.checkButton, self,eventModel),nil,true)
    	end

    	local panel_icon =  baseCell.mc_2:getViewByFrame(frames)

    	local cityID = eventModel.tid   ---建筑ID
        local index = itemData.index or 1
    	local baseData  =  self:getFuncMineData("ExploreCity",cityID)
		local res = string.split(baseData.base[1], ",")
	    local resID = res[4] ---资源类型  测试用
        -- if res[4] ==  FuncGuildExplore.guildExploreResType then
        --     resID = res[5]
        -- else
        --     resID = res[4]
        -- end

        local icon = nil
        if res[4] == FuncGuildExplore.guildExploreResType  then
            local iconName   =  self:getFuncMineData("ExploreResource",res[5],"icon" )
            icon = FuncRes.getIconResByName(iconName)
        else
            local iconName = FuncDataResource.getIconPathById(res[4])
            icon = FuncRes.getIconResByName(iconName)
        end


		-- local image   =  self:getFuncMineData("ExploreResource",resID,"icon" )
		-- local icon = FuncRes.getIconResByName(image)
		local sprite = display.newSprite(icon)
		sprite:size(35,35)
        sprite:setPositionX(5)
		panel_icon.ctn_1:removeAllChildren()
		panel_icon.ctn_1:addChild(sprite)


        local  typeId = baseData.type[index]

    	local data = self:getFuncMineData("ExploreDispatch", typeId )
        -- local anim = data.anim
        -- local sprite = self:createUIArmature("UI_xianmengtansuo",anim,nil,true)

        local pathIcon = FuncRes.getGuildExporeIcon(data.img2)
        local sprite = display.newSprite(pathIcon)
        baseCell.ctn_1:removeAllChildren()
        baseCell.ctn_1:removeAllChildren()
        -- sprite:setScale(0.5)
        -- sprite:setPosition(cc.p(0,-35))

        sprite:anchor(0.5, 0)
    	baseCell.ctn_1:addChild(sprite)

        if  data.img then
            local path = FuncRes.getGuildExporeIcon(data.img)
            local sprite1 = display.newSprite(path)
            sprite1:setPosition(cc.p(50,-14))
            baseCell.ctn_2:removeAllChildren()
            baseCell.ctn_2:addChild(sprite1)
        end

    
    end

end



--领取按钮
function GuildExploreCheckDispatchView:evacuationButton(eventModel)
    -- echo("=======领取按钮=======")
    -- dump(eventModel,"3333333333")
    local function callBack(event)
        if event.result then
            -- dump(event.result,"领取按钮奖励 =======")
            WindowControler:showTips("成功领取");
            local reward =  event.result.data.reward
            local partenerList = event.result.data.partenerList or {}
            GuildExploreModel:setPartnerIsHas(partenerList)

            reward,ischange = GuildExploreModel:rewardTypeConversion(reward)
            if ischange then
                FuncCommUI.startRewardView(reward)
            end

            if self.allData then
                for k,v in pairs(self.allData) do
                    if v.eventId == eventModel.id then
                        -- self.allData[k] = nil
                        table.remove(self.allData, k)
                    end
                end
            end
            -- local newData = {}
            -- for k,v in pairs(self.allData) do
            --     if v then
            --         table.insert(newData,v)
            --     end
            -- end
            -- dump(self.allData,"事件数据==111======")
            -- self.allData = {}
            -- self.allData = newData
            -- if self.allData then
            --     if table.length(self.allData) == 0 then
            --         GuildExploreModel:setMapSendData()
            --     end
            -- end

            self:initData()

            EventControler:dispatchEvent(GuildExploreEvent.RES_EXCHANGE_REFRESH)
        end

    end
    local pames = {
        eventId = eventModel.id, --撤离
    }
    GuildExploreServer:leaveToMine(pames,callBack)
end




--获得建筑累计开采数量
function GuildExploreCheckDispatchView:getCityCount(itemData)
    -- dump(self.pames,"1111111111111111000000000011111")
   
    local eventModel = GuildExploreModel:getEventData( itemData.eventId )
    local cityID = eventModel.tid
    local baseData  =  self:getFuncMineData("ExploreCity",cityID,"base" ) 
    local res = string.split(baseData[1], ",")
    local ability = tonumber(res[1])
    local addAdility = tonumber(res[2])
    local time = tonumber(res[3])
    local _type = tonumber(res[4])
    local itemId = tonumber(res[5])
    local count = tonumber(res[6])
    local addNum = tonumber(res[7])

    -- local newpartnerIdList = {}

    local partnerAbility = GuildExploreModel:getPartnersAbility(itemData.pidList)
    if partnerAbility > ability then
        local addFactor = math.floor((partnerAbility - ability)/addAdility) * addNum
        count = count + addFactor
    end


    local ctime = itemData.cTime
    local serveTime = TimeControler:getServerTime()
    -- echo("====serveTime===111111111=",serveTime,ctime,(serveTime-ctime)/(time*60))
    if ctime ~= 0 then
        local createTime = math.floor((serveTime-ctime)/(time*60))
        count =  createTime * count
    end
    return count or 0
end


function GuildExploreCheckDispatchView:calculateTime(_finishTime)
    local times = _finishTime - TimeControler:getServerTime()
    if times > 0 then
        times = TimeControler:turnTimeSec(times, TimeControler.timeType_hhmmss)
    else
        times = ""
    end
    return times
end

function GuildExploreCheckDispatchView:setPartnerData(view,data)
	view.mc_3:setVisible(false)
	local createFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(view.mc_3);
        self:setPartnerCell(baseCell, itemData)
        return baseCell;
    end
     local updateFunc = function (itemData,view)
    	self:setPartnerCell(view, itemData)
	end



    local  _scrollParams = {
        {
            data = data ,
            createFunc = createFunc,
            updateFunc= updateFunc,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -83, width = 100, height = 83},
            perFrame = 1,
        }
    }    
    view.scroll_1:refreshCellView( 1 )
    view.scroll_1:styleFill(_scrollParams);
    view.scroll_1:hideDragBar()

end
function GuildExploreCheckDispatchView:setPartnerCell(baseCell, itemData)
    -- dump(itemData,"000000000000000000000000000")
	if not itemData.id  then
		baseCell:showFrame(2)
		return
	end
	baseCell:showFrame(1)
    local skin = nil
    if tostring(itemData.id) ==  tostring(UserModel:avatar()) then
        skin = UserExtModel:garmentId()
    else
        local data = PartnerModel:getPartnerDataById(itemData.id)
        skin = data.skin
    end

	local panel = baseCell:getViewByFrame(1)
	panel.UI_1:updataUI(itemData.id,skin)


end



function GuildExploreCheckDispatchView:getFuncMineData(cfgsName, id,key )
	local cfgsName = cfgsName --"ExploreMine"
	local id = id
	local keyData
	if key then
		keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,id,key)
	else
		keyData = FuncGuildExplore.getCfgDatas( cfgsName,id )
	end
	return keyData
end

--查看按钮
function GuildExploreCheckDispatchView:checkButton(eventModel)
    -- dump(eventModel,"==============查看按钮=============")
    if eventModel.type == FuncGuildExplore.gridTypeMap.mine then
        GuildExploreEventModel:showMineUI(eventModel,true)
    elseif eventModel.type == FuncGuildExplore.gridTypeMap.build then
        GuildExploreEventModel:showBuildUI(eventModel)
    end
end


function GuildExploreCheckDispatchView:getReward()
    -- body
end

function GuildExploreCheckDispatchView:initView()
	-- TODO
end

function GuildExploreCheckDispatchView:initViewAlign()
	-- TODO
end

function GuildExploreCheckDispatchView:updateUI()
	-- TODO
end

function GuildExploreCheckDispatchView:deleteMe()
	-- TODO

	GuildExploreCheckDispatchView.super.deleteMe(self);
end

return GuildExploreCheckDispatchView;
