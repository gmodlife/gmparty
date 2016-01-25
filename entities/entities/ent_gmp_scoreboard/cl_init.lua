include('shared.lua')

local Logo = surface.GetTextureID('gmp/logo_512');
local TF2BG = surface.GetTextureID("HUD/character_red_bg");
local TF2_Score_Left = surface.GetTextureID("HUD/objectives_flagpanel_bg_left");
local TF2_Score_Right = surface.GetTextureID("HUD/objectives_flagpanel_bg_right");
local TF2_Score_BG = surface.GetTextureID("HUD/objectives_flagpanel_bg_outline");
local TF2_Score_PlayingTo = surface.GetTextureID("HUD/objectives_flagpanel_bg_playingto");

surface.CreateFont('gmpTF2_Small_Secondary', {size=15, weight=400, antialias=true, font="TF2 Secondary"});
surface.CreateFont('gmpTF2_Small_Secondary2', {size=20, weight=400, antialias=true, font="TF2 Secondary"});
surface.CreateFont('gmpTF2_Bold2', {size=37, weight=400, antialias=true, font="TF2 Build"});

ENT.RenderGroup = RENDERGROUP_OPAQUE;

local function WithinBounds ( Number, OtherNumber, Max )
	return ((Number > OtherNumber - Max) and (Number < OtherNumber + Max));
end

local ConsecOffline = {};

function ENT:Draw()		
	local Looking = false;
	
	local XPerUnit = self.W / 248;
	local YPerUnit = self.H / 120;
	
	local HitPos_X, HitPos_Y, Looking;
	if LocalPlayer():GetPos():Distance(self:GetPos()) < 250 then
		local EyeTrace = LocalPlayer():GetEyeTrace();
		local HitPos = EyeTrace.HitPos;
		local OurPos = self:GetPos();
		
		local HitX = WithinBounds(HitPos.x, OurPos.x, 125.1)
		local HitY = WithinBounds(HitPos.y, OurPos.y, 125.4)
		local HitZ = WithinBounds(HitPos.z, OurPos.z, 60)
		
		if HitX and HitY and HitZ then
			Looking = true
			
			local HitPosOffset = HitPos - OurPos;
			
			HitPos_X = XPerUnit * HitPosOffset.x * -1
			HitPos_Y = XPerUnit * HitPosOffset.z * -1
		end
	end
	
	cam.Start3D2D(self:GetPos(), self.Angle, 1 / self.Scale)
		if !GAMEMODE.TDEnabled then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawRect(self.X, self.Y, self.W, self.H);
		
			surface.SetTexture(Logo);
			surface.DrawTexturedRect(self.X + self.W * .5 - self.H * .5, self.Y, self.H, self.H);
		else
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(self.X, self.Y, self.W, self.H);
		
			local NumServers = 0;
			for i = 1, 10 do
				if GetGlobalString('tdinfo_' .. i, "") == "" then
					break;
				else
					NumServers = NumServers + 1;
				end
			end
			
			local Padding = 50;
			
			local ToDoHeight = self.H;
			local ToDoWidth = self.W / NumServers;
			
			for i = 1, NumServers do
				local SplitInfo = string.Explode(';', GetGlobalString('tdinfo_' .. i, ""));
				local Available = tonumber(SplitInfo[1]) or 0;
				local Wave = tonumber(SplitInfo[2]) or 0;
				local Score_Red = tonumber(SplitInfo[3]) or 0;
				local Score_Blu = tonumber(SplitInfo[4]) or 0;
				
				local OurX, OurY = (i - 1) * ToDoWidth, 0;
				
				surface.SetDrawColor(255, 255, 255, 255);
				surface.SetTexture(TF2BG);
				surface.DrawTexturedRect(self.X + OurX, self.Y + OurY, ToDoWidth, ToDoHeight);
				
				draw.SimpleText("Server #" .. i, "gmpTF2_Bold2", self.X + OurX + ToDoWidth * .5, self.Y + OurY + ToDoHeight * .2, Color(255, 255, 255, 255), 1, 1);
				
				local Smaller_W, Smaller_H = (ToDoWidth * .7), (ToDoHeight * .2);
				local Smaller_X, Smaller_Y = self.X + (OurX + ToDoWidth * .5 - Smaller_W * .5), self.Y + OurY + ToDoHeight - Smaller_H * 1.5;
				
				surface.SetTexture(TF2_Score_BG);
				surface.DrawTexturedRect(Smaller_X, Smaller_Y, Smaller_W, Smaller_H);
				surface.SetTexture(TF2_Score_Left);
				surface.DrawTexturedRect(Smaller_X, Smaller_Y, Smaller_W, Smaller_H);
				surface.SetTexture(TF2_Score_Right);
				surface.DrawTexturedRect(Smaller_X, Smaller_Y, Smaller_W, Smaller_H);
				
				local SmallerSmaller_W = (Smaller_W / 2) * 1.2;
								
				surface.SetTexture(TF2_Score_PlayingTo);
				surface.DrawTexturedRect(self.X + OurX + ToDoWidth * .5 - SmallerSmaller_W * .5, Smaller_Y + Smaller_H * .5, SmallerSmaller_W, Smaller_H * .5);
				
				draw.SimpleText("Wave " .. Wave, "gmpTF2_Small_Secondary", self.X + OurX + ToDoWidth * .5, Smaller_Y + Smaller_H * .75, Color(255, 255, 255, 255), 1, 1);
				draw.SimpleText(math.Clamp(Score_Red, 0, 10), "gmpTF2_Bold2", Smaller_X + Smaller_W * .5 + ((Smaller_W  * .5) * .75), Smaller_Y + Smaller_H * .565, Color(255, 255, 255, 255), 1, 1);
				draw.SimpleText(math.Clamp(Score_Blu, 0, 10), "gmpTF2_Bold2", Smaller_X + Smaller_W * .5 - ((Smaller_W  * .5) * .75), Smaller_Y + Smaller_H * .565, Color(255, 255, 255, 255), 1, 1);
				
				local RedPlayersSplit = string.Explode(";", GetGlobalString('tdinfo_red_' .. i, "")) or {};
				local BluPlayersSplit = string.Explode(";", GetGlobalString('tdinfo_blu_' .. i, "")) or {};
				
				surface.SetFont("gmpTF2_Small_Secondary2");
				local TW1, TH1 = surface.GetTextSize("test");
				surface.SetFont("gmpTF2_Bold2");
				local TW2, TH2 = surface.GetTextSize("test");
				
				for k, v in pairs(RedPlayersSplit) do
					draw.SimpleText(v, "gmpTF2_Small_Secondary2", self.X + OurX + ToDoWidth * .5, self.Y + OurY + ToDoHeight * .2 + TH2 * .5 + TH1 * k, Color(255, 200, 200, 255), 1, 1);
				end
				
				for k, v in pairs(BluPlayersSplit) do
					draw.SimpleText(v, "gmpTF2_Small_Secondary2", self.X + OurX + ToDoWidth * .5, self.Y + OurY + ToDoHeight * .2 + TH2 * .5 + TH1 * (#RedPlayersSplit) + TH1 * k, Color(200, 200, 255, 255), 1, 1);
				end
				
				
				
				if Available == 1 then
					draw.SimpleText("Available", "gmpTF2_Bold2", self.X + OurX + ToDoWidth * .5, self.Y + OurY + ToDoHeight * .5, Color(255, 255, 255, 255), 1, 1);
					ConsecOffline[i] = nil;
				elseif Wave == 0 and Score_Blu == 0 and Score_Red == 0 and GetGlobalString('tdinfo_red_' .. i, "") == "" and GetGlobalString('tdinfo_blu_' .. i, "") == "" then
					ConsecOffline[i] = ConsecOffline[i] or CurTime();
					
					if ConsecOffline[i] + 30 < CurTime() then
						draw.SimpleText("Offline", "gmpTF2_Bold2", self.X + OurX + ToDoWidth * .5, self.Y + OurY + ToDoHeight * .5, Color(255, 255, 255, 255), 1, 1);
					else
						draw.SimpleText("Loading", "gmpTF2_Bold2", self.X + OurX + ToDoWidth * .5, self.Y + OurY + ToDoHeight * .5, Color(255, 255, 255, 255), 1, 1);
					end
				else
					ConsecOffline[i] = nil;
				end
			end
		
		/*
						if GetGlobalString('tdinfo_' .. ID, "") != NetworkedString then
				SetGlobalString('tdinfo_' .. ID, NetworkedString);
			end
			
			local PlayerList_Red_Exploded = string.Explode(';', tostring(v['players_red'] or ""));
			for k, v in pairs(PlayerList_Red_Exploded) do if v == "" or v == " " then PlayerList_Red_Exploded[k] = nil; end end
			local PlayerList_Red = string.Implode(';', PlayerList_Red_Exploded);
			
			local PlayerList_Blu_Exploded = string.Explode(';', tostring(v['players_blu'] or ""));
			for k, v in pairs(PlayerList_Blu_Exploded) do if v == "" or v == " " then PlayerList_Blu_Exploded[k] = nil; end end
			local PlayerList_Blu = string.Implode(';', PlayerList_Blu_Exploded);
			
			if GetGlobalString('tdinfo_red_' .. ID, "") != PlayerList_Red then SetGlobalString('tdinfo_red_' .. ID, PlayerList_Red); end
			if GetGlobalString('tdinfo_blu_' .. ID, "") != PlayerList_Blu then SetGlobalString('tdinfo_blu_' .. ID, PlayerList_Blu); end
		*/
			
			
			
			
		end
	cam.End3D2D();
end

local NumOffset = 0;
function ENT:Initialize ( )
	local TraceUp = {};
	local TraceRight = {};
	
	local OP = self:GetPos() + Vector(2, 0, 0);
	
	TraceUp.start = OP;
	TraceUp.endpos = OP + Vector(0, 0, 1000);
	
	TraceRight.start = OP;
	TraceRight.endpos = OP + Vector(1000, 0, 0);
	
	local TraceRight_Res = util.TraceLine(TraceRight);
	local TraceUp_Res = util.TraceLine(TraceUp);
		
	local Dist_R = math.Round(math.abs(TraceRight_Res.HitPos.x - self:GetPos().x));
	local Dist_U = math.Round(math.abs(TraceUp_Res.HitPos.z - self:GetPos().z));

	self.OBBMin = self:LocalToWorld(Vector(-5, -Dist_R, -Dist_U));
	self.OBBMax = self:LocalToWorld(Vector(5, Dist_R, Dist_U));
	
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
