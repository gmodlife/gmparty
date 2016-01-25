SOUND_WELCOME = 1;
SOUND_FAIL = 2;
SOUND_WIN = 3;
SOUND_START = 4;
SOUND_THEME_FAST = 5;
SOUND_THEME_SLOW = 6;

local SOUNDS = {};
SOUNDS[SOUND_WELCOME] = {'welcome.mp3'};
SOUNDS[SOUND_FAIL] = {'miss_01.mp3', 'miss_02.mp3', 'miss_03.mp3'};
SOUNDS[SOUND_START] = {'start_01.mp3', 'start_02.mp3', 'start_03.mp3'};
SOUNDS[SOUND_WIN] = {'win_01.mp3', 'win_02.mp3', 'win_03.mp3'};
SOUNDS[SOUND_THEME_FAST] = {'song_fast_01.mp3', 'song_fast_02.mp3', 'song_fast_03.mp3', 'song_fast_04.mp3', 'song_fast_05.mp3', 'song_fast_06.mp3'};
SOUNDS[SOUND_THEME_SLOW] = {'song_slow_01.mp3', 'song_slow_02.mp3', 'song_slow_03.mp3', 'song_slow_04.mp3'};

GM.AutoStopSounds = {}

local SOUND_CURRENT;

function GM.PlaySound ( Type, Loop )
	if not Type then Msg('Missing Sound') return false end
	if !SOUNDS[Type] then
		Msg('Missing Sound Type: ' .. Type .. '\n');
		return false;
	end
	
	if SOUND_CURRENT then
		SOUND_CURRENT:Stop();
		SOUND_CURRENT = nil;
		GAMEMODE.LoopingSound_Type = nil;
		GAMEMODE.LoopingSound_Time = nil;
	end
	
	local OurSound = Sound('gmp/' .. SOUNDS[Type][math.random(1, #SOUNDS[Type])]);
	if !LocalPlayer() or !LocalPlayer():IsValid() or !LocalPlayer():IsPlayer() then
		surface.PlaySound(OurSound);
	else
		SOUND_CURRENT = CreateSound(LocalPlayer(), OurSound);
		SOUND_CURRENT:Play();
	end
	
	if Loop then
		GAMEMODE.LoopingSound_Type = Type;
		GAMEMODE.LoopingSound_Time = CurTime() + SoundDuration(OurSound);
	end
	
	return OurSound;
end

function GM.LoopSounds ( ) 
	if GAMEMODE.LoopingSound_Type and GAMEMODE.LoopingSound_Time and CurTime() >= GAMEMODE.LoopingSound_Time then
		GAMEMODE.PlaySound(GAMEMODE.LoopingSound_Type, true);
	end
	
	for k, v in pairs(GAMEMODE.AutoStopSounds) do
		if !v[1] or !v[1]:IsValid() then
			v[2]:Stop();
			v[2] = nil;
			v[1] = nil;
			
			GAMEMODE.AutoStopSounds[k] = nil;
		end
	end
end
hook.Add('Think', 'GM.LoopSounds', GM.LoopSounds);