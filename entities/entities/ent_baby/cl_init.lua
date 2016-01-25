
include('shared.lua')


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	self.BabyCryingSound = CreateSound(self, Sound('gmp/baby.mp3'));
	table.insert(GAMEMODE.AutoStopSounds, {self, self.BabyCryingSound});
	self.Duration = SoundDuration(Sound('gmp/baby.mp3'));
end

/*---------------------------------------------------------
   Name: DrawPre
---------------------------------------------------------*/
function ENT:Draw()
	if !self.NextBabyCryPlay or self.NextBabyCryPlay < CurTime() then
		self.NextBabyCryPlay = CurTime() + self.Duration;
		
		self.BabyCryingSound:Stop();
		self.BabyCryingSound:Play();
	end

	self:DrawModel()
end

