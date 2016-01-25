function GM:Initialize ( ) 
	local HUDVGUI = vgui.Create('gmp_hud');
	
	if !file.Exists('gmp_intro.txt','DATA') then
		file.Write('gmp_intro.txt', '1');
		self.LoadingScreen = vgui.Create('gmp_loading');
	end
end

function GM:InitPostEntity ( )
	--RunConsoleCommand("gmp_rsl");
end

function GM:GameInitialize ( ) 
	if self.LoadingScreen then
		local WelcomeSound = self.PlaySound(SOUND_WELCOME);
		local ScreenDieTime = CurTime() + SoundDuration(WelcomeSound) + .75;
		self.LoadingScreen:SetDieTime(ScreenDieTime);
	end
end

function GM.TrueInitializeHook ( ) 
	if LocalPlayer() and LocalPlayer():IsPlayer() then
		GAMEMODE:GameInitialize();
		hook.Remove('Think', 'GM.TrueInitializeHook');
	end
end
hook.Add('Think', 'GM.TrueInitializeHook', GM.TrueInitializeHook);

function GM.BuildManipulationFunctions ( )
	for k, v in pairs(player.GetAll()) do
		if !v:GetTable().BuildManipFunc then
			v:GetTable().BuildManipFunc = true;
			
			function v:BuildBonePositions ( NumBones, NumPhysBones )
				if GAMEMODE.GamePlaying and GAMEMODE.CurrentMinigame and v:InMinigame() and GAMEMODE.CurrentMinigame.ManipulateBones then
					GAMEMODE.CurrentMinigame.ManipulateBones(self, NumBones, NumPhysBones);
				end
			end
			
			v:InvalidateBoneCache();
		end
	end
end
hook.Add('Think', 'GM.BuildManipulationFunctions', GM.BuildManipulationFunctions);

function GM.DoShouldDraw ( Type )
	if Type == "CHudAmmo" or Type == "CHudSecondaryAmmo" or Type == "CHudHealth" or Type == "CHudSuit" or Type == "CHudBattery" or Type == "CHudWeaponSelection" then
		return false;
	end
end
hook.Add("HUDShouldDraw", "GM.DoShouldDraw", GM.DoShouldDraw);

function GM:HUDWeaponPickedUp ( ) end
function GM:HUDItemPickedUp ( ) end
function GM:HUDAmmoPickedUp ( ) end
function GM:HUDDrawPickupHistory ( ) end

function GM:PlayerBindPress (Player, Bind )
	if string.find(string.lower(Bind), "impulse 100") then
		return true;
	end
end

function GM:DrawDeathNotice( x, y ) end

// Minigame camera :)
local MinigameScreen_RT = GetRenderTarget("GMPMinigameScreen512", 512, 512)
function GM.RenderTextures ( )
	if(!IsValid( LocalPlayer() )) then return end
	if !MinigameScreen_RT then return end
	if !GAMEMODE.Camera_Pos or !GAMEMODE.Camera_Ang then return false; end
	if !LocalPlayer():InReadyRoom() then return false; end
	
	local OldRT = render.GetRenderTarget();
	local OldW, OldH = ScrW(), ScrH();
	
	local BackgroundColor = Color(255, 255, 255, 255);
		
	render.SetRenderTarget(MinigameScreen_RT)
	render.Clear(255, 255, 255, 255);
	render.SetViewPort(0, 0, 512, 512)
	
	render.ClearDepth();
	
	local CamData = {};
	CamData.angles = GAMEMODE.Camera_Ang;
	CamData.origin = GAMEMODE.Camera_Pos;
	CamData.x = 0;
	CamData.y = 0;
	CamData.w = 512;
	CamData.h = 512;
	
	render.RenderView(CamData);
	
	render.SetRenderTarget(OldRT);
	render.SetViewPort(0, 0, OldW, OldH);
end
hook.Add('RenderScene', 'GM.RenderTextures', GM.RenderTextures);