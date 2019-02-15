local FriendEmailview = class("FriendEmailview", UIBase);

--[[
    self.UI_mail,
    self.btn_close,
    self.mc_mailzong1,
    self.scale9_mailbeijing,
]]

function FriendEmailview:ctor(winName)
    FriendEmailview.super.ctor(self, winName);
end

function FriendEmailview:loadUIComplete()
	self:registerEvent();

	self._currentIndex =1
	--分辨率适配
	--关闭按钮右上
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name,UIAlignTypes.LeftTop) 
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan,UIAlignTypes.RightTop)
    -- FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_updi,UIAlignTypes.MiddleTop, 1, 0)
	--请求邮件


	--隐藏 需要克隆的邮件item
	self.mc_mailzong1:getViewByFrame(1).panel_1:visible(false)
    -- 邮件刷新支持
    self._breakMail = 0
    
	local scroll_list = self.mc_mailzong1:getViewByFrame(1).scroll_list
	-- scroll_list:setPositionX(70)
	--初始化更新ui
	self:updateUI()



end 





function FriendEmailview:registerEvent()
	--添加邮件事件
	EventControler:addEventListener(MailEvent.MAILEVENT_DELMAIL  ,self.receiveMail,self)
	EventControler:addEventListener(MailEvent.MAILEVENT_UPDATEMAIL  ,self.receiveMail,self)
	FriendEmailview.super.registerEvent();
	-- self:registClickClose("out")
    self.btn_back:setTap(c_func(self.press_btn_close, self));
 --    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_email_001"))
end  

function FriendEmailview:press_btn_close()
	self:startHide()
end

function FriendEmailview:refreshBtnTap()
    local  mails = MailModel:getSortMail()
    
    if #mails > 0 then
        -- 一键领取
        local getAllBtn = self.mc_mailzong1.currentView.btn_lq
        getAllBtn:setTap(function()
            if mails then
                local num = 0
                for i,v in pairs(mails) do
                    if v.reward then
                        num = num + 1
                        -- self:pressLingquBtn(v)
                    end
                end
                if num == 0 then 
                    WindowControler:showTips(GameConfig.getLanguage("#tid_email_002"))
                else
                	self:getAllReward()
                end
            else    
                WindowControler:showTips("现在是空，此时逻辑有问题")
            end
        end)

        -- 一键删除
        local delAllBtn = self.mc_mailzong1.currentView.btn_sc
        delAllBtn:setTap(function()
            if mails then
                local num = 0
                for i,v in pairs(mails) do
                    if v.reward == nil then
                        num = num + 1
                        -- self:pressLingquBtn(v)
                    end
                end
                if num == 0 then
                    WindowControler:showTips(GameConfig.getLanguage("#tid_email_003"))
                else 
                   self:deleteAllBlankMail()
                end
            else    
                WindowControler:showTips("现在是空，此时逻辑有问题")
            end
        end)
    end
    
end

--收到邮件后 更新UI
function FriendEmailview:receiveMail( e )
	-- echo("receiveMail:,",e.name)
	self:updateUI()
end


--获取邮件返回
function FriendEmailview:requestMailBack( data )

	--如果请求失败 
	if not data.result then
		return
	end

	local mails = data.result.data.data
	self:updateUI()
end


--刷新邮件列表
function FriendEmailview:updateUI(  )
	
	--获取邮件数据
	local  mails = MailModel:getSortMail()

--    local  mails = {}
    -- 检查错误信息
--    for i,v in pairs(_mails) do
--        if MailModel.checkErrorMail(v.reward) then
--            table.insert(mails,v)
--        end

--    end
    
    self._cacheMails = mails

    -- 不知道 有什么用
--	if not self._cacheMails then
--		self._cacheMails = mails
--	else
--		--把缓存的mails 和 mails 进行对比
--		for i=#self._cacheMails,1,-1 do
--			--如果没有这个邮件 那么直接删除
--			if not table.indexof(mails, self._cacheMails[i]) then
--				table.remove(self._cacheMails,i)
--			end

--		end

--		mails = self._cacheMails


--	end
	-- self.mc_mailzong1:setScale(1)
	if not mails or #mails ==0 then
		self.mc_mailzong1:showFrame(2)
		self.mc_mailzong1:setScale(1)
	else
		-- if self.mc_mailzong1:getScaleX() == 1  and self.mc_mailzong1:getScaleY() == 1 then
			-- self.mc_mailzong1:setScaleX(0.9)
		self.mc_mailzong1:setScaleY(0.98)
		-- end
		self.mc_mailzong1:showFrame(1)
		--dump(mails,"_mails_"..#mails)
		--存储所有的邮件信息
		
		local createFunc = function ( itemData )
			local view = UIBaseDef:cloneOneView(self.mc_mailzong1:getViewByFrame(1).panel_1)
			self:updateItem(view, itemData)
			return view
		end
		

		local scrollParams = {
			{
				data = mails,
				createFunc= createFunc,
				perFrame = 2,
				offsetX =0,
				offsetY =6,
				itemRect = {x=0,y=-105,width=320,height = 105},
				
				heightGap = 12
			}
		}

		local scroll = self.mc_mailzong1:getViewByFrame(1).scroll_list


		if self._currentIndex == (#self._cacheMails +1 ) then
            self._currentIndex =1
            scroll:gotoTargetPos(1,1,0);
		end


		-- scroll:setFillEaseTime(0.3)
		scroll:styleFill(scrollParams)
		scroll:hideDragBar()

		if self._currentIndex <= 0 then
			self._currentIndex =1
		end

		local info = mails[self._currentIndex]
		local isFirst = false
		if not info then
			--那么显示第一条
			info = mails[1]
			isFirst = true
		end
		
		--默认显示第一个
		  self:showOneMailInfo(info,true)
	end

    self:refreshBtnTap()
end


--邮件信息
--[[

]]
function FriendEmailview:updateItem(view,info )
	
	view._itemData = info 

	--初始化隐藏选中框
	view.panel_jinjiao:visible(false)
	

	local frameView = view

     --取邮件内容如果有tempId时使用模板的title和content，否则用邮件数据本身的title和content
	local tempId = info.tempId 
    local title = info.title -- 邮件数据本身的title
    if tempId then
        title = FuncMail.getMailTitle(tempId)
    end
	--title
	--发送时间
	local sendTime = info.sendTime

	--日期table
	--[[	
		 - "data" = {
		     "day"   = 14
		     "hour"  = 15
		     "isdst" = false
		     "min"   = 8
		     "month" = 1
		     "sec"   = 18
		    "wday"  = 5
		     "yday"  = 14
		    "year"  = 2016
		}
		
	]]
	local date = os.date("*t",sendTime)

	-- local dateStr =date.year.."-"..date.month .."-"..date.day.." " ..string.ljust(date.hour,2) ..":" ..string.ljust(date.min,2) 
--	local dateStr =string.ljust(date.hour,2) ..":" ..string.ljust(date.min,2) 
    local dateStr =string.ljust(date.year,4).."-"..string.ljust(date.month,2).."-"..string.ljust(date.day,2)
	view.txt_name:setString(title)

    view.txt_mailday:setString(dateStr)
	--view.txt_mailday:setString(dateStr.."_id:"..info._id)

	--注册点击事件
	view:setTouchedFunc(c_func(self.showOneMailInfo, self,info,false))


	if info.reward then
		view.panel_reward:visible(true)
	else
		view.panel_reward:visible(false)
	end


	if (not info.read) or info.read ==0 then
		view.mc_di1:showFrame(1)
		view.mc_icon:showFrame(1)
	else
		view.mc_di1:showFrame(2)
		view.mc_icon:showFrame(2)
	end

	--有奖励的地板永远是 第一帧
--	if  info.reward then
--		view.mc_di1:showFrame(1)
--	end
    --邮件列表底板 只显示第一帧
    -- view.mc_di1:showFrame(1)
end

--显示mail详细信息 传递
function FriendEmailview:showOneMailInfo(info ,isInit)
	
	--如果滚动条是滚动中的
	local scroll_list = self.mc_mailzong1:getViewByFrame(1).scroll_list

	if scroll_list:isMoving() and (not isInit) then
		return 
	end
	if not self._currentIndex then
		self._currentIndex =1
	end
	--获取所有的邮件view
	local allViewArr = scroll_list:getAllView()
	for i,v in ipairs(allViewArr) do
		if v._itemData == info then
			v.panel_jinjiao:visible(true)
			self._currentIndex = i
			     if not info.read  or info.read ==0 then
				    --判断是否是未读
				    local mailId = info._id
				    --让这个邮件变成已读 同时记录scroll当前位置 读取完毕以后 复原

				    --读邮件
                    if self._breakMail == 0 then
				        MailServer:readMail(mailId)
                    end
				    --同时让修改读取状态
				    if not info.reward then
					   v.mc_di1:showFrame(2)
				    else
					   v.mc_di1:showFrame(2)
				    end
				
				    v.mc_icon:showFrame(2)
			     end
		else
			v.panel_jinjiao:visible(false)
		end
	end


	--右边详情
	local targetView = self.mc_mailzong1.currentView.mc_xiangqing1
	--如果是有奖励的 
	if info.reward then
		targetView:showFrame(1)
		--领取奖励事件
		targetView.currentView.btn_lingqu1:setTap(c_func(self.pressLingquBtn, self,info,2))

		FilterTools.setGrayFilter(targetView.currentView.btn_lingqu1)
		FilterTools.clearFilter(targetView.currentView.btn_lingqu1)
		--奖励
		local rewards = info.reward

		--这里需要换成scroll
		local rewardScroll =  targetView.currentView.scroll_list

		local createFunc = function (data)
			local itemView = UIBaseDef:cloneOneView( targetView:getViewByFrame(1).UI_1 )

			itemView:setResItemData({reward = data})
			itemView:showResItemName(false)
			local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(data)
			FuncCommUI.regesitShowResView(itemView, resType, needNum, resId,data,true,true)

			return itemView
		end
        
		local params = {
			{
				data = rewards,
				createFunc= createFunc,
				-- perNums=1,
				offsetX =5,
				offsetY =-60,
				itemRect = {x=0,y=1,width=90,height = 74},
				perFrame = 2,
				heightGap = 0,
                widthGap = 16,
			}
		}

		rewardScroll:styleFill(params)

		if #rewards <= 4 then
			--rewardScroll:setCanScroll(false)
		else
			rewardScroll:setCanScroll(true)
		end

		for i=1,4 do
			local itemView = targetView.currentView["UI_"..i]:visible(false)
			itemView:visible(false)
		end

	else
		targetView:showFrame(2)
		targetView.currentView.btn_shanchu1:setTap(c_func(self.pressLingquBtn, self,info,1))
	end

    --取邮件内容如果有tempId时使用模板的title和content，否则用邮件数据本身的title和content
	local tempId = info.tempId 
    local title = info.title -- 邮件数据本身的title
    local content = info.content

    if tempId then
        local param = {}--MailModel:mailDetail(info._id)
        title = FuncMail.getMailTitle(tempId) 
        
        local param = MailModel:getPamesArr(info)

        content = FuncMail.getMailContent(tempId, param)
        --发件人
	    local sec = FuncMail.getMailSec( tempId )
	    content = content.. "\n\n"..FriendEmailview:getSpaceStr(sec)
    end
	   

	targetView.currentView.txt_biaoti:setString(title)

	
	
	--设置内容
	targetView.currentView.txt_neirong:setString(content)

	--targetView.currentView.txt_name:setString(sec)

end
function FriendEmailview:getAllReward()
	local  mails = MailModel:getSortMail()
    self._breakMail = self._breakMail+1
	local tempFunc =function ()
		local number = 0
		for i,v in pairs(mails) do
			if v.reward then
				number = number + 1
				local info = v
				local mailId = info._id
				MailModel:deleteMail(mailId)
				if not info.reward then 
					WindowControler:showTips(GameConfig.getLanguage("#tid_email_004"))
				else
					FuncCommUI.startRewardView(info.reward)
				end
			end
 		end
	end

	MailServer:getAttachment(nil,2,tempFunc,1)
end


--一键删除
function FriendEmailview:deleteAllBlankMail()
    local  mails = MailModel:getSortMail()
    self._breakMail = self._breakMail+1
    local tempFunc =function ()
        local number = 0
        for i,v in pairs(mails) do
            if  v.reward == nil then
                number = number + 1
                local info = v
                local mailId = info._id
                MailModel:deleteMail(mailId)
            end
        end
    end

    MailServer:getAttachment(nil,1,tempFunc,1)

end

--领取一条奖励
function FriendEmailview:pressLingquBtn(info,mailType)
	local mailId = info._id
    local type = mailType or 0
    self._breakMail = 0
	local tempFunc =function (  )
		MailModel:deleteMail(mailId)
		if not info.reward then
			WindowControler:showTips(GameConfig.getLanguage("#tid_email_004"))
		else
			FuncCommUI.startRewardView(info.reward)
		end
		--

	end
	MailServer:getAttachment(mailId,mailType,tempFunc)
	--self._currentMoveView = self.mc_mailzong1:getViewByFrame(1).scroll_list:getViewByData(info)

end


--计算发件人前面应该留多少个空格
function FriendEmailview:getSpaceStr( sec )

    if device.platform == "android" or device.platform == "ios" then
        local length = string.len4cn2(sec) *2
	    local total = 70
	    local spaceNum = total - length 
	    local resultStr = ""
	    for i=1,spaceNum do
		    resultStr = resultStr.." "
	    end
	    resultStr = resultStr..sec
	    return resultStr
    else
        local length = string.len4cn2(sec) *2
	    local total = 70
	    local spaceNum = total - length 
	    local resultStr = ""
	    for i=1,spaceNum do
		    resultStr = resultStr.." "
	    end
	    resultStr = resultStr..sec
	    return resultStr
    end
	


end


return FriendEmailview;
