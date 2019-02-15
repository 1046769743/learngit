--2016.7.5
--guan

--玩家的Y坐标
local playerPosY = -(640 - 150);

--主角移动速度每秒移动多少像素
local moveSpeed = 250 * 1.5;

local Player = class("Player", function()
	--是个Node, 里面放具体的人物, 看看是 dragonBone 或是 spine 
    return display.newNode()
end)

--传入node 或 是其他信息，在这里生成显示对象
function Player:ctor()
	--todo loading 时候加
    -- FuncArmature.loadOneArmatureTexture("UI_zhujuexuanzhong", nil, true)
	--spine 动画
	self._showNode = self:initShowNode();
	--脚下光圈
	FuncArmature.createArmature("UI_zhujuexuanzhong_juese_xia", self, true);

	self:addChild(self._showNode);
end


function Player:setChatBubbleUI(bubbleUI)
	bubbleUI:setPosition(-40, 225);
	bubbleUI:setVisible(false);
	self:addChild(bubbleUI, 1001);
	self._bubbleUI = bubbleUI;
end

--[[
	重复说，则覆盖之前说的话
]]
function Player:showBubble(str)
    self._bubbleUI:setVisible(true);
    self._bubbleUI:setOpacity(255);
    self._bubbleUI:stopAllActions();

    self._bubbleUI.txt_1:setString(str);

    local delayAction = cc.DelayTime:create(3);
    local fadeOutAction = cc.FadeOut:create(0.5);
    local sequenceAction = cc.Sequence:create(delayAction, fadeOutAction);

    self._bubbleUI:runAction(sequenceAction);
end

function Player:changeShowNode()
	local node = self:initShowNode();

	local preLabel = self._showNode.currentLabel;

	self._showNode:removeFromParent();
	self._showNode = node ;

	self._showNode:playLabel(preLabel);

	self:addChild(self._showNode);
end

function Player:getShowNode()
	return self._showNode;
end

function Player:initShowNode()
	-- local node = NatalModel:getCharOnNatal("1");
	-- local node = FuncChar.getSpineAni(tostring(UserModel:avatar()), UserModel:level());
	-- local garmentId = GarmentModel:getOnGarmentId();
 --    local node = GarmentModel:getSpineViewByAvatarAndGarmentId(nil, garmentId);

 	local node = GarmentModel:getCharGarmentSpine();

	self._natalTid = "";

	node:setPosition(0, 0);
	node:setAnchorPoint(cc.p(0, 0));
	node:setScale(FuncHome.MinScal)
	--other init
	return node;
end



function Player:getNatalTid()
	return self._natalTid;
end

function Player:getCurSpeed()
	return moveSpeed / 30;
end

function Player:setCurSpeedY(distance, offsetY)
	local time = distance / self:getCurSpeed();
	local v = offsetY / time;
	if v < 0 then 
		v = -v;
	end 

	if v > moveSpeed / 30 then 
		v = moveSpeed / 30;
	end 

	self._curSpeedY = v;

end

function Player:getCurSpeedY()
	return self._curSpeedY;
end

--出生动画，在posX出生, 先调用这个！！
function Player:birth(posX)
	self:setPosition(posX, playerPosY);
	--出生动画
	self._showNode:playLabel("stand");
end

function Player:updateNatalTreasure()
	self._showNode:removeFromParent();
	self._showNode = self:initShowNode();
	self:addChild(self._showNode);
end

return Player;














