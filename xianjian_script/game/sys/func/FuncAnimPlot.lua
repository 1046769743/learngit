
FuncAnimPlot = {}
local animPlotCfg = nil
local plotID = 1



--[[
动画编辑器的配置文件
]]
function FuncAnimPlot.init(  )

   animPlotCfg= Tool:configRequire("plot.AnimBoneNew") 
end 



function FuncAnimPlot.setPlotID( id )
  FuncAnimPlot.plotID = id
end

--[[
获取当前的plotID
]]  
function FuncAnimPlot.getPlotID( )
  return plotID
end  


--[[
获取id对应的行数据
]]
function FuncAnimPlot.getRowData( animId )
	-- dump(animPlotCfg)

	-- echo(FuncAnimPlot.plotID)
	-- dump(animPlotCfg[FuncAnimPlot.plotID])

	if animPlotCfg then
		local data = animPlotCfg[tostring(animId)]
		if not data then
			echoError("没有找到animBone对应plotId数据,",FuncAnimPlot.plotID)
		end
		return data
	end
	return nil
end



--[[
获取spine对应的所有事件
]]
function FuncAnimPlot.getAllEvents(animId  )

	local rowData = FuncAnimPlot.getRowData(animId )
	-- echo("rowDatarowDatarowDatarowDatarowDatarowDatarowData")
	-- dump(rowData)
	-- echo("rowDatarowDatarowDatarowDatarowDatarowDatarowData")
	
	
	if rowData then
		local name = rowData["order"]
		local eventCfg = Tool:configRequire("viewConfig.spineEvent."..name.."Event")
		if eventCfg then
			--return eventCfg["animation"]
			return eventCfg
		end
	end
	return nil
end




--[[
source中对应的配置，可以读取到action方法
]]
function FuncAnimPlot.getSourceDataById(sourceId)
	return  FuncTreasure.getSourceDataById(sourceId)
end


 

return FuncAnimPlot  
