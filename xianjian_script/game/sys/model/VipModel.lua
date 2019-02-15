--[[
	2017.7.10
	注释一下这个model现在对应的是recharge功能
]]
local VipModel = class("VipModel")

function VipModel:init()

end

--是否已经买了那个vipLevel的礼包
function VipModel:isAlreadyBuyThatVipGift(vipLevel)
	local buyInfoNum = UserExtModel:buyVipGift();
	local array = number.int2BinaryArray(buyInfoNum);
	return array[vipLevel + 1] == 1 and true or false;
end

function VipModel:isGoldEnoughToBuyGift(vipLevel)
	local vipPrice = FuncCommon.getVipPropByKey(vipLevel, "Discountprice");
	local haveGold = UserModel:getGold();
	return haveGold >= vipPrice and true or false;
end

function VipModel:isVipReach(vipLevel)
	local vipCur = UserModel:vip();
	return vipCur >= vipLevel and true or false;
end

function VipModel:getNextVipGiltToBuy()
	for i = 0, 15 do
		local isGoldEnough = self:isGoldEnoughToBuyGift(i);
		local isAlreadyBuy = self:isAlreadyBuyThatVipGift(i);
		local isVipEnough = self:isVipReach(i);

		if self:isVipReach(i) == false then 
			break;
		end 

		if isAlreadyBuy == false and isGoldEnough == true then 
			return i;
		end 
	end
	return -1;
end

return VipModel



