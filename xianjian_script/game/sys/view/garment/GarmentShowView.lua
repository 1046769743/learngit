--
--Author:      zhuguangyuan
--DateTime:    2017-07-31 22:08:16
--Description: 详细展示一件时装界面，可分享时装到其他系统
--

local GarmentShowView = class("GarmentShowView", UIBase);

-- 根据时装id、展示类型、主角id进行时装展示
function GarmentShowView:ctor(winName,garmentId,showType,characterSex)
    GarmentShowView.super.ctor(self, winName)
    self.garmentId = garmentId
    self.showType = showType  
    self.avatar = characterSex or UserModel:avatar()
end

function GarmentShowView:loadUIComplete()
	self:initData()
	self:initView()

	self:registerEvent()
	self:initViewAlign()

	self:updateUI()
end 

----------------------------------------------
--1 初始化数据
----------------------------------------------
function GarmentShowView:initData()
end


----------------------------------------------
--2 初始化view
----------------------------------------------
function GarmentShowView:initView()
	self.mcMainName = self.mc_1
	self.txtGarmentName = self.txt_name

	self.txtStory = self.txt_1

	self.btnShared = self.btn_2
	self.panelSharedTo = self.panel_1

    self.txtClose = self.txt_close
    self.ctnChacator = self.ctn_icon
end



----------------------------------------------
--3 注册事件
----------------------------------------------
function GarmentShowView:registerEvent()
	GarmentShowView.super.registerEvent(self)
    self:registClickClose()  -- 点击任意地方关闭

    -- 设置分享按钮回调
	self.btnShared:setTap(  c_func(self.shareCallBack, self)  )

    -- 设置分享到 工会、世界、朋友 回调
    self.panelSharedTo.btn_1:setTap( c_func(self.shareToGuild, self) )
    self.panelSharedTo.btn_2:setTap( c_func(self.shareToWorld, self) )
    self.panelSharedTo.btn_3:setTap( c_func(self.shareToFriend, self) )

	-- 监听时装分享界面关闭事件
	EventControler:addEventListener(GarmentEvent.GARMENT_CLOSE_SHARE_UI,self.closeUI, self)
end
--点击分享 弹出分享到 panel
function GarmentShowView:shareCallBack()
    echo("----share----");
    self.panelSharedTo:setVisible(true);
end

--分享到工会
function GarmentShowView:shareToGuild()
    echo("----分享到工会----");
end

--分享到世界
function GarmentShowView:shareToWorld()
    echo("----分享到世界----");
    local datas = {
        _type = "CHAT_TYPE_GARMENT",  	-- 类型
        subtypes = "world",  			-- 好友列表
        data = { id = self.garmentId ,sex = UserModel:avatar() }
    }
    ChatShareControler:SendPlayerShareGood(datas)
end

--分享到好友
function GarmentShowView:shareToFriend()
    echo("------分享到好友------");
    if FriendModel:getFriendCount() > 0 then
        local datas = {
            _type = "CHAT_TYPE_GARMENT",  ---类型
            subtypes = "friend",  ----好友列表
            data = { id = self.garmentId ,sex = UserModel:avatar() }
        }
        ChatShareControler:SendPlayerShareGood(datas)
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid_friend_014"))
    end 
end
-- 关闭界面
function GarmentShowView:closeUI()
    self:startHide()
end



----------------------------------------------
--4 屏幕适配
----------------------------------------------
-- 屏幕适配
function GarmentShowView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.mcMainName, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.txtGarmentName, UIAlignTypes.Left);

    FuncCommUI.setViewAlign(self.widthScreenOffset, self.txtStory, UIAlignTypes.Right);
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.btnShared, UIAlignTypes.RightBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panelSharedTo, UIAlignTypes.RightBottom);
    
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_shanzi, UIAlignTypes.Middle);

    FuncCommUI.setViewAlign(self.widthScreenOffset, self.txtClose, UIAlignTypes.MiddleBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.ctnChacator, UIAlignTypes.MiddleBottom);
end



----------------------------------------------
--5 更新ui
----------------------------------------------
function GarmentShowView:updateUI()
	-- 大标题显示 主角战袍或者主角霓裳
    local sex =  FuncChar.getCharSex(self.avatar)
    if tonumber(sex) == 1 then
        self.mcMainName:showFrame(2) --战袍
    else
        self.mcMainName:showFrame(1)
    end

	-- 时装名字
	local nameStr = FuncGarment.getGarmentName(self.garmentId, self.avatar)
    self.txtGarmentName:setString(nameStr)

     --立绘
    local artSp = FuncGarment.getGarmentLihui(self.garmentId, self.avatar,"dynamicShare")
    self.ctnChacator:addChild(artSp)

	-- 设置故事文字
	local strotyStr = FuncGarment.getStoryStr(self.garmentId,self.avatar)
    FuncCommUI.setVerTicalTXT( {str = strotyStr, space = 1, txt = self.txtStory} )

    -- 根据展示类型决定是否展示分享按钮
    if self.showType == "see" then  -- 如果只是展示时装，则不显示分享按钮
        self.btnShared:setVisible(false)
    end
    self.panelSharedTo:setVisible(false)
end

function GarmentShowView:deleteMe()
	-- TODO
	GarmentShowView.super.deleteMe(self);
end

return GarmentShowView;
