--
-- Author: shineflag
-- Date: 2017-03-01 17:51:32
--

local effect_path = "audio/"
local music_path = "audio/"
local ms_type = ".mp3"
if device.platform == "android" then
ms_type = ".ogg"
else
ms_type = ".mp3"
end

--背景音乐
local music = {
	BGM = music_path .. "bgm.mp3",
}

--音效
local effect = {
	audio_card_click = effect_path .. "audio_card_click" .. ms_type,
	audio_card_out = effect_path .. "audio_card_out" .. ms_type,
	audio_get_card = effect_path .. "audio_get_card" .. ms_type,
	shazi = effect_path .. "shazi" .. ms_type,
	click = effect_path .. "click" .. ms_type,
	m_chi_hu = effect_path .. "m_chi_hu" .. ms_type,
	m_gang = effect_path .. "m_gang" .. ms_type,
	m_peng = effect_path .. "m_peng" .. ms_type,
	m_bian = effect_path .. "m_bian" .. ms_type,
	m_zuan = effect_path .. "m_zuan" .. ms_type,
	w_chi_hu = effect_path .. "w_chi_hu" .. ms_type,
	w_gang = effect_path .. "w_gang" .. ms_type,
	w_peng = effect_path .. "w_peng" .. ms_type,
	w_bian = effect_path .. "w_bian" .. ms_type,
	w_zuan = effect_path .. "w_zuan" .. ms_type,
}

-- 麻将
for i=0,2 do
	for j=1,9 do
		local key = string.format("0x%d%d",i,j)
		effect["m_"..key] = effect_path .. "m_" .. key .. ms_type
		effect["w_"..key] = effect_path .. "w_" .. key .. ms_type
	end
end

for i=1,4 do
	local key = string.format("0x%d%d",3,i)
	effect["m_"..key] = effect_path .. "m_" .. key .. ms_type
	effect["w_"..key] = effect_path .. "w_" .. key .. ms_type
end

for i=1,3 do
	local key = string.format("0x%d%d",4,i)
	effect["m_"..key] = effect_path .. "m_" .. key .. ms_type
	effect["w_"..key] = effect_path .. "w_" .. key .. ms_type
end

for i=1,9 do
	local key = string.format("fix_msg_%d",i)
	effect[key] = effect_path .. key .. ms_type
end


local play = {}

local function init_keys ()
	for k, v in pairs(music) do
	    play[k] = v
	end

	for k, v in pairs(effect) do
	    play[k] = v
	end
end

local function preload_music()
	-- preload all musics
	for k, v in pairs(music) do
	    audio.preloadMusic(v)
	end
end

local function preload_sound( ... )
	-- preload all effects
	for k, v in pairs(effect) do
	    audio.preloadSound(v)
	end
end

local isPlayMusic = false
local musicName = nil

local function play_music( name )
	musicName = name
	local src = music[name]
	print("playMusic",src)
	if not (tt.game_data.music_btn_status == false) then
		isPlayMusic = true
		audio.playMusic(src, true)
	end
end

local function pause_music()
	audio.pauseMusic()
end

local function resume_music()
	if not (tt.game_data.music_btn_status == false) then
		if isPlayMusic then 
			audio.resumeMusic()
		else
			play_music(musicName)
		end
	end
end

local function stop_music()
	audio.stopMusic()
	isPlayMusic = false
end

local function play_sound( name ,flag )
	print("playSound",name,tt.game_data.sound_btn_status ~= false)
	if tt.game_data.sound_btn_status ~= false and effect[name] then
	    audio.playSound(effect[name], flag or false)
	end
end

local function set_music_vol( volume )
	print("setVol:",volume)
	audio.setMusicVolume(volume)
end

local function get_music_vol()
	local volume =  audio.getMusicVolume()
	print("getVol:",volume)
	return volume
end

local function set_sounds_vol(volume)
	printInfo("set_sounds_vol:",volume)
	audio.setSoundsVolume(volume)
end

local function get_sounds_vol()
	local volume = audio.getSoundsVolume()
	printInfo("get_sounds_vol:",volume)
	return volume
end

local function get_effect_config()
	return effect
end

preload_music()
preload_sound()
get_music_vol()
set_music_vol(1.0)
set_sounds_vol(1.0)
init_keys()

play.play_music = play_music
play.play_sound = play_sound
play.pause_music = pause_music
play.resume_music = resume_music
play.stop_music = stop_music
play.get_effect_config = get_effect_config
play.set_music_vol = set_music_vol
play.set_sounds_vol = set_sounds_vol
return play
