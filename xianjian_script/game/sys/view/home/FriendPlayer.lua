--2015.12.10
--guan

local Direction = {
	Left = 1,
	Right = 2,	
};

local GLOW_TAG = 562;


--好友移动速度每秒移动多少像素
local moveSpeed = 100 * 1.5;

local FriendPlayer = class("FriendPlayer", function()
	--是个Node, 里面放具体的人物, 看看是 dragonBone 或是 spine 
    return display.newNode()
end)

--传入node 或 是其他信息，在这里生成显示对象
function FriendPlayer:ctor(node, playerInfo)
	--spine 动画
	self._showNode = self:initShowNode(node);
	self._moveSpeed = moveSpeed;

	self:addChild(self._showNode);

	self._ai = self:aiCreate();

	--下次是否消失
	self._nextDisAppear = nil;

	--目前人物往左走还是往右走
	self._faceDirection = Direction.Right;
	--是否让玩家移动
	self.isPlayerMove = true
	
	--上次的目标x位置
	self._preTargerPosX = nil;
	self._avatarId = playerInfo.avatar or 101;

	self._playerInfo = playerInfo;

	if playerInfo.isRobot == true then 
		self._isRobot = true
	else 
		self._isRobot = false
	end 
end

function FriendPlayer:getRid()
	return self._playerInfo._id;
end

function FriendPlayer:getHid()
	return self._avatarId;
end

function FriendPlayer:getMoveSpeed( ... )
	return self._moveSpeed;
end

function FriendPlayer:getShowNode()
	return self._showNode;
end

function FriendPlayer:isRobot( )
	return self._isRobot;
end

function FriendPlayer:initShowNode(node)
	node:setOpacity(0);
	node:setPosition(0, 0);
	node:setAnchorPoint(cc.p(0, 0));
	node:setScale(FuncHome.OtherScal)
	return node;
end


function FriendPlayer:setChatBubbleUI(bubbleUI)
	bubbleUI:setPosition(-40, 225);
	bubbleUI:setVisible(false);
	self:addChild(bubbleUI, 1001);

	self._bubbleUI = bubbleUI;
end

--[[
	重复说，则覆盖之前说的话
]]
function FriendPlayer:showBubble(str)
    self._bubbleUI:setVisible(true);
    self._bubbleUI:setOpacity(255);
    self._bubbleUI:stopAllActions();

    self._bubbleUI.txt_1:setString(str);

    local delayAction = cc.DelayTime:create(3);
    local fadeOutAction = cc.FadeOut:create(0.5);
    local sequenceAction = cc.Sequence:create(delayAction, fadeOutAction);

    self._bubbleUI:runAction(sequenceAction);
end



--增加脚下的光
function FriendPlayer:addGrowDown()
	self:removeChildByTag(GLOW_TAG, true);
	local growAni = FuncArmature.createArmature("common_xuanzhongb", nil, true);
	self:addChild(growAni, -1, GLOW_TAG);
end

function FriendPlayer:reoveGrowDown()
	self:removeChildByTag(GLOW_TAG, true);
end

--出生动画
function FriendPlayer:birth(targetCtn)
	local pos = self._ai:getBirthPos();
	local posX = pos.x;
	self._posY = pos.y;
	self._preTargerPosX = posX;
	self:setPosition(posX, self._posY);

	--出生动画
	self._showNode:playLabel("stand");
	local appearAnim = FuncArmature.createArmature("UI_common_juesexiaoshi_juesechuxian", 
            targetCtn, false, GameVars.emptyFunc);
    FuncArmature.changeBoneDisplay(appearAnim, "node2", self._showNode);
	
	appearAnim:setPosition(posX, self._posY);

	appearAnim:setLocalZOrder(-self._posY);

	appearAnim:doByLastFrame(true, true, function ( ... )
            FuncArmature.takeNodeFromBoneToParent(self._showNode, self);
            if self.isPlayerMove then
            	self:startAction();
            end
        end
    );	
end
function FriendPlayer:isoffPlayerMove( _boor )
	self.isPlayerMove = _boor
end

function FriendPlayer:goAway(targetCtn)	

 	function delayFunc( )
 		-- echo("---targetCtn---", targetCtn);
		self._showNode:playLabel("stand");

		local disappearAnim = FuncArmature.createArmature("UI_common_juesexiaoshi", 
	        targetCtn, false, GameVars.emptyFunc);

	    FuncArmature.changeBoneDisplay(disappearAnim, "node1", self._showNode);
		
		disappearAnim:setPosition(self:getPositionX(), 
			self:getPositionY());

		disappearAnim:doByLastFrame(true, true, function ( ... )
				self:removeFromParent();
	        end
	    );	
 	end

 	self:stopAllActions();

	--下线动画
	self._showNode:playLabel("stand");
	local startAniTime = self._showNode:getCurrentAnimTotalFrame() * 1/30;
	self:delayCall(delayFunc, startAniTime);

end

function FriendPlayer:aiCreate()
	return FriendPlayerStrollAI.new(self);
end

--开始乱走
function FriendPlayer:startAction()
	local actionType, stayTime, posX, posY = self._ai:getNextAction();

	-- echo("actionType:" .. tostring(actionType));
	-- echo("stayTime:" .. tostring(stayTime));
	-- echo("posX:" .. tostring(posX));

	if actionType == ActionType.JustStay then
	
		self._showNode:playLabel("stand");
		self:delayCall( c_func(self.playNextAction, self), stayTime);

	elseif actionType == ActionType.GoToAndStay then
		if self._preTargerPosX > posX then 
			self:setRunAction(Direction.Left);
		else 
			self:setRunAction(Direction.Right);
		end 

		local moveTime = math.abs(posX - self._preTargerPosX) / moveSpeed;
	    local moveAct = cc.MoveTo:create(moveTime, cc.p(posX, posY));

	    local sequence = cc.Sequence:create(moveAct, cc.CallFunc:create(
	    	function ()    	 
	    		self._showNode:playLabel("stand");
				self:delayCall( c_func(self.playNextAction, self), stayTime);
	    	end)
	    )
	    self:runAction(sequence);		

		self._preTargerPosX = posX;
	else 
		echo("startAction type is error! " .. tostring(actionType));
	end 
end


function FriendPlayer:setRunAction(direction)
	if direction == Direction.Left then 
		if self._faceDirection == Direction.Right then 
			self._showNode:setRotationSkewY(180);
		end
	else 
		if self._faceDirection == Direction.Left then 
			self._showNode:setRotationSkewY(0);
		end
	end 

	self._showNode:playLabel("run");
	self._faceDirection = direction;
end

function FriendPlayer:playNextAction()
	if self._nextDisAppear == true then
		if self.playDisappearAction ~= nil then 
			self:playDisappearAction();
		end 
	else 
		if self.startAction ~= nil then 
			self:startAction();
		end
	end 
end

-- --播放消失的动作然后消失RemoveFromParent 貌似木有用
-- function FriendPlayer:disAppearAndRemoveFromParent()
-- 	self._nextDisAppear = true;
-- end
function FriendPlayer:playDisappearAction()
    local disAppearAct = cc.FadeTo:create(2, 0);

    local sequence = cc.Sequence:create(disAppearAct, cc.CallFunc:create(
    	function ()    	 
    		self:removeFromParent();	
    	end)
    )
    self:runAction(sequence);
end

return FriendPlayer;














