ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize() end

function ENT:StartTouch( Ent )
	if !Ent:IsValid() or !Ent:IsPlayer() then return false; end
	
	Ent:Kill();
end

function ENT:KeyValue ( Key, Value )
	if Key == "parent" then
		self:SetParent(ents.FindByName(Value)[1]);
	end
end

function ENT:EndTouch( Ent )

end	

function ENT:Touch ( Ent ) end
function ENT:PassesTriggerFilters( Ent ) return Ent:IsPlayer() end

function ENT:Think() end

function ENT:OnRemove() end
