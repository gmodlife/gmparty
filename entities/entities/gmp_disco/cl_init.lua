include("shared.lua")

function ENT:Initialize ( )
	self.LaserSpawn = CurTime() + .3;
	self.NextRotate = CurTime() + .02;
	self.Entity:SetRenderBounds(Vector() * -1024, Vector() * 1024);
	
	self.POffset = 10;
	self.YOffset = 5;
end

function ENT:Draw()
	self.Entity:DrawModel()
	
	if CurTime() >= self.NextRotate then
		self.NextRotate = CurTime() + .02;
		
		local OurAng = self:GetAngles();
		self:SetAngles(Angle(OurAng.p + self.POffset, OurAng.y + self.YOffset, OurAng.r));
	end
	
	if CurTime() >= self.LaserSpawn then
		self.LaserSpawn = CurTime() + .3;

		for i = 1, 5 do
			local effectdata = EffectData();
			
			effectdata:SetEntity(self);
			effectdata:SetStart(self:GetPos());
			effectdata:SetAngle(Angle(math.random(0, 180), math.random(-180, 180), math.random(-180, 180)));
			util.Effect("gmp_disco_laser", effectdata);
		end
	end
end

