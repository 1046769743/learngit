-- WonderlandListView
--aouth wk
--time 2017/12/27

local WonderlandListView = class("WonderlandListView", ItemBase);


function WonderlandListView:ctor(winName,_type)
    WonderlandListView.super.ctor(self, winName);
    self.selectType = _type
end
local maxlistNum = 15
function WonderlandListView:loadUIComplete()
	self:registerEvent();

	
	self.dataList = {}
	self.getrankTab = {
		rank = 1,
		rankEnd = maxlistNum,
	}
	self.myselfData = false
	local _cell = self.panel_1.panel_2
	_cell:setVisible(false)
	self:getServeData({})

	self:delayCall(function ()
		self:registClickClose("out");
	end,0.4)
	

end 
function WonderlandListView:registerEvent()
	-- EventControler:addEventListener(NewLotteryEvent.REFRESH_REPLACE_VIEW, self.updateUI, self)
end

function WonderlandListView:getServeData(params)
	local _cell = self.panel_1.panel_2
	
	local _type = FuncWonderland.PaiHanbang_Type[tonumber(self.selectType)] 
	local function callBack(_param)
        if (_param.result ~= nil) then
        	_cell:setVisible(true)
            -- dump(_param.result," 须臾排行榜数据 ====",7)
            local data = _param.result.data
            local newdata = WonderlandModel:getPaiHangBangDataSorting(data.list)
            local myselfdata = {
            	rank = data.rank or 0,
            	score = data.score or 0,
            	name = UserModel:name(),
            	rid = UserModel:rid(),
        	}
            self:myselfDataInit(_cell,myselfdata)
            self:listDataInit(newdata)
            self:updateUI()
        end
    end

	local params = {
		type = _type,
		rank = params.rank or self.getrankTab.rank,
		rankEnd =  params.rankEnd or self.getrankTab.rankEnd,
	}
	WonderlandModel:getPaiHangBang(params,callBack)
end

--排行榜数据处理
function WonderlandListView:listDataInit(data)
	-- self.dataList
	if #self.dataList == 0 then
		self.dataList = data
	else
		for k,v in pairs(data) do
			self.dataList[v.rank] = v
		end
	end
end

function WonderlandListView:myselfDataInit(_cell,data)
	-- local _cell = self.panel_1.panel_2
	_cell:setVisible(true)
	local maxFloor =  data.score --WonderlandModel:getMaxfloor()
	local maxframe = data.rank 
	if maxframe == false or maxframe == 0 then
		-- _cell:setVisible(false)
		maxframe = 999
		-- return 
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
	_cell.txt_lv:setString(maxFloor..GameConfig.getLanguage("#tid_wonderland_ui_002"))

	if data.rid == UserModel:rid() then
		_cell.panel_ziji:setVisible(true)
	else
		_cell.panel_ziji:setVisible(false)
	end
	self.myselfData = true
end



function WonderlandListView:updateUI()
	local dataList = table.copy(self.dataList)
	local _cell = self.panel_1
	local createRankItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(_cell.panel_2);
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
            offsetX = 5,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -60, width = 460, height = 60},
            perFrame = 0,
        }
    }    
   	_cell.scroll_1:cancleCacheView()
    _cell.scroll_1:styleFill(_scrollParams)
    _cell.scroll_1:hideDragBar()
    _cell.scroll_1:onScroll(c_func(self.onMyListScroll, self))

end

function WonderlandListView:onMyListScroll(event)
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

function WonderlandListView:listcellviewData(baseCell, itemData)
	if itemData._type then
		baseCell.mc_1:setVisible(false)
		baseCell.panel_ziji:setVisible(false)
		baseCell.txt_lv:setVisible(false)
		baseCell.txt_name:setString(GameConfig.getLanguage("#tid_wonderland_ui_003"))
	else
		self:myselfDataInit(baseCell,itemData)
	end
end



function WonderlandListView:clickButtonBack()
    self:startHide();

end


return WonderlandListView;
