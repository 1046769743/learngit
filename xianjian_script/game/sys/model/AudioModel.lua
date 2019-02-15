--
-- Author: xd
-- Date: 2016-03-02 18:51:27
--管理音频和视频的 类
local AudioModel = AudioModel or {}

local STATUS_ON = FuncSetting.SWITCH_STATES.ON
local STATUS_OFF = FuncSetting.SWITCH_STATES.OFF

--初始化
function AudioModel:init()
	--读取本机缓存的音效开关
	self:initStatus()
	EventControler:addEventListener(SettingEvent.SETTINGEVENT_MUSIC_SETTING_CHANGE, self.onMusicStatusChange, self)
	EventControler:addEventListener(SettingEvent.SETTINGEVENT_SOUND_SETTING_CHANGE, self.onSoundStatusChange, self)

	self._currentMusic = nil;
	self._isCurrentMusicLoop = nil;

	self._currentSound = nil;
	self._isCurrentSoundLoop = nil;	
end

function AudioModel:initStatus()
	self._sound_status = LS:pub():get(StorageCode.setting_sound_st, FuncSetting.DEFAULT_SOUND_ST)
	self._music_status = LS:pub():get(StorageCode.setting_music_st, FuncSetting.DEFAULT_MUSIC_ST)
	self._battle_music_status = LS:pub():get(StorageCode.setting_battle_music_st, STATUS_OFF)
	self._battle_sound_status = LS:pub():get(StorageCode.setting_battle_sound_st, STATUS_OFF)
    self._music_volume = LS:pub():get(StorageCode.setting_music_volume, 0.5) --默认音量是0.5
    self._sound_volume = LS:pub():get(StorageCode.setting_sound_volume, 0.5)

    if self._music_volume == nil or self._music_volume == ""  or self._music_volume == "nil" then
    	self._music_volume = 0.5
    end

    if self._sound_volume == nil or self._sound_volume == ""  or self._sound_volume == "nil" then
    	self._sound_volume = 0.5
    end

	-- self:preloadSound("s_com_fixTip")
	self:setMusicVolume(self._music_volume)
	self:setSoundVolume(self._sound_volume)
end
--预加载某个音效
function AudioModel:preloadSound(effectName )
	audio.preloadSound(GameConfig.getMusic(effectName))
end
-- 释放掉某个音效
function AudioModel:unloadSound(effectName )
	audio.unloadSound(GameConfig.getMusic(effectName))
end
--全局的音乐设置变化
function AudioModel:onMusicStatusChange(event)
	self._music_status = LS:pub():get(StorageCode.setting_music_st, STATUS_OFF)
	if self._music_status == STATUS_OFF then
		audio.pauseMusic()
	end
end

--全局的音效设置变化
function AudioModel:onSoundStatusChange(event)
	self._sound_status = LS:pub():get(StorageCode.setting_sound_st, STATUS_OFF)
end

function AudioModel:isSoundOn()
	local sound_st = LS:pub():get(StorageCode.setting_sound_st, FuncSetting.DEFAULT_SOUND_ST)
	return sound_st == STATUS_ON
end

function AudioModel:isMusicOn()
	local music_st = LS:pub():get(StorageCode.setting_music_st, FuncSetting.DEFAULT_MUSIC_ST)
	return music_st == STATUS_ON
end

function AudioModel:isBattleSoundOn()
	return self:isMusicOn() and self._battle_sound_status == STATUS_ON
end

function AudioModel:isBattleMusicOn()
	return self:isSoundOn() and self._battle_music_status == STATUS_ON
end

--战斗中的音效暂停
function AudioModel:battlePauseSound()
	self._battle_sound_status = STATUS_OFF
	LS:pub():set(StorageCode.setting_battle_sound_st, STATUS_OFF)
end

--战斗中的音效恢复
function AudioModel:battleResumeSound()
	self._battle_sound_status = STATUS_ON
	LS:pub():set(StorageCode.setting_battle_sound_st, STATUS_ON)
end


function AudioModel:playSound(key, isLoop)
	if not self:isSoundOn() then return end
	

	local musicFile = GameConfig.getMusic(key)
	--dev test
	local musicFileExist = cc.FileUtils:getInstance():isFileExist(musicFile)

	if musicFileExist == false then 
		echo("sound is not exist. key is ".. tostring(key));
	end 

	if musicFile and musicFileExist then
		self._currentSound = key;
		self._isCurrentSoundLoop = isLoop;	
		return audio.playSound(musicFile, isLoop)
	end
end


function AudioModel:playMusic(key, isLoop)
	if not self:isMusicOn() then return end
	if self.currentMusic == key then
		return
	end
	self.currentMusic = key

	local musicFile = GameConfig.getMusic(key)
	if musicFile then
		audio.playMusic(musicFile, isLoop)
		self._currentMusic = key;
		self._isCurrentMusicLoop = isLoop;
	end
end

function AudioModel:setCacheMusic(musicBeforeBattle)
	self._cacheMusic = musicBeforeBattle
end

function AudioModel:getCacheMusic()
	return self._cacheMusic
end

--停止当前音乐
function AudioModel:stopMusic(  )
	self.currentMusic = nil
	audio:stopMusic()
end

function AudioModel:stopSound(handle)
	audio.stopSound(handle)
end


--停止当前音乐
function AudioModel:resumeMusic(  )
	if self.currentMusic then
		self.currentMusic = nil
		local musci = self.currentMusic
		AudioModel:playMusic(musci)
	end
end

function AudioModel:getCurrentSound()
	return self._currentSound, self._isCurrentSoundLoop;
end

function AudioModel:getCurrentMusic()
	return self._currentMusic, self._isCurrentMusicLoop;
end

function AudioModel:getMusicVolume()
	return self._music_volume
end
function AudioModel:getSoundVolume( ... )
	return self._sound_volume
end
-- 设置背景音乐音量大小 percent 0~1.0之间
function AudioModel:setMusicVolume(percent,ingoreIo)
	audio.setMusicVolume(percent)
	if not ingoreIo then
		self._music_volume = percent
		LS:pub():set(StorageCode.setting_music_volume, percent)
	end
end
-- 设置音效音量大小 percent 0~1.0之间
function AudioModel:setSoundVolume( percent,ingoreIo)
	audio.setSoundsVolume(percent)
	if not ingoreIo then
		self._sound_volume = percent
		LS:pub():set(StorageCode.setting_sound_volume, percent)
	end
end

--判断是否需要播放视频
function AudioModel:checkNeedPlayVideo( )
	return true
end

function AudioModel:test()
	local num = 500
    local soundID = nil
    local count = 0
    function play()
        if soundID then
            audio.stopSound(soundID)    
            -- echo("zygtest-stopSound soundID=",soundID)
        end
        local key = "s_drama_00_lixiaoyao-02"
        soundID = self:playSound(key,true)
        -- echo("zygtest-播放音效 soundID=",soundID)
        num = num - 1
        if num > 0 then
            -- delayCallByTime(100, play)
            WindowControler:globalDelayCall(c_func(play),0.1)
        end

        count = count + 1
        echo("zygtest count=",count)
    end

    local play2 = function(i)
    	num = 500
    	play()
    	echo("zygtest i=",i)
	end

    for i=1,100 do
    	WindowControler:globalDelayCall(c_func(play2,i),(i-1)*10)
    end
end


return AudioModel
