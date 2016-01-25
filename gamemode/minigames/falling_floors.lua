MINIGAME.ID = 8; // Make sure this is a unique identifier. Used to synch client and server.
MINIGAME.Name = "Falling Floors"; // Used for display purposes only.
MINIGAME.Description = "Go to the indicated platform"; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 4; // Minimum players required to even be considered.
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_SPIKEROOM_LARGE; // Maximum players able to be supported.

MINIGAME.Theme = THEME_SLOW; // Controls the music.
MINIGAME.SpawnZone = SPAWN_SPIKEROOM_LARGE; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 60 * 10; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {HUD_TIME}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = false; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = true; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 1; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = true; // The last player standing wins?

MINIGAME.CameraLocation = "spikes_room"; // What camera should we use?

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

local Locations = {
					// Above
					{Vector(0, -143.1517, 0), Color(108, 0, 175, 255)},
					
					// Right side
					{Vector(-95.4801, -71.6280, 0), Color(255, 0, 0, 255)},
					{Vector(-190.7796, 0, 0), Color(139, 69, 19, 255)},
					{Vector(-95.2155, 71.0158, 0), Color(0, 255, 0, 255)},
					
					// Below
					{Vector(0, 143.1517, 0), Color(255, 0, 255, 255)},
					
					// Left
					{Vector(95.4801, -71.6280, 0), Color(0, 255, 255, 255)},
					{Vector(190.7796, 0, 0), Color(255, 255, 0, 255)},
					{Vector(95.2155, 71.0158, 0), Color(0, 0, 255, 255)},
				};

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	
	local BoxOrigin = GAMEMODE.ChooseRandomLocation('spikes_center');
	
	MINIGAME.Platforms = {};
	MINIGAME.Lights = {};
	
	local Platform = ents.Create('prop_physics');
	Platform:SetPos(BoxOrigin);
	Platform:SetModel('models/hunter/plates/plate2x3.mdl');
	Platform:Spawn();
	Platform:SetMoveType(MOVETYPE_NONE);
	Platform:SetColor(Color(255, 255, 255, 255));
	Platform:SetMaterial('models/debug/debugwhite');
	table.insert(MINIGAME.Platforms, Platform);
	
	MINIGAME.ZHeight = BoxOrigin.z;
	
	for k, v in pairs(Locations) do
		local NewPlatform = ents.Create('prop_physics');
		NewPlatform:SetPos(Platform:LocalToWorld(v[1]));
		NewPlatform:SetModel('models/hunter/plates/plate2x3.mdl');
		NewPlatform:Spawn();
		NewPlatform:SetMoveType(MOVETYPE_NONE);
		NewPlatform:SetColor(Color(v[2].r, v[2].g, v[2].b, v[2].a));
		NewPlatform:SetMaterial('models/debug/debugwhite');
		table.insert(MINIGAME.Platforms, NewPlatform);
	end
	
	for i = 1, 2 do
		local NewLight = ents.Create('ent_ff_light');
		NewLight:SetPos(BoxOrigin);
		NewLight:Spawn();
		NewLight:SetMoveType(MOVETYPE_NONE);
		table.insert(MINIGAME.Lights, NewLight);
		NewLight:SetColor(Color(1, 1, 1, 255));
		
		if i == 1 then
			NewLight.WhatIsMyType = true;
		end
	end
end

// Ran on every player that is in the current minigame. Used to give any required weapons or modify appearance in any way needed. Return FACE_RANDOM to cause the player to face a random direction.
function MINIGAME.PlayerLoadout ( Player )
	return FACE_RANDOM
end

// Ran every frame after the minigame is loaded. The players are in the arena. Return true to start the countdown and halt pre-thinking.
function MINIGAME.PreThink ( )
	return true;
end

// Ran after the countdown ends. Return false to not unfreeze all players.
function MINIGAME.Start ( )
	MINIGAME.PerfWarnTime = 5; //
	MINIGAME.ToDrop = 5;
	MINIGAME.NextToChange = math.random(1, 9);
	MINIGAME.WarnTime = CurTime() + (MINIGAME.PerfWarnTime * .5);
	MINIGAME.DoTime = MINIGAME.WarnTime + MINIGAME.PerfWarnTime;
	MINIGAME.FinishDoTime = MINIGAME.WarnTime + MINIGAME.PerfWarnTime + MINIGAME.ToDrop;
	MINIGAME.NextMoveUpdate = CurTime();
end

// Ran every tick while the minigame is being played.
function MINIGAME.Think ( )
	if MINIGAME.WarnTime and MINIGAME.WarnTime < CurTime() then
		MINIGAME.WarnTime = nil;
		
		local DoColor = Color(255, 255, 255, 255);
		
		if MINIGAME.NextToChange != 1 then
			DoColor = Locations[MINIGAME.NextToChange - 1][2];
		end
		
		for k, v in pairs(MINIGAME.Lights) do
			v:SetColor(Color(DoColor.r, DoColor.g, DoColor.b, DoColor.a));
		end
	end
	
	if MINIGAME.DoTime and MINIGAME.DoTime < CurTime() then
		if MINIGAME.FinishDoTime and MINIGAME.FinishDoTime < CurTime() then
			MINIGAME.PerfWarnTime = math.Clamp(MINIGAME.PerfWarnTime - .25, 1, 10);
			MINIGAME.ToDrop = math.Clamp(MINIGAME.ToDrop - .1, 2, 5);
			
			for k, v in pairs(MINIGAME.Lights) do
				v:SetColor(Color(1, 1, 1, 255));
			end
			
			for k, v in pairs(MINIGAME.Platforms) do
				v:SetSolid(SOLID_VPHYSICS);
			end
			
			MINIGAME.NextToChange = math.random(1, 9);
			MINIGAME.WarnTime = CurTime() + (MINIGAME.PerfWarnTime * .5);
			MINIGAME.DoTime = MINIGAME.WarnTime + MINIGAME.PerfWarnTime;
			MINIGAME.FinishDoTime = MINIGAME.WarnTime + MINIGAME.PerfWarnTime + MINIGAME.ToDrop;
		elseif MINIGAME.NextMoveUpdate and MINIGAME.NextMoveUpdate < CurTime() then
			MINIGAME.NextMoveUpdate = CurTime() + .05;
			
			local TimeLeft = MINIGAME.FinishDoTime - CurTime();
			local Percent = 1 - (TimeLeft / MINIGAME.ToDrop);
			
			local OurPercent;
			if Percent > .5 then
				OurPercent = 1 - ((Percent - .4) * 2);
			elseif Percent < .5 then
				OurPercent = Percent * 2
			end
				
			for k, v in pairs(MINIGAME.Platforms) do
				if k != MINIGAME.NextToChange then
					if Percent > .5 then
						v:SetSolid(SOLID_NONE);
					end
					
					local CurPos = v:GetPos();
					local col = v:GetColor()
					local r,g,b = col.r,col.g,col.b
						
					v:SetPos(Vector(CurPos.x, CurPos.y, MINIGAME.ZHeight - math.Clamp(100 * OurPercent, 0, 75)));
					v:SetColor(Color(r, g, b, math.Clamp(255 - (150 * OurPercent), 175, 255)));
				end
			end
		end
	end
end

// Ran after all players have left the arena. Delete all variables and entities used.
function MINIGAME.Cleanup ( )		
	for k, v in pairs(MINIGAME.Platforms) do
		if v and v:IsValid() then
			v:Remove();
		end
		
		MINIGAME.Platforms[k] = nil;
	end
	
	for k, v in pairs(MINIGAME.Lights) do
		if v and v:IsValid() then
			v:Remove();
		end
		
		MINIGAME.Lights[k] = nil;
	end
	
	MINIGAME.Platforms = nil;
	MINIGAME.Lights = nil;
	MINIGAME.PerfWarnTime = nil;
	MINIGAME.ToDrop = nil;
	MINIGAME.NextToChange = nil;
	MINIGAME.WarnTime = nil;
	MINIGAME.DoTime = nil;
	MINIGAME.FinishDoTime = nil;
	MINIGAME.NextMoveUpdate = nil;
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )	

end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	return true;
end
