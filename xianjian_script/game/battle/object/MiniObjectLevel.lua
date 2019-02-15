--[[
	Author: lcy
	Date: 2018.07.03
	继承ObjectLevel 重写一些方法不做无用操作提高效率
]]

local partnerSkillShowCfg = require("level.PartnerSkillShow")

MiniObjectLevel = class("MiniObjectLevel", ObjectLevel)

function MiniObjectLevel:ctor(...)
	MiniObjectLevel.super.ctor(self, ...)

	self._partnerShowSkillData = partnerSkillShowCfg[tostring(self.battleInfo.showId)]

	if not self._partnerShowSkillData then
		echoError("找策划,没有此partnerShowSkill Id",self.battleInfo.showId)
		self._partnerShowSkillData = partnerSkillShowCfg["10101"]
	end
	-- 初始化技能展示参数
	self:initPartnerShowSkillInfo()
end

function MiniObjectLevel:initPartnerShowSkillInfo()
	local t = {
		firstRound = nil, -- 起始回合阵营
		process = {}, -- 操作流程
	}

	self.partnerShowSkillInfo = t

	local max = table.nums(self._partnerShowSkillData)
	
	for stepid=1,max do
		local info = self._partnerShowSkillData[tostring(stepid)]
		local tmp = {
			atype = info.atype,
			text = info.text,
		}
		if not t.firstRound then
			t.firstRound = info.firstRound
		end
		if info.atype == Fight.miniProcess_attack then -- 奇侠释放技能
			local step = string.split(info.step, "_")
			tmp.camp = tonumber(step[1])
			tmp.posIndex = tonumber(step[2])
			tmp.skillIndex = tonumber(step[3])
		-- elseif info.atype == 2 then -- 切换回合
		elseif info.atype == 3 then -- 等待时间
			tmp.delay = tonumber(info.step)
		end

		t.process[#t.process + 1] = tmp
	end
end

function MiniObjectLevel:checkEnemy()
	self.campData1 = {}
	local hidArr = {}
	local waveData = self.staticData[tostring(1)]

	self.useNpc = 1 -- 一定是用配置数据

	for i=1,6 do
		if waveData["npc"..i] then
			hidArr[i] = {pos = i,hid = waveData["npc"..i] }
		end
	end

	--判断是否有这个位置的伙伴了
	local checkHasHero = function (campData,pos  )
		for i,v in ipairs(campData) do
			if v.posIndex == pos then
				return true
			end
		end
		return false
	end

	local function getEnemyInfo(hid, pos)
		local enemyInfo  = self:createEnemyInfo(hid,1,pos,false) 
		--暂定第一个人是主角
		enemyInfo.attr.rid = enemyInfo.hid.."_"..pos
		if self.battleInfo.userRid then
			enemyInfo.attr.characterRid = self.battleInfo.userRid
		else
			enemyInfo.attr.characterRid = UserModel:rid()
		end
		--佩戴了多个法宝的 就算是主角
		if  #enemyInfo.attr.treasures >=2  then
			enemyInfo.attr.isCharacter = true
			
		end

		return enemyInfo
	end

	for ii,vv in pairs(hidArr) do
		--先必须保证对应位置没有人
		if not checkHasHero(self.campData1,vv.pos) then
			local enemyInfo = getEnemyInfo(vv.hid, vv.pos)
			if not Fight.isDummy then
				local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
				table.insert(self.cacheObjectHeroArr,objHero )

				table.insert(self.campData1, enemyInfo.attr)
			end
		end
	end

	if not self.waveDatas then
		self.waveDatas = {}
	end

	for i=1,self.maxWaves do
		if not self.waveDatas[i] then
			self.waveDatas[i] = {}
		end

		local waveData = self.staticData[tostring(i)]
		local posRandom = waveData.posRandom or 0
		local ePosition = waveData.elementsEnemyPosition

		-- 添加背景音乐
		if waveData.music then
			self.bgMusic[i] = waveData.music
		end

		for ii=1,6 do
			local hid = waveData["e"..ii]
			if hid then
				local enemyInfo  = self:createEnemyInfo(hid,2,ii,false) 
				--定义rid
				enemyInfo.attr.rid = enemyInfo.hid.."_"..ii .."_"..i

				--佩戴了多个法宝的 就算是主角
				if  #enemyInfo.attr.treasures >=2  then
					enemyInfo.attr.isCharacter = true
				end

				--对应的角色rid 
				enemyInfo.attr.characterRid = self.hid
				self:insertOneWaveDataAttr(i,enemyInfo.attr)
				if not Fight.isDummy then
					local objHero = ObjectHero.new(enemyInfo.hid,enemyInfo.attr)
					table.insert(self.cacheObjectHeroArr,objHero )
				end
			end
		end

		--随机位置
		self:randomPos(self.waveDatas[i],posRandom)
	end
end

return MiniObjectLevel