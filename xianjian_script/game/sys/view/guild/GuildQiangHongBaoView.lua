-- GuildQiangHongBaoView
-- Author: Wk
-- Date: 2018-03-07
-- 公会抢红包界面
local GuildQiangHongBaoView = class("GuildQiangHongBaoView", UIBase);

function GuildQiangHongBaoView:ctor(winName)
    GuildQiangHongBaoView.super.ctor(self, winName);
end

function GuildQiangHongBaoView:loadUIComplete()
	self.txt_2:setVisible(false)
	self.panel_1:setVisible(false)
	self.btn_1:setVisible(false)
end 

function GuildQiangHongBaoView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);

	self.initRegisterEvent = true
end


function GuildQiangHongBaoView:initData()

	local function callBack(event)
		self:createData()
		if callFunc then
			callFunc()
		end
	end

	GuildRedPacketModel:getServeData(callBack)


end




function GuildQiangHongBaoView:createData()
	if not self.initRegisterEvent then
		self:registerEvent()
	end
	 self.cellindex = 0
	self:setDailyGetStr()
	self:setButton()
	self.allData = GuildRedPacketModel:packetSorthaveAndNot()
	echo("111111111111111")
	if self.allData and table.length(self.allData) == 0 then
		self.txt_2:setVisible(true)
		self.btn_jian1:setVisible(false)
		self.btn_jian2:setVisible(false)
	else	
		self.txt_2:setVisible(false)
		self.btn_jian1:setVisible(true)
		self.btn_jian2:setVisible(true)
	end

	local createCellFunc = function ( itemData)
        local view = UIBaseDef:cloneOneView(self.panel_1);
        self:updateLeftCell(view,itemData)
        return view        
    end

    local function updateCellFunc(itemData,view)
    	 self:updateLeftCell(view,itemData)
    end

	local params =  {
        {
            data = self.allData,
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 20,
            offsetY = 80,
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

function GuildQiangHongBaoView:updateLeftCell(view,itemData)

	-- dump(itemData,"=====抢红包的数据情况====")
	local _avatar = itemData.avatar
	local _headId = itemData.head
	local _headFrameId = itemData.frame
	if not view then
		return 
	end
	self.cellindex = self.cellindex + 1
	if  self.cellindex == 1 then
		view.panel_hua:setVisible(false)
	end
	
	local _ctn = view.panel_tou.ctn_touxiang
	-- UserHeadModel:setPlayerHeadAndFrame(_ctn,_avatar,_headId,_headFrameId)
	_ctn:anchor(0.5,0.5)
    _ctn:removeAllChildren()
    GuildRedPacketModel:setPlayerHead(_ctn,_avatar,_headId)
	GuildRedPacketModel:setPlayerFrame(_ctn,_headFrameId)

	local name = itemData.name 
	view.panel_tou.txt_name:setString(name)

	--显示资源
	local packetId = itemData.packetId
	local baseData = FuncGuild.getpacketDataById(packetId)
	local iconpath = FuncRes.iconRes(baseData.rewardType,baseData.rewardType)
	local icon = display.newSprite(iconpath)
	icon:setScale(0.4)
	view.ctn_1:removeAllChildren()
	view.ctn_1:addChild(icon)


	-- local get_type = FuncGuild.redPacket_State_Type.GET
	-- local num = FuncGuild.getRedPacketType(packetId,"num")
	-- local details = itemData.details
	-- local peoplenum = 0
	-- local myselfData = nil
	-- if details ~= nil then
	-- 	for k,v in pairs(details) do
	-- 		if type(v) == "table" then
	-- 			if v.rid ~= nil then
	-- 				peoplenum = peoplenum + 1
	-- 				if v.rid == UserModel:rid() then
	-- 					myselfData = v
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- if peoplenum >= tonumber(num) then
	-- 	get_type = FuncGuild.redPacket_State_Type.IN_GET_ALL

	-- else
	-- 	if myselfData ~= nil then
	-- 		get_type = FuncGuild.redPacket_State_Type.IN_GET
	-- 	end
	-- end


	local get_type = GuildRedPacketModel:getPacketStatus(itemData._id)   --领取状态s
	view.mc_2:showFrame(get_type)
	FilterTools.clearFilter(view.panel_bg)
	FilterTools.clearFilter(view.btn_qiang)
	view.mc_bg:showFrame(1)

	view.panel_tou:setVisible(true)
	view.txt_1:setVisible(true)
	view.ctn_1:setVisible(true)
	view.txt_2:setVisible(true)
	view.panel_qian:setVisible(true)
	view.mc_2:setVisible(true)


	if get_type == FuncGuild.redPacket_State_Type.GET then
		view:setTouchedFunc(c_func(self.grabRedpacket, self,itemData),nil,true);
		view.mc_2:getViewByFrame(get_type).rich_1:setString(GameConfig.getLanguage(baseData.description))
	elseif get_type == FuncGuild.redPacket_State_Type.IN_GET then
		FilterTools.setGrayFilter(view.panel_bg)
		FilterTools.setGrayFilter(view.btn_qiang)
		view:setTouchedFunc(c_func(self.redPacketInfo, self,itemData),nil,true);
		view.mc_bg:showFrame(2)
		view.panel_tou:setVisible(false)
		view.txt_1:setVisible(false)
		view.ctn_1:setVisible(false)
		view.txt_2:setVisible(false)
		view.panel_qian:setVisible(false)
		view.mc_2:setVisible(false)
		view.mc_bg:getViewByFrame(2).mc_1:showFrame(3)
	elseif get_type == FuncGuild.redPacket_State_Type.IN_GET_ALL then
		FilterTools.setGrayFilter(view.panel_bg)
		FilterTools.setGrayFilter(view.btn_qiang)
		view:setTouchedFunc(c_func(self.redPacketInfo, self,itemData),nil,true);
		view.mc_bg:showFrame(2)
		view.panel_tou:setVisible(false)
		view.txt_1:setVisible(false)
		view.ctn_1:setVisible(false)
		view.txt_2:setVisible(false)
		view.panel_qian:setVisible(false)
		view.mc_2:setVisible(false)
		view.mc_bg:getViewByFrame(2).mc_1:showFrame(2)
	end
end


function GuildQiangHongBaoView:redPacketInfo(itemData)
	-- echo("===========红包详情ID=========",itemData)
	-- dump(itemData,"22222222222222222222")
	GuildControler:showRedPacketInfoView(itemData)
end


--抢红包
function GuildQiangHongBaoView:grabRedpacket(itemData)
	echo("===========抢红包ID=========",itemData._id)
	-- local playdata  = GuildModel:getMemberInfo(itemData.rid)
	-- if playdata then
	if not GuildControler:touchToMainview() then
		return 
	end

	local function cellFunc()
		self:refreshDataList()
	end
	GuildRedPacketModel:grabRedpacket(itemData,cellFunc)
	-- else
	-- 	WindowControler:showTips("该玩家已被剔除仙盟,红包不存在")--GameConfig.getLanguage("#tid_guild_redpacket_002"));
	-- 	self:refreshDataList()
	-- end

end

---刷新红包里面的数据
function GuildQiangHongBaoView:refreshDataList()
	-- local newdata = GuildRedPacketModel:packetSorthaveAndNot()
	-- if table.length(newdata) == table.length(self.allData) then
		-- for k,v in pairs(self.allData) do
		-- 	local _cell = self.scroll_1:getViewByData(v)
		-- 	self:updateLeftCell(_cell,v)
		-- end
	-- else
		self:createData()
	-- end

	-- self:setDailyGetStr()

end


function GuildQiangHongBaoView:setButton()
	self.btn_1:setVisible(true)
	self.btn_1:setTouchedFunc(c_func(self.myRedPacketButton, self),nil,true);
	self.btn_jian1:setTouchedFunc(c_func(self.rightButton, self),nil,true);
	self.btn_jian2:setTouchedFunc(c_func(self.leftButton, self),nil,true);

end

function GuildQiangHongBaoView:rightButton()
	self.selectCell = self.selectCell + 1
	if self.selectCell <= 3 then
		if #self.allData <= 3 then
			self.selectCell = 1
			WindowControler:showTips(GameConfig.getLanguage("#tid_guild_redpacket_003")) --"后面已经没有了")
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
function GuildQiangHongBaoView:leftButton()
	self.selectCell = self.selectCell - 1
	if self.selectCell <= 0 then
		self.selectCell = 1
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_redpacket_005"))
		return 
	end
	self.isMoving = true
	self.scroll_1:gotoTargetPos(self.selectCell,1,2,0.2)
end

function GuildQiangHongBaoView:nowScrollType(event)

	if event.name == "scrollEnd" then
		local groupIndex,posIndex =  self.scroll_1:getGroupPos(2)
		if self.isMoving then
			self.isMoving = false
		else
			self.selectCell = posIndex
		end

		-- local group,index = self.scroll_1:getGroupPos(0)
		
		-- if index ~= 1 then
		-- 	for k,v in pairs(_viewArr) do
		-- 		v.panel_hua:setVisible(true)
		-- 	end
		-- else
		-- 	for k,v in pairs(_viewArr) do
		-- 		if tonumber(index) == tonumber(k) then
		-- 			v.panel_hua:setVisible(false)
		-- 		else
		-- 			v.panel_hua:setVisible(true)
		-- 		end
		-- 	end
		-- end
	else
		local _viewArr = self.scroll_1._allCellViewArr
		local group,index = self.scroll_1:getGroupPos(0)
		if  index ~= 1 then
			_viewArr[1].panel_hua:setVisible(true)
		else
			_viewArr[1].panel_hua:setVisible(false)
		end
	end	

end

--我的红包按钮
function GuildQiangHongBaoView:myRedPacketButton()
	if not GuildControler:touchToMainview() then
		return 
	end
	EventControler:dispatchEvent(GuildEvent.GUILD_REDPACKET_SHOW_MY)
end

--设置每日和按钮红点
function GuildQiangHongBaoView:setDailyGetStr()
	local count = GuildRedPacketModel:dailyGetNum()
	local maxcount =  FuncGuild.getMaxRedPacketCount()
	self.txt_1:setString(GameConfig.getLanguage("#tid_guild_redpacket_006")..":"..count.."/"..maxcount)

	local isshow = GuildRedPacketModel:sendRedPacketRed()
	self.btn_1:getUpPanel().panel_red:setVisible(isshow)

end

function GuildQiangHongBaoView:press_btn_close()
	
	self:startHide()
end


return GuildQiangHongBaoView;
