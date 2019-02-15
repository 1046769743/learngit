--guan

local SysWillOpenView = class("SysWillOpenView", UIBase);
local BASESIZE = cc.size(293, 293)

function SysWillOpenView:ctor(winName, willOpenName, condition)
    SysWillOpenView.super.ctor(self, winName);
    self._willOpenName = willOpenName;
    self.condition = condition;
end

function SysWillOpenView:loadUIComplete()
	self:registerEvent();
    self:initUI();
    
    
    -- self.panel_txts.btn_close:setTap(c_func(self.startHide, self));
    self.panel_txts.btn_close:setVisible(false)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_xxx,UIAlignTypes.Middle)
    self.ctn_xxx:setPosition(cc.p(GameVars.halfResWidth,-GameVars.halfResHeight))

end 

function SysWillOpenView:registerEvent()
	SysWillOpenView.super.registerEvent(self);
    self:registClickClose(-1, c_func( function()
        self:clickButtonBack()
    end , self))
end

function SysWillOpenView:initUI()
    local tidName = FuncCommon.getSysOpensysname(self._willOpenName);
    -- self.panel_txts.txt_name:setString(GameConfig.getLanguage(tidName));

    local tidDes = FuncCommon.getSysOpenContent(self._willOpenName);
    local desStr = GameConfig.getLanguage(tidDes) --.. GameConfig.getLanguageWithSwap(GameVars.openLevelTid, UserModel:level(), self.condition)
    
    local dis = UserModel:getConditionTip(self.condition )

    self.panel_txts.rich_miaoshu:setString(desStr.."\n<color = ffffff>"..dis.."<->")

    local iconPath = FuncRes.iconSysTitle(self._willOpenName)
    local spIcon = display.newSprite(iconPath);
    -- spIcon:setScale(1.3)
    spIcon:anchor(0,1)
    self.panel_txts.ctn_xf:removeAllChildren()
    self.panel_txts.ctn_xf:addChild(spIcon)   

    local adDes = FuncCommon.getAdInt(self._willOpenName);
    self.panel_txts.txt_miao:setString(GameConfig.getLanguage(adDes));

    self:initAni();
end

function SysWillOpenView:clickButtonBack()
    if not self.touch_close then
        self.touch_close = true
        if self.ani then
            local bone = self.ani:getBoneDisplay("layer2a")
            bone:setVisible(false)
            self.ani:getAnimation():playWithIndex(2,0,0)
        end
        -- echo("=============",self.ani:getAnimation():getRawDuration())
        self:delayCall(function () 
            self:startHide()
        end, 0.5)
    end
end

function SysWillOpenView:initAni()

    self.ani = self:createUIArmature("UI_common","UI_common_xianfazhiren", self.ctn_xxx, 
        false, GameVars.emptyFunc);
    -- self.ani:getAnimation():playWithIndex(1,0,0)

    -- ani:setPosition(cc.p(GameVars.halfResWidth-GameVars.UIOffsetX,-GameVars.halfResHeight))
    local ctn_box = self.ctn_xxx:getContainerBox()
    self.ani:setPosition(cc.p(0,15))
    --换描述
    self.panel_txts:setPosition(-70, 40);
    FuncArmature.changeBoneDisplay(self.ani, "layer2a", self.panel_txts);
    -- 换icon
    local spPath = FuncRes.iconSysBig(self._willOpenName);
    local sp = display.newSprite(spPath);
    local sz = sp:getContentSize()
    -- 设置为固定大小
    sp:setScale(BASESIZE.width / sz.width, BASESIZE.height / sz.height)

    sp:setPosition(0, 10);
    FuncArmature.changeBoneDisplay(self.ani, "node1", sp);
    --  修改适配 wk
    self.ani:getBoneDisplay("tc2"):setScaleX(GameVars.width/1136)
    local x = self.ani:getBoneDisplay("tc2"):getPositionX()
    local offetx = GameVars.width-1136
    if offetx <= 0 then
        offetx = 0
    else
        offetx = offetx/2 - 20/2
    end
    self.ani:getBoneDisplay("tc2"):setPositionX(x - offetx )

    -- self.panel_xuan:setOpacity(1);
    -- local sp1 = display.newSprite(spPath);
    -- sp1:setPosition(100,-200)
    -- FuncArmature.changeBoneDisplay(ani, "tc2", sp1);

    -- 换关闭按钮
    -- self.panel_txts.btn_close:setPosition(0, 0);
    -- FuncArmature.changeBoneDisplay(ani, "layer1", self.panel_txts.btn_close);   

    -- ani:registerFrameEventCallFunc(10, 1, function ()

    -- end);


    -- self.panel_zhanwei:setOpacity(1);
    -- self.panel_zhanwei:setTouchedFunc(function ( ... )
    --     echo(" setTouchedFunc setTouchedFunc setTouchedFunc");
    -- end);

    -- self.panel_zhanwei:setTouchSwallowEnabled(true);
    -- self.panel_zhanwei1:setPositionX(480)
    -- self.panel_zhanwei1:setOpacity(1);
    -- self.panel_zhanwei1:setTouchedFunc(function ( ... )
    --     self:startHide();
    -- end);

    -- self.panel_zhanwei2:setPositionX(480)
    
    -- self.panel_zhanwei2:setTouchedFunc(function ( ... )
    --     self:startHide();
    -- end);


end

return SysWillOpenView;







