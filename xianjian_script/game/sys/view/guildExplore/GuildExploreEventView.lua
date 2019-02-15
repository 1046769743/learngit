-- GuildExploreEventView
--[[
	Author: TODO
	Date:2018-07-04
	Description: TODO
]]

local GuildExploreEventView = class("GuildExploreEventView", UIBase);

local add_parameter = 15
function GuildExploreEventView:ctor(winName,allData)
    GuildExploreEventView.super.ctor(self, winName)
    self.allData = allData

end

function GuildExploreEventView:loadUIComplete()

	local eventList = self.allData.recordList
	local count = 1
	if eventList ~= nil then
		count = table.length(eventList)
	end 
	self.getrankTab = {
		rank = 1,
		rankEnd = count,
	}

	self:initViewAlign()
	self:registerEvent()
	self:initData()


end 

function GuildExploreEventView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.Right)
end

function GuildExploreEventView:registerEvent()
	GuildExploreEventView.super.registerEvent(self);
	self.panel_1:setVisible(false)
	self:registClickClose("out")
	self.btn_back:setTap(c_func(self.startHide,self))
	-- self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_115"))
	-- self.UI_1.mc_1:setVisible(false)
	EventControler:addEventListener("notify_explore_map_pushEvent", self.eventListNotify, self)

end

function GuildExploreEventView:eventListNotify(event)
	local newData = event.params.params
	
	table.insert(self.allData.recordList,1,newData)
	self:initData()
end

function GuildExploreEventView:getServerEventData()


	local function callBack(_param)
        if (_param.result ~= nil) then
        	-- _cell:setVisible(true)
            -- dump(_param.result,"====事件数据===22222==",7)
            local allData = _param.result.data
            self.allData.maxIndex =  allData.maxIndex
            for k,v in pairs(allData.recordList) do
            	table.insert(self.allData.recordList,v)
            end

			self:initData()
        end
    end

	local pames = {
		startIndex = self.getrankTab.rank,
		endIndex = self.getrankTab.rankEnd,
	}

	-- dump(pames,"发送的获取事件的第几个到底几个 ====")
	GuildExploreServer:getMapEventList(pames,callBack)

end




function GuildExploreEventView:initData()
	-- self.allData = {1,2,3,4,5,6,4,5}

	local createFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_1);
        self:setCell(baseCell, itemData)
        return baseCell;
    end
     local updateCellFunc = function (itemData,view)
    	self:setCell(view, itemData)
	end



    local  _scrollParams = {
        {
            data = self.allData.recordList,
            createFunc = createFunc,
            updateCellFunc= updateCellFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 30,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -80, width = 777, height = 80},
            perFrame = 1,
        }
    }    
    self.scroll_1:refreshCellView( 1 )
    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()
    self.scroll_1:onScroll(c_func(self.onMyListScroll, self))


end

function GuildExploreEventView:onMyListScroll( event )
	local maxnum = 100 --FuncWonderland.getMaxlistNum()
    local num = add_parameter
    if event.name == "scrollEnd" then
    	local eventList = self.allData.recordList
    	if #eventList < maxnum then
	    	local groupIndex,posIndex =  self.scroll_1:getGroupPos(2)
	    	-- echo("=======groupIndex=========",groupIndex,posIndex)
	        if groupIndex == 1 then 
	        	-- echo("========#self.dataList=======",#eventList,num)
	        	if math.fmod(#eventList, num) == 0  then  
	        		-- echo("=========1111111111========",posIndex,#eventList)
		            if tonumber(posIndex) == tonumber(#eventList) then
		            	-- dump(self.getrankTab,"333333333333333")
		                self.getrankTab = {
							rank = self.getrankTab.rank + add_parameter,
							rankEnd = self.getrankTab.rankEnd + add_parameter,
						}
						
						self:getServerEventData()
		            end
		        end
	        end
	    end
    elseif event.name == "moved" then

    end
end

function GuildExploreEventView:setCell(view,itemData)

	-- dump(itemData,"=======事件结构======")

	local time = itemData.ctime
	local dataTime = os.date("*t",time)
	local timeStr = dataTime.day.."-"..dataTime.month.."-"
	-- view.txt_1:setString(timeStr)
	local smStr = self:formatChatTime(time)
	view.txt_1:setString(smStr)

	view.btn_1:setVisible(false)

	local eventId = itemData.tid --事件ID

	local eventData = self:getFuncCityData( "ExploreRecord",eventId)


	if eventData.jump then
		-- GuildExploreEventModel:eventJumpToView()
		view.btn_1:getUpPanel().txt_1:setString("前往")
		view.btn_1:setVisible(true)
		view.btn_1:setTouchedFunc(c_func(self.jumpButton, self,itemData),nil,true)

		local eventID = itemData.tid
		local eventData = FuncGuildExplore.getCfgDatas( "ExploreRecord",eventID )
		if eventData.type == FuncGuildExplore.eventType.mine then
			view.btn_1:getUpPanel().txt_1:setString("我要开采")
		else
			view.btn_1:getUpPanel().txt_1:setString("前往")
		end
	end

	-- dump(eventData,"=======事件结构======")
	local funParams = itemData.funParams
	local isok = false
	local desStr = ""
	if funParams[2] then
		local data = GuildExploreModel:getEventData( funParams[2] ,true)
		local serverTime = TimeControler:getServerTime()
		local sum = 3
		if eventData.type == FuncGuildExplore.eventType.mine then 
			if data  then
				local params = data.params
				local finishTime = params.finishTime
				if serverTime > finishTime then
					isok = true  --已消失
					desStr = "<color = ff0000 >(已失效)<->"
				else
					local num = 0
					for i=1,sum do
						if  params["state"..i] then
							if params["state"..i] ~= 0 then
								num = num + 1
							end
						end
					end
					if num >= sum then
						desStr = "<color = ff0000 >("..num.."/"..sum..")<->"
					else
						desStr = "(<color = 00ff00 >"..num.."<->/"..sum..")"
					end
				end
			else
				isok = true  --已消失
				desStr = "<color = ff0000 >(已失效)<->"
			end
		elseif eventData.type == FuncGuildExplore.eventType.build then

		elseif eventData.type == FuncGuildExplore.eventType.getRes then

		elseif eventData.type == FuncGuildExplore.eventType.eliteMonster then
			if data then
				local params = data.params
				local levelHpPercent = params.levelHpPercent
				if levelHpPercent == 0 then
					isok = true
					desStr =  "<color = ff0000 >(已失效)<->"
				else
					isok = false
					desStr = "(剩余血量:<color = ff0000 >"..(levelHpPercent/100).."<->%)"
				end
			else
				isok = true
				desStr =  "<color = ff0000 >(已失效)<->"
			end
		end
	end


	local des = GuildExploreEventModel:getEventStr(itemData)
	view.rich_3:setString(des.." "..desStr)
	if isok then
		view.btn_1:setVisible(false)
	end



end


function GuildExploreEventView:jumpButton( itemData )
	-- dump(itemData,"========jumpButton=======")
	self:startHide()
	GuildExploreEventModel:eventJumpToView(itemData)
end

function GuildExploreEventView:getFuncCityData( cfgsName,id,key )
	-- echo("=======cfgsName=======",cfgsName)
	local cfgsName = cfgsName --"ExploreCity"
	local id = id
	local keyData 
	if key == nil then
		keyData = FuncGuildExplore.getCfgDatas( cfgsName,id )
	else
		keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,id,key)
	end
	
	return keyData
end


--//辅助函数,格式化时间
function  GuildExploreEventView:formatChatTime(_time)
   	local  _format = os.date("%X",_time)
   	local serverTime =  TimeControler:getServerTime()
   	local day = 24*60*60 
   	local syTime = serverTime - _time
   	
   	if syTime >= day then
   		local days = math.floor(syTime/day)
   		_format = days.."天前"
   	end
   	return _format
end





return GuildExploreEventView;
