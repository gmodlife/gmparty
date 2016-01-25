AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


timer.Simple(5, function()
	local theGuy = ents.Create("ent_jukeboxs")
	theGuy:SetPos(Vector(300.968750, -535.984192, -152.968750))
	theGuy:SetAngles(Angle(0,180,0))
	theGuy:Spawn()
	theGuy:Activate()
end)

function ENT:Initialize()
   self:SetModel("models/Humans/Group01/male_08.mdl")
   
   self:SetHullType( HULL_HUMAN )
   self:SetHullSizeNormal();
   self:SetSolid( SOLID_BBOX )
   self:SetMoveType( MOVETYPE_STEP )
   self:CapabilitiesAdd(  CAP_ANIMATEDFACE | CAP_TURN_HEAD )
   self:SetMaxYawSpeed( 5000 )
  
   //Sets the entity values
   self:SetHealth(self.StartHealth)
   self:SetEnemy(NULL)
   self:SetSchedule(SCHED_IDLE_STAND)
   position = self:GetPos()
   self:SetUseType(SIMPLE_USE)
   
end
function ENT:AcceptInput( input, activator, caller )
	if input == "Use" && activator:IsPlayer() then
		umsg.Start( "GetFood", activator )  
		umsg.End()  
	end
end
   
function ENT:OnTakeDamage(dmg)
	self:SetHealth(100000)
end


function ENT:Think()
end

local function restoreEnergy(ply,cmd,args)
	ply:SetDarkRPVar("Energy", 100)
	ply:AddMoney(-75)
end
concommand.Add("restoreEnergy", restoreEnergy)