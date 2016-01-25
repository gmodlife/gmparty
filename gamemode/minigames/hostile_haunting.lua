MINIGAME.ID = 4; // Make sure this is a unique identifier. Used to synch client and server. 
MINIGAME.Name = "Hostile Haunting"; // Used for display purposes only.
MINIGAME.Description = "Avoid the ghosts for as long as possible"; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 2; // Minimum players required to even be considered.
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_HALLWAY; // Maximum players able to be supported.

MINIGAME.Theme = THEME_FAST; // Controls the music.
MINIGAME.SpawnZone = SPAWN_HALLWAY; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 60 * 2; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {HUD_TIME}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = false; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = true; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 1; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = true; // The last player standing wins?

MINIGAME.CameraLocation = "hallway_room_start"; // What camera should we use?

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	

end

// Ran on every player that is in the current minigame. Used to give any required weapons or modify appearance in any way needed. Return FACE_RANDOM to cause the player to face a random direction.
function MINIGAME.PlayerLoadout ( Player )
	MINIGAME.TimeDelay = 2;
	MINIGAME.ToMake = 1;
	MINIGAME.Speed = 500
	MINIGAME.NextBooCreation = CurTime() + MINIGAME.TimeDelay;
	MINIGAME.Boos = {};
end

// Ran every frame after the minigame is loaded. The players are in the arena. Return true to start the countdown and halt pre-thinking.
function MINIGAME.PreThink ( )
	return true;
end

// Ran after the countdown ends. Return false to not unfreeze all players.
function MINIGAME.Start ( )

end

// Ran every tick while the minigame is being played.
function MINIGAME.Think ( )
	if MINIGAME.NextBooCreation and CurTime() > MINIGAME.NextBooCreation then
		MINIGAME.TimeDelay = math.Clamp(MINIGAME.TimeDelay - .2, .5, 2);
		
		if MINIGAME.TimeDelay <= .5 then
			MINIGAME.ToMake = MINIGAME.ToMake + .05;
			MINIGAME.Speed = math.Clamp(MINIGAME.Speed + 50, 500, 1500)
		end
			
		MINIGAME.NextBooCreation = CurTime() + MINIGAME.TimeDelay;
		
		for i = 1, math.floor(MINIGAME.ToMake) do
			local DodgeballPos, DodgeballAng = GAMEMODE.ChooseRandomLocation_Trigger('hallway_end');
			
			local Dodgeball = ents.Create('ent_boo');
			Dodgeball:SetPos(DodgeballPos);
			Dodgeball:SetAngles(Angle(0, 180, 0));
			Dodgeball:Spawn();
			table.insert(MINIGAME.Boos, Dodgeball);
						
			Dodgeball:GetPhysicsObject():SetVelocity(Angle(0, 180, 0):Forward() * MINIGAME.Speed) 
		end
	end
end

// Ran after all players have left the arena. Delete all variables and entities used.
function MINIGAME.Cleanup ( )	
	if MINIGAME.Boos then
		for k, v in pairs(MINIGAME.Boos) do
			if v and v:IsValid() then
				v:Remove();
			end
		end
		
		MINIGAME.Boos = nil;
	end
	
	MINIGAME.NextBooCreation = nil;
	MINIGAME.TimeDelay = nil;
	MINIGAME.ToMake = nil;
	MINIGAME.Speed = nil;
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )

end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	Player:AddProgress(41, 1);
	return true;
end
