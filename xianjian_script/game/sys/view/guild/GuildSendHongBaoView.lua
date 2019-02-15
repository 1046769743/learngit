-- GuildSendHongBaoView
-- Author: Wk
-- Date: 2018-03-07
-- 公会发红包界面
local GuildSendHongBaoView = class("GuildSendHongBaoView", UIBase);

function GuildSendHongBaoView:ctor(winName)
    GuildSendHongBaoView.super.ctor(self, winName);
end

function GuildSendHongBaoView:loadUIComplete()
	
end 

function GuildSendHongBaoView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	self.btn_2:setTouchedFunc(c_func(self.sendAllPacked, self),nil,true);
	self.initRegisterEvent = true
end

--一键发送红包
function GuildSendHongBaoView:sendAllPacked()
-- dump(self.allData,"222222222")
	if self.allData then
		if table.length(self.allData) == 1 then
			if self.allData[1].nothave then
				WindowControler:showTips(GameConfig.getLanguage("#tid_group_guild_1508"));
				return
			end
		end
	end
	self:sendRedPacket(self.allData)

end



function GuildSendHongBaoView:initData()

	if not self.initRegisterEvent then
		self:registerEvent()
	end
	self.cellindex = 0
	self:setButton()
	self.mc_1:setVisible(false)
	self.allData = GuildRedPacketModel.sendPacketData

	-- dump(self.allData,"==========发送红包列表======")

	self.txt_2:setVisible(false)
	self.mc_1:setVisible(false)
	local issave = false 
	for k,v in pairs(self.allData) do
		if v.nothave then
			issave = true
		end
	end
	if not issave  then
		local pamedata = {  
			expireTime = 0,
			index      = 0,
			name       = UserModel:name(),
			packetId   = "904",
			rid        = UserModel:rid(),
			nothave    = true,
		}
		table.insert(self.allData,pamedata)
	end

	if table.length(self.allData) == 0 then
		-- self.txt_2:setVisible(true)
		-- self.btn_jian1:setVisible(false)
		-- self.btn_jian2:setVisible(false)
	else
		self.btn_jian1:setVisible(true)
		self.btn_jian2:setVisible(true)   
	end
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.mc_1);
        self:updateLeftCell(view,itemData)
        return view        
    end

    local function updateCellFunc(itemData,view)
    	self:updateLeftCell(view,itemData)
    end
    -- dump(self.allData,"3333333333333")
	local params =  {
        {
            data = self.allData,
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = -10,
            widthGap = 0,
            heightGap = 3,
            itemRect = {x = 0, y = -444, width = 245, height = 444},
            perFrame = 1,
        }
    }	
   	-- self.scroll_1:cancleCacheView()
   	self.scroll_1:refreshCellView(1)
    self.scroll_1:styleFill(params)
    self.scroll_1:hideDragBar()
    self.scroll_1:onScroll(c_func(self.nowScrollType,self))
    self.selectCell = 1

end

function GuildSendHongBaoView:updateLeftCell(view,itemData)
	-- self.cellCount = self.cellCount + 1
	-- local pame_index = 1
	

	if itemData.nothave then
		pame_index = 2
		view:showFrame(pame_index)
		view:getViewByFrame(pame_index).btn_lv1:setTouchedFunc(c_func(self.getRedPacketPath, self),nil,true);
	else
		pame_index = 1
		view:showFrame(pame_index)
		self:setpacketCell(view:getViewByFrame(1),itemData)
		self.cellindex = self.cellindex + 1
		if  self.cellindex == 1 then
			view:getViewByFrame(pame_index).panel_1.panel_hua:setVisible(false)
		end
	end
end


function GuildSendHongBaoView:setpacketCell(view,itemData)
	-- dump(itemData,"=======红包控件=======")
	local packetId = itemData.packetId
	view.panel_1.mc_t:showFrame(1)
	local mc_reward = view.panel_1.mc_t:getViewByFrame(1)
	local titlename =  FuncGuild.getRedPacketType(packetId,"description")
	mc_reward.txt_1:setString(GameConfig.getLanguage(titlename))

	-- mc_reward.ctn_1  --添加资源的ctn
	local baseData = FuncGuild.getpacketDataById(packetId)
	local iconpath = FuncRes.iconRes(baseData.rewardType,baseData.rewardType)
	local icon = display.newSprite(iconpath)
	icon:setScale(0.6)
	mc_reward.ctn_1:removeAllChildren()
	mc_reward.ctn_1:addChild(icon)


	local num =  FuncGuild.getRedPacketType(packetId,"reward")--奖励的数量
	mc_reward.txt_2:setString(num) 

	local count = FuncGuild.getRedPacketType(packetId,"num") --多少个红包
	mc_reward.txt_3:setString(GameConfig.getLanguage("#tid_guild_redpacket_009")..count)

	view.panel_1.btn_qiang:setTouchedFunc(c_func(self.sendRedPacket, self,{itemData}),nil,true);
end

function GuildSendHongBaoView:sendRedPacket(allData)
	if not GuildControler:touchToMainview() then
		return
	end
	-- dump(itemData,"=======发红包====== ")

	local function _callback(event)
		if event.result then
			-- dump(event.result,"=======发红包返回的数据======")
			if table.length(allData) == 1 then
				GuildRedPacketModel:setSendRedPacketIndex(true)
				GuildRedPacketModel:removeSendPacketDataById(allData[1].packetId)
				self:initData()
				self.btn_1:getUpPanel().panel_red:setVisible(true)
				local count = GuildRedPacketModel:dailyGetNum()
				local maxcount =  FuncGuild.getMaxRedPacketCount()
				if count >= maxcount then
					WindowControler:showTips(GameConfig.getLanguage("#tid_guild_redpacket_008"));
				else
					WindowControler:showTopWindow("GuildRedPacketCellView",allData[1],nil,false)
				end
			else
				WindowControler:showTips(GameConfig.getLanguage("#tid_guild_redpacket_008"));
				for k,v in pairs(allData) do
					GuildRedPacketModel:removeSendPacketDataById(v.packetId)
				end
				self:initData()
			end

		end
	end
	local ids = {}
	for k,v in pairs(allData) do
		table.insert(ids,v._id)
	end


	local params = {
		ids = ids
	}
	GuildServer:sendRedPacket(params,_callback)
end


---刷新红包里面的数据
function GuildSendHongBaoView:refreshDataList()
	self.allData = GuildRedPacketModel.sendPacketData
	for k,v in pairs(self.allData) do
		local _cell = self.scroll_1:getViewByData(v)
		self:updateLeftCell(_cell,v)
	end
end




----获取红包列表
function GuildSendHongBaoView:getRedPacketPath()
	echo("========跳转到获取红包列表========")

	if not GuildControler:touchToMainview() then
		return 
	end

	WindowControler:showWindow("GuildHongBaoGetPathView");

end



function GuildSendHongBaoView:setButton()
	self.btn_1:setTouchedFunc(c_func(self.redPacketButton, self),nil,true);
	self.btn_jian1:setTouchedFunc(c_func(self.rightButton, self),nil,true);
	self.btn_jian2:setTouchedFunc(c_func(self.leftButton, self),nil,true);
	self:setButtonRed()
end

--仙盟红包 按钮 显示红点
function GuildSendHongBaoView:setButtonRed()
	local isshow = GuildRedPacketModel:grabRedPacketRed()   --仙盟红包 按钮 显示红点
	self.btn_1:getUpPanel().panel_red:setVisible(isshow)
end

function GuildSendHongBaoView:rightButton()
	self.selectCell = self.selectCell + 1
	if self.selectCell <= 3 then
		if #self.allData <= 3 then
			self.selectCell = 1
			WindowControler:showTips(GameConfig.getLanguage("#tid_guild_redpacket_003"))
			return 
		end
		self.selectCell = 4
	elseif self.selectCell > #self.allData then
		self.selectCell = #self.allData
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_redpacket_004"))
		return 
	end
	self.isMoving = true
	self.scroll_1:gotoTargetPos(self.selectCell,1,2,0.2)

end
function GuildSendHongBaoView:leftButton()
	self.selectCell = self.selectCell - 1
	if self.selectCell <= 0 then
		self.selectCell = 1
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_redpacket_005"))
		return 
	end
	self.isMoving = true
	self.scroll_1:gotoTargetPos(self.selectCell,1,2,0.2)
end

function GuildSendHongBaoView:nowScrollType(event)
	if event.name == "scrollEnd" then
		local groupIndex,posIndex =  self.scroll_1:getGroupPos(2)
		if self.isMoving then
			self.isMoving = false
		else
			self.selectCell = posIndex
		end
	else
		local _viewArr = self.scroll_1._allCellViewArr
		local group,index = self.scroll_1:getGroupPos(0)
		if  index ~= 1 then
			_viewArr[1]:getViewByFrame(1).panel_1.panel_hua:setVisible(true)
		else
			_viewArr[1]:getViewByFrame(1).panel_1.panel_hua:setVisible(false)
		end

	end	
end



--仙盟红包按钮
function GuildSendHongBaoView:redPacketButton()
	if not GuildControler:touchToMainview() then
		return 
	end
	EventControler:dispatchEvent(GuildEvent.GUILD_REDPACKET_SHOW)

end



function GuildSendHongBaoView:press_btn_close()
	
	self:startHide()
end


return GuildSendHongBaoView;
