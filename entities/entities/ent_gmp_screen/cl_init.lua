include('shared.lua')

local MinigameScreen_Texture = surface.GetTextureID('gmp/minigame_stream');
local MinigameScreen_Material = Material('gmp/minigame_stream');
local MinigameScreen_RT = GetRenderTarget("GMPMinigameScreen512", 512, 512)
local MinigameScreen_Backup = surface.GetTextureID('gmp/logo_512');

function ENT:Draw()	
	/*
		
	if MinigameScreen_RT and GAMEMODE.Camera_Pos and GAMEMODE.Camera_Ang then
		local NewRT = MinigameScreen_RT
			
		local OldRT = render.GetRenderTarget();
		local OldW, OldH = ScrW(), ScrH();
			
		render.SetRenderTarget( NewRT )
		render.Clear(255, 255, 255, 255);
		render.SetViewPort(0, 0, 256, 256)

		render.ClearDepth();
		
		local CamData = {};
		CamData.angles = GAMEMODE.Camera_Ang;
		CamData.origin = GAMEMODE.Camera_Pos;
		CamData.x = 0;
		CamData.y = 0;
		CamData.w = 256;
		CamData.h = 256;
		render.RenderView(CamData);
			
		render.SetRenderTarget(OldRT)
	end
	
	*/

	cam.Start3D2D(self:GetPos(), self.Angle, 1 / self.Scale)
		if !MinigameScreen_RT then
			surface.SetDrawColor(255, 225, 225, 255)
			surface.SetTexture(MinigameScreen_Texture);
			surface.DrawTexturedRect(self.X, self.Y, self.W, self.H);
		elseif !GAMEMODE.Camera_Pos or !GAMEMODE.Camera_Ang or !LocalPlayer():InReadyRoom() then
			surface.SetDrawColor(255, 225, 225, 255)
			//surface.DrawRect(self.X, self.Y, self.W, self.H);
			surface.SetTexture(MinigameScreen_Backup);
			surface.DrawTexturedRect(self.X, self.Y, self.W, self.H);
		else
			MinigameScreen_Material:SetTexture("$basetexture", MinigameScreen_RT)
			surface.SetDrawColor(255, 225, 225, 255)
			surface.SetTexture(MinigameScreen_Texture);
			surface.DrawTexturedRect(self.X, self.Y, self.W, self.H);
		end
	cam.End3D2D();
end

local NumOffset = 0;
function ENT:Initialize ( )
	local W, H = 154, 110;

	self.OBBMin = self:LocalToWorld(Vector(-5, W * -.5, H * -.5));
	self.OBBMax = self:LocalToWorld(Vector(5, W * .5, H * .5));
	
	self:SetRenderBoundsWS(self:GetTable().OBBMin, self:GetTable().OBBMax);
	
	local Old_Angle = self:GetAngles();
	self.Angle = self:GetAngles();
	self.Angle:RotateAroundAxis(self.Angle:Right(), -90)
	self.Angle:RotateAroundAxis(self.Angle:Up(), 90)
	
	local OBBMin, OBBMax = self.OBBMin, self.OBBMax;
		
	local YDist = OBBMax:Distance(Vector(OBBMax.x, OBBMax.y, OBBMin.z));
	local XDist = OBBMax:Distance(Vector(OBBMin.x, OBBMin.y, OBBMax.z));
		
	self.Scale = 3;
		
	self.X = XDist * -(self.Scale * .5);
	self.Y = YDist * -(self.Scale * .5);
	self.W = XDist * self.Scale;
	self.H = YDist * self.Scale;
end


function ENT:Think() end
function ENT:DrawTranslucent() self:Draw(); end
function ENT:BuildBonePositions( NumBones, NumPhysBones ) end
function ENT:SetRagdollBones( bIn ) self.m_bRagdollSetup = bIn; end
function ENT:DoRagdollBone( PhysBoneNum, BoneNum ) end
