
SkillChooseExpand = {}
--确定技能
function SkillChooseExpand:sureSkillIndex( logical,camp )
	--回合前让阵营所有人都加一个步长
	local campArr= camp == 1 and  logical.controler.campArr_1 or logical.controler.campArr_2
	for i,v in ipairs(campArr) do
		--必须有技能概率才可以
		if v.data.skillRatioParams then
			v.data.skillRatioParams.current = v.data.skillRatioParams.current + v.data.skillRatioParams.step
		end
		
	end
	self:doChooseSkill_3(logical,camp)
end


--方案5
function SkillChooseExpand:doChooseSkill_3( logical,camp)
	local levelInfo = logical.controler.levelInfo
	--暂定 随机 0-3个的 的权重
	local weight = {10,30,30,30}
	local randomInt = BattleRandomControl.getOneIndexByGroup(weight)
	--额外给小技能的数量 
	local giveSkillNums = randomInt - 1

	local campArr= camp == 1 and  logical.controler.campArr_1 or logical.controler.campArr_2

	local unSkillArr = {}
	for i,v in ipairs(campArr) do
		--如果是普攻状态下的人 才可以被额外概率释放小技能
		if v.nextSkillIndex == Fight.skillIndex_normal then
			--必须配了小技能才可以
			if v.data.skillRatioParams then
				--如果满足释放小技能了
				if v.data.skillRatioParams.current >= v.data.skillRatioParams.need then
					--标记下一个为小技能 
					v.nextSkillIndex = Fight.skillIndex_small
				else
					table.insert(unSkillArr, v)
				end
			end
			
		end
	end


	if giveSkillNums == 0 then
		return 
	end
	local randomArr = BattleRandomControl.randomOneGroupArr(unSkillArr )
	for i=1,giveSkillNums do
		local hero = randomArr[i]
		if not hero then
			return
		end
		--让这个英雄确定为小技能
		hero.nextSkillIndex = Fight.skillIndex_small 
	end


end



