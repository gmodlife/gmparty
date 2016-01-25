
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


// This is the spawn function. It's called when a client calls the entity to be spawned.
// If you want to make your SENT spawnable you need one of these functions to properly create the entity
//
// ply is the name of the player that is spawning it
// tr is the trace from the player's eyes 
//
function ENT:SpawnFunction( ply, tr ) end


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	local SeatDatabase = list.Get("Vehicles")["Seat_Jeep"];
	
	local Seat = ents.Create("prop_vehicle_prisoner_pod");
	Seat:SetModel(SeatDatabase.Model);
	Seat:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt");
	Seat:SetAngles(self:GetAngles() - Angle(0, 90, 0));
	Seat:SetPos(self:GetPos() - Vector(0, 0, 15));
	Seat:Spawn();
	Seat:Activate();
	
	//Seat:SetSolid(SOLID_NONE);
	Seat:SetMoveType(MOVETYPE_NONE);
	
	if SeatDatabase.Members then table.Merge(Seat, SeatDatabase.Members); end
	if SeatDatabase.KeyValues then
		for k, v in pairs(SeatDatabase.KeyValues) do
			Seat:SetKeyValue(k, v);
		end
	end
	
	Seat:GetTable().ParentCar = Entity;
	Seat.VehicleName = "Jeep Seat";
	Seat.VehicleTable = SeatDatabase;
	Seat.ClassOverride = "prop_vehicle_prisoner_pod";

	Seat:SetColor(Color(255, 255, 255, 0));
	Seat:SetNoDraw(true)

	self:Remove();
	
end

function ENT:StartTouch ( Player )

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
