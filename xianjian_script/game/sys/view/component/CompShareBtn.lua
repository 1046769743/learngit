--[[
	Author: TODO
	Date:2018-06-07
	Description: TODO
]]

local CompShareBtn = class("CompShareBtn", UIBase);

function CompShareBtn:ctor(winName)
    CompShareBtn.super.ctor(self, winName)
end

function CompShareBtn:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function CompShareBtn:registerEvent()
	CompShareBtn.super.registerEvent(self);
	EventControler:addEventListener(PCShareHelper.EVENT_SHARE_SUCESS,self.onShareSucess,self)
	EventControler:addEventListener(PCShareHelper.EVENT_SHARE_FAIL,self.onShareFail,self)

	self.mc_fenxiang.currentView.btn_share:setTap(c_func(self.pressBtnExpand,self))

	self:registClickClose(nil,c_func(self.pressGlobalClick,self),true )
	--初始 状态是1  表示关闭状态
	self.currentState = 1
end

function CompShareBtn:registerBtnEvent()
	local btnGroupView = self.mc_fenxiang.currentView
	for k,v in pairs(self.keyMap) do
		btnGroupView[k]:setTap(c_func(self.pressShareBtn,self,v))
	end
end

function CompShareBtn:pressShareBtn( shareType )
	echo("点击分享按钮:",shareType,self.isSharing)
	if self.isSharing then
		return
	end

	self.isSharing = true

	local panel = self.getPanelFunc()
	if (not panel) or (tolua.isnull(panel))  then
		echoError("没有获取到panel")
	end

	local shareCallBack = function(filepath)
		if PCShareHelper:isShareFileExist(filepath) then
			PCShareHelper:shareImage(shareType,filepath)
			self.hasShare = true
		else
			WindowControler:showTips("分享失败")
		end
	end
	
	local fileName = "shareImage_" .. TimeControler:getTime()
	PCShareHelper:captureScreenAndShareImageToFile(panel,fileName,c_func(shareCallBack))

	local resetStatus = function()
		self.isSharing = false
	end

	self:delayCall(c_func(resetStatus), 5)
end

--[[
	当分享成功
]]
function CompShareBtn:onShareSucess(event)
	echo("CompShareBtn-分享成功")
	if self.hasShare and self.callBack then
		echo("执行分享回调")
		self.callBack()
		self.hasShare = false
		self.isSharing = false

		-- 检查首次分享奖励
		self:checkFirstShareReward()
	else
		if device.platform == "windows" or device.platform == "mac"  then
			self.callBack()
			-- 检查首次分享奖励
			self:checkFirstShareReward()
		end
	end
end

--[[
	当分享失败
]]
function CompShareBtn:onShareFail(event)
	echo("CompShareBtn-分享失败")
	self.hasShare = false
	self.isSharing = false
end

--[[
	检查首次分享奖励
]]
function CompShareBtn:checkFirstShareReward()
	if UserExtModel:hasFirstShared() then
		return
	end

	local rewardStr = self:getFirstShareReward()
	local rewardArr = {
		rewardStr
	}

	local callBack = function(data)
		WindowControler:showWindow("RewardSmallBgView", rewardArr);
		-- 如果当前组件被删除，该方法为nil
		if self and self.updateSharePanelView then
			self:updateSharePanelView()
		end
	end

	local params = {}
	Server:sendRequest(params,MethodCode.get_first_share_reward_377, callBack)
end

function CompShareBtn:getFirstShareReward(  )
	local rewardArr = FuncDataSetting.getDataArrayByConstantName("FirstShareReward")

	local rewardStr = nil
	if rewardArr and #rewardArr > 0  then
		rewardStr = rewardArr[1]
	end

	return rewardStr
end

--点击空白区域收缩
function CompShareBtn:pressGlobalClick(  )
	if self.currentState == 1 then
		return 
	end
	self.currentState  = 1
	self.mc_fenxiang:showFrame(1)
end


--点击展开按钮
function CompShareBtn:pressBtnExpand(  )
	if self.currentState ~= 1 then
		return 
	end
	self.currentState  = 2
	self:updateSharePanelView()
end


--设置分享回调
--需要传入获取截屏容器的函数进来 getPanelFunc  返回一个lanel,
--因为在截屏的时候 需要做一些逻辑处理 ,比如隐藏显示某些按钮或者图片返回最新的panel 然后在callback里面刷新
--callback  返回的参数  1代表成功  0 表示失败 2代表取消分享
function CompShareBtn:setShareCallBack( getPanelFunc,callBack)
	self.callBack = callBack
	self.getPanelFunc = getPanelFunc
end

function CompShareBtn:initData()
	--对应一个事件数组
	self.keyMap = {
		-- btn_pengyouquan = 1,
		-- btn_weibo = 2,
		-- btn_weixin = 3,
		-- 朋友圈
		btn_pengyouquan = PCShareHelper.SHARE_TYPE.SceneWeChatLine,
		btn_weixin = PCShareHelper.SHARE_TYPE.SceneWeChat,
		btn_weibo = PCShareHelper.SHARE_TYPE.SceneSinaWeibo,
		btn_qq = PCShareHelper.SHARE_TYPE.SceneQQ
	}
end

function CompShareBtn:initView()
	local isOpen = PCShareHelper:checkIsOpen()
	-- 根据开关状态显示或隐藏分享功能
	local childArr = self:getChildren()
	for k,v in pairs(childArr) do
		v:setVisible(isOpen)
	end
end

function CompShareBtn:initViewAlign()
	-- TODO
end

function CompShareBtn:updateUI()
	local hasFirstShared = UserExtModel:hasFirstShared()
	if hasFirstShared then
		self.mc_fenxiang.currentView.panel_red:setVisible(false)
	else
		self.mc_fenxiang.currentView.panel_red:setVisible(true)
	end
end

function CompShareBtn:updateSharePanelView()
	local hasFirstShared = UserExtModel:hasFirstShared()
	if hasFirstShared then
		self.mc_fenxiang:showFrame(3)
	else
		self.mc_fenxiang:showFrame(2)
		local rewardStr = self:getFirstShareReward()
		if not rewardStr then
			return
		end
		
		local rewardUI = self.mc_fenxiang.currentView.UI_1
		local params = {
            reward = rewardStr,
        }

        rewardUI:setResItemData(params)
        local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
        FuncCommUI.regesitShowResView(rewardUI:getResItemIconCtn(),resType,resNum,resId,rewardStr)
	end

	self:registerBtnEvent()
end

function CompShareBtn:deleteMe()
	-- TODO

	CompShareBtn.super.deleteMe(self);
end

return CompShareBtn;
