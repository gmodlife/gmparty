MINIGAME.ID = 19; // Make sure this is a unique identifier. Used to synch client and server.
MINIGAME.Name = "dont move"; // Used for display purposes only.
MINIGAME.Description = "dont"; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 2; // Minimum players required to even be considered.
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_WHITEROOM_CIRCLE; // Maximum players able to be supported.

MINIGAME.Theme = THEME_FAST; // Controls the music.
MINIGAME.SpawnZone = SPAWN_WHITEROOM_CIRCLE; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 45 * 1; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {HUD_TIME, HUD_HEALTH}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = true; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = true; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 1; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = false; // The last player standing wins?

MINIGAME.CameraLocation = "white_room"; // What camera should we use?

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	

end

// Ran on every player that is in the current minigame. Used to give any required weapons or modify appearance in any way needed. Return FACE_RANDOM to cause the player to face a random direction.
function MINIGAME.PlayerLoadout ( Player )
	Player:Give("sware_crowbar")
	return FACE_RANDOM;
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

	for k,v in pairs(player.GetAll()) do 
		if (v:GetVelocity():Length() > 16) then
			v:Kill( v:GetVelocity() * 10^3 )
			
		end
	end

end

// Ran after all players have left the arena. Delete all variables and entities used.
function MINIGAME.Cleanup ( )		
	for k, v in pairs(ents.FindByClass('sware_crowbar')) do
			v:Remove();
		end
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )	

end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	return true;
end
