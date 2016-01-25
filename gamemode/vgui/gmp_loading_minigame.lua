local PANEL = {}

function PANEL:Initialize ( ) 
	
end

function PANEL:PerformLayout ( ) 
	self:SetPos(0, 0);
	self:SetSize(ScrW(), ScrH());
end

function PANEL:SetMinigame ( MinigameID )	
	local MINIGAME = GAMEMODE.MinigameDatabase[MinigameID];
	
	self.Title = MINIGAME.Name;
	self.Instructions = MINIGAME.Description;
	
	self.DieTime = CurTime() + GAMEMODE.SetupPhaseTime;
	self.WhiteTime = CurTime() + .5;
	self.StartFade = self.DieTime - 2;
end

function PANEL:Paint ( )
	if CurTime() > self.DieTime then self:Remove(); return false; end
	
	local TimeLeft = self.DieTime - CurTime();
	
	local Alpha = 255;
	if CurTime() < self.WhiteTime then
		local Percentage = (self.WhiteTime - CurTime()) / .5;
		Alpha = 255 - (255 * Percentage);
	elseif CurTime() > self.StartFade then
		local Percentage = (self.DieTime - CurTime()) / 2;
		Alpha = 255 * Percentage;
	end
	
	surface.SetDrawColor(255, 255, 255, Alpha);
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall());
	
	draw.SimpleText(self.Title, "GMP_Large", self:GetWide() * .5, self:GetTall() * .25, Color(255, 50, 50, Alpha), 1, 1);
	draw.SimpleText(self.Instructions, "GMP", self:GetWide() * .5, self:GetTall() * .6, Color(0, 0, 0, Alpha), 1, 1);
end

vgui.Register('gmp_loading_minigame', PANEL);