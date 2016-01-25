MINIGAME.ID = 2; // Make sure this is a unique identifier. Used to synch client and server.
MINIGAME.Name = "Mortar Mayhem"; // Used for display purposes only.
MINIGAME.Description = "Avoid the mortar for as long as possible"; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 2 // Minimum players required to even be considered.
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_OUTDOORS; // Maximum players able to be supported.

MINIGAME.Theme = THEME_FAST; // Controls the music.
MINIGAME.SpawnZone = SPAWN_OUTDOORS; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 60 * 2; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {HUD_HEALTH, HUD_TIME}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = false; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = true; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 1; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = true; // The last player standing wins?

MINIGAME.CameraLocation = "field_room"; // What camera should we use?

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	

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
	MINIGAME.TimeProgression = 3;
	MINIGAME.NextCannonBlast = MINIGAME.TimeProgression;
end

// Ran every tick while the minigame is being played.
function MINIGAME.Think ( )
	if CurTime() > MINIGAME.NextCannonBlast then
		MINIGAME.TimeProgression = math.Clamp(MINIGAME.TimeProgression - .1, .5, 3);
		MINIGAME.NextCannonBlast = CurTime() + MINIGAME.TimeProgression;
		
		for i = 1, math.random(2, 3) do
			local PlacePos = GAMEMODE.ChooseRandomLocation_Trigger('outdoors', TRACE_DOWN);
			
			local TargetID = math.random(0, 10000);
			
			local TraceUp = {}
			TraceUp.start = PlacePos;
			TraceUp.endpos = PlacePos + Vector(0, 0, 10000);
			
			local TraceRes = util.TraceLine(TraceUp)
			local NewPlace = TraceRes.HitPos;
			
			local Delay = math.Clamp(MINIGAME.TimeProgression * 2, 0, 2);
			
			local mortar = ents.Create( "func_tankmortar" )	
				mortar:SetPos(NewPlace)
				mortar:SetAngles(Angle( 90, 0, 0 ))
				mortar:SetKeyValue("iMagnitude", 100)
				mortar:SetKeyValue("firedelay", Delay)
				mortar:SetKeyValue("warningtime", Delay)
				mortar:SetKeyValue("incomingsound", "Weapon_Mortar.Incomming" )
			mortar:Spawn()
			
			local target = ents.Create( "info_target" )
				target:SetPos(PlacePos)
				target:SetName("gmp_target_" .. tostring(TargetID))
			target:Spawn()
			
			mortar:Fire("SetTargetEntity", target:GetName(), 0)
			mortar:Fire("Activate", "", 0)
			mortar:Fire("FireAtWill", "", 0)
			mortar:Fire("Deactivate", "", 2)
			mortar:Fire("kill", "", Delay * 2.5)
			target:Fire("kill", "", Delay * 2.5)
		end
	end
end

// Ran after all players have left the arena. Delete all variables and entities used.
function MINIGAME.Cleanup ( )	
	MINIGAME.TimeProgression = nil;
	MINIGAME.NextCannonBlast = nil;
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )

end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	return true;
end
