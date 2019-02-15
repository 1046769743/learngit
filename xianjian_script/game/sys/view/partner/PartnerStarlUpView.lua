--guan
--2017.2.28
--hehehehehe

local PartnerStarlUpView = class("PartnerStarlUpView", UIBase);

local defaultParam =  {
        before = {
            power = 3,
            hp = 3,
            act = 10,
            def = 32,
            magicDef = 100,
        },
        after = {
            power = 3,
            hp = 3,
            act = 10,
            def = 32,
            magicDef = 100,    
        }
    }
--paramInfo 格式见面

function PartnerStarlUpView:ctor(winName, paramInfo)
    PartnerStarlUpView.super.ctor(self, winName);
    self._paramInfo = paramInfo or defaultParam;
end

function PartnerStarlUpView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function PartnerStarlUpView:registerEvent()
	PartnerStarlUpView.super.registerEvent();
end

function PartnerStarlUpView:initUI()
    self:disabledUIClick();

    self.panel_txt:setVisible(false);
    self.txt_bai:setVisible(false);
    self.txt_lv:setVisible(false);
    self.txt_bai:setVisible(false);
    self.panel_aniTxt:setVisible(false);
    self.txt_jixu:setVisible(false);

    self:initData();
    self:showArmature(); 

    AudioModel:playSound(MusicConfig.s_com_lvl_up);
end

function PartnerStarlUpView:initData()
    --之前的各种属性
    self._prePower = UIBaseDef:cloneOneView(self.txt_bai);
    self._prePower:setString(self._paramInfo.before.power or 0);

    self._preHP = UIBaseDef:cloneOneView(self.txt_bai);
    self._preHP:setString(self._paramInfo.before.hp or 0);

    self._preACT = UIBaseDef:cloneOneView(self.txt_bai);
    self._preACT:setString(self._paramInfo.before.act or 0) ;

    self._preDEF = UIBaseDef:cloneOneView(self.txt_bai);
    self._preDEF:setString(self._paramInfo.before.def or 0);

    self._preMagicDef = UIBaseDef:cloneOneView(self.txt_bai);
    self._preMagicDef:setString(self._paramInfo.before.magicDef or 0);

    --之后的各种属性
    self._afterPower = UIBaseDef:cloneOneView(self.txt_lv);
    self._afterPower:setString(self._paramInfo.after.power or 0);

    self._afterHP = UIBaseDef:cloneOneView(self.txt_lv);
    self._afterHP:setString(self._paramInfo.after.hp or 0);

    self._afterACT = UIBaseDef:cloneOneView(self.txt_lv);
    self._afterACT:setString(self._paramInfo.after.act or 0) ;

    self._afterDEF = UIBaseDef:cloneOneView(self.txt_lv);
    self._afterDEF:setString(self._paramInfo.after.def or 0);

    self._afterMagicDef = UIBaseDef:cloneOneView(self.txt_lv);
    self._afterMagicDef:setString(self._paramInfo.after.magicDef or 0);
end

function PartnerStarlUpView:showArmature()
    FuncCommUI.addBlackBg(self.widthScreenOffset,self._root);

    local mainAni = nil;

    mainAni = self:createUIArmature("UI_zhujueshengji", 
        "UI_zhujueshengji_shengji_shengxing", self.ctn_ani, false, GameVars.emptyFunc);        

    --猪脚小人   
    local charAni = mainAni:getBoneDisplay("zj");
    charAni:playWithIndex(0, 0); 

    local charPath = FuncRes.iconChar(tonumber( UserModel:sex() ));

    local charSp = display.newSprite(charPath);
    charSp:setPosition(0, 0);

    local p1 = charAni:getBoneDisplay("zhujue");
    FuncArmature.changeBoneDisplay(p1, "layer1", charSp); 


   local posY = 16;

    self._prePower:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node9", self._prePower); 
    self._afterPower:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node10", self._afterPower); 

    self._preHP:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node7", self._preHP); 
    self._afterHP:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node8", self._afterHP); 

    self._preACT:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node5", self._preACT); 
    self._afterACT:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node6", self._afterACT);

    self._preDEF:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node3", self._preDEF); 
    self._afterDEF:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node4", self._afterDEF);

    self._preMagicDef:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node1", self._preMagicDef); 
    self._afterMagicDef:setPosition(-100, posY);
    FuncArmature.changeBoneDisplay(mainAni, "node2", self._afterMagicDef);
    
    --80帧的时候
    mainAni:registerFrameEventCallFunc(80, 1, function ( ... )
        self:aniOver();
    end);

end

function PartnerStarlUpView:aniOver()
    self:resumeUIClick();
    self.txt_jixu:setVisible(true);

    self:setTouchedFunc(c_func(self.closeFunc, self));

end

function PartnerStarlUpView:closeFunc()
    self:startHide();
end

return PartnerStarlUpView;



















