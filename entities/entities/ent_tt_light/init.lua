
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local MODEL = Model( "models/props_c17/light_cagelight02_on.mdl" )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self:SetModel( MODEL )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:DrawShadow( false )
end

function ENT:Think ( )
	for k, v in pairs(player.GetAll()) do
		if v:InMinigame() then
			if !v:GetTable().MadeToPoint then
				if v:GetPos():Distance(self:GetPos()) < 100 then
					v:GetTable().MadeToPoint = true;
					v:GetTable().NumTilesReached = v:GetTable().NumTilesReached + 1;
					
					if v:GetTable().NumTilesReached == 5 then
						v:AddProgress(43, 1);
					end
				end
			end
		end
	end
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
end
