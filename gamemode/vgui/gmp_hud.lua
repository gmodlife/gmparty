local PANEL = {}
local Star = surface.GetTextureID("gmp/star_512");
local Heart = surface.GetTextureID("gmp/heart_512");
local Counter = surface.GetTextureID("gmp/counter_512");
local StarSmall = surface.GetTextureID("gmp/star_64");
local Clock = surface.GetTextureID("gmp/clock_512");
local Clock_Line = surface.GetTextureID("gmp/clock_line_512");
local Clock_Hand = surface.GetTextureID("gmp/clock_hand_512");

surface.CreateFont('PEChatFont', {size=14, weight=1000, antialias=true, font="Tahoma"});

function PANEL:Initialize ( ) 

end

function PANEL:PerformLayout ( ) 
	self:SetPos(0, 0);
	self:SetSize(ScrW(), ScrH());
	
	self.TextAimColor = Color(255, 226, 105);
end

function PANEL:Paint ( )
	local border = 5;
	local availableWidth = self:GetWide() - border * 6;
	local widthPer = availableWidth / 5;
	local heightPer = widthPer * .2;

	self.TextColor = nil;
	local Sine = math.sin(CurTime() * 2);
	
	local R_Change = 255 - self.TextAimColor.r;
	local G_Change = 255 - self.TextAimColor.g;
	local B_Change = 255 - self.TextAimColor.b;
	local R_Adjust = R_Change * .5;
	local G_Adjust = G_Change * .5;
	local B_Adjust = B_Change * .5;
	local R_Throw = (255 - R_Adjust) + (R_Adjust * Sine);
	local G_Throw = (255 - G_Adjust) + (G_Adjust * Sine);
	local B_Throw = (255 - B_Adjust) + (B_Adjust * Sine);
	
	self.TextColor = Color(R_Throw, G_Throw, B_Throw, 255);

	
	//if !TRIVIAPANEL or !TRIVIAPANEL:IsVisible() then
		if !LocalPlayer() or !LocalPlayer():IsPlayer() then
			self:DrawLobby();
		else
			if LocalPlayer():InMinigame() and (GAMEMODE.HudStartDisplay and GAMEMODE.HudStartDisplay < CurTime() and GAMEMODE.HudStartDisplay != 0) then
				self:DrawMinigame();
			elseif LocalPlayer():InReadyRoom() then
				self:DrawReadyRoom();
			else
				self:DrawLobby();
			end
		end
	//end
	
	local xBuffer = 160;
	
	surface.SetFont("PEChatFont");
	local _, y = surface.GetTextSize("what");
	local startY = self:GetTall() - border * 30 - heightPer - y - 8;
	
	if (GAMEMODE.ChatBoxOpen) then
		local ourType = "Local";
		if (GAMEMODE.chatBoxIsOOC) then ourType = "Local"; end
		
		local drawText = GAMEMODE.chatBoxText;
		
		for k, v in pairs(GAMEMODE.chatPrefixes) do
			if (string.match(string.lower(GAMEMODE.chatBoxText), "^[ \t]*[!/]" .. string.lower(k))) then
				
				ourType = v;
				drawText = string.Trim(string.sub(string.Trim(drawText), string.len(k) + 2));
				
				break;
			end
		end
	
		surface.SetFont("PEChatFont");
		local x, y = surface.GetTextSize(ourType .. ": " .. drawText);
		
		draw.RoundedBox(4, xBuffer, startY, x + 10, y, Color(255, 255, 255, 200))
		
		if (math.sin(CurTime() * 5) * 10) > 0 then
			drawText = drawText .. "|";
		end
		
		draw.SimpleText(ourType .. ": " .. drawText, "PEChatFont", xBuffer + 4, startY + y * .5, Color(0, 0, 0, 200), 0, 1);
		draw.SimpleText(ourType .. ": " .. drawText, "PEChatFont", xBuffer + 4, startY + y * .5, Color(0, 0, 0, 200), 0, 1);
	end
	
	if (#GAMEMODE.chatRecord > 0) then
		for i = math.Clamp(#GAMEMODE.chatRecord - GAMEMODE.linesToShow, 1, #GAMEMODE.chatRecord), #GAMEMODE.chatRecord do
			local tab = GAMEMODE.chatRecord[i];
			
			if (GAMEMODE.ChatBoxOpen || tab[1] + 15 >= CurTime()) then
				local Alpha = 255;
				
				if (!GAMEMODE.ChatBoxOpen && tab[1] + 10 < CurTime()) then
					local TimeLeft = tab[1] + 15 - CurTime();
					Alpha = (255 / 5) * TimeLeft;
				end

				local posX, posY = xBuffer, startY - y * (1.5 + (#GAMEMODE.chatRecord - i));
				
				if tab[3] then
					local col = Color(tab[3].r, tab[3].g, tab[3].b, Alpha);
					
					draw.SimpleText(tab[2] .. ": ", "PEChatFont", posX + 1, posY + 1, Color(0, 0, 0, Alpha), 2);
					draw.SimpleText(tab[2] .. ": ", "PEChatFont", posX + 1, posY + 1, Color(0, 0, 0, Alpha), 2);
					
					if (tab[6]) then
						local Cos = math.abs(math.sin(CurTime() * 2));
						
						draw.SimpleTextOutlined(tab[2] .. ": ", "PEChatFont", posX, posY, col, 2, 0, 1, Color(Cos * tab[6].r, Cos * tab[6].g, Cos * tab[6].b, math.Clamp(Alpha * Cos, 0, 255)));
						draw.SimpleTextOutlined(tab[2] .. ": ", "PEChatFont", posX, posY, col, 2, 0, 1, Color(Cos * tab[6].r, Cos * tab[6].g, Cos * tab[6].b, math.Clamp(Alpha * Cos, 0, 255)));
					else
						draw.SimpleText(tab[2] .. ": ", "PEChatFont", posX, posY, col, 2);
						draw.SimpleText(tab[2] .. ": ", "PEChatFont", posX, posY, col, 2);
					end
				end
				
				local col = Color(tab[5].r, tab[5].g, tab[5].b, Alpha);
				draw.SimpleText(tab[4], "PEChatFont", posX + 1, posY + 1, Color(0, 0, 0, Alpha));
				draw.SimpleText(tab[4], "PEChatFont", posX + 1, posY + 1, Color(0, 0, 0, Alpha));
				draw.SimpleText(tab[4], "PEChatFont", posX, posY, col);
				draw.SimpleText(tab[4], "PEChatFont", posX, posY, col);
			end
		end
	end
end

function PANEL:DrawLobbyBG ( ) 
	local Size = ScrH() * .3;
	local RSize = Size * .3;
	
	if !LocalPlayer():GetNetworkedBool('intrivia', false) then
		surface.SetDrawColor(0, 0, 0, 255);
		surface.DrawRect(0, ScrH() - RSize, ScrW(), RSize);
	end
	
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetTexture(Star);
	surface.DrawTexturedRect(Size * -.2, ScrH() - Size * .8, Size, Size);
	
	
	if LocalPlayer() and LocalPlayer():IsPlayer() then
		draw.SimpleText(LocalPlayer():GetNetworkedInt('gmp_stars', 0), "GMP_Large_2", Size * .33, ScrH() - (Size * .3), Color(0, 0, 0, 150), 1, 1);
	end
end

function PANEL:DrawLobby ( ) 
	self:DrawLobbyBG();
	
	local Size = ScrH() * .3;
	local RSize = Size * .3;
	
	if LocalPlayer():GetNetworkedInt('gmp_td', 0) > 0 then
		GAMEMODE.DrawTDPortalText(self, RSize);
	else
		draw.SimpleText("Enter center room to queue for GMod Party", "GMP", self:GetWide() * .5, ScrH() - RSize * .5, self.TextColor, 1, 1);
	end
end

function PANEL:DrawReadyRoom ( ) 
	self:DrawLobbyBG();
	
	local Size = ScrH() * .3;
	local RSize = Size * .3;
	
	local DrawText = "Waiting for minigame to finish";
	if !GAMEMODE.GamePlaying then
		if GAMEMODE.WaitingForPlayers then
			DrawText = "Waiting on more players";
		else
			local DisplaySeconds = math.Clamp(math.Round(GAMEMODE.NextGameStart - CurTime()), 1, GAMEMODE.CountdownTime);
			
			local Suffix = "s";
			if DisplaySeconds == 1 then Suffix = ""; end
			
			DrawText = "New game in " .. DisplaySeconds .. " second" .. Suffix;
		end
	end
	
	draw.SimpleText(DrawText, "GMP", self:GetWide() * .5, ScrH() - RSize * .5, self.TextColor, 1, 1);
end

function PANEL:DrawClockBase ( Percent )
	local Size = ScrH() * .3;
	local RSize = Size * .5;
	local LOrigin = -20 + RSize;
	local LOrigin2 = LOrigin;
	
	if Percent * 360 >= 300 then
		local Perc = math.Clamp(255 * math.abs(math.sin(CurTime() * 3)), 0, 255);
		surface.SetDrawColor(255, Perc, Perc, 255);
	else
		surface.SetDrawColor(255, 255, 255, 255);
	end
	
	surface.SetTexture(Clock);
	surface.DrawTexturedRect(-20, -20, Size, Size);
	
	surface.SetDrawColor(255, 255, 255, 255);
	
	surface.SetTexture(Clock_Line);
	for i = 1, 12 do
		local Place = (i - 1) * 30;
		
		surface.DrawTexturedRectRotated(LOrigin, LOrigin2, Size, Size, -15 + Place);
	end
	
	surface.SetTexture(Clock_Hand);
	
	if Percent != 0 then
		local ToDo = math.Round(math.Clamp(360 * Percent, 0, 10));
		local AlphaAlloc = 200 / ToDo;
		for i = 1, ToDo do
			//local i = ToDo - k;
			local Alpha = AlphaAlloc * i;
			
			surface.SetDrawColor(255, 255, 255, Alpha);
			surface.DrawTexturedRectRotated(LOrigin, LOrigin2, Size, Size, -44 + ToDo - (360 * Percent) - i);
		end
		
		surface.SetDrawColor(255, 255, 255, 255);
	end
	
	surface.DrawTexturedRectRotated(LOrigin, LOrigin2, Size, Size, -44 - 360 * Percent);
end

function PANEL:DrawClock ( )
	local TimePassed = 0;
	
	if GAMEMODE.MinigameStarted != 0 then
		TimePassed = math.Clamp(CurTime() - GAMEMODE.MinigameStarted, 0, GAMEMODE.CurrentMinigame.TimeLimit);
	end
	
	local Percent = TimePassed / GAMEMODE.CurrentMinigame.TimeLimit;
	
	self:DrawClockBase(Percent);
end

function PANEL:DrawFakeClock ( )
	if !GAMEMODE.FakeTime_End or !GAMEMODE.FakeTime_Start then
		self:DrawClockBase(0);
		return false;
	end
	
	local TotalTime = GAMEMODE.FakeTime_End - GAMEMODE.FakeTime_Start;
	
	local TimePassed = 0;
	if GAMEMODE.MinigameStarted != 0 then
		TimePassed = math.Clamp(CurTime() - GAMEMODE.FakeTime_Start, 0, TotalTime);
	end
	
	local Percent = TimePassed / TotalTime;
		
	if Percent >= 100 then
		GAMEMODE.FakeTime_Start = nil;
		GAMEMODE.FakeTime_End = nil;
	end
	
	self:DrawClockBase(Percent);
end

function PANEL:DrawHealth ( ) 
	local Size = ScrH() * .3;
	local RSize = Size * .1;
	
	if GAMEMODE.HeartColorOverride then
		surface.SetDrawColor(GAMEMODE.HeartColorOverride.r, GAMEMODE.HeartColorOverride.g, GAMEMODE.HeartColorOverride.b, GAMEMODE.HeartColorOverride.a);
	else
		surface.SetDrawColor(255, 100, 100, 255);
		if LocalPlayer():Health() < 25 then
			local Fader = math.abs(math.sin(CurTime() * 3)) * 100;
			surface.SetDrawColor(255, Fader, Fader, 255);
		end
	end
	
	surface.SetTexture(Heart);
	surface.DrawTexturedRect(ScrW() - Size + RSize, ScrH() - Size + RSize * 2, Size, Size);
	
	draw.SimpleText(LocalPlayer():Health(), "GMP_Large_2", ScrW() - Size * .4, ScrH() - Size * .3, Color(0, 0, 0, 150), 1, 1);
end

function PANEL:DrawCounter ( ) 
	local Size = ScrH() * .3;
	local RSize = Size * .1;
	
	surface.SetDrawColor(255, 255, 255, 255);
	
	surface.SetTexture(Counter);
	surface.DrawTexturedRect(ScrW() - Size + RSize, ScrH() - Size + RSize, Size, Size);
	
	draw.SimpleText(GAMEMODE.CounterValue, "GMP_Large_2", ScrW() - Size * .4, ScrH() - Size * .4, Color(0, 0, 0, 255), 1, 1);
end

function PANEL:DrawMinigame ( )
	local DrawnElements = GAMEMODE.CurrentMinigame.HUDElements;
	
	for k, v in pairs(DrawnElements) do
		if v == HUD_HEALTH then
			self:DrawHealth();
		elseif v == HUD_TIME then
			self:DrawClock();
		elseif v == HUD_COUNTER then
			self:DrawCounter();
		elseif v == HUD_FAKE_TIME then
			self:DrawFakeClock();
		end
	end
end

vgui.Register('gmp_hud', PANEL);