-- GuildTaskHistoryView
-- Author: Wk
-- Date: 2017-09-30
-- 仙盟任务历史界面
local GuildTaskHistoryView = class("GuildTaskHistoryView", UIBase);

function GuildTaskHistoryView:ctor(winName)
    GuildTaskHistoryView.super.ctor(self, winName);
end

function GuildTaskHistoryView:loadUIComplete()

	local _cell = self.rich_1
	_cell:setVisible(false)
	self:registerEvent()
	self:initData()
end 

function GuildTaskHistoryView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);

	self:registClickClose("-1")

	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_029"))
	self.UI_1.mc_1:setVisible(false)
end


function GuildTaskHistoryView:filtrateList(eventlist)
	local newcevent = {}
	local index = 1
	for i=1,table.length(eventlist) do
		if eventlist[i] ~= nil then
			if eventlist[i].type == FuncGuild.GuildEventType.FinishTask then
				newcevent[index] = eventlist[i]
				index = index + 1
			end
		end
	end
	return newcevent

end

function GuildTaskHistoryView:initData()
		

	-- local event = GuildModel.allchatEventData
	-- self.strData = self:filtrateList(event) ---获得的推送的消息数据
	local _type = FuncGuild.GuildEventType.FinishTask
	self.allData = GuildModel:getEventListByType(_type)
	-- self.allData = {1,23,3,4,5,6}

	if  table.length(self.allData) == 0 then
		self.txt_2:setVisible(true)
		return 
	end

	self.txt_2:setVisible(false)


	local _cell = self.rich_1
	_cell:setVisible(false)

	local createItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(_cell);
        	self:listcellviewData(baseCell, itemData)
        return baseCell;
    end

    local updateCellFunc = function (itemData,baseCell)
        self:listcellviewData(baseCell, itemData)
    end
    
    local  _scrollParams = {
        {
            data = self.allData,
            createFunc = createItemFunc,
            updateCellFunc= updateCellFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -60, width = 360, height = 60},
            perFrame = 0,
        }
    }    
   	-- _cell.scroll_1:cancleCacheView()
    self.scroll_1:styleFill(_scrollParams)
    self.scroll_1:hideDragBar()
    self.scroll_1:gotoTargetPos(tonumber(#self.allData),1,2);
end


function GuildTaskHistoryView:listcellviewData(baseCell, itemData)
	
	-- dump(itemData,"33333333333")
	local str = GuildModel:paramGuildEvent(itemData)
	baseCell:setString(str)

end




function GuildTaskHistoryView:press_btn_close()
	
	self:startHide()
end


return GuildTaskHistoryView;
