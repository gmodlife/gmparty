local LaserMat = Material("tripmine_laser");

function EFFECT:Init( data )
	self.Alpha = 1;
	self.FadingIn = true;
	self.Color = table.Random(LaserColors);
	self.Angle = data:GetAngle();
	self.Position = data:GetStart();
	self.ParentEnt = data:GetEntity();
	self.Entity:SetRenderBounds(Vector() * -512, Vector() * 512)
	
	self.FadeInTime = .2;
	self.StartTime = CurTime();
	self.StartEndTime = CurTime() + .5;
	
	self.NextAnglechange = CurTime() + .05;
end

function EFFECT:Think( )
	if self.NextAnglechange < CurTime() then
		self.Angle = self.Angle + Angle(0, 2, 0);
		self.NextAnglechange = CurTime() + .05
	end
	
	if self.StartTime + self.FadeInTime > CurTime() then
		self.Alpha = ((CurTime() - self.StartTime) / self.FadeInTime) * 255;
	elseif self.StartEndTime < CurTime() then
		self.Alpha = 255 - (((CurTime() - self.StartEndTime) / self.FadeInTime) * 255);
	else
		self.Alpha = 255;
	end
	
	if self.Alpha <= 0 then return false; end
	
	return true
end

function EFFECT:Render()
	local Trace = {};
	Trace.start = self.Position;
	Trace.endpos = self.Position + (self.Angle:Forward() * 50000);
	Trace.filter = {self.Entity, self.ParentEnt};
	
	local TraceRes = util.TraceLine(Trace);
	
	render.SetMaterial(LaserMat)
	render.DrawBeam(Trace.start, TraceRes.HitPos, 35, 0, 10, Color(self.Color.r, self.Color.g, self.Color.b, self.Alpha))
end



