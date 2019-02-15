--zhang
--2017.5.23

local PartnerSkinShowView = class("PartnerSkinShowView", UIBase);


function PartnerSkinShowView:ctor(winName, skinId ,showType)
    PartnerSkinShowView.super.ctor(self, winName);
    self._skinId = skinId;
    self.showType = showType
end

function PartnerSkinShowView:loadUIComplete()
	self:registerEvent();
    self:uiAdjust();
    self:initUI();
end 

function PartnerSkinShowView:registerEvent()
	PartnerSkinShowView.super.registerEvent();

    EventControler:addEventListener(GarmentEvent.GARMENT_CLOSE_SHARE_UI,self.closeUI, self)
    --点击任意地方关闭
    self:registClickClose(-1, c_func( function()
            self:startHide()
    end , self))
end
function PartnerSkinShowView:closeUI()
    self:startHide()
end
function PartnerSkinShowView:initUI()
    --故事
    local strotyStr = FuncPartnerSkin.getStoryStr(self._skinId);
    FuncCommUI.setVerTicalTXT( {str = strotyStr, space = 3, txt = self.txt_1} );
    --名字
    local nameStr = FuncPartnerSkin.getPartnerName(self._skinId);
    self.txt_name:setString(nameStr);

    --皮肤名称
    local skinStr = FuncPartnerSkin.getSkinName(self._skinId)
    self.txt_name2:setString(skinStr);

    --立绘
    local partnerId = FuncPartnerSkin.getValueByKey( self._skinId,"partnerId")
    local artSp = FuncPartner.getPartnerLiHuiByIdAndSkin(partnerId,self._skinId )
    self.ctn_icon:removeAllChildren();
    self.ctn_icon:addChild(artSp);

    if self.showType == "see" then
        self.panel_fen:visible(false)
    else
        --下面的两个btn
        self.panel_fen.btn_2:setTap( c_func(self.shareCallBack, self) );
        self.panel_fen.panel_1:visible(false)
        self.panel_fen.panel_1.btn_1:setTap( c_func(self.shareCallBack1, self) );
        self.panel_fen.panel_1.btn_2:setTap( c_func(self.shareCallBack2, self) );
        self.panel_fen.panel_1.btn_3:setTap( c_func(self.shareCallBack3, self) ); 
    end
    
end

function PartnerSkinShowView:shareCallBack()
    --分享
    self.panel_fen.panel_1:visible(true)
end
function PartnerSkinShowView:shareCallBack1()
    --仙盟分享
    WindowControler:showTips(GameConfig.getLanguage("tid_common_2033")) 
end
function PartnerSkinShowView:shareCallBack2()
    --世界分享
    local datas = {
        _type = "CHAT_TYPE_PARTNER_SKIN",  ---类型
        subtypes = "world",  ----好友列表
        data = { id = self._skinId }
    }
    ChatShareControler:SendPlayerShareGood(datas)
end
function PartnerSkinShowView:shareCallBack3()
    --好友分享
    if FriendModel:getFriendCount() > 0 then
        local datas = {
             _type = "CHAT_TYPE_PARTNER_SKIN",  ---类型
            subtypes = "friend",  ----好友列表
            data = { id = self._skinId }
        }
        ChatShareControler:SendPlayerShareGood(datas)
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid_partnerskin_007")) 
    end


    
end

--分辨率适配
function PartnerSkinShowView:uiAdjust()
--    FuncCommUI.setViewAlign(self.widthScreenOffset, 
--        self.panel_right, UIAlignTypes.RightTop);

--    FuncCommUI.setViewAlign(self.widthScreenOffset, 
--        self.panel_left, UIAlignTypes.LeftTop);

--    FuncCommUI.setViewAlign(self.widthScreenOffset, 
--        self.panel_shanzi, UIAlignTypes.MiddleBottom);

    FuncCommUI.setViewAlign(self.widthScreenOffset, 
        self.txt_close, UIAlignTypes.MiddleBottom);

    FuncCommUI.setViewAlign(self.widthScreenOffset, 
        self.panel_fen, UIAlignTypes.RightBottom);
end


return PartnerSkinShowView;






