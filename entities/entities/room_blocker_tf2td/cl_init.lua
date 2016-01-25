
include('shared.lua')

ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()	
	self.OBBMax, self.OBBMin = self:LocalToWorld(Vector(5, 50, 25)), self:LocalToWorld(Vector(-5, -50, -75));
	
	self:SetRenderBoundsWS(self.OBBMin, self.OBBMax);
	
	self.Angle = Angle(180, 0, -90);
	
	local OBBMin, OBBMax = self.OBBMin, self.OBBMax;
		
	local YDist = OBBMax:Distance(Vector(OBBMax.x, OBBMax.y, OBBMin.z - 25));
	local XDist = OBBMax:Distance(Vector(OBBMin.x, OBBMin.y, OBBMax.z - 25));
		
	self.Scale = 3;
		
	self.X = XDist * -(self.Scale * .5);
	self.Y = YDist * -(self.Scale * .5);
	self.W = XDist * self.Scale;
	self.H = YDist * self.Scale;
	
	self:SetSolid(SOLID_NONE); 
end



/*---------------------------------------------------------
   Name: DrawPre
---------------------------------------------------------*/
function ENT:Draw()
	//if GAMEMODE.TDEnabled then return false; end
	
	local Mid = self:LocalToWorld(self:OBBCenter());
	
	local Dist = math.Clamp(1.2 - (LocalPlayer():GetPos():Distance(self:GetPos()) / 750), 0, 1)
end

function ENT:Think ( )
	self:SetNotSolid(true);
end

