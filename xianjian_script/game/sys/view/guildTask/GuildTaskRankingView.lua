-- GuildTaskRankingView
-- Author: Wk
-- Date: 2017-09-30
-- 仙盟任务排行界面
local GuildTaskRankingView = class("GuildTaskRankingView", UIBase);
local maxlistNum = 15
function GuildTaskRankingView:ctor(winName,_type)
    GuildTaskRankingView.super.ctor(self, winName);
    self.selectType = _type
end


function GuildTaskRankingView:loadUIComplete()
	self:registerEvent();
	local _cell = self.panel_2
	_cell:setVisible(false)
	self.txt_2:setVisible(false)
	self:registClickClose("-1")
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);

	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guildtask_115"))

	self:initData()

end 
function GuildTaskRankingView:registerEvent()
	
end

function GuildTaskRankingView:initData()
	-- self.dataList = {}
	self.getrankTab = {
		rank = 1,
		rankEnd = maxlistNum,
	}

	self.myselfData = false


	self.dataList = {}
	self:getServeData({})
end

function GuildTaskRankingView:getServeData(params)
	local _cell = self.panel_2
	
	-- local _type = FuncWonderland.PaiHanbang_Type[self.selectType] 
	local function callBack(_param)
        if _param.result ~= nil then
        	dump(_param.result,"声望获取排行=====",8)
        	local newdata = _param.result.data.list
        	self:listDataInit(newdata)
        	self:updateUI()

        	local guildID =	UserModel:guildId()
		    local myData  = newdata[guildID] 
		    if myData then
		    	_cell:setVisible(true)
		    	local data = {
		    		score = myData.score or 0,
					rank = myData.rank or 0,
					name = GuildModel._baseGuildInfo.name or "",
					id = guildID,
					logo = GuildModel.guildIcon.borderId or 1,
					color = GuildModel.guildIcon.bgId or 1,
					icon = GuildModel.guildIcon.iconId or 1,
		    	}





		    	self:myselfDataInit(_cell,data)
		    else
		    	_cell:setVisible(false)
		    end


        end
    end

	local rankType = 41  --仙盟声望排行
	local beginRank = params.rank or self.getrankTab.rank
	local endRank = params.rankEnd or self.getrankTab.rankEnd
	RankServer:getRankList(rankType,beginRank,endRank,callBack)

end

--排行榜数据处理
function GuildTaskRankingView:listDataInit(data)
	-- self.dataList
	-- if #self.dataList == 0 then
	-- 	self.dataList = data
	-- else
		for k,v in pairs(data) do
			v.id = k
			table.insert(self.dataList,v)
		end
	-- end
end



function GuildTaskRankingView:myselfDataInit(_cell,data)

	-- _cell:setVisible(true)

	local renown =   data.score  or 0 ---声望
	local maxframe = data.rank  --排行
	if maxframe == false or maxframe == 0 then
		maxframe = 999
	end
	if maxframe <= 3 then
		_cell.mc_1:showFrame(maxframe)
	else
		if maxframe == 999 then
			maxframe = GameConfig.getLanguage("#tid_wonderland_ui_001")
		end
		_cell.mc_1:showFrame(4)
		_cell.mc_1:getViewByFrame(4).txt_1:setString(maxframe)
	end
	_cell.txt_name:setString(data.name)
	_cell.txt_jifen:setString(renown)

	if data.id == UserModel:guildId() then
		_cell.panel_ziji:setVisible(true)
	else
		_cell.panel_ziji:setVisible(false)

	end
	self.myselfData = true

	-- :initData(icondata)

	local icondata = {
		borderId = data.logo,
		bgId = data.color,
		iconId = data.icon,
	}

	_cell.UI_1:initData(icondata)
end

function GuildTaskRankingView:rankStor()

	local function sortFunc(a, b)
		return a.rank < b.rank
	end

	table.sort(self.dataList, sortFunc)

	return self.dataList
end



function GuildTaskRankingView:updateUI()
	-- local dataList = self.dataList --table.copy(self.dataList)
	local  dataList = self:rankStor()
	-- dump(dataList,"33333333333333")
	if  table.length(dataList) == 0 then
		self.txt_2:setVisible(true)
		self.panel_2:setVisible(false)
		return 
	end

	self.txt_2:setVisible(false)


	local _cell = self.panel_2
	local createRankItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(_cell);
        	self:listcellviewData(baseCell, itemData)
        return baseCell;
    end

    local updateCellFunc = function (itemData,baseCell)
        self:listcellviewData(baseCell, itemData)
    end
    if math.fmod(#dataList, maxlistNum) == 0  then
    	local tstrTab = {_type = 1}
    	table.insert(dataList,tstrTab)
    end

    
    local  _scrollParams = {
        {
            data = dataList,
            createFunc = createRankItemFunc,
            -- updateCellFunc= updateCellFunc,
            perNums = 1,
            offsetX = -5,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -60, width = 360, height = 60},
            perFrame = 1,
        }
    }    
   	-- _cell.scroll_1:cancleCacheView()
    self.scroll_1:styleFill(_scrollParams)
    self.scroll_1:hideDragBar()
    self.scroll_1:refreshCellView(0)
    -- self.scroll_1:onScroll(c_func(self.onMyListScroll, self))


   --  local guildID =	UserModel:guildId()
   --  local myData  = self.dataList[guildID] 
   --  if myData then
   --  	_cell:setVisible(true)
   --  	local data = {
   --  		score = myData.score or 0,
			-- rank = myData.rank or 0,
			-- name = GuildModel._baseGuildInfo.name or "",
			-- id = UserModel:rid(),
   --  	}

   --  	self:myselfDataInit(_cell,data)
   --  else
   --  	_cell:setVisible(false)
   --  end
end

function GuildTaskRankingView:onMyListScroll(event)
    -- dump(event,"滚动监听事件")
    local maxnum = FuncWonderland.getMaxlistNum()
    local num = maxlistNum
    if event.name == "scrollEnd" then
    	if #self.dataList < maxnum then
	    	local groupIndex,posIndex =  self.panel_1.scroll_1:getGroupPos(2)
	    	-- echo("=======groupIndex=========",groupIndex)
	        if groupIndex == 1 then 
	        	-- echo("========#self.dataList=======",#self.dataList,num)
	        	if math.fmod(#self.dataList, num) == 0  then  
	        		local rank = self.getrankTab.rank + num
	        		local rankEnd = self.getrankTab.rankEnd + num
	        		if rankEnd >= maxnum then
	        			rankEnd = maxnum 
	        		end
	        		if rank >= maxnum then
	        			rank = self.getrankTab.rank
	        		end
		            if posIndex-1 == #self.dataList then
		                self.getrankTab = {
							rank = rank,
							rankEnd = rankEnd,
						}
						self:getServeData( self.getrankTab)
		            end
		        end
	        end
	    end
    elseif event.name == "moved" then

    end
end

function GuildTaskRankingView:listcellviewData(baseCell, itemData)
	-- self:myselfDataInit(baseCell,itemData)
	-- dump(itemData,"33333333333333333333")
	if itemData._type then
		baseCell.mc_1:setVisible(false)
		baseCell.panel_ziji:setVisible(false)
		baseCell.txt_jifen:setVisible(false)
		baseCell.txt_name:setString(GameConfig.getLanguage("#tid_wonderland_ui_003"))
	else
		self:myselfDataInit(baseCell,itemData)
	end
end


function GuildTaskRankingView:press_btn_close()
	self:startHide()
end


return GuildTaskRankingView;



