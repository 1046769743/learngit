--[[
	处理战斗验证相关的数据组织
]]
verifyControler = class("verifyControler")

local TYPE_HERO = 1
local TYPE_ROUND = 2
local TYPE_SKILL = 3

local format = string.format

local function encrypt(t)
	return table.concat(t,"_")
end

local function decrypt(str)
	if type(str) ~= "string" then return end

	local t = string.split(str, "_")

	if not t then return end

	local rt = {}

	local tt = nil
	local s = nil
	for i=1,#t do
		tt = string.split(t[i],"|")
		if tt and tt[1] then
			if tonumber(tt[1]) == TYPE_ROUND then
				s = format("回合:%s,阵营:%s,step:%s",tt[2],tt[3],tt[4])
			elseif tonumber(tt[1]) == TYPE_HERO then
				s = format("id:%s,pos:%s,hp:%s,atk:%s,def:%s,magdef:%s,bf:%s,energycost:%s",
					tt[2],tt[3],tt[4],tt[5],tt[6],tt[7],tt[8],tt[9]
				)
			elseif tonumber(tt[1]) == TYPE_SKILL then
				s = format("->id:%s,camp:%s,pos:%s,atk:%s,bf:%s,skill:%s,step:%s",
					tt[2],tt[3],tt[4],tt[5],tt[6],tt[7],tt[8]
				)
			end
		end

		if s then 
			rt[#rt + 1] = s 
			s = nil 
		end
	end

	return rt
end

function verifyControler:ctor(controler)
	self.controler = controler
	self._data = {} -- 存分条数据（纯i,v数组）
	self._str = "" -- 存放加密后的串
	self._change = false -- 是否发生了变化
end

-- 插入一条普通英雄信息
function verifyControler:getOneHeroInfo(hero)
	--type_ id,pos,hp,atk,def,magdef,bf,energycost;
	local str = format("%s|%s|%s|%s|%s|%s|%s|%s|%s",
			TYPE_HERO,
			hero.data.hid,
			hero.data.posIndex,
			hero.data:hp(),
			hero.data:atk(),
			hero.data:def(),
			hero.data:magdef(),
			hero.data:getBuffNums(),
			hero:getEnergyCost()
		)

	return self:insertOneDes(str)
end

-- 插入回合信息
function verifyControler:getOneRoundInfo(round,camp,step)
	local str = format("%s|%s|%s|%s",
		TYPE_ROUND,
		round,
		camp,
		step
	)
	return self:insertOneDes(str)
end

-- 加密
function verifyControler:encrypt()
	if self._change then
		self._change = false
		self._str = encrypt(self._data)
	end
	return self._str
end
-- 解密
function verifyControler:decrypt(str)
	return decrypt(str)
end
-- 插入技能信息
function verifyControler:getOneSkillInfo(hero,skill,step)
	-- if true then return end
	-- type,id,pos,atk,bf,skill,step
	local str = format("%s|%s|%s|%s|%s|%s|%s|%s",
		TYPE_SKILL,
		hero.data.hid,
		hero.camp,
		hero.data.posIndex,
		hero.data:atk(),
		hero.data:getBuffNums(),
		skill.hid,
		step
	)

	return self:insertOneDes(str)
end

-- 获取信息
function verifyControler:getTableData()
	return self._data
end

-- 插入一条信息
function verifyControler:insertOneDes(str)
	--如果已经出结果了就不存了
	if self.controler and self.controler.__gameStep == Fight.gameStep.result then
		-- str = "2|1|1|16"
		return
	end
	-- echo("插入一条数据",str)
	self._change = true
	self._data[#self._data + 1] = str
	return str
end

-- 清空
function verifyControler:deleteMe()
	self._data = nil
end

return verifyControler