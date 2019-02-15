FuncSetting = FuncSetting or {}

if DEBUG_SERVICES then
	return
end

FuncSetting.SWITCH_STATES = {
	ON = "on",
	OFF = "off"
}
FuncSetting.DEFAULT_MUSIC_ST = FuncSetting.SWITCH_STATES.ON
FuncSetting.DEFAULT_SOUND_ST = FuncSetting.SWITCH_STATES.ON

local audio_default_status = FuncSetting.SWITCH_STATES.ON

FuncSetting.SETTTING_SWITCHS = {
--default 不知道有什么作用
	MUSIC = {
		key="music",
		sc=StorageCode.setting_music_st,
		keyStr="游戏音乐", 
		default=audio_default_status, 
		event = SettingEvent.SETTINGEVENT_MUSIC_SETTING_CHANGE
	},
	SOUND = {
		key="sound", 
		sc=StorageCode.setting_sound_st,
		keyStr="游戏音效",
		default=audio_default_status,
		event = SettingEvent.SETTINGEVENT_SOUND_SETTING_CHANGE
	},
    SHOWPLAYER = {
        key = "show_palyer",
        sc = StorageCode.setting_show_player_st,
        keyStr="屏蔽其他玩家",
        default=audio_default_status,
        event = SettingEvent.SETTINGEVENT_SHOWPLSYER_SETTING_CHANGE
    },
    TEAMINVITE = {
        key = "team_invite",
        sc = StorageCode.setting_teaminvite_player_st,
        keyStr="屏蔽组队邀请",
        default=audio_default_status,
        event = SettingEvent.SETTINGEVENT_TEAMINVITE_SETTING_CHANGE
    }
}

FuncSetting.FEEDBACK_PUBKEY = "cca712e9f"
FuncSetting.FEEDBACK_PRIKEY = "4042c7a5ee34f63f6b42a2e05d47f170"
--反馈地址，先用测试地址，等公钥、秘钥生效后启用
FuncSetting.FEEDBACK_URL = "https://customer.playcrab.com/v1/question" --正式反馈地址
--FuncSetting.FEEDBACK_URL = "http://117.121.26.180/v1/question" -- 测试反馈地址

local config_localNotifications
local noti_keys = {}

local CDKEY_SPEICIAL_CHARS = {" ", "~","!","@","#","%$","%%","%^","&","%*","%(","%)","<",">",",","%.","/","%?",";","%[","%]",":","'","\"","\\","|","%+", "-"}

function FuncSetting.init()
	config_localNotifications = Tool:configRequire("common.LocalNotifications")
	local sortById = function(a, b)
		return tonumber(a.id) < tonumber(b.id)
	end
	local noti_ids = table.sortedKeys(config_localNotifications, sortById)
	for _, id in ipairs(noti_ids) do
		local data = config_localNotifications[id]
		local key = data.key
		local upperKey = string.upper(key)
		local switch_info = {
			key = key,
			sc = string.format("setting_%s_st", key),
			keyStr = GameConfig.getLanguage(data.tid),
			default = data.state,
		}
		FuncSetting.SETTTING_SWITCHS[upperKey] = switch_info
		table.insert(noti_keys, upperKey)
	end
end

function FuncSetting.getNotificationKeys()
	return noti_keys
end

function FuncSetting.isCdkeyOpen()
	return true
end

function FuncSetting.checkCdkeyStr(cdkey)
	if cdkey ==nil or string.len(cdkey) ==0 then
		return false, GameConfig.getLanguage("tid_cdkey_1001")
	end
	--检查特殊字符
	for _, special_char in ipairs(CDKEY_SPEICIAL_CHARS) do
		if string.find(cdkey, special_char)~=nil then
			return false, GameConfig.getLanguage("tid_cdkey_1001")
		end
	end
	return true
end

--检查是否是口令码
function FuncSetting.checkIsPassCode(cdkey)
	if tonumber(cdkey) then
		return true
	end

	return false
end

-- 设置是否显示其他玩家
function FuncSetting.showOtherPlayer()
	local isShowOtherPlayer = LS:pub():get(StorageCode.setting_show_player_st, 
        FuncSetting.SWITCH_STATES.OFF) == FuncSetting.SWITCH_STATES.OFF and true or false;

	return isShowOtherPlayer
end
