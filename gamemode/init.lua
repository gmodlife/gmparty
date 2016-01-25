// Send all the files that the client will need
AddCSLuaFile('cl_init.lua');
AddCSLuaFile('cl_td_network.lua');
AddCSLuaFile('sh_init.lua');
AddCSLuaFile('cl_sounds.lua');
AddCSLuaFile('cl_hooks.lua');
AddCSLuaFile('cl_networking.lua');
AddCSLuaFile('cl_notifications.lua');
AddCSLuaFile('cl_tf2td_helpmenu.lua');
AddCSLuaFile('cl_tf2td_info.lua');
AddCSLuaFile('cl_chat.lua');
AddCSLuaFile('cl_scoreboards.lua');
AddCSLuaFile('sh_player.lua');


AddCSLuaFile("scoreboards/player_frame.lua")
AddCSLuaFile("scoreboards/player_infocard.lua")
AddCSLuaFile("scoreboards/player_row.lua")
AddCSLuaFile("scoreboards/scoreboard.lua")

for k, v in pairs(file.Find('gmparty/gamemode/GMod Party/*.lua','LUA')) do
	AddCSLuaFile('GMod Party/' .. v);
end

for k, v in pairs(file.Find('gmparty/gamemode/vgui/*.lua','LUA')) do
	AddCSLuaFile('vgui/' .. v);
end

GM.MonitorStockPrices = true

// Include all files we need
include('sh_init.lua');
include('sv_networking.lua');
include('sv_hooks.lua');
include('sv_GMod Party.lua');
include('sv_player.lua');
include('sv_library.lua');
include('sv_td_network.lua');
include('sv_npcs.lua');
include('sv_trivia.lua');
--include('sv_gatekeeper.lua');
include('sv_chat.lua');
include('sv_admin.lua');


// Variable Init
GM.GamePlaying = false;
GM.NextGameStart = CurTime() + 5;

// PE shit
RunConsoleCommand('sv_alltalk', '1');

function ChatNotify(msg,ply)
	if ChatBox then
		local rp = RecipientFilter()
		if IsValid(ply) then rp:AddPlayer(ply) else rp:AddAllPlayers() end
		umsg.Start("silkAdd",rp)
			umsg.String(msg)
		umsg.End()
	else
		if IsValid(ply) then ply:ChatPrint(msg)
		else
			for k,v in pairs(player.GetAll()) do
				v:ChatPrint(msg)
			end
		end
	end
end

malePlayermodels = {
	"models/player/group01/male_01.mdl",
	"models/player/group01/male_02.mdl",
	"models/player/group01/male_03.mdl",
	"models/player/group01/male_04.mdl",
	"models/player/group01/male_06.mdl",
	"models/player/group01/male_07.mdl",
	"models/player/group01/male_08.mdl",
	"models/player/group01/male_09.mdl",
};

function GM:PlayerSpray(ply)
   if not ply or not IsValid(ply) or ply:InMinigame() then
      return true -- block
   elseif ply:Alive() then
		umsg.Start("AddSpray")
			umsg.Entity(ply)
			umsg.Vector(util.TraceLine(util.GetPlayerTrace(ply)).HitPos)
		umsg.End()
	end
end

// Resource destribution
local ClientResources = 0;
local function ProcessFolder ( Location )
	print(Location .. '*')
	for k, v in pairs(file.Find(Location .. '*','GAME')) do
		if file.IsDir(Location .. v,'GAME') then
			ProcessFolder(Location .. v .. '/')
		else
			local OurLocation = string.gsub(Location .. v, '../gamemodes/' .. GM.Path .. '/content/', '')
			
			if !string.find(Location, '.db') then			
				ClientResources = ClientResources + 1;
				resource.AddFile(OurLocation);
			end
		end
	end
end

GM.Path = "gmparty";
if !game.SinglePlayer() then
	--ProcessFolder('../gamemodes/' .. GM.Path .. '/content/models/');
	--ProcessFolder('../gamemodes/' .. GM.Path .. '/content/materials/');
	--ProcessFolder('../gamemodes/' .. GM.Path .. '/content/sound/');
	--ProcessFolder('../gamemodes/' .. GM.Path .. '/content/settings/');
	for k, v in pairs(file.Find('models/cloudstrifexiii/boo/*',"GAME") or {}) do
		resource.AddFile('models/cloudstrifexiii/boo/' .. v);
	end
	for k, v in pairs(file.Find('materials/gmp/*',"GAME") or {}) do
		resource.AddFile('materials/gmp/' .. v);
	end
	for k, v in pairs(file.Find('sound/gmp/*',"GAME") or {}) do
		resource.AddFile('sound/gmp/' .. v);
	end
	for k, v in pairs(file.Find('settings/render_targets/*',"GAME") or {}) do
		resource.AddFile('settings/render_targets/' .. v);
	end
end

resource.AddFile('materials/sprites/gmp_ball.vtf');
resource.AddFile('materials/sprites/gmp_ball.vmt');
resource.AddFile('settings/render_targets/gmpGMod Partycreen512.txt');

// Make it VIP only :)
GM.VIPsOnly = nil;

for k, v in pairs(file.Find("maps/tf2td_*.bsp","GAME")) do
	resource.AddFile('maps/' .. v);
	Msg('Registered TF2TD Map -> ' .. v .. '\n');
end

resource.AddFile('sound/tf2ui/buttonclick.wav');
resource.AddFile('sound/tf2ui/buttonclickrelease.wav');
resource.AddFile('sound/tf2ui/buttonrollover.wav');
