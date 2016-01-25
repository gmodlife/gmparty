function GM.GetF4 ( UMsg )
	if GAMEMODE.AchievementsScreen then
		GAMEMODE.AchievementsScreen:Remove();
		GAMEMODE.AchievementsScreen = nil;
	end


	
	GAMEMODE.AchievementsScreen = vgui.Create('gmr2_achievements');
end
usermessage.Hook('tf2td_achv', GM.GetF4);

function GM.ReceiveNotification ( UMsg )
	local Message = UMsg:ReadString();
	GAMEMODE:AddNotify(Message, NOTIFY_GENERIC, 15);
end
usermessage.Hook('gmp_notify', GM.ReceiveNotification);

function GM.MinigameInfo_Waiting ( UMsg )
	GAMEMODE.WaitingForPlayers = true;
	GAMEMODE.GamePlaying = false;
	GAMEMODE.HudStartDisplay = 0;
	GAMEMODE.CounterValue = 0;
	GAMEMODE.FakeTime_End = nil;
	GAMEMODE.FakeTime_Start = nil;
	GAMEMODE.HeartColorOverride = nil;
	
	GAMEMODE.Camera_Pos = nil;
	GAMEMODE.Camera_Ang = nil;
end
usermessage.Hook('gmp_minigame_waiting', GM.MinigameInfo_Waiting);

function GM.MinigameInfo_RestartCountdown ( UMsg )
	GAMEMODE.WaitingForPlayers = false;
	GAMEMODE.NextGameStart = CurTime() + GAMEMODE.CountdownTime;
	GAMEMODE.GamePlaying = false;
	GAMEMODE.HudStartDisplay = 0;
	GAMEMODE.CounterValue = 0;
	GAMEMODE.FakeTime_End = nil;
	GAMEMODE.FakeTime_Start = nil;
	GAMEMODE.HeartColorOverride = nil;
	
	GAMEMODE.Camera_Pos = nil;
	GAMEMODE.Camera_Ang = nil;
end
usermessage.Hook('gmp_minigame_restart_countdown', GM.MinigameInfo_RestartCountdown);

function GM.MinigameInfo_Start ( UMsg )
	local MinigameID = UMsg:ReadShort();
	local WereInIt = UMsg:ReadBool();
	local PersueCamera = UMsg:ReadBool();
	
	if PersueCamera then
		GAMEMODE.Camera_Pos = UMsg:ReadVector();
		GAMEMODE.Camera_Ang = UMsg:ReadAngle();
	else
		GAMEMODE.Camera_Pos = nil;
		GAMEMODE.Camera_Ang = nil;
	end
	
	local MINIGAME = GAMEMODE.MinigameDatabase[MinigameID];
	
	GAMEMODE.WaitingForPlayers = false;
	GAMEMODE.NextGameStart = 0;
	GAMEMODE.GamePlaying = true;
	GAMEMODE.CurrentMinigame = MINIGAME;
	GAMEMODE.MinigameStarted = 0;
	GAMEMODE.HudStartDisplay = CurTime() + 1;
	GAMEMODE.CounterValue = 0;
	GAMEMODE.FakeTime_End = nil;
	GAMEMODE.FakeTime_Start = nil;
	GAMEMODE.HeartColorOverride = nil;
	
	if GAMEMODE.ReadyRoomMusic then
		GAMEMODE.ReadyRoomMusic:FadeOut(1);
	end
	
	RunConsoleCommand("r_cleardecals");
	
	if LocalPlayer():InReadyRoom() and WereInIt then
		local MinigameLoadingPanel = vgui.Create('gmp_loading_minigame');
		MinigameLoadingPanel:SetMinigame(MinigameID);
		GAMEMODE.PlaySound(SOUND_START);
	elseif LocalPlayer():InReadyRoom() then
		LocalPlayer():Notify("You could not be fit into this minigame.");
	end
	
	for k, v in pairs(ents.FindByClass("class C_ClientRagdoll")) do
		v:Remove();
	end
end
usermessage.Hook('gmp_minigame_start', GM.MinigameInfo_Start);

function GM.MinigameInfo_StartCountdown ( UMsg )
	GAMEMODE.MinigameStarted = CurTime() + 3;
	
	if LocalPlayer():InMinigame() then
		timer.Simple(3, GAMEMODE.PlaySound, GAMEMODE.CurrentMinigame.Theme, true);
		local MinigameLoadingPanel = vgui.Create('gmp_countdown');
	end
end
usermessage.Hook('gmp_minigame_start_countdown', GM.MinigameInfo_StartCountdown);

function GM.MinigameInfo_TimeUp ( UMsg )
	GAMEMODE.WaitingForPlayers = false;
	GAMEMODE.NextGameStart = CurTime() + GAMEMODE.CountdownTime;
	GAMEMODE.GamePlaying = false;
	GAMEMODE.HudStartDisplay = 0;
	GAMEMODE.CounterValue = 0;
	GAMEMODE.FakeTime_End = nil;
	GAMEMODE.FakeTime_Start = nil;
	GAMEMODE.HeartColorOverride = nil;
	
	GAMEMODE.Camera_Pos = nil;
	GAMEMODE.Camera_Ang = nil;
	
	if LocalPlayer():InMinigame() then
		local SplashVGUI = vgui.Create('gmp_splash');
		local OurBool = UMsg:ReadBool();
		
		if OurBool then
			SplashVGUI:SetVTF('time!_green');
			GAMEMODE.PlaySound(SOUND_WIN);
		else
			SplashVGUI:SetVTF('time!');
			GAMEMODE.PlaySound(SOUND_FAIL);
		end
	end
end
usermessage.Hook('gmp_minigame_time_up', GM.MinigameInfo_TimeUp);

function GM.MinigameInfo_Win ( UMsg )
	local SplashVGUI = vgui.Create('gmp_splash');
	SplashVGUI:SetVTF('win!');
	GAMEMODE.PlaySound(SOUND_WIN);
end
usermessage.Hook('gmp_minigame_win', GM.MinigameInfo_Win);

function GM.MinigameInfo_Loss ( UMsg )
	local SplashVGUI = vgui.Create('gmp_splash');
	SplashVGUI:SetVTF('loss!');
	GAMEMODE.PlaySound(SOUND_FAIL);
end
usermessage.Hook('gmp_minigame_loss', GM.MinigameInfo_Loss);

function GM.GetCounterAdder ( UMsg )
	GAMEMODE.CounterValue = GAMEMODE.CounterValue + 1;
end
usermessage.Hook('gmp_value_counter', GM.GetCounterAdder);

function GM.StartFakeTimer ( UMsg )
	local Time = UMsg:ReadShort();
	
	GAMEMODE.FakeTime_End = CurTime() + Time;
	GAMEMODE.FakeTime_Start = CurTime();
end
usermessage.Hook('gmp_fake_timer', GM.StartFakeTimer);

function GM.StopFakeTimer ( UMsg )
	GAMEMODE.FakeTime_End = nil;
	GAMEMODE.FakeTime_Start = nil;
end
usermessage.Hook('gmp_fake_timer_stop', GM.StopFakeTimer);

function GM.GetGMRAndPERPCash ( UMsg )
	GAMEMODE.GMRCash = UMsg:ReadLong();
	GAMEMODE.PERPCash = UMsg:ReadLong();
end
usermessage.Hook('gmp_gm_cashes', GM.GetGMRAndPERPCash);

function GM.NPCInteraction ( UMsg )
	local Type = UMsg:ReadShort();
	
	if LocalPlayer():GetNetworkedInt('gmp_stars', 0) == 0 then
		LocalPlayer():PrintMessage(HUD_PRINTTALK, "You have no stars to spend!");
		
		return false;
	end
	
	if Type == 1 then
		vgui.Create('shop_cash'):SetCashType(1);
			
		
	elseif Type == 2 then
		// PERP Cash
		--if GAMEMODE.PERPCash == -1 then
			--LocalPlayer():PrintMessage(HUD_PRINTTALK, "You don't have a PERP account yet, so you cannot convert your ----stars to PERP currency.");
			
			--return false;
		--end
		
		vgui.Create('shop_cash'):SetCashType(2);
	else
		Error("Invalid npc interaction id.");
	end
end
usermessage.Hook('gmr_npc_interact', GM.NPCInteraction);

function GM.ReceiveInitialSMF ( UMsg )

	GAMEMODE.MemberID = UMsg:ReadLong();
	GAMEMODE.LoginName = UMsg:ReadString();
	GAMEMODE.NumBans = UMsg:ReadShort();
	GAMEMODE.UnreadMessages = UMsg:ReadShort();
	
	
	
	
end
usermessage.Hook("perp_initial_smf", GM.ReceiveInitialSMF);