---------------------
-- TriviaPanel
---------------------

AddCSLuaFile("panel.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_office/computer_monitor.mdl")
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetMaterial("models/shiny")
end
