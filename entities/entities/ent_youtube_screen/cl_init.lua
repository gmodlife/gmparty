// this is now the news screen. kthx.

include('shared.lua')

local SublimeBG = surface.GetTextureID("gmp/sublime_bg");
local NewsHeader = surface.GetTextureID("");
local ProjectorBG = surface.GetTextureID("gmp/projector_bg");

function ENT:Draw()		
	cam.Start3D2D(self:GetPos(), self.Angle, 1 / self.Scale)
		surface.SetDrawColor(255, 225, 225, 25)
		surface.SetTexture(ProjectorBG);
		surface.DrawTexturedRect(self.X, self.Y, self.W, self.H);
	

	cam.End3D2D();
end

local NumOffset = 0;
function ENT:Initialize ( )
	self.OBBMin = self:LocalToWorld(Vector(-5, -124, -60));
	self.OBBMax = self:LocalToWorld(Vector(5, 124, 60));
	
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
	
	http.Fetch('', function ( x, y ) if self then self:GetCurNews(x,y) end end);
end

local function SplitTextLines ( Text, W, Font )
	local SplitText = string.Explode("\n", Text);
	local FinalText = {};
	
	if Font then
		surface.SetFont(Font);
	else
		surface.SetFont('Default');
	end

	local Comp = W - 30;
	local SComp = Comp - 50;
	local LComp = Comp - 40;
	for k, v in pairs(SplitText) do
		local TX, TY = surface.GetTextSize(v);
			
		if TX > Comp then
			local LastSplit = 1;
								
			for i = 1, string.len(v) do
				local LookingText = string.sub(v, LastSplit, i);
				local TEX, TEY = surface.GetTextSize(LookingText);
										
				if TEX >= Comp then
					LastSplit = i + 1;
					table.insert(FinalText, LookingText .. "-");
				elseif TEX >= SComp and string.sub(LookingText, -1) == " " and (!string.find(string.sub(v, i + 1, i + 6), " ") or TEX >= LComp) then
					LastSplit = i + 1;
					table.insert(FinalText, LookingText);
				elseif i == string.len(v) then
					table.insert(FinalText, LookingText);
				end
			end
		else
			table.insert(FinalText, v);
		end
	end
	
	return FinalText;
end

function ENT:GetCurNews ( content, size )
	local Explode = string.Explode("|", content);
	
	local GSubbed = string.gsub(string.gsub(string.gsub(string.gsub(Explode[2] or "News is broken for now. Will be fixed soon.", "&#039;", "'"), "<br />", "\n"), "<br/>", "\n"), "<br>", "\n")
	local GSubbed = string.gsub(string.gsub(string.gsub(string.gsub(GSubbed, '%[/list%]', ""), '%[list%]', ""), '%[/li%]', ""), '%[li%]', "     -     ")
	self.CurNews = SplitTextLines(GSubbed, self.W, "NewsFont");
	
	
	self.CurNewsHeader = Explode[1] or "Error";
end

function ENT:Think() end
function ENT:DrawTranslucent() self:Draw(); end
function ENT:BuildBonePositions( NumBones, NumPhysBones ) end
function ENT:SetRagdollBones( bIn ) self.m_bRagdollSetup = bIn; end
function ENT:DoRagdollBone( PhysBoneNum, BoneNum ) end
