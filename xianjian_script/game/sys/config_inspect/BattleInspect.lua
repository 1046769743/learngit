--
-- Author: xd
-- Date: 2016-05-27 15:42:58
--
local BaseInspect = require("game.sys.config_inspect.BaseInspect")
local BattleInspect = class("BattleInspect", BaseInspect)

--检查 flash动画 和spine 名称 是否配置错误
--检查 source表里 是否有动作和 spine里面的动作不匹配
--检查法宝id 是否不匹配

-- 检测所有的ID相互索引项是否存在


function BattleInspect:ctor()
	self.configs = {
		-- 关卡配置
		'level.Level',
		'level.Operate',

		-- 怪物配置
		'level.EnemyInfo',
		'level.EnemyTreasure',
		
		-- 战斗技能相关配置
		'battle.Attack',
		'battle.Skill',
		'battle.Buff',
		'battle.SpineEffect',
		

		-- spine特效
		'battle.SpineEffect',
		'level.Source',
		'level.SourceEx',
	}
end

function BattleInspect:getConfigItems()
	return self.configs
end

--判断是否是合法的spine
function BattleInspect:checkSpineName( spineName )
	FuncRes.spine(spineName)
end

--判断 icon
function BattleInspect:checkIconName( icon )
	local iconPath = FuncRes.icon("treasure/"..icon ..".png")
	if not cc.FileUtils:getInstance():isFileExist(iconPath) then 
        self:log("资源:法宝icon不存在 iconPath =" .. iconPath);
    end 
end


--判断是否是spine特效
function BattleInspect:checkIsSpineEff(aniName  )
	return self.config_SpineEffect[aniName]
	-- if self.config_SpineEffect[aniName] then
	-- 	return self.config_SpineEffect[aniName]
	-- end
	-- return false
end


function BattleInspect:checkEffSingle(name,configName, id, key)
	local data 
	local spineName = self:checkIsSpineEff(name) 
	if spineName then
		data = FuncArmature.getSpineArmatureFrameData(spineName.spine, name)
	else
		data = FuncArmature.getFlashArmatureFrameData( name )
	end

	if not data then
		if spineName then
			self:log(string.format("%s表中, id为 %s  中的  %s 字段配置的spine特效  %s 资源不存在",configName,id,key,name))
		else
			self:log(string.format("%s表中, id为 %s  中的  %s 字段配置的flash特效  %s 资源不存在",configName,id,key,name))
		end
	end
end

--判断特效数组
function BattleInspect:checkEffArr(aniArr, configName, id, key  )
	if not aniArr then
		return
	end
	for i,v in ipairs(aniArr) do
		self:checkEffSingle(v.n,configName, id, key)
	end
end

-- 检测关卡部分
function BattleInspect:run_check_Level(  )
	local Level = self.config_Level
	local Operate = self.config_Operate
	local EnemyInfo = self.config_EnemyInfo
	local d1 = 1

	for id,v in pairs(Level) do
		for wave, info in pairs(v) do
			-- 检测第一波中的特殊信息			
			if 	wave == "1" then
				-- 操作检测	
				if not Operate[info.operate] then
					self:log(string.format("level.Level.csv id=%s  wave=%s  operate=%s   在level.Operate.csv中不存在", info.hid, wave, info.operate))
				end
				-- map信息. 当前还没有地图,暂时不检测
			end

			-- npc
			for i=1,5 do
				local enemy = info["npc"..i]
				if enemy then
					if not EnemyInfo[enemy[1].d] then
						self:log(string.format("level.Level.csv id=%s   wave=%s   NpcHid=%s    在level.EnemyInfo.csv中不存在", info.hid, wave, enemy[1].d))
					end
				end
			end
			-- 初始化敌人
			for i=1,20 do
				local enemy = info["e"..i]
				if enemy then
					if not EnemyInfo[enemy[1].d] then
						self:log(string.format("level.Level.csv id=%s   wave=%s    EnemyInfoHid=%s   在level.EnemyInfo.csv中不存在", info.hid, wave,enemy[1].d))
					end
				end
			end
			-- 刷新敌人
			for i=1,5 do
				local enemy = info["point"..i]
				if enemy then
					if not EnemyInfo[tostring(enemy[1].eid)] then
						self:log(string.format("level.Level.csv id=%s   wave=%s   FreshEnemyInfoHid=%s  在level.EnemyInfo.csv中不存在", info.hid, wave, enemy[1].eid))
					end
				end
			end
		end
		
	end
end

-- 检测怪物部分
function BattleInspect:run_check_EnemyInfo(  )
	
	local EnemyInfo = self.config_EnemyInfo
	local EnemyTreasure = self.config_EnemyTreasure

	for hid, enemy in pairs(EnemyInfo) do
		-- 检测spine是否存在
		self:checkSpineName(enemy.spine)		

		-- 目前检测是否含有重复的法宝
		local treaArr = {}
		table.insert(treaArr,enemy.baseTrea)
		for i=1,5 do
			local treaCfg = enemy["trea"..i]
			if treaCfg then
				if table.indexof(treaArr,treaCfg[1]) then
					self:log(string.format("enemyInfo.csv 有重复法宝,EnemyHid=%s    TreasureHid=%s",hid,treaCfg[1]))
				else
					table.insert(treaArr,treaCfg[1])
					if not EnemyTreasure[treaCfg[1]] then
						self:log(string.format("EnemyTreasure.csv 有没有配置法宝,EnemyHid=%s    TreasureHid=%s",hid,treaCfg[1]))
					end
				end
			end
		end
		treaArr = nil
	end
end

function BattleInspect:run_check_EnemyTreasure(  )
	local EnemyTreasure = self.config_EnemyTreasure 
	local Source = self.config_Source
	local Skill = self.config_Skill
	local Buff = self.config_Buff

	for hid, treasure in pairs(EnemyTreasure) do
		-- 检测资源索引
		if not level.Source then
			self:log(string.format("EnemyTreasure中没有配置courceId TreasureHid=%s ",treasure.hid))
		else
			if not Source[level.Source] then
				self:log(string.format("Source.csv 中没有配置courceId SourceHid=%s ",level.Source))
			end
		end

		-- 法宝特写资源
		if treasure.treaImgTime then
			if not treasure.icon then
				self:log(string.format("EnemyTreasure.csv 中没有配置icon TreasureHid=%s ",treasure.hid))
			else
				self:checkIconName(treasure.icon)
			end
		end
		-- 登场技能
		if treasure.inSkill then
			for i=1,#treasure.inSkill do
				if not Skill[treasure.inSkill[i]] then
					self:log(string.format("Skill.csv 中没有配置技能 SkillHid=%s ",treasure.inSkill[i]))
				end
			end
		end
		-- 常态技能,这个技能是必带的
		if treasure.skill then
			if not Skill[treasure.skill] then
				self:log(string.format("Skill.csv 中没有配置技能 SkillHid=%s ",treasure.skill))
			end
		end
		-- 光环
		if treasure.aura then
			for i=1,#treasure.aura do
				if not Buff[treasure.aura[i]] then
					self:log(string.format("Buff.csv 中没有配置光环 BuffHid=%s ",treasure.aura[i]))
				end
			end
		end
		
	end
end

-- 主角法宝
function BattleInspect:run_check_Treasure()
	local TreasureC = self.config_Treasure
	for hid, treasure in pairs(TreasureC) do
		-- 法宝特写资源
		if treasure.isSuyan ~= 1 then
			if not treasure.icon then
				self:log(string.format("Treasure.csv 中没有配置icon TreasureHid=%s ",treasure.hid))
			else
				self:checkIconName(treasure.icon)
			end
		end
		-- 如果是瞬时方便需要配置咏唱时间
		if treasure.label1 == 3 then
			if not treasure.singTime then
				self:log(string.format("Treasure.csv 中没有配置咏唱时间 TreasureHid=%s ",treasure.hid))
			end
		end	

	end
end

-- 检测技能部分
function BattleInspect:run_check_Skill(  )
	local SkillC = self.config_Skill
	local Missle = self.config_Missle
	local Attack = self.config_Attack
	local EnemyInfo = self.config_EnemyInfo

	local atkInfo = nil

	for hid, skill in pairs(SkillC) do
		-- 特效数组 aniArr
		self:checkEffArr(skill.aniArr,"Skill",hid,"aniArr")
		-- 攻击包 attack: 
		for i=1,3 do
			local atkInfoArr = skill["atkInfoA"..i]
			if atkInfoArr then
				for m=1,#atkInfoArr do
					atkInfo = atkInfoArr[m]				
					if not Attack[atkInfo.at] then
						self:log(string.format("skill表中配置的 skillHid=%s,中  atkInfoAAAA%d  中的 attackHid%s 没有配置",hid,i,atkInfo.at))
					end
				end
			end
			atkInfoArr = skill["atkInfoB"..i]
			if atkInfoArr then
				for m=1,#atkInfoArr do
					atkInfo = atkInfoArr[m]
					if not Attack[atkInfo.at] then
						self:log(string.format("skill表中配置的 skillHid=%s,中  atkInfoBBBB%d  中的 attackHid%s 没有配置",hid,i,atkInfo.at))
					end
					
				end
			end
		end
	
		-- summon:
		for i=1,3 do
			local atkInfo = skill["summonA"..i]
			if atkInfo then
				if not EnemyInfo[atkInfo[2]] then
					self:log(string.format("skill表中配置的 skillHid=%s,中  summonAAAAA%d  中的 EnemyInfoHid%s 没有配置",hid,i,atkInfo[2]))
				end
			end

			atkInfo = skill["summonB"..i]
			if atkInfo then
				if not EnemyInfo[atkInfo[2]] then
					self:log(string.format("skill表中配置的 skillHid=%s,中  summonBBBB%d  中的 EnemyInfoHid%s 没有配置",hid,i,atkInfo[2]))
				end
			end
			
		end
		-- alert
		if skill.alert then
			self:checkEffSingle(skill.alert[1],"skill",hid,"alert")
		end
	end
end


function BattleInspect:run_check_Missle(  )
	local MissleC = self.config_Missle
	local Attack = self.config_Attack
	for hid, missle in pairs(MissleC)  do
		-- missle视图
		if missle.armature then 
			self:checkEffSingle(missle.armature,"Missle",hid,"armature")
		else
			self:log(string.format("missle表中配置的 missleHid%s, 没有配置 armature 字段",hid))
		end

		--运动方式检测
		if missle.moveType == 2 then
			if not missle.speed then
				self:log("missle 没有配置速度",hid)
			end
		elseif missle.moveType == 6 then
			if not missle.nFrame then
				self:log("missle 没有配置运动多少帧",hid)
			end
		end

		-- 扩散
		if missle.diffusion then
			if self.difSpeed then
				self:log("missle 没有配置扩散速度",hid)
			end
		end

		-- 每帧都检测的attackid
		if missle.attackId then
			if not Attack[missle.attackId] then
				self:log(string.format("missle表中配置的 missleHid%s,   attackId%s  中的 attackId没有配置",hid,missle.attackId))
			end
		end

		-- 固定帧检测的攻击
		if missle.attackInfos then
			for i=1,#missle.attackInfos do
				local info = missle.attackInfos[i]
				if not Attack[info.at] then
					self:log(string.format("missle表中配置的 missleHid%s,   attackInfos%s  中的 attackId没有配置",hid,info.at))
				end
			end
		end
	end
end
function BattleInspect:run_check_Attack(  )
	local AttackC = self.config_Attack
	local MissleC = self.config_Missle
	for hid, attack in pairs(AttackC) do

		if attack.addMissle then

			for i,v in ipairs(attack.addMissle ) do
				if not MissleC[v.id] then
					self:log(string.format("Attack引起的missle, attackHid=%s   子弹的hid为 missleHid=%s",v.id))
				end
			end

			
		end

		if not attack.useWay then
			self:log("Attack 没有配置作用对象, useWay")
		end

		if not attack.chooseType then
			self:log("Attack 没有配置选中目标的方式 chooseType")
		end

		if not attack.attackNums then
			self:log("Attack 没有配置选中目标的方式 attackNums")
		end

		if not attack.area then
			if not attack.must then
				self:log("Attack 没有配置检测区域",hid)
			end
		end

		-- 攻击包的特效
		if attack.aniArr then
			self:checkEffArr(attack.aniArr,"Attack",hid,"aniArr")
		end	
	end
end
function BattleInspect:run_check_Buff(  )
	local BuffC = self.config_Buff
	for hid, buff in pairs(BuffC) do
		if buff.aniArr then
			self:checkEffArr(buff.aniArr,"Buff",hid,"aniArr")
		end

	end
end


return BattleInspect