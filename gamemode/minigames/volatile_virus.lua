MINIGAME.ID = 14; // Make sure this is a unique identifier. Used to synch client and server.
MINIGAME.Name = "Volatile Virus"; // Used for display purposes only.
MINIGAME.Description = "Get near another player to give them the virus"; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 2; // Minimum players required to even be considered.
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_DM_ARENA; // Maximum players able to be supported.

MINIGAME.Theme = THEME_FAST; // Controls the music.
MINIGAME.SpawnZone = SPAWN_DM_ARENA; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 0; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {HUD_HEALTH}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = false; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = true; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 1; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = true; // The last player standing wins?

MINIGAME.CameraLocation = "deathmatch_room"; // What camera should we use?

if CLIENT then
	function MINIGAME.ManipulateBones ( Player, NumBones, NumPhysBones )
		local BoneToManip = Player:LookupBone('ValveBiped.Bip01_Head1');
		local Matrix = Player:GetBoneMatrix(BoneToManip);
		
		local Percent = math.Clamp(Player:Health() / 100, 0, 1) * 2;
		Matrix:Scale(Vector(3 - Percent, 3 - Percent, 3 - Percent));
		Player:SetBoneMatrix(BoneToManip, Matrix);
	end
	
	function MINIGAME.GetVirusInfo ( UMsg )
		GAMEMODE.VirusHolder = UMsg:ReadEntity();
		
		if GAMEMODE.VirusHolder == LocalPlayer() then
			GAMEMODE.HeartColorOverride = Color(150, 255, 150, 255);
		else
			GAMEMODE.HeartColorOverride = nil;
		end
	end
	usermessage.Hook('gmp_vv', MINIGAME.GetVirusInfo);
end

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	
	MINIGAME.GivePlayerVirus = true;
end

// Ran on every player that is in the current minigame. Used to give any required weapons or modify appearance in any way needed. Return FACE_RANDOM to cause the player to face a random direction.
function MINIGAME.PlayerLoadout ( Player )
	if MINIGAME.GivePlayerVirus then
		MINIGAME.GivePlayerVirus = nil;
		MINIGAME.VirusHolder = Player;
		MINIGAME.VirusHolder:SetColor(Color(150, 255, 150, 255));
	end
		
	return FACE_RANDOM;
end

// Ran every frame after the minigame is loaded. The players are in the arena. Return true to start the countdown and halt pre-thinking.
function MINIGAME.PreThink ( )
	return true;
end

// Ran after the countdown ends. Return false to not unfreeze all players.
function MINIGAME.Start ( )
	MINIGAME.NextHealthHit = CurTime() + .25;
	MINIGAME.PlayerVirusGivable = CurTime() + 1;
	MINIGAME.HealthLoss = 1;
	
	umsg.Start('gmp_vv');
		umsg.Entity(MINIGAME.VirusHolder);
	umsg.End();
end

// Ran every tick while the minigame is being played.
function MINIGAME.Think ( )
	if MINIGAME.VirusHolder and MINIGAME.VirusHolder:IsValid() and MINIGAME.VirusHolder:IsPlayer() and MINIGAME.VirusHolder:Alive() and MINIGAME.VirusHolder:InMinigame() then
		if !MINIGAME.PlayerVirusGivable or MINIGAME.PlayerVirusGivable < CurTime() then
			local EntsNearAfflictedPlayer = ents.FindInSphere(MINIGAME.VirusHolder:GetPos(), 100); //
			
			for k, v in pairs(EntsNearAfflictedPlayer) do
				if v and v:IsValid() and v:IsPlayer() and v != MINIGAME.VirusHolder and v:InMinigame() then
					local Trace = {};
					Trace.start = v:GetPos();
					Trace.endpos = MINIGAME.VirusHolder:GetPos();
					Trace.filter = {v, MINIGAME.VirusHolder};
					
					local TraceRes1 = util.TraceLine(Trace);
					
					local Trace2 = {};
					Trace2.start = v:GetPos() + Vector(0, 0, 64);
					Trace2.endpos = MINIGAME.VirusHolder:GetPos() + Vector(0, 0, 64);
					Trace2.filter = {v, MINIGAME.VirusHolder};
					
					local TraceRes2 = util.TraceLine(Trace2);
					
					if !TraceRes1.Hit or !TraceRes2.Hit then
						MINIGAME.VirusHolder:SetColor(Color(255, 255, 255, 255));
						GAMEMODE:SetPlayerSpeed(MINIGAME.VirusHolder, 200, 200);
						
						MINIGAME.VirusHolder = v;
						MINIGAME.VirusHolder:SetColor(Color(150, 255, 150, 255));
						local ToAdd = ((100 - MINIGAME.VirusHolder:Health()) * 2);
						GAMEMODE:SetPlayerSpeed(MINIGAME.VirusHolder, 200 + ToAdd, 200 + ToAdd)
						
						MINIGAME.PlayerVirusGivable = CurTime() + 2;
						MINIGAME.NextHealthHit = CurTime() + .25;
						
						umsg.Start('gmp_vv');
							umsg.Entity(MINIGAME.VirusHolder);
						umsg.End();
						
						break;
					end
				end
			end
		end
	
	
		if MINIGAME.NextHealthHit and MINIGAME.NextHealthHit < CurTime() then
			MINIGAME.NextHealthHit = CurTime() + .25;
			MINIGAME.HealthLoss = math.Clamp(MINIGAME.HealthLoss + .005, 1, 3);
			
			local NewHealth = MINIGAME.VirusHolder:Health() - math.floor(MINIGAME.HealthLoss);
			
			if NewHealth <= 0 then
				for i = 0, 16 do
					local effectdata = EffectData();
						effectdata:SetOrigin(MINIGAME.VirusHolder:GetPos() + i * Vector(0,0,4));
					util.Effect("gmp_bloodstream", effectdata);
				end
			
				MINIGAME.VirusHolder:Kill();
			else
				MINIGAME.VirusHolder:SetHealth(NewHealth);
				GAMEMODE:SetPlayerSpeed(MINIGAME.VirusHolder, 200 + ((100 - NewHealth) * 2), 200 + ((100 - NewHealth) * 2))
			end
		end
	else
		local AvailablePlayers = {};
		for k, v in pairs(player.GetAll()) do
			if v:InMinigame() then
				table.insert(AvailablePlayers, v);
			end
		end
		
		local AffectedPlayer = table.Random(AvailablePlayers);
		if AffectedPlayer and IsValid(AffectedPlayer) then
			MINIGAME.VirusHolder = AffectedPlayer;
			MINIGAME.VirusHolder:SetColor(Color(150, 255, 150, 255));
		end
	end
end

// Ran after all players have left the arena. Delete all variables and entities used.
function MINIGAME.Cleanup ( )		
	MINIGAME.VirusHolder = nil;
	MINIGAME.NextHealthHit = nil;
	MINIGAME.PlayerVirusGivable = nil;
	MINIGAME.HealthLoss = nil;
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )	

end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	return false;
end
