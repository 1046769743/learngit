
local GarmentServer = class("GarmentServer")


--买个衣服
function GarmentServer:buyGarment(garmentIndex, buyTime, callBack)
	local params = {
		garmentId = garmentIndex,
		buyTime = buyTime,
	};
	dump(params,"发送买衣服请求：")
	Server:sendRequest(params, 
		MethodCode.garment_buy_4801, callBack);
end

--穿衣服
function GarmentServer:onGarment(garmentIndex, callBack)
	-- 注意与服务器的数据交互
	-- GarmentModel.DefaultGarmentId 只有客户端维护，服务端对应空字符串“”
	-- 所以此处要注意转换
	if garmentIndex == GarmentModel.DefaultGarmentId then 
		garmentIndex = nil;
	end 

	local params = {
		garmentId = garmentIndex,
	};

	dump(params,"发送穿衣服请求：")
	Server:sendRequest(params, 
		MethodCode.garment_On_4803, callBack);
end


return GarmentServer




























