local GuildShouJiListView = class("GuildShouJiListView", UIBase);

function GuildShouJiListView:ctor(winName,_type,wishSign)
    GuildShouJiListView.super.ctor(self, winName);
   	self._type = _type
   	self._wishSign = wishSign   -- 心愿选择列表
end

function GuildShouJiListView:loadUIComplete()

	self.UI_di.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:registClickClose("out")

	self.UI_di.txt_1:setString(FuncGuild.Tranlast[9])

	self.selectItem = nil

	-- self:setStr()
	self:initData()
	self:setButton()
end 



function GuildShouJiListView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

function GuildShouJiListView:setStr()
	local str = ""
	if self._type == FuncGuild.Exchange_Type.Out_Item then
		str = FuncGuild.Tranlast[10]
	elseif  self._type == FuncGuild.Exchange_Type.Into_Item then
		str = FuncGuild.Tranlast[11]
	end
	self.txt_1:setString(str)
end



function GuildShouJiListView:initData()
	
	self.panel_1:setVisible(false)

	self.alldata = FuncGuild.getAllExchangeData()
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_1);
        self:updateCell(view,itemData)
        return view        
    end

    local updateCellFunc = function ( itemData ,view)
        self:updateCell(view,itemData)        
    end

	local params =  {
        {
            data = self.alldata, 
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 2,
            offsetY = -5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -145, width = 466, height = 145},
            perFrame = 1,
        }
        
    }
	self.scroll_1:styleFill(params)
	self.scroll_1:hideDragBar()
	self.selectindex = 1

end

function GuildShouJiListView:updateCell(view,itemData)

	for i=1,5 do
		view["panel_"..i]:setVisible(false)
		view["panel_"..i].panel_1:setVisible(false)
	end

	local costdata = itemData.cost

	local name = itemData.name
	view.txt_1:setString(GameConfig.getLanguage(name))

	for i=1,#costdata do
		local  reward = costdata[i]
		local panel = view["panel_"..i]
		local uiview = panel.UI_1
		panel:setVisible(true)
		uiview:setResItemData({reward = reward })
		local data = string.split(reward,",")
		local needNum = tonumber(data[3])
		local haveNum = ItemsModel:getItemNumById(data[2])
		uiview:setResItemNum(haveNum)
		-- echo("====haveNum============",haveNum,needNum)
		if haveNum >= needNum then
			uiview.panelInfo.txt_goodsshuliang:setColor(cc.c3b(0x00,0xff,0x00))
			FilterTools.clearFilter(uiview.panelInfo.mc_kuang)
			FilterTools.clearFilter(uiview.panelInfo.ctn_1)
		else
			FilterTools.setGrayFilter(uiview.panelInfo.mc_kuang)
			FilterTools.setGrayFilter(uiview.panelInfo.ctn_1)
			uiview.panelInfo.txt_goodsshuliang:setColor(cc.c3b(0xff,0x00,0x00))
		end
		panel:setTouchedFunc(c_func(self.selectCell, self,view,data,itemData.id),nil,true);
		if tonumber(data[2]) == tonumber(self.selectItem) then
			view["panel_"..i].panel_1:setVisible(true)
			self.selectItem = data[2]
		end
	end

end

function GuildShouJiListView:selectCell(view,data,boxID)

	local isok = self:conditional(data[2])
	if not isok then
		return 
	end

	self.selectItem = data[2]
	for k,v in pairs(self.alldata) do
		local _cell = self.scroll_1:getViewByData(v);
		for i=1,5 do
			_cell["panel_"..i].panel_1:setVisible(false)
			if tonumber(v.id) == tonumber(boxID) then
			-- if v
			-- _cell["panel_"..i].panel_1:
				local costdata =  v.cost
				for i=1,#costdata do
					local  reward = costdata[i]
					local rewardData = string.split(reward,",")
					local itemid = tonumber(rewardData[2])
					if tonumber(data[2]) == itemid then
						_cell["panel_"..i].panel_1:setVisible(true)
					else
						_cell["panel_"..i].panel_1:setVisible(false)
					end
				end
			end
		end
	end
end


function GuildShouJiListView:setButton()
	self.UI_di.mc_1:showFrame(1)
	self.UI_di.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.sureButton, self),nil,true);
end



function GuildShouJiListView:sureButton()
	-- self.selectItem 

	echo("=======选中的道具ID=======",self.selectItem)
	if self.selectItem == nil then
		WindowControler:showTips(FuncGuild.Tranlast[14])
		return 
	end
	if self._wishSign and self._wishSign == true then
		local item = {
			ItemID = self.selectItem,
			name = UserModel:name(),
			guildtype = GuildModel.guildName._type,
			position = GuildModel.MySelfGuildDataList.right,
			hasnum = 0,
			_time = TimeControler:getServerTime() + 22 * 3600,
			_id = UserModel:rid(),
		}

		local function _callback(param)
	        if (param.result ~= nil) then
	        	dump(param.result,"我的心愿数据返回",8)
	        	GuildModel:setMySelfWishList(item)
	        	EventControler:dispatchEvent(GuildEvent.REFRESH_WISH_LIST_EVENT)
	         	-- self:press_btn_close()
	        else
	            
	        end
	    end
		local params = {
			id = self.selectItem,
		};
		GuildServer:sendSendWish(params,_callback)
	else
		GuildModel:setExchangeListData(self._type,self.selectItem)
	end
	self:press_btn_close()

end

function GuildShouJiListView:conditional(itemID)
		echo("========self._type=============",self._type,itemID)
	if self._wishSign and self._wishSign == true then
		return true
	end
	local myselfID = UserModel:rid()
	local isok , data = GuildModel:getMyselfSendExchange(myselfID)
	if self._type == FuncGuild.Exchange_Type.Out_Item then  ---换出
		local haveNum = ItemsModel:getItemNumById(itemID) 
		echo("====选择当前已有数据============",haveNum)
		if haveNum and haveNum > 0 then
			if data.hasExchange ~= nil then
				if tonumber(itemID) == tonumber(data.hasExchange) then
					WindowControler:showTips(FuncGuild.Tranlast[13])
					return false
				end
			end
			return true
		else
			WindowControler:showTips(FuncGuild.Tranlast[12])
			return false
		end
	elseif  self._type == FuncGuild.Exchange_Type.Into_Item then   --换入
		if data ~= nil then
			if data.needExchang ~= nil then
				if tonumber(itemID) == tonumber(data.needExchang) then
					WindowControler:showTips(FuncGuild.Tranlast[11])
					return false
				else
					return true
				end
			else
				return true
			end
		end
	end
	return false
end


function GuildShouJiListView:press_btn_close()
	
	self:startHide()
end


return GuildShouJiListView;
