
local matLight 		= Material( "sprites/light_ignorez" )
local matBeam		= Material( "effects/lamp_beam" )

//ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

include('shared.lua')

function ENT:Initialize()

	self.PixVis = util.GetPixelVisibleHandle()

end

/*---------------------------------------------------------
   Name: Draw
---------------------------------------------------------*/
function ENT:Draw()	
	if !GAMEMODE.CurrentMinigame then return false; end
	
	local Trace = {}
	Trace.start = self:GetPos();
	Trace.endpos = LocalPlayer():GetShootPos();
	Trace.filter = LocalPlayer();
	
	local TraceRes = util.TraceLine(Trace);
	
	if TraceRes.Hit then return false; end
	
	local LightPos = self:GetPos();
	
	
	render.SetMaterial( matLight )
		
	local Visibile	= util.PixelVisible( LightPos, 4, self.PixVis )	
	
	if (!Visibile) then return end
	
	local col = self:GetColor()
	local r,g,b = col.r,col.g,col.b
	
	local Alpha = 255
	local Size = 64;
	
	render.DrawSprite( LightPos, Size, Size, Color(255, 255, 255, Alpha), Visibile )
	render.DrawSprite( LightPos, Size, Size, Color(r, g, b, Alpha), Visibile )
	render.DrawSprite( LightPos, Size, Size, Color(r, g, b, Alpha), Visibile )
	render.DrawSprite( LightPos, Size * 4, Size * 4, Color(r, g, b, Alpha), Visibile )
end

function ENT:DrawTranslucent ( ) 

end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()

end

/*---------------------------------------------------------
   Name: DrawTranslucent
   Desc: Draw translucent
---------------------------------------------------------*/
function ENT:DrawTranslucent()

	
end

/*---------------------------------------------------------
   Overridden because I want to show the name of the 
   player that spawned it..
---------------------------------------------------------*/