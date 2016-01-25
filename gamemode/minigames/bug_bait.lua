MINIGAME.ID = 7; // Make sure this is a unique identifier. Used to synch client and server.
MINIGAME.Name = "Bug Bait"; // Used for display purposes only.
MINIGAME.Description = "Throw the bug bait to another player"; // The font used makes this all capped. No punctuation, please

MINIGAME.MinPlayers = 2; // Minimum players required to even be considered
MINIGAME.MaxPlayers = MAX_PLAYER_COUNT_WHITEROOM_CIRCLE; // Maximum players able to be supported.

MINIGAME.Theme = THEME_FAST; // Controls the music.
MINIGAME.SpawnZone = SPAWN_WHITEROOM_CIRCLE; // Controls the arena being used along with spawn positions

MINIGAME.TimeLimit = 60 * 3; // The time available for play. Set to 0 for no time limit.
MINIGAME.HUDElements = {HUD_HEALTH, HUD_TIME}; // A table with all HUD elements to be drawn. Return an empty table to draw nothing.

MINIGAME.EnablePVPDamage = false; // Boolean which denotes whether or not players are allowed to damage eachother.
MINIGAME.EnablePlayerDamage = true; // Boolean which denotes whether or not players will take damage from anything.
MINIGAME.PlayerDamageScale = 20; // How much damage should the player take? 1 is normal / default.

MINIGAME.LastStanding = true; // The last player standing wins?

MINIGAME.CameraLocation = "white_room"; // What camera should we use?

if !SERVER then return false; end // The client doesn't need anything else to run properly, and it's just a waiste of memory.

// Ran when the minigame is supposed to setup ( During the minigame loading screen
function MINIGAME.Setup ( )	
	MINIGAME.GivePlayerBugbait = true;
	
	local AntlionPos, AntlionAng = GAMEMODE.ChooseRandomLocation('whiteroom_center');
	
	MINIGAME.AntlionGuards = {};
	local AntlionGuard = ents.Create('npc_antlionguard');
	AntlionGuard:SetPos(AntlionPos);
	AntlionGuard:SetModelScale(math.random(0.25,1.5),1);
	AntlionGuard:Spawn();
	AntlionGuard:SetNPCState(NPC_STATE_NONE);
	table.insert(MINIGAME.AntlionGuards, AntlionGuard);
end

// Ran on every player that is in the current minigame. Used to give any required weapons or modify appearance in any way needed. Return FACE_RANDOM to cause the player to face a random direction.
function MINIGAME.PlayerLoadout ( Player )
	if MINIGAME.GivePlayerBugbait then
		Player:Give('weapon_bugbait');
		MINIGAME.GivePlayerBugbait = nil;
	end
	
	return MINIGAME.AntlionGuards[1]:GetPos();
end

// Ran every frame after the minigame is loaded. The players are in the arena. Return true to start the countdown and halt pre-thinking.
function MINIGAME.PreThink ( )
	return true;
end

// Ran after the countdown ends. Return false to not unfreeze all players.
function MINIGAME.Start ( )
	MINIGAME.AntlionGuards[1]:SetNPCState(NPC_STATE_COMBAT);
	MINIGAME.NextAntlionSpawn = CurTime() + 15;
	
	for k, v in pairs(player.GetAll()) do
		if v:InMinigame() then
			if v:HasWeapon('weapon_bugbait') then
				MINIGAME.AntlionGuards[1]:AddEntityRelationship(v, D_HT, 99);
			else
				MINIGAME.AntlionGuards[1]:AddEntityRelationship(v, D_LI, 98);
			end
		end
	end
end

// Ran every tick while the minigame is being played.
function MINIGAME.Think ( )
	// Make sure SOMEONE has a bugbait...	
	
	for k, v in pairs(player.GetAll()) do
		v:GetTable().HasBugbait = false;
	end
	
	
	local NumBugbait = 0;
	for k, v in pairs(ents.FindByClass('weapon_bugbait')) do
		NumBugbait = NumBugbait + 1;
		
		if v:GetOwner() then
			v:GetOwner():GetTable().HasBugbait = true;
		end
	end
	
	if NumBugbait <= 0 then
		local OurPlayers = {}
		
		for k, v in pairs(player.GetAll()) do
			if v:InMinigame() then
				table.insert(OurPlayers, v);
			end
		end
		
		local OurPlayer = table.Random(OurPlayers);
		if OurPlayer and IsValid(OurPlayer) then
			OurPlayer:Give('weapon_bugbait');
		
			local Antlions = ents.FindByClass('npc_antlionguard');
			
			for p, antlion in pairs(Antlions) do
				antlion:AddEntityRelationship(OurPlayer, D_HT, 99);
			end
		end
	end
	
	// See if we needa add more antlion guards
	if MINIGAME.NextAntlionSpawn < CurTime() then
		MINIGAME.NextAntlionSpawn = CurTime() + 20;
		
		local AntlionPos, AntlionAng = GAMEMODE.ChooseRandomLocation('whiteroom_center');
		
		local AntlionGuard = ents.Create('npc_antlionguard');
		AntlionGuard:SetPos(AntlionPos);
		AntlionGuard:SetModelScale(math.random(0.25,1.5),1);
		AntlionGuard:Spawn();
		table.insert(MINIGAME.AntlionGuards, AntlionGuard);
		
		for k, v in pairs(player.GetAll()) do
			if v:InMinigame() then
				if v:GetTable().HasBugbait then
					AntlionGuard:AddEntityRelationship(v, D_HT, 99);
				else
					AntlionGuard:AddEntityRelationship(v, D_LI, 98);
				end
			end
		end
	end
	
	// Track all the bugbait flying around
	for k, v in pairs(ents.FindByClass('npc_grenade_bugbait')) do
		for _, Player in pairs(player.GetAll()) do
			if Player:InMinigame() and !v:GetTable().HasBugbait then				
				if v:GetPos():Distance(Player:GetPos()) < 60 then
					v:Remove(); // :(
					
					local Antlions = ents.FindByClass('npc_antlionguard');
					
					for l, oldplayer in pairs(player.GetAll()) do
						if oldplayer:GetTable().HasBugbait then
							oldplayer:StripWeapon('weapon_bugbait');
							
							for p, antlion in pairs(Antlions) do
								antlion:AddEntityRelationship(oldplayer, D_LI, 98);
							end
							
							break;
						end
					end
					
					Player:Give('weapon_bugbait');
					
					for p, antlion in pairs(Antlions) do
						antlion:AddEntityRelationship(Player, D_HT, 99);
					end
				end
			end
		end
	end
end

// Ran after all players have left the arena. Delete all variables and entities used.
function MINIGAME.Cleanup ( )		
	for k, v in pairs(MINIGAME.AntlionGuards) do
		if v and v:IsValid() then
			v:Remove();
		end
		
		MINIGAME.AntlionGuards[k] = nil;
	end
	
	MINIGAME.AntlionGuards = nil;
	MINIGAME.NextAntlionSpawn = nil;
end

// Ran when a player hits a trigger brush
function MINIGAME.MapTrigger ( Player, ID )	

end

// Ran after the time runs out. Return true to make player win, false to lose.
function MINIGAME.TimeLimitReached ( Player )
	return false;
end
