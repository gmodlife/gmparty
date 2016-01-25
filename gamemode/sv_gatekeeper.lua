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


Msg("Loading gatekeeper module... ");
require("gatekeeper");

if (gatekeeper) then
	Msg("done!\n");
else
	Msg("failed!\n");
	return;
end

VIP_ONLY = false;

serverBlacklists = {};
serverBans = {};
serverAdmins = {};
serverVIPs = {};

local function manageIncomingConnections ( Name, Pass, SteamID, IP )
	Msg(tostring(Name) .. " [" .. tostring(IP) .. "] joined with steamID " .. tostring(SteamID) .. ".\n");
	
	// We don't wanna mess with this if it's single player.
	if (game.SinglePlayer()) then return; end
	
	// If they don't have steamids block them, as they may be trying to bypass the ban system.
	if (SteamID == "STEAM_ID_UNKNOWN") then return {false, "SteamID Error."}; end
	if (SteamID == "STEAM_ID_PENDING") then return {false, "SteamID Error."}; end
	
	// Get the time for everything.
	local curTime = os.time();
	
	// Check the bans list.
	if (serverBans[SteamID]) then
		local unbanTime = tonumber(serverBans[SteamID]);
		
		if (unbanTime == 0) then
			return {false, "You are permanently banned from Pulsar Effect."};
		elseif (unbanTime <= curTime) then
			tmysql.query("UPDATE `smf_members` SET `bans_cur`='1' WHERE `steamid`='" .. SteamID .. "' LIMIT 1");
		else
			local timeLeft = unbanTime - curTime;
			
			local Minutes = math.floor(timeLeft / 60);
			local Seconds = timeLeft - (Minutes * 60);
			local Hours = math.floor(Minutes / 60);
			local Minutes = Minutes - (Hours * 60);
			local Days = math.floor(Hours / 24);
			local Hours = Hours - (Days * 24);
			
			if (Minutes == 0 && Hours == 0 && Days == 0) then
				return {false, "Banned. Lifted In: " .. Seconds + 1 .. " Seconds"};
			elseif (Hours == 0 && Days == 0) then
				return {false, "Banned. Lifted In: " .. Minutes + 1 .. " Minutes"};
			elseif (Days == 0) then
				return {false, "Banned. Lifted In: " .. Hours + 1 .. " Hours"};
			else
				return {false, "Banned. Lifted In: " .. Days + 1 .. " Days"};
			end
		end
	end
	
	// Check the blacklists
	if (GAMEMODE.IsSerious) then
		if (serverBlacklists[SteamID]) then
			local unbanTime = tonumber(serverBlacklists[SteamID]);
			
			if (unbanTime == 0) then
				return {false, "You are permanently blacklisted from Serious."};
			elseif (unbanTime > curTime) then
				local timeLeft = unbanTime - curTime;
				
				local Minutes = math.floor(timeLeft / 60);
				local Seconds = timeLeft - (Minutes * 60);
				local Hours = math.floor(Minutes / 60);
				local Minutes = Minutes - (Hours * 60);
				local Days = math.floor(Hours / 24);
				local Hours = Hours - (Days * 24);
				
				if (Minutes == 0 && Hours == 0 && Days == 0) then
					return {false, "BL'd from Serious. Lifted In: " .. Seconds + 1 .. " Seconds"};
				elseif (Hours == 0 && Days == 0) then
					return {false, "BL'd from Serious. Lifted In: " .. Minutes + 1 .. " Minutes"};
				elseif (Days == 0) then
					return {false, "BL'd from Serious. Lifted In: " .. Hours + 1 .. " Hours"};
				else
					return {false, "BL'd from Serious. Lifted In: " .. Days + 1 .. " Days"};
				end
			end
		end
	end
	
	// Make sure we're not overloaded.
	if (gatekeeper.GetNumClients().total > GAMEMODE.numPlayers) then
		if (!serverAdmins[SteamID]) then
			return {false, "Server is full."};
		end
	elseif (GAMEMODE.ServerIdentifier == 0 && #serverAdmins != 0) then
		if (!VIP_ONLY && !serverAdmins[SteamID]) then
			return {false, "Server is locked to the public."};
		end
	end
	
	// I guess it's okay if they join...
	return;
end
hook.Add("PlayerPasswordAuth", "manageIncomingConnections", manageIncomingConnections)

local function manageBlacklistCreation ( res )
	if (!res || !res[1]) then return; end
	
	serverBlacklists = {};
	
	for k, v in pairs(res) do
		local explodeLarge = string.Explode(";", v[2]);
		
		for _, chunk in pairs(explodeLarge) do
			local explodeMore = string.Explode(",", chunk);
						
			if (#explodeMore == 2 && explodeMore[1] == 'b') then
				serverBlacklists[v[1]] = tonumber(explodeMore[2]);
			end	
		end
	end
end

local function manageBanCreation ( res )
	if (!res || !res[1]) then return; end
	
	serverBans = {};
	
	for k, v in pairs(res) do
		serverBans[v[1]] = v[2];
	end
end

local function manageAdminCreation ( res )
	if (!res || !res[1]) then return; end
	
	for k, v in pairs(res) do
		Msg("Added Administrator: " .. v[1] .. "\n");
		serverAdmins[v[1]] = true;
	end
end

local function manageVIPCreation ( res )
	if (!res || !res[1]) then return; end
	
	for k, v in pairs(res) do
		Msg("Added VIP: " .. v[1] .. "\n");
		serverVIPs[v[1]] = true;
	end
end

local function timerForCreationism ( )
	// Admins shouldn't be changing that much. Lets just check once.
	if (table.Count(serverAdmins) == 0) then
		tmysql.query("SELECT `steamid` FROM `smf_members` WHERE `ID_GROUP`='20' OR `ID_GROUP`='1' OR `ID_GROUP`='2'", manageAdminCreation);
	end
	
	if (GAMEMODE.IsSerious) then
		timer.Simple(1.5, tmysql.query, "SELECT `steamid`, `blacklists` FROM `perp_users` WHERE `blacklists` LIKE '%b,%'", manageBlacklistCreation);
	end
	
	timer.Simple(3, tmysql.query, "SELECT `steamid`, `bans_cur` FROM `smf_members` WHERE `bans_cur`!=1", manageBanCreation);
end
timer.Create('timerForCreationism', 5, 0,timerForCreationism);