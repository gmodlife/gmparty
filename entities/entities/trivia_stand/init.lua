AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction( ply, tr )
	
	if ( !tr.Hit ) then return end
	
	local ent = ents.Create( "trivia_stand" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	
	self:SetModel("models/props_combine/breenPod_inner.mdl")
	self:SetMaterial("models/shiny")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:GetPhysicsObject():EnableMotion(false)
	
	local angle = self:GetAngles()
	angle:RotateAroundAxis(self:GetUp(), -90)
	
	self:SetAngles(angle)
	self:SetPos(self:GetPos() + self:GetUp() * -15)
	
	local angle = self:GetAngles()
	angle:RotateAroundAxis(self:GetForward(), 180)
	angle:RotateAroundAxis(self:GetRight(), 30)
	
	self.screen = ents.Create("trivia_panel")
	self.screen:SetPos(self:GetPos() + self:GetForward() * 2 + self:GetUp() * 84)
	self.screen:SetAngles(angle)
	self.screen:SetParent(self)
	self.screen:Spawn()
	self.screen:Activate()
	
end