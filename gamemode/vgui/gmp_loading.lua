local PANEL = {}
local Logo = surface.GetTextureID("gmp/logo_512");

function PANEL:Initialize ( ) 

end

function PANEL:PerformLayout ( ) 
	self:SetPos(0, 0);
	self:SetSize(ScrW(), ScrH());
	self.StartSize = math.Clamp(ScrW(), 0, 256)
	self.EndSize = math.Clamp(ScrW(), 0, 512)
end

function PANEL:SetDieTime ( NewDieTime )	
	self.PureWhite = true;
	self.StartTime = CurTime();
	self.DieTime = NewDieTime;
	self.HalfTimeTime = (self.DieTime - self.StartTime) * .5
	self.HalfTime = self.StartTime + self.HalfTimeTime;
	self.TotalTime = self.DieTime - self.StartTime;
end

function PANEL:Paint ( )
	if !self.PureWhite then
		surface.SetDrawColor(255, 255, 255, 255);
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall());
		return false;
	end
	
	if CurTime() > self.DieTime then self:Remove(); return false; end
	
	local TimeLeft = self.DieTime - CurTime();
	
	local Alpha = 255;
	if CurTime() > self.HalfTime then
		local Percentage = TimeLeft / self.HalfTimeTime;
		Alpha = 255 * Percentage;
	end
	
	local PAlpha = 255;
	if CurTime() > self.HalfTime - 3 then
		local Percentage = TimeLeft / self.HalfTimeTime;
		PAlpha = math.Clamp(255 * Percentage, 0, 255);
	end
	
	surface.SetDrawColor(255, 255, 255, Alpha);
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall());
	
	surface.SetDrawColor(255, 255, 255, PAlpha);
	surface.SetTexture(Logo);
	
	local Size = self.StartSize + self.EndSize * (1 - (TimeLeft / self.TotalTime));
	local HSize = Size * .5;
	surface.DrawTexturedRect((ScrW() * .5) - HSize, (ScrH() * .5) - HSize, Size, Size);
end

vgui.Register('gmp_loading', PANEL);