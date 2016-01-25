local PANEL = {}

local Images = {};
Images['1'] = surface.GetTextureID('gmp/1_512');
Images['2'] = surface.GetTextureID('gmp/2_512');
Images['3'] = surface.GetTextureID('gmp/3_512');
Images['start!'] = surface.GetTextureID('gmp/start!_512');

local SoundToPlay = Sound('buttons/button17.wav');

function PANEL:Initialize ( ) 
	
end

function PANEL:PerformLayout ( ) 
	self:SetPos(0, 0);
	self:SetSize(ScrW(), ScrH());
	self.StartTime = CurTime();
	self.DieTime = CurTime() + 4;
	
	self.LastNum = 5;
end

function PANEL:Paint ( )
	if CurTime() > self.DieTime then self:Remove(); return false; end
	
	local TimeFrame = math.floor(CurTime() - self.StartTime);
	
	if self.LastNum != TimeFrame and TimeFrame != 3 then
		surface.PlaySound(SoundToPlay);
		self.LastNum = TimeFrame;
	end
	
	local Image = "";
	if TimeFrame < 3 then
		Image = tostring(3 - TimeFrame);
	else
		Image = "start!";
	end
	
	local Size = math.Clamp(self:GetWide(), 0, 512)
	
	local Alpha = 255;
	if math.floor(CurTime() - self.StartTime + .5) != TimeFrame then
		Alpha = 0;
	elseif math.floor(CurTime() - self.StartTime + .75) != TimeFrame then
		local DisplayTimeLeft = self.StartTime + TimeFrame + .5 - CurTime();
		
		Alpha = math.Clamp((DisplayTimeLeft / .25) * 255, 0, 255);
	else
		local RegularDisplayLeft = self.StartTime + TimeFrame + .25 - CurTime();
		
		Size = Size - (100 * (RegularDisplayLeft / .25)); 
	end
	
	surface.SetDrawColor(255, 255, 255, Alpha);
	surface.SetTexture(Images[Image]);
	surface.DrawTexturedRect((self:GetWide() * .5) - (Size * .5), (self:GetTall() * .5) - (Size * .5), Size, Size);
end

vgui.Register('gmp_countdown', PANEL);