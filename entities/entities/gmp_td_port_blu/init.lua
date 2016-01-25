ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize() end

function ENT:StartTouch( Ent )
	if !Ent:IsValid() or !Ent:IsPlayer() then return false; end
	
	Ent:SetNetworkedInt('gmp_td', 3);
	Ent:GetTable().TDQueueTime = CurTime();
	GAMEMODE.RefreshTDServers();
end

function ENT:KeyValue ( Key, Value ) end

function ENT:EndTouch( Ent )
	if !Ent:IsValid() or !Ent:IsPlayer() then return false; end

	Ent:SetNetworkedInt('gmp_td', 1);
	GAMEMODE.RefreshTDServers();
end	

function ENT:Touch ( Ent ) end
function ENT:PassesTriggerFilters( Ent ) return Ent:IsPlayer() end

function ENT:Think() end

function ENT:OnRemove() end
