GM.TDEnabled = false-- = file.Exists('../sound/vo/heavy_helpmedefend02.wav','DATA');

if !GM.TDEnabled then timer.Simple(5, function() RunConsoleCommand('gmp_notf2', '1') end ); else include('cl_tf2td_helpmenu.lua'); end

Msg('TF2Enabled: ' .. tostring(GM.TDEnabled) .. '\n');

function GM.DrawTDPortalText ( self, RSize )
	if !GAMEMODE.CheckedTF2TDHelp then
		if !file.Exists('showed_tf2td_help.txt','DATA') then
			file.Write('showed_tf2td_help.txt', '1');
			
			GAMEMODE.ToggleTF2TDHelp();
		end
		
		GAMEMODE.CheckedTF2TDHelp = true;
	end

	if GetGlobalBool('td_available', false) then
		if LocalPlayer():GetNetworkedInt('gmp_td', 0) == 1 then
			draw.SimpleText("Stand on your preferred team's point", "GMP", self:GetWide() * .5, ScrH() - RSize * .5, self.TextColor, 1, 1);
		elseif LocalPlayer():GetNetworkedInt('gmp_td', 0) > 1 then
			if GetGlobalInt('tdstart', 0) == 0 then
				draw.SimpleText("Waiting for more players", "GMP", self:GetWide() * .5, ScrH() - RSize * .5, self.TextColor, 1, 1);
			else
				draw.SimpleText("Starting in " .. GetGlobalInt('tdstart', 0) .. " seconds", "GMP", self:GetWide() * .5, ScrH() - RSize * .5, self.TextColor, 1, 1);
			end
		end
	else
		draw.SimpleText("No TF2TD servers available", "GMP", self:GetWide() * .5, ScrH() - RSize * .5, self.TextColor, 1, 1);
	end
end

function GM.TDServerAvailable ( )
	surface.PlaySound(Sound('vo/heavy_helpmedefend02.wav'));
end
usermessage.Hook('td_acts', GM.TDServerAvailable);

function GM.TDServerConnect ( UMsg )
	local Pass = UMsg:ReadString();
	local IP = UMsg:ReadString();
	
	RunConsoleCommand('password', Pass);
	timer.Simple(.5, LocalPlayer().ConCommand, LocalPlayer(), "connect " .. IP .. "\n");




end
usermessage.Hook('td_con', GM.TDServerConnect);