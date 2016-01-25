local PlayerMetaTable = FindMetaTable('Player');

local SpawnZones = {};
SpawnZones[SPAWN_WHITEROOM_CIRCLE] = "whiteroom_circle";
SpawnZones[SPAWN_WHITEROOM_SQUARE] = "whiteroom_square";
SpawnZones[SPAWN_BLACKROOM_CIRCLE] = "blackroom_circle";
SpawnZones[SPAWN_OUTDOORS] = "outdoors";
SpawnZones[SPAWN_HALLWAY] = "hallway";
SpawnZones[SPAWN_TRAIN] = "train";
SpawnZones[SPAWN_SPIKEROOM_LARGE] = "spikes_center";
SpawnZones[SPAWN_DM_ARENA] = "dm_arena";
SpawnZones[SPAWN_TILES] = "tiles";

function PlayerMetaTable:KillSilent ( ) self:Kill(); end

function PlayerMetaTable:DeclareWinner ( )
	self:SetNetworkedBool('gmp_minigame', false);
	self:Kill();
	self:GiveStar();
	
	umsg.Start('gmp_minigame_win', self);
	umsg.End();
	
	GAMEMODE:CheckMinigameOver();
end

function PlayerMetaTable:DeclareLoser ( )
	self:Kill();
end

function PlayerMetaTable:SetStars ( NumStars ) 
	self:SetNetworkedInt('gmp_stars', NumStars);
	--tmysql.query("UPDATE `gmp_users` SET `stars`='" .. NumStars .. "' WHERE `steamid`='" .. self:SteamID() .. "'");
	self:SetPData('gmp_stars',tostring(NumStars))
end

function PlayerMetaTable:GiveStar ( )
	local NumStars = math.Clamp(self:GetNetworkedInt('gmp_stars', 0) + 1, 0, 99);
	self:SetStars(NumStars);
end

function PlayerMetaTable:TakeStars ( Number ) 
	local NumStars = math.Clamp(self:GetNetworkedInt('gmp_stars', 0) - Number, 0, 99);
	self:SetStars(NumStars);
end

function PlayerMetaTable:SendCashValues ( )
	if IsValid(self) then
		umsg.Start('gmp_gm_cashes', self);
			umsg.Long(self:GetTable().GMRCash or 0);
			umsg.Long(self:GetTable().PERPCash or 0);
		umsg.End();
	end
end

function PlayerMetaTable:LoadInformation ( ) 
	tmysql.query("SELECT `stars` FROM `gmp_users` WHERE `steamid`='" .. self:SteamID() .. "'",
		function ( PlayerInformation )
			self:SetNetworkedInt('gmp_stars', math.Clamp(tonumber(PlayerInformation[1][1]), 0, 99));
			
			self:GetTable().GMRCash = -1;
			self:GetTable().PERPCash = -1;
		end
	);
	
	/*tmysql.query("SELECT `CASH` FROM `gmr_cash` WHERE `STEAMID`='" .. self:SteamID() .. "'",
		function ( PlayerGMPData )
			if PlayerGMPData and PlayerGMPData[1] and PlayerGMPData[1][1] then
				self:GetTable().GMRCash = tonumber(PlayerGMPData[1][1]);
				
				if self:GetTable().PERPCash and self:GetTable().GMRCash then
					self:SendCashValues();
				end
			end
		end
	, true);
	
	tmysql.query("SELECT `cash` FROM `perp_users` WHERE `steamid`='" .. self:SteamID() .. "'",
		function ( PlayerGMPData )
			if PlayerGMPData and PlayerGMPData[1] and PlayerGMPData[1]['cash'] then
				self:GetTable().PERPCash = tonumber(PlayerGMPData[1]['cash']);
				
				if self:GetTable().PERPCash and self:GetTable().GMRCash then
					self:SendCashValues();
				end
			end
		end
	, true);*/
end

function PlayerMetaTable:CreateProfile ( ) 
	/*tmysql.query("INSERT INTO `gmp_users` (`steamid`) VALUES ('" .. self:SteamID() .. "')",
		function ( )
			self:LoadInformation();
		end
	);*/
end

function PlayerMetaTable:Notify ( Text )
	umsg.Start('gmp_notify', self);
		umsg.String(Text);
	umsg.End();
end

function GM.FreezePlayer ( Player )
	if Player and Player:IsValid() and Player:IsPlayer() then 
		Player:Freeze(true);
	end
end

function PlayerMetaTable:SpawnForMinigame ( Location, LookLocation )
	local PossibleSpawns = {};
	for k, v in pairs(ents.FindByClass('ent_gmp_player_spawn')) do
		if v and v:IsValid() and v:GetTable().SpawnType == SpawnZones[Location] then
			v:GetTable().NextAvailableSpawn = v:GetTable().NextAvailableSpawn or 0;
			if CurTime() > v:GetTable().NextAvailableSpawn and util.IsInWorld(v:GetPos() + Vector(0, 0, 64)) then
				table.insert(PossibleSpawns, v);
			end
		end
	end

	
	local UsedSpawn = table.Random(PossibleSpawns);
	UsedSpawn:GetTable().NextAvailableSpawn = CurTime() + 5;
	self:SetPos(UsedSpawn:GetPos() + Vector(0, 0, 64));
	
	if LookLocation then
		if LookLocation == FACE_RANDOM then
			local Angles = Angle(0, math.random(0, 360), 0);
			self:SetEyeAngles(Angles);
		else
			local Angles = (LookLocation - self:EyePos()):Angle();
			self:SetEyeAngles(Angles);
		end
	else
		self:SetEyeAngles(UsedSpawn:GetAngles());
	end
	self:Freeze(true)
	
	timer.Simple(1, GAMEMODE.FreezePlayer, self);
end

function PlayerMetaTable:AddCounterValue ( OptionalSetTo )
	umsg.Start('gmp_value_counter', self);
	umsg.End();
end

function PlayerMetaTable:StartFakeTimer ( Time )
	umsg.Start('gmp_fake_timer', self);
		umsg.Short(Time);
	umsg.End();
end

function PlayerMetaTable:StopFakeTimer ( )
	umsg.Start('gmp_fake_timer_stop', self);
	umsg.End();
end
