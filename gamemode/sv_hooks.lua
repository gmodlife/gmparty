--[[
Brought To You By The Gmod Scripts Team
www.GmodScripts.com
--]]

local DiscoBallLocations = {Vector(-474.8362, 500, 219.9688), Vector(-474.8362, -500, 219.9688)}

local LightsOn = true;
function GM:PlayerUse ( Player, Ent )
	if Ent:GetName() == "light_button" then 
		/*
		Player:Notify("Button temporarily disabled.");
		return false;
		*/
	
		
		--if !Player:IsSuperAdmin() then Player:Notify("Not authorized."); return false; end
		
		if !Player:GetTable().NextMod or Player:GetTable().NextMod < CurTime() then
			Player:GetTable().NextMod = CurTime() + .5;
			
			if !self.DiscoBalls then
				self.DiscoBalls = {};
				
				for k, v in pairs(DiscoBallLocations) do
					local NewDisco = ents.Create('gmp_disco');
					NewDisco:SetPos(v);
					NewDisco:Spawn();
					
					table.insert(self.DiscoBalls, NewDisco);
				end
			else
				for k, v in pairs(self.DiscoBalls) do
					v:Remove();
				end
				
				self.DiscoBalls = nil;
			end
		else
			Player:GetTable().NextMod = CurTime() + .5;
		end
	end
	
	return true;
end

function GM.SetTeam ( Player, Hint )
	if Hint == 0 then
		Player:SetTeam(1337);
	else
		Player:SetTeam(Hint)
	end
end

function GM:PlayerSetModel(Player)
	Player:SetModel(Player:GetPData('pmodel',malePlayermodels[1]))
	Player:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

function GM:PlayerSelectSpawn ( Player )
	local SpawnPoints;
	
	if !Player:GetTable().NFirstSpawn then
		Player:GetTable().NFirstSpawn = true;
		SpawnPoints = ents.FindByClass("info_player_start");
	else
		SpawnPoints = ents.FindByClass("ent_gmp_ready_room_spawn");
	end
	
	if #SpawnPoints == 0 then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n");
		return nil;
	end
	
	local ChosenSpawnPoint;
	
	for i = 0, 6 do
		ChosenSpawnPoint = table.Random(SpawnPoints);
		
		if ChosenSpawnPoint and ChosenSpawnPoint:IsValid() and ChosenSpawnPoint:IsInWorld() and ChosenSpawnPoint != Player:GetVar("LastSpawnpoint") and (!self.LastSpawnPoint or ChosenSpawnPoint != self.LastSpawnPoint) then
			if self:IsSpawnpointSuitable(Player, ChosenSpawnPoint, i==6) then
				self.LastSpawnPoint = ChosenSpawnPoint;
				Player:SetVar("LastSpawnpoint", ChosenSpawnPoint);
				
				return ChosenSpawnPoint;
			end
		end
	end
	
	GAMEMODE:SetPlayerSpeed(Player, 400, 400)
	
	return ChosenSpawnPoint;
end

function GM:Initialize ( )
	--require("tmysql")
	--tmysql.initialize("ttt4.site.nfoservers.com", "ttt4", "KwaLKNW95v", "ttt4_gmp", 3306, 2, 2);
	
	
	
		RunConsoleCommand("sv_allowdownload", "1");
		RunConsoleCommand("sv_allowupload", "0");
		RunConsoleCommand("sv_usermessage_maxsize", "5000");
		--RunConsoleCommand("sv_downloadurl", "http://74.63.220.45/74.63.220.45-27015");

	
	GAMEMODE.numPlayers = 32
	RunConsoleCommand("sv_visiblemaxplayers", "32");
	--RunConsoleCommand("hostname", "[BB] Bit-Block #4 | GMod Party | TF2 Tower Defense | 1.3 | Fast Dl ");

end

function GM:PlayerInitialSpawn ( Player )

	Player:SetNetworkedInt('gmp_stars', math.Clamp(tonumber(Player:GetPData('gmp_stars','0')), 0, 99));
	Player:GetTable().GMRCash = -1;
	Player:GetTable().PERPCash = -1;
	
	local pdatamdl = Player:GetPData('pmodel')
	if pdatamdl then mdl = pdatamdl else mdl = malePlayermodels[math.random(#malePlayermodels)] Player:SetPData('pmodel',mdl) end
	
	/*tmysql.query("SELECT `steamid` FROM `gmp_users` WHERE `steamid`='" .. Player:SteamID() .. "'",
		function ( PlayerInformation )
			if PlayerInformation and PlayerInformation[1] and PlayerInformation[1][1] then
				Player:LoadInformation();
			else
				Player:CreateProfile();
			end
		end
	);*/
end

function GM:PlayerLoadout ( Player )
	GAMEMODE:SetPlayerSpeed(Player, 200, 200)
end

function GM:Think ( ) 
	if !self.GamePlaying then
		// We're waiting for the next minigame, apparently.
		
		if self.NextGameStart < CurTime() then
			self:SelectMinigame();
		end
	else
		// See if we're in the "loading" stage or think stage
		
		if !self.MinigamePlayBegin then
			if self.MinigameTimeLimit and self.MinigameTimeLimit != 0 and CurTime() > self.MinigameTimeLimit then
				// Time's up - blow the whistle
				self:MinigameHitTimeLimit();
			else
				// We've begun!
				self:MinigameThink();
			end
		elseif self.SetupTime and self.SetupTime < CurTime() then	
			// Setup the minigame after a second of delay...
			self:SetupMinigame();
		elseif self.MinigamePreThinkBegin < CurTime() then	
			if self.MinigamePlayBegin != 0 then
				// Wait until the minigame says we can start
				if self.MinigamePlayBegin < CurTime() then
					self:StartMinigame();
				end
			else
				// Ask the minigame if we should start the countdown.
				self:RunMinigamePreThink();
			end
		end
	end
	
	// Get rid of their flashlight!
	for k, v in pairs(player.GetAll()) do
		if v:FlashlightIsOn() then
			v:Flashlight(false);
		end
	end
end

function GM:PlayerDeath ( Player )
	if Player:InMinigame() then
		Player:SetNWInt('gmp_losses',Player:GetNWInt('gmp_losses',0)+1)
		ChatNotify(Player:Nick()..' has lost!')
		umsg.Start('gmp_minigame_loss', Player); umsg.End();
		Player:SetNetworkedBool('gmp_minigame', false);
		self:CheckMinigameOver();
	end
	
	Player:SetColor(Color(255, 255, 255, 255));
end

function GM:PlayerDeathThink ( Player ) Player:Spawn(); end
function GM:PlayerDeathSound ( ) return true; end

function GM:PlayerShouldTakeDamage ( Victim, Attacker )
	if Attacker and Attacker:IsValid() and Attacker:IsPlayer() then
		if Victim:InMinigame() and Attacker:InMinigame() then
			return self.CurrentMinigame.EnablePVPDamage;
		end
	end
	
	if Victim:InMinigame() then
		return self.CurrentMinigame.EnablePlayerDamage;
	end
	
	return false;
end

function GM:ScalePlayerDamage ( Player, Hitgroup, DmgInfo )
	if Player:InMinigame() then
		DmgInfo:ScaleDamage(self.CurrentMinigame.PlayerDamageScale);
	end
	
	return DmgInfo;
end

function GM:PlayerNoClip ( Player )
	return Player:IsSuperAdmin() or game.SinglePlayer();
end

function GM:PlayerDisconnected ( Player )
	self:CheckMinigameOver();
end


function GM:ShouldCollide ( Ent1, Ent2 )
	if Ent1 == Ent2 then return false; end
	if !(Ent1:IsPlayer() or Ent2:IsPlayer()) then return true; end
	if Ent1:IsPlayer() and Ent2:IsPlayer() then return true; end
	local Player = Ent1; local NPlayer = Ent2; if Ent2:IsPlayer() then Player = Ent2; NPlayer = Ent1 end
	
	if NPlayer:GetClass() == 'room_blocker_tf2td' then
		return false;
	end
	
	if NPlayer:GetClass() == 'room_blocker_vip' and !Player:IsVIP() then
		return false;
	end

	return true;
end

function GM:SetupPlayerVisibility ( pl )
	if GAMEMODE.CurCamera and pl:InReadyRoom() and !pl:InMinigame() then
		AddOriginToPVS(GAMEMODE.CurCamera:GetPos());
	end
end


function GM:CanPlayerSuicide( ply )
	return false
end

