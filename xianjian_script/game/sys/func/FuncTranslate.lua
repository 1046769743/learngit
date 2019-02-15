
FuncTranslate = FuncTranslate or {}

local translateData = nil
local PlotTranslate = nil
local errorTranslate = nil
local translateLuaData = nil

--把需要加载的translate 模块话封装
--以后如果有新的名模块进来  一定要在这里添加对应的文件名称
local translateModels = {
	"Translate","TranslateElite","TranslateItem","Translate_lua","TranslatePartner",
	"TranslateQuest","TranslateStory","TranslateTreasure","TranslateChar","TranslateActivity","TranslateBattle",
	"TranslateLoading","TranslateTeaminfo","TranslateGarment","TranslateSign","TranslateTalk","TranslateLogin",
	"TranslatePartnerSkin","TranslateDelegate","TranslateLove","TranslateCimelia","TranslateShop","TranslateTower",
	"TranslateGroup","TranslateFood","TranslateShareBoss","TranslateFivesoul","TranslateMission","TranslateHead",
	"TranslateWonderLand","TranslateCrossPeak","TranslateTag","TranslateGuildBoss","TranslateEndless","TranslateTitle",
	"TranslateTrail","TranslateDanmu","TranslateElitQuestion", "TranslatePvp","TranslateCrossPeakBox","TranslateMemory",
	"TranslateRing","TranslateLottery","TranslateChallenge","TranslateAddition","TranslateMonthCard",
	"TranslateRankList","TranslateHandbook","TranslateTeam","TranslateBattleBubble","TranslateActivityList","TranslateEnemy",
	"TranslateBiography","TranslateGame","TranslateGameQuestion","TranslateGuide",
	"TranslateExplore",	"TranslateGame",
}

local translateGroups = {}


function FuncTranslate.init(  )
	if DEBUG_SERVICES  then
		return
	end

	for i,v in ipairs(translateModels) do
		table.insert(translateGroups,Tool:configRequire("translate/"..v) )
	end

	-- translateData = Tool:configRequire("translate/Translate")
	-- translateLuaData = Tool:configRequire("translate/Translate_lua")
    PlotTranslate = Tool:configRequire("translate/PlotTranslate")
    errorTranslate = Tool:configRequire("translate/TranslateError")
    FuncTranslate.checkHasErrorState(  )


end
local NoHandleTransErrorArr  ={}
--检查是否 存在没有标记状态为1的 error
function FuncTranslate.checkHasErrorState(  )

	for i,v in pairs(errorTranslate) do
		if v.state ~=1 then
			-- echoWarn("TranslateError key:",i ,"not handle,message:",v.zh_CN);
			table.insert(NoHandleTransErrorArr, {"TranslateError key:",i ,"not handle,message:",v.zh_CN })
			FuncTranslate.hasNotHandleErrorCode = true
		end
	end
end

--打印没有标记的translateError
function FuncTranslate.echoNoHandleError(  )
	local desStr = ""
	for i,v in ipairs(NoHandleTransErrorArr) do
		echoWarn(unpack(v))
		desStr = desStr .. v[2] .. "_des:"..tostring(v[4]) .. "\n"
	end
	local params = {
		title = "有未处理的错误码",
		isSingleBtn = true,
		des = desStr
	}

	if DEBUG > 1 then
		if not IS_TODO_MAIN_RUNCATION then
			WindowControler:showAlertView(params)
		end
	end
	
end


-- 根据key获取对应的文字
function FuncTranslate._getLanguage(key,languageVersion)
	if DEBUG_SERVICES then
		return key
	end
	languageVersion = languageVersion or "zh_CN"
    if not key then
        echoError("传入了空language key")
        key = ""
        return key
    end

    for i,v in ipairs(translateGroups) do
    	local content = v[key] or v["#" .. key]
    	if content then
    		--多语言文件判断是否是table，兼容两种导出结构(table/string)
    		if type(content) == "table" then
    			if not content[languageVersion] then
	    			break
	    		end
	    		return  content[languageVersion]
	    	else
				return content	    		
    		end
    	end
    end
    echoError("没有找到这个语言id配置:", key) 
	-- local content = translateData[key] 
	-- if not content or next(content) == nil then
	-- 	content = translateLuaData[key]
	-- end
	-- local str = key
	-- if content ~= nil then
	-- 	str = content[languageVersion]
	-- else
		
	-- end

	return key
end
-- 获取剧情对话文字信息
function FuncTranslate.getPlotLanguage(key,languageVersion, ...)
	languageVersion = languageVersion or "zh_CN"
	local content = PlotTranslate[key] 
	local str = nil
	if type(content) == 'table' then
		str=content[languageVersion]
	else
		str=content
	end
	if not str then
		echoWarn("__没有找到对应的剧情对话文本",key)
		return key
	end
	--echo(str)
	local args = {...}
	--dump(args)
	for i, v in ipairs(args) do
		--echo("替换",i,v)
		str = string.gsub(str, "#" .. tostring(i), tostring(v))
	end

	return str

end

-- 置换字符串 并 换文字
--[[
	eg: 
]]
function FuncTranslate._getLanguageWithSwap(key, ...)
	local str = FuncTranslate._getLanguage(key)
	return FuncTranslate.turnStringWithSwap(str,...)
	
end

function FuncTranslate.turnStringWithSwap( str,... )
	local args = {...}

	for i=#args,1,-1 do
		local v = args[i]
		v = string.gsub(tostring(v), "%%","%%%%")
		str = string.gsub(str, "#" .. tostring(i), tostring(v))
	end
	return str
end



--获取errortranslate
function FuncTranslate._getErrorLanguage(key,... )
	local languageVersion = "zh_CN"
    if not key then
        echoError("传入了空language key")
    end
	local content = errorTranslate[key] 
	local str = key
	if content ~= nil then
		str = content[languageVersion]

		local args = {...}
		for i, v in ipairs(args) do
			str = string.gsub(str, "#" .. tostring(i), tostring(v))
		end
		if not str then
			echoError("没有找到这个语言id配置:", key) 
			str = key
		end
	else
		echoError("没有找到这个语言id配置:", key) 
	end
	return str
end
function FuncTranslate._checkNoFoundText( )
	local tmpStr = {}
	local getCount = function(str )
		for i=1,string.len(str),3 do
			local s = str:sub(i,i+2)
			if not tmpStr[s] then
				tmpStr[s] = 1
		else
				tmpStr[s] = tmpStr[s] + 1
			end
		end
	end
	local hid = "hid"
	local languageKey = "zh_CN"
	local count = 0


	local tempFunc = function (cfgs  )
		for m,n in pairs(cfgs) do
			count = count +1
			local word = ""
			if type(n) == "table" then
				word = n[languageKey]
			else
				word = n
			end

			local str = pc.PCUtils:checkTTFMissChar(word,"ttf/"..GameVars.fontName)
			if str ~= "" then
				echo("在hid为 %s 的字符串 %s 中找不到 %s 字",m,word,str)
				getCount(str)
			end
		end
	end

	local checkEnd = function (  )
		echo("检查结束--总检查数:%s---总生僻字数：%s",count,#tmpStr)
		dump(tmpStr,"生僻字次数----")
	end

	local groupIndex = 0
	for k,v in pairs(translateGroups) do
		groupIndex = groupIndex +1
		WindowControler:globalDelayCall(c_func(tempFunc, v), groupIndex*0.03 )

	end

	local config_t_xing = Tool:configRequire("translate/Translate_xing")
	local config_t_name_male = Tool:configRequire("translate/Translate_mingnan")
	local config_t_name_female = Tool:configRequire("translate/Translate_mingnv")

	local otherGroup = {config_t_xing,config_t_name_male,config_t_name_female,PlotTranslate}

	for k,v in pairs(otherGroup) do

		groupIndex = groupIndex +1
		WindowControler:globalDelayCall(c_func(tempFunc, v), groupIndex*0.03 )

	end

	WindowControler:globalDelayCall(checkEnd, groupIndex*0.03+0.2 )
	


	

	-- local scheduler = Tool:configRequire("framework.scheduler")
	-- local sssss = nil
	-- local updateTt = 0
	-- local updateTime = function( )
	-- 	for i=1,50 do
	-- 		local index = updateTt + i
	-- 		if index >= #tmpTbl then
	-- 			scheduler.unscheduleGlobal(sssss)
	-- 			sssss = nil
	-- 			echo("检查结束-----")
	-- 		end
	-- 		pc.PCUtils:checkTTFMissChar(tmpTbl[index],"ttf/"..GameVars.fontName)
	-- 	end
	-- 	updateTt = updateTt + 50
	-- end
	-- sssss = scheduler.scheduleGlobal(c_func(updateTime,self), 0.5)
end



--获取服务器错误码信息
--[[
errorData = {
	code 错误码
	lang  服务器传递给的多语言
	message 服务器给的多语言信息
}
]]
function FuncTranslate.getServerErrorMessage( errorData )
	if errorData.lang then
		return errorData.lang
	end
	local error_code = errorData.code..''
	local tip = GameConfig.getErrorLanguage("#error"..error_code)
	if tip and tip ~= "" and tip ~= "#error"..error_code  then
		return tip
	end
	
	if GameStatic.displayErrorBoard then
		return string.format("ServerErrorCode: %s", error_code)
	end
	return errorData.message
end
