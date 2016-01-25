function GM.GetPlayerTF2Report ( Player, Cmd, Args )
	Player:GetTable().NoTF2 = true;
end
concommand.Add('gmp_notf2', GM.GetPlayerTF2Report);

function GM:ShowSpare1( pl )
	if pl:GetTable().NoTF2 then return false; end
	
	pl.nextShowHelp = pl.nextShowHelp or CurTime()
	if( CurTime() >= pl.nextShowHelp ) then
		pl.nextShowHelp = CurTime() + 0.2
		umsg.Start( "HelpMenu.toggle", pl )
		umsg.End()
	end
	
end

local AvailableServers = {};
function GM.LookForServers ( )
	if true then return false end
	tmysql.query("SELECT `ip`, `id`, `available`, `wave`, `score_red`, `score_blu`, `players_red`, `players_blu` FROM `td_servers`",
		function ( Query )
			if Query[1] and Query[1][1] then
				for k, v in pairs(Query) do
					local ID = tonumber(v[2]);
				
					if tonumber(v[3]) == 1 and !AvailableServers[ID] then
						local NewTable = {};
						NewTable.Discovered = CurTime();
						NewTable.IP = v[1];
						NewTable.ID = ID;
						
						AvailableServers[ID] = NewTable;
					end
					
					local NetworkedString =  tonumber(v[3] or 0) .. ";" .. tonumber(v[4] or 0) .. ";" .. tonumber(v[5] or 0) .. ";" .. tonumber(v[6] or 0);

					
					if GetGlobalString('tdinfo_' .. ID, "") != NetworkedString then
						SetGlobalString('tdinfo_' .. ID, NetworkedString);
					end
					
					local PlayerList_Red_Exploded = string.Explode(';', tostring(v[7] or ""));
					for k, v in pairs(PlayerList_Red_Exploded) do if v == "" or v == " " then PlayerList_Red_Exploded[k] = nil; end end
					local PlayerList_Red = string.Implode(';', PlayerList_Red_Exploded);
					
					local PlayerList_Blu_Exploded = string.Explode(';', tostring(v[8] or ""));
					for k, v in pairs(PlayerList_Blu_Exploded) do if v == "" or v == " " then PlayerList_Blu_Exploded[k] = nil; end end
					local PlayerList_Blu = string.Implode(';', PlayerList_Blu_Exploded);
					
					if GetGlobalString('tdinfo_red_' .. ID, "") != PlayerList_Red then SetGlobalString('tdinfo_red_' .. ID, PlayerList_Red); end
					if GetGlobalString('tdinfo_blu_' .. ID, "") != PlayerList_Blu then SetGlobalString('tdinfo_blu_' .. ID, PlayerList_Blu); end
				end
				
				GAMEMODE.RefreshTDServers();
			end
		end
	);
end
timer.Create('LookForTF2TDServers', 5, 0, GM.LookForServers);

function GM.LaunchTDServer ( )
	local ActiveServer = GAMEMODE.GetActiveTDServer();
	
	if !ActiveServer.MadeAvailable or ActiveServer.MadeAvailable + 10 > CurTime() then return false; end
	
	local PlayersReady = {};
	for k, v in pairs(player.GetAll()) do
		if v:GetNetworkedInt("gmp_td", 0) > 1 then
			table.insert(PlayersReady, v);
			v:GetTable().AuthedTeam = nil;
		end
	end
	
	if table.Count(PlayersReady) > 8 then
		local NumToTrim = table.Count(PlayersReady) - 8;
		
		for i = 1, NumToTrim do
			local Highest = 0;
			local HighestPerp;
			
			for k, v in pairs(PlayersReady) do
				local CompQueue = v:GetTable().TDQueueTime;
				
				if v:GetLevel() <= 4 then
					CompQueue = CompQueue - 60;
				end
				
				if CompQueue > Highest then
					HighestPerp = k;
					Highest = CompQueue;
				end
			end
			
			PlayersReady[HighestPerp]:Notify("You could not be fit into this game.");
			PlayersReady[HighestPerp] = nil;
		end
	end
	
	local MaxEach = math.ceil(table.Count(PlayersReady) / 2);
	
	local NumBlu, NumRed = 0, 0;
	for i = 1, table.Count(PlayersReady) do
		local Highest = CurTime() + 1;
		local HighestPerp;
			
		for k, v in pairs(PlayersReady) do
			if !v:GetTable().AuthedTeam then
				local CompQueue = v:GetTable().TDQueueTime;
					
				
					
				if CompQueue < Highest then
					HighestPerp = k;
					Highest = CompQueue;
				end
			end
		end
			
		local v = PlayersReady[HighestPerp];
		
		local RequestedTeam = v:GetNetworkedInt("gmp_td", 0);
		
		if RequestedTeam == 3 then
			if NumBlu < MaxEach then
				NumBlu = NumBlu + 1;
				v:GetTable().AuthedTeam = 1;
			else
				v:GetTable().AuthedTeam = 3;
			end
		elseif RequestedTeam == 4 then
			if NumRed < MaxEach then
				NumRed = NumRed + 1;
				v:GetTable().AuthedTeam = 2;
			else
				v:GetTable().AuthedTeam = 3;
			end
		else
			v:GetTable().AuthedTeam = 3; 
		end
	end
	
	local TossIP = ActiveServer.IP;
	local TossPW = "dev";
	
	for k, v in pairs(PlayersReady) do
		local PassTeam = v:GetTable().AuthedTeam or 3;
		
		if PassTeam == 3 then
			if NumBlu < MaxEach then
				NumBlu = NumBlu + 1;
				PassTeam = 1;
			else
				PassTeam = 2;
			end
		end
	
		tmysql.query("INSERT INTO `td_auth` VALUES ('" .. ActiveServer.ID .. "', '" .. v:SteamID() .. "', '" .. PassTeam .. "', '" .. v:Nick() .. "')");
	
		umsg.Start('td_con', v);
			umsg.String(TossPW);
			umsg.String(TossIP);
		umsg.End();
	end
	
	tmysql.query("UPDATE `td_servers` SET `available`='0' WHERE `id`='" .. ActiveServer.ID .. "'");
	
	AvailableServers[ActiveServer.ID] = nil;
	ActiveServer = nil;
	GAMEMODE.RefreshTDServers();
end

concommand.Add( "td_injectme", function( pl, cmd, args )
	
	if( !pl:IsAdmin() ) then return end
	local password = args[1]
	local serverid = tonumber( args[2] )
	local ip = args[3]
	local team = tonumber( args[4] )
	if( !password ) then return end
	if( !serverid ) then return end
	if( !ip ) then return end
	
	if( password != "dev" ) then return end
	
	tmysql.query("INSERT INTO `td_auth` VALUES ('" .. serverid .. "', '" .. pl:SteamID() .. "', '" .. (team or math.random(11,12)) .. "', '" .. pl:Nick() .. "')");
	
	umsg.Start('td_con', pl)
		umsg.String(TD_PASSWORD or 'dev')
		umsg.String(ip)
	umsg.End()
	
end )

function GM.LetsGoPlayTD ( )
	local ActiveServer = GAMEMODE.GetActiveTDServer();
		
	if ActiveServer then
		if !GAMEMODE.LastActiveTDServer or GAMEMODE.LastActiveTDServer != ActiveServer.ID then
			ActiveServer.MadeAvailable = CurTime();
			
			umsg.Start('td_acts');
			umsg.End();
		end
		GAMEMODE.LastActiveTDServer = ActiveServer.ID;
	
		if ActiveServer.CountdownStart then
			local TimeLeft = math.Clamp(math.ceil(ActiveServer.CountdownStart + 60 - CurTime()), 0, 60);
			
			if TimeLeft == 0 then
				GAMEMODE.LaunchTDServer();
			end
			
			if TimeLeft != GetGlobalInt('tdstart', 0) then
				SetGlobalInt('tdstart', TimeLeft);
			end
		end
	else
		GAMEMODE.LastActiveTDServer = nil;
		
		if GetGlobalBool('td_available', true) then
			SetGlobalBool('td_available', false);
		end
	end
end
hook.Add('Think', "GM.LetsGoPlayTD", GM.LetsGoPlayTD);

function GM.GetActiveTDServer ( )
	local MostRecent;
	local MostRecentTime = CurTime() + 1;
	
	for k, v in pairs(AvailableServers) do
		if v.Discovered < MostRecentTime then
			MostRecent = k;
			MostRecentTime = v.Discovered;
		end
	end
	
	return AvailableServers[MostRecent];
end

function GM.RefreshTDServers ( )
	if table.Count(AvailableServers) == 0 then SetGlobalBool('td_available', false); return false; end
	
	SetGlobalBool('td_available', true);
	
	local ActiveServer = GAMEMODE.GetActiveTDServer();
	
	local PlayersReady = {};
	for k, v in pairs(player.GetAll()) do
		if v:GetNetworkedInt("gmp_td", 0) > 1 then
			table.insert(PlayersReady, v);
		end
	end
	
	if table.Count(PlayersReady) >= 2 then
		if table.Count(PlayersReady) == 8 then
			GAMEMODE.LaunchTDServer();
		elseif !ActiveServer.CountdownStart then
			ActiveServer.CountdownStart = CurTime();
			SetGlobalInt('tdstart', 60);
		end
	else
		ActiveServer.CountdownStart = nil;
		SetGlobalInt('tdstart', 0);
	end
end
