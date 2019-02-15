
FuncTrail = FuncTrail or {}

local trial = nil;
local trialResources = nil;
local  trialnew = nil
local statetype = {
	UNLOCK = 1,  --解封
	CHALLENGE = 2,  --挑战
}


FuncTrail.Angle = {
	[1] = 0,
	[2] = 72,
	[3] = 72*2,
	[4] = 72*3,
	[5] = 72*4,
}

FuncTrail.IndexStr  = {
	[1] = "普通",
	[2] = "困难",
	[3] = "大师",
	[4] = "宗师",
	[5] = "巅峰",
}
FuncTrail.TrailIiemId = "3011"

function FuncTrail.init()
	trialResources = Tool:configRequire("trial.TrialResources");
	trialnew = Tool:configRequire("trial.Trial");
end

--每个试炼的挑战次数
function FuncTrail.getallchallengCount()
	local count = {}
	for k,v in pairs(trialResources) do
		count[tonumber(k)] = FuncTrail.getSumChallengNum()
	end
	return count
end



--根据试炼类型  获得试炼相关的数据列表
function FuncTrail.getTrialDataById(trial_type)
	local tailadata = {}
	for k,v in pairs(trialnew) do
		if  tonumber(v.trialType) == tonumber(trial_type) then
			v.id = k
			tailadata[v.difficulty] = v
		end
	end
	return tailadata
end

--通过试炼ID和state 类型来获取关卡ID
function FuncTrail.getLevelIdByTrialId(trialId,state)
	if trialnew[tostring(trialId)] ==  nil then
		echoError("试炼关卡Id  不存在   trial  ID is ======",trialId)
		return nil
	end
	if tonumber(state) == statetype.UNLOCK then
		local levelid = trialnew[tostring(trialId)].level1
		return levelid
	elseif tonumber(state) == statetype.CHALLENGE then
		local levelid = trialnew[tostring(trialId)].level2
		return levelid
	end
end
-- 获取试炼战斗界面显示的掉落物品、击杀小怪奖励、击杀boss奖励
function FuncTrail.getRewardByTrialId(trialId)
	local d = trialnew[tostring(trialId)]
	if not d then
		echoError ("试炼关卡Id不存在",trialId)
		d = next(trialnew)
	end
	return d.rewardType,d.rewardmonster,d.rewardboss
end
-- 获取试炼最大的掉落数
function FuncTrail.getMaxRewardByTrialId(trialId)
	local d = trialnew[tostring(trialId)]
	if not d then
		echoError ("试炼关卡Id不存在",trialId)
		d = next(trialnew)
	end
	local tmpArr = string.split(d.showReward[1],",")
	local max = tonumber(tmpArr[#tmpArr])
	return max
end
-- 获取试炼基础奖励
function FuncTrail.getBaseRewardByTrialId(trialId)
	local d = trialnew[tostring(trialId)]
	if not d then
		echoError ("试炼关卡Id不存在",trialId)
		d = next(trialnew)
	end
	local tmpArr = string.split(d.rewardbase[1],",")
	local base = tonumber(tmpArr[#tmpArr])
	return base
end
function FuncTrail.getTrailData(id, key)
	local value = trialnew[tostring(id)][tostring(key)];
	if value == nil then
		echo("getTrailData id " .. tostring(id) .. 
			" " .. tostring(key) .. "is nil"); 
		return nil;
	else 
		return value;
	end 
end
function FuncTrail.byIdgetdata( TrailID )
	return trialnew[tostring(TrailID)]
end
function FuncTrail.getServerTime(TrailID,sweeptime)
	local Traildata = trialnew[tostring(TrailID)]
	local day = Traildata.freeCondition
	local sumtime = (tonumber(day) - 1) *24 *3600 + 4* 3600
	-- echo("==========1111111111==============",day,sumtime)
	return sweeptime + sumtime
end
function FuncTrail.newgetTrailData(id,key)
	local value = trialnew[tostring(id)][tostring(key)];
	if value == nil then
		echo("getTrailData id " .. tostring(id) ..  
			" " .. tostring(key) .. "is nil"); 
		return nil;
	else 
		return value;
	end 
end
function FuncTrail.gettrialResourcesName(type)
	-- local data  = {
	-- 	[1] = "山神",
	-- 	[2] = "火神",
	-- 	[3] = "盗宝者",
	-- }
	local data = trialResources[tostring(type)].name
	
	return data
end
----退出的总时间 --匹配推送其他玩家加入退出
function FuncTrail.clossOnTime()
	return 5
end
----匹配loading的总时间 
function FuncTrail.PiPeiSumTime()
	return 15
end
function FuncTrail.getTrialResourcesData(id, key)
	local value = trialResources[tostring(id)][tostring(key)];

	if value == nil then
		echo("getTrialResourcesData id " .. tostring(id) .. " " .. tostring(key) .. "is nil"); 
		return nil;
	else 
		return value;
	end 
end
function FuncTrail.getTrialResourceIsOpen(typeid)
	local value = trialResources[tostring(typeid)]["openCycle"];
	return value
end
function FuncTrail.OpenSysten()
	local data = FuncTrail.getTrialResourceIsOpen(1)
	local newsourdata =  string.split(data[1], ",")
	return true
end

function FuncTrail.gettrialResources()
	return trialResources
end

----默认狭义值   1 
function FuncTrail.getXiaYivalue()
	return 1
end

function FuncTrail.getTotalTimes(id)
	return FuncTrail.getTrailData(id, "totalTimes")
end
function FuncTrail.getTrailIDbyReward(index,Trailid,_file)
	local reward = {}
	if Trailid ~= nil then
		for k,v in pairs(trialnew) do
			local id = tonumber(k)
			if tonumber(v.trialType) == index then
				if _file then
					if tonumber(Trailid) == id then
						local trialReward = v.trialReward
						for i=1,#trialReward do
							local rewards = string.split(trialReward[i], ",")
							if reward[rewards[2]] == nil then
								reward[rewards[2]] = trialReward[i]
							else
								local new_rewards = string.split(reward[rewards[2]], ",")
								local nbumber = rewards[3]+new_rewards[3]
								local _rewards = rewards[1]..","..rewards[2]..","..nbumber
								reward[rewards[2]] = _rewards
							end
						end
					end
				else
					if tonumber(Trailid) >= id then
						local trialReward = v.trialReward
						for i=1,#trialReward do
							local rewards = string.split(trialReward[i], ",")
							if reward[rewards[2]] == nil then
								reward[rewards[2]] = trialReward[i]
							else
								local new_rewards = string.split(reward[rewards[2]], ",")
								local nbumber = rewards[3]+new_rewards[3]
								local _rewards = rewards[1]..","..rewards[2]..","..nbumber
								reward[rewards[2]] = _rewards
							end
						end
					end
				end
			end
		end
		local index = 1
		local newtable = {}
		for k,v in pairs(reward) do
			newtable[index] = v
			index = index + 1
		end
		return newtable
	else
		echo("============不存在该试炼ID=================")
		return reward
	end

end

--获取总的挑战次数
function FuncTrail.getSumChallengNum()
	return FuncDataSetting.getOriginalData("TrialChallengeNum")
end


--获取多人挑战的道具令牌ID
function FuncTrail.getManyPeopleChallengID()
	return FuncDataSetting.getOriginalData("TrialMatchCostItemId")
end


function FuncTrail.getAlltrialData()
	return  trialnew
end

--试炼助战侠义值奖励获得次数
function FuncTrail.getRescueRewardLimit()
	return  FuncDataSetting.getOriginalData("TrialRescueRewardLimit")
end

function FuncTrail.getRewardById(trialId)
	-- trialReward
	local data = trialnew[tostring(trialId)]
	local newData = {}
	-- local trialReward = data.reward3
	-- local newdata = FuncTrail.paixudata(trialReward)
	-- local rewardbase = data.rewardbase
	-- local rewardmonster = data.rewardmonster
	local newData = data.showReward

	-- for i=1,#rewardbase do
	-- 	table.insert(newData,rewardbase[i])
	-- end
	-- for i=1,#rewardmonster do
	-- 	table.insert(newData,rewardmonster[i])
	-- end
	-- for i=1,#rewardboss do
	-- 	table.insert(newData,rewardboss[i])
	-- end
	if not newData  then
		echo("======试炼难度ID====trialId=====",trialId)
	end
	
	newData = FuncTrail.paixudata(newData)
	return newData
end


function FuncTrail.paixudata(data)
	local newreward = {}
	local index = 1
	for i=1,#data do
		local rew  = string.split(data[i], ",")
		local ishave = false
		for _x = 1,#newreward do
			if newreward[_x].types == rew[1] then
				newreward[_x].number = newreward[_x].number + (rew[3] or rew[2] )
				ishave = true
			end
		end
		if not ishave then
			local quility = 1
			local newData = {}
			if rew[1] == FuncDataResource.RES_TYPE.ITEM then
				local itemdata = FuncItem.getItemData(rew[2])
				if itemdata ~= nil then
					quility =itemdata.quality
				end 
				newData = {
					id = rew[2],
					number = rew[3],
					types = rew[1],
					quility = quility,
				}
			else
				quility = FuncDataResource.getQualityById( rew[1],resId )
				newData = {
					id = rew[1],
					number = rew[2],
					types = rew[1],
					quility = quility,
				}
			end
			newreward[index] = newData
			index = index + 1
		end
	end

	local function trial_sort( a,b )
		if a.quility > b.quility then
	        return true
	    else  --if a.quility < b.quility  then
	        return false
	    end
	end

	table.sort(newreward,trial_sort)

	local zuihoudata = {}
	for i=1,#newreward do
		if newreward[i].types == FuncDataResource.RES_TYPE.ITEM then
			local string = newreward[i].types..","..newreward[i].id..","..newreward[i].number
			zuihoudata[i] = string
		else
			local string = newreward[i].types..","..newreward[i].number
			zuihoudata[i] = string
		end
	end
	return zuihoudata
end








