---------------------
-- TriviaPanel
---------------------

include("panel.lua")
include("shared.lua")

ENT.Width = 1024
ENT.Height = 768
ENT.CamScale = 0.0202

--ENT.RenderGroup = RENDERGROUP_BOTH

AccessorFunc( ENT, "i_State", "State" )

--Panel States
local STATE_DISABLED = -1
local STATE_DEFAULT = 0
local STATE_TOOFAR = 1

function ENT:Initialize()
	local Radius = math.max(self.Width, self.Height)
	self:SetRenderBounds(Vector() * -Radius, Vector() * Radius)
end

function ENT:Draw()
	
	self.Entity:DrawModel()
	
	if(!TRIVIAPANEL or !TRIVIAPANEL:IsValid()) then
		return
	end
	
	TRIVIAPANEL.Screen = self.Entity
	
	if(!TRIVIAPANEL:IsVisible()) then return end
		
	self.nextDistCheck = self.nextDistCheck or CurTime()
	if( CurTime() >= self.nextDistCheck ) then
		
		self.nextDistCheck = CurTime() + math.min( 1.5, (self.lastDist or 200) / 800 )
		local pl = LocalPlayer()
		if( !IsValid( pl ) ) then return end
		
		local pos = pl:EyePos() - self:GetPos()
		if(	math.abs( pos.x ) > 400	||
			math.abs( pos.y ) > 400	||
			math.abs( pos.z ) > 400	) then
			if( self:GetState() != STATE_TOOFAR ) then
				self:SetState( STATE_TOOFAR )
				return
			end
		elseif( self:GetState() == STATE_TOOFAR ) then
			self.InTime = RealTime()
			self:SetState( STATE_DEFAULT )
		end
		
		self.lastDist = math.max( pos.x, math.max( pos.y, pos.z ) )
		
	end
	
	local pos = self:GetPos() + (self:GetUp() * self.Height * self.CamScale * 0.5 * 1.145) + (self:GetForward() * 3.25) - (self:GetRight() * self.Width * self.CamScale * 0.5)
	
	self.Pos = pos
	self.LocalPos = self:WorldToLocal( pos )
	
	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetForward(), 180)
	ang:RotateAroundAxis(self:GetUp(), -90)
	ang:RotateAroundAxis(self:GetRight(), 90)
	
	self.Normal = ang:Up()
	
	local eyepos = EyePos()
	
	if( self.Normal:Dot( ( pos - eyepos ):GetNormalized() ) >= 0 ) then
		
		--We are behind the screen, don't draw it
		return
		
	end
	
	TRIVIAPANEL:SetPaintedManually(false)
	TRIVIAPANEL.Screen = self
	TRIVIAPANEL:RestoreCursor()
	
	if( self:GetState() != STATE_TOOFAR ) then
		local eyeang = EyeAngles()
		self.lastEyeAngles = self.lastEyeAngles or eyeang
		if( eyeang != self.lastEyeAngles ) then
			TRIVIAPANEL:UpdateCursor()
		end
		self.lastEyeAngles = eyeang
		
		self.lastEyePos = self.lastEyePos or eyepos
		if( eyepos != self.lastEyePos ) then
			TRIVIAPANEL:UpdateCursor()
		end
		self.lastEyePos = eyepos
	end
	
	local ok, err = pcall( function(self)
	cam.Start3D2D(pos, ang, self.CamScale)
	
		if( self:GetState() == STATE_TOOFAR ) then
			
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawRect( 0, 0, self.Width, self.Height )
			
		else
			
			surface.SetDrawColor(255, 255, 255, 255)
			TRIVIAPANEL:PaintManual()
			
		end
		
	cam.End3D2D()
	end, self )
	
	if not ok then
		Error( err, "\n" )
	end
	
	TRIVIAPANEL:SetPaintedManually(true)
	TRIVIAPANEL.Screen = nil
	
end

function ENT:IsTranslucent()  
    return false  
end

if(TRIVIAPANEL and TRIVIAPANEL:IsValid()) then
	TRIVIAPANEL:Remove()
end

TRIVIAPANEL = vgui.Create("trivia_main")
TRIVIAPANEL:SetVisible(true)
TRIVIAPANEL:SetSize(ENT.Width, ENT.Height)
TRIVIAPANEL:Center()
TRIVIAPANEL:InvalidateLayout(true)
TRIVIAPANEL:NewQuestion("What is love?", {"A conundrum of philosophy", "Baby don't hurt me", "We're no strangers to it", "Date Rape"})
