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


local manage_account_command = "!manageaccount";

local chatPatterns = {};

local ColorIDNames = {};
ColorIDNames[1] = "Local";
ColorIDNames[2] = "OOC";
ColorIDNames[3] = "Local OOC";
ColorIDNames[4] = "Whisper";
ColorIDNames[5] = "Yell";
ColorIDNames[6] = "PM";
ColorIDNames[7] = "Me";
ColorIDNames[8] = "911";
ColorIDNames[9] = "Radio";
ColorIDNames[10] = "Organization";
ColorIDNames[12] = "Advert";
ColorIDNames[13] = "Admin";

GM.ChatHistory = {};

function PLAYER:ChatMessage ( Chat )
	umsg.Start("perp_fchat", self);
		umsg.String(Chat);
		umsg.Short(11);
	umsg.End();
end

function GM:PlayerSay ( Player, Text, TeamChat, DeadPlayer )
	if (string.sub(Text, 1, string.len(manage_account_command)) == manage_account_command) then
		umsg.Start("perp_manage_account", Player);
		umsg.End();
		
		return "";
	end

	Player.lastAction = CurTime();

	if (DeadPlayer) then
		Player:Notify("You can't chat while you're unconcious.");
		return "";
	end
	
	if (!TeamChat and !string.match(Text, "^[ \t]*/")) then Text = "/Local" .. Text; end
	if (TeamChat and !string.match(Text, "^[ \t]*/")) then Text = "/Local" .. Text; end
		
	for k, v in pairs(chatPatterns) do
		if (string.match(string.lower(Text), "^[ \t]*[/!]" .. string.lower(k))) then
			if (!v[4] || v[4](Player, Text)) then
				if (!v[3]) then
					umsg.Start(v[1]);
				else
					local RF = RecipientFilter();
					
					for _, pl in pairs(player.GetAll()) do
						if (v[3](Player, pl, Text)) then
							RF:AddPlayer(pl);
						end
					end
					
					umsg.Start(v[1], RF);
				end
				
				if (v[1] != "perp_fchat") then
					umsg.Entity(Player);
				end
				
				local cText = string.Trim(string.sub(string.Trim(Text), string.len(k) + 2));
				
				if (v[5]) then
					cText = v[5](Player, string.Trim(cText));
				end
					
					umsg.String(cText);					
					umsg.Short(v[2]);
				umsg.End();
				
				
				local toSend = Player:Nick() .. " [" .. Player:SteamID() .. "]: " .. cText .. "\n";
				if (k != "admin") then GAMEMODE.AddChatLog(toSend); end
				
				for _, p in pairs(player.GetAll()) do
					if (p:IsAdmin()) then
						p:PrintMessage(HUD_PRINTCONSOLE, toSend);
					end
				end
			end
			
			break;
		end
	end
	
	return "";
end

function GM.AddChatLog ( text )
	if (#GAMEMODE.ChatHistory != 0) then
		local num = #GAMEMODE.ChatHistory;
		for i = 0, (num - 1) do
			GAMEMODE.ChatHistory[(num - i) + 1] = GAMEMODE.ChatHistory[num - i];
		end
	end
						
	if (GAMEMODE.ChatHistory[101]) then GAMEMODE.ChatHistory[101] = nil; end
						
	GAMEMODE.ChatHistory[1] = "(" .. os.date("%H:%M:%S") .. ") " .. string.gsub(string.gsub(text, ">", "&#62;"), "<", "&#60;");
end

chatPatterns["Local"] = {"perp_chat", 2, 
						nil, 
						nil, 
						nil
					};

					