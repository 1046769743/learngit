
GameSortControler = class("GameSortControler")

function GameSortControler:ctor(controler)
	self.controler = controler
end



-------------------------------------------------------------------------
-----------------------  深度排序 ---------------------------------------
-------------------------------------------------------------------------

--比较排序
local function sortView( obj1,obj2 )
	--y越小越在里面
	local obj1y = obj1.pos.y 
	local obj2y = obj2.pos.y
	local bbj1x = obj1.pos.x * obj1.way
	local bbj2x = obj2.pos.x * obj2.way
	if obj1y < obj2y then 
		return true
	elseif obj1y == obj2y then

		if obj1.modelType < obj2.modelType then
			return true
		elseif obj1.modelType == obj2.modelType then
			if bbj1x > bbj2x then
				return true
			elseif bbj1x == bbj2x then
				return false
			else
				return false
			end
		else
			return false
		end
		
	else
		return false
	end
end

-- 深度排列
function GameSortControler:sortDepth(initCheck)
	-- if true then
	-- 	return
	-- end
	--3帧排一次 
	-- if self.controler.updateCount % 10 ~= 0 and not initCheck then
	-- 	return
	-- end

	local arr = table.copy(self.controler.depthModelArr)

	table.sort(arr,sortView)

	for i,v in ipairs(arr) do
		v.__zorder = i
		v.myView:zorder(i)
		if v.healthBar then
			v.healthBar:zorder(i + Fight.zorder_health)
		end
		if v.talkBubble then
			v.talkBubble:zorder(i + Fight.zorder_health)
		end
	end
end

-------------------------------------------------------------------------
-----------------------  调整遮挡 X 站位  第三版-------------------------
-------------------------------------------------------------------------
local function sorAtkposAsc( model1,model2 )
	if model1.data.attackDis < model2.data.attackDis then
		return true
	elseif model1.data.attackDis == model2.data.attackDis then
		local hid1 = tonumber(model1.data.hid)
		local hid2 = tonumber(model2.data.hid)
		if hid1 < hid2 then
			return true
		elseif hid1 == hid2 then
			if model1.countId < model2.countId then
				return true
			elseif model1.countId == model2.countId then
				return false
			else
				return false
			end
		else
			return false
		end
	else 
		return false
	end
	return false
end




return GameSortControler