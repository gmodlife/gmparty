MINIGAME.ID = 11; // Make sure this is a unique identifier. Used to synch client and server.
MINIGAME.Name = "Craving Cannibal"; // Used for display purposes only.
MINIGAME.Description = '"Eat" babies to stay alive'; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 5 // Minimum players required to even be considered.  
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_OUTDOORS; // Maximum players able to be supported.

MINIGAME.Theme = THEME_SLOW; // Controls the music.
MINIGAME.SpawnZone = SPAWN_OUTDOORS; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 0; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {HUD_HEALTH}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = false; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = true; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 1; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = true; // The last player standing wins?

MINIGAME.CameraLocation = "field_room"; // What camera should we use?

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	
	MINIGAME.Babies = {};
	MINIGAME.BabyDropDelay = 2;
	MINIGAME.NumBabiesToDrop = 5;
end

// Ran on every player that is in the current minigame. Used to give any required weapons or modify appearance in any way needed. Return FACE_RANDOM to cause the player to face a random direction.
function MINIGAME.PlayerLoadout ( Player )
	return FACE_RANDOM;
end

// Ran every frame after the minigame is loaded. The players are in the arena. Return true to start the countdown and halt pre-thinking.
function MINIGAME.PreThink ( )
	return true;
end

// Ran after the countdown ends. Return false to not unfreeze all players.
function MINIGAME.Start ( )
	MINIGAME.NextBabyDrop = CurTime() + MINIGAME.BabyDropDelay;
	MINIGAME.NextHealthDrop = CurTime() + .5;
end

// Ran every tick while the minigame is being played.
function MINIGAME.Think ( )
	if MINIGAME.NextBabyDrop < CurTime() then
		MINIGAME.BabyDropDelay = MINIGAME.BabyDropDelay + .2
		MINIGAME.NumBabiesToDrop = math.Clamp(MINIGAME.NumBabiesToDrop - .2, 1, 5);
		MINIGAME.NextBabyDrop = CurTime() + MINIGAME.BabyDropDelay;
		
		for i = 1, math.floor(MINIGAME.NumBabiesToDrop) do
			local PlacePos = GAMEMODE.ChooseRandomLocation_Trigger('outdoors', TRACE_DOWN);
			
			local NewBaby = ents.Create('ent_baby');
			NewBaby:SetPos(PlacePos + Vector(0, 0, 5));
			NewBaby:Spawn();
			table.insert(MINIGAME.Babies, NewBaby);
		end
	end
	
	if MINIGAME.NextHealthDrop < CurTime() then
		MINIGAME.NextHealthDrop = CurTime() + .5;
		
		for k, v in pairs(player.GetAll()) do
			if v and v:InMinigame() then
				local NewHealth = v:Health() - 1;

				if NewHealth <= 0 then
					v:Kill();
				else
					v:SetHealth(NewHealth);
				end
			end
		end
	end
end

// Ran after all players have left the arena. Delete all variables and entities used.
function MINIGAME.Cleanup ( )	
	for k, v in pairs(MINIGAME.Babies) do
		if v and v:IsValid() then
			v:Remove();
		end
		
		MINIGAME.Babies[k] = nil;
	end
	
	MINIGAME.Babies = nil;
	MINIGAME.NextBabyDrop = nil;
	MINIGAME.BabyDropDelay = nil;
	MINIGAME.NumBabiesToDrop = nil;
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )

end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	return true;
end
