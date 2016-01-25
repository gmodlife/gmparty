
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
	
	self.OriginalPos = self:GetPos();
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
end

function ENT:Think ( )
	if self.WhatIsMyType then
		self:SetPos(self.OriginalPos + Vector(math.sin(CurTime() * 3) * 300, math.cos(CurTime() * 3) * 300, 100));
	else
		self:SetPos(self.OriginalPos + Vector(math.sin(CurTime() * 3 + 185) * 300, math.cos(CurTime() * 3 + 185) * 300, 100));
	end
		
	self:NextThink(CurTime() + .1);
	return true;
end

