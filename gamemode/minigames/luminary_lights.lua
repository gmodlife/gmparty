MINIGAME.ID = 10; // Make sure this is a unique identifier. Used to synch client and server. 
MINIGAME.Name = "Luminary Lights"; // Used for display purposes only.
MINIGAME.Description = "Classic red light green light game"; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 2; // Minimum players required to even be considered.
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_HALLWAY; // Maximum players able to be supported.

MINIGAME.Theme = THEME_SLOW; // Controls the music.
MINIGAME.SpawnZone = SPAWN_HALLWAY; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 60 * 2; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {HUD_TIME}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = false; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = false; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 1; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = false; // The last player standing wins?

MINIGAME.CameraLocation = "hallway_room_end"; // What camera should we use?

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	
	MINIGAME.Lights = {};
	for k, v in pairs(ents.FindByClass('ent_gmp_ll_light')) do		
		local NewLight = ents.Create('ent_ll_light');
		NewLight:SetPos(v:GetPos() + Vector(0, 0, 5));
		NewLight:Spawn();
		NewLight:SetColor(Color(255, 0, 0, 255));
		
		table.insert(MINIGAME.Lights, NewLight);
	end
end

// Ran on every player that is in the current minigame. Used to give any required weapons or modify appearance in any way needed. Return FACE_RANDOM to cause the player to face a random direction.
function MINIGAME.PlayerLoadout ( Player )

end

// Ran every frame after the minigame is loaded. The players are in the arena. Return true to start the countdown and halt pre-thinking.
function MINIGAME.PreThink ( )
	return true;
end

// Ran after the countdown ends. Return false to not unfreeze all players.
function MINIGAME.Start ( )
	for k, v in pairs(MINIGAME.Lights) do
		v:SetColor(Color(0, 255, 0, 255));
	end
	
	MINIGAME.IsGreenLight = true;
	MINIGAME.NextLightWarn = CurTime() + math.random(2, 5);
	MINIGAME.NextLightShift = MINIGAME.NextLightWarn + (math.random(5, 25) * .1)
end

// Ran every tick while the minigame is being played.
function MINIGAME.Think ( )
	if MINIGAME.NextLightWarn and MINIGAME.NextLightWarn < CurTime() then
		MINIGAME.NextLightWarn = nil;
		
		for k, v in pairs(MINIGAME.Lights) do
			v:SetColor(Color(255, 150, 0, 255));
		end
	end
	
	if MINIGAME.NextLightShift and MINIGAME.NextLightShift < CurTime() then
		MINIGAME.NextLightShift = nil;
		MINIGAME.IsGreenLight = !MINIGAME.IsGreenLight;
		
		for k, v in pairs(MINIGAME.Lights) do
			if MINIGAME.IsGreenLight then
				v:SetColor(Color(0, 255, 0, 255));
			else
				v:SetColor(Color(255, 0, 0, 255));
			end
		end
		
		if MINIGAME.IsGreenLight then
			MINIGAME.NextLightWarn = CurTime() + math.random(1, 4);
			MINIGAME.NextLightShift = MINIGAME.NextLightWarn + (math.random(5, 25) * .1);
		else
			MINIGAME.NextLightShift = CurTime() + math.random(2, 5);
		end
	end
	
	if !MINIGAME.IsGreenLight then
		for k, v in pairs(player.GetAll()) do
			if v:InMinigame() and v:GetVelocity():Length() > 15 then
				v:Kill();
			end
		end
	end
end

// Ran after all players have left the arena. Delete all variables and entities used.
function MINIGAME.Cleanup ( )	
	for k, v in pairs(MINIGAME.Lights) do
		if v and v:IsValid() then
			v:Remove();
		end
		
		MINIGAME.Lights[k] = nil;
	end
	
	MINIGAME.Lights = nil;
	MINIGAME.IsGreenLight = nil;
	MINIGAME.NextLightShift = nil;
	MINIGAME.NextLightWarn = nil;
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )
	if ID == 'hallway_end' then
		for k, v in pairs(player.GetAll()) do
			if v:InMinigame() and v != Player then
				v:Kill();
			end
		end
		
		if CurTime() - GAMEMODE.LastMinigameBegin <= 30 then
			Player:AddProgress(42, 1);
		end
		
		Player:DeclareWinner();
	end
end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	return false;
end
