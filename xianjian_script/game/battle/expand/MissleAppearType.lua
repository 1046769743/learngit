


MissleAppearType = {}


function MissleAppearType:appear(missle,atkData)

	local xpos =  0 
	local zpos =  0
	local ypos = 0
	if missle.data.sta_appearPos then
		local appear = missle.data:sta_appearPos()
		xpos = numEncrypt:getNum(appear[1]) or 0
		zpos = numEncrypt:getNum(appear[2]) or 0
		ypos = numEncrypt:getNum(appear[3]) or 0
	end


	-- 判断作用对象
	local campArr = missle.data:sta_useWay() == 1 and missle.campArr or missle.toArr
	local appearType = missle.data:sta_appearType() 
	--根据攻击方式确定missle的出现点
	if appearType == Fight.missle_appearType_shoot then
		missle:setPos(missle.carrier.pos.x+xpos*missle.carrier.way,missle.carrier.pos.y+1,missle.carrier.pos.z + zpos)
	
	-- 最前的敌人	
	elseif appearType == Fight.missle_appearType_jin then
		local nearArr = missle.player.campArr[1]
		if #nearArr > 0 then 
			local nearEnemy = nearArr[1]	
			missle:setPos(nearEnemy.pos.x+xpos*nearEnemy.way,nearEnemy.pos.y+1,nearEnemy.pos.z + zpos)
		end
	elseif appearType == Fight.missle_appearType_chooseMid then
		local chooseArr = AttackChooseType:atkChooseByType(missle.player, atkData,nil, self.campArr, self.toArr,missle.currentSkill )
		if not chooseArr or #chooseArr ==0 then
			echo("创建的目标missle没有选中人")
			return
		end
		local firstHero = chooseArr[1]
		local lastHero = chooseArr[#chooseArr]
		xpos = xpos + ( firstHero.pos.x+  lastHero.pos.x ) /2
		ypos = ypos + ( firstHero.pos.y+  lastHero.pos.y ) /2
		missle:setPos(xpos, ypos,zpos)

	elseif appearType == Fight.missle_appearType_middleX then
		local x = campArr[1].pos.x
		if #campArr > 1 then
			x = (campArr[1].pos.x + campArr[#campArr].pos.x)/2
			dis = math.abs(campArr[1].pos.x - campArr[#campArr].pos.x)
		end
		missle:setPos(x,missle.player.pos.y+1,missle.player.pos.z + zpos)


	-- 特定敌人的身前	
	elseif appearType == Fight.missle_appearType_specEnemy then
	
	end

	if ypos ~= 0 then
		missle.pos.y = ypos
	end

end


return MissleAppearType