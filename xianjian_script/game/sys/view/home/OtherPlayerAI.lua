--guan
--2016.7.10

OtherPlayerAI = class("OtherPlayerAI");

local Area1And2Boundary = 600;
local Area2And3Boundary = 2320;

local maxWidth = 3150;
local leftBondary = 600

local yPos1 = 200;
local yPos2 = 170;
local yPos3 = 134;
local yPos4 = 94;

local actionPercent = {
	50, 60, 30, 30, 50, 100
};


local AreaXpos = {
	[1] = {Left = 600, Right = 600},
	[4] = {Left = 600, Right = 600},

	[2] = {Left = 600, Right = 2320},
	[5] = {Left = 600, Right = 2320},

	[3] = {Left = 2320, Right = maxWidth},
	[6] = {Left = 2320, Right = maxWidth},
};

local AreaYpos = {
	[1] = {Up = -(640 - yPos1), Down = -(640 - yPos2)},
	[2] = {Up = -(640 - yPos1), Down = -(640 - yPos2)},
	[3] = {Up = -(640 - yPos1), Down = -(640 - yPos2)},

	[4] = {Up = -(640 - yPos3), Down = -(640 - yPos4)},
	[5] = {Up = -(640 - yPos3), Down = -(640 - yPos4)},
	[6] = {Up = -(640 - yPos3), Down = -(640 - yPos4)},
};

--todo 读表 npcPos表
local npcPos = {
	[1] = {x = 2050, y = -(640 - 280)},
	[2] = {x = 1470, y = -(640 - 280)},
	[3] = {x = 670, y = -(640 - 280)},
	[4] = {x = 800, y = -(640 - 280)},
	[5] = {x = 2375, y = -(640 - 280)},
};
local npcPosGuild = {
	[1] = {x = 2050, y = -(640 - 170)},
	[2] = {x = 1470, y = -(640 - 170)},
	[3] = {x = 940, y = -(640 - 170)},
	[4] = {x = 1000, y = -(640 - 170)},
	[5] = {x = 2200, y = -(640 - 170)},
};

ActionType = {
	JustStay = 1, --停留
	GoToAndStay = 2, --走过去并且停在那
};


--6个区域的概率
local AreaPercent = {
	8, 60, 12, 4, 12, 4 
};

function OtherPlayerAI:ctor(player)
	self._area = self:getBirthArea();
	self._player = player;
end

--随机个出生区域6个区域
function OtherPlayerAI:getBirthArea()
	function areaPercentSum()
		local ret = {};
		for k, v in pairs(AreaPercent) do
			if k == 1 then 
				ret[k] = v;
			else 
				ret[k] = ret[k - 1] + v;
			end
		end
		return ret;
	end

	local randomNum = math.random(1, 100);
	-- echo("--randomNum--", tostring(randomNum));
	local areaPercetArray = areaPercentSum();

	for k, v in pairs(areaPercetArray) do
		if randomNum <= v then 
			-- echo("--区域--", tostring(k))
			return k;
		end 
	end

	echo("warning！！！--OtherPlayerAI:getBirthArea 概率配错了--");

	return 6;
end

function OtherPlayerAI:getBirthPos()
	function getPosY()
		local up, down = AreaYpos[self._area].Up, AreaYpos[self._area].Down;
		local randomNum = math.random(1, 100);
		return up - (up - down) * randomNum / 100; 
	end

	function getPosX()
		local left, right = AreaXpos[self._area].Left, AreaXpos[self._area].Right;
		local randomNum = math.random(1, 100);
		return left + (right - left) * randomNum / 100; 
	end

	local birthArea = self:getBirthArea();
	
	local posY = getPosY();
	local posx = getPosX();
	-- echo("");
	-- echo("-- self._area--", tostring(self._area));
	-- echo("-- posY--", tostring(posY));
	-- echo("-- posx--", tostring(posx));

	return {x = posx, y = posY};
end


-- local npcPos = {
-- 	[1] = {x = 2050, y = -(640 - 280)},
-- 	[2] = {x = 1470, y = -(640 - 280)},
-- 	[3] = {x = 670, y = -(640 - 280)},
-- 	[4] = {x = 160, y = -(640 - 280)},
-- };
function OtherPlayerAI:getNextAction()
	local actionType = nil ;
	local isStayForever = false;
	local posX = 0;
	local poxY = 0;
	local stayTime = 0;
	
	local StayPercentNum = actionPercent[self._area];
	local randomNum = math.random(1, 100);

	if randomNum <= StayPercentNum then 
		isStayForever = true
	end 
 
	if math.random(1, 4) <= 2 then 
		--跑
		actionType = ActionType.GoToAndStay;
		local time = math.random(3, 8);

		--90%概率跑到npc附近
		if math.random(1, 10) <= 4 then 
			local moveDistance = self._player:getMoveSpeed() * time;
			if math.random(1, 2) == 1 then 
				moveDistance = -moveDistance;
			end 
			posX = self._player:getPositionX() + moveDistance;
			poxY = -( 640 - math.random(120, 250) );
			
			if posX < leftBondary or posX > maxWidth then 
				posX = self._player:getPositionX() - moveDistance;
			end 
		else 
			--从npc位置中取一个
			local npcTab = npcPos
			local Windownames = WindowControler:checkCurrentViewName( "GuildMainView" )
			if Windownames then
				npcTab = npcPosGuild
			end
			
			local npcIndex = math.random(1, 5);
			posX = npcTab[npcIndex].x + self:getRandomOffsetX();
			poxY = -(640 - 250 + self:getRandomOffsetY() );
		end 
		stayTime = math.random(6, 10);
	else
		--停下 
		actionType = ActionType.JustStay;
		stayTime = math.random(6, 10);
	end 
	return actionType, stayTime, posX, poxY;

end

function OtherPlayerAI:getRandomOffsetY()
	return math.random(0, 80);
end

function OtherPlayerAI:getRandomOffsetX()
	local offsetX = math.random(0, 80)
	if math.random(1, 2) == 1 then 
		return offsetX
	else 
		return -offsetX
	end 
end

return OtherPlayerAI;






