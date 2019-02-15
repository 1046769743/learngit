--
-- Author: dmx
-- Date: 2016-04-07
--
-- 创建角色

local config_t_xing = nil
local config_t_name_male = nil
local config_t_name_female = nil
local xing_ids = nil
local name_male_ids = nil
local name_female_ids = nil

local NAME_DEFAULT_LANG_VERSION = "zh_CN"

--正式密码长度最小为6
local PASSWORD_MIN_LEN = 6
local PASSWORD_MAX_LEN = 16
local ACCOUNT_MIN_LEN = 6
local ACCOUNT_MAX_LEN = 20
local ROLE_NAME_MIN_LEN = 4 -- 角色名最短4个字符
local ROLE_NAME_MAX_LEN = 12 -- 角色名最长12个字符
--有些正则表达式中的字符需要用%转义一下
local ROLE_NAME_FORBIDDEN_SPECIAL_CHARS = {" ", "~","!","@","#","%$","%%","%^","&","%*","%(","%)","<",">",",","%.","/","%?",";","%[","%]",":","'","\"","\\","|","%+", "-"}

FuncAccountUtil = FuncAccountUtil or {}

function FuncAccountUtil.init()
	config_t_xing = Tool:configRequire("translate/Translate_xing")
	config_t_name_male = Tool:configRequire("translate/Translate_mingnan")
	config_t_name_female = Tool:configRequire("translate/Translate_mingnv")

	xing_ids = table.keys(config_t_xing)
	name_male_ids = table.keys(config_t_name_male)
	name_female_ids = table.keys(config_t_name_female)
end


--检查账号名是否符合要求
function FuncAccountUtil.checkAccountName(name)
	--账号名，只能包含数字、字母
	local filteredName, replNum = string.gsub(name, "%W", "") 
	--包含除a-zA-Z0-9的特殊字符
	if replNum > 0 then
		return false, GameConfig.getLanguage("tid_login_1010")
	end

	local nameLen = string.len(name)
	--TODO 方便测试，暂时注释掉
	if nameLen < ACCOUNT_MIN_LEN or nameLen > ACCOUNT_MAX_LEN then
	   return false, GameConfig.getLanguage("tid_login_1014")
	end
	return true, nil
end

function FuncAccountUtil.checkAccountPassword(pass)
	--检查密码长度
	local filteredName, replNum = string.gsub(pass, "%W", "") 
	--包含除a-zA-Z0-9的特殊字符
	if replNum > 0 then
		return false, GameConfig.getLanguage("tid_login_1015")
	end

	local passlen = string.len(pass)
	--TODO 方便测试，暂时注释掉
	if passlen < PASSWORD_MIN_LEN or passlen>PASSWORD_MAX_LEN then
	   return false, GameConfig.getLanguageWithSwap("tid_login_1011", PASSWORD_MIN_LEN)
	end
	return true, nil
end

--检查游戏内玩家主角的名字
--一个汉字算两个字符，一个英文算一个字符
function FuncAccountUtil.checkRoleName(roleName)
	if roleName ==nil or string.len(roleName) ==0 then
		return false, GameConfig.getLanguage("tid_login_1018")
	end
	local tempRoleName = roleName
	--中文、英文、数字、下划线之外的都是特殊字符
	----去除英文、数字、下划线
	local tempRoleName, len = string.gsub(tempRoleName, "[a-zA-Z_0-9]", "")

	--检查中文之外的字符
	local utf32Values = string.utf8to32(tempRoleName)
	for _,v in ipairs(utf32Values) do
		if tonumber(v) < GameVars.CHINESE_UTF32_RANGE[1] or tonumber(v) > GameVars.CHINESE_UTF32_RANGE[2] then
			return false, GameConfig.getLanguage("tid_login_1016")
		end
	end

	--TODO 检查敏感字库
	local isBadName = Tool:checkIsBadWords(roleName)
	if isBadName then
		return false, GameConfig.getLanguage("tid_login_1035")
	end
	--检查长度
	local len = string.len4cn2(roleName)
	if len < ROLE_NAME_MIN_LEN or len > ROLE_NAME_MAX_LEN then
		return false, GameConfig.getLanguage("tid_login_1017")
	end
	return true
end

--获取固定映射的姓名
--PVP系统专用
function FuncAccountUtil.getRobotName(_rid, _robot_id)
    local _robot_item = FuncPvp.getRobotById(tostring(_rid))
    local _char_item = FuncChar.getHeroData(_robot_item.avatar)
    local _sex = _char_item.sex

    local _post_name 
    local _name_set
    if _sex == FuncChar.SEX_TYPE.NAN then
        _post_name = name_male_ids
        _name_set = config_t_name_male
    else
        _post_name = name_female_ids
        _name_set = config_t_name_female
    end
    
    local _seed = tonumber(_rid)
    local _seed1
    if _robot_id then
    	_seed1 = tonumber(_robot_id)
    else
    	_seed1 = _seed
    end

    local _post_key = _post_name[(_seed * 1037 + 29)% #_post_name + 1]
    local _prefix_key = xing_ids[(_seed * _seed1 + 137) % #xing_ids +1]

    -- 兼容两种导出格式
    if type(config_t_xing[_prefix_key]) == "table" then
    	return config_t_xing[_prefix_key][NAME_DEFAULT_LANG_VERSION] .. _name_set[_post_key][NAME_DEFAULT_LANG_VERSION]
    else
    	return config_t_xing[_prefix_key] .. _name_set[_post_key]
    end
end

function FuncAccountUtil.getRandomRoleName(sex)
	local xing_id_pool = table.copy(xing_ids)
	local name_id_pool = table.copy(name_female_ids)
	local name_pool = config_t_name_female
	if sex == FuncChar.SEX_TYPE.NAN then
		name_id_pool = table.copy(name_male_ids)
		name_pool = config_t_name_male
	end
	
	local name = FuncAccountUtil.getNameAgain(xing_id_pool, name_id_pool, name_pool)
	while Tool:checkIsBadWords(name) do
		-- echoError("敏感词过滤")
		name = FuncAccountUtil.getNameAgain(xing_id_pool, name_id_pool, name_pool)
	end

	return name
end

function FuncAccountUtil.getNameAgain(xing_id_pool, name_id_pool, name_pool)
	local randomseed = RandomControl.getOneRandomInt(os.time(), 1)

	-- TODO 屏蔽姓 by ZhangYanguang
	-- 已打开   姓
	table.shuffle(xing_id_pool, randomseed)
	table.shuffle(name_id_pool, randomseed)

	local xing_id = xing_id_pool[1]
	local name_id = name_id_pool[1]

	local xing = ""
	local ming = ""
	if type(config_t_xing[xing_id]) == "table" then
		xing = config_t_xing[xing_id][NAME_DEFAULT_LANG_VERSION]
		ming = name_pool[name_id][NAME_DEFAULT_LANG_VERSION]
	else
		xing = config_t_xing[xing_id]
		ming = name_pool[name_id]
	end
	local name = xing..ming
	return name
end
