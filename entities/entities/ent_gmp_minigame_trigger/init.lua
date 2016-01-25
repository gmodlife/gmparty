
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )



/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

end

function ENT:KeyValue ( Key, Value )
	if Key == "type" then
		self:GetTable().ID = Value;
	end
end

function ENT:StartTouch ( Player )
	if !Player or !Player:IsValid() or !Player:IsPlayer() then return false; end
	
	if GAMEMODE.CurrentMinigame and GAMEMODE.CurrentMinigame.MapTrigger then
		GAMEMODE.CurrentMinigame.MapTrigger(Player, self:GetTable().ID);
	end
end

/*---------------------------------------------------------
   Name: PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide( data, physobj )
	
	
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	
end


/*---------------------------------------------------------
   Name: Use
---------------------------------------------------------*/
function ENT:Use( activator, caller )

end
