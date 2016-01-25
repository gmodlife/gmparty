///////////////////////////////
// © 2009-2010 Pulsar Effect //
//    All rights reserved    //
///////////////////////////////
// This material may not be  //
//   reproduced, displayed,  //
//  modified or distributed  //
// without the express prior //
// written permission of the //
//   the copyright holder.   //
///////////////////////////////


local PANEL = {};

surface.CreateFont('HUDFont', {size=ScreenScale(12), weight=1000, antialias=true, font="Tahoma"});
surface.CreateFont('PEChatFont', {size=14, weight=1000, antialias=true, font="Tahoma"});
surface.CreateFont('PlayerNameFont', {size=20, weight=1000, antialias=true, font="Tahoma"});

function PANEL:Init ( )
	self:SetAlpha(GAMEMODE.GetHUDAlpha());
	self.LastDisplayCash = 0;
end

function PANEL:PerformLayout ( )
	self:SetPos(0, 0);
	self:SetSize(ScrW(), ScrH());
end

local doorAssosiations = {};

local redBG = surface.GetTextureID("perp2/hud/red");
local greenBG = surface.GetTextureID("perp2/hud/green");
local silverBG = surface.GetTextureID("perp2/hud/silver");
local dgBG = surface.GetTextureID("perp2/hud/dg");
local yellowBG = surface.GetTextureID("perp2/hud/yellow");

local TypingText = surface.GetTextureID("perp2/hud/typing");
local MicText = surface.GetTextureID("perp2/hud/mic");
local currentlyTalkingTexture = surface.GetTextureID("voice/icntlk_pl");
local currentlyRadioTexture = surface.GetTextureID("perp2/radio");
function PANEL:Paint ( )
	local border = 1

	// Typing... / names and stuff
	local FadePoint = ChatRadius_Local;
	local RealDist = ChatRadius_Local * 1.5;
	
	surface.SetFont("PlayerNameFont");
	local w, h = surface.GetTextSize("Player Name");
	
	local ourPos = LocalPlayer():GetPos();
	if (PERP_SpectatingEntity) then ourPos = PERP_SpectatingEntity:GetPos() end
	
	local shootPos = LocalPlayer():GetShootPos();
	if (PERP_SpectatingEntity) then shootPos = PERP_SpectatingEntity:GetPos() end
	
	for k, v in pairs(player.GetAll()) do
		if (v != LocalPlayer() && !v:InVehicle() && v:Alive()) then
			local dist = v:GetPos():Distance(ourPos);
			
			if (dist <= RealDist) then
				local trace = {}
				trace.start = shootPos;
				trace.endpos = v:GetShootPos();
				trace.filter = {LocalPlayer(), v};
				
				if PERP_SpectatingEntity then table.insert(trace.filter, PERP_SpectatingEntity); end

				local tr = util.TraceLine( trace ) 
				
				if (!tr.Hit) then
					local Alpha = 255;
					
					if (dist >= FadePoint) then
						local moreDist = RealDist - dist;
						local percOff = moreDist / (RealDist - FadePoint);
						
						Alpha = 255 * percOff;
					end
					
					local AttachmentPoint = v:GetAttachment(v:LookupAttachment('eyes'));
					if !AttachmentPoint then AttachmentPoint = v:GetAttachment(v:LookupAttachment('head')); end
					
					if (AttachmentPoint) then 
						local realPos = Vector(v:GetPos().x, v:GetPos().y, AttachmentPoint.Pos.z + 10);
						local screenPos = realPos:ToScreen();
						
						if (v:GetUMsgString("typing", 0) == 1) then						
							local pointDown = (realPos + Vector(0, 0, math.sin(CurTime() * 2) * 3)):ToScreen()
							local pointUp = (realPos + Vector(0, 0, 20 + math.sin(CurTime() * 2) * 3)):ToScreen() 
							
							local Size = math.abs(pointDown.y - pointUp.y);
							
							surface.SetDrawColor(255, 255, 255, Alpha);
							surface.SetTexture(TypingText);
							surface.DrawTexturedRect(pointUp.x - Size * .5, pointUp.y, Size, Size);
						elseif GAMEMODE.Options_ShowNames:GetBool() then
							local color = team.GetColor(v:Team());
							
							draw.SimpleTextOutlined(v:GetRPName(), "PlayerNameFont", screenPos.x, screenPos.y - h, Color(255, 255, 255, Alpha), 1, 1, 1, Color(color.r, color.g, color.b, Alpha));
							
							if (v:InVehicle() && v:GetVehicle():GetClass() == "prop_vehicle_jeep") then
								if (LocalPlayer():Team() == TEAM_POLICE) then
									local Speed = tostring(math.Round(v:GetVehicle():GetVelocity():Length() / 17.6));
									draw.SimpleTextOutlined(SpeedText(Speed), "PlayerNameFont", screenPos.x, screenPos.y - h * 2, Color(255, 255, 255, Alpha), 1, 1, 1, Color(0, 0, 255, Alpha));
								end
								
								if (!v:GetVehicle().setVisuals) then
									v:GetVehicle().setVisuals = true;
									v:GetVehicle():SetRenderMode(RENDERMODE_NONE);
								end
							else
								local orgName = v:GetOrganizationName();
								if (orgName && orgName != '' and orgName != 'New Organization') then
									draw.SimpleTextOutlined(orgName, "PlayerNameFont", screenPos.x, screenPos.y - h * 2, Color(255, 255, 255, Alpha), 1, 1, 1, Color(255, 0, 0, Alpha));
								end
							end
							
							if (v:GetNetworkedBool("warrent", false)) then
								draw.SimpleTextOutlined("Arrest Warrent", "PlayerNameFont", screenPos.x, screenPos.y, Color(255, 255, 255, Alpha), 1, 1, 1, Color(color.r, color.g, color.b, Alpha));
							end
						end
					end
				end
			end
		end
	end
	
	// Door Stuff / Vehicles
	local FadePoint = FadePoint * .5;
	local RealDist = RealDist * .5;
	
	local eyeTrace = LocalPlayer():GetEyeTrace();
	
	if (!LocalPlayer():InVehicle() && GAMEMODE.Options_ShowNames:GetBool() && eyeTrace.Entity && IsValid(eyeTrace.Entity) && (eyeTrace.Entity:IsDoor() || eyeTrace.Entity:IsVehicle())) then
		local dist = eyeTrace.Entity:GetPos():Distance(ourPos);
		
		if (dist <= RealDist) then
			local Alpha = 255;
					
			if (dist >= FadePoint) then
				local moreDist = RealDist - dist;
				local percOff = moreDist / (RealDist - FadePoint);
						
				Alpha = 255 * percOff;
			end
			
			if (eyeTrace.Entity:IsDoor()) then
				local Pos = eyeTrace.Entity:LocalToWorld(eyeTrace.Entity:OBBCenter()):ToScreen();
				local doorTable = eyeTrace.Entity:GetPropertyTable();

				if (doorTable) then			
					local doorOwner = eyeTrace.Entity:GetDoorOwner();
					
					if (!doorOwner || !IsValid(doorOwner)) then
						draw.SimpleTextOutlined('For Sale', "RealtorFont", Pos.x, Pos.y, Color(255, 255, 255, Alpha), 1, 1, 1, Color(0, 100, 0, Alpha));
						draw.SimpleTextOutlined(doorTable.Name, "RealtorFont", Pos.x, Pos.y + 25, Color(255, 255, 255, Alpha), 1, 1, 1, Color(0, 100, 0, Alpha));
					else
						draw.SimpleTextOutlined('Owned By ' .. doorOwner:GetRPName(), "RealtorFont", Pos.x, Pos.y, Color(255, 255, 255, Alpha), 1, 1, 1, Color(255, 0, 0, Alpha));
						draw.SimpleTextOutlined(doorTable.Name, "RealtorFont", Pos.x, Pos.y + 25, Color(255, 255, 255, Alpha), 1, 1, 1, Color(255, 0, 0, Alpha));
					end
				elseif (GAMEMODE.Options_ShowUnownableDoors:GetBool()) then
					if (eyeTrace.Entity:IsPoliceDoor()) then
						draw.SimpleTextOutlined('Owned By Police Deperatment', "RealtorFont", Pos.x, Pos.y, Color(255, 255, 255, Alpha), 1, 1, 1, Color(255, 0, 0, Alpha));
					else
						draw.SimpleTextOutlined('Unownable', "RealtorFont", Pos.x, Pos.y, Color(255, 255, 255, Alpha), 1, 1, 1, Color(255, 0, 0, Alpha));
					end
				end
			elseif (eyeTrace.Entity:GetTrueOwner() && IsValid(eyeTrace.Entity:GetTrueOwner()) && eyeTrace.Entity:GetTrueOwner().GetRPName) then
				local Pos = eyeTrace.Entity:LocalToWorld(Vector(eyeTrace.Entity:OBBCenter().x, eyeTrace.Entity:OBBCenter().y, eyeTrace.Entity:OBBMaxs().z + 15)):ToScreen();
				draw.SimpleTextOutlined('Owned By ' .. eyeTrace.Entity:GetTrueOwner():GetRPName(), "RealtorFont", Pos.x, Pos.y, Color(255, 255, 255, Alpha), 1, 1, 1, Color(0, 0, 255, Alpha));
			end
		end
	end
	
	// Arrested
	if (GAMEMODE.UnarrestTime) then
		if (GAMEMODE.UnarrestTime < CurTime()) then GAMEMODE.UnarrestTime = nil; else
			local timeLeft = math.ceil(GAMEMODE.UnarrestTime - CurTime());
			
			draw.SimpleText('You are arrested for another ' .. timeLeft .. ' seconds.', 'SelectSexFont', ScrW() * .5, ScrH() * .25, Color(100+ 100 * math.abs(math.sin(CurTime())), 0, 0, 255), 1, 1);
			draw.SimpleText('You are arrested for another ' .. timeLeft .. ' seconds.', 'SelectSexFont', ScrW() * .5, ScrH() * .25, Color(100+ 100 * math.abs(math.sin(CurTime())), 0, 0, 255), 1, 1);
		end
	end
	
	// HUD
	local border = 5;
	local availableWidth = self:GetWide() - border * 6;
	local widthPer = availableWidth / 5;
	local heightPer = widthPer * .2;
	
	surface.SetDrawColor(150, 150, 150, 255);
		
	surface.SetTexture(redBG);
	surface.DrawTexturedRect(border, self:GetTall() - border - heightPer, widthPer, heightPer);
	
	surface.SetTexture(greenBG);
	surface.DrawTexturedRect(border * 2 + widthPer, self:GetTall() - border - heightPer, widthPer, heightPer);
	
	surface.SetTexture(silverBG);
	surface.DrawTexturedRect(border * 3 + widthPer * 2, self:GetTall() - border - heightPer, widthPer, heightPer);
	
	surface.SetTexture(dgBG);
	surface.DrawTexturedRect(border * 4 + widthPer * 3, self:GetTall() - border - heightPer, widthPer, heightPer);
	
	surface.SetTexture(yellowBG);
	surface.DrawTexturedRect(border * 5 + widthPer * 4, self:GetTall() - border - heightPer, widthPer, heightPer);
	
	local healthStatus = "Healthy";
	local health = LocalPlayer():Health();
	
	if (health < 1) then healthStatus = "Unconcious";
	elseif (health < 20) then healthStatus = "Critically Injured";
	elseif (health < 40) then healthStatus = "Majorly Injured";
	elseif (health < 60) then healthStatus = "Badly Injured";
	elseif (health < 80) then healthStatus = "Mildly Injured";
	elseif (health < 90) then healthStatus = "Slightly Injured";
	elseif (health < 100) then healthStatus	= "Slightly Bruised";
	end
	
	local percent = health / 100;
	
	local color = math.Clamp(percent * 255, 0, 255);
	draw.SimpleText(healthStatus, "HUDFont", border + widthPer * .5, self:GetTall() - border - heightPer * .5, Color(255 - color, color, 0, 200), 1, 1);
	draw.SimpleText((LocalPlayer().Stamina or 100) .. "%", "HUDFont", border * 2 + widthPer * 1.5, self:GetTall() - border - heightPer * .5, Color(255, 255, 255, 200), 1, 1);
	
	if (LocalPlayer():GetPrivateInt("gpoints", 0) != 0) then
		local wht = math.Clamp((255 * .5) + (math.sin(CurTime() * 3) * 255 * .5), 0, 255);
	
		if (LocalPlayer():GetPrivateInt("gpoints", 0) == 1) then
			draw.SimpleText(LocalPlayer():GetPrivateInt("gpoints", 0) .. " Gene Available (F1)", "HUDFont", border * 3 + widthPer * 2.5, self:GetTall() - border - heightPer * .5, Color(255, wht, wht, 200), 1, 1);
		else
			draw.SimpleText(LocalPlayer():GetPrivateInt("gpoints", 0) .. " Genes Available (F1)", "HUDFont", border * 3 + widthPer * 2.5, self:GetTall() - border - heightPer * .5, Color(255, wht, wht, 200), 1, 1);
		end
	elseif (LocalPlayer():InVehicle()) then
		local Speed = tostring(math.Round(LocalPlayer():GetVehicle():GetVelocity():Length() / 17.6));
		draw.SimpleText(SpeedText(Speed), "HUDFont", border * 3 + widthPer * 2.5, self:GetTall() - border - heightPer * .5, Color(255, 255, 255, 200), 1, 1);
	else
		local formattedTime = "0 Seconds";
		local timePlayed = LocalPlayer():GetTimePlayed();
		
		local numMonths = math.floor(timePlayed / (60 * 60 * 24 * 31));
		local numWeeks = math.floor(timePlayed / (60 * 60 * 24 * 7));
		local numDays = math.floor(timePlayed / (60 * 60 * 24));
		local numHours = math.floor(timePlayed / (60 * 60));
		local numMinutes = math.floor(timePlayed / 60);
		local numSeconds = math.floor(timePlayed);
		
		if (numMonths != 0) then formattedTime = numMonths .. " Month"; if (numMonths > 1) then formattedTime = formattedTime .. "s" end
		elseif (numWeeks != 0) then formattedTime = numWeeks .. " Week"; if (numWeeks > 1) then formattedTime = formattedTime .. "s" end
		elseif (numDays != 0) then formattedTime = numDays .. " Day";  if (numDays > 1) then formattedTime = formattedTime .. "s" end
		elseif (numHours != 0) then formattedTime = numHours .. " Hour";  if (numHours > 1) then formattedTime = formattedTime .. "s" end
		elseif (numMinutes != 0) then formattedTime = numMinutes .. " Minute";  if (numMinutes > 1) then formattedTime = formattedTime .. "s" end
		else formattedTime = numSeconds .. " Second"; if (numSeconds > 1) then formattedTime = formattedTime .. "s" end end
		
		draw.SimpleText(formattedTime, "HUDFont", border * 3 + widthPer * 2.5, self:GetTall() - border - heightPer * .5, Color(255, 255, 255, 200), 1, 1);
	end
	
	if (LocalPlayer():GetCash() > self.LastDisplayCash) then
		if (LocalPlayer():GetCash() - self.LastDisplayCash) > 10000 then
			self.LastDisplayCash = self.LastDisplayCash + 1000;
		elseif (LocalPlayer():GetCash() - self.LastDisplayCash) > 1000 then
			self.LastDisplayCash = self.LastDisplayCash + 100;
		elseif (LocalPlayer():GetCash() - self.LastDisplayCash) > 100 then
			self.LastDisplayCash = self.LastDisplayCash + 10;
		else
			self.LastDisplayCash = self.LastDisplayCash + 1;
		end
	elseif (LocalPlayer():GetCash() < self.LastDisplayCash) then
		if (self.LastDisplayCash - LocalPlayer():GetCash()) > 10000 then
			self.LastDisplayCash = self.LastDisplayCash - 1000;
		elseif (self.LastDisplayCash - LocalPlayer():GetCash()) > 1000 then
			self.LastDisplayCash = self.LastDisplayCash - 100;
		elseif (self.LastDisplayCash - LocalPlayer():GetCash()) > 100 then
			self.LastDisplayCash = self.LastDisplayCash - 10;
		else
			self.LastDisplayCash = self.LastDisplayCash - 1;
		end
	end
	
	draw.SimpleText(DollarSign() .. self.LastDisplayCash, "HUDFont", border * 4 + widthPer * 3.5, self:GetTall() - border - heightPer * .5, Color(255, 255, 255, 200), 1, 1);
	
	local text = "No Weapon";
	if (LocalPlayer():Alive() && LocalPlayer():GetActiveWeapon() && LocalPlayer():GetActiveWeapon().Clip1) then
		local clip1 = LocalPlayer():GetActiveWeapon():Clip1();
		local ammo = LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType());
		
		if (clip1 == -1) then
			text = "Unlimited Ammo";
		else
			text = clip1 .. " / " .. ammo;
		end
		
		if (LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physcannon") then
			text = "Unlimited Ammo";
		elseif (LocalPlayer():GetActiveWeapon():GetClass() == "weapon_perp_paramedic_defib") then
			self.lastChargeDisp = self.lastChargeDisp or 0;
			
			if (self.lastChargeDisp > LocalPlayer():GetActiveWeapon().ChargeAmmount) then
				self.lastChargeDisp = self.lastChargeDisp - 1;
			elseif (self.lastChargeDisp < LocalPlayer():GetActiveWeapon().ChargeAmmount) then
				self.lastChargeDisp = self.lastChargeDisp + 1;
			end
			
			text = "Charge: " .. self.lastChargeDisp .. "%";
		elseif (LocalPlayer():GetActiveWeapon():GetClass() == "weapon_perp_paramedic_health") then
			if (LocalPlayer():GetActiveWeapon().LastUse && LocalPlayer():GetActiveWeapon().LastUse + 10 > CurTime()) then
				local left = math.Clamp(math.ceil(10 - (CurTime() - LocalPlayer():GetActiveWeapon().LastUse)), 1, 10);
				
				if (last == 1) then
					text = "Ready In " .. math.ceil(10 - (CurTime() - LocalPlayer():GetActiveWeapon().LastUse)) .. " Second";
				else
					text = "Ready In " .. math.ceil(10 - (CurTime() - LocalPlayer():GetActiveWeapon().LastUse)) .. " Seconds";
				end
			else
				text = "Ready";
			end
		end
	end
	draw.SimpleText(text, "HUDFont", border * 5 + widthPer * 4.5, self:GetTall() - border - heightPer * .5, Color(255, 255, 255, 200), 1, 1);
	
	// talking
	if (GAMEMODE.CurrentlyTalking) then
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetTexture(currentlyTalkingTexture);
		surface.DrawTexturedRect(5, 5, ScrH() * .1, ScrH() * .1);
	end
	
	if (LocalPlayer():Team() != TEAM_CITIZEN && LocalPlayer():Team() != TEAM_MAYOR && LocalPlayer():GetUMsgBool("tradio", false)) then
		surface.SetDrawColor(255, 255, 255, 255);
		surface.SetTexture(currentlyRadioTexture);
		surface.DrawTexturedRect(10 + ScrH() * .1, 5, ScrH() * .1, ScrH() * .1);
	end
	
	// Chat
	local xBuffer = 160;
	
	surface.SetFont("PEChatFont");
	local _, y = surface.GetTextSize("what");
	local startY = self:GetTall() - border * 10 - heightPer - y - 8;
	
	if (GAMEMODE.ChatBoxOpen) then
		local ourType = "Local";
		if (GAMEMODE.chatBoxIsOOC) then ourType = "OOC"; end
		
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

vgui.Register("perp2_hud", PANEL);