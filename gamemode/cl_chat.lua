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


GM.chatRecord = {};

GM.linesToShow = 10;

local ColorIDs = {};
local ColorIDNames = {};
ColorIDs[1] = Color(240, 230, 140, 255); 				ColorIDNames[1] = "Local";
ColorIDs[2] = Color(255, 255, 255, 255); 				ColorIDNames[2] = "OOC";
ColorIDs[3] = Color(200, 200, 200, 255);				ColorIDNames[3] = "Local OOC";
ColorIDs[4] = Color(135, 206, 235, 255);				ColorIDNames[4] = "Whisper";
ColorIDs[5] = Color(255, 140, 0, 255); 					ColorIDNames[5] = "Yell";
ColorIDs[6] = Color(50, 205, 50, 255); 					ColorIDNames[6] = "PM";
ColorIDs[7] = Color(255, 50, 50, 255); 					ColorIDNames[7] = "Me";
ColorIDs[8] = Color(255, 0, 0, 255); 					ColorIDNames[8] = "911";
ColorIDs[9] = Color(0, 0, 255, 255); 					ColorIDNames[9] = "Radio";
ColorIDs[10] = Color(255, 0, 255, 255); 				ColorIDNames[10] = "Organization";
ColorIDs[11] = Color(0, 255, 0, 255); 					ColorIDNames[11] = "";
ColorIDs[12] = Color(255, 255, 255, 255); 				ColorIDNames[12] = "Advert";
ColorIDs[13] = Color(0, 255, 0, 255); 					ColorIDNames[13] = "Admin";

local newMessageSound = Sound("common/talk.wav");

function GM:StartChat ( teamSay )
	GAMEMODE.chatBoxIsOOC = teamSay;
	GAMEMODE.chatBoxText = "";
	GAMEMODE.ChatBoxOpen = true;
	
	return true;
end

function GM:FinishChat ( )
	GAMEMODE.chatBoxIsOOC = nil;
	GAMEMODE.chatBoxText = nil;
	GAMEMODE.ChatBoxOpen = nil;
end

function GM:ChatTextChanged ( newChat )
	GAMEMODE.chatBoxText = newChat;
end

// This part is handled through UMsgs so baddies can't hear from across the map. Silly exploiters.
function GM:ChatText ( playerID, playerName, text, type )
	if (!LocalPlayer():IsAdmin()) then
		if string.find(text, "joined") then return; end
		if string.find(text, "left") then return; end
	end

	surface.PlaySound(newMessageSound);
	table.insert(GAMEMODE.chatRecord, {CurTime(), "", nil, string.Trim(text), ColorIDs[11], nil});
	Msg(text .. "\n");
end
function GM:OnPlayerChat ( Player, Text, TeamChat, PlayerIsDead ) end

local function getRealChatOOC ( UMsg )
	local pl = UMsg:ReadEntity();
	local text = UMsg:ReadString();
	local id = UMsg:ReadShort();
		
	surface.PlaySound(newMessageSound);
	
	local RPName = pl:Nick();
	
	local glowType;
	if (pl:IsOwner()) then
		glowType = Color(255, 0, 0)
	elseif (pl:IsSuperAdmin()) then
		glowType = Color(0, 255, 0)
	elseif (pl:IsAdmin()) then
		glowType = Color(0, 0, 255)
	end
	
	Msg(RPName .. ": " .. string.Trim(text) .. "\n");
	
	table.insert(GAMEMODE.chatRecord, {CurTime(), RPName, Color(0, 255, 0), string.Trim(text), ColorIDs[id or 1], glowType});
end
usermessage.Hook("perp_ochat", getRealChatOOC);

local function getRealChat ( UMsg )
	getRealChatOOC(UMsg)
end
usermessage.Hook("perp_chat", getRealChat);

function PLAYER:ChatMessage ( Chat )
	table.insert(GAMEMODE.chatRecord, {CurTime(), "", nil, string.Trim(Chat), ColorIDs[11], nil});
end

GM.chatPrefixes = {}
