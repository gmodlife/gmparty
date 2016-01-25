function GM:SelectMinigame ( ) 
	// Time to start!
	// Get how many players we have to work with
	local AvailablePlayers = 0;
	local WaitingPlayers = {};
			
	for k, v in pairs(player.GetAll()) do
		v:GetTable().Tosspot = nil;
		if v:InReadyRoom() then
			AvailablePlayers = AvailablePlayers + 1;
			table.insert(WaitingPlayers, v);
		end
	end
			
	if AvailablePlayers == 0 then				
		self.NextGameStart = CurTime() + GAMEMODE.CountdownTime;
				
		umsg.Start('gmp_minigame_restart_countdown'); 
		umsg.End();
				
		return false;
	end
	
	// Now scan through our GMod Party to see which games are available...
	local AvailableGMod Party_Prelim = {};
	for ID, MINIGAME in pairs(self.MinigameDatabase) do
		if AvailablePlayers >= MINIGAME.MinPlayers and MINIGAME.LastPlayID == 0 then
			table.insert(AvailableGMod Party_Prelim, MINIGAME);
		end
	end
			
	// See if we have enough to sort out the last one...
	local AvailableGMod Party = {};
	if #AvailableGMod Party_Prelim > 1 then				
		for k, v in pairs(AvailableGMod Party_Prelim) do
			if v.ID != self.LastMinigame then
				table.insert(AvailableGMod Party, v);
			end
		end
	elseif #AvailableGMod Party_Prelim == 1 then
		AvailableGMod Party = AvailableGMod Party_Prelim;
	end
			
	// Make sure we have a minigame! :<
	if #AvailableGMod Party == 0 then				
		// Oh no! No available GMod Party!
		umsg.Start('gmp_minigame_waiting');
		umsg.End();
				
		self.NextGameStart = self.NextGameStart + 1;
		return false;
	end
			
	// Time to pick a minigame... hmmmm... which to choose...
	local Minigame = table.Random(AvailableGMod Party);
	
	for ID, MINIGAME in pairs(self.MinigameDatabase) do
		MINIGAME.LastPlayID = math.Clamp(MINIGAME.LastPlayID - 1, 0, 10);
	end
	
	if AvailablePlayers > Minigame.MaxPlayers then
		for i = 1, AvailablePlayers - Minigame.MaxPlayers do
			local LowestSkipped = CurTime() + 1;
			local LowestSkippedPerp;
			
			for k, v in pairs(WaitingPlayers) do
				if !v:GetTable().LastSkipTime or v:GetTable().LastSkipTime < LowestSkipped then
					LowestSkipped = v:GetTable().LastSkipTime or 0;
					LowestSkippedPerp = k;
				end
			end
			
			if LowestSkippedPerp then
				WaitingPlayers[LowestSkippedPerp]:GetTable().LastSkipTime = CurTime();
				WaitingPlayers[LowestSkippedPerp] = nil;
			end
		end
	end
	
	Minigame.LastPlayID = 5; //
	
	self.GamePlaying = true;
	self.MinigamePreThinkBegin = CurTime() + GAMEMODE.SetupPhaseTime;
	self.MinigamePlayBegin = 0;
	self.CurrentMinigame = Minigame;
	self.SetupTime = CurTime() + 1;
	self.LastMinigame = Minigame.ID;
	
	for k, v in pairs(WaitingPlayers) do
		v:SetNetworkedBool('gmp_minigame', true);
		v:GetTable().Tosspot = true;
	end
	
	local Camera;
	
	if Minigame.CameraLocation then
		for k, v in pairs(ents.FindByClass('gmp_camera')) do
			if v.Loc == Minigame.CameraLocation then
				Camera = v;
			end
		end
	end
	
	GAMEMODE.CurCamera = Camera;
		
	for k, v in pairs(player.GetAll()) do
		umsg.Start('gmp_minigame_start', v);
			umsg.Short(Minigame.ID);
			umsg.Bool(v:GetTable().Tosspot or false); 
			
			if Camera and Camera:IsValid() and Camera.Angles then
				umsg.Bool(true);
				umsg.Vector(Camera:GetPos());
				umsg.Angle(Camera.Angles);
			else
				umsg.Bool(false);
			end
		umsg.End();
	end
end

function GM:SetupMinigame ( )
	self.SetupTime = nil;
	
	if self.CurrentMinigame.Setup then 
		self.CurrentMinigame.Setup(); 
	else
		Msg(self.CurrentMinigame.Name .. " missing setup phase.\n");
	end
	
	local PlayerDatabase = {}
	for k, v in pairs(player.GetAll()) do
		if v:InMinigame() then		
			PlayerDatabase[math.random(1, 999999)] = v;
		end
	end
	
	for k, v in pairs(PlayerDatabase) do
		local SendArgs = nil;
		if self.CurrentMinigame.PlayerLoadout then
			local Returned = self.CurrentMinigame.PlayerLoadout(v);
				
			if Returned then
				SendArgs = Returned;
			end
		end
			
		v:SpawnForMinigame(self.CurrentMinigame.SpawnZone, SendArgs);
	end
end

function GM:RunMinigamePreThink ( ) 
	if self.CurrentMinigame.PreThink then
		local MinigameResponse = self.CurrentMinigame.PreThink() or false;
		
		if !MinigameResponse then return false; end
	end
	
	self.MinigamePlayBegin = CurTime() + 3;
	
	umsg.Start('gmp_minigame_start_countdown');
	umsg.End();
	for k,v in pairs(player.GetAll()) do
		if v:InMinigame() then
			v:Freeze(true);
			if self.CurrentMinigame.Name == "Beastly Blackout" or self.CurrentMinigame.Name == "Bug Bait" then v:SetCollisionGroup(COLLISION_GROUP_NONE) else v:SetCollisionGroup(COLLISION_GROUP_WEAPON) end
		end
	end
end

function GM:StartMinigame ( ) 
	self.MinigamePlayBegin = nil;
	
	if self.CurrentMinigame.TimeLimit and self.CurrentMinigame.TimeLimit != 0 then
		self.MinigameTimeLimit = CurTime() + self.CurrentMinigame.TimeLimit;
	else
		self.MinigameTimeLimit = 0;
	end

	if self.CurrentMinigame.Start then 
		local UnfreezePlayers = self.CurrentMinigame.Start() or true;
		
		if UnfreezePlayers then
			for k, v in pairs(player.GetAll()) do
				if v:InMinigame() then
					v:Freeze(false);
				end
				
				if !v:Alive() then v:Spawn(); end
			end
		end
	else
		Msg(self.CurrentMinigame.Name .. " missing start phase.\n");
	end
	
	self.LastMinigameBegin = CurTime();
end

function GM:MinigameThink ( )
	if self.CurrentMinigame.Think then 
		self.CurrentMinigame.Think();
	end
end

function GM:MinigameHitTimeLimit ( ) 		
	for k, v in pairs(player.GetAll()) do
		if v:InMinigame() then
			v:SetNetworkedBool('gmp_minigame', false);
			v:Kill();
			
			if self.CurrentMinigame.TimeLimitReached and self.CurrentMinigame.TimeLimitReached(v) then
				v:GiveStar();
				v:GetTable().TimeOver_Won = true;
			end
		end
	end
	
	self:CleanupMinigame();
	
	for k, v in pairs(player.GetAll()) do
		umsg.Start('gmp_minigame_time_up', v);
			umsg.Bool(v:GetTable().TimeOver_Won or false);
		umsg.End();
		
		v:GetTable().TimeOver_Won = nil;
	end
end

function GM:CleanupMinigame ( )
	if !self.GamePlaying then return false; end

	self.GamePlaying = false;
	self.NextGameStart = CurTime() + GAMEMODE.CountdownTime;

	if self.CurrentMinigame.Cleanup then 
		self.CurrentMinigame.Cleanup()
	else
		Msg(self.CurrentMinigame.Name .. " missing start phase.\n");
	end
end

function GM:CheckMinigameOver ( )
	if !self.CurrentMinigame then return false; end

	local NumPlayersRemaining = 0;
	for k, v in pairs(player.GetAll()) do
		if v:InMinigame() then
			NumPlayersRemaining = NumPlayersRemaining + 1;
		end
	end
		
	if (NumPlayersRemaining <= 1 and self.CurrentMinigame.LastStanding) or NumPlayersRemaining == 0 then
		for k, v in pairs(player.GetAll()) do
			if v:InMinigame() then
				v:SetNetworkedBool('gmp_minigame', false);
				umsg.Start('gmp_minigame_win', v); umsg.End();
				v:Kill();
						
				v:GiveStar();
				ChatNotify(v:Nick()..' has won!')
			end
		end
			
		umsg.Start('gmp_minigame_restart_countdown'); umsg.End();
			
		self:CleanupMinigame();
	end
end
