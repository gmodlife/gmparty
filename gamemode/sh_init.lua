PLAYER = FindMetaTable("Player")

THEME_SLOW = 6;
THEME_FAST = 5;

SPAWN_WHITEROOM_CIRCLE = 1;
SPAWN_WHITEROOM_SQUARE = 2;
SPAWN_BLACKROOM_CIRCLE = 3;
SPAWN_OUTDOORS = 4;
SPAWN_HALLWAY = 5;
SPAWN_TRAIN = 6;
SPAWN_SPIKEROOM_LARGE = 7;
SPAWN_DM_ARENA = 8;
SPAWN_TILES = 9;

MAX_PLAYER_COUNT_WHITEROOM_SQUARE = 21;
MAX_PLAYER_COUNT_WHITEROOM_CIRCLE = 20;
MAX_PLAYER_COUNT_BLACKROOM_CIRCLE = 20;
MAX_PLAYER_COUNT_OUTDOORS = 20;
MAX_PLAYER_COUNT_HALLWAY = 16;
MAX_PLAYER_COUNT_TRAIN = 21;
MAX_PLAYER_COUNT_SPIKEROOM_LARGE = 25;
MAX_PLAYER_COUNT_DM_ARENA = 21;
MAX_PLAYER_COUNT_TILES = 16;

HUD_TIME = 1;
HUD_HEALTH = 2;
HUD_COUNTER = 3;
HUD_FAKE_TIME = 4;

TRACE_DOWN = 1;
TRACE_UP = 2;

FORCE_WIN = 1;
FORCE_LOSE = 2;
FORCE_LOSS = 2;

FACE_RANDOM = 1;

GM.Name = "[BB]GMod Party"
GM.Author = "Hunts and Valkyrie"

include('sh_player.lua');

GM.MinigameDatabase = {};

if SERVER then
	function GM.MoonwalkCmd ( Player, Cmd )
		if Cmd == '+moonwalk' then
			Player:SetNetworkedBool('mw', true)
		else
			Player:SetNetworkedBool('mw', false)
		end
	end
	concommand.Add('+moonwalk', GM.MoonwalkCmd);
	concommand.Add('-moonwalk', GM.MoonwalkCmd);
end

function GM:UpdateAnimation( pl )
 
	if ( pl:InVehicle() ) then
 
		local Vehicle =  pl:GetVehicle()
 
		// We only need to do this clientside..
		if ( CLIENT ) then
 
			//
			// This is used for the 'rollercoaster' arms
			//
			local Velocity = Vehicle:GetVelocity()
			pl:SetPoseParameter( "vertical_velocity", Velocity.z * 0.01 ) 
 
			// Pass the vehicles steer param down to the player
			local steer = Vehicle:GetPoseParameter( "vehicle_steer" )
			steer = steer * 2 - 1 // convert from 0..1 to -1..1
			pl:SetPoseParameter( "vehicle_steer", steer  ) 
 
		end
 
	end
 
	if pl:GetNetworkedBool('mw', false) then
		pl:SetPoseParameter("move_x", 45)
	end
end



for k, v in pairs(file.Find('gmparty/gamemode/GMod Party/*.lua','LUA')) do
	MINIGAME = {};
	
	include('GMod Party/' .. v);
	
	MINIGAME.LastPlayID = 0;
	
	Msg('Registered Minigame -> ' .. MINIGAME.Name .. ' ( ' .. MINIGAME.ID .. ' )\n');
	GM.MinigameDatabase[MINIGAME.ID] = MINIGAME;
end

GM.CountdownTime = 10;
GM.SetupPhaseTime = 5;

team.SetUp(5, "Players", Color(255, 255, 0));
team.SetUp(4, "VIP", Color(0, 0, 255));
team.SetUp(3, "Temp Administrator", Color(255, 0, 255));
team.SetUp(2, "Administrator", Color(0, 255, 0));
team.SetUp(1337, "Owners", Color(255, 255, 255));
team.SetUp(1, "Super Administrator", Color(255, 0, 0));
team.SetUp(0, "Players", Color(255, 255, 0));

GM.GMRConversionRate = 5;
GM.PERPConversionRate = 350;
GM.VIPConversionRateMod = 1.25;