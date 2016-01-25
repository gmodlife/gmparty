local PlayerMetaTable = FindMetaTable('Player');
PLAYER = PlayerMetaTable

function PlayerMetaTable:InReadyRoom ( )
	return self:GetNetworkedBool('gmp_readyroom', false);
end

function PlayerMetaTable:GetLevel ( )
	return 1
end

function PlayerMetaTable:AddProgress ( )
	return 1
end

function PlayerMetaTable:InMinigame ( )
	return self:GetNetworkedBool('gmp_minigame', false);
end

function PLAYER:GetAccessLevel ( )
	if SERVER then
		return self.AccessLevel or 999;
	else
		return self:GetNetworkedInt("alevel", 999);
	end
end

function PLAYER:HasAccessLevel ( num ) return self:GetAccessLevel() <= num; end

function PLAYER:IsSuperAdmin ( ) return self:GetAccessLevel() <= 2; end
function PLAYER:IsOwner ( ) return self:GetAccessLevel() <= 1; end
function PLAYER:IsAdmin ( ) return self:GetAccessLevel() <= 4; end
function PLAYER:IsVIP ( ) return self:GetAccessLevel() <= 997; end
function PLAYER:IsGoldMember ( ) return (self:GetAccessLevel() == 998 || self:GetAccessLevel() == 997 || self:GetAccessLevel() == 4 || self:IsSuperAdmin()); end