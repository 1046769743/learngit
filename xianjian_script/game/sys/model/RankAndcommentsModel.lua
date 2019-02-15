-- RankAndcommentsModel   评论和排行
local RankAndcommentsModel = class("RankAndcommentsModel", BaseModel);

function RankAndcommentsModel:init(data)
    RankAndcommentsModel.super.init(self, data)

end

-- function RankAndcommentsModel:updateData(data)
  
-- end


function RankAndcommentsModel:setAllData(data)
	-- dump(data,"=====设置评论的数据======")
	self.allRankInfo = {} ---排行的数据
    self.allCommentsInfo = {} --- 评论的数据
    self.playInfoMinAbilityData = nil
    self.playInfoLeastShotData = nil

	if data == nil then
		return 
	end
	
	

	self.levelId = data.levelId
	local comments = data.comments
	if comments ~= nil then
		for i=1,#comments do
			self.allCommentsInfo[i] = comments[i] --聊天的内容
		end
	end
	local rankInfo = data.rankInfo
	if  rankInfo ~= nil then
		local minAbility = rankInfo.minAbility --最小战力的数据
		if minAbility ~= nil then 
			self.allRankInfo[1] = {}
			local partnerInfo = minAbility.partnerInfo
			if partnerInfo ~= nil then
				for k,v in pairs(partnerInfo) do
					if k == "wave_1" then
						-- local chardata = v
						-- if k == "1" then ---主角数据
						-- for key,valuer in pairs(v) do
						-- 	local num  = minAbility.num
						-- 	self:setDataTable(self.allRankInfo[1],chardata,num)
						-- end
						for key,valuer in pairs(v) do
							local num  = minAbility.num
							local chardata = valuer
							self:setDataTable(self.allRankInfo[1],chardata,num)
						end
						local newArr = {
							id = "0"
						}
						table.insert(self.allRankInfo[1],newArr)
					elseif k == "wave_2" then
						for key,valuer in pairs(v) do
							local num  = minAbility.num
							local chardata = valuer
							self:setDataTable(self.allRankInfo[1],chardata,num)
						end
						local newArr = {
							id = "0"
						}
						table.insert(self.allRankInfo[1],newArr)

					else
						local chardata = v
						local num  = minAbility.num
						if v.id == "1"  then
							v.num  = num
							self.playInfoMinAbilityData = v
						end
						self:setDataTable(self.allRankInfo[1],chardata,num)
					end
				end
			end
		end

		local leastShot = rankInfo.leastShot --最少出手的数据
		if leastShot ~= nil then 
			self.allRankInfo[2] = {}
			local partnerInfo = leastShot.partnerInfo
			if partnerInfo ~= nil then
				for k,v in pairs(partnerInfo) do

					if k == "wave_1" then
						local chardata = v
						for key,valuer in pairs(v) do
							local num  = leastShot.num or 0
							local chardata = valuer
							self:setDataTable(self.allRankInfo[2],chardata,num)
						end
						local newArr = {
							id = "0"
						}
						table.insert(self.allRankInfo[2],newArr)
					elseif k == "wave_2" then
						for key,valuer in pairs(v) do
							local num  = leastShot.num or 0
							local chardata = valuer
							self:setDataTable(self.allRankInfo[2],chardata,num)
						end
						local newArr = {
							id = "0"
						}
						table.insert(self.allRankInfo[2],newArr)

					else
						local num  = leastShot.num or 0
						local chardata = v
						if chardata.id == "1"  then
							chardata.num  = num
							self.playInfoLeastShotData = v
						end
						self:setDataTable(self.allRankInfo[2],chardata,num)
					end

					-- local chardata = v
					-- if k == "1" then ---主角数据
					-- 	chardata.num  = leastShot.num
					-- 	table.insert(self.allRankInfo[2],1,chardata)
					-- else
					-- 	table.insert(self.allRankInfo[2],chardata)
					-- end
				end
			end
		end
	end

	-- dump(self.allRankInfo,"======排行的数据======")
	-- dump(self.allCommentsInfo,"======评论的数据======")
end

function RankAndcommentsModel:getPlayInfoLeastShotData()
	return self.playInfoLeastShotData
end
function RankAndcommentsModel:getPlayInfoMinAbilityData()
	return self.playInfoMinAbilityData
end

function RankAndcommentsModel:setDataTable(newTable,oldData,num)
	local chardata = oldData
	if chardata.id == "1" then ---主角数据
		if chardata.notInFormationFlag == nil or chardata.notInFormationFlag ==  0 then  --上阵
			chardata.num  = num
			table.insert(newTable,chardata)
		end
	else
		table.insert(newTable,chardata)
	end
end

--获取排行所有数据
function RankAndcommentsModel:getAllRankInfoData()
	local allRankInfo = self.allRankInfo
	return allRankInfo or {}
end

--获取评论所有数据
function RankAndcommentsModel:getAllCommentsInfoData()
	local allCommentsInfo = self.allCommentsInfo
	return allCommentsInfo or {}
end



--[[
  	"elite_20101" = 1
	"elite_20102" = 1

]]
function RankAndcommentsModel:getCommentTimes()
	local countData =  UserModel:commentTimes()
	local datalist = {}  --评论的次数
	dump(countData,"分解后的数据 ==111===")
	if countData ~= nil and table.length(countData) ~= 0 then
		for k,v in pairs(countData) do
			local arrData = string.split(k,"_")
			if  datalist[arrData[1]] ~= nil then
				-- datalist[arrData[1]][arrData[2]] = {}
				if arrData[3] == nil then
					datalist[arrData[1]][arrData[2]] = v	
				else
					if datalist[arrData[1]][arrData[2]] ~= nil then
						datalist[arrData[1]][arrData[2]][arrData[3]] = v
					else
						datalist[arrData[1]][arrData[2]] = {}
						datalist[arrData[1]][arrData[2]][arrData[3]] = v
					end
				end
			else
				datalist[arrData[1]] = {}
				if arrData[3] == nil then 
					datalist[arrData[1]][arrData[2]] = v
				else
					datalist[arrData[1]][arrData[2]] = {}
					datalist[arrData[1]][arrData[2]][arrData[3]] = v
				end
			end
		end
	end
	-- dump(datalist,"评论的次数的数据=====")
	return datalist
end

--根据系统名，和关卡ID获取评论次数
function RankAndcommentsModel:getNumBySystemAndDiffID(systemName,diffID,orid)
	local dataList = self:getCommentTimes()
	local num = 0
	-- echo("=======diffID=========",diffID,orid)
	if table.length(dataList) ~= 0 then
		local sys = dataList[tostring(systemName)]
		if sys ~= nil then
			local oridtable = sys[tostring(diffID)]
			if oridtable ~= nil then
				if type(oridtable) == "table" then
					num = oridtable[tostring(orid)]
					if num == nil then
						num = 0
					end
				else
					num = oridtable
				end
				return num
			end
		end
	end
	return 0
end

function RankAndcommentsModel:updateComments(commentData,removecomment)
	if self.allCommentsInfo == nil or #self.allCommentsInfo == 0  then
		self.allCommentsInfo = {}
		table.insert(self.allCommentsInfo,commentData)
	else
		if removecomment ~= nil and removecomment ~= false then
			for i=1,#self.allCommentsInfo do
				for k,v in pairs(removecomment) do
					if self.allCommentsInfo[i].id == v then
						self.allCommentsInfo[i] = commentData
					end
				end
			end
		else
			table.insert(self.allCommentsInfo, commentData)
		end
	end

end

--刷新点赞和点踩数据
function RankAndcommentsModel:setPraiseAndStopOnData(_type,data,num)
	if self.allCommentsInfo == nil then
		return 
	end
	if _type ==  FuncRankAndcomments.COMMENTTYPE.praise then
		for k,v in pairs(self.allCommentsInfo) do
			if v.id == data.id then
				v.likeCount = v.likeCount + num
				v.doILike = data.doILike
			end
		end
	elseif _type == FuncRankAndcomments.COMMENTTYPE.stepOn then
		for k,v in pairs(self.allCommentsInfo) do
			if v.id == data.id then
				v.dissCount = v.dissCount + num
				v.doIDiss = data.doIDiss
			end
		end	
	end

end

--热评排序
function RankAndcommentsModel:commentsBuzzSort(commentData)
	if #commentData == 0 then
		return commentData
	end 

	local partner_table_sort = function (a,b)
		local iask = false
		if a.likeCount > b.likeCount then
			iask = true
		elseif a.likeCount == b.likeCount then
			if a.time < b.time then
				iask = true
			end
		end
		return iask
    end
    table.sort(commentData,partner_table_sort)
    -- for i=1,#commentData do
    -- 	if i <= 3 then
    -- 		commentData[i].isbuzz = true
    -- 	end
    -- end
    -- dump(commentData,"000000000======")
    local newdata = {}
    for i=1,#commentData do
    	if commentData[i].hot ~= nil and commentData[i].hot == 1 then
    		table.insert(newdata,i,commentData[i])
    	else
    		table.insert(newdata,commentData[i])
    	end
    end

    return newdata

end

function RankAndcommentsModel:sortQuileAndID(arrTab)
	local partner_table_sort = function (a,b)
		local iask = false
		if a.combineColor < b.combineColor then
			iask = true
		elseif a.combineColor == b.combineColor then
			if a.rank < b.rank then
				iask = true
			end
		end
		return iask
    end
    table.sort(arrTab,partner_table_sort)
    return arrTab

end

return RankAndcommentsModel;





















