-- GuildExchangeView
-- Author: Wk
-- Date: 2018-03-03
-- 公会福利的交换界面
local GuildExchangeView = class("GuildExchangeView", UIBase);

function GuildExchangeView:ctor(winName)
    GuildExchangeView.super.ctor(self, winName);
end

function GuildExchangeView:loadUIComplete()
	self.panel_1:setVisible(false)
end 

function GuildExchangeView:registerEvent()
	EventControler:addEventListener(GuildEvent.GUILD_EXCHANGE_LIST_FRESH, self.refreshListData, self)
	EventControler:addEventListener(GuildEvent.GUILD_SHOUJI_LIST_REFRESH, self.refreshListData, self)
	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.refreshListData, self); 
	self.initRegisterEvent = true

end

function GuildExchangeView:initData()
	self:createViewData()
	if not self.initRegisterEvent then
		self:registerEvent()
	end
end


function GuildExchangeView:createViewData()
	local function cellfun(data)
		self:initListData()
	end
	GuildModel:getEcxhangeListData(cellfun)
end
function GuildExchangeView:initListData()
	-- echoError("111111111111111=========")
	self.alldata = GuildModel:getExchallengAllData()
	dump(self.alldata,"所有兑换的列表====")
	
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
            offsetX = 20,
            offsetY = 30,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -470, width = 300, height = 470},
            perFrame = 1,
        }
        
    }
	self.scroll_1:styleFill(params)
	self.scroll_1:hideDragBar()
end

function GuildExchangeView:updateCell(view,itemData,isRunaction)


	self:addSpineAndTitle(view,itemData)
	
	echo("=========运行=updateCell=======")
	if itemData.id == UserModel:rid() then
		echo("=========运行=myselfData=======")
		self:myselfData(view,itemData)
	else
		echo("=========运行=otherData=======")
		self:otherData(view,itemData)
		if not isRunaction then
			self:addbubblesRunaction(view)
		end
	end

end

--处理自己的当前的数据
function GuildExchangeView:myselfData(view,itemData)

	view.panel_qipao:setVisible(false)

	local myselfID = UserModel:rid()
	local isexchange,myData = GuildModel:getMyselfSendExchange(myselfID)    ---是否提出交换的请求
	local needIcon_1 = view.panel_1.mc_1
	local needIcon_2 = view.panel_2.mc_1
	local addIcon_1 = view.panel_1.panel_lv1
	local addIcon_2 = view.panel_2.panel_lv1
	local UI_1_1 = view.panel_1.UI_1
	local UI_1_2 = view.panel_2.UI_1
	needIcon_1:setVisible(false)
	needIcon_2:setVisible(false)

	addIcon_1:setVisible(false)
	addIcon_2:setVisible(false)
	UI_1_1:setVisible(false)
	UI_1_2:setVisible(false)

	local name = itemData.name
	view.txt_1:setString(name)

	local bgicon1 = view.panel_1.panel_bgicon
	local bgicon2 = view.panel_2.panel_bgicon

	bgicon1:setVisible(true)
	bgicon2:setVisible(true)

	if isexchange then
		-- addIcon_1:setVisible(false)
		-- addIcon_2:setVisible(false)
		if itemData.needExchang then
			local reward = "1,"..itemData.needExchang..",1"
			UI_1_1:setResItemData({reward = reward })
			UI_1_1:setVisible(true)
		else
			self:setUIisShow(UI_1_1)
			addIcon_1:setVisible(true)
		end
		if itemData.hasExchange  then
			needIcon_2:setVisible(true)
			needIcon_2:showFrame(1)
			local reward = "1,"..itemData.hasExchange..",1"
			UI_1_2:setResItemData({reward = reward })
			UI_1_2:setVisible(true)
		end
		bgicon1:setVisible(false)
		bgicon2:setVisible(false)
		view.panel_1:setTouchedFunc(function () end)
		view.panel_2:setTouchedFunc(function () end)
	else
		if itemData.hasExchange or itemData.needExchang then
			echo("==========itemData.hasExchange================",itemData.hasExchange, itemData.needExchang)
			if itemData.needExchang then
				local reward = "1,"..itemData.needExchang..",1"
				UI_1_1:setResItemData({reward = reward })
				UI_1_1:setVisible(true)
				bgicon1:setVisible(false)
			else
				self:setUIisShow(UI_1_1)
				addIcon_1:setVisible(true)
			end
			if itemData.hasExchange  then
				needIcon_2:setVisible(true)
				needIcon_2:showFrame(1)
				local reward = "1,"..itemData.hasExchange..",1"
				UI_1_2:setResItemData({reward = reward })
				UI_1_2:setVisible(true)
				bgicon2:setVisible(false)
			else
				self:setUIisShow(UI_1_2)
				addIcon_2:setVisible(true)
			end
		else
			addIcon_1:setVisible(true)
			addIcon_2:setVisible(true)
			self:setUIisShow(UI_1_1)
			self:setUIisShow(UI_1_2)
		end
		view.panel_1:setTouchedFunc(c_func(self.showShouJiList,self,1))
		view.panel_2:setTouchedFunc(c_func(self.showShouJiList,self,2))
	end


	if isexchange then
		view.mc_btn:showFrame(3)
		view.mc_btn:getViewByFrame(3).btn_1:setTouchedFunc(c_func(self.notSendExchangeButton,self,itemData))
	else
		view.mc_btn:showFrame(1)
		view.mc_btn:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.MyselfExchangeButton,self,itemData))
	end
end




function GuildExchangeView:setUIisShow(_ui)
	-- _ui:showResItemName(false)
    -- 显示数量
    local panelInfo = _ui.mc_1.currentView.btn_1:getUpPanel().panel_1
    local mcZi = panelInfo.mc_zi
    mcZi:setVisible(false)
    panelInfo.txt_goodsshuliang:setVisible(false)
    _ui.mc_1.currentView.btn_1:disabled(true)
	local redPanel = panelInfo.panel_red
	if redPanel then
   	 	redPanel:setVisible(false)
   	end
end


--显示收集品的列表
function GuildExchangeView:showShouJiList(_type)
	
	WindowControler:showWindow("GuildShouJiListView",_type);
	echo("=======显示收集品的列表======",_type)

end


--发起交换
function GuildExchangeView:MyselfExchangeButton( itemData )
	-- body
	dump(itemData,"发起交换")
	echo("=======发起交换======")

	if not itemData.needExchang or not itemData.hasExchange then
		WindowControler:showTips(FuncGuild.Tranlast[14])
		return 
	end  


	local function _callback(event)
		if event.result then
			dump(event.result,"===发起交换=返回的数据=")
			WindowControler:showTips(FuncGuild.Tranlast[15])
			GuildModel:setIsexchangeData(UserModel:rid(),true)
			self:refreshListData()
		end
	end
	local params = {
		need = itemData.hasExchange,
		have = itemData.needExchang,
	}

	GuildServer:sendExchangeRequest(params,_callback)
end

--撤销发送
function GuildExchangeView:notSendExchangeButton( itemData )
	-- body
	dump(itemData,"撤销发送")
	echo("=======撤销发送======")
	local function _callback(event)
		if event.result then
			dump(event.result,"===撤销发送=返回的数据=")
			WindowControler:showTips(FuncGuild.Tranlast[16])
			GuildModel:setIsexchangeData(UserModel:rid(),false)
			self:refreshListData()
		else
			if event.error then
				local code = event.error.code
				if code == FuncGuild.ErrorCode[1] then
					WindowControler:showTips(FuncGuild.Tranlast[18])
				else


				end
				GuildModel:setIsexchangeData(UserModel:rid(),false)
				self:refreshListData()
			end
		end
	end

	GuildServer:sendNotGuildExchange(_callback)
end



--处理其他人的数据
function GuildExchangeView:otherData(view,itemData)

	view.mc_btn:showFrame(2)
	view.mc_btn:getViewByFrame(2).btn_1:setTouchedFunc(c_func(self.sendExchangeButton,self,itemData))

	local needIcon_1 = view.panel_1.mc_1
	local needIcon_2 = view.panel_2.mc_1
	local addIcon_1 = view.panel_1.panel_lv1
	local addIcon_2 = view.panel_2.panel_lv1
	local UI_1_1 = view.panel_1.UI_1
	local UI_1_2 = view.panel_2.UI_1
	local bgicon1 = view.panel_1.panel_bgicon
	local bgicon2 = view.panel_2.panel_bgicon


	needIcon_1:setVisible(false)
	needIcon_2:setVisible(false)
	addIcon_1:setVisible(false)
	addIcon_2:setVisible(false)
	bgicon1:setVisible(false)
	bgicon2:setVisible(false)
	UI_1_1:setVisible(true)
	UI_1_2:setVisible(true)



	local name = itemData.name
	view.txt_1:setString(name)



	if itemData.needExchang then
		local reward = "1,"..itemData.needExchang..",1"
		UI_1_1:setResItemData({reward = reward })
	end

	if itemData.hasExchange then
		local reward = "1,"..itemData.hasExchange..",1"
		UI_1_2:setResItemData({reward = reward })
	end




	local otherNeedID = itemData.needExchang
	local otherhaveID = itemData.hasExchange



	local isneed = GuildModel:getItemIsMyNeedById(otherNeedID)
	if isneed then
		needIcon_1:showFrame(1)
		needIcon_1:setVisible(true)
		UI_1_1.panelInfo.txt_goodsshuliang:setColor(cc.c3b(0xff,0x00,0x00))
	else
		UI_1_1.panelInfo.txt_goodsshuliang:setColor(cc.c3b(0xff,0xff,0xff))
	end
	
	needIcon_2:showFrame(2)
	needIcon_2:setVisible(true)


	local count = ItemsModel:getItemNumById(otherhaveID)

	if count <= 0 then
		UI_1_2.panelInfo.txt_goodsshuliang:setColor(cc.c3b(0xff,0x00,0x00))
	else
		UI_1_2.panelInfo.txt_goodsshuliang:setColor(cc.c3b(0xff,0xff,0xff))
	end
	UI_1_2.panelInfo.txt_goodsshuliang:setString(count.."/1")






end


function GuildExchangeView:refreshUIData()
	self:initListData()
end

---交换的按钮
function GuildExchangeView:sendExchangeButton(itemData)


	WindowControler:showWindow("GuildSureExchangeView",itemData,c_func(self.refreshUIData, self))

	--[[
		echo("==========-交换的按钮======")
	dump(itemData,"8888888888888888")
	local playerID = itemData.id
	local hasExchange = itemData.hasExchange
	local num = ItemsModel:getItemNumById(hasExchange)
	if num <= 0 then
		WindowControler:showTips(FuncGuild.Tranlast[17])
		return 
	end
	local function _callback(event)
		if event.result then
			dump(event.result,"===交换的按钮=返回的数据=")
			WindowControler:showTips(FuncGuild.Tranlast[19])
			GuildModel:removeExchangData(playerID)
		else
			if event.error then
				local code = event.error.code
				if tonumber(code) == FuncGuild.ErrorCode[2] then
					WindowControler:showTips(FuncGuild.Tranlast[18])
				end
			end
		end
		self:initListData()
	end

	local params = {
		trid = playerID
	}
	GuildServer:sendGuildExchange(params,_callback)
	]]
end


function GuildExchangeView:addbubblesRunaction(view)
	-- local delaytime_1 = act.delaytime(0.2)
	view.panel_qipao:stopAllActions()

	local scaleto_1 = act.scaleto(0.1,1.2,1.2)
	local scaleto_2 = act.scaleto(0.05,1.0,1.0)
	local delaytime_2 = act.delaytime(5.0)
 	local scaleto_3 = act.scaleto(0.1,0)
 	local delaytime_3 = act.delaytime(1.5)
 	local callfun = act.callfunc(function ()
 		self:bubbles(view)
 	end)
	local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)

	view.panel_qipao:runAction(act._repeat(seqAct))

end

function GuildExchangeView:bubbles(view)

	local strtable =  {
		[1] = FuncGuild.Tranlast[6],
		[2] = FuncGuild.Tranlast[7],
		[3] = FuncGuild.Tranlast[8],
	}
	local idex = math.random(1,#strtable)
	local str = strtable[idex]
	local panel = view.panel_qipao
	panel.rich_1:setString("<color = 000000>"..str.."<->")

end


--主角的形象
function GuildExchangeView:addSpineAndTitle(view,data)
	local avatar = data.avatar
	local garmentId = data.garmentId
	local npc = GarmentModel:getSpineViewByAvatarAndGarmentId(tostring(avatar), garmentId);
	npc:playLabel(npc.actionArr.stand);
	view.ctn_ren:removeAllChildren()
	view.ctn_ren:addChild(npc)

	local guildType = GuildModel.guildName._type
	local postype = data.right or 4
	self:addGuildTitle(view,guildType,postype)

	local name = data.name
	view.txt_1:setString(name)

end

function GuildExchangeView:addGuildTitle(view,guildType,postype)
	-- local guilddata = GuildModel.MySelfGuildDataList
   	guildType = guildType or GuildModel.guildName._type
    postype = postype or 4
    local str,spritename   = FuncGuild.byIdAndPosgetName(guildType,postype)
	local right = FuncRes.iconGuild(spritename)
	local icon = display.newSprite(right)
    icon:setScale(0.6)
    view.ctn_name:removeAllChildren()
    view.ctn_name:addChild(icon)
end


function GuildExchangeView:press_btn_close()
	
	self:startHide()
end



function GuildExchangeView:refreshListData()
	-- local  alldata = GuildModel:getExchallengAllData()
	-- for k,v in pairs(alldata) do
	-- 	local view = self.scroll_1:getViewByData(v);
	-- 	self:updateCell(view,v,true)
	-- end
	self.scroll_1:refreshCellView(1)
    self:initListData()
end

return GuildExchangeView;
