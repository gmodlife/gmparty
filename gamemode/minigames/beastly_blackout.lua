MINIGAME.ID = 3; // Make sure this is a unique identifier. Used to synch client and server.
MINIGAME.Name = "Beastly Blackout"; // Used for display purposes only.
MINIGAME.Description = "Avoid the antlion guard for as long as possible"; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 2; // Minimum players required to even be considered.
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_BLACKROOM_CIRCLE; // Maximum players able to be supported.

MINIGAME.Theme = THEME_SLOW; // Controls the music.
MINIGAME.SpawnZone = SPAWN_BLACKROOM_CIRCLE; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 60 * 4; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {HUD_HEALTH, HUD_TIME}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = false; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = true; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 5; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = true; // The last player standing wins?

MINIGAME.CameraLocation = "dark_room"; // What camera should we use?

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	
	local AntlionPos, AntlionAng = GAMEMODE.ChooseRandomLocation('blackroom_center');
	
	MINIGAME.AntlionGuards = {};
	local AntlionGuard = ents.Create('npc_antlionguard');
	AntlionGuard:SetPos(AntlionPos);
	AntlionGuard:Spawn();
	AntlionGuard:SetNPCState(NPC_STATE_NONE);
	table.insert(MINIGAME.AntlionGuards, AntlionGuard);
	
	MINIGAME.Lights = {};
	for i = 1, 6 do
		local LightStartPos = GAMEMODE.ChooseRandomLocation_Trigger('blackroom_ceiling', TRACE_UP);
		
		local NewLight = ents.Create("ent_lamp");
		NewLight:SetFlashlightTexture("effects/flashlight001");
		NewLight:SetLightColor(255, 255, 255)
		NewLight:SetPos(LightStartPos - Vector(0, 0, 25));
		NewLight:Spawn();
		NewLight:GetPhysicsObject():Sleep();
				
		table.insert(MINIGAME.Lights, NewLight);
	end
end

// Ran on every player that is in the current minigame. Used to give any required weapons or modify appearance in any way needed. Return FACE_RANDOM to cause the player to face a random direction.
function MINIGAME.PlayerLoadout ( Player )
	return MINIGAME.AntlionGuards[1]:GetPos();
end

// Ran every frame after the minigame is loaded. The players are in the arena. Return true to start the countdown and halt pre-thinking.
function MINIGAME.PreThink ( )
	return true;
end

// Ran after the countdown ends. Return false to not unfreeze all players.
function MINIGAME.Start ( )
	MINIGAME.AntlionGuards[1]:SetNPCState(NPC_STATE_COMBAT);
	MINIGAME.NextLightOff = CurTime() + 15;
	MINIGAME.NextAntlionSpawn = CurTime() + 30;
end

// Ran every tick while the minigame is being played.
function MINIGAME.Think ( )
	if MINIGAME.NextLightOff and MINIGAME.NextLightOff < CurTime() then
		MINIGAME.NextLightOff = CurTime() + 15;
		
		local DeletedOne = false;
		for k, v in pairs(MINIGAME.Lights) do
			local Effect = EffectData();
				Effect:SetOrigin(v:GetPos());
			util.Effect("gmp_spark", Effect);
			
			sound.Play(Sound('ambient/energy/spark' .. math.random(5, 6) ..'.wav'), v:GetPos(), 75, 100);

			v:Remove();
			MINIGAME.Lights[k] = nil;
			DeletedOne = true;
			
			break;
		end
		
		if !DeletedOne then MINIGAME.NextLightOff = nil; end
	end
	
	if MINIGAME.NextAntlionSpawn < CurTime() then
		MINIGAME.NextAntlionSpawn = CurTime() + 30;
		
		local AntlionPos, AntlionAng = GAMEMODE.ChooseRandomLocation('blackroom_center');
		
		local AntlionGuard = ents.Create('npc_antlionguard');
		AntlionGuard:SetPos(AntlionPos);
		AntlionGuard:Spawn();
		table.insert(MINIGAME.AntlionGuards, AntlionGuard);
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
	
	for k, v in pairs(MINIGAME.AntlionGuards) do
		if v and v:IsValid() then
			v:Remove();
		end
		
		MINIGAME.AntlionGuards[k] = nil;
	end
	
	MINIGAME.AntlionGuards = nil;
	MINIGAME.Lights = nil;
	MINIGAME.NextLightOff = nil;
	MINIGAME.NextAntlionSpawn = nil;
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )

end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	return true;
end
