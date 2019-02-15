--
--Author:      zhuguangyuan
--DateTime:    2018-05-22 16:08:26
--Description: 名册系统 - 换阵界面
-- 

local HandbookExchangeDirView = class("HandbookExchangeDirView", UIBase);

function HandbookExchangeDirView:ctor(winName,dirId,partnerId,index)
    HandbookExchangeDirView.super.ctor(self, winName)
    self.dirId = dirId
    self.curPosPartnerId = partnerId  -- 进此界面时选中的阵位中站立的奇侠,没有则为""
    self.curIndex = index  --  

    echo("________ dirId,partnerId ____________",dirId,partnerId)
end

function HandbookExchangeDirView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function HandbookExchangeDirView:registerEvent()
	HandbookExchangeDirView.super.registerEvent(self);
	self.panel_1.btn_close:setTap(c_func(self.onClose,self))
	self:registClickClose("out")
end

function HandbookExchangeDirView:initData()
	local allPartners = HandbookModel:getAllOwnPartnersInOneDir( self.dirId )
	self.panel_h:visible(true)
	if #allPartners ~= 0 then
		self.panel_h:visible(false)
	end
	self.curDirAllPartners = self:formatePartnerStatus( allPartners )
end

-- 计算所有该系奇侠的状态
function HandbookExchangeDirView:formatePartnerStatus( allPartners )
	-- 剔除当前系内已上阵但是不是当前阵位的奇侠
	local tempArr = {}
	local userData = UserModel._data
	table.sort( allPartners, function (a,b) --- 按照评分高低排个序  高的在前 
		return (FuncHandbook.getScoreOnePartner(userData.partners[a], userData,self.dirId) > FuncHandbook.getScoreOnePartner(userData.partners[b], userData,self.dirId))
	end )

	for k,partnerId in pairs(allPartners) do
		local inFieldStatus = nil
		local curWorkDir = HandbookModel:getOnePartnerWorkingDir( partnerId )
		echo("__________ curWorkDir,self.dirId,self.curPosPartnerId,partnerId  ",curWorkDir,self.dirId,self.curPosPartnerId,partnerId)
		if curWorkDir == "" then
			inFieldStatus = FuncHandbook.inPlaceStatus.can_enterField -- 空闲,可上阵
		else
			if tostring(curWorkDir) == tostring(self.dirId) then
				-- 只显示当前阵位进来的已在位奇侠 的下阵操作
				-- 其他阵位的奇侠应该在对应阵位显示 
				-- 不能在1号阵位下阵3号阵位的奇侠
				if tostring(partnerId) == tostring(self.curPosPartnerId) then 
					inFieldStatus = FuncHandbook.inPlaceStatus.can_leaveField -- 在当前阵位,可下阵
				else
					inFieldStatus = FuncHandbook.inPlaceStatus.can_changeField  -- 在其他名册,可交换
				end
			else
				inFieldStatus = FuncHandbook.inPlaceStatus.can_changeField  -- 在其他名册,可换阵
			end
		end	

		if inFieldStatus then
			local temp = {
				pId = partnerId,
				status = inFieldStatus,
			}
			if inFieldStatus == FuncHandbook.inPlaceStatus.can_leaveField then
				table.insert(tempArr, 1,temp)
			else
				tempArr[#tempArr +1] = temp
			end
			
			
		end
	end

	-- dump(tempArr, "tempArr", nesting)
	return tempArr
end

function HandbookExchangeDirView:initView()
	self.panel_1.txt_1:setString(FuncHandbook.dirId2Name[tostring(self.dirId)])
	self.panel_2:visible(false)
	self:initScrollCfg()
end

function HandbookExchangeDirView:initScrollCfg()
	local createFunc = function(itemData)
		local itemView = UIBaseDef:cloneOneView(self.panel_2)
		self:updateOnePartnerView(itemData,itemView)
		return itemView
	end
	local updateFunc = function(itemData,itemView)
		self:updateOnePartnerView(itemData,itemView)
		return itemView
	end

    self.scrollParams = {
   		{
	        data = self.curDirAllPartners,
	        createFunc = createFunc,
	        updateCellFunc = updateFunc,
	        perNums= 2,
	        offsetX = 10,
	        offsetY = 20,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x= 0,y=-110,width = 305,height = 110}, 
	        perFrame = 1
	    }
    }
end

function HandbookExchangeDirView:updateOnePartnerView( itemData,itemView )
	-- dump(itemData, "itemData", nesting)
	local partnerId = itemData.pId
	-- 当前标签
	if tostring(partnerId) == tostring(self.curPosPartnerId) then
		itemView.panel_1:visible(true)
	else
		itemView.panel_1:visible(false)
	end
	-- 奇侠评分
	local userData = UserModel._data
	local score = FuncHandbook.getScoreOnePartner(userData.partners[partnerId], userData,self.dirId)
	itemView.txt_2:setString(score)
	-- 奇侠头像
	-- local partnerData = PartnerModel:getPartnerDataById(partnerId)
	itemView.UI_1:updataUI(partnerId)

	-- 当前工作系别 及 上阵下阵状态
	local inFieldStatus = itemData.status -- 上阵1,下阵2,换阵3
	local curWorkDir = HandbookModel:getOnePartnerWorkingDir( partnerId )
	if inFieldStatus == FuncHandbook.inPlaceStatus.can_enterField then
		itemView.txt_4:setString("空 闲")
		itemView.mc_1:showFrame(1)
		local contentView = itemView.mc_1:getCurFrameView()
		contentView.btn_1:setBtnStr("上 阵","txt_1")
	else
		itemView.txt_4:setString(FuncHandbook.dirId2Name[tostring(curWorkDir)])
		itemView.mc_1:showFrame(2)
		local contentView = itemView.mc_1:getCurFrameView()
		if inFieldStatus == FuncHandbook.inPlaceStatus.can_leaveField then
			contentView.btn_1:setBtnStr("下 阵","txt_1")
		elseif inFieldStatus == FuncHandbook.inPlaceStatus.can_changeField then
			contentView.btn_1:setBtnStr("换 阵","txt_1")
		end
	end

	itemView.mc_1:setTouchEnabled(true)
	local function _touchFunc( inFieldStatus,partnerId )
		local partnerArr = {[partnerId] = self.curIndex}
		if inFieldStatus == FuncHandbook.inPlaceStatus.can_enterField then
			HandbookServer:enterTheField(self.dirId,partnerArr,c_func(self.exchangeFieldCallBack,self,inFieldStatus))
		elseif inFieldStatus == FuncHandbook.inPlaceStatus.can_leaveField then
			HandbookServer:leaveTheField(self.dirId,self.curIndex,c_func(self.exchangeFieldCallBack,self,inFieldStatus))
		elseif inFieldStatus == FuncHandbook.inPlaceStatus.can_changeField then
			HandbookServer:enterTheField(self.dirId,partnerArr,c_func(self.exchangeFieldCallBack,self,inFieldStatus))
		end
	end
	itemView.mc_1:setTouchedFunc(c_func(_touchFunc,inFieldStatus,partnerId))
end

function HandbookExchangeDirView:exchangeFieldCallBack( inFieldStatus,serverData )
	echo("+++ inFieldStatus,serverData ++++++",inFieldStatus,serverData)
	if serverData.error then

	else
		-- dump(serverData.result.data, "serverData.result.data", nesting)
		if inFieldStatus == FuncHandbook.inPlaceStatus.can_enterField then
			EventControler:dispatchEvent(HandbookEvent.ONE_PARTNER_ENTER_FIELD)
		elseif inFieldStatus == FuncHandbook.inPlaceStatus.can_leaveField then
			EventControler:dispatchEvent(HandbookEvent.ONE_PARTNER_LEAVE_FIELD)
		elseif inFieldStatus == FuncHandbook.inPlaceStatus.can_changeField then
			EventControler:dispatchEvent(HandbookEvent.ONE_PARTNER_EXCHANGE_FIELD)
		end
		self:onClose()
		-- self:updateUI()
	end
end
function HandbookExchangeDirView:initViewAlign()
	-- TODO
end

function HandbookExchangeDirView:updateUI()
	self:updatePartnersUI()
end

-- 更新阵位所有列表里的奇侠
function HandbookExchangeDirView:updatePartnersUI()
    self.scroll_1:styleFill(self.scrollParams)
    self.scroll_1:hideDragBar()
    self.scroll_1:refreshCellView(1)
end

function HandbookExchangeDirView:deleteMe()
	HandbookExchangeDirView.super.deleteMe(self);
end

function HandbookExchangeDirView:onClose()
	self:startHide()
end
return HandbookExchangeDirView;
