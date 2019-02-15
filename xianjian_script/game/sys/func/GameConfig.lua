 --
-- User: ZhangYanGuang
-- Date: 15-5-14
-- 获取csv配置工具类
--

GameConfig = GameConfig or {}

function GameConfig.addSingelConfig(config_name,cfg)
    --echo("info","config filename  = "..config_name.."已经加载完成")
end

--获取不带占位符的文本
function GameConfig.getLanguage(key)
	return FuncTranslate._getLanguage(key)
end

--获取带有占位符的文本
function GameConfig.getLanguageWithSwap(key, ...)
	return FuncTranslate._getLanguageWithSwap(key, ...)
end

-- 置换字符串 并 换文字
--[[
	eg: 
]]
function GameConfig.getLanguageWithSwapForSkillDazhao(str, ...)

	local args = {...}
	for i=#args,1,-1 do
		str = string.gsub(str, "&" .. tostring(i), tostring(args[i]))
	end

	return str
end
function GameConfig.getLanguageWithSwapForSkillKind3(str, ...)

	local args = {...}
	for i=#args,1,-1 do
		str = string.gsub(str, "$" .. tostring(i), tostring(args[i]))
	end

	return str
end
--
-- 置换字符串 并 换文字
--[[
	eg: 
]]
function GameConfig.getLanguageWithSwapForPlot(key, ...)
	local str = getPlotLanguage(key)

	local args = {...}
	for i, v in pairs(args) do
		str = string.gsub(str, "#" .. tostring(i), tostring(v))
	end

	return str
end

--获取音频文件
function GameConfig.getMusic(key)
    local tempMusic = MusicConfig[key] or key or  ""
	tempMusic = string.format("sound/%s.mp3", tempMusic)
    local path = nil
    --发布后查询数据库
    -- path = AppInformation:getInstance():getRealFileName(tempMusic or key)
    if path == nil then
        return tempMusic
    end
    return path
end

function GameConfig.getErrorLanguage(key,... )
    return FuncTranslate._getErrorLanguage(key,... )
end