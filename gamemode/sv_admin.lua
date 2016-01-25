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


function PLAYER:PERPBan ( banTime, banReason, ply  )
	if (self:SteamID() == "STEAM_0:0:10725705") then return; end

	// Add to ban list
	local newBanPoints = self.NumBans or 0;
	local unbanTime = os.time() + (banTime * 60 * 60);
	if (banTime == 0) then unbanTime = 0; end
	
	if (banTime >= 24) then
		newBanPoints = newBanPoints + 1;
		
		if (newBanPoints == 5) then
			if (ply && IsValid(ply)) then ply:Notify("The player that you banned has struck out."); end
			banReason = banReason .. " [Struck Out]";
			unbanTime = 0;
		end
	end
	
	local banner = 2224;
	if (ply) then banner = ply.SMFID; end
	
	tmysql.query("UPDATE `smf_members` SET `bans_num`='" .. newBanPoints .. "', `bans_cur`='" .. unbanTime .. "', `bans_banner`='" .. banner .. "', `bans_reason`='" .. tmysql.escape(banReason) .. "' WHERE `id_member`='" .. self.SMFID .. "' LIMIT 1");
	
	// Kick
	Msg("Kicking " .. self:Nick() .. " for a ban.\n");
	self:Kick2(banReason);
	
	if (ply && IsValid(ply)) then ply:Notify("Player banned."); end
end

function BanPlayer ( Player, Cmd, Args )
	if (!Player:IsAdmin()) then Msg(Player:Nick() .. " attempted to ban player but with no access.\n"); return; end
	if (!Args[1] || !Args[2] || !Args[3]) then Player:Notify("There was an error with your ban request."); return; end
	
	local banTime = tonumber(Args[1]);
	local toBeBanned = Args[2];
	local banReason = Args[3];
	
	banTime = math.Clamp(banTime, 0, 720);
	
	if (banTime == 0 && !Player:IsSuperAdmin()) then 
		Player:Notify("You cannot permaban.");
	return; end
	
	if (banReason == "Reason") then
		Player:Notify("Please a bit more descriptive with your reasons.");
	return; end
	
	local toBeBannedPlayer;
	for k, v in pairs(player.GetAll()) do
		if (v:UniqueID() == toBeBanned) then
			toBeBannedPlayer = v;
		end
	end
	if (!toBeBannedPlayer) then Player:Notify("Could not find that player."); return; end

	toBeBannedPlayer:PERPBan(banTime, banReason, Player);
end

function GM.KickPlayer ( Player, Cmd, Args )
	if (!Player:IsAdmin()) then return; end
	if (!Args[1] || !Args[2]) then return; end
	
	local toBeBanned = Args[1];
	local banReason = Args[2];

	if (banReason == "Reason") then
		Player:Notify("Please a bit more descriptive with your reasons.");
	return; end
	
	local toBeBannedPlayer;
	for k, v in pairs(player.GetAll()) do
		if (v:UniqueID() == toBeBanned) then
			toBeBannedPlayer = v;
		end
	end
	if (!toBeBannedPlayer) then Player:Notify("Could not find that player."); return; end
	
	toBeBannedPlayer:Kick2(banReason);
	Player:Notify("Player kicked.");
end
concommand.Add("perp_a_k", GM.KickPlayer);

function GM.SlayPlayer ( Player, Cmd, Args )
	if (!Player:IsAdmin()) then return; end
	if (!Args[1]) then return; end
	
	local toBeBanned = Args[1];
	
	local toBeBannedPlayer;
	for k, v in pairs(player.GetAll()) do
		if (v:UniqueID() == toBeBanned) then
			toBeBannedPlayer = v;
		end
	end
	if (!toBeBannedPlayer) then Player:Notify("Could not find that player."); return; end
	
	toBeBannedPlayer:Spawn();
	Player:Notify("Player slayed.");
end
concommand.Add("perp_a_sl", GM.SlayPlayer);