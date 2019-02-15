-- FuncActivityList.lua

FuncActivityList = {}
local activityListData = nil

function FuncActivityList.init(  )

   activityListData= Tool:configRequire("activitylist.ActivityList") 
end 


function FuncActivityList.getDataList()
	local newArr = {}
	local index = 1
	for k,v in pairs(activityListData) do
		newArr[index] = v
		newArr[index].id = tonumber(k)
		index = index  + 1
	end
	local sortFunc = function ( t1,t2 )
        return t1.order < t2.order
    end

    table.sort(newArr,sortFunc)
    -- dump(newArr,"限时活动的列表 ========= ")
	return newArr
end


function FuncActivityList.getDataById( id )
  	if not id then
  		echoError("=====不存在限时活动ID =====默认给第一个数据======",id)
  		return activityListData["1"]
  	else
  		return activityListData[tostring(id)]
  	end 

end









 

return FuncActivityList  
