MINIGAME.ID = 6; // Make sure this is a unique identifier. Used to synch client and server.
MINIGAME.Name = "Crumbling Crates"; // Used for display purposes only.
MINIGAME.Description = "Stay atop the crates for as long as possible"; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 6; // Minimum players required to even be considered.
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_SPIKEROOM_LARGE; // Maximum players able to be supported.

MINIGAME.Theme = THEME_SLOW; // Controls the music.
MINIGAME.SpawnZone = SPAWN_SPIKEROOM_LARGE; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 0; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = false; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = true; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 1; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = true; // The last player standing wins?

MINIGAME.CameraLocation = "spikes_room"; // What camera should we use?

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

local Whatever = 255 / 100;

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	
	MINIGAME.Boxes = {};
	
	local NumCrates = 7;
	local HCrates = math.floor(NumCrates * .5)
	local BoxOrigin = GAMEMODE.ChooseRandomLocation('spikes_center');
	
	local OurBox = ents.Create('prop_physics');
	OurBox:SetPos(BoxOrigin);
	OurBox:SetModel("models/props_junk/wood_crate001a.mdl");
	OurBox:Spawn();
	OurBox:SetMoveType(MOVETYPE_NONE);
	table.insert(MINIGAME.Boxes, OurBox);
	
	local OBBMax, OBBMin = OurBox:OBBMaxs(), OurBox:OBBMins();
	local Size = OBBMax - OBBMin;
	
	local ToAddVector = Vector(Size.x, Size.y, 0);
	local ToAdd_X = Vector(Size.x, 0, 0);
	local ToAdd_Y = Vector(0, Size.y, 0);

	for x = HCrates * -1, HCrates do	
		for y = HCrates * -1, HCrates do
			if !(x ==0 and y == 0) then
				local OurBox = ents.Create('prop_physics');
				OurBox:SetPos(BoxOrigin + Vector(Size.x * x, Size.y * y, 0));
				OurBox:SetModel("models/props_junk/wood_crate001a.mdl");
				OurBox:Spawn();
				OurBox:SetMoveType(MOVETYPE_NONE);
				table.insert(MINIGAME.Boxes, OurBox);
			end
		end
	end
	
	for k, v in pairs(MINIGAME.Boxes) do
		v:SetColor(Color(0, 255, 0, 255));
		v:GetTable().NumHealth = 100;
	end
	
	MINIGAME.NextCrateHealthCheck = CurTime() + .1;
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

end

// Ran every tick while the minigame is being played.
function MINIGAME.Think ( )
	if MINIGAME.NextCrateHealthCheck < CurTime() then
		MINIGAME.NextCrateHealthCheck = CurTime() + .1
		
		for k, v in pairs(player.GetAll()) do
			if v and v:IsValid() and v:IsPlayer() and v:InMinigame() then
				local ClosestBox, ClosestBoxDist = nil, 65;
				for _, ent in pairs(ents.FindInSphere(v:GetPos(), 64)) do
					if ent:GetModel() == "models/props_junk/wood_crate001a.mdl" then
						local Dist = ent:GetPos():Distance(v:GetPos());
						
						if Dist < ClosestBoxDist then
							ClosestBox = ent;
							ClosestBoxDist = Dist;
						end
					end
				end
				
				if ClosestBox then
					ClosestBox:GetTable().NumHealth = ClosestBox:GetTable().NumHealth - 1;
						
					if ClosestBox:GetTable().NumHealth <= 0 then
						ClosestBox:Fire('sethealth', '', 0);
					else
						local SetterColor = math.Clamp(Whatever * ClosestBox:GetTable().NumHealth, 0, 255);
						ClosestBox:SetColor(Color(255 - SetterColor, SetterColor, 0, 255));
					end
				end
			end
		end
	end
end

// Ran after all players have left the arena. Delete all variables and entities used.
function MINIGAME.Cleanup ( )		
	for k, v in pairs(MINIGAME.Boxes) do
		if v and v:IsValid() then
			v:Remove();
		end
		
		MINIGAME.Boxes[k] = nil;
	end
	
	MINIGAME.Boxes = nil;
	MINIGAME.NextCrateHealthCheck = nil;
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )	

end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	return false;
end
