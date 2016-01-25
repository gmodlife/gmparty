local PANEL = {}

local Images = {};
Images['loss!'] = surface.GetTextureID('gmp/loss!_512');
Images['win!'] = surface.GetTextureID('gmp/win!_512');
Images['time!'] = surface.GetTextureID('gmp/time!_512');
Images['time!_green'] = surface.GetTextureID('gmp/time!_green_512');

function PANEL:Initialize ( ) 
	
end

function PANEL:PerformLayout ( ) 
	self:SetPos(0, 0);
	self:SetSize(ScrW(), ScrH());
end

function PANEL:SetVTF ( VTF ) 
	self.ToUseImage = Images[VTF];
	self.StartTime = CurTime();
	self.EndTime = CurTime() + 4;
	self.HalfTime = (self.EndTime - self.StartTime) * .25
end

function PANEL:Paint ( )
	if CurTime() > self.EndTime then self:Remove(); return false; end
	
	local Size = math.Clamp(self:GetWide(), 0, 512)
	local Alpha = 255;
	
	if self.StartTime + self.HalfTime > CurTime() then
		// Still enlarging
		local TimeLeft = self.StartTime + self.HalfTime - CurTime();
		local Percent = TimeLeft / self.HalfTime;
		
		Size = Size - (100 * Percent);
	else
		local TimeLeft = self.EndTime - CurTime();
		local Percent = TimeLeft / self.HalfTime;
		
		Alpha = math.Clamp(Percent * 255, 0, 255);
	end
	
	surface.SetDrawColor(255, 255, 255, Alpha);
	surface.SetTexture(self.ToUseImage);
	surface.DrawTexturedRect((self:GetWide() * .5) - (Size * .5), (self:GetTall() * .5) - (Size * .5), Size, Size);
end

vgui.Register('gmp_splash', PANEL);