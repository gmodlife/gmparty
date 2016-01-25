 function GM.SendMinigameNotification ( Text )
	for k, v in pairs(player.GetAll()) do
		if v:IsInMinigame() then
			v:Notify(Text);
		end
	end
end

function GM.SendPlayerNotification ( Text )
	umsg.Start('gmp_notify');
		umsg.String(Text);
	umsg.End();
end

function GM.ConvertMoney ( Player, Command, Args )
	local Type = tonumber(Args[1]);
	local Val = tonumber(Args[2]);
	
	if Val > Player:GetNetworkedInt('gmp_stars', 0) then return false; end
	if Val < 1 then Player:Kick("Haxor"); return false; end
	
	if Type == 1 then
		local Conv = GAMEMODE.GMRConversionRate;
		
		if Player:GetLevel() <= 4 then
			Conv = Conv * GAMEMODE.VIPConversionRateMod;
		end
		
		local Reward = Val * Conv;
	
		tmysql.query("UPDATE `gmr_cash` SET `CASH`=`CASH`+'" .. Reward .. "' WHERE `STEAMID`='" .. Player:SteamID() .. "'");
		
		Player:TakeStars(Val);
	elseif Type == 2 then
		local Conv = GAMEMODE.PERPConversionRate;
		
		if Player:GetLevel() <= 4 then
			Conv = Conv * GAMEMODE.VIPConversionRateMod;
		end
		
		local Reward = Val * Conv;
	
		tmysql.query("UPDATE `perp_users` SET `cash`=`cash`+'" .. Reward .. "' WHERE `steamid`='" .. Player:SteamID() .. "'");
		
		Player:TakeStars(Val);
	end
end
concommand.Add('gmp_conv', GM.ConvertMoney);

function GM.RequestSMFLoad ( Player )
	if (Player.SMFLoaded) then return; end
	Player.SMFLoaded = true;
	
	--Player:LoadSMF();
end
concommand.Add("gmp_rsl", GM.RequestSMFLoad);

local AccessRedirects = {};
AccessRedirects[20]	= 2; // Super Admin
AccessRedirects[1] 	= 1; // Owner
AccessRedirects[2] 	= 3; // Admin
AccessRedirects[9] 	= 996; // VIP
// 997 = VIP + GM
// 998 = GM w/o VIP
// 4 = Admin + GM
local PLAYER = FindMetaTable("Player")
function PLAYER:LoadSMF ( )
	Msg("Loading " .. self:Nick() .. "'s SMF ID... \n");
	
	self.Buddies = self.Buddies or {};
	
	self.AccessLevel = 999;
	local steamID = self:SteamID();
	
	self.PlayerItems = {};

	tmysql.query("SELECT `id_member`, `member_name`, `real_name`, `bans_num`, `id_group`, `unread_messages`, `id_post_group` FROM `smf_members` WHERE `steamid`='" .. steamID .. "' LIMIT 1", function ( PlayerInfo )
	local ID_MEMBER 		= -1;
	local MEMBER_NAME 		= "";
	local REAL_NAME			= self:Nick();
	local NUM_BANS			= 0;
	local ID_GROUP			= 5;
	local ID_POST_GROUP		= 4;
	local UNREAD_MESSAGES	= 0;
	
	if (PlayerInfo && PlayerInfo[1]) then
		ID_MEMBER 		= tonumber(PlayerInfo[1][1]);
		MEMBER_NAME 	= PlayerInfo[1][2];
		REAL_NAME		= PlayerInfo[1][3];
		NUM_BANS		= tonumber(PlayerInfo[1][4]);
		ID_GROUP		= tonumber(PlayerInfo[1][5]);
		ID_POST_GROUP	= tonumber(PlayerInfo[1][7]);
		UNREAD_MESSAGES	= tonumber(PlayerInfo[1][6]);
		
		tmysql.query("UPDATE `smf_members` SET `real_name`='" .. tmysql.escape(self:Nick()) .. "' WHERE `id_member`='" .. ID_MEMBER .. "'");
	end
	
	self.NumBans = NUM_BANS;
	self.DisplayName = REAL_NAME;
	self.LoginName = MEMBER_NAME;
	self.SMFID = ID_MEMBER;
	
	if (AccessRedirects[ID_GROUP]) then
		self.AccessLevel = AccessRedirects[ID_GROUP];
	end
	
	// Find the goldies.
	if (ID_POST_GROUP == 21) then
		if (self.AccessLevel == 996) then
			self.AccessLevel = 997;
		elseif (self.AccessLevel == 999) then
			self.AccessLevel = 998;
		elseif (self.AccessLevel == 3) then
			self.AccessLevel = 4;
		end
	end
	
	umsg.Start("perp_initial_smf", self);
		umsg.Long(ID_MEMBER);
		umsg.String(MEMBER_NAME);
		umsg.Short(NUM_BANS);
		umsg.Short(UNREAD_MESSAGES);
	umsg.End();
	
	self:SetNetworkedInt("alevel", self.AccessLevel);
	
	end);
end
	



