-- GuildAddView
-- Author: Wk
-- Date: 2017-09-29
-- 公会加入界面
local GuildAddView = class("GuildAddView", UIBase);
---1 公会列表第一界  2 查找界面  3 受邀界面

function GuildAddView:ctor(winName)
    GuildAddView.super.ctor(self, winName);
    self.selectAll = GuildModel.selectShowAll
    self.page = 1
    self.selectpage = 1  --默认选择是公会列表第一页

end

function GuildAddView:loadUIComplete() 
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guildAdd_001"))
	self.UI_1.btn_1:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:registerEvent()
	self:initData()
	self:setbottomAPI()
	self:registClickClose("out")
	self.addnum = false
end 

function GuildAddView:registerEvent()
	EventControler:addEventListener(GuildEvent.CLOSE_ADD_GUILD_VIEW_EVENT, self.press_btn_close, self)
	EventControler:addEventListener(GuildEvent.GUILD_invite_EVENT, self.setButtonred, self)
	EventControler:addEventListener(GuildEvent.GUILD_REFRESH_invite_EVENT, self.refreshUi, self)
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
end

function GuildAddView:refreshUi()
	self:setbottomAPI()
	self:beInvitedButton(true)
end

function GuildAddView:setButtonred()
	local panel_botton = self.panel_2
	panel_botton.btn_2:getUpPanel().panel_red:setVisible(true)
end

function GuildAddView:refreshUI()
	-- if self.selectpage == 1 then

	-- elseif self.selectpage == 2 then

	-- else
	-- 	self:beInvitedButton()
	-- end
end
function GuildAddView:initData()
	-- --创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
	self.UI_2:setVisible(false)
	self.cellData = GuildModel:getAddGuildData()
	self:setInitView()
end

function GuildAddView:setInitView()
	self.mc_1:setVisible(false)
	self.panel_2:setVisible(true)
	if #self.cellData == 0 then
		self:notAddGuildData()
	else
		-- local  isfull = GuildModel:judgmentAddGuildData()
		-- if isfull then
		-- 	self:isFullGuildData()
		-- else
			self:initScrollList(self.cellData)
		-- end
	end
end

--初始化滚动列表
function GuildAddView:initScrollList(data)
	local alldata = data --self.cellData
	-- alldata = self:dataListSort(alldata)
	local newalldata = {} 
	local index = 1
	for i=1,#data do
		if data[i]._id ~= "0" then
			newalldata[index] = data[i]
			index = index + 1
		end
	end


	-- dump(alldata,"所有推荐公会",8)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.UI_2);
        self:updateItem(view,itemData)
        return view        
    end

 	local params =  {
        {
            data = newalldata,  ---alldata
            createFunc = createCellFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 20,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -125, width = 900, height = 125},
            perFrame = 0,
        }
        
    }
    self.scroll_1:cancleCacheView();
    self.scroll_1:styleFill(params)
    self.scroll_1:onScroll(c_func(self.onMyListScroll, self))
    if #alldata > FuncGuild.pageNum then
    	self.scroll_1:gotoTargetPos(#alldata - FuncGuild.pageNum,1,2);
    end
end

function GuildAddView:dataListSort(datalist)
	datalist = self:allsortList(datalist)
	return datalist
end

--全部仙盟排序
function GuildAddView:allsortList(datalist)
	table.sort(datalist,function(a,b)
        local rst = false
        if a.level > b.level then
            rst = true
        elseif a.level == b.level then
            if a._id > b._id then
                rst = true
            else
                rst = false
            end
        else
            rst = false
        end 
        return rst
	end)
	return datalist
end

function GuildAddView:onMyListScroll(event)
    -- dump(event,"滚动监听事件")
    if event.name == "scrollEnd" then
        -- echo("111111111111111111111111111111111111111111111'")
        local groupIndex,posIndex =  self.scroll_1:getGroupPos(2)
        -- echo("=======groupIndex========posIndex=========",groupIndex,posIndex)
        if groupIndex == 1 then 
        	if math.fmod(#self.cellData, FuncGuild.pageNum) == 0  then  
	            if posIndex == #self.cellData then
	                self.page = self.page + 1
	                self:getpageDataList()
	            end
	        end
        end
    end
end
function GuildAddView:getpageDataList()
	local function _callback(_param)
		-- dump(_param.result,"公会列表数据",8)
		if _param.result then
			local datalist = _param.result.data.guild
			-- GuildModel:setguildAllList(datalist)
			for k,v in pairs(datalist) do
				table.insert(GuildModel.guildAllList,v)
			end
			local addnum = table.length(datalist)
			if addnum < 10 then
				self.addnum = true
			end
			self.cellData = GuildModel.guildAllList
			self:initScrollList(self.cellData)
		end
	end

	local params = {
		page = self.page,
		all = 1,
	};
	if not self.addnum then
		GuildServer:listGuild(params,_callback)
	end
end




--数据显示
function GuildAddView:updateItem(view,itemData)
	-- dump(itemData,"仙盟数据",8)
	-- self.selectpage
	view:initData(itemData,self.selectpage)
end

---已满
function GuildAddView:isFullGuildData()
	self.panel_2:setVisible(true)
	local mcbutton = self.mc_1
	mcbutton:setVisible(true)
	local frame = 2
	mcbutton:showFrame(frame)
	mcbutton:getViewByFrame(frame).btn_1:setTouchedFunc(c_func(self.createGuildButton, self),nil,true);
end

--没有可以加入的仙盟数据
function GuildAddView:notAddGuildData()
	local mcbutton = self.mc_1
	local frame = 3
	self.panel_2:setVisible(false)
	mcbutton:setVisible(true)
	mcbutton:showFrame(frame)
	mcbutton:getViewByFrame(frame).btn_1:setTouchedFunc(c_func(self.createGuildButton, self),nil,true);
end

--查看其它仙盟数据
function GuildAddView:findOtherGuildData()
	local mcbutton = self.mc_1
	mcbutton:setVisible(true)
	local frame = 1
	mcbutton:showFrame(frame)
	mcbutton:getViewByFrame(frame).btn_1:setTouchedFunc(c_func(self.checkGuildButton, self),nil,true);
end

--查看
function GuildAddView:checkGuildButton()
	-- self.cellData = self.cellData ----重新获得数据
	-- if not GuildControler:touchToMainview() then
	-- 	return 
	-- end
	local mcbutton = self.mc_1
	mcbutton:setVisible(false)
	self.selectpage = 1
	self:initScrollList(self.cellData)
	self.panel_2.btn_3:setVisible(true)
end

---去创建
function GuildAddView:createGuildButton()
	-- if not GuildControler:touchToMainview() then
	-- 	return 
	-- end

	self:press_btn_close()
	WindowControler:showWindow("GuildCreateView");
end


--设置底部控件
function GuildAddView:setbottomAPI()
	local panel_botton = self.panel_2
	panel_botton:setVisible(true)
	local num =  GuildModel.invitedToList
	local ishow = false
	if #num ~= 0 then
		ishow  = true
	end
	panel_botton.btn_2:getUpPanel().panel_red:setVisible(ishow)
	panel_botton.btn_1:setTouchedFunc(c_func(self.findButton, self),nil,true);
	panel_botton.btn_2:setTouchedFunc(c_func(self.beInvitedButton, self),nil,true);
	-- panel_botton.panel_select:setTouchedFunc(c_func(self.selectShowAllGuild, self),nil,true);
	local isshow = false
	if self.selectAll == 1 then
		isshow = true
	end
	-- panel_botton.panel_select.panel_dui:setVisible(isshow)
	panel_botton.btn_3:setTouchedFunc(c_func(self.oneButtonAdd, self),nil,true);

end

function GuildAddView:oneButtonAdd()
	echo("=======一键加入=======")
	local function cellBack(event)
		if event.result then
			EventControler:dispatchEvent(GuildEvent.CLOSE_ADD_GUILD_VIEW_EVENT)
			local _str = GameConfig.getLanguage("#tid_group_guild_1504")
			WindowControler:showTips(_str)
			GuildControler:getMemberList(1)
			GuildBossModel:updateTimeFrame()
		end
	end


	local params = {}
	GuildServer:oneAddGuild(params,cellBack)
end

--输入api
function GuildAddView:bottomInput()
	local panel_botton = self.panel_2
end

--查找按钮
function GuildAddView:findButton()
	-- if not GuildControler:touchToMainview() then
	-- 	return 
	-- end
	self.selectpage = 2
	local panel_botton = self.panel_2
	local text = panel_botton.input_1:getText()
	if text == "" or text == nil then 
		WindowControler:showTips(GameConfig.getLanguage("#tid_guildAdd_002"))
		return 
	end

	local function _callback(_param)
		dump(_param.result,"搜索",8)
		if _param.result then
			local cellData = _param.result.data.guild
			self:findOtherGuildData()
			self:initScrollList({cellData})
			panel_botton.input_1:setText("");
			self.panel_2.btn_3:setVisible(false)
		else
			--错误和没查找到的情况  
			WindowControler:showTips(GameConfig.getLanguage("#tid_guildAdd_003"))
		end

	end 

	local params = {
		id = text
	};
	GuildServer:findGuild(params,_callback)

end

--受邀Button
function GuildAddView:beInvitedButton(file)
	-- if not GuildControler:touchToMainview() then
	-- 	return 
	-- end
	--TODO
	-- echo("=======file========",type(file))
	self.selectpage= 3
	--判断是否有被玩家邀请的数据
	local cellData = GuildModel.invitedToList
	if #cellData == 0 then
		self.selectpage = 1
		self.cellData = GuildModel:filtrateList(1) 
		self:initScrollList(self.cellData)
		if type(file) == "table" then 
			WindowControler:showTips(GameConfig.getLanguage("#tid_guildAdd_004"))
		end
		return 
	end

	self:initScrollList(cellData)

end

--选择是否全部显示  self.selectAll
function GuildAddView:selectShowAllGuild()
	-- if not GuildControler:touchToMainview() then
	-- 	return 
	-- end
	local panel_botton = self.panel_2
	
	if self.selectAll == 1 then
		self.selectAll = 0
		-- panel_botton.panel_select.panel_dui:setVisible(false)
	else
		self.selectAll = 1
		-- panel_botton.panel_select.panel_dui:setVisible(true)
	end
	echo("========选择========",self.selectAll)
	---TODO
	--处理刷新控件数据
	self.cellData = GuildModel:filtrateList(self.selectAll) 
	self:initScrollList(self.cellData)

end


--创建
function GuildAddView:creaGuild()
	echo("======创建=========")
	WindowControler:showWindow("GuildCreateView");
	self:press_btn_close()
end

function GuildAddView:press_btn_close()
	
	self:startHide()
end


return GuildAddView;
