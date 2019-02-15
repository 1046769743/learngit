local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopSpView = class("CompResTopSpView", ResTopBase);

function CompResTopSpView:ctor(winName)
    CompResTopSpView.super.ctor(self, winName);
end

function CompResTopSpView:loadUIComplete()
	CompResTopSpView.super.loadUIComplete(self)
	self:registerEvent();
	self.preNum = tonumber(UserExtModel:sp())
	self:updateUI()
end
function CompResTopSpView:registerEvent()
	CompResTopSpView.super.registerEvent();
    self.btn_tilijiahao:setTap(c_func(self.press_btn_tilijiahao, self));
	-- self._root:setTouchedFunc(c_func(self.onAddTap, self), nil, true)
	self:addtouchRoot()
	EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE, self.updateUI, self)
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, self.onUserLevelChange, self)
    EventControler:addEventListener(UserEvent.USEREVENT_SP_CHANGE, self.onSpChange, self)
--    EventControler:addEventListener(UserExtEvent.USEREXTEVENT_MODEL_UPDATE, self.onUserExtModelUpdate, self)
	EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT,self.monthCardUpdate,self)
end

function CompResTopSpView:addtouchRoot()
	local function onTouchBegan(touch, event)
		self:onAddTap()
        return true
    end

    local function onTouchCallBack(touch, event)

    end

    local function onTouch(touch, event)

    end

    local function onTouchEnded(touch, event)
    	if self.win then
    		self.win:startHide()
    	end
    end
    self._root:setTouchedFunc(GameVars.emptyFunc, nil, true, 
        onTouchBegan, onTouchCallBack,
        onTouch, onTouchEnded)
end


function CompResTopSpView:monthCardUpdate()
	self:delayCall(function()
		self:updateUI()
	end,0.5)
end

function CompResTopSpView:onUserLevelChange()
	self:updateUI()
end

function CompResTopSpView:onSpChange()
	if self._isStopEffect ~= true then 
		self:updateUI()
	end 
end

function CompResTopSpView:onUserExtModelUpdate()
	local sp = UserExtModel:sp()

	if self._isStopEffect ~= true then 
		self:updateUI()
	end 

end

function CompResTopSpView:onAddTap()
	local isshow = self.btn_tilijiahao:isVisible()
	if isshow then
		echo("=====展示获取体力的面板=====")
		self:addTips()
	else
		local _buySpWin=WindowControler:showWindow("CompBuySpMainView")
		_buySpWin:buyStrength()
	end
end

function CompResTopSpView:addTips()
	self.win = WindowControler:showWindow("CompBuyTiLiTips")
	local posx = self.ctn_1:getPositionX()
	local posy = self.ctn_1:getPositionY()
	local newpos = self.ctn_1:convertLocalToNodeLocalPos(WindowControler:getCurrScene()._root,  cc.p(0,0))
	newpos.x = newpos.x -175
	newpos.y = newpos.y -30
	self.win:setPosition(newpos)
end

-- 购买体力
function CompResTopSpView:press_btn_tilijiahao()
	-- self:onAddTap()
	local _buySpWin=WindowControler:showWindow("CompBuySpMainView")
	_buySpWin:buyStrength()
end

function CompResTopSpView:updateUI()
	--tili 体力动画显不显示
	if  HomeModel.isMoByspRunaction then
		return 
	end

    local sp = UserExtModel:sp()
	local preNum = self:getPreNum()
    if preNum < sp then
		self:playNumChangeEffect(preNum, sp)
	else
		self.txt_tili:setString(sp.."/" .. UserModel:getMaxSpLimit())
		self:updatePreNum(sp)
	end
    -- 体力
    self.txt_zongtili:setVisible(false)
    HomeModel.isMoByspRunaction = false
    -- :setString("/" .. UserModel:getMaxSpLimit())
end

function CompResTopSpView:stopChangeEffect()
	self._isStopEffect = true;
end

function CompResTopSpView:playChangeEffect()
	self._isStopEffect = false;
end

function CompResTopSpView:forceUpdate()
	self:updateUI();
end

--由于体力是分开的两部分，左边的数字又是右对齐，所以单独处理
function CompResTopSpView:playNumChangeEffect(fromNum, toNum)
	local textNode = self:getAnimTextNode()
	local textAnimCtn = self:getNumChangeEffecCtn()
	if not textNode or not textAnimCtn then
		return
	end
	local animName = "UI_common_res_num"
	if not self.ani_resNum then
		self.ani_resNum = self:createUIArmature("UI_common", animName, textAnimCtn, false, GameVars.emptyFunc)
		self.ani_resNum:scale(0.8)
		local posx, posy = self.ani_resNum:getPosition()
		self.resNumAnimPosX = posx
		self.resNumAnimPosY = posy
		FuncArmature.changeBoneDisplay(self.ani_resNum , "layer6", textNode)
	end
	local numAnim = self.ani_resNum
	local textRect = textNode:getContainerBox()
	--reset position
	-- numAnim:pos(-68-50,17)--self.resNumAnimPosX, self.resNumAnimPosY)
	textNode:pos((-textRect.width+5)/2, (textRect.height-6)/2)

	--动画居中
	local stringWidth = FuncCommUI.getStringWidth(UserExtModel:sp()..'', 22, GameVars.systemFontName)
	local scale = (GameVars.width - GameVars.gameResWidth)*1.0/GameVars.gameResWidth
	local offsetX = (textRect.width - stringWidth)*1.0/2
	-- textNode:pos(textNode:getPositionX()-offsetX, textNode:getPositionY())
	-- numAnim:pos(numAnim:getPositionX()+offsetX, numAnim:getPositionY())

	local setTextNum = function(num)
		textNode:setString(num.."/" .. UserModel:getMaxSpLimit())
		self:updatePreNum(num)
	end
	numAnim:gotoAndPause(1)
	numAnim:startPlay(false)
	local frameLen = 20
	for frame=1,frameLen do
		local num = toNum
		if frame < frameLen then
			num = math.floor((toNum - fromNum)*1.0/frameLen * frame) + fromNum
		end
		numAnim:registerFrameEventCallFunc(frame, 1, c_func(setTextNum, num))
	end
end

function CompResTopSpView:getAnimTextNode()
	return self.txt_tili
end

function CompResTopSpView:getIconAnimCtn()
	return self.ctn_2
end

function CompResTopSpView:getIconNode()
	return self.panel_icon_tili
end

function CompResTopSpView:getIconAnimName()
	return "UI_common_icon_anim_tili"
end

function CompResTopSpView:getNumChangeEffecCtn()
	return self.ctn_1
end


return CompResTopSpView;
