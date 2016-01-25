
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


function ENT:Initialize()
	self.Entity:SetModel("models/Fallout3/jukebox.mdl")
	self:SetSolid(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_NONE);
	self:SetUseType(SIMPLE_USE);
end

function ENT:Use( activator, caller )
	umsg.Start('jukebox_open', activator); umsg.End();
end




local NextJukeboxSongBegin = 30;
local CurrentSong = 0;
local TimeBetweenSongRequests = 60;
Radio = {};

function Radio.PickNewSong ( )
	tmysql.query("SELECT `id`, `length`, `artist`, `name` FROM `construct_jukebox` ORDER BY `requests` DESC, `last_request` ASC, `last_play` ASC, `length` ASC LIMIT 1",
		function ( NewSongQuery ) 
			CurrentSong = tonumber(NewSongQuery[1][1]);
			
			tmysql.query("UPDATE `construct_jukebox` SET `last_request`='0', `last_play`='" .. os.time() .. "', `requests`='0' WHERE `id`='" .. CurrentSong .. "'");
			
			umsg.Start('jukebox_newsong')
				umsg.Short(CurrentSong);
				umsg.Long(tonumber(NewSongQuery[1][2]));
				umsg.String(NewSongQuery[1][3]);
				umsg.String(NewSongQuery[1][4]);
			umsg.End();
			
			GAMEMODE.Jukebox_CurSong = CurrentSong;
			GAMEMODE.Jukebox_Len = tonumber(NewSongQuery[1][2]);
			GAMEMODE.Jukebox_Artist = NewSongQuery[1][3];
			GAMEMODE.Jukebox_Name = NewSongQuery[1][4];
			
			NextJukeboxSongBegin = CurTime() + tonumber(NewSongQuery[1][2]);
		end
	);
end

function Radio.MonitorNewSongTime ( )
	if CurTime() >= NextJukeboxSongBegin then
		Radio.PickNewSong();
	end
end
//hook.Add('Think', 'Radio.MonitorNewSongTime', Radio.MonitorNewSongTime);

function Radio.RequestSong ( Player, Cmd, Args )
	local IDToRequest = tonumber(Args[1]);
	
	if Player:GetTable().LastSongRequest and Player:GetTable().LastSongRequest + TimeBetweenSongRequests > CurTime() and Player:GetLevel() > 1 then return false; end
	
	local NumRequestsToFile = 1;
	
	if Player:GetLevel() <= 1 then
		NumRequestsToFile = 4;
	elseif Player:GetLevel() <= 2 then
		NumRequestsToFile = 3;
	elseif Player:GetLevel() <= 4 then
		NumRequestsToFile = 2;
	end
	
	tmysql.query("UPDATE `construct_jukebox` SET `requests`=`requests`+'" .. NumRequestsToFile .. "', `last_request`='" .. os.time() .. "' WHERE `id`='" .. IDToRequest .. "'");
	
	Player:PrintMessage(HUD_PRINTTALK, "Song successfully requested.");
	
	Player:AddProgress(39, 1);
end
//concommand.Add('gmp_jrs', Radio.RequestSong);

