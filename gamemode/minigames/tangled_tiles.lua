MINIGAME.ID = 15; // Make sure this is a unique identifier. Used to synch client and server.
MINIGAME.Name = "Tangled Tiles"; // Used for display purposes only.
MINIGAME.Description = "Make it to the indicated location before time runs out"; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 2; // Minimum players required to even be considered.
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_TILES; // Maximum players able to be supported.

MINIGAME.Theme = THEME_FAST; // Controls the music.
MINIGAME.SpawnZone = SPAWN_TILES; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 0; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {HUD_FAKE_TIME}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = false; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = true; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 1; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = true; // The last player standing wins?

MINIGAME.CameraLocation = "tiles_room"; // What camera should we use?

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	

end

// Ran on every player that is in the current minigame. Used to give any required weapons or modify appearance in any way needed. Return FACE_RANDOM to cause the player to face a random direction.
function MINIGAME.PlayerLoadout ( Player )
	Player:GetTable().MadeToPoint = nil;
end

// Ran every frame after the minigame is loaded. The players are in the arena. Return true to start the countdown and halt pre-thinking.
function MINIGAME.PreThink ( )
	return true;
end

// Ran after the countdown ends. Return false to not unfreeze all players.
function MINIGAME.Start ( )
	MINIGAME.TimeToGetThere = 60;

	for k, v in pairs(player.GetAll()) do
		if v:InMinigame() then
			v:StartFakeTimer(MINIGAME.TimeToGetThere);
			v:GetTable().NumTilesReached = 0;
		end
	end
	
	MINIGAME.CurrentRoundOver = CurTime() + MINIGAME.TimeToGetThere;
	
	local SpawnPos = GAMEMODE.ChooseRandomLocation('tiles_up');
	MINIGAME.Display = ents.Create('ent_tt_light');
	MINIGAME.Display:SetPos(SpawnPos);
	MINIGAME.Display:Spawn();
end

// Ran every tick while the minigame is being played.
function MINIGAME.Think ( )
	local Exception = true;
	for k, v in pairs(player.GetAll()) do
		if v:InMinigame() and !v:GetTable().MadeToPoint then
			Exception = false;
			return false;
		end
	end

	if (MINIGAME.CurrentRoundOver and MINIGAME.CurrentRoundOver < CurTime()) or Exception then
		MINIGAME.TimeToGetThere = math.Clamp(MINIGAME.TimeToGetThere - 5, 15, 60);

		for k, v in pairs(player.GetAll()) do
			if v:InMinigame() then
				if v:GetTable().MadeToPoint then
					v:GetTable().MadeToPoint = nil;
					v:StartFakeTimer(MINIGAME.TimeToGetThere);
				else
					v:Kill();
				end
			end
		end
		
		MINIGAME.CurrentRoundOver = CurTime() + MINIGAME.TimeToGetThere;
		
		if MINIGAME.Display and MINIGAME.Display:IsValid() then
			MINIGAME.Display:Remove();
			MINIGAME.Display = nil;
		end
		
		local SpawnPos = GAMEMODE.ChooseRandomLocation('tiles_up');
		MINIGAME.Display = ents.Create('ent_tt_light');
		MINIGAME.Display:SetPos(SpawnPos);
		MINIGAME.Display:Spawn();
	end
end

// Ran after all players have left the arena. Delete all variables and entities used.
function MINIGAME.Cleanup ( )	
	MINIGAME.TimeToGetThere = nil;
	MINIGAME.CurrentRoundOver = nil;
	
	if MINIGAME.Display and MINIGAME.Display:IsValid() then
		MINIGAME.Display:Remove();
		MINIGAME.Display = nil;
	end
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )

end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	return true;
end
